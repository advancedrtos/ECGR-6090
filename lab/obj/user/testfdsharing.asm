
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 00 23 80 00       	push   $0x802300
  800043:	e8 29 18 00 00       	call   801871 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 05 23 80 00       	push   $0x802305
  800057:	6a 0c                	push   $0xc
  800059:	68 13 23 80 00       	push   $0x802313
  80005e:	e8 ad 01 00 00       	call   800210 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 0a 15 00 00       	call   801578 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 22 14 00 00       	call   8014a3 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 28 23 80 00       	push   $0x802328
  800090:	6a 0f                	push   $0xf
  800092:	68 13 23 80 00       	push   $0x802313
  800097:	e8 74 01 00 00       	call   800210 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 b1 0e 00 00       	call   800f52 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 81 28 80 00       	push   $0x802881
  8000ad:	6a 12                	push   $0x12
  8000af:	68 13 23 80 00       	push   $0x802313
  8000b4:	e8 57 01 00 00       	call   800210 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 ac 14 00 00       	call   801578 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 68 23 80 00 	movl   $0x802368,(%esp)
  8000d3:	e8 11 02 00 00       	call   8002e9 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 b8 13 00 00       	call   8014a3 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 ac 23 80 00       	push   $0x8023ac
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 13 23 80 00       	push   $0x802313
  800103:	e8 08 01 00 00       	call   800210 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 60 09 00 00       	call   800a7b <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 d8 23 80 00       	push   $0x8023d8
  80012a:	6a 19                	push   $0x19
  80012c:	68 13 23 80 00       	push   $0x802313
  800131:	e8 da 00 00 00       	call   800210 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 32 23 80 00       	push   $0x802332
  80013e:	e8 a6 01 00 00       	call   8002e9 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 2a 14 00 00       	call   801578 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 80 11 00 00       	call   8012d6 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 0a 1b 00 00       	call   801c71 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 29 13 00 00       	call   8014a3 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 10 24 80 00       	push   $0x802410
  80018b:	6a 21                	push   $0x21
  80018d:	68 13 23 80 00       	push   $0x802313
  800192:	e8 79 00 00 00       	call   800210 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 4b 23 80 00       	push   $0x80234b
  80019f:	e8 45 01 00 00       	call   8002e9 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 2a 11 00 00       	call   8012d6 <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  8001c3:	e8 6b 0a 00 00       	call   800c33 <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800204:	6a 00                	push   $0x0
  800206:	e8 e7 09 00 00       	call   800bf2 <sys_env_destroy>
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800215:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800218:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80021e:	e8 10 0a 00 00       	call   800c33 <sys_getenvid>
  800223:	83 ec 0c             	sub    $0xc,%esp
  800226:	ff 75 0c             	pushl  0xc(%ebp)
  800229:	ff 75 08             	pushl  0x8(%ebp)
  80022c:	56                   	push   %esi
  80022d:	50                   	push   %eax
  80022e:	68 40 24 80 00       	push   $0x802440
  800233:	e8 b1 00 00 00       	call   8002e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800238:	83 c4 18             	add    $0x18,%esp
  80023b:	53                   	push   %ebx
  80023c:	ff 75 10             	pushl  0x10(%ebp)
  80023f:	e8 54 00 00 00       	call   800298 <vcprintf>
	cprintf("\n");
  800244:	c7 04 24 49 23 80 00 	movl   $0x802349,(%esp)
  80024b:	e8 99 00 00 00       	call   8002e9 <cprintf>
  800250:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800253:	cc                   	int3   
  800254:	eb fd                	jmp    800253 <_panic+0x43>

00800256 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	53                   	push   %ebx
  80025a:	83 ec 04             	sub    $0x4,%esp
  80025d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800260:	8b 13                	mov    (%ebx),%edx
  800262:	8d 42 01             	lea    0x1(%edx),%eax
  800265:	89 03                	mov    %eax,(%ebx)
  800267:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80026e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800273:	75 1a                	jne    80028f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800275:	83 ec 08             	sub    $0x8,%esp
  800278:	68 ff 00 00 00       	push   $0xff
  80027d:	8d 43 08             	lea    0x8(%ebx),%eax
  800280:	50                   	push   %eax
  800281:	e8 2f 09 00 00       	call   800bb5 <sys_cputs>
		b->idx = 0;
  800286:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80028c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80028f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002a8:	00 00 00 
	b.cnt = 0;
  8002ab:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002b2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002b5:	ff 75 0c             	pushl  0xc(%ebp)
  8002b8:	ff 75 08             	pushl  0x8(%ebp)
  8002bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c1:	50                   	push   %eax
  8002c2:	68 56 02 80 00       	push   $0x800256
  8002c7:	e8 54 01 00 00       	call   800420 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002cc:	83 c4 08             	add    $0x8,%esp
  8002cf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002db:	50                   	push   %eax
  8002dc:	e8 d4 08 00 00       	call   800bb5 <sys_cputs>

	return b.cnt;
}
  8002e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f2:	50                   	push   %eax
  8002f3:	ff 75 08             	pushl  0x8(%ebp)
  8002f6:	e8 9d ff ff ff       	call   800298 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002fb:	c9                   	leave  
  8002fc:	c3                   	ret    

008002fd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 1c             	sub    $0x1c,%esp
  800306:	89 c7                	mov    %eax,%edi
  800308:	89 d6                	mov    %edx,%esi
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800310:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800313:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800316:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800319:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800321:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800324:	39 d3                	cmp    %edx,%ebx
  800326:	72 05                	jb     80032d <printnum+0x30>
  800328:	39 45 10             	cmp    %eax,0x10(%ebp)
  80032b:	77 45                	ja     800372 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80032d:	83 ec 0c             	sub    $0xc,%esp
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	8b 45 14             	mov    0x14(%ebp),%eax
  800336:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800339:	53                   	push   %ebx
  80033a:	ff 75 10             	pushl  0x10(%ebp)
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	ff 75 e4             	pushl  -0x1c(%ebp)
  800343:	ff 75 e0             	pushl  -0x20(%ebp)
  800346:	ff 75 dc             	pushl  -0x24(%ebp)
  800349:	ff 75 d8             	pushl  -0x28(%ebp)
  80034c:	e8 0f 1d 00 00       	call   802060 <__udivdi3>
  800351:	83 c4 18             	add    $0x18,%esp
  800354:	52                   	push   %edx
  800355:	50                   	push   %eax
  800356:	89 f2                	mov    %esi,%edx
  800358:	89 f8                	mov    %edi,%eax
  80035a:	e8 9e ff ff ff       	call   8002fd <printnum>
  80035f:	83 c4 20             	add    $0x20,%esp
  800362:	eb 18                	jmp    80037c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	56                   	push   %esi
  800368:	ff 75 18             	pushl  0x18(%ebp)
  80036b:	ff d7                	call   *%edi
  80036d:	83 c4 10             	add    $0x10,%esp
  800370:	eb 03                	jmp    800375 <printnum+0x78>
  800372:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800375:	83 eb 01             	sub    $0x1,%ebx
  800378:	85 db                	test   %ebx,%ebx
  80037a:	7f e8                	jg     800364 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	56                   	push   %esi
  800380:	83 ec 04             	sub    $0x4,%esp
  800383:	ff 75 e4             	pushl  -0x1c(%ebp)
  800386:	ff 75 e0             	pushl  -0x20(%ebp)
  800389:	ff 75 dc             	pushl  -0x24(%ebp)
  80038c:	ff 75 d8             	pushl  -0x28(%ebp)
  80038f:	e8 fc 1d 00 00       	call   802190 <__umoddi3>
  800394:	83 c4 14             	add    $0x14,%esp
  800397:	0f be 80 63 24 80 00 	movsbl 0x802463(%eax),%eax
  80039e:	50                   	push   %eax
  80039f:	ff d7                	call   *%edi
}
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a7:	5b                   	pop    %ebx
  8003a8:	5e                   	pop    %esi
  8003a9:	5f                   	pop    %edi
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003af:	83 fa 01             	cmp    $0x1,%edx
  8003b2:	7e 0e                	jle    8003c2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b4:	8b 10                	mov    (%eax),%edx
  8003b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b9:	89 08                	mov    %ecx,(%eax)
  8003bb:	8b 02                	mov    (%edx),%eax
  8003bd:	8b 52 04             	mov    0x4(%edx),%edx
  8003c0:	eb 22                	jmp    8003e4 <getuint+0x38>
	else if (lflag)
  8003c2:	85 d2                	test   %edx,%edx
  8003c4:	74 10                	je     8003d6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c6:	8b 10                	mov    (%eax),%edx
  8003c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003cb:	89 08                	mov    %ecx,(%eax)
  8003cd:	8b 02                	mov    (%edx),%eax
  8003cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d4:	eb 0e                	jmp    8003e4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d6:	8b 10                	mov    (%eax),%edx
  8003d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003db:	89 08                	mov    %ecx,(%eax)
  8003dd:	8b 02                	mov    (%edx),%eax
  8003df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f5:	73 0a                	jae    800401 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fa:	89 08                	mov    %ecx,(%eax)
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	88 02                	mov    %al,(%edx)
}
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800409:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040c:	50                   	push   %eax
  80040d:	ff 75 10             	pushl  0x10(%ebp)
  800410:	ff 75 0c             	pushl  0xc(%ebp)
  800413:	ff 75 08             	pushl  0x8(%ebp)
  800416:	e8 05 00 00 00       	call   800420 <vprintfmt>
	va_end(ap);
}
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	57                   	push   %edi
  800424:	56                   	push   %esi
  800425:	53                   	push   %ebx
  800426:	83 ec 2c             	sub    $0x2c,%esp
  800429:	8b 75 08             	mov    0x8(%ebp),%esi
  80042c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80042f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800432:	eb 12                	jmp    800446 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800434:	85 c0                	test   %eax,%eax
  800436:	0f 84 89 03 00 00    	je     8007c5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	50                   	push   %eax
  800441:	ff d6                	call   *%esi
  800443:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800446:	83 c7 01             	add    $0x1,%edi
  800449:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80044d:	83 f8 25             	cmp    $0x25,%eax
  800450:	75 e2                	jne    800434 <vprintfmt+0x14>
  800452:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800456:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80045d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800464:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80046b:	ba 00 00 00 00       	mov    $0x0,%edx
  800470:	eb 07                	jmp    800479 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800475:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8d 47 01             	lea    0x1(%edi),%eax
  80047c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047f:	0f b6 07             	movzbl (%edi),%eax
  800482:	0f b6 c8             	movzbl %al,%ecx
  800485:	83 e8 23             	sub    $0x23,%eax
  800488:	3c 55                	cmp    $0x55,%al
  80048a:	0f 87 1a 03 00 00    	ja     8007aa <vprintfmt+0x38a>
  800490:	0f b6 c0             	movzbl %al,%eax
  800493:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80049d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a1:	eb d6                	jmp    800479 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ae:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004b5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004b8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004bb:	83 fa 09             	cmp    $0x9,%edx
  8004be:	77 39                	ja     8004f9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c3:	eb e9                	jmp    8004ae <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 48 04             	lea    0x4(%eax),%ecx
  8004cb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d6:	eb 27                	jmp    8004ff <vprintfmt+0xdf>
  8004d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e2:	0f 49 c8             	cmovns %eax,%ecx
  8004e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004eb:	eb 8c                	jmp    800479 <vprintfmt+0x59>
  8004ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004f7:	eb 80                	jmp    800479 <vprintfmt+0x59>
  8004f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800503:	0f 89 70 ff ff ff    	jns    800479 <vprintfmt+0x59>
				width = precision, precision = -1;
  800509:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80050c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800516:	e9 5e ff ff ff       	jmp    800479 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800521:	e9 53 ff ff ff       	jmp    800479 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 50 04             	lea    0x4(%eax),%edx
  80052c:	89 55 14             	mov    %edx,0x14(%ebp)
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	53                   	push   %ebx
  800533:	ff 30                	pushl  (%eax)
  800535:	ff d6                	call   *%esi
			break;
  800537:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80053d:	e9 04 ff ff ff       	jmp    800446 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	99                   	cltd   
  80054e:	31 d0                	xor    %edx,%eax
  800550:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800552:	83 f8 0f             	cmp    $0xf,%eax
  800555:	7f 0b                	jg     800562 <vprintfmt+0x142>
  800557:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  80055e:	85 d2                	test   %edx,%edx
  800560:	75 18                	jne    80057a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800562:	50                   	push   %eax
  800563:	68 7b 24 80 00       	push   $0x80247b
  800568:	53                   	push   %ebx
  800569:	56                   	push   %esi
  80056a:	e8 94 fe ff ff       	call   800403 <printfmt>
  80056f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800575:	e9 cc fe ff ff       	jmp    800446 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80057a:	52                   	push   %edx
  80057b:	68 ca 29 80 00       	push   $0x8029ca
  800580:	53                   	push   %ebx
  800581:	56                   	push   %esi
  800582:	e8 7c fe ff ff       	call   800403 <printfmt>
  800587:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058d:	e9 b4 fe ff ff       	jmp    800446 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80059d:	85 ff                	test   %edi,%edi
  80059f:	b8 74 24 80 00       	mov    $0x802474,%eax
  8005a4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ab:	0f 8e 94 00 00 00    	jle    800645 <vprintfmt+0x225>
  8005b1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005b5:	0f 84 98 00 00 00    	je     800653 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c1:	57                   	push   %edi
  8005c2:	e8 86 02 00 00       	call   80084d <strnlen>
  8005c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ca:	29 c1                	sub    %eax,%ecx
  8005cc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005cf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005d2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005dc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005de:	eb 0f                	jmp    8005ef <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	53                   	push   %ebx
  8005e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e9:	83 ef 01             	sub    $0x1,%edi
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	85 ff                	test   %edi,%edi
  8005f1:	7f ed                	jg     8005e0 <vprintfmt+0x1c0>
  8005f3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005f6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005f9:	85 c9                	test   %ecx,%ecx
  8005fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800600:	0f 49 c1             	cmovns %ecx,%eax
  800603:	29 c1                	sub    %eax,%ecx
  800605:	89 75 08             	mov    %esi,0x8(%ebp)
  800608:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80060b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80060e:	89 cb                	mov    %ecx,%ebx
  800610:	eb 4d                	jmp    80065f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800612:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800616:	74 1b                	je     800633 <vprintfmt+0x213>
  800618:	0f be c0             	movsbl %al,%eax
  80061b:	83 e8 20             	sub    $0x20,%eax
  80061e:	83 f8 5e             	cmp    $0x5e,%eax
  800621:	76 10                	jbe    800633 <vprintfmt+0x213>
					putch('?', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	ff 75 0c             	pushl  0xc(%ebp)
  800629:	6a 3f                	push   $0x3f
  80062b:	ff 55 08             	call   *0x8(%ebp)
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb 0d                	jmp    800640 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	ff 75 0c             	pushl  0xc(%ebp)
  800639:	52                   	push   %edx
  80063a:	ff 55 08             	call   *0x8(%ebp)
  80063d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800640:	83 eb 01             	sub    $0x1,%ebx
  800643:	eb 1a                	jmp    80065f <vprintfmt+0x23f>
  800645:	89 75 08             	mov    %esi,0x8(%ebp)
  800648:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80064b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80064e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800651:	eb 0c                	jmp    80065f <vprintfmt+0x23f>
  800653:	89 75 08             	mov    %esi,0x8(%ebp)
  800656:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800659:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80065c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065f:	83 c7 01             	add    $0x1,%edi
  800662:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800666:	0f be d0             	movsbl %al,%edx
  800669:	85 d2                	test   %edx,%edx
  80066b:	74 23                	je     800690 <vprintfmt+0x270>
  80066d:	85 f6                	test   %esi,%esi
  80066f:	78 a1                	js     800612 <vprintfmt+0x1f2>
  800671:	83 ee 01             	sub    $0x1,%esi
  800674:	79 9c                	jns    800612 <vprintfmt+0x1f2>
  800676:	89 df                	mov    %ebx,%edi
  800678:	8b 75 08             	mov    0x8(%ebp),%esi
  80067b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067e:	eb 18                	jmp    800698 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 20                	push   $0x20
  800686:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800688:	83 ef 01             	sub    $0x1,%edi
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	eb 08                	jmp    800698 <vprintfmt+0x278>
  800690:	89 df                	mov    %ebx,%edi
  800692:	8b 75 08             	mov    0x8(%ebp),%esi
  800695:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800698:	85 ff                	test   %edi,%edi
  80069a:	7f e4                	jg     800680 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069f:	e9 a2 fd ff ff       	jmp    800446 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a4:	83 fa 01             	cmp    $0x1,%edx
  8006a7:	7e 16                	jle    8006bf <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 50 08             	lea    0x8(%eax),%edx
  8006af:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b2:	8b 50 04             	mov    0x4(%eax),%edx
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006bd:	eb 32                	jmp    8006f1 <vprintfmt+0x2d1>
	else if (lflag)
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	74 18                	je     8006db <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 50 04             	lea    0x4(%eax),%edx
  8006c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d1:	89 c1                	mov    %eax,%ecx
  8006d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d9:	eb 16                	jmp    8006f1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8d 50 04             	lea    0x4(%eax),%edx
  8006e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e9:	89 c1                	mov    %eax,%ecx
  8006eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006fc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800700:	79 74                	jns    800776 <vprintfmt+0x356>
				putch('-', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 2d                	push   $0x2d
  800708:	ff d6                	call   *%esi
				num = -(long long) num;
  80070a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80070d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800710:	f7 d8                	neg    %eax
  800712:	83 d2 00             	adc    $0x0,%edx
  800715:	f7 da                	neg    %edx
  800717:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80071a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80071f:	eb 55                	jmp    800776 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800721:	8d 45 14             	lea    0x14(%ebp),%eax
  800724:	e8 83 fc ff ff       	call   8003ac <getuint>
			base = 10;
  800729:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80072e:	eb 46                	jmp    800776 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
  800733:	e8 74 fc ff ff       	call   8003ac <getuint>
			base = 8;
  800738:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80073d:	eb 37                	jmp    800776 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	6a 30                	push   $0x30
  800745:	ff d6                	call   *%esi
			putch('x', putdat);
  800747:	83 c4 08             	add    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 78                	push   $0x78
  80074d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8d 50 04             	lea    0x4(%eax),%edx
  800755:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800758:	8b 00                	mov    (%eax),%eax
  80075a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80075f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800762:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800767:	eb 0d                	jmp    800776 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
  80076c:	e8 3b fc ff ff       	call   8003ac <getuint>
			base = 16;
  800771:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800776:	83 ec 0c             	sub    $0xc,%esp
  800779:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80077d:	57                   	push   %edi
  80077e:	ff 75 e0             	pushl  -0x20(%ebp)
  800781:	51                   	push   %ecx
  800782:	52                   	push   %edx
  800783:	50                   	push   %eax
  800784:	89 da                	mov    %ebx,%edx
  800786:	89 f0                	mov    %esi,%eax
  800788:	e8 70 fb ff ff       	call   8002fd <printnum>
			break;
  80078d:	83 c4 20             	add    $0x20,%esp
  800790:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800793:	e9 ae fc ff ff       	jmp    800446 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	53                   	push   %ebx
  80079c:	51                   	push   %ecx
  80079d:	ff d6                	call   *%esi
			break;
  80079f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007a5:	e9 9c fc ff ff       	jmp    800446 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	53                   	push   %ebx
  8007ae:	6a 25                	push   $0x25
  8007b0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 03                	jmp    8007ba <vprintfmt+0x39a>
  8007b7:	83 ef 01             	sub    $0x1,%edi
  8007ba:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007be:	75 f7                	jne    8007b7 <vprintfmt+0x397>
  8007c0:	e9 81 fc ff ff       	jmp    800446 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5f                   	pop    %edi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 18             	sub    $0x18,%esp
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	74 26                	je     800814 <vsnprintf+0x47>
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	7e 22                	jle    800814 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f2:	ff 75 14             	pushl  0x14(%ebp)
  8007f5:	ff 75 10             	pushl  0x10(%ebp)
  8007f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007fb:	50                   	push   %eax
  8007fc:	68 e6 03 80 00       	push   $0x8003e6
  800801:	e8 1a fc ff ff       	call   800420 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800806:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800809:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	eb 05                	jmp    800819 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800814:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800821:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800824:	50                   	push   %eax
  800825:	ff 75 10             	pushl  0x10(%ebp)
  800828:	ff 75 0c             	pushl  0xc(%ebp)
  80082b:	ff 75 08             	pushl  0x8(%ebp)
  80082e:	e8 9a ff ff ff       	call   8007cd <vsnprintf>
	va_end(ap);

	return rc;
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
  800840:	eb 03                	jmp    800845 <strlen+0x10>
		n++;
  800842:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800845:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800849:	75 f7                	jne    800842 <strlen+0xd>
		n++;
	return n;
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800856:	ba 00 00 00 00       	mov    $0x0,%edx
  80085b:	eb 03                	jmp    800860 <strnlen+0x13>
		n++;
  80085d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800860:	39 c2                	cmp    %eax,%edx
  800862:	74 08                	je     80086c <strnlen+0x1f>
  800864:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800868:	75 f3                	jne    80085d <strnlen+0x10>
  80086a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	53                   	push   %ebx
  800872:	8b 45 08             	mov    0x8(%ebp),%eax
  800875:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800878:	89 c2                	mov    %eax,%edx
  80087a:	83 c2 01             	add    $0x1,%edx
  80087d:	83 c1 01             	add    $0x1,%ecx
  800880:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800884:	88 5a ff             	mov    %bl,-0x1(%edx)
  800887:	84 db                	test   %bl,%bl
  800889:	75 ef                	jne    80087a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80088b:	5b                   	pop    %ebx
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	53                   	push   %ebx
  800892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800895:	53                   	push   %ebx
  800896:	e8 9a ff ff ff       	call   800835 <strlen>
  80089b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80089e:	ff 75 0c             	pushl  0xc(%ebp)
  8008a1:	01 d8                	add    %ebx,%eax
  8008a3:	50                   	push   %eax
  8008a4:	e8 c5 ff ff ff       	call   80086e <strcpy>
	return dst;
}
  8008a9:	89 d8                	mov    %ebx,%eax
  8008ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	56                   	push   %esi
  8008b4:	53                   	push   %ebx
  8008b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bb:	89 f3                	mov    %esi,%ebx
  8008bd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c0:	89 f2                	mov    %esi,%edx
  8008c2:	eb 0f                	jmp    8008d3 <strncpy+0x23>
		*dst++ = *src;
  8008c4:	83 c2 01             	add    $0x1,%edx
  8008c7:	0f b6 01             	movzbl (%ecx),%eax
  8008ca:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cd:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d3:	39 da                	cmp    %ebx,%edx
  8008d5:	75 ed                	jne    8008c4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d7:	89 f0                	mov    %esi,%eax
  8008d9:	5b                   	pop    %ebx
  8008da:	5e                   	pop    %esi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e8:	8b 55 10             	mov    0x10(%ebp),%edx
  8008eb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ed:	85 d2                	test   %edx,%edx
  8008ef:	74 21                	je     800912 <strlcpy+0x35>
  8008f1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f5:	89 f2                	mov    %esi,%edx
  8008f7:	eb 09                	jmp    800902 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	83 c1 01             	add    $0x1,%ecx
  8008ff:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800902:	39 c2                	cmp    %eax,%edx
  800904:	74 09                	je     80090f <strlcpy+0x32>
  800906:	0f b6 19             	movzbl (%ecx),%ebx
  800909:	84 db                	test   %bl,%bl
  80090b:	75 ec                	jne    8008f9 <strlcpy+0x1c>
  80090d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80090f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800912:	29 f0                	sub    %esi,%eax
}
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800921:	eb 06                	jmp    800929 <strcmp+0x11>
		p++, q++;
  800923:	83 c1 01             	add    $0x1,%ecx
  800926:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800929:	0f b6 01             	movzbl (%ecx),%eax
  80092c:	84 c0                	test   %al,%al
  80092e:	74 04                	je     800934 <strcmp+0x1c>
  800930:	3a 02                	cmp    (%edx),%al
  800932:	74 ef                	je     800923 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800934:	0f b6 c0             	movzbl %al,%eax
  800937:	0f b6 12             	movzbl (%edx),%edx
  80093a:	29 d0                	sub    %edx,%eax
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 55 0c             	mov    0xc(%ebp),%edx
  800948:	89 c3                	mov    %eax,%ebx
  80094a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80094d:	eb 06                	jmp    800955 <strncmp+0x17>
		n--, p++, q++;
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800955:	39 d8                	cmp    %ebx,%eax
  800957:	74 15                	je     80096e <strncmp+0x30>
  800959:	0f b6 08             	movzbl (%eax),%ecx
  80095c:	84 c9                	test   %cl,%cl
  80095e:	74 04                	je     800964 <strncmp+0x26>
  800960:	3a 0a                	cmp    (%edx),%cl
  800962:	74 eb                	je     80094f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800964:	0f b6 00             	movzbl (%eax),%eax
  800967:	0f b6 12             	movzbl (%edx),%edx
  80096a:	29 d0                	sub    %edx,%eax
  80096c:	eb 05                	jmp    800973 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800980:	eb 07                	jmp    800989 <strchr+0x13>
		if (*s == c)
  800982:	38 ca                	cmp    %cl,%dl
  800984:	74 0f                	je     800995 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	0f b6 10             	movzbl (%eax),%edx
  80098c:	84 d2                	test   %dl,%dl
  80098e:	75 f2                	jne    800982 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a1:	eb 03                	jmp    8009a6 <strfind+0xf>
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a9:	38 ca                	cmp    %cl,%dl
  8009ab:	74 04                	je     8009b1 <strfind+0x1a>
  8009ad:	84 d2                	test   %dl,%dl
  8009af:	75 f2                	jne    8009a3 <strfind+0xc>
			break;
	return (char *) s;
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009bf:	85 c9                	test   %ecx,%ecx
  8009c1:	74 36                	je     8009f9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c9:	75 28                	jne    8009f3 <memset+0x40>
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 23                	jne    8009f3 <memset+0x40>
		c &= 0xFF;
  8009d0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d4:	89 d3                	mov    %edx,%ebx
  8009d6:	c1 e3 08             	shl    $0x8,%ebx
  8009d9:	89 d6                	mov    %edx,%esi
  8009db:	c1 e6 18             	shl    $0x18,%esi
  8009de:	89 d0                	mov    %edx,%eax
  8009e0:	c1 e0 10             	shl    $0x10,%eax
  8009e3:	09 f0                	or     %esi,%eax
  8009e5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009e7:	89 d8                	mov    %ebx,%eax
  8009e9:	09 d0                	or     %edx,%eax
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
  8009ee:	fc                   	cld    
  8009ef:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f1:	eb 06                	jmp    8009f9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	fc                   	cld    
  8009f7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f9:	89 f8                	mov    %edi,%eax
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5f                   	pop    %edi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0e:	39 c6                	cmp    %eax,%esi
  800a10:	73 35                	jae    800a47 <memmove+0x47>
  800a12:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a15:	39 d0                	cmp    %edx,%eax
  800a17:	73 2e                	jae    800a47 <memmove+0x47>
		s += n;
		d += n;
  800a19:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1c:	89 d6                	mov    %edx,%esi
  800a1e:	09 fe                	or     %edi,%esi
  800a20:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a26:	75 13                	jne    800a3b <memmove+0x3b>
  800a28:	f6 c1 03             	test   $0x3,%cl
  800a2b:	75 0e                	jne    800a3b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a2d:	83 ef 04             	sub    $0x4,%edi
  800a30:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a33:	c1 e9 02             	shr    $0x2,%ecx
  800a36:	fd                   	std    
  800a37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a39:	eb 09                	jmp    800a44 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3b:	83 ef 01             	sub    $0x1,%edi
  800a3e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a41:	fd                   	std    
  800a42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a44:	fc                   	cld    
  800a45:	eb 1d                	jmp    800a64 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a47:	89 f2                	mov    %esi,%edx
  800a49:	09 c2                	or     %eax,%edx
  800a4b:	f6 c2 03             	test   $0x3,%dl
  800a4e:	75 0f                	jne    800a5f <memmove+0x5f>
  800a50:	f6 c1 03             	test   $0x3,%cl
  800a53:	75 0a                	jne    800a5f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a55:	c1 e9 02             	shr    $0x2,%ecx
  800a58:	89 c7                	mov    %eax,%edi
  800a5a:	fc                   	cld    
  800a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5d:	eb 05                	jmp    800a64 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a5f:	89 c7                	mov    %eax,%edi
  800a61:	fc                   	cld    
  800a62:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a6b:	ff 75 10             	pushl  0x10(%ebp)
  800a6e:	ff 75 0c             	pushl  0xc(%ebp)
  800a71:	ff 75 08             	pushl  0x8(%ebp)
  800a74:	e8 87 ff ff ff       	call   800a00 <memmove>
}
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a86:	89 c6                	mov    %eax,%esi
  800a88:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8b:	eb 1a                	jmp    800aa7 <memcmp+0x2c>
		if (*s1 != *s2)
  800a8d:	0f b6 08             	movzbl (%eax),%ecx
  800a90:	0f b6 1a             	movzbl (%edx),%ebx
  800a93:	38 d9                	cmp    %bl,%cl
  800a95:	74 0a                	je     800aa1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a97:	0f b6 c1             	movzbl %cl,%eax
  800a9a:	0f b6 db             	movzbl %bl,%ebx
  800a9d:	29 d8                	sub    %ebx,%eax
  800a9f:	eb 0f                	jmp    800ab0 <memcmp+0x35>
		s1++, s2++;
  800aa1:	83 c0 01             	add    $0x1,%eax
  800aa4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	39 f0                	cmp    %esi,%eax
  800aa9:	75 e2                	jne    800a8d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	53                   	push   %ebx
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800abb:	89 c1                	mov    %eax,%ecx
  800abd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac4:	eb 0a                	jmp    800ad0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac6:	0f b6 10             	movzbl (%eax),%edx
  800ac9:	39 da                	cmp    %ebx,%edx
  800acb:	74 07                	je     800ad4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acd:	83 c0 01             	add    $0x1,%eax
  800ad0:	39 c8                	cmp    %ecx,%eax
  800ad2:	72 f2                	jb     800ac6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae3:	eb 03                	jmp    800ae8 <strtol+0x11>
		s++;
  800ae5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae8:	0f b6 01             	movzbl (%ecx),%eax
  800aeb:	3c 20                	cmp    $0x20,%al
  800aed:	74 f6                	je     800ae5 <strtol+0xe>
  800aef:	3c 09                	cmp    $0x9,%al
  800af1:	74 f2                	je     800ae5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800af3:	3c 2b                	cmp    $0x2b,%al
  800af5:	75 0a                	jne    800b01 <strtol+0x2a>
		s++;
  800af7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afa:	bf 00 00 00 00       	mov    $0x0,%edi
  800aff:	eb 11                	jmp    800b12 <strtol+0x3b>
  800b01:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b06:	3c 2d                	cmp    $0x2d,%al
  800b08:	75 08                	jne    800b12 <strtol+0x3b>
		s++, neg = 1;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b12:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b18:	75 15                	jne    800b2f <strtol+0x58>
  800b1a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b1d:	75 10                	jne    800b2f <strtol+0x58>
  800b1f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b23:	75 7c                	jne    800ba1 <strtol+0xca>
		s += 2, base = 16;
  800b25:	83 c1 02             	add    $0x2,%ecx
  800b28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2d:	eb 16                	jmp    800b45 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b2f:	85 db                	test   %ebx,%ebx
  800b31:	75 12                	jne    800b45 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b33:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b38:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3b:	75 08                	jne    800b45 <strtol+0x6e>
		s++, base = 8;
  800b3d:	83 c1 01             	add    $0x1,%ecx
  800b40:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b4d:	0f b6 11             	movzbl (%ecx),%edx
  800b50:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b53:	89 f3                	mov    %esi,%ebx
  800b55:	80 fb 09             	cmp    $0x9,%bl
  800b58:	77 08                	ja     800b62 <strtol+0x8b>
			dig = *s - '0';
  800b5a:	0f be d2             	movsbl %dl,%edx
  800b5d:	83 ea 30             	sub    $0x30,%edx
  800b60:	eb 22                	jmp    800b84 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b62:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b65:	89 f3                	mov    %esi,%ebx
  800b67:	80 fb 19             	cmp    $0x19,%bl
  800b6a:	77 08                	ja     800b74 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b6c:	0f be d2             	movsbl %dl,%edx
  800b6f:	83 ea 57             	sub    $0x57,%edx
  800b72:	eb 10                	jmp    800b84 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b74:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b77:	89 f3                	mov    %esi,%ebx
  800b79:	80 fb 19             	cmp    $0x19,%bl
  800b7c:	77 16                	ja     800b94 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b7e:	0f be d2             	movsbl %dl,%edx
  800b81:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b84:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b87:	7d 0b                	jge    800b94 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b89:	83 c1 01             	add    $0x1,%ecx
  800b8c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b90:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b92:	eb b9                	jmp    800b4d <strtol+0x76>

	if (endptr)
  800b94:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b98:	74 0d                	je     800ba7 <strtol+0xd0>
		*endptr = (char *) s;
  800b9a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9d:	89 0e                	mov    %ecx,(%esi)
  800b9f:	eb 06                	jmp    800ba7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba1:	85 db                	test   %ebx,%ebx
  800ba3:	74 98                	je     800b3d <strtol+0x66>
  800ba5:	eb 9e                	jmp    800b45 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ba7:	89 c2                	mov    %eax,%edx
  800ba9:	f7 da                	neg    %edx
  800bab:	85 ff                	test   %edi,%edi
  800bad:	0f 45 c2             	cmovne %edx,%eax
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	89 c3                	mov    %eax,%ebx
  800bc8:	89 c7                	mov    %eax,%edi
  800bca:	89 c6                	mov    %eax,%esi
  800bcc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bde:	b8 01 00 00 00       	mov    $0x1,%eax
  800be3:	89 d1                	mov    %edx,%ecx
  800be5:	89 d3                	mov    %edx,%ebx
  800be7:	89 d7                	mov    %edx,%edi
  800be9:	89 d6                	mov    %edx,%esi
  800beb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c00:	b8 03 00 00 00       	mov    $0x3,%eax
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	89 cb                	mov    %ecx,%ebx
  800c0a:	89 cf                	mov    %ecx,%edi
  800c0c:	89 ce                	mov    %ecx,%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 03                	push   $0x3
  800c1a:	68 5f 27 80 00       	push   $0x80275f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 7c 27 80 00       	push   $0x80277c
  800c26:	e8 e5 f5 ff ff       	call   800210 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c43:	89 d1                	mov    %edx,%ecx
  800c45:	89 d3                	mov    %edx,%ebx
  800c47:	89 d7                	mov    %edx,%edi
  800c49:	89 d6                	mov    %edx,%esi
  800c4b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_yield>:

void
sys_yield(void)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c62:	89 d1                	mov    %edx,%ecx
  800c64:	89 d3                	mov    %edx,%ebx
  800c66:	89 d7                	mov    %edx,%edi
  800c68:	89 d6                	mov    %edx,%esi
  800c6a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	be 00 00 00 00       	mov    $0x0,%esi
  800c7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8d:	89 f7                	mov    %esi,%edi
  800c8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 17                	jle    800cac <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 04                	push   $0x4
  800c9b:	68 5f 27 80 00       	push   $0x80275f
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 7c 27 80 00       	push   $0x80277c
  800ca7:	e8 64 f5 ff ff       	call   800210 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cce:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 17                	jle    800cee <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 05                	push   $0x5
  800cdd:	68 5f 27 80 00       	push   $0x80275f
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 7c 27 80 00       	push   $0x80277c
  800ce9:	e8 22 f5 ff ff       	call   800210 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d04:	b8 06 00 00 00       	mov    $0x6,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 df                	mov    %ebx,%edi
  800d11:	89 de                	mov    %ebx,%esi
  800d13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7e 17                	jle    800d30 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	50                   	push   %eax
  800d1d:	6a 06                	push   $0x6
  800d1f:	68 5f 27 80 00       	push   $0x80275f
  800d24:	6a 23                	push   $0x23
  800d26:	68 7c 27 80 00       	push   $0x80277c
  800d2b:	e8 e0 f4 ff ff       	call   800210 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	b8 08 00 00 00       	mov    $0x8,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	89 df                	mov    %ebx,%edi
  800d53:	89 de                	mov    %ebx,%esi
  800d55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	7e 17                	jle    800d72 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	50                   	push   %eax
  800d5f:	6a 08                	push   $0x8
  800d61:	68 5f 27 80 00       	push   $0x80275f
  800d66:	6a 23                	push   $0x23
  800d68:	68 7c 27 80 00       	push   $0x80277c
  800d6d:	e8 9e f4 ff ff       	call   800210 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d88:	b8 09 00 00 00       	mov    $0x9,%eax
  800d8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d90:	8b 55 08             	mov    0x8(%ebp),%edx
  800d93:	89 df                	mov    %ebx,%edi
  800d95:	89 de                	mov    %ebx,%esi
  800d97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7e 17                	jle    800db4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	50                   	push   %eax
  800da1:	6a 09                	push   $0x9
  800da3:	68 5f 27 80 00       	push   $0x80275f
  800da8:	6a 23                	push   $0x23
  800daa:	68 7c 27 80 00       	push   $0x80277c
  800daf:	e8 5c f4 ff ff       	call   800210 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dca:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	89 df                	mov    %ebx,%edi
  800dd7:	89 de                	mov    %ebx,%esi
  800dd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	7e 17                	jle    800df6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	50                   	push   %eax
  800de3:	6a 0a                	push   $0xa
  800de5:	68 5f 27 80 00       	push   $0x80275f
  800dea:	6a 23                	push   $0x23
  800dec:	68 7c 27 80 00       	push   $0x80277c
  800df1:	e8 1a f4 ff ff       	call   800210 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e04:	be 00 00 00 00       	mov    $0x0,%esi
  800e09:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e34:	8b 55 08             	mov    0x8(%ebp),%edx
  800e37:	89 cb                	mov    %ecx,%ebx
  800e39:	89 cf                	mov    %ecx,%edi
  800e3b:	89 ce                	mov    %ecx,%esi
  800e3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	7e 17                	jle    800e5a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	50                   	push   %eax
  800e47:	6a 0d                	push   $0xd
  800e49:	68 5f 27 80 00       	push   $0x80275f
  800e4e:	6a 23                	push   $0x23
  800e50:	68 7c 27 80 00       	push   $0x80277c
  800e55:	e8 b6 f3 ff ff       	call   800210 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	53                   	push   %ebx
  800e66:	83 ec 04             	sub    $0x4,%esp
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e6c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800e6e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e72:	75 14                	jne    800e88 <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800e74:	83 ec 04             	sub    $0x4,%esp
  800e77:	68 8c 27 80 00       	push   $0x80278c
  800e7c:	6a 22                	push   $0x22
  800e7e:	68 6f 28 80 00       	push   $0x80286f
  800e83:	e8 88 f3 ff ff       	call   800210 <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800e88:	89 d8                	mov    %ebx,%eax
  800e8a:	c1 e8 0c             	shr    $0xc,%eax
  800e8d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e94:	f6 c4 08             	test   $0x8,%ah
  800e97:	75 14                	jne    800ead <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	68 c8 27 80 00       	push   $0x8027c8
  800ea1:	6a 27                	push   $0x27
  800ea3:	68 6f 28 80 00       	push   $0x80286f
  800ea8:	e8 63 f3 ff ff       	call   800210 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800ead:	83 ec 04             	sub    $0x4,%esp
  800eb0:	6a 07                	push   $0x7
  800eb2:	68 00 f0 7f 00       	push   $0x7ff000
  800eb7:	6a 00                	push   $0x0
  800eb9:	e8 b3 fd ff ff       	call   800c71 <sys_page_alloc>
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	79 14                	jns    800ed9 <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800ec5:	83 ec 04             	sub    $0x4,%esp
  800ec8:	68 f8 27 80 00       	push   $0x8027f8
  800ecd:	6a 2f                	push   $0x2f
  800ecf:	68 6f 28 80 00       	push   $0x80286f
  800ed4:	e8 37 f3 ff ff       	call   800210 <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800ed9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	68 00 10 00 00       	push   $0x1000
  800ee7:	53                   	push   %ebx
  800ee8:	68 00 f0 7f 00       	push   $0x7ff000
  800eed:	e8 0e fb ff ff       	call   800a00 <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800ef2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ef9:	53                   	push   %ebx
  800efa:	6a 00                	push   $0x0
  800efc:	68 00 f0 7f 00       	push   $0x7ff000
  800f01:	6a 00                	push   $0x0
  800f03:	e8 ac fd ff ff       	call   800cb4 <sys_page_map>
  800f08:	83 c4 20             	add    $0x20,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	79 14                	jns    800f23 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800f0f:	83 ec 04             	sub    $0x4,%esp
  800f12:	68 24 28 80 00       	push   $0x802824
  800f17:	6a 34                	push   $0x34
  800f19:	68 6f 28 80 00       	push   $0x80286f
  800f1e:	e8 ed f2 ff ff       	call   800210 <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f23:	83 ec 08             	sub    $0x8,%esp
  800f26:	68 00 f0 7f 00       	push   $0x7ff000
  800f2b:	6a 00                	push   $0x0
  800f2d:	e8 c4 fd ff ff       	call   800cf6 <sys_page_unmap>
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	79 14                	jns    800f4d <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	68 4c 28 80 00       	push   $0x80284c
  800f41:	6a 37                	push   $0x37
  800f43:	68 6f 28 80 00       	push   $0x80286f
  800f48:	e8 c3 f2 ff ff       	call   800210 <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800f4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800f5b:	68 62 0e 80 00       	push   $0x800e62
  800f60:	e8 de 0e 00 00       	call   801e43 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f65:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6a:	cd 30                	int    $0x30
  800f6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	79 15                	jns    800f8b <fork+0x39>
		panic("sys_exofork: %e", envid);
  800f76:	50                   	push   %eax
  800f77:	68 7a 28 80 00       	push   $0x80287a
  800f7c:	68 87 00 00 00       	push   $0x87
  800f81:	68 6f 28 80 00       	push   $0x80286f
  800f86:	e8 85 f2 ff ff       	call   800210 <_panic>
  800f8b:	89 c7                	mov    %eax,%edi
  800f8d:	be 00 00 00 00       	mov    $0x0,%esi
  800f92:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  800f97:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f9b:	75 21                	jne    800fbe <fork+0x6c>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f9d:	e8 91 fc ff ff       	call   800c33 <sys_getenvid>
  800fa2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800faa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800faf:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  800fb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb9:	e9 56 01 00 00       	jmp    801114 <fork+0x1c2>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  800fbe:	89 f0                	mov    %esi,%eax
  800fc0:	c1 e8 16             	shr    $0x16,%eax
  800fc3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fca:	a8 01                	test   $0x1,%al
  800fcc:	0f 84 a5 00 00 00    	je     801077 <fork+0x125>
  800fd2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd9:	a8 05                	test   $0x5,%al
  800fdb:	0f 84 96 00 00 00    	je     801077 <fork+0x125>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)))
  800fe1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fe8:	a8 02                	test   $0x2,%al
  800fea:	75 0c                	jne    800ff8 <fork+0xa6>
  800fec:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ff3:	f6 c4 08             	test   $0x8,%ah
  800ff6:	74 57                	je     80104f <fork+0xfd>
	{

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm | PTE_COW))) < 0)
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	68 05 08 00 00       	push   $0x805
  801000:	56                   	push   %esi
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	6a 00                	push   $0x0
  801005:	e8 aa fc ff ff       	call   800cb4 <sys_page_map>
  80100a:	83 c4 20             	add    $0x20,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	79 12                	jns    801023 <fork+0xd1>
			panic("fork: sys_page_map: %e", r);
  801011:	50                   	push   %eax
  801012:	68 8a 28 80 00       	push   $0x80288a
  801017:	6a 5c                	push   $0x5c
  801019:	68 6f 28 80 00       	push   $0x80286f
  80101e:	e8 ed f1 ff ff       	call   800210 <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm|PTE_COW))) < 0)
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	68 05 08 00 00       	push   $0x805
  80102b:	56                   	push   %esi
  80102c:	6a 00                	push   $0x0
  80102e:	56                   	push   %esi
  80102f:	6a 00                	push   $0x0
  801031:	e8 7e fc ff ff       	call   800cb4 <sys_page_map>
  801036:	83 c4 20             	add    $0x20,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	79 3a                	jns    801077 <fork+0x125>
			panic("fork: sys_page_map: %e", r);
  80103d:	50                   	push   %eax
  80103e:	68 8a 28 80 00       	push   $0x80288a
  801043:	6a 5f                	push   $0x5f
  801045:	68 6f 28 80 00       	push   $0x80286f
  80104a:	e8 c1 f1 ff ff       	call   800210 <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	6a 05                	push   $0x5
  801054:	56                   	push   %esi
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	6a 00                	push   $0x0
  801059:	e8 56 fc ff ff       	call   800cb4 <sys_page_map>
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 12                	jns    801077 <fork+0x125>
			panic("fork: sys_page_map: %e", r);
  801065:	50                   	push   %eax
  801066:	68 8a 28 80 00       	push   $0x80288a
  80106b:	6a 64                	push   $0x64
  80106d:	68 6f 28 80 00       	push   $0x80286f
  801072:	e8 99 f1 ff ff       	call   800210 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  801077:	83 c3 01             	add    $0x1,%ebx
  80107a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801080:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801086:	0f 85 32 ff ff ff    	jne    800fbe <fork+0x6c>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  80108c:	83 ec 04             	sub    $0x4,%esp
  80108f:	6a 07                	push   $0x7
  801091:	68 00 f0 bf ee       	push   $0xeebff000
  801096:	ff 75 e4             	pushl  -0x1c(%ebp)
  801099:	e8 d3 fb ff ff       	call   800c71 <sys_page_alloc>
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 15                	jns    8010ba <fork+0x168>
		panic("sys_page_alloc: %e", r);
  8010a5:	50                   	push   %eax
  8010a6:	68 a1 28 80 00       	push   $0x8028a1
  8010ab:	68 98 00 00 00       	push   $0x98
  8010b0:	68 6f 28 80 00       	push   $0x80286f
  8010b5:	e8 56 f1 ff ff       	call   800210 <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	68 c0 1e 80 00       	push   $0x801ec0
  8010c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c5:	e8 f2 fc ff ff       	call   800dbc <sys_env_set_pgfault_upcall>
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	79 17                	jns    8010e8 <fork+0x196>
		panic("sys_pgfault_upcall error");
  8010d1:	83 ec 04             	sub    $0x4,%esp
  8010d4:	68 b4 28 80 00       	push   $0x8028b4
  8010d9:	68 9b 00 00 00       	push   $0x9b
  8010de:	68 6f 28 80 00       	push   $0x80286f
  8010e3:	e8 28 f1 ff ff       	call   800210 <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010e8:	83 ec 08             	sub    $0x8,%esp
  8010eb:	6a 02                	push   $0x2
  8010ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f0:	e8 43 fc ff ff       	call   800d38 <sys_env_set_status>
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	79 15                	jns    801111 <fork+0x1bf>
		panic("sys_env_set_status: %e", r);
  8010fc:	50                   	push   %eax
  8010fd:	68 cd 28 80 00       	push   $0x8028cd
  801102:	68 a1 00 00 00       	push   $0xa1
  801107:	68 6f 28 80 00       	push   $0x80286f
  80110c:	e8 ff f0 ff ff       	call   800210 <_panic>

	return envid;
  801111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  801114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <sfork>:

// Challenge!
int
sfork(void)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801122:	68 e4 28 80 00       	push   $0x8028e4
  801127:	68 ac 00 00 00       	push   $0xac
  80112c:	68 6f 28 80 00       	push   $0x80286f
  801131:	e8 da f0 ff ff       	call   800210 <_panic>

00801136 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	05 00 00 00 30       	add    $0x30000000,%eax
  801141:	c1 e8 0c             	shr    $0xc,%eax
}
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801149:	8b 45 08             	mov    0x8(%ebp),%eax
  80114c:	05 00 00 00 30       	add    $0x30000000,%eax
  801151:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801156:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801163:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801168:	89 c2                	mov    %eax,%edx
  80116a:	c1 ea 16             	shr    $0x16,%edx
  80116d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801174:	f6 c2 01             	test   $0x1,%dl
  801177:	74 11                	je     80118a <fd_alloc+0x2d>
  801179:	89 c2                	mov    %eax,%edx
  80117b:	c1 ea 0c             	shr    $0xc,%edx
  80117e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801185:	f6 c2 01             	test   $0x1,%dl
  801188:	75 09                	jne    801193 <fd_alloc+0x36>
			*fd_store = fd;
  80118a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118c:	b8 00 00 00 00       	mov    $0x0,%eax
  801191:	eb 17                	jmp    8011aa <fd_alloc+0x4d>
  801193:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801198:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119d:	75 c9                	jne    801168 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80119f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011a5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b2:	83 f8 1f             	cmp    $0x1f,%eax
  8011b5:	77 36                	ja     8011ed <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b7:	c1 e0 0c             	shl    $0xc,%eax
  8011ba:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	c1 ea 16             	shr    $0x16,%edx
  8011c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cb:	f6 c2 01             	test   $0x1,%dl
  8011ce:	74 24                	je     8011f4 <fd_lookup+0x48>
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	c1 ea 0c             	shr    $0xc,%edx
  8011d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dc:	f6 c2 01             	test   $0x1,%dl
  8011df:	74 1a                	je     8011fb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e4:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	eb 13                	jmp    801200 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f2:	eb 0c                	jmp    801200 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f9:	eb 05                	jmp    801200 <fd_lookup+0x54>
  8011fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120b:	ba 78 29 80 00       	mov    $0x802978,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801210:	eb 13                	jmp    801225 <dev_lookup+0x23>
  801212:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801215:	39 08                	cmp    %ecx,(%eax)
  801217:	75 0c                	jne    801225 <dev_lookup+0x23>
			*dev = devtab[i];
  801219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
  801223:	eb 2e                	jmp    801253 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801225:	8b 02                	mov    (%edx),%eax
  801227:	85 c0                	test   %eax,%eax
  801229:	75 e7                	jne    801212 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122b:	a1 20 44 80 00       	mov    0x804420,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	51                   	push   %ecx
  801237:	50                   	push   %eax
  801238:	68 fc 28 80 00       	push   $0x8028fc
  80123d:	e8 a7 f0 ff ff       	call   8002e9 <cprintf>
	*dev = 0;
  801242:	8b 45 0c             	mov    0xc(%ebp),%eax
  801245:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	56                   	push   %esi
  801259:	53                   	push   %ebx
  80125a:	83 ec 10             	sub    $0x10,%esp
  80125d:	8b 75 08             	mov    0x8(%ebp),%esi
  801260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80126d:	c1 e8 0c             	shr    $0xc,%eax
  801270:	50                   	push   %eax
  801271:	e8 36 ff ff ff       	call   8011ac <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 05                	js     801282 <fd_close+0x2d>
	    || fd != fd2)
  80127d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801280:	74 0c                	je     80128e <fd_close+0x39>
		return (must_exist ? r : 0);
  801282:	84 db                	test   %bl,%bl
  801284:	ba 00 00 00 00       	mov    $0x0,%edx
  801289:	0f 44 c2             	cmove  %edx,%eax
  80128c:	eb 41                	jmp    8012cf <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801294:	50                   	push   %eax
  801295:	ff 36                	pushl  (%esi)
  801297:	e8 66 ff ff ff       	call   801202 <dev_lookup>
  80129c:	89 c3                	mov    %eax,%ebx
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 1a                	js     8012bf <fd_close+0x6a>
		if (dev->dev_close)
  8012a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ab:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	74 0b                	je     8012bf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012b4:	83 ec 0c             	sub    $0xc,%esp
  8012b7:	56                   	push   %esi
  8012b8:	ff d0                	call   *%eax
  8012ba:	89 c3                	mov    %eax,%ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	56                   	push   %esi
  8012c3:	6a 00                	push   $0x0
  8012c5:	e8 2c fa ff ff       	call   800cf6 <sys_page_unmap>
	return r;
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	89 d8                	mov    %ebx,%eax
}
  8012cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d2:	5b                   	pop    %ebx
  8012d3:	5e                   	pop    %esi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    

008012d6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 75 08             	pushl  0x8(%ebp)
  8012e3:	e8 c4 fe ff ff       	call   8011ac <fd_lookup>
  8012e8:	83 c4 08             	add    $0x8,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 10                	js     8012ff <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	6a 01                	push   $0x1
  8012f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f7:	e8 59 ff ff ff       	call   801255 <fd_close>
  8012fc:	83 c4 10             	add    $0x10,%esp
}
  8012ff:	c9                   	leave  
  801300:	c3                   	ret    

00801301 <close_all>:

void
close_all(void)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	53                   	push   %ebx
  801305:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801308:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80130d:	83 ec 0c             	sub    $0xc,%esp
  801310:	53                   	push   %ebx
  801311:	e8 c0 ff ff ff       	call   8012d6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801316:	83 c3 01             	add    $0x1,%ebx
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	83 fb 20             	cmp    $0x20,%ebx
  80131f:	75 ec                	jne    80130d <close_all+0xc>
		close(i);
}
  801321:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	57                   	push   %edi
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
  80132c:	83 ec 2c             	sub    $0x2c,%esp
  80132f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801332:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	ff 75 08             	pushl  0x8(%ebp)
  801339:	e8 6e fe ff ff       	call   8011ac <fd_lookup>
  80133e:	83 c4 08             	add    $0x8,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	0f 88 c1 00 00 00    	js     80140a <dup+0xe4>
		return r;
	close(newfdnum);
  801349:	83 ec 0c             	sub    $0xc,%esp
  80134c:	56                   	push   %esi
  80134d:	e8 84 ff ff ff       	call   8012d6 <close>

	newfd = INDEX2FD(newfdnum);
  801352:	89 f3                	mov    %esi,%ebx
  801354:	c1 e3 0c             	shl    $0xc,%ebx
  801357:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80135d:	83 c4 04             	add    $0x4,%esp
  801360:	ff 75 e4             	pushl  -0x1c(%ebp)
  801363:	e8 de fd ff ff       	call   801146 <fd2data>
  801368:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80136a:	89 1c 24             	mov    %ebx,(%esp)
  80136d:	e8 d4 fd ff ff       	call   801146 <fd2data>
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801378:	89 f8                	mov    %edi,%eax
  80137a:	c1 e8 16             	shr    $0x16,%eax
  80137d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801384:	a8 01                	test   $0x1,%al
  801386:	74 37                	je     8013bf <dup+0x99>
  801388:	89 f8                	mov    %edi,%eax
  80138a:	c1 e8 0c             	shr    $0xc,%eax
  80138d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801394:	f6 c2 01             	test   $0x1,%dl
  801397:	74 26                	je     8013bf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801399:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a0:	83 ec 0c             	sub    $0xc,%esp
  8013a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a8:	50                   	push   %eax
  8013a9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ac:	6a 00                	push   $0x0
  8013ae:	57                   	push   %edi
  8013af:	6a 00                	push   $0x0
  8013b1:	e8 fe f8 ff ff       	call   800cb4 <sys_page_map>
  8013b6:	89 c7                	mov    %eax,%edi
  8013b8:	83 c4 20             	add    $0x20,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 2e                	js     8013ed <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c2:	89 d0                	mov    %edx,%eax
  8013c4:	c1 e8 0c             	shr    $0xc,%eax
  8013c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d6:	50                   	push   %eax
  8013d7:	53                   	push   %ebx
  8013d8:	6a 00                	push   $0x0
  8013da:	52                   	push   %edx
  8013db:	6a 00                	push   $0x0
  8013dd:	e8 d2 f8 ff ff       	call   800cb4 <sys_page_map>
  8013e2:	89 c7                	mov    %eax,%edi
  8013e4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013e7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e9:	85 ff                	test   %edi,%edi
  8013eb:	79 1d                	jns    80140a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	53                   	push   %ebx
  8013f1:	6a 00                	push   $0x0
  8013f3:	e8 fe f8 ff ff       	call   800cf6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f8:	83 c4 08             	add    $0x8,%esp
  8013fb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013fe:	6a 00                	push   $0x0
  801400:	e8 f1 f8 ff ff       	call   800cf6 <sys_page_unmap>
	return r;
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	89 f8                	mov    %edi,%eax
}
  80140a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	53                   	push   %ebx
  801416:	83 ec 14             	sub    $0x14,%esp
  801419:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141f:	50                   	push   %eax
  801420:	53                   	push   %ebx
  801421:	e8 86 fd ff ff       	call   8011ac <fd_lookup>
  801426:	83 c4 08             	add    $0x8,%esp
  801429:	89 c2                	mov    %eax,%edx
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 6d                	js     80149c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801439:	ff 30                	pushl  (%eax)
  80143b:	e8 c2 fd ff ff       	call   801202 <dev_lookup>
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 4c                	js     801493 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801447:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144a:	8b 42 08             	mov    0x8(%edx),%eax
  80144d:	83 e0 03             	and    $0x3,%eax
  801450:	83 f8 01             	cmp    $0x1,%eax
  801453:	75 21                	jne    801476 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801455:	a1 20 44 80 00       	mov    0x804420,%eax
  80145a:	8b 40 48             	mov    0x48(%eax),%eax
  80145d:	83 ec 04             	sub    $0x4,%esp
  801460:	53                   	push   %ebx
  801461:	50                   	push   %eax
  801462:	68 3d 29 80 00       	push   $0x80293d
  801467:	e8 7d ee ff ff       	call   8002e9 <cprintf>
		return -E_INVAL;
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801474:	eb 26                	jmp    80149c <read+0x8a>
	}
	if (!dev->dev_read)
  801476:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801479:	8b 40 08             	mov    0x8(%eax),%eax
  80147c:	85 c0                	test   %eax,%eax
  80147e:	74 17                	je     801497 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801480:	83 ec 04             	sub    $0x4,%esp
  801483:	ff 75 10             	pushl  0x10(%ebp)
  801486:	ff 75 0c             	pushl  0xc(%ebp)
  801489:	52                   	push   %edx
  80148a:	ff d0                	call   *%eax
  80148c:	89 c2                	mov    %eax,%edx
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	eb 09                	jmp    80149c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801493:	89 c2                	mov    %eax,%edx
  801495:	eb 05                	jmp    80149c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801497:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80149c:	89 d0                	mov    %edx,%eax
  80149e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	57                   	push   %edi
  8014a7:	56                   	push   %esi
  8014a8:	53                   	push   %ebx
  8014a9:	83 ec 0c             	sub    $0xc,%esp
  8014ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014af:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b7:	eb 21                	jmp    8014da <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b9:	83 ec 04             	sub    $0x4,%esp
  8014bc:	89 f0                	mov    %esi,%eax
  8014be:	29 d8                	sub    %ebx,%eax
  8014c0:	50                   	push   %eax
  8014c1:	89 d8                	mov    %ebx,%eax
  8014c3:	03 45 0c             	add    0xc(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	57                   	push   %edi
  8014c8:	e8 45 ff ff ff       	call   801412 <read>
		if (m < 0)
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 10                	js     8014e4 <readn+0x41>
			return m;
		if (m == 0)
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	74 0a                	je     8014e2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d8:	01 c3                	add    %eax,%ebx
  8014da:	39 f3                	cmp    %esi,%ebx
  8014dc:	72 db                	jb     8014b9 <readn+0x16>
  8014de:	89 d8                	mov    %ebx,%eax
  8014e0:	eb 02                	jmp    8014e4 <readn+0x41>
  8014e2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e7:	5b                   	pop    %ebx
  8014e8:	5e                   	pop    %esi
  8014e9:	5f                   	pop    %edi
  8014ea:	5d                   	pop    %ebp
  8014eb:	c3                   	ret    

008014ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 14             	sub    $0x14,%esp
  8014f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	53                   	push   %ebx
  8014fb:	e8 ac fc ff ff       	call   8011ac <fd_lookup>
  801500:	83 c4 08             	add    $0x8,%esp
  801503:	89 c2                	mov    %eax,%edx
  801505:	85 c0                	test   %eax,%eax
  801507:	78 68                	js     801571 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801513:	ff 30                	pushl  (%eax)
  801515:	e8 e8 fc ff ff       	call   801202 <dev_lookup>
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 47                	js     801568 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801521:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801524:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801528:	75 21                	jne    80154b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80152a:	a1 20 44 80 00       	mov    0x804420,%eax
  80152f:	8b 40 48             	mov    0x48(%eax),%eax
  801532:	83 ec 04             	sub    $0x4,%esp
  801535:	53                   	push   %ebx
  801536:	50                   	push   %eax
  801537:	68 59 29 80 00       	push   $0x802959
  80153c:	e8 a8 ed ff ff       	call   8002e9 <cprintf>
		return -E_INVAL;
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801549:	eb 26                	jmp    801571 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154e:	8b 52 0c             	mov    0xc(%edx),%edx
  801551:	85 d2                	test   %edx,%edx
  801553:	74 17                	je     80156c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	ff 75 10             	pushl  0x10(%ebp)
  80155b:	ff 75 0c             	pushl  0xc(%ebp)
  80155e:	50                   	push   %eax
  80155f:	ff d2                	call   *%edx
  801561:	89 c2                	mov    %eax,%edx
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	eb 09                	jmp    801571 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801568:	89 c2                	mov    %eax,%edx
  80156a:	eb 05                	jmp    801571 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80156c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801571:	89 d0                	mov    %edx,%eax
  801573:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <seek>:

int
seek(int fdnum, off_t offset)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	ff 75 08             	pushl  0x8(%ebp)
  801585:	e8 22 fc ff ff       	call   8011ac <fd_lookup>
  80158a:	83 c4 08             	add    $0x8,%esp
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 0e                	js     80159f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801591:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801594:	8b 55 0c             	mov    0xc(%ebp),%edx
  801597:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 14             	sub    $0x14,%esp
  8015a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	53                   	push   %ebx
  8015b0:	e8 f7 fb ff ff       	call   8011ac <fd_lookup>
  8015b5:	83 c4 08             	add    $0x8,%esp
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 65                	js     801623 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c8:	ff 30                	pushl  (%eax)
  8015ca:	e8 33 fc ff ff       	call   801202 <dev_lookup>
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 44                	js     80161a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015dd:	75 21                	jne    801600 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015df:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e4:	8b 40 48             	mov    0x48(%eax),%eax
  8015e7:	83 ec 04             	sub    $0x4,%esp
  8015ea:	53                   	push   %ebx
  8015eb:	50                   	push   %eax
  8015ec:	68 1c 29 80 00       	push   $0x80291c
  8015f1:	e8 f3 ec ff ff       	call   8002e9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fe:	eb 23                	jmp    801623 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801600:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801603:	8b 52 18             	mov    0x18(%edx),%edx
  801606:	85 d2                	test   %edx,%edx
  801608:	74 14                	je     80161e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	ff 75 0c             	pushl  0xc(%ebp)
  801610:	50                   	push   %eax
  801611:	ff d2                	call   *%edx
  801613:	89 c2                	mov    %eax,%edx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 09                	jmp    801623 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	eb 05                	jmp    801623 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801623:	89 d0                	mov    %edx,%eax
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	53                   	push   %ebx
  80162e:	83 ec 14             	sub    $0x14,%esp
  801631:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801634:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801637:	50                   	push   %eax
  801638:	ff 75 08             	pushl  0x8(%ebp)
  80163b:	e8 6c fb ff ff       	call   8011ac <fd_lookup>
  801640:	83 c4 08             	add    $0x8,%esp
  801643:	89 c2                	mov    %eax,%edx
  801645:	85 c0                	test   %eax,%eax
  801647:	78 58                	js     8016a1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164f:	50                   	push   %eax
  801650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801653:	ff 30                	pushl  (%eax)
  801655:	e8 a8 fb ff ff       	call   801202 <dev_lookup>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 37                	js     801698 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801664:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801668:	74 32                	je     80169c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80166a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80166d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801674:	00 00 00 
	stat->st_isdir = 0;
  801677:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80167e:	00 00 00 
	stat->st_dev = dev;
  801681:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801687:	83 ec 08             	sub    $0x8,%esp
  80168a:	53                   	push   %ebx
  80168b:	ff 75 f0             	pushl  -0x10(%ebp)
  80168e:	ff 50 14             	call   *0x14(%eax)
  801691:	89 c2                	mov    %eax,%edx
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	eb 09                	jmp    8016a1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801698:	89 c2                	mov    %eax,%edx
  80169a:	eb 05                	jmp    8016a1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80169c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a1:	89 d0                	mov    %edx,%eax
  8016a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	56                   	push   %esi
  8016ac:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	6a 00                	push   $0x0
  8016b2:	ff 75 08             	pushl  0x8(%ebp)
  8016b5:	e8 b7 01 00 00       	call   801871 <open>
  8016ba:	89 c3                	mov    %eax,%ebx
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 1b                	js     8016de <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	ff 75 0c             	pushl  0xc(%ebp)
  8016c9:	50                   	push   %eax
  8016ca:	e8 5b ff ff ff       	call   80162a <fstat>
  8016cf:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d1:	89 1c 24             	mov    %ebx,(%esp)
  8016d4:	e8 fd fb ff ff       	call   8012d6 <close>
	return r;
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	89 f0                	mov    %esi,%eax
}
  8016de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	56                   	push   %esi
  8016e9:	53                   	push   %ebx
  8016ea:	89 c6                	mov    %eax,%esi
  8016ec:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ee:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016f5:	75 12                	jne    801709 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f7:	83 ec 0c             	sub    $0xc,%esp
  8016fa:	6a 01                	push   $0x1
  8016fc:	e8 e5 08 00 00       	call   801fe6 <ipc_find_env>
  801701:	a3 00 40 80 00       	mov    %eax,0x804000
  801706:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801709:	6a 07                	push   $0x7
  80170b:	68 00 50 80 00       	push   $0x805000
  801710:	56                   	push   %esi
  801711:	ff 35 00 40 80 00    	pushl  0x804000
  801717:	e8 3e 08 00 00       	call   801f5a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80171c:	83 c4 0c             	add    $0xc,%esp
  80171f:	6a 00                	push   $0x0
  801721:	53                   	push   %ebx
  801722:	6a 00                	push   $0x0
  801724:	e8 bc 07 00 00       	call   801ee5 <ipc_recv>
}
  801729:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801736:	8b 45 08             	mov    0x8(%ebp),%eax
  801739:	8b 40 0c             	mov    0xc(%eax),%eax
  80173c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801741:	8b 45 0c             	mov    0xc(%ebp),%eax
  801744:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801749:	ba 00 00 00 00       	mov    $0x0,%edx
  80174e:	b8 02 00 00 00       	mov    $0x2,%eax
  801753:	e8 8d ff ff ff       	call   8016e5 <fsipc>
}
  801758:	c9                   	leave  
  801759:	c3                   	ret    

0080175a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	8b 40 0c             	mov    0xc(%eax),%eax
  801766:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80176b:	ba 00 00 00 00       	mov    $0x0,%edx
  801770:	b8 06 00 00 00       	mov    $0x6,%eax
  801775:	e8 6b ff ff ff       	call   8016e5 <fsipc>
}
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	8b 40 0c             	mov    0xc(%eax),%eax
  80178c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801791:	ba 00 00 00 00       	mov    $0x0,%edx
  801796:	b8 05 00 00 00       	mov    $0x5,%eax
  80179b:	e8 45 ff ff ff       	call   8016e5 <fsipc>
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 2c                	js     8017d0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a4:	83 ec 08             	sub    $0x8,%esp
  8017a7:	68 00 50 80 00       	push   $0x805000
  8017ac:	53                   	push   %ebx
  8017ad:	e8 bc f0 ff ff       	call   80086e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8017db:	68 88 29 80 00       	push   $0x802988
  8017e0:	68 90 00 00 00       	push   $0x90
  8017e5:	68 a6 29 80 00       	push   $0x8029a6
  8017ea:	e8 21 ea ff ff       	call   800210 <_panic>

008017ef <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	56                   	push   %esi
  8017f3:	53                   	push   %ebx
  8017f4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801802:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801808:	ba 00 00 00 00       	mov    $0x0,%edx
  80180d:	b8 03 00 00 00       	mov    $0x3,%eax
  801812:	e8 ce fe ff ff       	call   8016e5 <fsipc>
  801817:	89 c3                	mov    %eax,%ebx
  801819:	85 c0                	test   %eax,%eax
  80181b:	78 4b                	js     801868 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80181d:	39 c6                	cmp    %eax,%esi
  80181f:	73 16                	jae    801837 <devfile_read+0x48>
  801821:	68 b1 29 80 00       	push   $0x8029b1
  801826:	68 b8 29 80 00       	push   $0x8029b8
  80182b:	6a 7c                	push   $0x7c
  80182d:	68 a6 29 80 00       	push   $0x8029a6
  801832:	e8 d9 e9 ff ff       	call   800210 <_panic>
	assert(r <= PGSIZE);
  801837:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80183c:	7e 16                	jle    801854 <devfile_read+0x65>
  80183e:	68 cd 29 80 00       	push   $0x8029cd
  801843:	68 b8 29 80 00       	push   $0x8029b8
  801848:	6a 7d                	push   $0x7d
  80184a:	68 a6 29 80 00       	push   $0x8029a6
  80184f:	e8 bc e9 ff ff       	call   800210 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801854:	83 ec 04             	sub    $0x4,%esp
  801857:	50                   	push   %eax
  801858:	68 00 50 80 00       	push   $0x805000
  80185d:	ff 75 0c             	pushl  0xc(%ebp)
  801860:	e8 9b f1 ff ff       	call   800a00 <memmove>
	return r;
  801865:	83 c4 10             	add    $0x10,%esp
}
  801868:	89 d8                	mov    %ebx,%eax
  80186a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186d:	5b                   	pop    %ebx
  80186e:	5e                   	pop    %esi
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	53                   	push   %ebx
  801875:	83 ec 20             	sub    $0x20,%esp
  801878:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80187b:	53                   	push   %ebx
  80187c:	e8 b4 ef ff ff       	call   800835 <strlen>
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801889:	7f 67                	jg     8018f2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801891:	50                   	push   %eax
  801892:	e8 c6 f8 ff ff       	call   80115d <fd_alloc>
  801897:	83 c4 10             	add    $0x10,%esp
		return r;
  80189a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 57                	js     8018f7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a0:	83 ec 08             	sub    $0x8,%esp
  8018a3:	53                   	push   %ebx
  8018a4:	68 00 50 80 00       	push   $0x805000
  8018a9:	e8 c0 ef ff ff       	call   80086e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018be:	e8 22 fe ff ff       	call   8016e5 <fsipc>
  8018c3:	89 c3                	mov    %eax,%ebx
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	79 14                	jns    8018e0 <open+0x6f>
		fd_close(fd, 0);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	6a 00                	push   $0x0
  8018d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d4:	e8 7c f9 ff ff       	call   801255 <fd_close>
		return r;
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	89 da                	mov    %ebx,%edx
  8018de:	eb 17                	jmp    8018f7 <open+0x86>
	}

	return fd2num(fd);
  8018e0:	83 ec 0c             	sub    $0xc,%esp
  8018e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e6:	e8 4b f8 ff ff       	call   801136 <fd2num>
  8018eb:	89 c2                	mov    %eax,%edx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	eb 05                	jmp    8018f7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018f2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018f7:	89 d0                	mov    %edx,%eax
  8018f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801904:	ba 00 00 00 00       	mov    $0x0,%edx
  801909:	b8 08 00 00 00       	mov    $0x8,%eax
  80190e:	e8 d2 fd ff ff       	call   8016e5 <fsipc>
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80191d:	83 ec 0c             	sub    $0xc,%esp
  801920:	ff 75 08             	pushl  0x8(%ebp)
  801923:	e8 1e f8 ff ff       	call   801146 <fd2data>
  801928:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80192a:	83 c4 08             	add    $0x8,%esp
  80192d:	68 d9 29 80 00       	push   $0x8029d9
  801932:	53                   	push   %ebx
  801933:	e8 36 ef ff ff       	call   80086e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801938:	8b 46 04             	mov    0x4(%esi),%eax
  80193b:	2b 06                	sub    (%esi),%eax
  80193d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801943:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80194a:	00 00 00 
	stat->st_dev = &devpipe;
  80194d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801954:	30 80 00 
	return 0;
}
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
  80195c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195f:	5b                   	pop    %ebx
  801960:	5e                   	pop    %esi
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    

00801963 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	53                   	push   %ebx
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80196d:	53                   	push   %ebx
  80196e:	6a 00                	push   $0x0
  801970:	e8 81 f3 ff ff       	call   800cf6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801975:	89 1c 24             	mov    %ebx,(%esp)
  801978:	e8 c9 f7 ff ff       	call   801146 <fd2data>
  80197d:	83 c4 08             	add    $0x8,%esp
  801980:	50                   	push   %eax
  801981:	6a 00                	push   $0x0
  801983:	e8 6e f3 ff ff       	call   800cf6 <sys_page_unmap>
}
  801988:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	57                   	push   %edi
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	83 ec 1c             	sub    $0x1c,%esp
  801996:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801999:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80199b:	a1 20 44 80 00       	mov    0x804420,%eax
  8019a0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019a3:	83 ec 0c             	sub    $0xc,%esp
  8019a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8019a9:	e8 71 06 00 00       	call   80201f <pageref>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	89 3c 24             	mov    %edi,(%esp)
  8019b3:	e8 67 06 00 00       	call   80201f <pageref>
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	39 c3                	cmp    %eax,%ebx
  8019bd:	0f 94 c1             	sete   %cl
  8019c0:	0f b6 c9             	movzbl %cl,%ecx
  8019c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019c6:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8019cc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019cf:	39 ce                	cmp    %ecx,%esi
  8019d1:	74 1b                	je     8019ee <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019d3:	39 c3                	cmp    %eax,%ebx
  8019d5:	75 c4                	jne    80199b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019d7:	8b 42 58             	mov    0x58(%edx),%eax
  8019da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019dd:	50                   	push   %eax
  8019de:	56                   	push   %esi
  8019df:	68 e0 29 80 00       	push   $0x8029e0
  8019e4:	e8 00 e9 ff ff       	call   8002e9 <cprintf>
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	eb ad                	jmp    80199b <_pipeisclosed+0xe>
	}
}
  8019ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5f                   	pop    %edi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	57                   	push   %edi
  8019fd:	56                   	push   %esi
  8019fe:	53                   	push   %ebx
  8019ff:	83 ec 28             	sub    $0x28,%esp
  801a02:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a05:	56                   	push   %esi
  801a06:	e8 3b f7 ff ff       	call   801146 <fd2data>
  801a0b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	bf 00 00 00 00       	mov    $0x0,%edi
  801a15:	eb 4b                	jmp    801a62 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a17:	89 da                	mov    %ebx,%edx
  801a19:	89 f0                	mov    %esi,%eax
  801a1b:	e8 6d ff ff ff       	call   80198d <_pipeisclosed>
  801a20:	85 c0                	test   %eax,%eax
  801a22:	75 48                	jne    801a6c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a24:	e8 29 f2 ff ff       	call   800c52 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a29:	8b 43 04             	mov    0x4(%ebx),%eax
  801a2c:	8b 0b                	mov    (%ebx),%ecx
  801a2e:	8d 51 20             	lea    0x20(%ecx),%edx
  801a31:	39 d0                	cmp    %edx,%eax
  801a33:	73 e2                	jae    801a17 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a38:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a3c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a3f:	89 c2                	mov    %eax,%edx
  801a41:	c1 fa 1f             	sar    $0x1f,%edx
  801a44:	89 d1                	mov    %edx,%ecx
  801a46:	c1 e9 1b             	shr    $0x1b,%ecx
  801a49:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a4c:	83 e2 1f             	and    $0x1f,%edx
  801a4f:	29 ca                	sub    %ecx,%edx
  801a51:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a55:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a59:	83 c0 01             	add    $0x1,%eax
  801a5c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5f:	83 c7 01             	add    $0x1,%edi
  801a62:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a65:	75 c2                	jne    801a29 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a67:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6a:	eb 05                	jmp    801a71 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a6c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5f                   	pop    %edi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	57                   	push   %edi
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 18             	sub    $0x18,%esp
  801a82:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a85:	57                   	push   %edi
  801a86:	e8 bb f6 ff ff       	call   801146 <fd2data>
  801a8b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a95:	eb 3d                	jmp    801ad4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a97:	85 db                	test   %ebx,%ebx
  801a99:	74 04                	je     801a9f <devpipe_read+0x26>
				return i;
  801a9b:	89 d8                	mov    %ebx,%eax
  801a9d:	eb 44                	jmp    801ae3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a9f:	89 f2                	mov    %esi,%edx
  801aa1:	89 f8                	mov    %edi,%eax
  801aa3:	e8 e5 fe ff ff       	call   80198d <_pipeisclosed>
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	75 32                	jne    801ade <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aac:	e8 a1 f1 ff ff       	call   800c52 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ab1:	8b 06                	mov    (%esi),%eax
  801ab3:	3b 46 04             	cmp    0x4(%esi),%eax
  801ab6:	74 df                	je     801a97 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ab8:	99                   	cltd   
  801ab9:	c1 ea 1b             	shr    $0x1b,%edx
  801abc:	01 d0                	add    %edx,%eax
  801abe:	83 e0 1f             	and    $0x1f,%eax
  801ac1:	29 d0                	sub    %edx,%eax
  801ac3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ac8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ace:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ad1:	83 c3 01             	add    $0x1,%ebx
  801ad4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ad7:	75 d8                	jne    801ab1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ad9:	8b 45 10             	mov    0x10(%ebp),%eax
  801adc:	eb 05                	jmp    801ae3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ae3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5f                   	pop    %edi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801af3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af6:	50                   	push   %eax
  801af7:	e8 61 f6 ff ff       	call   80115d <fd_alloc>
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	89 c2                	mov    %eax,%edx
  801b01:	85 c0                	test   %eax,%eax
  801b03:	0f 88 2c 01 00 00    	js     801c35 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b09:	83 ec 04             	sub    $0x4,%esp
  801b0c:	68 07 04 00 00       	push   $0x407
  801b11:	ff 75 f4             	pushl  -0xc(%ebp)
  801b14:	6a 00                	push   $0x0
  801b16:	e8 56 f1 ff ff       	call   800c71 <sys_page_alloc>
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	89 c2                	mov    %eax,%edx
  801b20:	85 c0                	test   %eax,%eax
  801b22:	0f 88 0d 01 00 00    	js     801c35 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b2e:	50                   	push   %eax
  801b2f:	e8 29 f6 ff ff       	call   80115d <fd_alloc>
  801b34:	89 c3                	mov    %eax,%ebx
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	0f 88 e2 00 00 00    	js     801c23 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b41:	83 ec 04             	sub    $0x4,%esp
  801b44:	68 07 04 00 00       	push   $0x407
  801b49:	ff 75 f0             	pushl  -0x10(%ebp)
  801b4c:	6a 00                	push   $0x0
  801b4e:	e8 1e f1 ff ff       	call   800c71 <sys_page_alloc>
  801b53:	89 c3                	mov    %eax,%ebx
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	0f 88 c3 00 00 00    	js     801c23 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b60:	83 ec 0c             	sub    $0xc,%esp
  801b63:	ff 75 f4             	pushl  -0xc(%ebp)
  801b66:	e8 db f5 ff ff       	call   801146 <fd2data>
  801b6b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6d:	83 c4 0c             	add    $0xc,%esp
  801b70:	68 07 04 00 00       	push   $0x407
  801b75:	50                   	push   %eax
  801b76:	6a 00                	push   $0x0
  801b78:	e8 f4 f0 ff ff       	call   800c71 <sys_page_alloc>
  801b7d:	89 c3                	mov    %eax,%ebx
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	85 c0                	test   %eax,%eax
  801b84:	0f 88 89 00 00 00    	js     801c13 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8a:	83 ec 0c             	sub    $0xc,%esp
  801b8d:	ff 75 f0             	pushl  -0x10(%ebp)
  801b90:	e8 b1 f5 ff ff       	call   801146 <fd2data>
  801b95:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b9c:	50                   	push   %eax
  801b9d:	6a 00                	push   $0x0
  801b9f:	56                   	push   %esi
  801ba0:	6a 00                	push   $0x0
  801ba2:	e8 0d f1 ff ff       	call   800cb4 <sys_page_map>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	83 c4 20             	add    $0x20,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 55                	js     801c05 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bb0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bc5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bce:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bda:	83 ec 0c             	sub    $0xc,%esp
  801bdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801be0:	e8 51 f5 ff ff       	call   801136 <fd2num>
  801be5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bea:	83 c4 04             	add    $0x4,%esp
  801bed:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf0:	e8 41 f5 ff ff       	call   801136 <fd2num>
  801bf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	ba 00 00 00 00       	mov    $0x0,%edx
  801c03:	eb 30                	jmp    801c35 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c05:	83 ec 08             	sub    $0x8,%esp
  801c08:	56                   	push   %esi
  801c09:	6a 00                	push   $0x0
  801c0b:	e8 e6 f0 ff ff       	call   800cf6 <sys_page_unmap>
  801c10:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c13:	83 ec 08             	sub    $0x8,%esp
  801c16:	ff 75 f0             	pushl  -0x10(%ebp)
  801c19:	6a 00                	push   $0x0
  801c1b:	e8 d6 f0 ff ff       	call   800cf6 <sys_page_unmap>
  801c20:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c23:	83 ec 08             	sub    $0x8,%esp
  801c26:	ff 75 f4             	pushl  -0xc(%ebp)
  801c29:	6a 00                	push   $0x0
  801c2b:	e8 c6 f0 ff ff       	call   800cf6 <sys_page_unmap>
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c35:	89 d0                	mov    %edx,%eax
  801c37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3a:	5b                   	pop    %ebx
  801c3b:	5e                   	pop    %esi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c47:	50                   	push   %eax
  801c48:	ff 75 08             	pushl  0x8(%ebp)
  801c4b:	e8 5c f5 ff ff       	call   8011ac <fd_lookup>
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 18                	js     801c6f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c57:	83 ec 0c             	sub    $0xc,%esp
  801c5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5d:	e8 e4 f4 ff ff       	call   801146 <fd2data>
	return _pipeisclosed(fd, p);
  801c62:	89 c2                	mov    %eax,%edx
  801c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c67:	e8 21 fd ff ff       	call   80198d <_pipeisclosed>
  801c6c:	83 c4 10             	add    $0x10,%esp
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	56                   	push   %esi
  801c75:	53                   	push   %ebx
  801c76:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801c79:	85 f6                	test   %esi,%esi
  801c7b:	75 16                	jne    801c93 <wait+0x22>
  801c7d:	68 f8 29 80 00       	push   $0x8029f8
  801c82:	68 b8 29 80 00       	push   $0x8029b8
  801c87:	6a 09                	push   $0x9
  801c89:	68 03 2a 80 00       	push   $0x802a03
  801c8e:	e8 7d e5 ff ff       	call   800210 <_panic>
	e = &envs[ENVX(envid)];
  801c93:	89 f3                	mov    %esi,%ebx
  801c95:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c9b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801c9e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801ca4:	eb 05                	jmp    801cab <wait+0x3a>
		sys_yield();
  801ca6:	e8 a7 ef ff ff       	call   800c52 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801cab:	8b 43 48             	mov    0x48(%ebx),%eax
  801cae:	39 c6                	cmp    %eax,%esi
  801cb0:	75 07                	jne    801cb9 <wait+0x48>
  801cb2:	8b 43 54             	mov    0x54(%ebx),%eax
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	75 ed                	jne    801ca6 <wait+0x35>
		sys_yield();
}
  801cb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbc:	5b                   	pop    %ebx
  801cbd:	5e                   	pop    %esi
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    

00801cc0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    

00801cca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd0:	68 0e 2a 80 00       	push   $0x802a0e
  801cd5:	ff 75 0c             	pushl  0xc(%ebp)
  801cd8:	e8 91 eb ff ff       	call   80086e <strcpy>
	return 0;
}
  801cdd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	57                   	push   %edi
  801ce8:	56                   	push   %esi
  801ce9:	53                   	push   %ebx
  801cea:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cfb:	eb 2d                	jmp    801d2a <devcons_write+0x46>
		m = n - tot;
  801cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d00:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d02:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d05:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d0a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d0d:	83 ec 04             	sub    $0x4,%esp
  801d10:	53                   	push   %ebx
  801d11:	03 45 0c             	add    0xc(%ebp),%eax
  801d14:	50                   	push   %eax
  801d15:	57                   	push   %edi
  801d16:	e8 e5 ec ff ff       	call   800a00 <memmove>
		sys_cputs(buf, m);
  801d1b:	83 c4 08             	add    $0x8,%esp
  801d1e:	53                   	push   %ebx
  801d1f:	57                   	push   %edi
  801d20:	e8 90 ee ff ff       	call   800bb5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d25:	01 de                	add    %ebx,%esi
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	89 f0                	mov    %esi,%eax
  801d2c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d2f:	72 cc                	jb     801cfd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 08             	sub    $0x8,%esp
  801d3f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d48:	74 2a                	je     801d74 <devcons_read+0x3b>
  801d4a:	eb 05                	jmp    801d51 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d4c:	e8 01 ef ff ff       	call   800c52 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d51:	e8 7d ee ff ff       	call   800bd3 <sys_cgetc>
  801d56:	85 c0                	test   %eax,%eax
  801d58:	74 f2                	je     801d4c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 16                	js     801d74 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d5e:	83 f8 04             	cmp    $0x4,%eax
  801d61:	74 0c                	je     801d6f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d63:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d66:	88 02                	mov    %al,(%edx)
	return 1;
  801d68:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6d:	eb 05                	jmp    801d74 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d6f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d74:	c9                   	leave  
  801d75:	c3                   	ret    

00801d76 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d82:	6a 01                	push   $0x1
  801d84:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d87:	50                   	push   %eax
  801d88:	e8 28 ee ff ff       	call   800bb5 <sys_cputs>
}
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	c9                   	leave  
  801d91:	c3                   	ret    

00801d92 <getchar>:

int
getchar(void)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d98:	6a 01                	push   $0x1
  801d9a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9d:	50                   	push   %eax
  801d9e:	6a 00                	push   $0x0
  801da0:	e8 6d f6 ff ff       	call   801412 <read>
	if (r < 0)
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	85 c0                	test   %eax,%eax
  801daa:	78 0f                	js     801dbb <getchar+0x29>
		return r;
	if (r < 1)
  801dac:	85 c0                	test   %eax,%eax
  801dae:	7e 06                	jle    801db6 <getchar+0x24>
		return -E_EOF;
	return c;
  801db0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801db4:	eb 05                	jmp    801dbb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801db6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dbb:	c9                   	leave  
  801dbc:	c3                   	ret    

00801dbd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc6:	50                   	push   %eax
  801dc7:	ff 75 08             	pushl  0x8(%ebp)
  801dca:	e8 dd f3 ff ff       	call   8011ac <fd_lookup>
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	78 11                	js     801de7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ddf:	39 10                	cmp    %edx,(%eax)
  801de1:	0f 94 c0             	sete   %al
  801de4:	0f b6 c0             	movzbl %al,%eax
}
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <opencons>:

int
opencons(void)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801def:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df2:	50                   	push   %eax
  801df3:	e8 65 f3 ff ff       	call   80115d <fd_alloc>
  801df8:	83 c4 10             	add    $0x10,%esp
		return r;
  801dfb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 3e                	js     801e3f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e01:	83 ec 04             	sub    $0x4,%esp
  801e04:	68 07 04 00 00       	push   $0x407
  801e09:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0c:	6a 00                	push   $0x0
  801e0e:	e8 5e ee ff ff       	call   800c71 <sys_page_alloc>
  801e13:	83 c4 10             	add    $0x10,%esp
		return r;
  801e16:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	78 23                	js     801e3f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e1c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e25:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e31:	83 ec 0c             	sub    $0xc,%esp
  801e34:	50                   	push   %eax
  801e35:	e8 fc f2 ff ff       	call   801136 <fd2num>
  801e3a:	89 c2                	mov    %eax,%edx
  801e3c:	83 c4 10             	add    $0x10,%esp
}
  801e3f:	89 d0                	mov    %edx,%eax
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    

00801e43 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e49:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e50:	75 64                	jne    801eb6 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801e52:	a1 20 44 80 00       	mov    0x804420,%eax
  801e57:	8b 40 48             	mov    0x48(%eax),%eax
  801e5a:	83 ec 04             	sub    $0x4,%esp
  801e5d:	6a 07                	push   $0x7
  801e5f:	68 00 f0 bf ee       	push   $0xeebff000
  801e64:	50                   	push   %eax
  801e65:	e8 07 ee ff ff       	call   800c71 <sys_page_alloc>
		if ( r != 0)
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	74 14                	je     801e85 <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  801e71:	83 ec 04             	sub    $0x4,%esp
  801e74:	68 1c 2a 80 00       	push   $0x802a1c
  801e79:	6a 24                	push   $0x24
  801e7b:	68 6a 2a 80 00       	push   $0x802a6a
  801e80:	e8 8b e3 ff ff       	call   800210 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  801e85:	a1 20 44 80 00       	mov    0x804420,%eax
  801e8a:	8b 40 48             	mov    0x48(%eax),%eax
  801e8d:	83 ec 08             	sub    $0x8,%esp
  801e90:	68 c0 1e 80 00       	push   $0x801ec0
  801e95:	50                   	push   %eax
  801e96:	e8 21 ef ff ff       	call   800dbc <sys_env_set_pgfault_upcall>
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	79 14                	jns    801eb6 <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  801ea2:	83 ec 04             	sub    $0x4,%esp
  801ea5:	68 48 2a 80 00       	push   $0x802a48
  801eaa:	6a 27                	push   $0x27
  801eac:	68 6a 2a 80 00       	push   $0x802a6a
  801eb1:	e8 5a e3 ff ff       	call   800210 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb9:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ec0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ec1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ec6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ec8:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  801ecb:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  801ecf:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  801ed1:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  801ed5:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  801ed6:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  801ed9:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  801edb:	83 c4 08             	add    $0x8,%esp
popal
  801ede:	61                   	popa   
addl $0x4, %esp
  801edf:	83 c4 04             	add    $0x4,%esp
popfl
  801ee2:	9d                   	popf   
popl %esp
  801ee3:	5c                   	pop    %esp
ret
  801ee4:	c3                   	ret    

00801ee5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
  801eea:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef0:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	74 0e                	je     801f05 <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  801ef7:	83 ec 0c             	sub    $0xc,%esp
  801efa:	50                   	push   %eax
  801efb:	e8 21 ef ff ff       	call   800e21 <sys_ipc_recv>
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	eb 10                	jmp    801f15 <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  801f05:	83 ec 0c             	sub    $0xc,%esp
  801f08:	68 00 00 00 f0       	push   $0xf0000000
  801f0d:	e8 0f ef ff ff       	call   800e21 <sys_ipc_recv>
  801f12:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  801f15:	85 c0                	test   %eax,%eax
  801f17:	74 16                	je     801f2f <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  801f19:	85 db                	test   %ebx,%ebx
  801f1b:	74 36                	je     801f53 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  801f1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  801f23:	85 f6                	test   %esi,%esi
  801f25:	74 2c                	je     801f53 <ipc_recv+0x6e>
				*perm_store = 0;
  801f27:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f2d:	eb 24                	jmp    801f53 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  801f2f:	85 db                	test   %ebx,%ebx
  801f31:	74 18                	je     801f4b <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  801f33:	a1 20 44 80 00       	mov    0x804420,%eax
  801f38:	8b 40 74             	mov    0x74(%eax),%eax
  801f3b:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  801f3d:	85 f6                	test   %esi,%esi
  801f3f:	74 0a                	je     801f4b <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  801f41:	a1 20 44 80 00       	mov    0x804420,%eax
  801f46:	8b 40 78             	mov    0x78(%eax),%eax
  801f49:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  801f4b:	a1 20 44 80 00       	mov    0x804420,%eax
  801f50:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  801f53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f56:	5b                   	pop    %ebx
  801f57:	5e                   	pop    %esi
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	57                   	push   %edi
  801f5e:	56                   	push   %esi
  801f5f:	53                   	push   %ebx
  801f60:	83 ec 0c             	sub    $0xc,%esp
  801f63:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f66:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  801f69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f6d:	75 39                	jne    801fa8 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  801f6f:	6a 00                	push   $0x0
  801f71:	68 00 00 00 f0       	push   $0xf0000000
  801f76:	56                   	push   %esi
  801f77:	57                   	push   %edi
  801f78:	e8 81 ee ff ff       	call   800dfe <sys_ipc_try_send>
  801f7d:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f85:	74 16                	je     801f9d <ipc_send+0x43>
  801f87:	85 c0                	test   %eax,%eax
  801f89:	74 12                	je     801f9d <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801f8b:	50                   	push   %eax
  801f8c:	68 78 2a 80 00       	push   $0x802a78
  801f91:	6a 4f                	push   $0x4f
  801f93:	68 b0 2a 80 00       	push   $0x802ab0
  801f98:	e8 73 e2 ff ff       	call   800210 <_panic>
			sys_yield();
  801f9d:	e8 b0 ec ff ff       	call   800c52 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  801fa2:	85 db                	test   %ebx,%ebx
  801fa4:	75 c9                	jne    801f6f <ipc_send+0x15>
  801fa6:	eb 36                	jmp    801fde <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  801fa8:	ff 75 14             	pushl  0x14(%ebp)
  801fab:	ff 75 10             	pushl  0x10(%ebp)
  801fae:	56                   	push   %esi
  801faf:	57                   	push   %edi
  801fb0:	e8 49 ee ff ff       	call   800dfe <sys_ipc_try_send>
  801fb5:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fbd:	74 16                	je     801fd5 <ipc_send+0x7b>
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	74 12                	je     801fd5 <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801fc3:	50                   	push   %eax
  801fc4:	68 78 2a 80 00       	push   $0x802a78
  801fc9:	6a 5a                	push   $0x5a
  801fcb:	68 b0 2a 80 00       	push   $0x802ab0
  801fd0:	e8 3b e2 ff ff       	call   800210 <_panic>
			sys_yield();
  801fd5:	e8 78 ec ff ff       	call   800c52 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  801fda:	85 db                	test   %ebx,%ebx
  801fdc:	75 ca                	jne    801fa8 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  801fde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe1:	5b                   	pop    %ebx
  801fe2:	5e                   	pop    %esi
  801fe3:	5f                   	pop    %edi
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    

00801fe6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fec:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ff1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ff4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ffa:	8b 52 50             	mov    0x50(%edx),%edx
  801ffd:	39 ca                	cmp    %ecx,%edx
  801fff:	75 0d                	jne    80200e <ipc_find_env+0x28>
			return envs[i].env_id;
  802001:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802004:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802009:	8b 40 48             	mov    0x48(%eax),%eax
  80200c:	eb 0f                	jmp    80201d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80200e:	83 c0 01             	add    $0x1,%eax
  802011:	3d 00 04 00 00       	cmp    $0x400,%eax
  802016:	75 d9                	jne    801ff1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802018:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802025:	89 d0                	mov    %edx,%eax
  802027:	c1 e8 16             	shr    $0x16,%eax
  80202a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802031:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802036:	f6 c1 01             	test   $0x1,%cl
  802039:	74 1d                	je     802058 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80203b:	c1 ea 0c             	shr    $0xc,%edx
  80203e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802045:	f6 c2 01             	test   $0x1,%dl
  802048:	74 0e                	je     802058 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80204a:	c1 ea 0c             	shr    $0xc,%edx
  80204d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802054:	ef 
  802055:	0f b7 c0             	movzwl %ax,%eax
}
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80206b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80206f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 f6                	test   %esi,%esi
  802079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207d:	89 ca                	mov    %ecx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	75 3d                	jne    8020c0 <__udivdi3+0x60>
  802083:	39 cf                	cmp    %ecx,%edi
  802085:	0f 87 c5 00 00 00    	ja     802150 <__udivdi3+0xf0>
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 fd                	mov    %edi,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f7                	div    %edi
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	89 cf                	mov    %ecx,%edi
  8020a8:	f7 f5                	div    %ebp
  8020aa:	89 c3                	mov    %eax,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 ce                	cmp    %ecx,%esi
  8020c2:	77 74                	ja     802138 <__udivdi3+0xd8>
  8020c4:	0f bd fe             	bsr    %esi,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0x108>
  8020d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	89 c5                	mov    %eax,%ebp
  8020d9:	29 fb                	sub    %edi,%ebx
  8020db:	d3 e6                	shl    %cl,%esi
  8020dd:	89 d9                	mov    %ebx,%ecx
  8020df:	d3 ed                	shr    %cl,%ebp
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	09 ee                	or     %ebp,%esi
  8020e7:	89 d9                	mov    %ebx,%ecx
  8020e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ed:	89 d5                	mov    %edx,%ebp
  8020ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020f3:	d3 ed                	shr    %cl,%ebp
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e2                	shl    %cl,%edx
  8020f9:	89 d9                	mov    %ebx,%ecx
  8020fb:	d3 e8                	shr    %cl,%eax
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	89 ea                	mov    %ebp,%edx
  802103:	f7 f6                	div    %esi
  802105:	89 d5                	mov    %edx,%ebp
  802107:	89 c3                	mov    %eax,%ebx
  802109:	f7 64 24 0c          	mull   0xc(%esp)
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	72 10                	jb     802121 <__udivdi3+0xc1>
  802111:	8b 74 24 08          	mov    0x8(%esp),%esi
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e6                	shl    %cl,%esi
  802119:	39 c6                	cmp    %eax,%esi
  80211b:	73 07                	jae    802124 <__udivdi3+0xc4>
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	75 03                	jne    802124 <__udivdi3+0xc4>
  802121:	83 eb 01             	sub    $0x1,%ebx
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 d8                	mov    %ebx,%eax
  802128:	89 fa                	mov    %edi,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	31 db                	xor    %ebx,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d8                	mov    %ebx,%eax
  802152:	f7 f7                	div    %edi
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 c3                	mov    %eax,%ebx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	72 0c                	jb     802178 <__udivdi3+0x118>
  80216c:	31 db                	xor    %ebx,%ebx
  80216e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802172:	0f 87 34 ff ff ff    	ja     8020ac <__udivdi3+0x4c>
  802178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80217d:	e9 2a ff ff ff       	jmp    8020ac <__udivdi3+0x4c>
  802182:	66 90                	xchg   %ax,%ax
  802184:	66 90                	xchg   %ax,%ax
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 d2                	test   %edx,%edx
  8021a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f3                	mov    %esi,%ebx
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x48>
  8021bc:	39 f7                	cmp    %esi,%edi
  8021be:	76 50                	jbe    802210 <__umoddi3+0x80>
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	f7 f7                	div    %edi
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	31 d2                	xor    %edx,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	77 52                	ja     802230 <__umoddi3+0xa0>
  8021de:	0f bd ea             	bsr    %edx,%ebp
  8021e1:	83 f5 1f             	xor    $0x1f,%ebp
  8021e4:	75 5a                	jne    802240 <__umoddi3+0xb0>
  8021e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ea:	0f 82 e0 00 00 00    	jb     8022d0 <__umoddi3+0x140>
  8021f0:	39 0c 24             	cmp    %ecx,(%esp)
  8021f3:	0f 86 d7 00 00 00    	jbe    8022d0 <__umoddi3+0x140>
  8021f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	85 ff                	test   %edi,%edi
  802212:	89 fd                	mov    %edi,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x91>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f7                	div    %edi
  80221f:	89 c5                	mov    %eax,%ebp
  802221:	89 f0                	mov    %esi,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f5                	div    %ebp
  802227:	89 c8                	mov    %ecx,%eax
  802229:	f7 f5                	div    %ebp
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	eb 99                	jmp    8021c8 <__umoddi3+0x38>
  80222f:	90                   	nop
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	8b 34 24             	mov    (%esp),%esi
  802243:	bf 20 00 00 00       	mov    $0x20,%edi
  802248:	89 e9                	mov    %ebp,%ecx
  80224a:	29 ef                	sub    %ebp,%edi
  80224c:	d3 e0                	shl    %cl,%eax
  80224e:	89 f9                	mov    %edi,%ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	d3 ea                	shr    %cl,%edx
  802254:	89 e9                	mov    %ebp,%ecx
  802256:	09 c2                	or     %eax,%edx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 14 24             	mov    %edx,(%esp)
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	89 f9                	mov    %edi,%ecx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	89 c6                	mov    %eax,%esi
  802271:	d3 e3                	shl    %cl,%ebx
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 d0                	mov    %edx,%eax
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	09 d8                	or     %ebx,%eax
  80227d:	89 d3                	mov    %edx,%ebx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	f7 34 24             	divl   (%esp)
  802284:	89 d6                	mov    %edx,%esi
  802286:	d3 e3                	shl    %cl,%ebx
  802288:	f7 64 24 04          	mull   0x4(%esp)
  80228c:	39 d6                	cmp    %edx,%esi
  80228e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802292:	89 d1                	mov    %edx,%ecx
  802294:	89 c3                	mov    %eax,%ebx
  802296:	72 08                	jb     8022a0 <__umoddi3+0x110>
  802298:	75 11                	jne    8022ab <__umoddi3+0x11b>
  80229a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80229e:	73 0b                	jae    8022ab <__umoddi3+0x11b>
  8022a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022a4:	1b 14 24             	sbb    (%esp),%edx
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 c3                	mov    %eax,%ebx
  8022ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022af:	29 da                	sub    %ebx,%edx
  8022b1:	19 ce                	sbb    %ecx,%esi
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d0                	or     %edx,%eax
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	83 c4 1c             	add    $0x1c,%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	29 f9                	sub    %edi,%ecx
  8022d2:	19 d6                	sbb    %edx,%esi
  8022d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022dc:	e9 18 ff ff ff       	jmp    8021f9 <__umoddi3+0x69>
