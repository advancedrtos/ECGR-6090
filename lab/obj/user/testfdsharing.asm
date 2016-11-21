
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
  80003e:	68 00 28 80 00       	push   $0x802800
  800043:	e8 c9 18 00 00       	call   801911 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 05 28 80 00       	push   $0x802805
  800057:	6a 0c                	push   $0xc
  800059:	68 13 28 80 00       	push   $0x802813
  80005e:	e8 ad 01 00 00       	call   800210 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 7e 15 00 00       	call   8015ec <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 96 14 00 00       	call   801517 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 28 28 80 00       	push   $0x802828
  800090:	6a 0f                	push   $0xf
  800092:	68 13 28 80 00       	push   $0x802813
  800097:	e8 74 01 00 00       	call   800210 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 d0 0e 00 00       	call   800f71 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 81 2d 80 00       	push   $0x802d81
  8000ad:	6a 12                	push   $0x12
  8000af:	68 13 28 80 00       	push   $0x802813
  8000b4:	e8 57 01 00 00       	call   800210 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 20 15 00 00       	call   8015ec <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 68 28 80 00 	movl   $0x802868,(%esp)
  8000d3:	e8 11 02 00 00       	call   8002e9 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 2c 14 00 00       	call   801517 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 ac 28 80 00       	push   $0x8028ac
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 13 28 80 00       	push   $0x802813
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
  800125:	68 d8 28 80 00       	push   $0x8028d8
  80012a:	6a 19                	push   $0x19
  80012c:	68 13 28 80 00       	push   $0x802813
  800131:	e8 da 00 00 00       	call   800210 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 32 28 80 00       	push   $0x802832
  80013e:	e8 a6 01 00 00       	call   8002e9 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 9e 14 00 00       	call   8015ec <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 f4 11 00 00       	call   80134a <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 11 20 00 00       	call   802178 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 9d 13 00 00       	call   801517 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 10 29 80 00       	push   $0x802910
  80018b:	6a 21                	push   $0x21
  80018d:	68 13 28 80 00       	push   $0x802813
  800192:	e8 79 00 00 00       	call   800210 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 4b 28 80 00       	push   $0x80284b
  80019f:	e8 45 01 00 00       	call   8002e9 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 9e 11 00 00       	call   80134a <close>
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
  80022e:	68 40 29 80 00       	push   $0x802940
  800233:	e8 b1 00 00 00       	call   8002e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800238:	83 c4 18             	add    $0x18,%esp
  80023b:	53                   	push   %ebx
  80023c:	ff 75 10             	pushl  0x10(%ebp)
  80023f:	e8 54 00 00 00       	call   800298 <vcprintf>
	cprintf("\n");
  800244:	c7 04 24 49 28 80 00 	movl   $0x802849,(%esp)
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
  80034c:	e8 1f 22 00 00       	call   802570 <__udivdi3>
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
  80038f:	e8 0c 23 00 00       	call   8026a0 <__umoddi3>
  800394:	83 c4 14             	add    $0x14,%esp
  800397:	0f be 80 63 29 80 00 	movsbl 0x802963(%eax),%eax
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
  800493:	ff 24 85 a0 2a 80 00 	jmp    *0x802aa0(,%eax,4)
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
  800557:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  80055e:	85 d2                	test   %edx,%edx
  800560:	75 18                	jne    80057a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800562:	50                   	push   %eax
  800563:	68 7b 29 80 00       	push   $0x80297b
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
  80057b:	68 a5 2e 80 00       	push   $0x802ea5
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
  80059f:	b8 74 29 80 00       	mov    $0x802974,%eax
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
  800c1a:	68 5f 2c 80 00       	push   $0x802c5f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 7c 2c 80 00       	push   $0x802c7c
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
  800c9b:	68 5f 2c 80 00       	push   $0x802c5f
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 7c 2c 80 00       	push   $0x802c7c
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
  800cdd:	68 5f 2c 80 00       	push   $0x802c5f
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 7c 2c 80 00       	push   $0x802c7c
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
  800d1f:	68 5f 2c 80 00       	push   $0x802c5f
  800d24:	6a 23                	push   $0x23
  800d26:	68 7c 2c 80 00       	push   $0x802c7c
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
  800d61:	68 5f 2c 80 00       	push   $0x802c5f
  800d66:	6a 23                	push   $0x23
  800d68:	68 7c 2c 80 00       	push   $0x802c7c
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
  800da3:	68 5f 2c 80 00       	push   $0x802c5f
  800da8:	6a 23                	push   $0x23
  800daa:	68 7c 2c 80 00       	push   $0x802c7c
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
  800de5:	68 5f 2c 80 00       	push   $0x802c5f
  800dea:	6a 23                	push   $0x23
  800dec:	68 7c 2c 80 00       	push   $0x802c7c
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
  800e49:	68 5f 2c 80 00       	push   $0x802c5f
  800e4e:	6a 23                	push   $0x23
  800e50:	68 7c 2c 80 00       	push   $0x802c7c
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

00800e62 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	57                   	push   %edi
  800e66:	56                   	push   %esi
  800e67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e68:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e72:	89 d1                	mov    %edx,%ecx
  800e74:	89 d3                	mov    %edx,%ebx
  800e76:	89 d7                	mov    %edx,%edi
  800e78:	89 d6                	mov    %edx,%esi
  800e7a:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	53                   	push   %ebx
  800e85:	83 ec 04             	sub    $0x4,%esp
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e8b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800e8d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e91:	75 14                	jne    800ea7 <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	68 8c 2c 80 00       	push   $0x802c8c
  800e9b:	6a 22                	push   $0x22
  800e9d:	68 6f 2d 80 00       	push   $0x802d6f
  800ea2:	e8 69 f3 ff ff       	call   800210 <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800ea7:	89 d8                	mov    %ebx,%eax
  800ea9:	c1 e8 0c             	shr    $0xc,%eax
  800eac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb3:	f6 c4 08             	test   $0x8,%ah
  800eb6:	75 14                	jne    800ecc <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800eb8:	83 ec 04             	sub    $0x4,%esp
  800ebb:	68 c8 2c 80 00       	push   $0x802cc8
  800ec0:	6a 27                	push   $0x27
  800ec2:	68 6f 2d 80 00       	push   $0x802d6f
  800ec7:	e8 44 f3 ff ff       	call   800210 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800ecc:	83 ec 04             	sub    $0x4,%esp
  800ecf:	6a 07                	push   $0x7
  800ed1:	68 00 f0 7f 00       	push   $0x7ff000
  800ed6:	6a 00                	push   $0x0
  800ed8:	e8 94 fd ff ff       	call   800c71 <sys_page_alloc>
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	79 14                	jns    800ef8 <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	68 f8 2c 80 00       	push   $0x802cf8
  800eec:	6a 2f                	push   $0x2f
  800eee:	68 6f 2d 80 00       	push   $0x802d6f
  800ef3:	e8 18 f3 ff ff       	call   800210 <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800ef8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	68 00 10 00 00       	push   $0x1000
  800f06:	53                   	push   %ebx
  800f07:	68 00 f0 7f 00       	push   $0x7ff000
  800f0c:	e8 ef fa ff ff       	call   800a00 <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f11:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f18:	53                   	push   %ebx
  800f19:	6a 00                	push   $0x0
  800f1b:	68 00 f0 7f 00       	push   $0x7ff000
  800f20:	6a 00                	push   $0x0
  800f22:	e8 8d fd ff ff       	call   800cb4 <sys_page_map>
  800f27:	83 c4 20             	add    $0x20,%esp
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	79 14                	jns    800f42 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	68 24 2d 80 00       	push   $0x802d24
  800f36:	6a 34                	push   $0x34
  800f38:	68 6f 2d 80 00       	push   $0x802d6f
  800f3d:	e8 ce f2 ff ff       	call   800210 <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f42:	83 ec 08             	sub    $0x8,%esp
  800f45:	68 00 f0 7f 00       	push   $0x7ff000
  800f4a:	6a 00                	push   $0x0
  800f4c:	e8 a5 fd ff ff       	call   800cf6 <sys_page_unmap>
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	79 14                	jns    800f6c <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	68 4c 2d 80 00       	push   $0x802d4c
  800f60:	6a 37                	push   $0x37
  800f62:	68 6f 2d 80 00       	push   $0x802d6f
  800f67:	e8 a4 f2 ff ff       	call   800210 <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800f7a:	68 81 0e 80 00       	push   $0x800e81
  800f7f:	e8 c6 13 00 00       	call   80234a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f84:	b8 07 00 00 00       	mov    $0x7,%eax
  800f89:	cd 30                	int    $0x30
  800f8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	79 15                	jns    800fad <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800f98:	50                   	push   %eax
  800f99:	68 7a 2d 80 00       	push   $0x802d7a
  800f9e:	68 8d 00 00 00       	push   $0x8d
  800fa3:	68 6f 2d 80 00       	push   $0x802d6f
  800fa8:	e8 63 f2 ff ff       	call   800210 <_panic>
  800fad:	be 00 00 00 00       	mov    $0x0,%esi
  800fb2:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  800fb7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fbb:	75 21                	jne    800fde <fork+0x6d>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  800fbd:	e8 71 fc ff ff       	call   800c33 <sys_getenvid>
  800fc2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fcf:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  800fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd9:	e9 aa 01 00 00       	jmp    801188 <fork+0x217>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  800fde:	89 f0                	mov    %esi,%eax
  800fe0:	c1 e8 16             	shr    $0x16,%eax
  800fe3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fea:	a8 01                	test   $0x1,%al
  800fec:	0f 84 f9 00 00 00    	je     8010eb <fork+0x17a>
  800ff2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ff9:	a8 05                	test   $0x5,%al
  800ffb:	0f 84 ea 00 00 00    	je     8010eb <fork+0x17a>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
  801001:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801008:	a8 02                	test   $0x2,%al
  80100a:	75 1c                	jne    801028 <fork+0xb7>
  80100c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801013:	f6 c4 08             	test   $0x8,%ah
  801016:	75 10                	jne    801028 <fork+0xb7>
  801018:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80101f:	f6 c4 04             	test   $0x4,%ah
  801022:	0f 84 99 00 00 00    	je     8010c1 <fork+0x150>
	{
		if(uvpt[pn] & PTE_SHARE)
  801028:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80102f:	f6 c4 04             	test   $0x4,%ah
  801032:	74 0f                	je     801043 <fork+0xd2>
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
  801034:	8b 3c 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edi
  80103b:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801041:	eb 2d                	jmp    801070 <fork+0xff>
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  801043:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
			perm = PTE_P|PTE_U|PTE_COW;
  80104a:	bf 05 08 00 00       	mov    $0x805,%edi
	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
	{
		if(uvpt[pn] & PTE_SHARE)
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  80104f:	a8 02                	test   $0x2,%al
  801051:	75 1d                	jne    801070 <fork+0xff>
  801053:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80105a:	25 00 08 00 00       	and    $0x800,%eax
			perm = PTE_P|PTE_U|PTE_COW;
  80105f:	83 f8 01             	cmp    $0x1,%eax
  801062:	19 ff                	sbb    %edi,%edi
  801064:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  80106a:	81 c7 05 08 00 00    	add    $0x805,%edi
		}

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm))) < 0)
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	ff 75 e4             	pushl  -0x1c(%ebp)
  801078:	56                   	push   %esi
  801079:	6a 00                	push   $0x0
  80107b:	e8 34 fc ff ff       	call   800cb4 <sys_page_map>
  801080:	83 c4 20             	add    $0x20,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	79 12                	jns    801099 <fork+0x128>
			panic("fork: sys_page_map: %e", r);
  801087:	50                   	push   %eax
  801088:	68 8a 2d 80 00       	push   $0x802d8a
  80108d:	6a 62                	push   $0x62
  80108f:	68 6f 2d 80 00       	push   $0x802d6f
  801094:	e8 77 f1 ff ff       	call   800210 <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm))) < 0)
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	57                   	push   %edi
  80109d:	56                   	push   %esi
  80109e:	6a 00                	push   $0x0
  8010a0:	56                   	push   %esi
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 0c fc ff ff       	call   800cb4 <sys_page_map>
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	79 3c                	jns    8010eb <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  8010af:	50                   	push   %eax
  8010b0:	68 8a 2d 80 00       	push   $0x802d8a
  8010b5:	6a 65                	push   $0x65
  8010b7:	68 6f 2d 80 00       	push   $0x802d6f
  8010bc:	e8 4f f1 ff ff       	call   800210 <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	6a 05                	push   $0x5
  8010c6:	56                   	push   %esi
  8010c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ca:	56                   	push   %esi
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 e2 fb ff ff       	call   800cb4 <sys_page_map>
  8010d2:	83 c4 20             	add    $0x20,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 12                	jns    8010eb <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  8010d9:	50                   	push   %eax
  8010da:	68 8a 2d 80 00       	push   $0x802d8a
  8010df:	6a 6a                	push   $0x6a
  8010e1:	68 6f 2d 80 00       	push   $0x802d6f
  8010e6:	e8 25 f1 ff ff       	call   800210 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  8010eb:	83 c3 01             	add    $0x1,%ebx
  8010ee:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8010f4:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8010fa:	0f 85 de fe ff ff    	jne    800fde <fork+0x6d>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	6a 07                	push   $0x7
  801105:	68 00 f0 bf ee       	push   $0xeebff000
  80110a:	ff 75 e0             	pushl  -0x20(%ebp)
  80110d:	e8 5f fb ff ff       	call   800c71 <sys_page_alloc>
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	79 15                	jns    80112e <fork+0x1bd>
		panic("sys_page_alloc: %e", r);
  801119:	50                   	push   %eax
  80111a:	68 a1 2d 80 00       	push   $0x802da1
  80111f:	68 9e 00 00 00       	push   $0x9e
  801124:	68 6f 2d 80 00       	push   $0x802d6f
  801129:	e8 e2 f0 ff ff       	call   800210 <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80112e:	83 ec 08             	sub    $0x8,%esp
  801131:	68 c7 23 80 00       	push   $0x8023c7
  801136:	ff 75 e0             	pushl  -0x20(%ebp)
  801139:	e8 7e fc ff ff       	call   800dbc <sys_env_set_pgfault_upcall>
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	79 17                	jns    80115c <fork+0x1eb>
		panic("sys_pgfault_upcall error");
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	68 b4 2d 80 00       	push   $0x802db4
  80114d:	68 a1 00 00 00       	push   $0xa1
  801152:	68 6f 2d 80 00       	push   $0x802d6f
  801157:	e8 b4 f0 ff ff       	call   800210 <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80115c:	83 ec 08             	sub    $0x8,%esp
  80115f:	6a 02                	push   $0x2
  801161:	ff 75 e0             	pushl  -0x20(%ebp)
  801164:	e8 cf fb ff ff       	call   800d38 <sys_env_set_status>
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	79 15                	jns    801185 <fork+0x214>
		panic("sys_env_set_status: %e", r);
  801170:	50                   	push   %eax
  801171:	68 cd 2d 80 00       	push   $0x802dcd
  801176:	68 a7 00 00 00       	push   $0xa7
  80117b:	68 6f 2d 80 00       	push   $0x802d6f
  801180:	e8 8b f0 ff ff       	call   800210 <_panic>

	return envid;
  801185:	8b 45 e0             	mov    -0x20(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  801188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <sfork>:

// Challenge!
int
sfork(void)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801196:	68 e4 2d 80 00       	push   $0x802de4
  80119b:	68 b2 00 00 00       	push   $0xb2
  8011a0:	68 6f 2d 80 00       	push   $0x802d6f
  8011a5:	e8 66 f0 ff ff       	call   800210 <_panic>

008011aa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b5:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ca:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	c1 ea 16             	shr    $0x16,%edx
  8011e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e8:	f6 c2 01             	test   $0x1,%dl
  8011eb:	74 11                	je     8011fe <fd_alloc+0x2d>
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	c1 ea 0c             	shr    $0xc,%edx
  8011f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f9:	f6 c2 01             	test   $0x1,%dl
  8011fc:	75 09                	jne    801207 <fd_alloc+0x36>
			*fd_store = fd;
  8011fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  801200:	b8 00 00 00 00       	mov    $0x0,%eax
  801205:	eb 17                	jmp    80121e <fd_alloc+0x4d>
  801207:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80120c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801211:	75 c9                	jne    8011dc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801213:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801219:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801226:	83 f8 1f             	cmp    $0x1f,%eax
  801229:	77 36                	ja     801261 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80122b:	c1 e0 0c             	shl    $0xc,%eax
  80122e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801233:	89 c2                	mov    %eax,%edx
  801235:	c1 ea 16             	shr    $0x16,%edx
  801238:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123f:	f6 c2 01             	test   $0x1,%dl
  801242:	74 24                	je     801268 <fd_lookup+0x48>
  801244:	89 c2                	mov    %eax,%edx
  801246:	c1 ea 0c             	shr    $0xc,%edx
  801249:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801250:	f6 c2 01             	test   $0x1,%dl
  801253:	74 1a                	je     80126f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801255:	8b 55 0c             	mov    0xc(%ebp),%edx
  801258:	89 02                	mov    %eax,(%edx)
	return 0;
  80125a:	b8 00 00 00 00       	mov    $0x0,%eax
  80125f:	eb 13                	jmp    801274 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801261:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801266:	eb 0c                	jmp    801274 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801268:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126d:	eb 05                	jmp    801274 <fd_lookup+0x54>
  80126f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	83 ec 08             	sub    $0x8,%esp
  80127c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127f:	ba 78 2e 80 00       	mov    $0x802e78,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801284:	eb 13                	jmp    801299 <dev_lookup+0x23>
  801286:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801289:	39 08                	cmp    %ecx,(%eax)
  80128b:	75 0c                	jne    801299 <dev_lookup+0x23>
			*dev = devtab[i];
  80128d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801290:	89 01                	mov    %eax,(%ecx)
			return 0;
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
  801297:	eb 2e                	jmp    8012c7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801299:	8b 02                	mov    (%edx),%eax
  80129b:	85 c0                	test   %eax,%eax
  80129d:	75 e7                	jne    801286 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80129f:	a1 20 44 80 00       	mov    0x804420,%eax
  8012a4:	8b 40 48             	mov    0x48(%eax),%eax
  8012a7:	83 ec 04             	sub    $0x4,%esp
  8012aa:	51                   	push   %ecx
  8012ab:	50                   	push   %eax
  8012ac:	68 fc 2d 80 00       	push   $0x802dfc
  8012b1:	e8 33 f0 ff ff       	call   8002e9 <cprintf>
	*dev = 0;
  8012b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    

008012c9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	56                   	push   %esi
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 10             	sub    $0x10,%esp
  8012d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e1:	c1 e8 0c             	shr    $0xc,%eax
  8012e4:	50                   	push   %eax
  8012e5:	e8 36 ff ff ff       	call   801220 <fd_lookup>
  8012ea:	83 c4 08             	add    $0x8,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 05                	js     8012f6 <fd_close+0x2d>
	    || fd != fd2)
  8012f1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012f4:	74 0c                	je     801302 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012f6:	84 db                	test   %bl,%bl
  8012f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fd:	0f 44 c2             	cmove  %edx,%eax
  801300:	eb 41                	jmp    801343 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801308:	50                   	push   %eax
  801309:	ff 36                	pushl  (%esi)
  80130b:	e8 66 ff ff ff       	call   801276 <dev_lookup>
  801310:	89 c3                	mov    %eax,%ebx
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 1a                	js     801333 <fd_close+0x6a>
		if (dev->dev_close)
  801319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80131f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801324:	85 c0                	test   %eax,%eax
  801326:	74 0b                	je     801333 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801328:	83 ec 0c             	sub    $0xc,%esp
  80132b:	56                   	push   %esi
  80132c:	ff d0                	call   *%eax
  80132e:	89 c3                	mov    %eax,%ebx
  801330:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	56                   	push   %esi
  801337:	6a 00                	push   $0x0
  801339:	e8 b8 f9 ff ff       	call   800cf6 <sys_page_unmap>
	return r;
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	89 d8                	mov    %ebx,%eax
}
  801343:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	ff 75 08             	pushl  0x8(%ebp)
  801357:	e8 c4 fe ff ff       	call   801220 <fd_lookup>
  80135c:	83 c4 08             	add    $0x8,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 10                	js     801373 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	6a 01                	push   $0x1
  801368:	ff 75 f4             	pushl  -0xc(%ebp)
  80136b:	e8 59 ff ff ff       	call   8012c9 <fd_close>
  801370:	83 c4 10             	add    $0x10,%esp
}
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <close_all>:

void
close_all(void)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	53                   	push   %ebx
  801379:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80137c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801381:	83 ec 0c             	sub    $0xc,%esp
  801384:	53                   	push   %ebx
  801385:	e8 c0 ff ff ff       	call   80134a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80138a:	83 c3 01             	add    $0x1,%ebx
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	83 fb 20             	cmp    $0x20,%ebx
  801393:	75 ec                	jne    801381 <close_all+0xc>
		close(i);
}
  801395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	57                   	push   %edi
  80139e:	56                   	push   %esi
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 2c             	sub    $0x2c,%esp
  8013a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013a9:	50                   	push   %eax
  8013aa:	ff 75 08             	pushl  0x8(%ebp)
  8013ad:	e8 6e fe ff ff       	call   801220 <fd_lookup>
  8013b2:	83 c4 08             	add    $0x8,%esp
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	0f 88 c1 00 00 00    	js     80147e <dup+0xe4>
		return r;
	close(newfdnum);
  8013bd:	83 ec 0c             	sub    $0xc,%esp
  8013c0:	56                   	push   %esi
  8013c1:	e8 84 ff ff ff       	call   80134a <close>

	newfd = INDEX2FD(newfdnum);
  8013c6:	89 f3                	mov    %esi,%ebx
  8013c8:	c1 e3 0c             	shl    $0xc,%ebx
  8013cb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013d1:	83 c4 04             	add    $0x4,%esp
  8013d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013d7:	e8 de fd ff ff       	call   8011ba <fd2data>
  8013dc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013de:	89 1c 24             	mov    %ebx,(%esp)
  8013e1:	e8 d4 fd ff ff       	call   8011ba <fd2data>
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ec:	89 f8                	mov    %edi,%eax
  8013ee:	c1 e8 16             	shr    $0x16,%eax
  8013f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f8:	a8 01                	test   $0x1,%al
  8013fa:	74 37                	je     801433 <dup+0x99>
  8013fc:	89 f8                	mov    %edi,%eax
  8013fe:	c1 e8 0c             	shr    $0xc,%eax
  801401:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801408:	f6 c2 01             	test   $0x1,%dl
  80140b:	74 26                	je     801433 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80140d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	25 07 0e 00 00       	and    $0xe07,%eax
  80141c:	50                   	push   %eax
  80141d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801420:	6a 00                	push   $0x0
  801422:	57                   	push   %edi
  801423:	6a 00                	push   $0x0
  801425:	e8 8a f8 ff ff       	call   800cb4 <sys_page_map>
  80142a:	89 c7                	mov    %eax,%edi
  80142c:	83 c4 20             	add    $0x20,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 2e                	js     801461 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801433:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801436:	89 d0                	mov    %edx,%eax
  801438:	c1 e8 0c             	shr    $0xc,%eax
  80143b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801442:	83 ec 0c             	sub    $0xc,%esp
  801445:	25 07 0e 00 00       	and    $0xe07,%eax
  80144a:	50                   	push   %eax
  80144b:	53                   	push   %ebx
  80144c:	6a 00                	push   $0x0
  80144e:	52                   	push   %edx
  80144f:	6a 00                	push   $0x0
  801451:	e8 5e f8 ff ff       	call   800cb4 <sys_page_map>
  801456:	89 c7                	mov    %eax,%edi
  801458:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80145b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145d:	85 ff                	test   %edi,%edi
  80145f:	79 1d                	jns    80147e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	53                   	push   %ebx
  801465:	6a 00                	push   $0x0
  801467:	e8 8a f8 ff ff       	call   800cf6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80146c:	83 c4 08             	add    $0x8,%esp
  80146f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801472:	6a 00                	push   $0x0
  801474:	e8 7d f8 ff ff       	call   800cf6 <sys_page_unmap>
	return r;
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	89 f8                	mov    %edi,%eax
}
  80147e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    

00801486 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	53                   	push   %ebx
  80148a:	83 ec 14             	sub    $0x14,%esp
  80148d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801490:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	53                   	push   %ebx
  801495:	e8 86 fd ff ff       	call   801220 <fd_lookup>
  80149a:	83 c4 08             	add    $0x8,%esp
  80149d:	89 c2                	mov    %eax,%edx
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 6d                	js     801510 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ad:	ff 30                	pushl  (%eax)
  8014af:	e8 c2 fd ff ff       	call   801276 <dev_lookup>
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 4c                	js     801507 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014be:	8b 42 08             	mov    0x8(%edx),%eax
  8014c1:	83 e0 03             	and    $0x3,%eax
  8014c4:	83 f8 01             	cmp    $0x1,%eax
  8014c7:	75 21                	jne    8014ea <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c9:	a1 20 44 80 00       	mov    0x804420,%eax
  8014ce:	8b 40 48             	mov    0x48(%eax),%eax
  8014d1:	83 ec 04             	sub    $0x4,%esp
  8014d4:	53                   	push   %ebx
  8014d5:	50                   	push   %eax
  8014d6:	68 3d 2e 80 00       	push   $0x802e3d
  8014db:	e8 09 ee ff ff       	call   8002e9 <cprintf>
		return -E_INVAL;
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e8:	eb 26                	jmp    801510 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ed:	8b 40 08             	mov    0x8(%eax),%eax
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	74 17                	je     80150b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f4:	83 ec 04             	sub    $0x4,%esp
  8014f7:	ff 75 10             	pushl  0x10(%ebp)
  8014fa:	ff 75 0c             	pushl  0xc(%ebp)
  8014fd:	52                   	push   %edx
  8014fe:	ff d0                	call   *%eax
  801500:	89 c2                	mov    %eax,%edx
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	eb 09                	jmp    801510 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801507:	89 c2                	mov    %eax,%edx
  801509:	eb 05                	jmp    801510 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80150b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801510:	89 d0                	mov    %edx,%eax
  801512:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801515:	c9                   	leave  
  801516:	c3                   	ret    

00801517 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	57                   	push   %edi
  80151b:	56                   	push   %esi
  80151c:	53                   	push   %ebx
  80151d:	83 ec 0c             	sub    $0xc,%esp
  801520:	8b 7d 08             	mov    0x8(%ebp),%edi
  801523:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801526:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152b:	eb 21                	jmp    80154e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152d:	83 ec 04             	sub    $0x4,%esp
  801530:	89 f0                	mov    %esi,%eax
  801532:	29 d8                	sub    %ebx,%eax
  801534:	50                   	push   %eax
  801535:	89 d8                	mov    %ebx,%eax
  801537:	03 45 0c             	add    0xc(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	57                   	push   %edi
  80153c:	e8 45 ff ff ff       	call   801486 <read>
		if (m < 0)
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	78 10                	js     801558 <readn+0x41>
			return m;
		if (m == 0)
  801548:	85 c0                	test   %eax,%eax
  80154a:	74 0a                	je     801556 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154c:	01 c3                	add    %eax,%ebx
  80154e:	39 f3                	cmp    %esi,%ebx
  801550:	72 db                	jb     80152d <readn+0x16>
  801552:	89 d8                	mov    %ebx,%eax
  801554:	eb 02                	jmp    801558 <readn+0x41>
  801556:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801558:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155b:	5b                   	pop    %ebx
  80155c:	5e                   	pop    %esi
  80155d:	5f                   	pop    %edi
  80155e:	5d                   	pop    %ebp
  80155f:	c3                   	ret    

00801560 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	53                   	push   %ebx
  801564:	83 ec 14             	sub    $0x14,%esp
  801567:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	53                   	push   %ebx
  80156f:	e8 ac fc ff ff       	call   801220 <fd_lookup>
  801574:	83 c4 08             	add    $0x8,%esp
  801577:	89 c2                	mov    %eax,%edx
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 68                	js     8015e5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157d:	83 ec 08             	sub    $0x8,%esp
  801580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801587:	ff 30                	pushl  (%eax)
  801589:	e8 e8 fc ff ff       	call   801276 <dev_lookup>
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	85 c0                	test   %eax,%eax
  801593:	78 47                	js     8015dc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801595:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801598:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159c:	75 21                	jne    8015bf <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80159e:	a1 20 44 80 00       	mov    0x804420,%eax
  8015a3:	8b 40 48             	mov    0x48(%eax),%eax
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	53                   	push   %ebx
  8015aa:	50                   	push   %eax
  8015ab:	68 59 2e 80 00       	push   $0x802e59
  8015b0:	e8 34 ed ff ff       	call   8002e9 <cprintf>
		return -E_INVAL;
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015bd:	eb 26                	jmp    8015e5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c5:	85 d2                	test   %edx,%edx
  8015c7:	74 17                	je     8015e0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	ff 75 10             	pushl  0x10(%ebp)
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	50                   	push   %eax
  8015d3:	ff d2                	call   *%edx
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	eb 09                	jmp    8015e5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dc:	89 c2                	mov    %eax,%edx
  8015de:	eb 05                	jmp    8015e5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015e5:	89 d0                	mov    %edx,%eax
  8015e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	ff 75 08             	pushl  0x8(%ebp)
  8015f9:	e8 22 fc ff ff       	call   801220 <fd_lookup>
  8015fe:	83 c4 08             	add    $0x8,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 0e                	js     801613 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801605:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801608:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80160e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801613:	c9                   	leave  
  801614:	c3                   	ret    

00801615 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	53                   	push   %ebx
  801619:	83 ec 14             	sub    $0x14,%esp
  80161c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	53                   	push   %ebx
  801624:	e8 f7 fb ff ff       	call   801220 <fd_lookup>
  801629:	83 c4 08             	add    $0x8,%esp
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 65                	js     801697 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801632:	83 ec 08             	sub    $0x8,%esp
  801635:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163c:	ff 30                	pushl  (%eax)
  80163e:	e8 33 fc ff ff       	call   801276 <dev_lookup>
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	78 44                	js     80168e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801651:	75 21                	jne    801674 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801653:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801658:	8b 40 48             	mov    0x48(%eax),%eax
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	53                   	push   %ebx
  80165f:	50                   	push   %eax
  801660:	68 1c 2e 80 00       	push   $0x802e1c
  801665:	e8 7f ec ff ff       	call   8002e9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801672:	eb 23                	jmp    801697 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801674:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801677:	8b 52 18             	mov    0x18(%edx),%edx
  80167a:	85 d2                	test   %edx,%edx
  80167c:	74 14                	je     801692 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	ff 75 0c             	pushl  0xc(%ebp)
  801684:	50                   	push   %eax
  801685:	ff d2                	call   *%edx
  801687:	89 c2                	mov    %eax,%edx
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	eb 09                	jmp    801697 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168e:	89 c2                	mov    %eax,%edx
  801690:	eb 05                	jmp    801697 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801692:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801697:	89 d0                	mov    %edx,%eax
  801699:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	53                   	push   %ebx
  8016a2:	83 ec 14             	sub    $0x14,%esp
  8016a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ab:	50                   	push   %eax
  8016ac:	ff 75 08             	pushl  0x8(%ebp)
  8016af:	e8 6c fb ff ff       	call   801220 <fd_lookup>
  8016b4:	83 c4 08             	add    $0x8,%esp
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 58                	js     801715 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c7:	ff 30                	pushl  (%eax)
  8016c9:	e8 a8 fb ff ff       	call   801276 <dev_lookup>
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 37                	js     80170c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016dc:	74 32                	je     801710 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016de:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016e8:	00 00 00 
	stat->st_isdir = 0;
  8016eb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f2:	00 00 00 
	stat->st_dev = dev;
  8016f5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016fb:	83 ec 08             	sub    $0x8,%esp
  8016fe:	53                   	push   %ebx
  8016ff:	ff 75 f0             	pushl  -0x10(%ebp)
  801702:	ff 50 14             	call   *0x14(%eax)
  801705:	89 c2                	mov    %eax,%edx
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	eb 09                	jmp    801715 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170c:	89 c2                	mov    %eax,%edx
  80170e:	eb 05                	jmp    801715 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801710:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801715:	89 d0                	mov    %edx,%eax
  801717:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801721:	83 ec 08             	sub    $0x8,%esp
  801724:	6a 00                	push   $0x0
  801726:	ff 75 08             	pushl  0x8(%ebp)
  801729:	e8 e3 01 00 00       	call   801911 <open>
  80172e:	89 c3                	mov    %eax,%ebx
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	78 1b                	js     801752 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	50                   	push   %eax
  80173e:	e8 5b ff ff ff       	call   80169e <fstat>
  801743:	89 c6                	mov    %eax,%esi
	close(fd);
  801745:	89 1c 24             	mov    %ebx,(%esp)
  801748:	e8 fd fb ff ff       	call   80134a <close>
	return r;
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	89 f0                	mov    %esi,%eax
}
  801752:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801755:	5b                   	pop    %ebx
  801756:	5e                   	pop    %esi
  801757:	5d                   	pop    %ebp
  801758:	c3                   	ret    

00801759 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	89 c6                	mov    %eax,%esi
  801760:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801762:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801769:	75 12                	jne    80177d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80176b:	83 ec 0c             	sub    $0xc,%esp
  80176e:	6a 01                	push   $0x1
  801770:	e8 78 0d 00 00       	call   8024ed <ipc_find_env>
  801775:	a3 00 40 80 00       	mov    %eax,0x804000
  80177a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80177d:	6a 07                	push   $0x7
  80177f:	68 00 50 80 00       	push   $0x805000
  801784:	56                   	push   %esi
  801785:	ff 35 00 40 80 00    	pushl  0x804000
  80178b:	e8 d1 0c 00 00       	call   802461 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801790:	83 c4 0c             	add    $0xc,%esp
  801793:	6a 00                	push   $0x0
  801795:	53                   	push   %ebx
  801796:	6a 00                	push   $0x0
  801798:	e8 4f 0c 00 00       	call   8023ec <ipc_recv>
}
  80179d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	5d                   	pop    %ebp
  8017a3:	c3                   	ret    

008017a4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c2:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c7:	e8 8d ff ff ff       	call   801759 <fsipc>
}
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017da:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 06 00 00 00       	mov    $0x6,%eax
  8017e9:	e8 6b ff ff ff       	call   801759 <fsipc>
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <devfile_stat>:
                return ((ssize_t)r);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801800:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801805:	ba 00 00 00 00       	mov    $0x0,%edx
  80180a:	b8 05 00 00 00       	mov    $0x5,%eax
  80180f:	e8 45 ff ff ff       	call   801759 <fsipc>
  801814:	85 c0                	test   %eax,%eax
  801816:	78 2c                	js     801844 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801818:	83 ec 08             	sub    $0x8,%esp
  80181b:	68 00 50 80 00       	push   $0x805000
  801820:	53                   	push   %ebx
  801821:	e8 48 f0 ff ff       	call   80086e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801826:	a1 80 50 80 00       	mov    0x805080,%eax
  80182b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801831:	a1 84 50 80 00       	mov    0x805084,%eax
  801836:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	83 ec 0c             	sub    $0xc,%esp
  80184f:	8b 45 10             	mov    0x10(%ebp),%eax
  801852:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801857:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80185c:	0f 47 c2             	cmova  %edx,%eax
	int r;
	if(n > (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t))))
	{
		n = (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t)));
	}
		fsipcbuf.write.req_fileid = fd->fd_file.id;
  80185f:	8b 55 08             	mov    0x8(%ebp),%edx
  801862:	8b 52 0c             	mov    0xc(%edx),%edx
  801865:	89 15 00 50 80 00    	mov    %edx,0x805000
		fsipcbuf.write.req_n = n;
  80186b:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove((void *)fsipcbuf.write.req_buf, buf, n);
  801870:	50                   	push   %eax
  801871:	ff 75 0c             	pushl  0xc(%ebp)
  801874:	68 08 50 80 00       	push   $0x805008
  801879:	e8 82 f1 ff ff       	call   800a00 <memmove>
		r = fsipc(FSREQ_WRITE, NULL);
  80187e:	ba 00 00 00 00       	mov    $0x0,%edx
  801883:	b8 04 00 00 00       	mov    $0x4,%eax
  801888:	e8 cc fe ff ff       	call   801759 <fsipc>
                return ((ssize_t)r);
}
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	56                   	push   %esi
  801893:	53                   	push   %ebx
  801894:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801897:	8b 45 08             	mov    0x8(%ebp),%eax
  80189a:	8b 40 0c             	mov    0xc(%eax),%eax
  80189d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b2:	e8 a2 fe ff ff       	call   801759 <fsipc>
  8018b7:	89 c3                	mov    %eax,%ebx
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 4b                	js     801908 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018bd:	39 c6                	cmp    %eax,%esi
  8018bf:	73 16                	jae    8018d7 <devfile_read+0x48>
  8018c1:	68 8c 2e 80 00       	push   $0x802e8c
  8018c6:	68 93 2e 80 00       	push   $0x802e93
  8018cb:	6a 7c                	push   $0x7c
  8018cd:	68 a8 2e 80 00       	push   $0x802ea8
  8018d2:	e8 39 e9 ff ff       	call   800210 <_panic>
	assert(r <= PGSIZE);
  8018d7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018dc:	7e 16                	jle    8018f4 <devfile_read+0x65>
  8018de:	68 b3 2e 80 00       	push   $0x802eb3
  8018e3:	68 93 2e 80 00       	push   $0x802e93
  8018e8:	6a 7d                	push   $0x7d
  8018ea:	68 a8 2e 80 00       	push   $0x802ea8
  8018ef:	e8 1c e9 ff ff       	call   800210 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018f4:	83 ec 04             	sub    $0x4,%esp
  8018f7:	50                   	push   %eax
  8018f8:	68 00 50 80 00       	push   $0x805000
  8018fd:	ff 75 0c             	pushl  0xc(%ebp)
  801900:	e8 fb f0 ff ff       	call   800a00 <memmove>
	return r;
  801905:	83 c4 10             	add    $0x10,%esp
}
  801908:	89 d8                	mov    %ebx,%eax
  80190a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190d:	5b                   	pop    %ebx
  80190e:	5e                   	pop    %esi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	53                   	push   %ebx
  801915:	83 ec 20             	sub    $0x20,%esp
  801918:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80191b:	53                   	push   %ebx
  80191c:	e8 14 ef ff ff       	call   800835 <strlen>
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801929:	7f 67                	jg     801992 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801931:	50                   	push   %eax
  801932:	e8 9a f8 ff ff       	call   8011d1 <fd_alloc>
  801937:	83 c4 10             	add    $0x10,%esp
		return r;
  80193a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 57                	js     801997 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801940:	83 ec 08             	sub    $0x8,%esp
  801943:	53                   	push   %ebx
  801944:	68 00 50 80 00       	push   $0x805000
  801949:	e8 20 ef ff ff       	call   80086e <strcpy>
	fsipcbuf.open.req_omode = mode;
  80194e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801951:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801956:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801959:	b8 01 00 00 00       	mov    $0x1,%eax
  80195e:	e8 f6 fd ff ff       	call   801759 <fsipc>
  801963:	89 c3                	mov    %eax,%ebx
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	79 14                	jns    801980 <open+0x6f>
		fd_close(fd, 0);
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	6a 00                	push   $0x0
  801971:	ff 75 f4             	pushl  -0xc(%ebp)
  801974:	e8 50 f9 ff ff       	call   8012c9 <fd_close>
		return r;
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	89 da                	mov    %ebx,%edx
  80197e:	eb 17                	jmp    801997 <open+0x86>
	}

	return fd2num(fd);
  801980:	83 ec 0c             	sub    $0xc,%esp
  801983:	ff 75 f4             	pushl  -0xc(%ebp)
  801986:	e8 1f f8 ff ff       	call   8011aa <fd2num>
  80198b:	89 c2                	mov    %eax,%edx
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	eb 05                	jmp    801997 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801992:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801997:	89 d0                	mov    %edx,%eax
  801999:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a9:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ae:	e8 a6 fd ff ff       	call   801759 <fsipc>
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019bb:	68 bf 2e 80 00       	push   $0x802ebf
  8019c0:	ff 75 0c             	pushl  0xc(%ebp)
  8019c3:	e8 a6 ee ff ff       	call   80086e <strcpy>
	return 0;
}
  8019c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	53                   	push   %ebx
  8019d3:	83 ec 10             	sub    $0x10,%esp
  8019d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019d9:	53                   	push   %ebx
  8019da:	e8 47 0b 00 00       	call   802526 <pageref>
  8019df:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019e2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019e7:	83 f8 01             	cmp    $0x1,%eax
  8019ea:	75 10                	jne    8019fc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019ec:	83 ec 0c             	sub    $0xc,%esp
  8019ef:	ff 73 0c             	pushl  0xc(%ebx)
  8019f2:	e8 c0 02 00 00       	call   801cb7 <nsipc_close>
  8019f7:	89 c2                	mov    %eax,%edx
  8019f9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019fc:	89 d0                	mov    %edx,%eax
  8019fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a09:	6a 00                	push   $0x0
  801a0b:	ff 75 10             	pushl  0x10(%ebp)
  801a0e:	ff 75 0c             	pushl  0xc(%ebp)
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	ff 70 0c             	pushl  0xc(%eax)
  801a17:	e8 78 03 00 00       	call   801d94 <nsipc_send>
}
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a24:	6a 00                	push   $0x0
  801a26:	ff 75 10             	pushl  0x10(%ebp)
  801a29:	ff 75 0c             	pushl  0xc(%ebp)
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	ff 70 0c             	pushl  0xc(%eax)
  801a32:	e8 f1 02 00 00       	call   801d28 <nsipc_recv>
}
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a3f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a42:	52                   	push   %edx
  801a43:	50                   	push   %eax
  801a44:	e8 d7 f7 ff ff       	call   801220 <fd_lookup>
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	78 17                	js     801a67 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a53:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a59:	39 08                	cmp    %ecx,(%eax)
  801a5b:	75 05                	jne    801a62 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a5d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a60:	eb 05                	jmp    801a67 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a62:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 1c             	sub    $0x1c,%esp
  801a71:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a76:	50                   	push   %eax
  801a77:	e8 55 f7 ff ff       	call   8011d1 <fd_alloc>
  801a7c:	89 c3                	mov    %eax,%ebx
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 1b                	js     801aa0 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a85:	83 ec 04             	sub    $0x4,%esp
  801a88:	68 07 04 00 00       	push   $0x407
  801a8d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a90:	6a 00                	push   $0x0
  801a92:	e8 da f1 ff ff       	call   800c71 <sys_page_alloc>
  801a97:	89 c3                	mov    %eax,%ebx
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	79 10                	jns    801ab0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	56                   	push   %esi
  801aa4:	e8 0e 02 00 00       	call   801cb7 <nsipc_close>
		return r;
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	89 d8                	mov    %ebx,%eax
  801aae:	eb 24                	jmp    801ad4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ab0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ac5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	50                   	push   %eax
  801acc:	e8 d9 f6 ff ff       	call   8011aa <fd2num>
  801ad1:	83 c4 10             	add    $0x10,%esp
}
  801ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	e8 50 ff ff ff       	call   801a39 <fd2sockid>
		return r;
  801ae9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 1f                	js     801b0e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aef:	83 ec 04             	sub    $0x4,%esp
  801af2:	ff 75 10             	pushl  0x10(%ebp)
  801af5:	ff 75 0c             	pushl  0xc(%ebp)
  801af8:	50                   	push   %eax
  801af9:	e8 12 01 00 00       	call   801c10 <nsipc_accept>
  801afe:	83 c4 10             	add    $0x10,%esp
		return r;
  801b01:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b03:	85 c0                	test   %eax,%eax
  801b05:	78 07                	js     801b0e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b07:	e8 5d ff ff ff       	call   801a69 <alloc_sockfd>
  801b0c:	89 c1                	mov    %eax,%ecx
}
  801b0e:	89 c8                	mov    %ecx,%eax
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	e8 19 ff ff ff       	call   801a39 <fd2sockid>
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 12                	js     801b36 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b24:	83 ec 04             	sub    $0x4,%esp
  801b27:	ff 75 10             	pushl  0x10(%ebp)
  801b2a:	ff 75 0c             	pushl  0xc(%ebp)
  801b2d:	50                   	push   %eax
  801b2e:	e8 2d 01 00 00       	call   801c60 <nsipc_bind>
  801b33:	83 c4 10             	add    $0x10,%esp
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <shutdown>:

int
shutdown(int s, int how)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	e8 f3 fe ff ff       	call   801a39 <fd2sockid>
  801b46:	85 c0                	test   %eax,%eax
  801b48:	78 0f                	js     801b59 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b4a:	83 ec 08             	sub    $0x8,%esp
  801b4d:	ff 75 0c             	pushl  0xc(%ebp)
  801b50:	50                   	push   %eax
  801b51:	e8 3f 01 00 00       	call   801c95 <nsipc_shutdown>
  801b56:	83 c4 10             	add    $0x10,%esp
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b61:	8b 45 08             	mov    0x8(%ebp),%eax
  801b64:	e8 d0 fe ff ff       	call   801a39 <fd2sockid>
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 12                	js     801b7f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b6d:	83 ec 04             	sub    $0x4,%esp
  801b70:	ff 75 10             	pushl  0x10(%ebp)
  801b73:	ff 75 0c             	pushl  0xc(%ebp)
  801b76:	50                   	push   %eax
  801b77:	e8 55 01 00 00       	call   801cd1 <nsipc_connect>
  801b7c:	83 c4 10             	add    $0x10,%esp
}
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <listen>:

int
listen(int s, int backlog)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b87:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8a:	e8 aa fe ff ff       	call   801a39 <fd2sockid>
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	78 0f                	js     801ba2 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b93:	83 ec 08             	sub    $0x8,%esp
  801b96:	ff 75 0c             	pushl  0xc(%ebp)
  801b99:	50                   	push   %eax
  801b9a:	e8 67 01 00 00       	call   801d06 <nsipc_listen>
  801b9f:	83 c4 10             	add    $0x10,%esp
}
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801baa:	ff 75 10             	pushl  0x10(%ebp)
  801bad:	ff 75 0c             	pushl  0xc(%ebp)
  801bb0:	ff 75 08             	pushl  0x8(%ebp)
  801bb3:	e8 3a 02 00 00       	call   801df2 <nsipc_socket>
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	78 05                	js     801bc4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bbf:	e8 a5 fe ff ff       	call   801a69 <alloc_sockfd>
}
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	53                   	push   %ebx
  801bca:	83 ec 04             	sub    $0x4,%esp
  801bcd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bcf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bd6:	75 12                	jne    801bea <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bd8:	83 ec 0c             	sub    $0xc,%esp
  801bdb:	6a 02                	push   $0x2
  801bdd:	e8 0b 09 00 00       	call   8024ed <ipc_find_env>
  801be2:	a3 04 40 80 00       	mov    %eax,0x804004
  801be7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bea:	6a 07                	push   $0x7
  801bec:	68 00 60 80 00       	push   $0x806000
  801bf1:	53                   	push   %ebx
  801bf2:	ff 35 04 40 80 00    	pushl  0x804004
  801bf8:	e8 64 08 00 00       	call   802461 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bfd:	83 c4 0c             	add    $0xc,%esp
  801c00:	6a 00                	push   $0x0
  801c02:	6a 00                	push   $0x0
  801c04:	6a 00                	push   $0x0
  801c06:	e8 e1 07 00 00       	call   8023ec <ipc_recv>
}
  801c0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0e:	c9                   	leave  
  801c0f:	c3                   	ret    

00801c10 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	56                   	push   %esi
  801c14:	53                   	push   %ebx
  801c15:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c18:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c20:	8b 06                	mov    (%esi),%eax
  801c22:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c27:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2c:	e8 95 ff ff ff       	call   801bc6 <nsipc>
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	85 c0                	test   %eax,%eax
  801c35:	78 20                	js     801c57 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c37:	83 ec 04             	sub    $0x4,%esp
  801c3a:	ff 35 10 60 80 00    	pushl  0x806010
  801c40:	68 00 60 80 00       	push   $0x806000
  801c45:	ff 75 0c             	pushl  0xc(%ebp)
  801c48:	e8 b3 ed ff ff       	call   800a00 <memmove>
		*addrlen = ret->ret_addrlen;
  801c4d:	a1 10 60 80 00       	mov    0x806010,%eax
  801c52:	89 06                	mov    %eax,(%esi)
  801c54:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c57:	89 d8                	mov    %ebx,%eax
  801c59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c5c:	5b                   	pop    %ebx
  801c5d:	5e                   	pop    %esi
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	53                   	push   %ebx
  801c64:	83 ec 08             	sub    $0x8,%esp
  801c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c72:	53                   	push   %ebx
  801c73:	ff 75 0c             	pushl  0xc(%ebp)
  801c76:	68 04 60 80 00       	push   $0x806004
  801c7b:	e8 80 ed ff ff       	call   800a00 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c80:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c86:	b8 02 00 00 00       	mov    $0x2,%eax
  801c8b:	e8 36 ff ff ff       	call   801bc6 <nsipc>
}
  801c90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cab:	b8 03 00 00 00       	mov    $0x3,%eax
  801cb0:	e8 11 ff ff ff       	call   801bc6 <nsipc>
}
  801cb5:	c9                   	leave  
  801cb6:	c3                   	ret    

00801cb7 <nsipc_close>:

int
nsipc_close(int s)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cc5:	b8 04 00 00 00       	mov    $0x4,%eax
  801cca:	e8 f7 fe ff ff       	call   801bc6 <nsipc>
}
  801ccf:	c9                   	leave  
  801cd0:	c3                   	ret    

00801cd1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	53                   	push   %ebx
  801cd5:	83 ec 08             	sub    $0x8,%esp
  801cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ce3:	53                   	push   %ebx
  801ce4:	ff 75 0c             	pushl  0xc(%ebp)
  801ce7:	68 04 60 80 00       	push   $0x806004
  801cec:	e8 0f ed ff ff       	call   800a00 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cf1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cf7:	b8 05 00 00 00       	mov    $0x5,%eax
  801cfc:	e8 c5 fe ff ff       	call   801bc6 <nsipc>
}
  801d01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d17:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d1c:	b8 06 00 00 00       	mov    $0x6,%eax
  801d21:	e8 a0 fe ff ff       	call   801bc6 <nsipc>
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	56                   	push   %esi
  801d2c:	53                   	push   %ebx
  801d2d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d30:	8b 45 08             	mov    0x8(%ebp),%eax
  801d33:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d38:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d3e:	8b 45 14             	mov    0x14(%ebp),%eax
  801d41:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d46:	b8 07 00 00 00       	mov    $0x7,%eax
  801d4b:	e8 76 fe ff ff       	call   801bc6 <nsipc>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	85 c0                	test   %eax,%eax
  801d54:	78 35                	js     801d8b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d56:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d5b:	7f 04                	jg     801d61 <nsipc_recv+0x39>
  801d5d:	39 c6                	cmp    %eax,%esi
  801d5f:	7d 16                	jge    801d77 <nsipc_recv+0x4f>
  801d61:	68 cb 2e 80 00       	push   $0x802ecb
  801d66:	68 93 2e 80 00       	push   $0x802e93
  801d6b:	6a 62                	push   $0x62
  801d6d:	68 e0 2e 80 00       	push   $0x802ee0
  801d72:	e8 99 e4 ff ff       	call   800210 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d77:	83 ec 04             	sub    $0x4,%esp
  801d7a:	50                   	push   %eax
  801d7b:	68 00 60 80 00       	push   $0x806000
  801d80:	ff 75 0c             	pushl  0xc(%ebp)
  801d83:	e8 78 ec ff ff       	call   800a00 <memmove>
  801d88:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d8b:	89 d8                	mov    %ebx,%eax
  801d8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    

00801d94 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	53                   	push   %ebx
  801d98:	83 ec 04             	sub    $0x4,%esp
  801d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801da1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801da6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dac:	7e 16                	jle    801dc4 <nsipc_send+0x30>
  801dae:	68 ec 2e 80 00       	push   $0x802eec
  801db3:	68 93 2e 80 00       	push   $0x802e93
  801db8:	6a 6d                	push   $0x6d
  801dba:	68 e0 2e 80 00       	push   $0x802ee0
  801dbf:	e8 4c e4 ff ff       	call   800210 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dc4:	83 ec 04             	sub    $0x4,%esp
  801dc7:	53                   	push   %ebx
  801dc8:	ff 75 0c             	pushl  0xc(%ebp)
  801dcb:	68 0c 60 80 00       	push   $0x80600c
  801dd0:	e8 2b ec ff ff       	call   800a00 <memmove>
	nsipcbuf.send.req_size = size;
  801dd5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ddb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dde:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801de3:	b8 08 00 00 00       	mov    $0x8,%eax
  801de8:	e8 d9 fd ff ff       	call   801bc6 <nsipc>
}
  801ded:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801df8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e03:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e08:	8b 45 10             	mov    0x10(%ebp),%eax
  801e0b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e10:	b8 09 00 00 00       	mov    $0x9,%eax
  801e15:	e8 ac fd ff ff       	call   801bc6 <nsipc>
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	56                   	push   %esi
  801e20:	53                   	push   %ebx
  801e21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e24:	83 ec 0c             	sub    $0xc,%esp
  801e27:	ff 75 08             	pushl  0x8(%ebp)
  801e2a:	e8 8b f3 ff ff       	call   8011ba <fd2data>
  801e2f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e31:	83 c4 08             	add    $0x8,%esp
  801e34:	68 f8 2e 80 00       	push   $0x802ef8
  801e39:	53                   	push   %ebx
  801e3a:	e8 2f ea ff ff       	call   80086e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e3f:	8b 46 04             	mov    0x4(%esi),%eax
  801e42:	2b 06                	sub    (%esi),%eax
  801e44:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e4a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e51:	00 00 00 
	stat->st_dev = &devpipe;
  801e54:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e5b:	30 80 00 
	return 0;
}
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    

00801e6a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	53                   	push   %ebx
  801e6e:	83 ec 0c             	sub    $0xc,%esp
  801e71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e74:	53                   	push   %ebx
  801e75:	6a 00                	push   $0x0
  801e77:	e8 7a ee ff ff       	call   800cf6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e7c:	89 1c 24             	mov    %ebx,(%esp)
  801e7f:	e8 36 f3 ff ff       	call   8011ba <fd2data>
  801e84:	83 c4 08             	add    $0x8,%esp
  801e87:	50                   	push   %eax
  801e88:	6a 00                	push   $0x0
  801e8a:	e8 67 ee ff ff       	call   800cf6 <sys_page_unmap>
}
  801e8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e92:	c9                   	leave  
  801e93:	c3                   	ret    

00801e94 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	57                   	push   %edi
  801e98:	56                   	push   %esi
  801e99:	53                   	push   %ebx
  801e9a:	83 ec 1c             	sub    $0x1c,%esp
  801e9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ea0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ea2:	a1 20 44 80 00       	mov    0x804420,%eax
  801ea7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	ff 75 e0             	pushl  -0x20(%ebp)
  801eb0:	e8 71 06 00 00       	call   802526 <pageref>
  801eb5:	89 c3                	mov    %eax,%ebx
  801eb7:	89 3c 24             	mov    %edi,(%esp)
  801eba:	e8 67 06 00 00       	call   802526 <pageref>
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	39 c3                	cmp    %eax,%ebx
  801ec4:	0f 94 c1             	sete   %cl
  801ec7:	0f b6 c9             	movzbl %cl,%ecx
  801eca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ecd:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ed3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ed6:	39 ce                	cmp    %ecx,%esi
  801ed8:	74 1b                	je     801ef5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801eda:	39 c3                	cmp    %eax,%ebx
  801edc:	75 c4                	jne    801ea2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ede:	8b 42 58             	mov    0x58(%edx),%eax
  801ee1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ee4:	50                   	push   %eax
  801ee5:	56                   	push   %esi
  801ee6:	68 ff 2e 80 00       	push   $0x802eff
  801eeb:	e8 f9 e3 ff ff       	call   8002e9 <cprintf>
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	eb ad                	jmp    801ea2 <_pipeisclosed+0xe>
	}
}
  801ef5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efb:	5b                   	pop    %ebx
  801efc:	5e                   	pop    %esi
  801efd:	5f                   	pop    %edi
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	57                   	push   %edi
  801f04:	56                   	push   %esi
  801f05:	53                   	push   %ebx
  801f06:	83 ec 28             	sub    $0x28,%esp
  801f09:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f0c:	56                   	push   %esi
  801f0d:	e8 a8 f2 ff ff       	call   8011ba <fd2data>
  801f12:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	bf 00 00 00 00       	mov    $0x0,%edi
  801f1c:	eb 4b                	jmp    801f69 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f1e:	89 da                	mov    %ebx,%edx
  801f20:	89 f0                	mov    %esi,%eax
  801f22:	e8 6d ff ff ff       	call   801e94 <_pipeisclosed>
  801f27:	85 c0                	test   %eax,%eax
  801f29:	75 48                	jne    801f73 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f2b:	e8 22 ed ff ff       	call   800c52 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f30:	8b 43 04             	mov    0x4(%ebx),%eax
  801f33:	8b 0b                	mov    (%ebx),%ecx
  801f35:	8d 51 20             	lea    0x20(%ecx),%edx
  801f38:	39 d0                	cmp    %edx,%eax
  801f3a:	73 e2                	jae    801f1e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f3f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f43:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f46:	89 c2                	mov    %eax,%edx
  801f48:	c1 fa 1f             	sar    $0x1f,%edx
  801f4b:	89 d1                	mov    %edx,%ecx
  801f4d:	c1 e9 1b             	shr    $0x1b,%ecx
  801f50:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f53:	83 e2 1f             	and    $0x1f,%edx
  801f56:	29 ca                	sub    %ecx,%edx
  801f58:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f5c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f60:	83 c0 01             	add    $0x1,%eax
  801f63:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f66:	83 c7 01             	add    $0x1,%edi
  801f69:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f6c:	75 c2                	jne    801f30 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801f71:	eb 05                	jmp    801f78 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5f                   	pop    %edi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	57                   	push   %edi
  801f84:	56                   	push   %esi
  801f85:	53                   	push   %ebx
  801f86:	83 ec 18             	sub    $0x18,%esp
  801f89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f8c:	57                   	push   %edi
  801f8d:	e8 28 f2 ff ff       	call   8011ba <fd2data>
  801f92:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f9c:	eb 3d                	jmp    801fdb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f9e:	85 db                	test   %ebx,%ebx
  801fa0:	74 04                	je     801fa6 <devpipe_read+0x26>
				return i;
  801fa2:	89 d8                	mov    %ebx,%eax
  801fa4:	eb 44                	jmp    801fea <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fa6:	89 f2                	mov    %esi,%edx
  801fa8:	89 f8                	mov    %edi,%eax
  801faa:	e8 e5 fe ff ff       	call   801e94 <_pipeisclosed>
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	75 32                	jne    801fe5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fb3:	e8 9a ec ff ff       	call   800c52 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fb8:	8b 06                	mov    (%esi),%eax
  801fba:	3b 46 04             	cmp    0x4(%esi),%eax
  801fbd:	74 df                	je     801f9e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fbf:	99                   	cltd   
  801fc0:	c1 ea 1b             	shr    $0x1b,%edx
  801fc3:	01 d0                	add    %edx,%eax
  801fc5:	83 e0 1f             	and    $0x1f,%eax
  801fc8:	29 d0                	sub    %edx,%eax
  801fca:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fd2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fd5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd8:	83 c3 01             	add    $0x1,%ebx
  801fdb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fde:	75 d8                	jne    801fb8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fe0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe3:	eb 05                	jmp    801fea <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fe5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    

00801ff2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	56                   	push   %esi
  801ff6:	53                   	push   %ebx
  801ff7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ffa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffd:	50                   	push   %eax
  801ffe:	e8 ce f1 ff ff       	call   8011d1 <fd_alloc>
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	89 c2                	mov    %eax,%edx
  802008:	85 c0                	test   %eax,%eax
  80200a:	0f 88 2c 01 00 00    	js     80213c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802010:	83 ec 04             	sub    $0x4,%esp
  802013:	68 07 04 00 00       	push   $0x407
  802018:	ff 75 f4             	pushl  -0xc(%ebp)
  80201b:	6a 00                	push   $0x0
  80201d:	e8 4f ec ff ff       	call   800c71 <sys_page_alloc>
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	89 c2                	mov    %eax,%edx
  802027:	85 c0                	test   %eax,%eax
  802029:	0f 88 0d 01 00 00    	js     80213c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80202f:	83 ec 0c             	sub    $0xc,%esp
  802032:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802035:	50                   	push   %eax
  802036:	e8 96 f1 ff ff       	call   8011d1 <fd_alloc>
  80203b:	89 c3                	mov    %eax,%ebx
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	0f 88 e2 00 00 00    	js     80212a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802048:	83 ec 04             	sub    $0x4,%esp
  80204b:	68 07 04 00 00       	push   $0x407
  802050:	ff 75 f0             	pushl  -0x10(%ebp)
  802053:	6a 00                	push   $0x0
  802055:	e8 17 ec ff ff       	call   800c71 <sys_page_alloc>
  80205a:	89 c3                	mov    %eax,%ebx
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	0f 88 c3 00 00 00    	js     80212a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802067:	83 ec 0c             	sub    $0xc,%esp
  80206a:	ff 75 f4             	pushl  -0xc(%ebp)
  80206d:	e8 48 f1 ff ff       	call   8011ba <fd2data>
  802072:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802074:	83 c4 0c             	add    $0xc,%esp
  802077:	68 07 04 00 00       	push   $0x407
  80207c:	50                   	push   %eax
  80207d:	6a 00                	push   $0x0
  80207f:	e8 ed eb ff ff       	call   800c71 <sys_page_alloc>
  802084:	89 c3                	mov    %eax,%ebx
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	85 c0                	test   %eax,%eax
  80208b:	0f 88 89 00 00 00    	js     80211a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802091:	83 ec 0c             	sub    $0xc,%esp
  802094:	ff 75 f0             	pushl  -0x10(%ebp)
  802097:	e8 1e f1 ff ff       	call   8011ba <fd2data>
  80209c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020a3:	50                   	push   %eax
  8020a4:	6a 00                	push   $0x0
  8020a6:	56                   	push   %esi
  8020a7:	6a 00                	push   $0x0
  8020a9:	e8 06 ec ff ff       	call   800cb4 <sys_page_map>
  8020ae:	89 c3                	mov    %eax,%ebx
  8020b0:	83 c4 20             	add    $0x20,%esp
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	78 55                	js     80210c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020b7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020cc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020da:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020e1:	83 ec 0c             	sub    $0xc,%esp
  8020e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e7:	e8 be f0 ff ff       	call   8011aa <fd2num>
  8020ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ef:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020f1:	83 c4 04             	add    $0x4,%esp
  8020f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f7:	e8 ae f0 ff ff       	call   8011aa <fd2num>
  8020fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ff:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	ba 00 00 00 00       	mov    $0x0,%edx
  80210a:	eb 30                	jmp    80213c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80210c:	83 ec 08             	sub    $0x8,%esp
  80210f:	56                   	push   %esi
  802110:	6a 00                	push   $0x0
  802112:	e8 df eb ff ff       	call   800cf6 <sys_page_unmap>
  802117:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80211a:	83 ec 08             	sub    $0x8,%esp
  80211d:	ff 75 f0             	pushl  -0x10(%ebp)
  802120:	6a 00                	push   $0x0
  802122:	e8 cf eb ff ff       	call   800cf6 <sys_page_unmap>
  802127:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80212a:	83 ec 08             	sub    $0x8,%esp
  80212d:	ff 75 f4             	pushl  -0xc(%ebp)
  802130:	6a 00                	push   $0x0
  802132:	e8 bf eb ff ff       	call   800cf6 <sys_page_unmap>
  802137:	83 c4 10             	add    $0x10,%esp
  80213a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80213c:	89 d0                	mov    %edx,%eax
  80213e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802141:	5b                   	pop    %ebx
  802142:	5e                   	pop    %esi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80214e:	50                   	push   %eax
  80214f:	ff 75 08             	pushl  0x8(%ebp)
  802152:	e8 c9 f0 ff ff       	call   801220 <fd_lookup>
  802157:	83 c4 10             	add    $0x10,%esp
  80215a:	85 c0                	test   %eax,%eax
  80215c:	78 18                	js     802176 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80215e:	83 ec 0c             	sub    $0xc,%esp
  802161:	ff 75 f4             	pushl  -0xc(%ebp)
  802164:	e8 51 f0 ff ff       	call   8011ba <fd2data>
	return _pipeisclosed(fd, p);
  802169:	89 c2                	mov    %eax,%edx
  80216b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216e:	e8 21 fd ff ff       	call   801e94 <_pipeisclosed>
  802173:	83 c4 10             	add    $0x10,%esp
}
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	56                   	push   %esi
  80217c:	53                   	push   %ebx
  80217d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802180:	85 f6                	test   %esi,%esi
  802182:	75 16                	jne    80219a <wait+0x22>
  802184:	68 17 2f 80 00       	push   $0x802f17
  802189:	68 93 2e 80 00       	push   $0x802e93
  80218e:	6a 09                	push   $0x9
  802190:	68 22 2f 80 00       	push   $0x802f22
  802195:	e8 76 e0 ff ff       	call   800210 <_panic>
	e = &envs[ENVX(envid)];
  80219a:	89 f3                	mov    %esi,%ebx
  80219c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021a2:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8021a5:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8021ab:	eb 05                	jmp    8021b2 <wait+0x3a>
		sys_yield();
  8021ad:	e8 a0 ea ff ff       	call   800c52 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021b2:	8b 43 48             	mov    0x48(%ebx),%eax
  8021b5:	39 c6                	cmp    %eax,%esi
  8021b7:	75 07                	jne    8021c0 <wait+0x48>
  8021b9:	8b 43 54             	mov    0x54(%ebx),%eax
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	75 ed                	jne    8021ad <wait+0x35>
		sys_yield();
}
  8021c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    

008021c7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8021cf:	5d                   	pop    %ebp
  8021d0:	c3                   	ret    

008021d1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d1:	55                   	push   %ebp
  8021d2:	89 e5                	mov    %esp,%ebp
  8021d4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021d7:	68 2d 2f 80 00       	push   $0x802f2d
  8021dc:	ff 75 0c             	pushl  0xc(%ebp)
  8021df:	e8 8a e6 ff ff       	call   80086e <strcpy>
	return 0;
}
  8021e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    

008021eb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	57                   	push   %edi
  8021ef:	56                   	push   %esi
  8021f0:	53                   	push   %ebx
  8021f1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021f7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021fc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802202:	eb 2d                	jmp    802231 <devcons_write+0x46>
		m = n - tot;
  802204:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802207:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802209:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80220c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802211:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802214:	83 ec 04             	sub    $0x4,%esp
  802217:	53                   	push   %ebx
  802218:	03 45 0c             	add    0xc(%ebp),%eax
  80221b:	50                   	push   %eax
  80221c:	57                   	push   %edi
  80221d:	e8 de e7 ff ff       	call   800a00 <memmove>
		sys_cputs(buf, m);
  802222:	83 c4 08             	add    $0x8,%esp
  802225:	53                   	push   %ebx
  802226:	57                   	push   %edi
  802227:	e8 89 e9 ff ff       	call   800bb5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80222c:	01 de                	add    %ebx,%esi
  80222e:	83 c4 10             	add    $0x10,%esp
  802231:	89 f0                	mov    %esi,%eax
  802233:	3b 75 10             	cmp    0x10(%ebp),%esi
  802236:	72 cc                	jb     802204 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80223b:	5b                   	pop    %ebx
  80223c:	5e                   	pop    %esi
  80223d:	5f                   	pop    %edi
  80223e:	5d                   	pop    %ebp
  80223f:	c3                   	ret    

00802240 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	83 ec 08             	sub    $0x8,%esp
  802246:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80224b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80224f:	74 2a                	je     80227b <devcons_read+0x3b>
  802251:	eb 05                	jmp    802258 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802253:	e8 fa e9 ff ff       	call   800c52 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802258:	e8 76 e9 ff ff       	call   800bd3 <sys_cgetc>
  80225d:	85 c0                	test   %eax,%eax
  80225f:	74 f2                	je     802253 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802261:	85 c0                	test   %eax,%eax
  802263:	78 16                	js     80227b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802265:	83 f8 04             	cmp    $0x4,%eax
  802268:	74 0c                	je     802276 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80226a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80226d:	88 02                	mov    %al,(%edx)
	return 1;
  80226f:	b8 01 00 00 00       	mov    $0x1,%eax
  802274:	eb 05                	jmp    80227b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802276:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80227b:	c9                   	leave  
  80227c:	c3                   	ret    

0080227d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80227d:	55                   	push   %ebp
  80227e:	89 e5                	mov    %esp,%ebp
  802280:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802283:	8b 45 08             	mov    0x8(%ebp),%eax
  802286:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802289:	6a 01                	push   $0x1
  80228b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80228e:	50                   	push   %eax
  80228f:	e8 21 e9 ff ff       	call   800bb5 <sys_cputs>
}
  802294:	83 c4 10             	add    $0x10,%esp
  802297:	c9                   	leave  
  802298:	c3                   	ret    

00802299 <getchar>:

int
getchar(void)
{
  802299:	55                   	push   %ebp
  80229a:	89 e5                	mov    %esp,%ebp
  80229c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80229f:	6a 01                	push   $0x1
  8022a1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022a4:	50                   	push   %eax
  8022a5:	6a 00                	push   $0x0
  8022a7:	e8 da f1 ff ff       	call   801486 <read>
	if (r < 0)
  8022ac:	83 c4 10             	add    $0x10,%esp
  8022af:	85 c0                	test   %eax,%eax
  8022b1:	78 0f                	js     8022c2 <getchar+0x29>
		return r;
	if (r < 1)
  8022b3:	85 c0                	test   %eax,%eax
  8022b5:	7e 06                	jle    8022bd <getchar+0x24>
		return -E_EOF;
	return c;
  8022b7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022bb:	eb 05                	jmp    8022c2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022bd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022c2:	c9                   	leave  
  8022c3:	c3                   	ret    

008022c4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022cd:	50                   	push   %eax
  8022ce:	ff 75 08             	pushl  0x8(%ebp)
  8022d1:	e8 4a ef ff ff       	call   801220 <fd_lookup>
  8022d6:	83 c4 10             	add    $0x10,%esp
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	78 11                	js     8022ee <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022e6:	39 10                	cmp    %edx,(%eax)
  8022e8:	0f 94 c0             	sete   %al
  8022eb:	0f b6 c0             	movzbl %al,%eax
}
  8022ee:	c9                   	leave  
  8022ef:	c3                   	ret    

008022f0 <opencons>:

int
opencons(void)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f9:	50                   	push   %eax
  8022fa:	e8 d2 ee ff ff       	call   8011d1 <fd_alloc>
  8022ff:	83 c4 10             	add    $0x10,%esp
		return r;
  802302:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802304:	85 c0                	test   %eax,%eax
  802306:	78 3e                	js     802346 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802308:	83 ec 04             	sub    $0x4,%esp
  80230b:	68 07 04 00 00       	push   $0x407
  802310:	ff 75 f4             	pushl  -0xc(%ebp)
  802313:	6a 00                	push   $0x0
  802315:	e8 57 e9 ff ff       	call   800c71 <sys_page_alloc>
  80231a:	83 c4 10             	add    $0x10,%esp
		return r;
  80231d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80231f:	85 c0                	test   %eax,%eax
  802321:	78 23                	js     802346 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802323:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80232e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802331:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802338:	83 ec 0c             	sub    $0xc,%esp
  80233b:	50                   	push   %eax
  80233c:	e8 69 ee ff ff       	call   8011aa <fd2num>
  802341:	89 c2                	mov    %eax,%edx
  802343:	83 c4 10             	add    $0x10,%esp
}
  802346:	89 d0                	mov    %edx,%eax
  802348:	c9                   	leave  
  802349:	c3                   	ret    

0080234a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802350:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802357:	75 64                	jne    8023bd <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  802359:	a1 20 44 80 00       	mov    0x804420,%eax
  80235e:	8b 40 48             	mov    0x48(%eax),%eax
  802361:	83 ec 04             	sub    $0x4,%esp
  802364:	6a 07                	push   $0x7
  802366:	68 00 f0 bf ee       	push   $0xeebff000
  80236b:	50                   	push   %eax
  80236c:	e8 00 e9 ff ff       	call   800c71 <sys_page_alloc>
		if ( r != 0)
  802371:	83 c4 10             	add    $0x10,%esp
  802374:	85 c0                	test   %eax,%eax
  802376:	74 14                	je     80238c <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  802378:	83 ec 04             	sub    $0x4,%esp
  80237b:	68 3c 2f 80 00       	push   $0x802f3c
  802380:	6a 24                	push   $0x24
  802382:	68 8a 2f 80 00       	push   $0x802f8a
  802387:	e8 84 de ff ff       	call   800210 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  80238c:	a1 20 44 80 00       	mov    0x804420,%eax
  802391:	8b 40 48             	mov    0x48(%eax),%eax
  802394:	83 ec 08             	sub    $0x8,%esp
  802397:	68 c7 23 80 00       	push   $0x8023c7
  80239c:	50                   	push   %eax
  80239d:	e8 1a ea ff ff       	call   800dbc <sys_env_set_pgfault_upcall>
  8023a2:	83 c4 10             	add    $0x10,%esp
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	79 14                	jns    8023bd <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  8023a9:	83 ec 04             	sub    $0x4,%esp
  8023ac:	68 68 2f 80 00       	push   $0x802f68
  8023b1:	6a 27                	push   $0x27
  8023b3:	68 8a 2f 80 00       	push   $0x802f8a
  8023b8:	e8 53 de ff ff       	call   800210 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c0:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023c5:	c9                   	leave  
  8023c6:	c3                   	ret    

008023c7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023c7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023c8:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023cd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023cf:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  8023d2:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  8023d6:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  8023d8:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  8023dc:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  8023dd:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  8023e0:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  8023e2:	83 c4 08             	add    $0x8,%esp
popal
  8023e5:	61                   	popa   
addl $0x4, %esp
  8023e6:	83 c4 04             	add    $0x4,%esp
popfl
  8023e9:	9d                   	popf   
popl %esp
  8023ea:	5c                   	pop    %esp
ret
  8023eb:	c3                   	ret    

008023ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	56                   	push   %esi
  8023f0:	53                   	push   %ebx
  8023f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8023f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f7:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  8023fa:	85 c0                	test   %eax,%eax
  8023fc:	74 0e                	je     80240c <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  8023fe:	83 ec 0c             	sub    $0xc,%esp
  802401:	50                   	push   %eax
  802402:	e8 1a ea ff ff       	call   800e21 <sys_ipc_recv>
  802407:	83 c4 10             	add    $0x10,%esp
  80240a:	eb 10                	jmp    80241c <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  80240c:	83 ec 0c             	sub    $0xc,%esp
  80240f:	68 00 00 00 f0       	push   $0xf0000000
  802414:	e8 08 ea ff ff       	call   800e21 <sys_ipc_recv>
  802419:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  80241c:	85 c0                	test   %eax,%eax
  80241e:	74 16                	je     802436 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  802420:	85 db                	test   %ebx,%ebx
  802422:	74 36                	je     80245a <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  802424:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  80242a:	85 f6                	test   %esi,%esi
  80242c:	74 2c                	je     80245a <ipc_recv+0x6e>
				*perm_store = 0;
  80242e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802434:	eb 24                	jmp    80245a <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  802436:	85 db                	test   %ebx,%ebx
  802438:	74 18                	je     802452 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  80243a:	a1 20 44 80 00       	mov    0x804420,%eax
  80243f:	8b 40 74             	mov    0x74(%eax),%eax
  802442:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  802444:	85 f6                	test   %esi,%esi
  802446:	74 0a                	je     802452 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  802448:	a1 20 44 80 00       	mov    0x804420,%eax
  80244d:	8b 40 78             	mov    0x78(%eax),%eax
  802450:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  802452:	a1 20 44 80 00       	mov    0x804420,%eax
  802457:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  80245a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5d                   	pop    %ebp
  802460:	c3                   	ret    

00802461 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802461:	55                   	push   %ebp
  802462:	89 e5                	mov    %esp,%ebp
  802464:	57                   	push   %edi
  802465:	56                   	push   %esi
  802466:	53                   	push   %ebx
  802467:	83 ec 0c             	sub    $0xc,%esp
  80246a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80246d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  802470:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802474:	75 39                	jne    8024af <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  802476:	6a 00                	push   $0x0
  802478:	68 00 00 00 f0       	push   $0xf0000000
  80247d:	56                   	push   %esi
  80247e:	57                   	push   %edi
  80247f:	e8 7a e9 ff ff       	call   800dfe <sys_ipc_try_send>
  802484:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  802486:	83 c4 10             	add    $0x10,%esp
  802489:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80248c:	74 16                	je     8024a4 <ipc_send+0x43>
  80248e:	85 c0                	test   %eax,%eax
  802490:	74 12                	je     8024a4 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802492:	50                   	push   %eax
  802493:	68 98 2f 80 00       	push   $0x802f98
  802498:	6a 4f                	push   $0x4f
  80249a:	68 d0 2f 80 00       	push   $0x802fd0
  80249f:	e8 6c dd ff ff       	call   800210 <_panic>
			sys_yield();
  8024a4:	e8 a9 e7 ff ff       	call   800c52 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  8024a9:	85 db                	test   %ebx,%ebx
  8024ab:	75 c9                	jne    802476 <ipc_send+0x15>
  8024ad:	eb 36                	jmp    8024e5 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  8024af:	ff 75 14             	pushl  0x14(%ebp)
  8024b2:	ff 75 10             	pushl  0x10(%ebp)
  8024b5:	56                   	push   %esi
  8024b6:	57                   	push   %edi
  8024b7:	e8 42 e9 ff ff       	call   800dfe <sys_ipc_try_send>
  8024bc:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  8024be:	83 c4 10             	add    $0x10,%esp
  8024c1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024c4:	74 16                	je     8024dc <ipc_send+0x7b>
  8024c6:	85 c0                	test   %eax,%eax
  8024c8:	74 12                	je     8024dc <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  8024ca:	50                   	push   %eax
  8024cb:	68 98 2f 80 00       	push   $0x802f98
  8024d0:	6a 5a                	push   $0x5a
  8024d2:	68 d0 2f 80 00       	push   $0x802fd0
  8024d7:	e8 34 dd ff ff       	call   800210 <_panic>
			sys_yield();
  8024dc:	e8 71 e7 ff ff       	call   800c52 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  8024e1:	85 db                	test   %ebx,%ebx
  8024e3:	75 ca                	jne    8024af <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  8024e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e8:	5b                   	pop    %ebx
  8024e9:	5e                   	pop    %esi
  8024ea:	5f                   	pop    %edi
  8024eb:	5d                   	pop    %ebp
  8024ec:	c3                   	ret    

008024ed <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024ed:	55                   	push   %ebp
  8024ee:	89 e5                	mov    %esp,%ebp
  8024f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024f3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024f8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024fb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802501:	8b 52 50             	mov    0x50(%edx),%edx
  802504:	39 ca                	cmp    %ecx,%edx
  802506:	75 0d                	jne    802515 <ipc_find_env+0x28>
			return envs[i].env_id;
  802508:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80250b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802510:	8b 40 48             	mov    0x48(%eax),%eax
  802513:	eb 0f                	jmp    802524 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802515:	83 c0 01             	add    $0x1,%eax
  802518:	3d 00 04 00 00       	cmp    $0x400,%eax
  80251d:	75 d9                	jne    8024f8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80251f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802524:	5d                   	pop    %ebp
  802525:	c3                   	ret    

00802526 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802526:	55                   	push   %ebp
  802527:	89 e5                	mov    %esp,%ebp
  802529:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80252c:	89 d0                	mov    %edx,%eax
  80252e:	c1 e8 16             	shr    $0x16,%eax
  802531:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802538:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80253d:	f6 c1 01             	test   $0x1,%cl
  802540:	74 1d                	je     80255f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802542:	c1 ea 0c             	shr    $0xc,%edx
  802545:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80254c:	f6 c2 01             	test   $0x1,%dl
  80254f:	74 0e                	je     80255f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802551:	c1 ea 0c             	shr    $0xc,%edx
  802554:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80255b:	ef 
  80255c:	0f b7 c0             	movzwl %ax,%eax
}
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    
  802561:	66 90                	xchg   %ax,%ax
  802563:	66 90                	xchg   %ax,%ax
  802565:	66 90                	xchg   %ax,%ax
  802567:	66 90                	xchg   %ax,%ax
  802569:	66 90                	xchg   %ax,%ax
  80256b:	66 90                	xchg   %ax,%ax
  80256d:	66 90                	xchg   %ax,%ax
  80256f:	90                   	nop

00802570 <__udivdi3>:
  802570:	55                   	push   %ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 1c             	sub    $0x1c,%esp
  802577:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80257b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80257f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802583:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802587:	85 f6                	test   %esi,%esi
  802589:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80258d:	89 ca                	mov    %ecx,%edx
  80258f:	89 f8                	mov    %edi,%eax
  802591:	75 3d                	jne    8025d0 <__udivdi3+0x60>
  802593:	39 cf                	cmp    %ecx,%edi
  802595:	0f 87 c5 00 00 00    	ja     802660 <__udivdi3+0xf0>
  80259b:	85 ff                	test   %edi,%edi
  80259d:	89 fd                	mov    %edi,%ebp
  80259f:	75 0b                	jne    8025ac <__udivdi3+0x3c>
  8025a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025a6:	31 d2                	xor    %edx,%edx
  8025a8:	f7 f7                	div    %edi
  8025aa:	89 c5                	mov    %eax,%ebp
  8025ac:	89 c8                	mov    %ecx,%eax
  8025ae:	31 d2                	xor    %edx,%edx
  8025b0:	f7 f5                	div    %ebp
  8025b2:	89 c1                	mov    %eax,%ecx
  8025b4:	89 d8                	mov    %ebx,%eax
  8025b6:	89 cf                	mov    %ecx,%edi
  8025b8:	f7 f5                	div    %ebp
  8025ba:	89 c3                	mov    %eax,%ebx
  8025bc:	89 d8                	mov    %ebx,%eax
  8025be:	89 fa                	mov    %edi,%edx
  8025c0:	83 c4 1c             	add    $0x1c,%esp
  8025c3:	5b                   	pop    %ebx
  8025c4:	5e                   	pop    %esi
  8025c5:	5f                   	pop    %edi
  8025c6:	5d                   	pop    %ebp
  8025c7:	c3                   	ret    
  8025c8:	90                   	nop
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	39 ce                	cmp    %ecx,%esi
  8025d2:	77 74                	ja     802648 <__udivdi3+0xd8>
  8025d4:	0f bd fe             	bsr    %esi,%edi
  8025d7:	83 f7 1f             	xor    $0x1f,%edi
  8025da:	0f 84 98 00 00 00    	je     802678 <__udivdi3+0x108>
  8025e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	89 c5                	mov    %eax,%ebp
  8025e9:	29 fb                	sub    %edi,%ebx
  8025eb:	d3 e6                	shl    %cl,%esi
  8025ed:	89 d9                	mov    %ebx,%ecx
  8025ef:	d3 ed                	shr    %cl,%ebp
  8025f1:	89 f9                	mov    %edi,%ecx
  8025f3:	d3 e0                	shl    %cl,%eax
  8025f5:	09 ee                	or     %ebp,%esi
  8025f7:	89 d9                	mov    %ebx,%ecx
  8025f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025fd:	89 d5                	mov    %edx,%ebp
  8025ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802603:	d3 ed                	shr    %cl,%ebp
  802605:	89 f9                	mov    %edi,%ecx
  802607:	d3 e2                	shl    %cl,%edx
  802609:	89 d9                	mov    %ebx,%ecx
  80260b:	d3 e8                	shr    %cl,%eax
  80260d:	09 c2                	or     %eax,%edx
  80260f:	89 d0                	mov    %edx,%eax
  802611:	89 ea                	mov    %ebp,%edx
  802613:	f7 f6                	div    %esi
  802615:	89 d5                	mov    %edx,%ebp
  802617:	89 c3                	mov    %eax,%ebx
  802619:	f7 64 24 0c          	mull   0xc(%esp)
  80261d:	39 d5                	cmp    %edx,%ebp
  80261f:	72 10                	jb     802631 <__udivdi3+0xc1>
  802621:	8b 74 24 08          	mov    0x8(%esp),%esi
  802625:	89 f9                	mov    %edi,%ecx
  802627:	d3 e6                	shl    %cl,%esi
  802629:	39 c6                	cmp    %eax,%esi
  80262b:	73 07                	jae    802634 <__udivdi3+0xc4>
  80262d:	39 d5                	cmp    %edx,%ebp
  80262f:	75 03                	jne    802634 <__udivdi3+0xc4>
  802631:	83 eb 01             	sub    $0x1,%ebx
  802634:	31 ff                	xor    %edi,%edi
  802636:	89 d8                	mov    %ebx,%eax
  802638:	89 fa                	mov    %edi,%edx
  80263a:	83 c4 1c             	add    $0x1c,%esp
  80263d:	5b                   	pop    %ebx
  80263e:	5e                   	pop    %esi
  80263f:	5f                   	pop    %edi
  802640:	5d                   	pop    %ebp
  802641:	c3                   	ret    
  802642:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802648:	31 ff                	xor    %edi,%edi
  80264a:	31 db                	xor    %ebx,%ebx
  80264c:	89 d8                	mov    %ebx,%eax
  80264e:	89 fa                	mov    %edi,%edx
  802650:	83 c4 1c             	add    $0x1c,%esp
  802653:	5b                   	pop    %ebx
  802654:	5e                   	pop    %esi
  802655:	5f                   	pop    %edi
  802656:	5d                   	pop    %ebp
  802657:	c3                   	ret    
  802658:	90                   	nop
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	89 d8                	mov    %ebx,%eax
  802662:	f7 f7                	div    %edi
  802664:	31 ff                	xor    %edi,%edi
  802666:	89 c3                	mov    %eax,%ebx
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	89 fa                	mov    %edi,%edx
  80266c:	83 c4 1c             	add    $0x1c,%esp
  80266f:	5b                   	pop    %ebx
  802670:	5e                   	pop    %esi
  802671:	5f                   	pop    %edi
  802672:	5d                   	pop    %ebp
  802673:	c3                   	ret    
  802674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802678:	39 ce                	cmp    %ecx,%esi
  80267a:	72 0c                	jb     802688 <__udivdi3+0x118>
  80267c:	31 db                	xor    %ebx,%ebx
  80267e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802682:	0f 87 34 ff ff ff    	ja     8025bc <__udivdi3+0x4c>
  802688:	bb 01 00 00 00       	mov    $0x1,%ebx
  80268d:	e9 2a ff ff ff       	jmp    8025bc <__udivdi3+0x4c>
  802692:	66 90                	xchg   %ax,%ax
  802694:	66 90                	xchg   %ax,%ax
  802696:	66 90                	xchg   %ax,%ax
  802698:	66 90                	xchg   %ax,%ax
  80269a:	66 90                	xchg   %ax,%ax
  80269c:	66 90                	xchg   %ax,%ax
  80269e:	66 90                	xchg   %ax,%ax

008026a0 <__umoddi3>:
  8026a0:	55                   	push   %ebp
  8026a1:	57                   	push   %edi
  8026a2:	56                   	push   %esi
  8026a3:	53                   	push   %ebx
  8026a4:	83 ec 1c             	sub    $0x1c,%esp
  8026a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026b7:	85 d2                	test   %edx,%edx
  8026b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026c1:	89 f3                	mov    %esi,%ebx
  8026c3:	89 3c 24             	mov    %edi,(%esp)
  8026c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ca:	75 1c                	jne    8026e8 <__umoddi3+0x48>
  8026cc:	39 f7                	cmp    %esi,%edi
  8026ce:	76 50                	jbe    802720 <__umoddi3+0x80>
  8026d0:	89 c8                	mov    %ecx,%eax
  8026d2:	89 f2                	mov    %esi,%edx
  8026d4:	f7 f7                	div    %edi
  8026d6:	89 d0                	mov    %edx,%eax
  8026d8:	31 d2                	xor    %edx,%edx
  8026da:	83 c4 1c             	add    $0x1c,%esp
  8026dd:	5b                   	pop    %ebx
  8026de:	5e                   	pop    %esi
  8026df:	5f                   	pop    %edi
  8026e0:	5d                   	pop    %ebp
  8026e1:	c3                   	ret    
  8026e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026e8:	39 f2                	cmp    %esi,%edx
  8026ea:	89 d0                	mov    %edx,%eax
  8026ec:	77 52                	ja     802740 <__umoddi3+0xa0>
  8026ee:	0f bd ea             	bsr    %edx,%ebp
  8026f1:	83 f5 1f             	xor    $0x1f,%ebp
  8026f4:	75 5a                	jne    802750 <__umoddi3+0xb0>
  8026f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026fa:	0f 82 e0 00 00 00    	jb     8027e0 <__umoddi3+0x140>
  802700:	39 0c 24             	cmp    %ecx,(%esp)
  802703:	0f 86 d7 00 00 00    	jbe    8027e0 <__umoddi3+0x140>
  802709:	8b 44 24 08          	mov    0x8(%esp),%eax
  80270d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802711:	83 c4 1c             	add    $0x1c,%esp
  802714:	5b                   	pop    %ebx
  802715:	5e                   	pop    %esi
  802716:	5f                   	pop    %edi
  802717:	5d                   	pop    %ebp
  802718:	c3                   	ret    
  802719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802720:	85 ff                	test   %edi,%edi
  802722:	89 fd                	mov    %edi,%ebp
  802724:	75 0b                	jne    802731 <__umoddi3+0x91>
  802726:	b8 01 00 00 00       	mov    $0x1,%eax
  80272b:	31 d2                	xor    %edx,%edx
  80272d:	f7 f7                	div    %edi
  80272f:	89 c5                	mov    %eax,%ebp
  802731:	89 f0                	mov    %esi,%eax
  802733:	31 d2                	xor    %edx,%edx
  802735:	f7 f5                	div    %ebp
  802737:	89 c8                	mov    %ecx,%eax
  802739:	f7 f5                	div    %ebp
  80273b:	89 d0                	mov    %edx,%eax
  80273d:	eb 99                	jmp    8026d8 <__umoddi3+0x38>
  80273f:	90                   	nop
  802740:	89 c8                	mov    %ecx,%eax
  802742:	89 f2                	mov    %esi,%edx
  802744:	83 c4 1c             	add    $0x1c,%esp
  802747:	5b                   	pop    %ebx
  802748:	5e                   	pop    %esi
  802749:	5f                   	pop    %edi
  80274a:	5d                   	pop    %ebp
  80274b:	c3                   	ret    
  80274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802750:	8b 34 24             	mov    (%esp),%esi
  802753:	bf 20 00 00 00       	mov    $0x20,%edi
  802758:	89 e9                	mov    %ebp,%ecx
  80275a:	29 ef                	sub    %ebp,%edi
  80275c:	d3 e0                	shl    %cl,%eax
  80275e:	89 f9                	mov    %edi,%ecx
  802760:	89 f2                	mov    %esi,%edx
  802762:	d3 ea                	shr    %cl,%edx
  802764:	89 e9                	mov    %ebp,%ecx
  802766:	09 c2                	or     %eax,%edx
  802768:	89 d8                	mov    %ebx,%eax
  80276a:	89 14 24             	mov    %edx,(%esp)
  80276d:	89 f2                	mov    %esi,%edx
  80276f:	d3 e2                	shl    %cl,%edx
  802771:	89 f9                	mov    %edi,%ecx
  802773:	89 54 24 04          	mov    %edx,0x4(%esp)
  802777:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80277b:	d3 e8                	shr    %cl,%eax
  80277d:	89 e9                	mov    %ebp,%ecx
  80277f:	89 c6                	mov    %eax,%esi
  802781:	d3 e3                	shl    %cl,%ebx
  802783:	89 f9                	mov    %edi,%ecx
  802785:	89 d0                	mov    %edx,%eax
  802787:	d3 e8                	shr    %cl,%eax
  802789:	89 e9                	mov    %ebp,%ecx
  80278b:	09 d8                	or     %ebx,%eax
  80278d:	89 d3                	mov    %edx,%ebx
  80278f:	89 f2                	mov    %esi,%edx
  802791:	f7 34 24             	divl   (%esp)
  802794:	89 d6                	mov    %edx,%esi
  802796:	d3 e3                	shl    %cl,%ebx
  802798:	f7 64 24 04          	mull   0x4(%esp)
  80279c:	39 d6                	cmp    %edx,%esi
  80279e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027a2:	89 d1                	mov    %edx,%ecx
  8027a4:	89 c3                	mov    %eax,%ebx
  8027a6:	72 08                	jb     8027b0 <__umoddi3+0x110>
  8027a8:	75 11                	jne    8027bb <__umoddi3+0x11b>
  8027aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ae:	73 0b                	jae    8027bb <__umoddi3+0x11b>
  8027b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027b4:	1b 14 24             	sbb    (%esp),%edx
  8027b7:	89 d1                	mov    %edx,%ecx
  8027b9:	89 c3                	mov    %eax,%ebx
  8027bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027bf:	29 da                	sub    %ebx,%edx
  8027c1:	19 ce                	sbb    %ecx,%esi
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 f0                	mov    %esi,%eax
  8027c7:	d3 e0                	shl    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	d3 ea                	shr    %cl,%edx
  8027cd:	89 e9                	mov    %ebp,%ecx
  8027cf:	d3 ee                	shr    %cl,%esi
  8027d1:	09 d0                	or     %edx,%eax
  8027d3:	89 f2                	mov    %esi,%edx
  8027d5:	83 c4 1c             	add    $0x1c,%esp
  8027d8:	5b                   	pop    %ebx
  8027d9:	5e                   	pop    %esi
  8027da:	5f                   	pop    %edi
  8027db:	5d                   	pop    %ebp
  8027dc:	c3                   	ret    
  8027dd:	8d 76 00             	lea    0x0(%esi),%esi
  8027e0:	29 f9                	sub    %edi,%ecx
  8027e2:	19 d6                	sbb    %edx,%esi
  8027e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ec:	e9 18 ff ff ff       	jmp    802709 <__umoddi3+0x69>
