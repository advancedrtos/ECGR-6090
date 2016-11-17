
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 e5 07 00 00       	call   80082e <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 b8 0b 00 00       	call   800c31 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 ec 27 80 00       	push   $0x8027ec
  800086:	6a 13                	push   $0x13
  800088:	68 ff 27 80 00       	push   $0x8027ff
  80008d:	e8 3e 01 00 00       	call   8001d0 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 7b 0e 00 00       	call   800f12 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 e1 2c 80 00       	push   $0x802ce1
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 ff 27 80 00       	push   $0x8027ff
  8000aa:	e8 21 01 00 00       	call   8001d0 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 68 07 00 00       	call   80082e <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 55 15 00 00       	call   80162c <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 ee 07 00 00       	call   8008d8 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba e6 27 80 00       	mov    $0x8027e6,%edx
  8000f4:	b8 e0 27 80 00       	mov    $0x8027e0,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 13 28 80 00       	push   $0x802813
  800102:	e8 a2 01 00 00       	call   8002a9 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 2e 28 80 00       	push   $0x80282e
  80010e:	68 33 28 80 00       	push   $0x802833
  800113:	68 32 28 80 00       	push   $0x802832
  800118:	e8 9c 14 00 00       	call   8015b9 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 40 28 80 00       	push   $0x802840
  80012a:	6a 21                	push   $0x21
  80012c:	68 ff 27 80 00       	push   $0x8027ff
  800131:	e8 9a 00 00 00       	call   8001d0 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 ed 14 00 00       	call   80162c <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 86 07 00 00       	call   8008d8 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba e6 27 80 00       	mov    $0x8027e6,%edx
  80015c:	b8 e0 27 80 00       	mov    $0x8027e0,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 4a 28 80 00       	push   $0x80284a
  80016a:	e8 3a 01 00 00       	call   8002a9 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  800183:	e8 6b 0a 00 00       	call   800bf3 <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8001c4:	6a 00                	push   $0x0
  8001c6:	e8 e7 09 00 00       	call   800bb2 <sys_env_destroy>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001d5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d8:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001de:	e8 10 0a 00 00       	call   800bf3 <sys_getenvid>
  8001e3:	83 ec 0c             	sub    $0xc,%esp
  8001e6:	ff 75 0c             	pushl  0xc(%ebp)
  8001e9:	ff 75 08             	pushl  0x8(%ebp)
  8001ec:	56                   	push   %esi
  8001ed:	50                   	push   %eax
  8001ee:	68 90 28 80 00       	push   $0x802890
  8001f3:	e8 b1 00 00 00       	call   8002a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f8:	83 c4 18             	add    $0x18,%esp
  8001fb:	53                   	push   %ebx
  8001fc:	ff 75 10             	pushl  0x10(%ebp)
  8001ff:	e8 54 00 00 00       	call   800258 <vcprintf>
	cprintf("\n");
  800204:	c7 04 24 34 2f 80 00 	movl   $0x802f34,(%esp)
  80020b:	e8 99 00 00 00       	call   8002a9 <cprintf>
  800210:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800213:	cc                   	int3   
  800214:	eb fd                	jmp    800213 <_panic+0x43>

00800216 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	53                   	push   %ebx
  80021a:	83 ec 04             	sub    $0x4,%esp
  80021d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800220:	8b 13                	mov    (%ebx),%edx
  800222:	8d 42 01             	lea    0x1(%edx),%eax
  800225:	89 03                	mov    %eax,(%ebx)
  800227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80022e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800233:	75 1a                	jne    80024f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800235:	83 ec 08             	sub    $0x8,%esp
  800238:	68 ff 00 00 00       	push   $0xff
  80023d:	8d 43 08             	lea    0x8(%ebx),%eax
  800240:	50                   	push   %eax
  800241:	e8 2f 09 00 00       	call   800b75 <sys_cputs>
		b->idx = 0;
  800246:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80024c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80024f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800253:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800261:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800268:	00 00 00 
	b.cnt = 0;
  80026b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800272:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800275:	ff 75 0c             	pushl  0xc(%ebp)
  800278:	ff 75 08             	pushl  0x8(%ebp)
  80027b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800281:	50                   	push   %eax
  800282:	68 16 02 80 00       	push   $0x800216
  800287:	e8 54 01 00 00       	call   8003e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80028c:	83 c4 08             	add    $0x8,%esp
  80028f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800295:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80029b:	50                   	push   %eax
  80029c:	e8 d4 08 00 00       	call   800b75 <sys_cputs>

	return b.cnt;
}
  8002a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b2:	50                   	push   %eax
  8002b3:	ff 75 08             	pushl  0x8(%ebp)
  8002b6:	e8 9d ff ff ff       	call   800258 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 1c             	sub    $0x1c,%esp
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	89 d6                	mov    %edx,%esi
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002e4:	39 d3                	cmp    %edx,%ebx
  8002e6:	72 05                	jb     8002ed <printnum+0x30>
  8002e8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002eb:	77 45                	ja     800332 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ed:	83 ec 0c             	sub    $0xc,%esp
  8002f0:	ff 75 18             	pushl  0x18(%ebp)
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002f9:	53                   	push   %ebx
  8002fa:	ff 75 10             	pushl  0x10(%ebp)
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	ff 75 e4             	pushl  -0x1c(%ebp)
  800303:	ff 75 e0             	pushl  -0x20(%ebp)
  800306:	ff 75 dc             	pushl  -0x24(%ebp)
  800309:	ff 75 d8             	pushl  -0x28(%ebp)
  80030c:	e8 3f 22 00 00       	call   802550 <__udivdi3>
  800311:	83 c4 18             	add    $0x18,%esp
  800314:	52                   	push   %edx
  800315:	50                   	push   %eax
  800316:	89 f2                	mov    %esi,%edx
  800318:	89 f8                	mov    %edi,%eax
  80031a:	e8 9e ff ff ff       	call   8002bd <printnum>
  80031f:	83 c4 20             	add    $0x20,%esp
  800322:	eb 18                	jmp    80033c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800324:	83 ec 08             	sub    $0x8,%esp
  800327:	56                   	push   %esi
  800328:	ff 75 18             	pushl  0x18(%ebp)
  80032b:	ff d7                	call   *%edi
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	eb 03                	jmp    800335 <printnum+0x78>
  800332:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800335:	83 eb 01             	sub    $0x1,%ebx
  800338:	85 db                	test   %ebx,%ebx
  80033a:	7f e8                	jg     800324 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	56                   	push   %esi
  800340:	83 ec 04             	sub    $0x4,%esp
  800343:	ff 75 e4             	pushl  -0x1c(%ebp)
  800346:	ff 75 e0             	pushl  -0x20(%ebp)
  800349:	ff 75 dc             	pushl  -0x24(%ebp)
  80034c:	ff 75 d8             	pushl  -0x28(%ebp)
  80034f:	e8 2c 23 00 00       	call   802680 <__umoddi3>
  800354:	83 c4 14             	add    $0x14,%esp
  800357:	0f be 80 b3 28 80 00 	movsbl 0x8028b3(%eax),%eax
  80035e:	50                   	push   %eax
  80035f:	ff d7                	call   *%edi
}
  800361:	83 c4 10             	add    $0x10,%esp
  800364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036f:	83 fa 01             	cmp    $0x1,%edx
  800372:	7e 0e                	jle    800382 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 08             	lea    0x8(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	8b 52 04             	mov    0x4(%edx),%edx
  800380:	eb 22                	jmp    8003a4 <getuint+0x38>
	else if (lflag)
  800382:	85 d2                	test   %edx,%edx
  800384:	74 10                	je     800396 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800386:	8b 10                	mov    (%eax),%edx
  800388:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038b:	89 08                	mov    %ecx,(%eax)
  80038d:	8b 02                	mov    (%edx),%eax
  80038f:	ba 00 00 00 00       	mov    $0x0,%edx
  800394:	eb 0e                	jmp    8003a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b5:	73 0a                	jae    8003c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ba:	89 08                	mov    %ecx,(%eax)
  8003bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bf:	88 02                	mov    %al,(%edx)
}
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cc:	50                   	push   %eax
  8003cd:	ff 75 10             	pushl  0x10(%ebp)
  8003d0:	ff 75 0c             	pushl  0xc(%ebp)
  8003d3:	ff 75 08             	pushl  0x8(%ebp)
  8003d6:	e8 05 00 00 00       	call   8003e0 <vprintfmt>
	va_end(ap);
}
  8003db:	83 c4 10             	add    $0x10,%esp
  8003de:	c9                   	leave  
  8003df:	c3                   	ret    

008003e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	83 ec 2c             	sub    $0x2c,%esp
  8003e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f2:	eb 12                	jmp    800406 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	0f 84 89 03 00 00    	je     800785 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003fc:	83 ec 08             	sub    $0x8,%esp
  8003ff:	53                   	push   %ebx
  800400:	50                   	push   %eax
  800401:	ff d6                	call   *%esi
  800403:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800406:	83 c7 01             	add    $0x1,%edi
  800409:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80040d:	83 f8 25             	cmp    $0x25,%eax
  800410:	75 e2                	jne    8003f4 <vprintfmt+0x14>
  800412:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800416:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80041d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800424:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80042b:	ba 00 00 00 00       	mov    $0x0,%edx
  800430:	eb 07                	jmp    800439 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800435:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8d 47 01             	lea    0x1(%edi),%eax
  80043c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043f:	0f b6 07             	movzbl (%edi),%eax
  800442:	0f b6 c8             	movzbl %al,%ecx
  800445:	83 e8 23             	sub    $0x23,%eax
  800448:	3c 55                	cmp    $0x55,%al
  80044a:	0f 87 1a 03 00 00    	ja     80076a <vprintfmt+0x38a>
  800450:	0f b6 c0             	movzbl %al,%eax
  800453:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  80045a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80045d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800461:	eb d6                	jmp    800439 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800471:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800475:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800478:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80047b:	83 fa 09             	cmp    $0x9,%edx
  80047e:	77 39                	ja     8004b9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800480:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800483:	eb e9                	jmp    80046e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 48 04             	lea    0x4(%eax),%ecx
  80048b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80048e:	8b 00                	mov    (%eax),%eax
  800490:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800496:	eb 27                	jmp    8004bf <vprintfmt+0xdf>
  800498:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004a2:	0f 49 c8             	cmovns %eax,%ecx
  8004a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ab:	eb 8c                	jmp    800439 <vprintfmt+0x59>
  8004ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004b7:	eb 80                	jmp    800439 <vprintfmt+0x59>
  8004b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004bc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c3:	0f 89 70 ff ff ff    	jns    800439 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d6:	e9 5e ff ff ff       	jmp    800439 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004db:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e1:	e9 53 ff ff ff       	jmp    800439 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	ff 30                	pushl  (%eax)
  8004f5:	ff d6                	call   *%esi
			break;
  8004f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004fd:	e9 04 ff ff ff       	jmp    800406 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8d 50 04             	lea    0x4(%eax),%edx
  800508:	89 55 14             	mov    %edx,0x14(%ebp)
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	99                   	cltd   
  80050e:	31 d0                	xor    %edx,%eax
  800510:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800512:	83 f8 0f             	cmp    $0xf,%eax
  800515:	7f 0b                	jg     800522 <vprintfmt+0x142>
  800517:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  80051e:	85 d2                	test   %edx,%edx
  800520:	75 18                	jne    80053a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800522:	50                   	push   %eax
  800523:	68 cb 28 80 00       	push   $0x8028cb
  800528:	53                   	push   %ebx
  800529:	56                   	push   %esi
  80052a:	e8 94 fe ff ff       	call   8003c3 <printfmt>
  80052f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800535:	e9 cc fe ff ff       	jmp    800406 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80053a:	52                   	push   %edx
  80053b:	68 73 2d 80 00       	push   $0x802d73
  800540:	53                   	push   %ebx
  800541:	56                   	push   %esi
  800542:	e8 7c fe ff ff       	call   8003c3 <printfmt>
  800547:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054d:	e9 b4 fe ff ff       	jmp    800406 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80055d:	85 ff                	test   %edi,%edi
  80055f:	b8 c4 28 80 00       	mov    $0x8028c4,%eax
  800564:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800567:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80056b:	0f 8e 94 00 00 00    	jle    800605 <vprintfmt+0x225>
  800571:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800575:	0f 84 98 00 00 00    	je     800613 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 d0             	pushl  -0x30(%ebp)
  800581:	57                   	push   %edi
  800582:	e8 86 02 00 00       	call   80080d <strnlen>
  800587:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80058a:	29 c1                	sub    %eax,%ecx
  80058c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80058f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800592:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800596:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800599:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80059c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059e:	eb 0f                	jmp    8005af <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005a7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a9:	83 ef 01             	sub    $0x1,%edi
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	85 ff                	test   %edi,%edi
  8005b1:	7f ed                	jg     8005a0 <vprintfmt+0x1c0>
  8005b3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005b6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c0:	0f 49 c1             	cmovns %ecx,%eax
  8005c3:	29 c1                	sub    %eax,%ecx
  8005c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ce:	89 cb                	mov    %ecx,%ebx
  8005d0:	eb 4d                	jmp    80061f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d6:	74 1b                	je     8005f3 <vprintfmt+0x213>
  8005d8:	0f be c0             	movsbl %al,%eax
  8005db:	83 e8 20             	sub    $0x20,%eax
  8005de:	83 f8 5e             	cmp    $0x5e,%eax
  8005e1:	76 10                	jbe    8005f3 <vprintfmt+0x213>
					putch('?', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	ff 75 0c             	pushl  0xc(%ebp)
  8005e9:	6a 3f                	push   $0x3f
  8005eb:	ff 55 08             	call   *0x8(%ebp)
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	eb 0d                	jmp    800600 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	ff 75 0c             	pushl  0xc(%ebp)
  8005f9:	52                   	push   %edx
  8005fa:	ff 55 08             	call   *0x8(%ebp)
  8005fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800600:	83 eb 01             	sub    $0x1,%ebx
  800603:	eb 1a                	jmp    80061f <vprintfmt+0x23f>
  800605:	89 75 08             	mov    %esi,0x8(%ebp)
  800608:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80060b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80060e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800611:	eb 0c                	jmp    80061f <vprintfmt+0x23f>
  800613:	89 75 08             	mov    %esi,0x8(%ebp)
  800616:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800619:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80061c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061f:	83 c7 01             	add    $0x1,%edi
  800622:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800626:	0f be d0             	movsbl %al,%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	74 23                	je     800650 <vprintfmt+0x270>
  80062d:	85 f6                	test   %esi,%esi
  80062f:	78 a1                	js     8005d2 <vprintfmt+0x1f2>
  800631:	83 ee 01             	sub    $0x1,%esi
  800634:	79 9c                	jns    8005d2 <vprintfmt+0x1f2>
  800636:	89 df                	mov    %ebx,%edi
  800638:	8b 75 08             	mov    0x8(%ebp),%esi
  80063b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063e:	eb 18                	jmp    800658 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 20                	push   $0x20
  800646:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800648:	83 ef 01             	sub    $0x1,%edi
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	eb 08                	jmp    800658 <vprintfmt+0x278>
  800650:	89 df                	mov    %ebx,%edi
  800652:	8b 75 08             	mov    0x8(%ebp),%esi
  800655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800658:	85 ff                	test   %edi,%edi
  80065a:	7f e4                	jg     800640 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065f:	e9 a2 fd ff ff       	jmp    800406 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800664:	83 fa 01             	cmp    $0x1,%edx
  800667:	7e 16                	jle    80067f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 08             	lea    0x8(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)
  800672:	8b 50 04             	mov    0x4(%eax),%edx
  800675:	8b 00                	mov    (%eax),%eax
  800677:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067d:	eb 32                	jmp    8006b1 <vprintfmt+0x2d1>
	else if (lflag)
  80067f:	85 d2                	test   %edx,%edx
  800681:	74 18                	je     80069b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 00                	mov    (%eax),%eax
  80068e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800691:	89 c1                	mov    %eax,%ecx
  800693:	c1 f9 1f             	sar    $0x1f,%ecx
  800696:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800699:	eb 16                	jmp    8006b1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8d 50 04             	lea    0x4(%eax),%edx
  8006a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a4:	8b 00                	mov    (%eax),%eax
  8006a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a9:	89 c1                	mov    %eax,%ecx
  8006ab:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c0:	79 74                	jns    800736 <vprintfmt+0x356>
				putch('-', putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 2d                	push   $0x2d
  8006c8:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006d0:	f7 d8                	neg    %eax
  8006d2:	83 d2 00             	adc    $0x0,%edx
  8006d5:	f7 da                	neg    %edx
  8006d7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006da:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006df:	eb 55                	jmp    800736 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e4:	e8 83 fc ff ff       	call   80036c <getuint>
			base = 10;
  8006e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ee:	eb 46                	jmp    800736 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f3:	e8 74 fc ff ff       	call   80036c <getuint>
			base = 8;
  8006f8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006fd:	eb 37                	jmp    800736 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	53                   	push   %ebx
  800703:	6a 30                	push   $0x30
  800705:	ff d6                	call   *%esi
			putch('x', putdat);
  800707:	83 c4 08             	add    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	6a 78                	push   $0x78
  80070d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80071f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800722:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800727:	eb 0d                	jmp    800736 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	e8 3b fc ff ff       	call   80036c <getuint>
			base = 16;
  800731:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800736:	83 ec 0c             	sub    $0xc,%esp
  800739:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80073d:	57                   	push   %edi
  80073e:	ff 75 e0             	pushl  -0x20(%ebp)
  800741:	51                   	push   %ecx
  800742:	52                   	push   %edx
  800743:	50                   	push   %eax
  800744:	89 da                	mov    %ebx,%edx
  800746:	89 f0                	mov    %esi,%eax
  800748:	e8 70 fb ff ff       	call   8002bd <printnum>
			break;
  80074d:	83 c4 20             	add    $0x20,%esp
  800750:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800753:	e9 ae fc ff ff       	jmp    800406 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	53                   	push   %ebx
  80075c:	51                   	push   %ecx
  80075d:	ff d6                	call   *%esi
			break;
  80075f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800762:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800765:	e9 9c fc ff ff       	jmp    800406 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 25                	push   $0x25
  800770:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	eb 03                	jmp    80077a <vprintfmt+0x39a>
  800777:	83 ef 01             	sub    $0x1,%edi
  80077a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80077e:	75 f7                	jne    800777 <vprintfmt+0x397>
  800780:	e9 81 fc ff ff       	jmp    800406 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800785:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5f                   	pop    %edi
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 18             	sub    $0x18,%esp
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800799:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007aa:	85 c0                	test   %eax,%eax
  8007ac:	74 26                	je     8007d4 <vsnprintf+0x47>
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	7e 22                	jle    8007d4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b2:	ff 75 14             	pushl  0x14(%ebp)
  8007b5:	ff 75 10             	pushl  0x10(%ebp)
  8007b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007bb:	50                   	push   %eax
  8007bc:	68 a6 03 80 00       	push   $0x8003a6
  8007c1:	e8 1a fc ff ff       	call   8003e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	eb 05                	jmp    8007d9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e4:	50                   	push   %eax
  8007e5:	ff 75 10             	pushl  0x10(%ebp)
  8007e8:	ff 75 0c             	pushl  0xc(%ebp)
  8007eb:	ff 75 08             	pushl  0x8(%ebp)
  8007ee:	e8 9a ff ff ff       	call   80078d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    

008007f5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 03                	jmp    800805 <strlen+0x10>
		n++;
  800802:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800805:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800809:	75 f7                	jne    800802 <strlen+0xd>
		n++;
	return n;
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800813:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800816:	ba 00 00 00 00       	mov    $0x0,%edx
  80081b:	eb 03                	jmp    800820 <strnlen+0x13>
		n++;
  80081d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800820:	39 c2                	cmp    %eax,%edx
  800822:	74 08                	je     80082c <strnlen+0x1f>
  800824:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800828:	75 f3                	jne    80081d <strnlen+0x10>
  80082a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c2 01             	add    $0x1,%edx
  80083d:	83 c1 01             	add    $0x1,%ecx
  800840:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800844:	88 5a ff             	mov    %bl,-0x1(%edx)
  800847:	84 db                	test   %bl,%bl
  800849:	75 ef                	jne    80083a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80084b:	5b                   	pop    %ebx
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	53                   	push   %ebx
  800852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800855:	53                   	push   %ebx
  800856:	e8 9a ff ff ff       	call   8007f5 <strlen>
  80085b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	01 d8                	add    %ebx,%eax
  800863:	50                   	push   %eax
  800864:	e8 c5 ff ff ff       	call   80082e <strcpy>
	return dst;
}
  800869:	89 d8                	mov    %ebx,%eax
  80086b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	56                   	push   %esi
  800874:	53                   	push   %ebx
  800875:	8b 75 08             	mov    0x8(%ebp),%esi
  800878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087b:	89 f3                	mov    %esi,%ebx
  80087d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800880:	89 f2                	mov    %esi,%edx
  800882:	eb 0f                	jmp    800893 <strncpy+0x23>
		*dst++ = *src;
  800884:	83 c2 01             	add    $0x1,%edx
  800887:	0f b6 01             	movzbl (%ecx),%eax
  80088a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088d:	80 39 01             	cmpb   $0x1,(%ecx)
  800890:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800893:	39 da                	cmp    %ebx,%edx
  800895:	75 ed                	jne    800884 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800897:	89 f0                	mov    %esi,%eax
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	56                   	push   %esi
  8008a1:	53                   	push   %ebx
  8008a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a8:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ab:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ad:	85 d2                	test   %edx,%edx
  8008af:	74 21                	je     8008d2 <strlcpy+0x35>
  8008b1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b5:	89 f2                	mov    %esi,%edx
  8008b7:	eb 09                	jmp    8008c2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b9:	83 c2 01             	add    $0x1,%edx
  8008bc:	83 c1 01             	add    $0x1,%ecx
  8008bf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c2:	39 c2                	cmp    %eax,%edx
  8008c4:	74 09                	je     8008cf <strlcpy+0x32>
  8008c6:	0f b6 19             	movzbl (%ecx),%ebx
  8008c9:	84 db                	test   %bl,%bl
  8008cb:	75 ec                	jne    8008b9 <strlcpy+0x1c>
  8008cd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008cf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d2:	29 f0                	sub    %esi,%eax
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e1:	eb 06                	jmp    8008e9 <strcmp+0x11>
		p++, q++;
  8008e3:	83 c1 01             	add    $0x1,%ecx
  8008e6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e9:	0f b6 01             	movzbl (%ecx),%eax
  8008ec:	84 c0                	test   %al,%al
  8008ee:	74 04                	je     8008f4 <strcmp+0x1c>
  8008f0:	3a 02                	cmp    (%edx),%al
  8008f2:	74 ef                	je     8008e3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f4:	0f b6 c0             	movzbl %al,%eax
  8008f7:	0f b6 12             	movzbl (%edx),%edx
  8008fa:	29 d0                	sub    %edx,%eax
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	53                   	push   %ebx
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	89 c3                	mov    %eax,%ebx
  80090a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80090d:	eb 06                	jmp    800915 <strncmp+0x17>
		n--, p++, q++;
  80090f:	83 c0 01             	add    $0x1,%eax
  800912:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800915:	39 d8                	cmp    %ebx,%eax
  800917:	74 15                	je     80092e <strncmp+0x30>
  800919:	0f b6 08             	movzbl (%eax),%ecx
  80091c:	84 c9                	test   %cl,%cl
  80091e:	74 04                	je     800924 <strncmp+0x26>
  800920:	3a 0a                	cmp    (%edx),%cl
  800922:	74 eb                	je     80090f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800924:	0f b6 00             	movzbl (%eax),%eax
  800927:	0f b6 12             	movzbl (%edx),%edx
  80092a:	29 d0                	sub    %edx,%eax
  80092c:	eb 05                	jmp    800933 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800933:	5b                   	pop    %ebx
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800940:	eb 07                	jmp    800949 <strchr+0x13>
		if (*s == c)
  800942:	38 ca                	cmp    %cl,%dl
  800944:	74 0f                	je     800955 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	0f b6 10             	movzbl (%eax),%edx
  80094c:	84 d2                	test   %dl,%dl
  80094e:	75 f2                	jne    800942 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800961:	eb 03                	jmp    800966 <strfind+0xf>
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800969:	38 ca                	cmp    %cl,%dl
  80096b:	74 04                	je     800971 <strfind+0x1a>
  80096d:	84 d2                	test   %dl,%dl
  80096f:	75 f2                	jne    800963 <strfind+0xc>
			break;
	return (char *) s;
}
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097f:	85 c9                	test   %ecx,%ecx
  800981:	74 36                	je     8009b9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800983:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800989:	75 28                	jne    8009b3 <memset+0x40>
  80098b:	f6 c1 03             	test   $0x3,%cl
  80098e:	75 23                	jne    8009b3 <memset+0x40>
		c &= 0xFF;
  800990:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800994:	89 d3                	mov    %edx,%ebx
  800996:	c1 e3 08             	shl    $0x8,%ebx
  800999:	89 d6                	mov    %edx,%esi
  80099b:	c1 e6 18             	shl    $0x18,%esi
  80099e:	89 d0                	mov    %edx,%eax
  8009a0:	c1 e0 10             	shl    $0x10,%eax
  8009a3:	09 f0                	or     %esi,%eax
  8009a5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009a7:	89 d8                	mov    %ebx,%eax
  8009a9:	09 d0                	or     %edx,%eax
  8009ab:	c1 e9 02             	shr    $0x2,%ecx
  8009ae:	fc                   	cld    
  8009af:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b1:	eb 06                	jmp    8009b9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b6:	fc                   	cld    
  8009b7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b9:	89 f8                	mov    %edi,%eax
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5f                   	pop    %edi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ce:	39 c6                	cmp    %eax,%esi
  8009d0:	73 35                	jae    800a07 <memmove+0x47>
  8009d2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d5:	39 d0                	cmp    %edx,%eax
  8009d7:	73 2e                	jae    800a07 <memmove+0x47>
		s += n;
		d += n;
  8009d9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dc:	89 d6                	mov    %edx,%esi
  8009de:	09 fe                	or     %edi,%esi
  8009e0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e6:	75 13                	jne    8009fb <memmove+0x3b>
  8009e8:	f6 c1 03             	test   $0x3,%cl
  8009eb:	75 0e                	jne    8009fb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ed:	83 ef 04             	sub    $0x4,%edi
  8009f0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
  8009f6:	fd                   	std    
  8009f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f9:	eb 09                	jmp    800a04 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009fb:	83 ef 01             	sub    $0x1,%edi
  8009fe:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a01:	fd                   	std    
  800a02:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a04:	fc                   	cld    
  800a05:	eb 1d                	jmp    800a24 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a07:	89 f2                	mov    %esi,%edx
  800a09:	09 c2                	or     %eax,%edx
  800a0b:	f6 c2 03             	test   $0x3,%dl
  800a0e:	75 0f                	jne    800a1f <memmove+0x5f>
  800a10:	f6 c1 03             	test   $0x3,%cl
  800a13:	75 0a                	jne    800a1f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a15:	c1 e9 02             	shr    $0x2,%ecx
  800a18:	89 c7                	mov    %eax,%edi
  800a1a:	fc                   	cld    
  800a1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1d:	eb 05                	jmp    800a24 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1f:	89 c7                	mov    %eax,%edi
  800a21:	fc                   	cld    
  800a22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a24:	5e                   	pop    %esi
  800a25:	5f                   	pop    %edi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a2b:	ff 75 10             	pushl  0x10(%ebp)
  800a2e:	ff 75 0c             	pushl  0xc(%ebp)
  800a31:	ff 75 08             	pushl  0x8(%ebp)
  800a34:	e8 87 ff ff ff       	call   8009c0 <memmove>
}
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a46:	89 c6                	mov    %eax,%esi
  800a48:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4b:	eb 1a                	jmp    800a67 <memcmp+0x2c>
		if (*s1 != *s2)
  800a4d:	0f b6 08             	movzbl (%eax),%ecx
  800a50:	0f b6 1a             	movzbl (%edx),%ebx
  800a53:	38 d9                	cmp    %bl,%cl
  800a55:	74 0a                	je     800a61 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a57:	0f b6 c1             	movzbl %cl,%eax
  800a5a:	0f b6 db             	movzbl %bl,%ebx
  800a5d:	29 d8                	sub    %ebx,%eax
  800a5f:	eb 0f                	jmp    800a70 <memcmp+0x35>
		s1++, s2++;
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a67:	39 f0                	cmp    %esi,%eax
  800a69:	75 e2                	jne    800a4d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	53                   	push   %ebx
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a7b:	89 c1                	mov    %eax,%ecx
  800a7d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a80:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a84:	eb 0a                	jmp    800a90 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a86:	0f b6 10             	movzbl (%eax),%edx
  800a89:	39 da                	cmp    %ebx,%edx
  800a8b:	74 07                	je     800a94 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	39 c8                	cmp    %ecx,%eax
  800a92:	72 f2                	jb     800a86 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a94:	5b                   	pop    %ebx
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa3:	eb 03                	jmp    800aa8 <strtol+0x11>
		s++;
  800aa5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa8:	0f b6 01             	movzbl (%ecx),%eax
  800aab:	3c 20                	cmp    $0x20,%al
  800aad:	74 f6                	je     800aa5 <strtol+0xe>
  800aaf:	3c 09                	cmp    $0x9,%al
  800ab1:	74 f2                	je     800aa5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab3:	3c 2b                	cmp    $0x2b,%al
  800ab5:	75 0a                	jne    800ac1 <strtol+0x2a>
		s++;
  800ab7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aba:	bf 00 00 00 00       	mov    $0x0,%edi
  800abf:	eb 11                	jmp    800ad2 <strtol+0x3b>
  800ac1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac6:	3c 2d                	cmp    $0x2d,%al
  800ac8:	75 08                	jne    800ad2 <strtol+0x3b>
		s++, neg = 1;
  800aca:	83 c1 01             	add    $0x1,%ecx
  800acd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad8:	75 15                	jne    800aef <strtol+0x58>
  800ada:	80 39 30             	cmpb   $0x30,(%ecx)
  800add:	75 10                	jne    800aef <strtol+0x58>
  800adf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae3:	75 7c                	jne    800b61 <strtol+0xca>
		s += 2, base = 16;
  800ae5:	83 c1 02             	add    $0x2,%ecx
  800ae8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aed:	eb 16                	jmp    800b05 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aef:	85 db                	test   %ebx,%ebx
  800af1:	75 12                	jne    800b05 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af8:	80 39 30             	cmpb   $0x30,(%ecx)
  800afb:	75 08                	jne    800b05 <strtol+0x6e>
		s++, base = 8;
  800afd:	83 c1 01             	add    $0x1,%ecx
  800b00:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0d:	0f b6 11             	movzbl (%ecx),%edx
  800b10:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b13:	89 f3                	mov    %esi,%ebx
  800b15:	80 fb 09             	cmp    $0x9,%bl
  800b18:	77 08                	ja     800b22 <strtol+0x8b>
			dig = *s - '0';
  800b1a:	0f be d2             	movsbl %dl,%edx
  800b1d:	83 ea 30             	sub    $0x30,%edx
  800b20:	eb 22                	jmp    800b44 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b22:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b25:	89 f3                	mov    %esi,%ebx
  800b27:	80 fb 19             	cmp    $0x19,%bl
  800b2a:	77 08                	ja     800b34 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b2c:	0f be d2             	movsbl %dl,%edx
  800b2f:	83 ea 57             	sub    $0x57,%edx
  800b32:	eb 10                	jmp    800b44 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b34:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b37:	89 f3                	mov    %esi,%ebx
  800b39:	80 fb 19             	cmp    $0x19,%bl
  800b3c:	77 16                	ja     800b54 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b3e:	0f be d2             	movsbl %dl,%edx
  800b41:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b44:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b47:	7d 0b                	jge    800b54 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b50:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b52:	eb b9                	jmp    800b0d <strtol+0x76>

	if (endptr)
  800b54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b58:	74 0d                	je     800b67 <strtol+0xd0>
		*endptr = (char *) s;
  800b5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5d:	89 0e                	mov    %ecx,(%esi)
  800b5f:	eb 06                	jmp    800b67 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b61:	85 db                	test   %ebx,%ebx
  800b63:	74 98                	je     800afd <strtol+0x66>
  800b65:	eb 9e                	jmp    800b05 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b67:	89 c2                	mov    %eax,%edx
  800b69:	f7 da                	neg    %edx
  800b6b:	85 ff                	test   %edi,%edi
  800b6d:	0f 45 c2             	cmovne %edx,%eax
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	89 c3                	mov    %eax,%ebx
  800b88:	89 c7                	mov    %eax,%edi
  800b8a:	89 c6                	mov    %eax,%esi
  800b8c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba3:	89 d1                	mov    %edx,%ecx
  800ba5:	89 d3                	mov    %edx,%ebx
  800ba7:	89 d7                	mov    %edx,%edi
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	89 cb                	mov    %ecx,%ebx
  800bca:	89 cf                	mov    %ecx,%edi
  800bcc:	89 ce                	mov    %ecx,%esi
  800bce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 17                	jle    800beb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	50                   	push   %eax
  800bd8:	6a 03                	push   $0x3
  800bda:	68 bf 2b 80 00       	push   $0x802bbf
  800bdf:	6a 23                	push   $0x23
  800be1:	68 dc 2b 80 00       	push   $0x802bdc
  800be6:	e8 e5 f5 ff ff       	call   8001d0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfe:	b8 02 00 00 00       	mov    $0x2,%eax
  800c03:	89 d1                	mov    %edx,%ecx
  800c05:	89 d3                	mov    %edx,%ebx
  800c07:	89 d7                	mov    %edx,%edi
  800c09:	89 d6                	mov    %edx,%esi
  800c0b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <sys_yield>:

void
sys_yield(void)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c22:	89 d1                	mov    %edx,%ecx
  800c24:	89 d3                	mov    %edx,%ebx
  800c26:	89 d7                	mov    %edx,%edi
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	be 00 00 00 00       	mov    $0x0,%esi
  800c3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4d:	89 f7                	mov    %esi,%edi
  800c4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 17                	jle    800c6c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 04                	push   $0x4
  800c5b:	68 bf 2b 80 00       	push   $0x802bbf
  800c60:	6a 23                	push   $0x23
  800c62:	68 dc 2b 80 00       	push   $0x802bdc
  800c67:	e8 64 f5 ff ff       	call   8001d0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 17                	jle    800cae <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 05                	push   $0x5
  800c9d:	68 bf 2b 80 00       	push   $0x802bbf
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 dc 2b 80 00       	push   $0x802bdc
  800ca9:	e8 22 f5 ff ff       	call   8001d0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	89 df                	mov    %ebx,%edi
  800cd1:	89 de                	mov    %ebx,%esi
  800cd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 17                	jle    800cf0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	50                   	push   %eax
  800cdd:	6a 06                	push   $0x6
  800cdf:	68 bf 2b 80 00       	push   $0x802bbf
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 dc 2b 80 00       	push   $0x802bdc
  800ceb:	e8 e0 f4 ff ff       	call   8001d0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d06:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	89 df                	mov    %ebx,%edi
  800d13:	89 de                	mov    %ebx,%esi
  800d15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 17                	jle    800d32 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 08                	push   $0x8
  800d21:	68 bf 2b 80 00       	push   $0x802bbf
  800d26:	6a 23                	push   $0x23
  800d28:	68 dc 2b 80 00       	push   $0x802bdc
  800d2d:	e8 9e f4 ff ff       	call   8001d0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 17                	jle    800d74 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	6a 09                	push   $0x9
  800d63:	68 bf 2b 80 00       	push   $0x802bbf
  800d68:	6a 23                	push   $0x23
  800d6a:	68 dc 2b 80 00       	push   $0x802bdc
  800d6f:	e8 5c f4 ff ff       	call   8001d0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	89 df                	mov    %ebx,%edi
  800d97:	89 de                	mov    %ebx,%esi
  800d99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	7e 17                	jle    800db6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	50                   	push   %eax
  800da3:	6a 0a                	push   $0xa
  800da5:	68 bf 2b 80 00       	push   $0x802bbf
  800daa:	6a 23                	push   $0x23
  800dac:	68 dc 2b 80 00       	push   $0x802bdc
  800db1:	e8 1a f4 ff ff       	call   8001d0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	be 00 00 00 00       	mov    $0x0,%esi
  800dc9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dda:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800def:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 cb                	mov    %ecx,%ebx
  800df9:	89 cf                	mov    %ecx,%edi
  800dfb:	89 ce                	mov    %ecx,%esi
  800dfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 17                	jle    800e1a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 0d                	push   $0xd
  800e09:	68 bf 2b 80 00       	push   $0x802bbf
  800e0e:	6a 23                	push   $0x23
  800e10:	68 dc 2b 80 00       	push   $0x802bdc
  800e15:	e8 b6 f3 ff ff       	call   8001d0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	53                   	push   %ebx
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800e2e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e32:	75 14                	jne    800e48 <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800e34:	83 ec 04             	sub    $0x4,%esp
  800e37:	68 ec 2b 80 00       	push   $0x802bec
  800e3c:	6a 22                	push   $0x22
  800e3e:	68 cf 2c 80 00       	push   $0x802ccf
  800e43:	e8 88 f3 ff ff       	call   8001d0 <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800e48:	89 d8                	mov    %ebx,%eax
  800e4a:	c1 e8 0c             	shr    $0xc,%eax
  800e4d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e54:	f6 c4 08             	test   $0x8,%ah
  800e57:	75 14                	jne    800e6d <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800e59:	83 ec 04             	sub    $0x4,%esp
  800e5c:	68 28 2c 80 00       	push   $0x802c28
  800e61:	6a 27                	push   $0x27
  800e63:	68 cf 2c 80 00       	push   $0x802ccf
  800e68:	e8 63 f3 ff ff       	call   8001d0 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	6a 07                	push   $0x7
  800e72:	68 00 f0 7f 00       	push   $0x7ff000
  800e77:	6a 00                	push   $0x0
  800e79:	e8 b3 fd ff ff       	call   800c31 <sys_page_alloc>
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	79 14                	jns    800e99 <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800e85:	83 ec 04             	sub    $0x4,%esp
  800e88:	68 58 2c 80 00       	push   $0x802c58
  800e8d:	6a 2f                	push   $0x2f
  800e8f:	68 cf 2c 80 00       	push   $0x802ccf
  800e94:	e8 37 f3 ff ff       	call   8001d0 <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800e99:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	68 00 10 00 00       	push   $0x1000
  800ea7:	53                   	push   %ebx
  800ea8:	68 00 f0 7f 00       	push   $0x7ff000
  800ead:	e8 0e fb ff ff       	call   8009c0 <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800eb2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eb9:	53                   	push   %ebx
  800eba:	6a 00                	push   $0x0
  800ebc:	68 00 f0 7f 00       	push   $0x7ff000
  800ec1:	6a 00                	push   $0x0
  800ec3:	e8 ac fd ff ff       	call   800c74 <sys_page_map>
  800ec8:	83 c4 20             	add    $0x20,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	79 14                	jns    800ee3 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	68 84 2c 80 00       	push   $0x802c84
  800ed7:	6a 34                	push   $0x34
  800ed9:	68 cf 2c 80 00       	push   $0x802ccf
  800ede:	e8 ed f2 ff ff       	call   8001d0 <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ee3:	83 ec 08             	sub    $0x8,%esp
  800ee6:	68 00 f0 7f 00       	push   $0x7ff000
  800eeb:	6a 00                	push   $0x0
  800eed:	e8 c4 fd ff ff       	call   800cb6 <sys_page_unmap>
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	79 14                	jns    800f0d <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	68 ac 2c 80 00       	push   $0x802cac
  800f01:	6a 37                	push   $0x37
  800f03:	68 cf 2c 80 00       	push   $0x802ccf
  800f08:	e8 c3 f2 ff ff       	call   8001d0 <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800f0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f10:	c9                   	leave  
  800f11:	c3                   	ret    

00800f12 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800f1b:	68 22 0e 80 00       	push   $0x800e22
  800f20:	e8 56 07 00 00       	call   80167b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f25:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2a:	cd 30                	int    $0x30
  800f2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  800f2f:	83 c4 10             	add    $0x10,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	79 15                	jns    800f4b <fork+0x39>
		panic("sys_exofork: %e", envid);
  800f36:	50                   	push   %eax
  800f37:	68 da 2c 80 00       	push   $0x802cda
  800f3c:	68 87 00 00 00       	push   $0x87
  800f41:	68 cf 2c 80 00       	push   $0x802ccf
  800f46:	e8 85 f2 ff ff       	call   8001d0 <_panic>
  800f4b:	89 c7                	mov    %eax,%edi
  800f4d:	be 00 00 00 00       	mov    $0x0,%esi
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  800f57:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f5b:	75 21                	jne    800f7e <fork+0x6c>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f5d:	e8 91 fc ff ff       	call   800bf3 <sys_getenvid>
  800f62:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f67:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f6a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f6f:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
  800f79:	e9 56 01 00 00       	jmp    8010d4 <fork+0x1c2>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  800f7e:	89 f0                	mov    %esi,%eax
  800f80:	c1 e8 16             	shr    $0x16,%eax
  800f83:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8a:	a8 01                	test   $0x1,%al
  800f8c:	0f 84 a5 00 00 00    	je     801037 <fork+0x125>
  800f92:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f99:	a8 05                	test   $0x5,%al
  800f9b:	0f 84 96 00 00 00    	je     801037 <fork+0x125>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)))
  800fa1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fa8:	a8 02                	test   $0x2,%al
  800faa:	75 0c                	jne    800fb8 <fork+0xa6>
  800fac:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fb3:	f6 c4 08             	test   $0x8,%ah
  800fb6:	74 57                	je     80100f <fork+0xfd>
	{

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm | PTE_COW))) < 0)
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	68 05 08 00 00       	push   $0x805
  800fc0:	56                   	push   %esi
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 aa fc ff ff       	call   800c74 <sys_page_map>
  800fca:	83 c4 20             	add    $0x20,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	79 12                	jns    800fe3 <fork+0xd1>
			panic("fork: sys_page_map: %e", r);
  800fd1:	50                   	push   %eax
  800fd2:	68 ea 2c 80 00       	push   $0x802cea
  800fd7:	6a 5c                	push   $0x5c
  800fd9:	68 cf 2c 80 00       	push   $0x802ccf
  800fde:	e8 ed f1 ff ff       	call   8001d0 <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm|PTE_COW))) < 0)
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	68 05 08 00 00       	push   $0x805
  800feb:	56                   	push   %esi
  800fec:	6a 00                	push   $0x0
  800fee:	56                   	push   %esi
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 7e fc ff ff       	call   800c74 <sys_page_map>
  800ff6:	83 c4 20             	add    $0x20,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	79 3a                	jns    801037 <fork+0x125>
			panic("fork: sys_page_map: %e", r);
  800ffd:	50                   	push   %eax
  800ffe:	68 ea 2c 80 00       	push   $0x802cea
  801003:	6a 5f                	push   $0x5f
  801005:	68 cf 2c 80 00       	push   $0x802ccf
  80100a:	e8 c1 f1 ff ff       	call   8001d0 <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	6a 05                	push   $0x5
  801014:	56                   	push   %esi
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	6a 00                	push   $0x0
  801019:	e8 56 fc ff ff       	call   800c74 <sys_page_map>
  80101e:	83 c4 20             	add    $0x20,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	79 12                	jns    801037 <fork+0x125>
			panic("fork: sys_page_map: %e", r);
  801025:	50                   	push   %eax
  801026:	68 ea 2c 80 00       	push   $0x802cea
  80102b:	6a 64                	push   $0x64
  80102d:	68 cf 2c 80 00       	push   $0x802ccf
  801032:	e8 99 f1 ff ff       	call   8001d0 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  801037:	83 c3 01             	add    $0x1,%ebx
  80103a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801040:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801046:	0f 85 32 ff ff ff    	jne    800f7e <fork+0x6c>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	6a 07                	push   $0x7
  801051:	68 00 f0 bf ee       	push   $0xeebff000
  801056:	ff 75 e4             	pushl  -0x1c(%ebp)
  801059:	e8 d3 fb ff ff       	call   800c31 <sys_page_alloc>
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 15                	jns    80107a <fork+0x168>
		panic("sys_page_alloc: %e", r);
  801065:	50                   	push   %eax
  801066:	68 ec 27 80 00       	push   $0x8027ec
  80106b:	68 98 00 00 00       	push   $0x98
  801070:	68 cf 2c 80 00       	push   $0x802ccf
  801075:	e8 56 f1 ff ff       	call   8001d0 <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	68 f8 16 80 00       	push   $0x8016f8
  801082:	ff 75 e4             	pushl  -0x1c(%ebp)
  801085:	e8 f2 fc ff ff       	call   800d7c <sys_env_set_pgfault_upcall>
  80108a:	83 c4 10             	add    $0x10,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 17                	jns    8010a8 <fork+0x196>
		panic("sys_pgfault_upcall error");
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	68 01 2d 80 00       	push   $0x802d01
  801099:	68 9b 00 00 00       	push   $0x9b
  80109e:	68 cf 2c 80 00       	push   $0x802ccf
  8010a3:	e8 28 f1 ff ff       	call   8001d0 <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	6a 02                	push   $0x2
  8010ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b0:	e8 43 fc ff ff       	call   800cf8 <sys_env_set_status>
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	79 15                	jns    8010d1 <fork+0x1bf>
		panic("sys_env_set_status: %e", r);
  8010bc:	50                   	push   %eax
  8010bd:	68 1a 2d 80 00       	push   $0x802d1a
  8010c2:	68 a1 00 00 00       	push   $0xa1
  8010c7:	68 cf 2c 80 00       	push   $0x802ccf
  8010cc:	e8 ff f0 ff ff       	call   8001d0 <_panic>

	return envid;
  8010d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sfork>:

// Challenge!
int
sfork(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e2:	68 31 2d 80 00       	push   $0x802d31
  8010e7:	68 ac 00 00 00       	push   $0xac
  8010ec:	68 cf 2c 80 00       	push   $0x802ccf
  8010f1:	e8 da f0 ff ff       	call   8001d0 <_panic>

008010f6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801102:	6a 00                	push   $0x0
  801104:	ff 75 08             	pushl  0x8(%ebp)
  801107:	e8 4c 0d 00 00       	call   801e58 <open>
  80110c:	89 c7                	mov    %eax,%edi
  80110e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	0f 88 30 04 00 00    	js     80154f <spawn+0x459>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80111f:	83 ec 04             	sub    $0x4,%esp
  801122:	68 00 02 00 00       	push   $0x200
  801127:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	57                   	push   %edi
  80112f:	e8 56 09 00 00       	call   801a8a <readn>
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	3d 00 02 00 00       	cmp    $0x200,%eax
  80113c:	75 0c                	jne    80114a <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80113e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801145:	45 4c 46 
  801148:	74 33                	je     80117d <spawn+0x87>
		close(fd);
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801153:	e8 65 07 00 00       	call   8018bd <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801158:	83 c4 0c             	add    $0xc,%esp
  80115b:	68 7f 45 4c 46       	push   $0x464c457f
  801160:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801166:	68 47 2d 80 00       	push   $0x802d47
  80116b:	e8 39 f1 ff ff       	call   8002a9 <cprintf>
		return -E_NOT_EXEC;
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801178:	e9 32 04 00 00       	jmp    8015af <spawn+0x4b9>
  80117d:	b8 07 00 00 00       	mov    $0x7,%eax
  801182:	cd 30                	int    $0x30
  801184:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80118a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801190:	85 c0                	test   %eax,%eax
  801192:	0f 88 bf 03 00 00    	js     801557 <spawn+0x461>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801198:	89 c6                	mov    %eax,%esi
  80119a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8011a0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8011a3:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8011a9:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8011af:	b9 11 00 00 00       	mov    $0x11,%ecx
  8011b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8011b6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8011bc:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8011c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8011c7:	be 00 00 00 00       	mov    $0x0,%esi
  8011cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011cf:	eb 13                	jmp    8011e4 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8011d1:	83 ec 0c             	sub    $0xc,%esp
  8011d4:	50                   	push   %eax
  8011d5:	e8 1b f6 ff ff       	call   8007f5 <strlen>
  8011da:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8011de:	83 c3 01             	add    $0x1,%ebx
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8011eb:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	75 df                	jne    8011d1 <spawn+0xdb>
  8011f2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8011f8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8011fe:	bf 00 10 40 00       	mov    $0x401000,%edi
  801203:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801205:	89 fa                	mov    %edi,%edx
  801207:	83 e2 fc             	and    $0xfffffffc,%edx
  80120a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801211:	29 c2                	sub    %eax,%edx
  801213:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801219:	8d 42 f8             	lea    -0x8(%edx),%eax
  80121c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801221:	0f 86 40 03 00 00    	jbe    801567 <spawn+0x471>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	6a 07                	push   $0x7
  80122c:	68 00 00 40 00       	push   $0x400000
  801231:	6a 00                	push   $0x0
  801233:	e8 f9 f9 ff ff       	call   800c31 <sys_page_alloc>
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	0f 88 2b 03 00 00    	js     80156e <spawn+0x478>
  801243:	be 00 00 00 00       	mov    $0x0,%esi
  801248:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80124e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801251:	eb 30                	jmp    801283 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801253:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801259:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80125f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801268:	57                   	push   %edi
  801269:	e8 c0 f5 ff ff       	call   80082e <strcpy>
		string_store += strlen(argv[i]) + 1;
  80126e:	83 c4 04             	add    $0x4,%esp
  801271:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801274:	e8 7c f5 ff ff       	call   8007f5 <strlen>
  801279:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80127d:	83 c6 01             	add    $0x1,%esi
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801289:	7f c8                	jg     801253 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80128b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801291:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801297:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80129e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8012a4:	74 19                	je     8012bf <spawn+0x1c9>
  8012a6:	68 bc 2d 80 00       	push   $0x802dbc
  8012ab:	68 61 2d 80 00       	push   $0x802d61
  8012b0:	68 f1 00 00 00       	push   $0xf1
  8012b5:	68 76 2d 80 00       	push   $0x802d76
  8012ba:	e8 11 ef ff ff       	call   8001d0 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8012bf:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8012c5:	89 c8                	mov    %ecx,%eax
  8012c7:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8012cc:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8012cf:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8012d5:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8012d8:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8012de:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8012e4:	83 ec 0c             	sub    $0xc,%esp
  8012e7:	6a 07                	push   $0x7
  8012e9:	68 00 d0 bf ee       	push   $0xeebfd000
  8012ee:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8012f4:	68 00 00 40 00       	push   $0x400000
  8012f9:	6a 00                	push   $0x0
  8012fb:	e8 74 f9 ff ff       	call   800c74 <sys_page_map>
  801300:	89 c3                	mov    %eax,%ebx
  801302:	83 c4 20             	add    $0x20,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	0f 88 90 02 00 00    	js     80159d <spawn+0x4a7>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	68 00 00 40 00       	push   $0x400000
  801315:	6a 00                	push   $0x0
  801317:	e8 9a f9 ff ff       	call   800cb6 <sys_page_unmap>
  80131c:	89 c3                	mov    %eax,%ebx
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	0f 88 74 02 00 00    	js     80159d <spawn+0x4a7>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801329:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80132f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801336:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80133c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801343:	00 00 00 
  801346:	e9 86 01 00 00       	jmp    8014d1 <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  80134b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801351:	83 38 01             	cmpl   $0x1,(%eax)
  801354:	0f 85 69 01 00 00    	jne    8014c3 <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80135a:	89 c1                	mov    %eax,%ecx
  80135c:	8b 40 18             	mov    0x18(%eax),%eax
  80135f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801365:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801368:	83 f8 01             	cmp    $0x1,%eax
  80136b:	19 c0                	sbb    %eax,%eax
  80136d:	83 e0 fe             	and    $0xfffffffe,%eax
  801370:	83 c0 07             	add    $0x7,%eax
  801373:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801379:	89 c8                	mov    %ecx,%eax
  80137b:	8b 49 04             	mov    0x4(%ecx),%ecx
  80137e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801384:	8b 78 10             	mov    0x10(%eax),%edi
  801387:	8b 50 14             	mov    0x14(%eax),%edx
  80138a:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801390:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801393:	89 f0                	mov    %esi,%eax
  801395:	25 ff 0f 00 00       	and    $0xfff,%eax
  80139a:	74 14                	je     8013b0 <spawn+0x2ba>
		va -= i;
  80139c:	29 c6                	sub    %eax,%esi
		memsz += i;
  80139e:	01 c2                	add    %eax,%edx
  8013a0:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8013a6:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8013a8:	29 c1                	sub    %eax,%ecx
  8013aa:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8013b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b5:	e9 f7 00 00 00       	jmp    8014b1 <spawn+0x3bb>
		if (i >= filesz) {
  8013ba:	39 df                	cmp    %ebx,%edi
  8013bc:	77 27                	ja     8013e5 <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8013be:	83 ec 04             	sub    $0x4,%esp
  8013c1:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8013c7:	56                   	push   %esi
  8013c8:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8013ce:	e8 5e f8 ff ff       	call   800c31 <sys_page_alloc>
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	0f 89 c7 00 00 00    	jns    8014a5 <spawn+0x3af>
  8013de:	89 c3                	mov    %eax,%ebx
  8013e0:	e9 97 01 00 00       	jmp    80157c <spawn+0x486>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8013e5:	83 ec 04             	sub    $0x4,%esp
  8013e8:	6a 07                	push   $0x7
  8013ea:	68 00 00 40 00       	push   $0x400000
  8013ef:	6a 00                	push   $0x0
  8013f1:	e8 3b f8 ff ff       	call   800c31 <sys_page_alloc>
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	0f 88 71 01 00 00    	js     801572 <spawn+0x47c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80140a:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801410:	50                   	push   %eax
  801411:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801417:	e8 43 07 00 00       	call   801b5f <seek>
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	0f 88 4f 01 00 00    	js     801576 <spawn+0x480>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801427:	83 ec 04             	sub    $0x4,%esp
  80142a:	89 f8                	mov    %edi,%eax
  80142c:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801432:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801437:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80143c:	0f 47 c1             	cmova  %ecx,%eax
  80143f:	50                   	push   %eax
  801440:	68 00 00 40 00       	push   $0x400000
  801445:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80144b:	e8 3a 06 00 00       	call   801a8a <readn>
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	0f 88 1f 01 00 00    	js     80157a <spawn+0x484>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801464:	56                   	push   %esi
  801465:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80146b:	68 00 00 40 00       	push   $0x400000
  801470:	6a 00                	push   $0x0
  801472:	e8 fd f7 ff ff       	call   800c74 <sys_page_map>
  801477:	83 c4 20             	add    $0x20,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	79 15                	jns    801493 <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  80147e:	50                   	push   %eax
  80147f:	68 82 2d 80 00       	push   $0x802d82
  801484:	68 24 01 00 00       	push   $0x124
  801489:	68 76 2d 80 00       	push   $0x802d76
  80148e:	e8 3d ed ff ff       	call   8001d0 <_panic>
			sys_page_unmap(0, UTEMP);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	68 00 00 40 00       	push   $0x400000
  80149b:	6a 00                	push   $0x0
  80149d:	e8 14 f8 ff ff       	call   800cb6 <sys_page_unmap>
  8014a2:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8014a5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8014ab:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8014b1:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8014b7:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8014bd:	0f 87 f7 fe ff ff    	ja     8013ba <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8014c3:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8014ca:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8014d1:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8014d8:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8014de:	0f 8c 67 fe ff ff    	jl     80134b <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8014ed:	e8 cb 03 00 00       	call   8018bd <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8014f2:	83 c4 08             	add    $0x8,%esp
  8014f5:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8014fb:	50                   	push   %eax
  8014fc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801502:	e8 33 f8 ff ff       	call   800d3a <sys_env_set_trapframe>
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	79 15                	jns    801523 <spawn+0x42d>
		panic("sys_env_set_trapframe: %e", r);
  80150e:	50                   	push   %eax
  80150f:	68 9f 2d 80 00       	push   $0x802d9f
  801514:	68 85 00 00 00       	push   $0x85
  801519:	68 76 2d 80 00       	push   $0x802d76
  80151e:	e8 ad ec ff ff       	call   8001d0 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	6a 02                	push   $0x2
  801528:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80152e:	e8 c5 f7 ff ff       	call   800cf8 <sys_env_set_status>
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	79 25                	jns    80155f <spawn+0x469>
		panic("sys_env_set_status: %e", r);
  80153a:	50                   	push   %eax
  80153b:	68 1a 2d 80 00       	push   $0x802d1a
  801540:	68 88 00 00 00       	push   $0x88
  801545:	68 76 2d 80 00       	push   $0x802d76
  80154a:	e8 81 ec ff ff       	call   8001d0 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80154f:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801555:	eb 58                	jmp    8015af <spawn+0x4b9>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801557:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80155d:	eb 50                	jmp    8015af <spawn+0x4b9>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80155f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801565:	eb 48                	jmp    8015af <spawn+0x4b9>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801567:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80156c:	eb 41                	jmp    8015af <spawn+0x4b9>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80156e:	89 c3                	mov    %eax,%ebx
  801570:	eb 3d                	jmp    8015af <spawn+0x4b9>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801572:	89 c3                	mov    %eax,%ebx
  801574:	eb 06                	jmp    80157c <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801576:	89 c3                	mov    %eax,%ebx
  801578:	eb 02                	jmp    80157c <spawn+0x486>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80157a:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801585:	e8 28 f6 ff ff       	call   800bb2 <sys_env_destroy>
	close(fd);
  80158a:	83 c4 04             	add    $0x4,%esp
  80158d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801593:	e8 25 03 00 00       	call   8018bd <close>
	return r;
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	eb 12                	jmp    8015af <spawn+0x4b9>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	68 00 00 40 00       	push   $0x400000
  8015a5:	6a 00                	push   $0x0
  8015a7:	e8 0a f7 ff ff       	call   800cb6 <sys_page_unmap>
  8015ac:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8015af:	89 d8                	mov    %ebx,%eax
  8015b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5e                   	pop    %esi
  8015b6:	5f                   	pop    %edi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    

008015b9 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	56                   	push   %esi
  8015bd:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8015be:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8015c1:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8015c6:	eb 03                	jmp    8015cb <spawnl+0x12>
		argc++;
  8015c8:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8015cb:	83 c2 04             	add    $0x4,%edx
  8015ce:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8015d2:	75 f4                	jne    8015c8 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8015d4:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8015db:	83 e2 f0             	and    $0xfffffff0,%edx
  8015de:	29 d4                	sub    %edx,%esp
  8015e0:	8d 54 24 03          	lea    0x3(%esp),%edx
  8015e4:	c1 ea 02             	shr    $0x2,%edx
  8015e7:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8015ee:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8015f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015f3:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8015fa:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801601:	00 
  801602:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801604:	b8 00 00 00 00       	mov    $0x0,%eax
  801609:	eb 0a                	jmp    801615 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  80160b:	83 c0 01             	add    $0x1,%eax
  80160e:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801612:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801615:	39 d0                	cmp    %edx,%eax
  801617:	75 f2                	jne    80160b <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	56                   	push   %esi
  80161d:	ff 75 08             	pushl  0x8(%ebp)
  801620:	e8 d1 fa ff ff       	call   8010f6 <spawn>
}
  801625:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801628:	5b                   	pop    %ebx
  801629:	5e                   	pop    %esi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    

0080162c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	56                   	push   %esi
  801630:	53                   	push   %ebx
  801631:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801634:	85 f6                	test   %esi,%esi
  801636:	75 16                	jne    80164e <wait+0x22>
  801638:	68 e2 2d 80 00       	push   $0x802de2
  80163d:	68 61 2d 80 00       	push   $0x802d61
  801642:	6a 09                	push   $0x9
  801644:	68 ed 2d 80 00       	push   $0x802ded
  801649:	e8 82 eb ff ff       	call   8001d0 <_panic>
	e = &envs[ENVX(envid)];
  80164e:	89 f3                	mov    %esi,%ebx
  801650:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801656:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801659:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80165f:	eb 05                	jmp    801666 <wait+0x3a>
		sys_yield();
  801661:	e8 ac f5 ff ff       	call   800c12 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801666:	8b 43 48             	mov    0x48(%ebx),%eax
  801669:	39 c6                	cmp    %eax,%esi
  80166b:	75 07                	jne    801674 <wait+0x48>
  80166d:	8b 43 54             	mov    0x54(%ebx),%eax
  801670:	85 c0                	test   %eax,%eax
  801672:	75 ed                	jne    801661 <wait+0x35>
		sys_yield();
}
  801674:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801677:	5b                   	pop    %ebx
  801678:	5e                   	pop    %esi
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801681:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801688:	75 64                	jne    8016ee <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80168a:	a1 04 40 80 00       	mov    0x804004,%eax
  80168f:	8b 40 48             	mov    0x48(%eax),%eax
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	6a 07                	push   $0x7
  801697:	68 00 f0 bf ee       	push   $0xeebff000
  80169c:	50                   	push   %eax
  80169d:	e8 8f f5 ff ff       	call   800c31 <sys_page_alloc>
		if ( r != 0)
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	74 14                	je     8016bd <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  8016a9:	83 ec 04             	sub    $0x4,%esp
  8016ac:	68 f8 2d 80 00       	push   $0x802df8
  8016b1:	6a 24                	push   $0x24
  8016b3:	68 46 2e 80 00       	push   $0x802e46
  8016b8:	e8 13 eb ff ff       	call   8001d0 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  8016bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c2:	8b 40 48             	mov    0x48(%eax),%eax
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	68 f8 16 80 00       	push   $0x8016f8
  8016cd:	50                   	push   %eax
  8016ce:	e8 a9 f6 ff ff       	call   800d7c <sys_env_set_pgfault_upcall>
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	79 14                	jns    8016ee <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  8016da:	83 ec 04             	sub    $0x4,%esp
  8016dd:	68 24 2e 80 00       	push   $0x802e24
  8016e2:	6a 27                	push   $0x27
  8016e4:	68 46 2e 80 00       	push   $0x802e46
  8016e9:	e8 e2 ea ff ff       	call   8001d0 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	a3 08 40 80 00       	mov    %eax,0x804008
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8016f8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8016f9:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  8016fe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801700:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  801703:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  801707:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  801709:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  80170d:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  80170e:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  801711:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  801713:	83 c4 08             	add    $0x8,%esp
popal
  801716:	61                   	popa   
addl $0x4, %esp
  801717:	83 c4 04             	add    $0x4,%esp
popfl
  80171a:	9d                   	popf   
popl %esp
  80171b:	5c                   	pop    %esp
ret
  80171c:	c3                   	ret    

0080171d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	05 00 00 00 30       	add    $0x30000000,%eax
  801728:	c1 e8 0c             	shr    $0xc,%eax
}
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801730:	8b 45 08             	mov    0x8(%ebp),%eax
  801733:	05 00 00 00 30       	add    $0x30000000,%eax
  801738:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80173d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80174a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80174f:	89 c2                	mov    %eax,%edx
  801751:	c1 ea 16             	shr    $0x16,%edx
  801754:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80175b:	f6 c2 01             	test   $0x1,%dl
  80175e:	74 11                	je     801771 <fd_alloc+0x2d>
  801760:	89 c2                	mov    %eax,%edx
  801762:	c1 ea 0c             	shr    $0xc,%edx
  801765:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80176c:	f6 c2 01             	test   $0x1,%dl
  80176f:	75 09                	jne    80177a <fd_alloc+0x36>
			*fd_store = fd;
  801771:	89 01                	mov    %eax,(%ecx)
			return 0;
  801773:	b8 00 00 00 00       	mov    $0x0,%eax
  801778:	eb 17                	jmp    801791 <fd_alloc+0x4d>
  80177a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80177f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801784:	75 c9                	jne    80174f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801786:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80178c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801799:	83 f8 1f             	cmp    $0x1f,%eax
  80179c:	77 36                	ja     8017d4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80179e:	c1 e0 0c             	shl    $0xc,%eax
  8017a1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017a6:	89 c2                	mov    %eax,%edx
  8017a8:	c1 ea 16             	shr    $0x16,%edx
  8017ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017b2:	f6 c2 01             	test   $0x1,%dl
  8017b5:	74 24                	je     8017db <fd_lookup+0x48>
  8017b7:	89 c2                	mov    %eax,%edx
  8017b9:	c1 ea 0c             	shr    $0xc,%edx
  8017bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017c3:	f6 c2 01             	test   $0x1,%dl
  8017c6:	74 1a                	je     8017e2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017cb:	89 02                	mov    %eax,(%edx)
	return 0;
  8017cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d2:	eb 13                	jmp    8017e7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d9:	eb 0c                	jmp    8017e7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e0:	eb 05                	jmp    8017e7 <fd_lookup+0x54>
  8017e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f2:	ba d0 2e 80 00       	mov    $0x802ed0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8017f7:	eb 13                	jmp    80180c <dev_lookup+0x23>
  8017f9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8017fc:	39 08                	cmp    %ecx,(%eax)
  8017fe:	75 0c                	jne    80180c <dev_lookup+0x23>
			*dev = devtab[i];
  801800:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801803:	89 01                	mov    %eax,(%ecx)
			return 0;
  801805:	b8 00 00 00 00       	mov    $0x0,%eax
  80180a:	eb 2e                	jmp    80183a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80180c:	8b 02                	mov    (%edx),%eax
  80180e:	85 c0                	test   %eax,%eax
  801810:	75 e7                	jne    8017f9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801812:	a1 04 40 80 00       	mov    0x804004,%eax
  801817:	8b 40 48             	mov    0x48(%eax),%eax
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	51                   	push   %ecx
  80181e:	50                   	push   %eax
  80181f:	68 54 2e 80 00       	push   $0x802e54
  801824:	e8 80 ea ff ff       	call   8002a9 <cprintf>
	*dev = 0;
  801829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	56                   	push   %esi
  801840:	53                   	push   %ebx
  801841:	83 ec 10             	sub    $0x10,%esp
  801844:	8b 75 08             	mov    0x8(%ebp),%esi
  801847:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80184a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184d:	50                   	push   %eax
  80184e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801854:	c1 e8 0c             	shr    $0xc,%eax
  801857:	50                   	push   %eax
  801858:	e8 36 ff ff ff       	call   801793 <fd_lookup>
  80185d:	83 c4 08             	add    $0x8,%esp
  801860:	85 c0                	test   %eax,%eax
  801862:	78 05                	js     801869 <fd_close+0x2d>
	    || fd != fd2)
  801864:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801867:	74 0c                	je     801875 <fd_close+0x39>
		return (must_exist ? r : 0);
  801869:	84 db                	test   %bl,%bl
  80186b:	ba 00 00 00 00       	mov    $0x0,%edx
  801870:	0f 44 c2             	cmove  %edx,%eax
  801873:	eb 41                	jmp    8018b6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187b:	50                   	push   %eax
  80187c:	ff 36                	pushl  (%esi)
  80187e:	e8 66 ff ff ff       	call   8017e9 <dev_lookup>
  801883:	89 c3                	mov    %eax,%ebx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 1a                	js     8018a6 <fd_close+0x6a>
		if (dev->dev_close)
  80188c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801892:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801897:	85 c0                	test   %eax,%eax
  801899:	74 0b                	je     8018a6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80189b:	83 ec 0c             	sub    $0xc,%esp
  80189e:	56                   	push   %esi
  80189f:	ff d0                	call   *%eax
  8018a1:	89 c3                	mov    %eax,%ebx
  8018a3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	56                   	push   %esi
  8018aa:	6a 00                	push   $0x0
  8018ac:	e8 05 f4 ff ff       	call   800cb6 <sys_page_unmap>
	return r;
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	89 d8                	mov    %ebx,%eax
}
  8018b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5e                   	pop    %esi
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    

008018bd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c6:	50                   	push   %eax
  8018c7:	ff 75 08             	pushl  0x8(%ebp)
  8018ca:	e8 c4 fe ff ff       	call   801793 <fd_lookup>
  8018cf:	83 c4 08             	add    $0x8,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 10                	js     8018e6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	6a 01                	push   $0x1
  8018db:	ff 75 f4             	pushl  -0xc(%ebp)
  8018de:	e8 59 ff ff ff       	call   80183c <fd_close>
  8018e3:	83 c4 10             	add    $0x10,%esp
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <close_all>:

void
close_all(void)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8018ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8018f4:	83 ec 0c             	sub    $0xc,%esp
  8018f7:	53                   	push   %ebx
  8018f8:	e8 c0 ff ff ff       	call   8018bd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018fd:	83 c3 01             	add    $0x1,%ebx
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	83 fb 20             	cmp    $0x20,%ebx
  801906:	75 ec                	jne    8018f4 <close_all+0xc>
		close(i);
}
  801908:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190b:	c9                   	leave  
  80190c:	c3                   	ret    

0080190d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	57                   	push   %edi
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	83 ec 2c             	sub    $0x2c,%esp
  801916:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801919:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80191c:	50                   	push   %eax
  80191d:	ff 75 08             	pushl  0x8(%ebp)
  801920:	e8 6e fe ff ff       	call   801793 <fd_lookup>
  801925:	83 c4 08             	add    $0x8,%esp
  801928:	85 c0                	test   %eax,%eax
  80192a:	0f 88 c1 00 00 00    	js     8019f1 <dup+0xe4>
		return r;
	close(newfdnum);
  801930:	83 ec 0c             	sub    $0xc,%esp
  801933:	56                   	push   %esi
  801934:	e8 84 ff ff ff       	call   8018bd <close>

	newfd = INDEX2FD(newfdnum);
  801939:	89 f3                	mov    %esi,%ebx
  80193b:	c1 e3 0c             	shl    $0xc,%ebx
  80193e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801944:	83 c4 04             	add    $0x4,%esp
  801947:	ff 75 e4             	pushl  -0x1c(%ebp)
  80194a:	e8 de fd ff ff       	call   80172d <fd2data>
  80194f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801951:	89 1c 24             	mov    %ebx,(%esp)
  801954:	e8 d4 fd ff ff       	call   80172d <fd2data>
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80195f:	89 f8                	mov    %edi,%eax
  801961:	c1 e8 16             	shr    $0x16,%eax
  801964:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80196b:	a8 01                	test   $0x1,%al
  80196d:	74 37                	je     8019a6 <dup+0x99>
  80196f:	89 f8                	mov    %edi,%eax
  801971:	c1 e8 0c             	shr    $0xc,%eax
  801974:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80197b:	f6 c2 01             	test   $0x1,%dl
  80197e:	74 26                	je     8019a6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801980:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	25 07 0e 00 00       	and    $0xe07,%eax
  80198f:	50                   	push   %eax
  801990:	ff 75 d4             	pushl  -0x2c(%ebp)
  801993:	6a 00                	push   $0x0
  801995:	57                   	push   %edi
  801996:	6a 00                	push   $0x0
  801998:	e8 d7 f2 ff ff       	call   800c74 <sys_page_map>
  80199d:	89 c7                	mov    %eax,%edi
  80199f:	83 c4 20             	add    $0x20,%esp
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	78 2e                	js     8019d4 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019a9:	89 d0                	mov    %edx,%eax
  8019ab:	c1 e8 0c             	shr    $0xc,%eax
  8019ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019b5:	83 ec 0c             	sub    $0xc,%esp
  8019b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8019bd:	50                   	push   %eax
  8019be:	53                   	push   %ebx
  8019bf:	6a 00                	push   $0x0
  8019c1:	52                   	push   %edx
  8019c2:	6a 00                	push   $0x0
  8019c4:	e8 ab f2 ff ff       	call   800c74 <sys_page_map>
  8019c9:	89 c7                	mov    %eax,%edi
  8019cb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8019ce:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019d0:	85 ff                	test   %edi,%edi
  8019d2:	79 1d                	jns    8019f1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8019d4:	83 ec 08             	sub    $0x8,%esp
  8019d7:	53                   	push   %ebx
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 d7 f2 ff ff       	call   800cb6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8019df:	83 c4 08             	add    $0x8,%esp
  8019e2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8019e5:	6a 00                	push   $0x0
  8019e7:	e8 ca f2 ff ff       	call   800cb6 <sys_page_unmap>
	return r;
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	89 f8                	mov    %edi,%eax
}
  8019f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5f                   	pop    %edi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 14             	sub    $0x14,%esp
  801a00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a03:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a06:	50                   	push   %eax
  801a07:	53                   	push   %ebx
  801a08:	e8 86 fd ff ff       	call   801793 <fd_lookup>
  801a0d:	83 c4 08             	add    $0x8,%esp
  801a10:	89 c2                	mov    %eax,%edx
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 6d                	js     801a83 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a16:	83 ec 08             	sub    $0x8,%esp
  801a19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1c:	50                   	push   %eax
  801a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a20:	ff 30                	pushl  (%eax)
  801a22:	e8 c2 fd ff ff       	call   8017e9 <dev_lookup>
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 4c                	js     801a7a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a31:	8b 42 08             	mov    0x8(%edx),%eax
  801a34:	83 e0 03             	and    $0x3,%eax
  801a37:	83 f8 01             	cmp    $0x1,%eax
  801a3a:	75 21                	jne    801a5d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a3c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a41:	8b 40 48             	mov    0x48(%eax),%eax
  801a44:	83 ec 04             	sub    $0x4,%esp
  801a47:	53                   	push   %ebx
  801a48:	50                   	push   %eax
  801a49:	68 95 2e 80 00       	push   $0x802e95
  801a4e:	e8 56 e8 ff ff       	call   8002a9 <cprintf>
		return -E_INVAL;
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a5b:	eb 26                	jmp    801a83 <read+0x8a>
	}
	if (!dev->dev_read)
  801a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a60:	8b 40 08             	mov    0x8(%eax),%eax
  801a63:	85 c0                	test   %eax,%eax
  801a65:	74 17                	je     801a7e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a67:	83 ec 04             	sub    $0x4,%esp
  801a6a:	ff 75 10             	pushl  0x10(%ebp)
  801a6d:	ff 75 0c             	pushl  0xc(%ebp)
  801a70:	52                   	push   %edx
  801a71:	ff d0                	call   *%eax
  801a73:	89 c2                	mov    %eax,%edx
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	eb 09                	jmp    801a83 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a7a:	89 c2                	mov    %eax,%edx
  801a7c:	eb 05                	jmp    801a83 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a7e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801a83:	89 d0                	mov    %edx,%eax
  801a85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	57                   	push   %edi
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a96:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a99:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a9e:	eb 21                	jmp    801ac1 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801aa0:	83 ec 04             	sub    $0x4,%esp
  801aa3:	89 f0                	mov    %esi,%eax
  801aa5:	29 d8                	sub    %ebx,%eax
  801aa7:	50                   	push   %eax
  801aa8:	89 d8                	mov    %ebx,%eax
  801aaa:	03 45 0c             	add    0xc(%ebp),%eax
  801aad:	50                   	push   %eax
  801aae:	57                   	push   %edi
  801aaf:	e8 45 ff ff ff       	call   8019f9 <read>
		if (m < 0)
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 10                	js     801acb <readn+0x41>
			return m;
		if (m == 0)
  801abb:	85 c0                	test   %eax,%eax
  801abd:	74 0a                	je     801ac9 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801abf:	01 c3                	add    %eax,%ebx
  801ac1:	39 f3                	cmp    %esi,%ebx
  801ac3:	72 db                	jb     801aa0 <readn+0x16>
  801ac5:	89 d8                	mov    %ebx,%eax
  801ac7:	eb 02                	jmp    801acb <readn+0x41>
  801ac9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5f                   	pop    %edi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 14             	sub    $0x14,%esp
  801ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801add:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ae0:	50                   	push   %eax
  801ae1:	53                   	push   %ebx
  801ae2:	e8 ac fc ff ff       	call   801793 <fd_lookup>
  801ae7:	83 c4 08             	add    $0x8,%esp
  801aea:	89 c2                	mov    %eax,%edx
  801aec:	85 c0                	test   %eax,%eax
  801aee:	78 68                	js     801b58 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801af0:	83 ec 08             	sub    $0x8,%esp
  801af3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af6:	50                   	push   %eax
  801af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801afa:	ff 30                	pushl  (%eax)
  801afc:	e8 e8 fc ff ff       	call   8017e9 <dev_lookup>
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 47                	js     801b4f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b0b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b0f:	75 21                	jne    801b32 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b11:	a1 04 40 80 00       	mov    0x804004,%eax
  801b16:	8b 40 48             	mov    0x48(%eax),%eax
  801b19:	83 ec 04             	sub    $0x4,%esp
  801b1c:	53                   	push   %ebx
  801b1d:	50                   	push   %eax
  801b1e:	68 b1 2e 80 00       	push   $0x802eb1
  801b23:	e8 81 e7 ff ff       	call   8002a9 <cprintf>
		return -E_INVAL;
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b30:	eb 26                	jmp    801b58 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b35:	8b 52 0c             	mov    0xc(%edx),%edx
  801b38:	85 d2                	test   %edx,%edx
  801b3a:	74 17                	je     801b53 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b3c:	83 ec 04             	sub    $0x4,%esp
  801b3f:	ff 75 10             	pushl  0x10(%ebp)
  801b42:	ff 75 0c             	pushl  0xc(%ebp)
  801b45:	50                   	push   %eax
  801b46:	ff d2                	call   *%edx
  801b48:	89 c2                	mov    %eax,%edx
  801b4a:	83 c4 10             	add    $0x10,%esp
  801b4d:	eb 09                	jmp    801b58 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b4f:	89 c2                	mov    %eax,%edx
  801b51:	eb 05                	jmp    801b58 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b53:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801b58:	89 d0                	mov    %edx,%eax
  801b5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <seek>:

int
seek(int fdnum, off_t offset)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b65:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b68:	50                   	push   %eax
  801b69:	ff 75 08             	pushl  0x8(%ebp)
  801b6c:	e8 22 fc ff ff       	call   801793 <fd_lookup>
  801b71:	83 c4 08             	add    $0x8,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	78 0e                	js     801b86 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801b78:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b7e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 14             	sub    $0x14,%esp
  801b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b95:	50                   	push   %eax
  801b96:	53                   	push   %ebx
  801b97:	e8 f7 fb ff ff       	call   801793 <fd_lookup>
  801b9c:	83 c4 08             	add    $0x8,%esp
  801b9f:	89 c2                	mov    %eax,%edx
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 65                	js     801c0a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ba5:	83 ec 08             	sub    $0x8,%esp
  801ba8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bab:	50                   	push   %eax
  801bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801baf:	ff 30                	pushl  (%eax)
  801bb1:	e8 33 fc ff ff       	call   8017e9 <dev_lookup>
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	78 44                	js     801c01 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801bc4:	75 21                	jne    801be7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801bc6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801bcb:	8b 40 48             	mov    0x48(%eax),%eax
  801bce:	83 ec 04             	sub    $0x4,%esp
  801bd1:	53                   	push   %ebx
  801bd2:	50                   	push   %eax
  801bd3:	68 74 2e 80 00       	push   $0x802e74
  801bd8:	e8 cc e6 ff ff       	call   8002a9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801be5:	eb 23                	jmp    801c0a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801be7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bea:	8b 52 18             	mov    0x18(%edx),%edx
  801bed:	85 d2                	test   %edx,%edx
  801bef:	74 14                	je     801c05 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801bf1:	83 ec 08             	sub    $0x8,%esp
  801bf4:	ff 75 0c             	pushl  0xc(%ebp)
  801bf7:	50                   	push   %eax
  801bf8:	ff d2                	call   *%edx
  801bfa:	89 c2                	mov    %eax,%edx
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	eb 09                	jmp    801c0a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	eb 05                	jmp    801c0a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c05:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801c0a:	89 d0                	mov    %edx,%eax
  801c0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    

00801c11 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	53                   	push   %ebx
  801c15:	83 ec 14             	sub    $0x14,%esp
  801c18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1e:	50                   	push   %eax
  801c1f:	ff 75 08             	pushl  0x8(%ebp)
  801c22:	e8 6c fb ff ff       	call   801793 <fd_lookup>
  801c27:	83 c4 08             	add    $0x8,%esp
  801c2a:	89 c2                	mov    %eax,%edx
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	78 58                	js     801c88 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c30:	83 ec 08             	sub    $0x8,%esp
  801c33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c36:	50                   	push   %eax
  801c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c3a:	ff 30                	pushl  (%eax)
  801c3c:	e8 a8 fb ff ff       	call   8017e9 <dev_lookup>
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	85 c0                	test   %eax,%eax
  801c46:	78 37                	js     801c7f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c4f:	74 32                	je     801c83 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c51:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c54:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c5b:	00 00 00 
	stat->st_isdir = 0;
  801c5e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c65:	00 00 00 
	stat->st_dev = dev;
  801c68:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c6e:	83 ec 08             	sub    $0x8,%esp
  801c71:	53                   	push   %ebx
  801c72:	ff 75 f0             	pushl  -0x10(%ebp)
  801c75:	ff 50 14             	call   *0x14(%eax)
  801c78:	89 c2                	mov    %eax,%edx
  801c7a:	83 c4 10             	add    $0x10,%esp
  801c7d:	eb 09                	jmp    801c88 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c7f:	89 c2                	mov    %eax,%edx
  801c81:	eb 05                	jmp    801c88 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c83:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c88:	89 d0                	mov    %edx,%eax
  801c8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c94:	83 ec 08             	sub    $0x8,%esp
  801c97:	6a 00                	push   $0x0
  801c99:	ff 75 08             	pushl  0x8(%ebp)
  801c9c:	e8 b7 01 00 00       	call   801e58 <open>
  801ca1:	89 c3                	mov    %eax,%ebx
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	78 1b                	js     801cc5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801caa:	83 ec 08             	sub    $0x8,%esp
  801cad:	ff 75 0c             	pushl  0xc(%ebp)
  801cb0:	50                   	push   %eax
  801cb1:	e8 5b ff ff ff       	call   801c11 <fstat>
  801cb6:	89 c6                	mov    %eax,%esi
	close(fd);
  801cb8:	89 1c 24             	mov    %ebx,(%esp)
  801cbb:	e8 fd fb ff ff       	call   8018bd <close>
	return r;
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	89 f0                	mov    %esi,%eax
}
  801cc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5e                   	pop    %esi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	56                   	push   %esi
  801cd0:	53                   	push   %ebx
  801cd1:	89 c6                	mov    %eax,%esi
  801cd3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801cd5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801cdc:	75 12                	jne    801cf0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cde:	83 ec 0c             	sub    $0xc,%esp
  801ce1:	6a 01                	push   $0x1
  801ce3:	e8 f4 07 00 00       	call   8024dc <ipc_find_env>
  801ce8:	a3 00 40 80 00       	mov    %eax,0x804000
  801ced:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cf0:	6a 07                	push   $0x7
  801cf2:	68 00 50 80 00       	push   $0x805000
  801cf7:	56                   	push   %esi
  801cf8:	ff 35 00 40 80 00    	pushl  0x804000
  801cfe:	e8 4d 07 00 00       	call   802450 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d03:	83 c4 0c             	add    $0xc,%esp
  801d06:	6a 00                	push   $0x0
  801d08:	53                   	push   %ebx
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 cb 06 00 00       	call   8023db <ipc_recv>
}
  801d10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    

00801d17 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	8b 40 0c             	mov    0xc(%eax),%eax
  801d23:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801d28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d30:	ba 00 00 00 00       	mov    $0x0,%edx
  801d35:	b8 02 00 00 00       	mov    $0x2,%eax
  801d3a:	e8 8d ff ff ff       	call   801ccc <fsipc>
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d4d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d52:	ba 00 00 00 00       	mov    $0x0,%edx
  801d57:	b8 06 00 00 00       	mov    $0x6,%eax
  801d5c:	e8 6b ff ff ff       	call   801ccc <fsipc>
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    

00801d63 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	53                   	push   %ebx
  801d67:	83 ec 04             	sub    $0x4,%esp
  801d6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d70:	8b 40 0c             	mov    0xc(%eax),%eax
  801d73:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d78:	ba 00 00 00 00       	mov    $0x0,%edx
  801d7d:	b8 05 00 00 00       	mov    $0x5,%eax
  801d82:	e8 45 ff ff ff       	call   801ccc <fsipc>
  801d87:	85 c0                	test   %eax,%eax
  801d89:	78 2c                	js     801db7 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d8b:	83 ec 08             	sub    $0x8,%esp
  801d8e:	68 00 50 80 00       	push   $0x805000
  801d93:	53                   	push   %ebx
  801d94:	e8 95 ea ff ff       	call   80082e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d99:	a1 80 50 80 00       	mov    0x805080,%eax
  801d9e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801da4:	a1 84 50 80 00       	mov    0x805084,%eax
  801da9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dba:	c9                   	leave  
  801dbb:	c3                   	ret    

00801dbc <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801dc2:	68 e0 2e 80 00       	push   $0x802ee0
  801dc7:	68 90 00 00 00       	push   $0x90
  801dcc:	68 fe 2e 80 00       	push   $0x802efe
  801dd1:	e8 fa e3 ff ff       	call   8001d0 <_panic>

00801dd6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dde:	8b 45 08             	mov    0x8(%ebp),%eax
  801de1:	8b 40 0c             	mov    0xc(%eax),%eax
  801de4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801de9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801def:	ba 00 00 00 00       	mov    $0x0,%edx
  801df4:	b8 03 00 00 00       	mov    $0x3,%eax
  801df9:	e8 ce fe ff ff       	call   801ccc <fsipc>
  801dfe:	89 c3                	mov    %eax,%ebx
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 4b                	js     801e4f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801e04:	39 c6                	cmp    %eax,%esi
  801e06:	73 16                	jae    801e1e <devfile_read+0x48>
  801e08:	68 09 2f 80 00       	push   $0x802f09
  801e0d:	68 61 2d 80 00       	push   $0x802d61
  801e12:	6a 7c                	push   $0x7c
  801e14:	68 fe 2e 80 00       	push   $0x802efe
  801e19:	e8 b2 e3 ff ff       	call   8001d0 <_panic>
	assert(r <= PGSIZE);
  801e1e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e23:	7e 16                	jle    801e3b <devfile_read+0x65>
  801e25:	68 10 2f 80 00       	push   $0x802f10
  801e2a:	68 61 2d 80 00       	push   $0x802d61
  801e2f:	6a 7d                	push   $0x7d
  801e31:	68 fe 2e 80 00       	push   $0x802efe
  801e36:	e8 95 e3 ff ff       	call   8001d0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e3b:	83 ec 04             	sub    $0x4,%esp
  801e3e:	50                   	push   %eax
  801e3f:	68 00 50 80 00       	push   $0x805000
  801e44:	ff 75 0c             	pushl  0xc(%ebp)
  801e47:	e8 74 eb ff ff       	call   8009c0 <memmove>
	return r;
  801e4c:	83 c4 10             	add    $0x10,%esp
}
  801e4f:	89 d8                	mov    %ebx,%eax
  801e51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	53                   	push   %ebx
  801e5c:	83 ec 20             	sub    $0x20,%esp
  801e5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e62:	53                   	push   %ebx
  801e63:	e8 8d e9 ff ff       	call   8007f5 <strlen>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e70:	7f 67                	jg     801ed9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e72:	83 ec 0c             	sub    $0xc,%esp
  801e75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	e8 c6 f8 ff ff       	call   801744 <fd_alloc>
  801e7e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e81:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 57                	js     801ede <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e87:	83 ec 08             	sub    $0x8,%esp
  801e8a:	53                   	push   %ebx
  801e8b:	68 00 50 80 00       	push   $0x805000
  801e90:	e8 99 e9 ff ff       	call   80082e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e98:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ea0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea5:	e8 22 fe ff ff       	call   801ccc <fsipc>
  801eaa:	89 c3                	mov    %eax,%ebx
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	79 14                	jns    801ec7 <open+0x6f>
		fd_close(fd, 0);
  801eb3:	83 ec 08             	sub    $0x8,%esp
  801eb6:	6a 00                	push   $0x0
  801eb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ebb:	e8 7c f9 ff ff       	call   80183c <fd_close>
		return r;
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	89 da                	mov    %ebx,%edx
  801ec5:	eb 17                	jmp    801ede <open+0x86>
	}

	return fd2num(fd);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecd:	e8 4b f8 ff ff       	call   80171d <fd2num>
  801ed2:	89 c2                	mov    %eax,%edx
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	eb 05                	jmp    801ede <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ed9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ede:	89 d0                	mov    %edx,%eax
  801ee0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801eeb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ef5:	e8 d2 fd ff ff       	call   801ccc <fsipc>
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f04:	83 ec 0c             	sub    $0xc,%esp
  801f07:	ff 75 08             	pushl  0x8(%ebp)
  801f0a:	e8 1e f8 ff ff       	call   80172d <fd2data>
  801f0f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f11:	83 c4 08             	add    $0x8,%esp
  801f14:	68 1c 2f 80 00       	push   $0x802f1c
  801f19:	53                   	push   %ebx
  801f1a:	e8 0f e9 ff ff       	call   80082e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f1f:	8b 46 04             	mov    0x4(%esi),%eax
  801f22:	2b 06                	sub    (%esi),%eax
  801f24:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f2a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f31:	00 00 00 
	stat->st_dev = &devpipe;
  801f34:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f3b:	30 80 00 
	return 0;
}
  801f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    

00801f4a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	53                   	push   %ebx
  801f4e:	83 ec 0c             	sub    $0xc,%esp
  801f51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f54:	53                   	push   %ebx
  801f55:	6a 00                	push   $0x0
  801f57:	e8 5a ed ff ff       	call   800cb6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f5c:	89 1c 24             	mov    %ebx,(%esp)
  801f5f:	e8 c9 f7 ff ff       	call   80172d <fd2data>
  801f64:	83 c4 08             	add    $0x8,%esp
  801f67:	50                   	push   %eax
  801f68:	6a 00                	push   $0x0
  801f6a:	e8 47 ed ff ff       	call   800cb6 <sys_page_unmap>
}
  801f6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f72:	c9                   	leave  
  801f73:	c3                   	ret    

00801f74 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	57                   	push   %edi
  801f78:	56                   	push   %esi
  801f79:	53                   	push   %ebx
  801f7a:	83 ec 1c             	sub    $0x1c,%esp
  801f7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f80:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f82:	a1 04 40 80 00       	mov    0x804004,%eax
  801f87:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f8a:	83 ec 0c             	sub    $0xc,%esp
  801f8d:	ff 75 e0             	pushl  -0x20(%ebp)
  801f90:	e8 80 05 00 00       	call   802515 <pageref>
  801f95:	89 c3                	mov    %eax,%ebx
  801f97:	89 3c 24             	mov    %edi,(%esp)
  801f9a:	e8 76 05 00 00       	call   802515 <pageref>
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	39 c3                	cmp    %eax,%ebx
  801fa4:	0f 94 c1             	sete   %cl
  801fa7:	0f b6 c9             	movzbl %cl,%ecx
  801faa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fad:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801fb3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fb6:	39 ce                	cmp    %ecx,%esi
  801fb8:	74 1b                	je     801fd5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fba:	39 c3                	cmp    %eax,%ebx
  801fbc:	75 c4                	jne    801f82 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fbe:	8b 42 58             	mov    0x58(%edx),%eax
  801fc1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fc4:	50                   	push   %eax
  801fc5:	56                   	push   %esi
  801fc6:	68 23 2f 80 00       	push   $0x802f23
  801fcb:	e8 d9 e2 ff ff       	call   8002a9 <cprintf>
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	eb ad                	jmp    801f82 <_pipeisclosed+0xe>
	}
}
  801fd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5e                   	pop    %esi
  801fdd:	5f                   	pop    %edi
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    

00801fe0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	57                   	push   %edi
  801fe4:	56                   	push   %esi
  801fe5:	53                   	push   %ebx
  801fe6:	83 ec 28             	sub    $0x28,%esp
  801fe9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fec:	56                   	push   %esi
  801fed:	e8 3b f7 ff ff       	call   80172d <fd2data>
  801ff2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	bf 00 00 00 00       	mov    $0x0,%edi
  801ffc:	eb 4b                	jmp    802049 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ffe:	89 da                	mov    %ebx,%edx
  802000:	89 f0                	mov    %esi,%eax
  802002:	e8 6d ff ff ff       	call   801f74 <_pipeisclosed>
  802007:	85 c0                	test   %eax,%eax
  802009:	75 48                	jne    802053 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80200b:	e8 02 ec ff ff       	call   800c12 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802010:	8b 43 04             	mov    0x4(%ebx),%eax
  802013:	8b 0b                	mov    (%ebx),%ecx
  802015:	8d 51 20             	lea    0x20(%ecx),%edx
  802018:	39 d0                	cmp    %edx,%eax
  80201a:	73 e2                	jae    801ffe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80201c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80201f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802023:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802026:	89 c2                	mov    %eax,%edx
  802028:	c1 fa 1f             	sar    $0x1f,%edx
  80202b:	89 d1                	mov    %edx,%ecx
  80202d:	c1 e9 1b             	shr    $0x1b,%ecx
  802030:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802033:	83 e2 1f             	and    $0x1f,%edx
  802036:	29 ca                	sub    %ecx,%edx
  802038:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80203c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802040:	83 c0 01             	add    $0x1,%eax
  802043:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802046:	83 c7 01             	add    $0x1,%edi
  802049:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80204c:	75 c2                	jne    802010 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80204e:	8b 45 10             	mov    0x10(%ebp),%eax
  802051:	eb 05                	jmp    802058 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802053:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205b:	5b                   	pop    %ebx
  80205c:	5e                   	pop    %esi
  80205d:	5f                   	pop    %edi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    

00802060 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	57                   	push   %edi
  802064:	56                   	push   %esi
  802065:	53                   	push   %ebx
  802066:	83 ec 18             	sub    $0x18,%esp
  802069:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80206c:	57                   	push   %edi
  80206d:	e8 bb f6 ff ff       	call   80172d <fd2data>
  802072:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	bb 00 00 00 00       	mov    $0x0,%ebx
  80207c:	eb 3d                	jmp    8020bb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80207e:	85 db                	test   %ebx,%ebx
  802080:	74 04                	je     802086 <devpipe_read+0x26>
				return i;
  802082:	89 d8                	mov    %ebx,%eax
  802084:	eb 44                	jmp    8020ca <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802086:	89 f2                	mov    %esi,%edx
  802088:	89 f8                	mov    %edi,%eax
  80208a:	e8 e5 fe ff ff       	call   801f74 <_pipeisclosed>
  80208f:	85 c0                	test   %eax,%eax
  802091:	75 32                	jne    8020c5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802093:	e8 7a eb ff ff       	call   800c12 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802098:	8b 06                	mov    (%esi),%eax
  80209a:	3b 46 04             	cmp    0x4(%esi),%eax
  80209d:	74 df                	je     80207e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80209f:	99                   	cltd   
  8020a0:	c1 ea 1b             	shr    $0x1b,%edx
  8020a3:	01 d0                	add    %edx,%eax
  8020a5:	83 e0 1f             	and    $0x1f,%eax
  8020a8:	29 d0                	sub    %edx,%eax
  8020aa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020b2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020b5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020b8:	83 c3 01             	add    $0x1,%ebx
  8020bb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020be:	75 d8                	jne    802098 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c3:	eb 05                	jmp    8020ca <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020c5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    

008020d2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020d2:	55                   	push   %ebp
  8020d3:	89 e5                	mov    %esp,%ebp
  8020d5:	56                   	push   %esi
  8020d6:	53                   	push   %ebx
  8020d7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020dd:	50                   	push   %eax
  8020de:	e8 61 f6 ff ff       	call   801744 <fd_alloc>
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	89 c2                	mov    %eax,%edx
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	0f 88 2c 01 00 00    	js     80221c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f0:	83 ec 04             	sub    $0x4,%esp
  8020f3:	68 07 04 00 00       	push   $0x407
  8020f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fb:	6a 00                	push   $0x0
  8020fd:	e8 2f eb ff ff       	call   800c31 <sys_page_alloc>
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	89 c2                	mov    %eax,%edx
  802107:	85 c0                	test   %eax,%eax
  802109:	0f 88 0d 01 00 00    	js     80221c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80210f:	83 ec 0c             	sub    $0xc,%esp
  802112:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802115:	50                   	push   %eax
  802116:	e8 29 f6 ff ff       	call   801744 <fd_alloc>
  80211b:	89 c3                	mov    %eax,%ebx
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	85 c0                	test   %eax,%eax
  802122:	0f 88 e2 00 00 00    	js     80220a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802128:	83 ec 04             	sub    $0x4,%esp
  80212b:	68 07 04 00 00       	push   $0x407
  802130:	ff 75 f0             	pushl  -0x10(%ebp)
  802133:	6a 00                	push   $0x0
  802135:	e8 f7 ea ff ff       	call   800c31 <sys_page_alloc>
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	85 c0                	test   %eax,%eax
  802141:	0f 88 c3 00 00 00    	js     80220a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802147:	83 ec 0c             	sub    $0xc,%esp
  80214a:	ff 75 f4             	pushl  -0xc(%ebp)
  80214d:	e8 db f5 ff ff       	call   80172d <fd2data>
  802152:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802154:	83 c4 0c             	add    $0xc,%esp
  802157:	68 07 04 00 00       	push   $0x407
  80215c:	50                   	push   %eax
  80215d:	6a 00                	push   $0x0
  80215f:	e8 cd ea ff ff       	call   800c31 <sys_page_alloc>
  802164:	89 c3                	mov    %eax,%ebx
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	85 c0                	test   %eax,%eax
  80216b:	0f 88 89 00 00 00    	js     8021fa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802171:	83 ec 0c             	sub    $0xc,%esp
  802174:	ff 75 f0             	pushl  -0x10(%ebp)
  802177:	e8 b1 f5 ff ff       	call   80172d <fd2data>
  80217c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802183:	50                   	push   %eax
  802184:	6a 00                	push   $0x0
  802186:	56                   	push   %esi
  802187:	6a 00                	push   $0x0
  802189:	e8 e6 ea ff ff       	call   800c74 <sys_page_map>
  80218e:	89 c3                	mov    %eax,%ebx
  802190:	83 c4 20             	add    $0x20,%esp
  802193:	85 c0                	test   %eax,%eax
  802195:	78 55                	js     8021ec <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802197:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80219d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021ac:	8b 15 28 30 80 00    	mov    0x803028,%edx
  8021b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021c1:	83 ec 0c             	sub    $0xc,%esp
  8021c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c7:	e8 51 f5 ff ff       	call   80171d <fd2num>
  8021cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021cf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021d1:	83 c4 04             	add    $0x4,%esp
  8021d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d7:	e8 41 f5 ff ff       	call   80171d <fd2num>
  8021dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021df:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021e2:	83 c4 10             	add    $0x10,%esp
  8021e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8021ea:	eb 30                	jmp    80221c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021ec:	83 ec 08             	sub    $0x8,%esp
  8021ef:	56                   	push   %esi
  8021f0:	6a 00                	push   $0x0
  8021f2:	e8 bf ea ff ff       	call   800cb6 <sys_page_unmap>
  8021f7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021fa:	83 ec 08             	sub    $0x8,%esp
  8021fd:	ff 75 f0             	pushl  -0x10(%ebp)
  802200:	6a 00                	push   $0x0
  802202:	e8 af ea ff ff       	call   800cb6 <sys_page_unmap>
  802207:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80220a:	83 ec 08             	sub    $0x8,%esp
  80220d:	ff 75 f4             	pushl  -0xc(%ebp)
  802210:	6a 00                	push   $0x0
  802212:	e8 9f ea ff ff       	call   800cb6 <sys_page_unmap>
  802217:	83 c4 10             	add    $0x10,%esp
  80221a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80221c:	89 d0                	mov    %edx,%eax
  80221e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80222b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222e:	50                   	push   %eax
  80222f:	ff 75 08             	pushl  0x8(%ebp)
  802232:	e8 5c f5 ff ff       	call   801793 <fd_lookup>
  802237:	83 c4 10             	add    $0x10,%esp
  80223a:	85 c0                	test   %eax,%eax
  80223c:	78 18                	js     802256 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80223e:	83 ec 0c             	sub    $0xc,%esp
  802241:	ff 75 f4             	pushl  -0xc(%ebp)
  802244:	e8 e4 f4 ff ff       	call   80172d <fd2data>
	return _pipeisclosed(fd, p);
  802249:	89 c2                	mov    %eax,%edx
  80224b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224e:	e8 21 fd ff ff       	call   801f74 <_pipeisclosed>
  802253:	83 c4 10             	add    $0x10,%esp
}
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80225b:	b8 00 00 00 00       	mov    $0x0,%eax
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    

00802262 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802268:	68 3b 2f 80 00       	push   $0x802f3b
  80226d:	ff 75 0c             	pushl  0xc(%ebp)
  802270:	e8 b9 e5 ff ff       	call   80082e <strcpy>
	return 0;
}
  802275:	b8 00 00 00 00       	mov    $0x0,%eax
  80227a:	c9                   	leave  
  80227b:	c3                   	ret    

0080227c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	57                   	push   %edi
  802280:	56                   	push   %esi
  802281:	53                   	push   %ebx
  802282:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802288:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80228d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802293:	eb 2d                	jmp    8022c2 <devcons_write+0x46>
		m = n - tot;
  802295:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802298:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80229a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80229d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022a2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022a5:	83 ec 04             	sub    $0x4,%esp
  8022a8:	53                   	push   %ebx
  8022a9:	03 45 0c             	add    0xc(%ebp),%eax
  8022ac:	50                   	push   %eax
  8022ad:	57                   	push   %edi
  8022ae:	e8 0d e7 ff ff       	call   8009c0 <memmove>
		sys_cputs(buf, m);
  8022b3:	83 c4 08             	add    $0x8,%esp
  8022b6:	53                   	push   %ebx
  8022b7:	57                   	push   %edi
  8022b8:	e8 b8 e8 ff ff       	call   800b75 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022bd:	01 de                	add    %ebx,%esi
  8022bf:	83 c4 10             	add    $0x10,%esp
  8022c2:	89 f0                	mov    %esi,%eax
  8022c4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022c7:	72 cc                	jb     802295 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022cc:	5b                   	pop    %ebx
  8022cd:	5e                   	pop    %esi
  8022ce:	5f                   	pop    %edi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    

008022d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	83 ec 08             	sub    $0x8,%esp
  8022d7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022e0:	74 2a                	je     80230c <devcons_read+0x3b>
  8022e2:	eb 05                	jmp    8022e9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022e4:	e8 29 e9 ff ff       	call   800c12 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022e9:	e8 a5 e8 ff ff       	call   800b93 <sys_cgetc>
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	74 f2                	je     8022e4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022f2:	85 c0                	test   %eax,%eax
  8022f4:	78 16                	js     80230c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022f6:	83 f8 04             	cmp    $0x4,%eax
  8022f9:	74 0c                	je     802307 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022fe:	88 02                	mov    %al,(%edx)
	return 1;
  802300:	b8 01 00 00 00       	mov    $0x1,%eax
  802305:	eb 05                	jmp    80230c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802307:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80230c:	c9                   	leave  
  80230d:	c3                   	ret    

0080230e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80230e:	55                   	push   %ebp
  80230f:	89 e5                	mov    %esp,%ebp
  802311:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802314:	8b 45 08             	mov    0x8(%ebp),%eax
  802317:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80231a:	6a 01                	push   $0x1
  80231c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80231f:	50                   	push   %eax
  802320:	e8 50 e8 ff ff       	call   800b75 <sys_cputs>
}
  802325:	83 c4 10             	add    $0x10,%esp
  802328:	c9                   	leave  
  802329:	c3                   	ret    

0080232a <getchar>:

int
getchar(void)
{
  80232a:	55                   	push   %ebp
  80232b:	89 e5                	mov    %esp,%ebp
  80232d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802330:	6a 01                	push   $0x1
  802332:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802335:	50                   	push   %eax
  802336:	6a 00                	push   $0x0
  802338:	e8 bc f6 ff ff       	call   8019f9 <read>
	if (r < 0)
  80233d:	83 c4 10             	add    $0x10,%esp
  802340:	85 c0                	test   %eax,%eax
  802342:	78 0f                	js     802353 <getchar+0x29>
		return r;
	if (r < 1)
  802344:	85 c0                	test   %eax,%eax
  802346:	7e 06                	jle    80234e <getchar+0x24>
		return -E_EOF;
	return c;
  802348:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80234c:	eb 05                	jmp    802353 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80234e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802353:	c9                   	leave  
  802354:	c3                   	ret    

00802355 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
  802358:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80235b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80235e:	50                   	push   %eax
  80235f:	ff 75 08             	pushl  0x8(%ebp)
  802362:	e8 2c f4 ff ff       	call   801793 <fd_lookup>
  802367:	83 c4 10             	add    $0x10,%esp
  80236a:	85 c0                	test   %eax,%eax
  80236c:	78 11                	js     80237f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80236e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802371:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802377:	39 10                	cmp    %edx,(%eax)
  802379:	0f 94 c0             	sete   %al
  80237c:	0f b6 c0             	movzbl %al,%eax
}
  80237f:	c9                   	leave  
  802380:	c3                   	ret    

00802381 <opencons>:

int
opencons(void)
{
  802381:	55                   	push   %ebp
  802382:	89 e5                	mov    %esp,%ebp
  802384:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802387:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238a:	50                   	push   %eax
  80238b:	e8 b4 f3 ff ff       	call   801744 <fd_alloc>
  802390:	83 c4 10             	add    $0x10,%esp
		return r;
  802393:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802395:	85 c0                	test   %eax,%eax
  802397:	78 3e                	js     8023d7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802399:	83 ec 04             	sub    $0x4,%esp
  80239c:	68 07 04 00 00       	push   $0x407
  8023a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a4:	6a 00                	push   $0x0
  8023a6:	e8 86 e8 ff ff       	call   800c31 <sys_page_alloc>
  8023ab:	83 c4 10             	add    $0x10,%esp
		return r;
  8023ae:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	78 23                	js     8023d7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023b4:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023bd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023c9:	83 ec 0c             	sub    $0xc,%esp
  8023cc:	50                   	push   %eax
  8023cd:	e8 4b f3 ff ff       	call   80171d <fd2num>
  8023d2:	89 c2                	mov    %eax,%edx
  8023d4:	83 c4 10             	add    $0x10,%esp
}
  8023d7:	89 d0                	mov    %edx,%eax
  8023d9:	c9                   	leave  
  8023da:	c3                   	ret    

008023db <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023db:	55                   	push   %ebp
  8023dc:	89 e5                	mov    %esp,%ebp
  8023de:	56                   	push   %esi
  8023df:	53                   	push   %ebx
  8023e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8023e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  8023e9:	85 c0                	test   %eax,%eax
  8023eb:	74 0e                	je     8023fb <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  8023ed:	83 ec 0c             	sub    $0xc,%esp
  8023f0:	50                   	push   %eax
  8023f1:	e8 eb e9 ff ff       	call   800de1 <sys_ipc_recv>
  8023f6:	83 c4 10             	add    $0x10,%esp
  8023f9:	eb 10                	jmp    80240b <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  8023fb:	83 ec 0c             	sub    $0xc,%esp
  8023fe:	68 00 00 00 f0       	push   $0xf0000000
  802403:	e8 d9 e9 ff ff       	call   800de1 <sys_ipc_recv>
  802408:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  80240b:	85 c0                	test   %eax,%eax
  80240d:	74 16                	je     802425 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  80240f:	85 db                	test   %ebx,%ebx
  802411:	74 36                	je     802449 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  802413:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  802419:	85 f6                	test   %esi,%esi
  80241b:	74 2c                	je     802449 <ipc_recv+0x6e>
				*perm_store = 0;
  80241d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802423:	eb 24                	jmp    802449 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  802425:	85 db                	test   %ebx,%ebx
  802427:	74 18                	je     802441 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  802429:	a1 04 40 80 00       	mov    0x804004,%eax
  80242e:	8b 40 74             	mov    0x74(%eax),%eax
  802431:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  802433:	85 f6                	test   %esi,%esi
  802435:	74 0a                	je     802441 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  802437:	a1 04 40 80 00       	mov    0x804004,%eax
  80243c:	8b 40 78             	mov    0x78(%eax),%eax
  80243f:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  802441:	a1 04 40 80 00       	mov    0x804004,%eax
  802446:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  802449:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80244c:	5b                   	pop    %ebx
  80244d:	5e                   	pop    %esi
  80244e:	5d                   	pop    %ebp
  80244f:	c3                   	ret    

00802450 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	57                   	push   %edi
  802454:	56                   	push   %esi
  802455:	53                   	push   %ebx
  802456:	83 ec 0c             	sub    $0xc,%esp
  802459:	8b 7d 08             	mov    0x8(%ebp),%edi
  80245c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  80245f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802463:	75 39                	jne    80249e <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  802465:	6a 00                	push   $0x0
  802467:	68 00 00 00 f0       	push   $0xf0000000
  80246c:	56                   	push   %esi
  80246d:	57                   	push   %edi
  80246e:	e8 4b e9 ff ff       	call   800dbe <sys_ipc_try_send>
  802473:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  802475:	83 c4 10             	add    $0x10,%esp
  802478:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80247b:	74 16                	je     802493 <ipc_send+0x43>
  80247d:	85 c0                	test   %eax,%eax
  80247f:	74 12                	je     802493 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802481:	50                   	push   %eax
  802482:	68 48 2f 80 00       	push   $0x802f48
  802487:	6a 4f                	push   $0x4f
  802489:	68 80 2f 80 00       	push   $0x802f80
  80248e:	e8 3d dd ff ff       	call   8001d0 <_panic>
			sys_yield();
  802493:	e8 7a e7 ff ff       	call   800c12 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  802498:	85 db                	test   %ebx,%ebx
  80249a:	75 c9                	jne    802465 <ipc_send+0x15>
  80249c:	eb 36                	jmp    8024d4 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  80249e:	ff 75 14             	pushl  0x14(%ebp)
  8024a1:	ff 75 10             	pushl  0x10(%ebp)
  8024a4:	56                   	push   %esi
  8024a5:	57                   	push   %edi
  8024a6:	e8 13 e9 ff ff       	call   800dbe <sys_ipc_try_send>
  8024ab:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  8024ad:	83 c4 10             	add    $0x10,%esp
  8024b0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024b3:	74 16                	je     8024cb <ipc_send+0x7b>
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	74 12                	je     8024cb <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  8024b9:	50                   	push   %eax
  8024ba:	68 48 2f 80 00       	push   $0x802f48
  8024bf:	6a 5a                	push   $0x5a
  8024c1:	68 80 2f 80 00       	push   $0x802f80
  8024c6:	e8 05 dd ff ff       	call   8001d0 <_panic>
			sys_yield();
  8024cb:	e8 42 e7 ff ff       	call   800c12 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  8024d0:	85 db                	test   %ebx,%ebx
  8024d2:	75 ca                	jne    80249e <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  8024d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    

008024dc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024dc:	55                   	push   %ebp
  8024dd:	89 e5                	mov    %esp,%ebp
  8024df:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024e2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024e7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024ea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024f0:	8b 52 50             	mov    0x50(%edx),%edx
  8024f3:	39 ca                	cmp    %ecx,%edx
  8024f5:	75 0d                	jne    802504 <ipc_find_env+0x28>
			return envs[i].env_id;
  8024f7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024ff:	8b 40 48             	mov    0x48(%eax),%eax
  802502:	eb 0f                	jmp    802513 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802504:	83 c0 01             	add    $0x1,%eax
  802507:	3d 00 04 00 00       	cmp    $0x400,%eax
  80250c:	75 d9                	jne    8024e7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80250e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    

00802515 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80251b:	89 d0                	mov    %edx,%eax
  80251d:	c1 e8 16             	shr    $0x16,%eax
  802520:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802527:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80252c:	f6 c1 01             	test   $0x1,%cl
  80252f:	74 1d                	je     80254e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802531:	c1 ea 0c             	shr    $0xc,%edx
  802534:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80253b:	f6 c2 01             	test   $0x1,%dl
  80253e:	74 0e                	je     80254e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802540:	c1 ea 0c             	shr    $0xc,%edx
  802543:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80254a:	ef 
  80254b:	0f b7 c0             	movzwl %ax,%eax
}
  80254e:	5d                   	pop    %ebp
  80254f:	c3                   	ret    

00802550 <__udivdi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 1c             	sub    $0x1c,%esp
  802557:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80255b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80255f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802563:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802567:	85 f6                	test   %esi,%esi
  802569:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80256d:	89 ca                	mov    %ecx,%edx
  80256f:	89 f8                	mov    %edi,%eax
  802571:	75 3d                	jne    8025b0 <__udivdi3+0x60>
  802573:	39 cf                	cmp    %ecx,%edi
  802575:	0f 87 c5 00 00 00    	ja     802640 <__udivdi3+0xf0>
  80257b:	85 ff                	test   %edi,%edi
  80257d:	89 fd                	mov    %edi,%ebp
  80257f:	75 0b                	jne    80258c <__udivdi3+0x3c>
  802581:	b8 01 00 00 00       	mov    $0x1,%eax
  802586:	31 d2                	xor    %edx,%edx
  802588:	f7 f7                	div    %edi
  80258a:	89 c5                	mov    %eax,%ebp
  80258c:	89 c8                	mov    %ecx,%eax
  80258e:	31 d2                	xor    %edx,%edx
  802590:	f7 f5                	div    %ebp
  802592:	89 c1                	mov    %eax,%ecx
  802594:	89 d8                	mov    %ebx,%eax
  802596:	89 cf                	mov    %ecx,%edi
  802598:	f7 f5                	div    %ebp
  80259a:	89 c3                	mov    %eax,%ebx
  80259c:	89 d8                	mov    %ebx,%eax
  80259e:	89 fa                	mov    %edi,%edx
  8025a0:	83 c4 1c             	add    $0x1c,%esp
  8025a3:	5b                   	pop    %ebx
  8025a4:	5e                   	pop    %esi
  8025a5:	5f                   	pop    %edi
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    
  8025a8:	90                   	nop
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	39 ce                	cmp    %ecx,%esi
  8025b2:	77 74                	ja     802628 <__udivdi3+0xd8>
  8025b4:	0f bd fe             	bsr    %esi,%edi
  8025b7:	83 f7 1f             	xor    $0x1f,%edi
  8025ba:	0f 84 98 00 00 00    	je     802658 <__udivdi3+0x108>
  8025c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	89 c5                	mov    %eax,%ebp
  8025c9:	29 fb                	sub    %edi,%ebx
  8025cb:	d3 e6                	shl    %cl,%esi
  8025cd:	89 d9                	mov    %ebx,%ecx
  8025cf:	d3 ed                	shr    %cl,%ebp
  8025d1:	89 f9                	mov    %edi,%ecx
  8025d3:	d3 e0                	shl    %cl,%eax
  8025d5:	09 ee                	or     %ebp,%esi
  8025d7:	89 d9                	mov    %ebx,%ecx
  8025d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025dd:	89 d5                	mov    %edx,%ebp
  8025df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025e3:	d3 ed                	shr    %cl,%ebp
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	d3 e2                	shl    %cl,%edx
  8025e9:	89 d9                	mov    %ebx,%ecx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	09 c2                	or     %eax,%edx
  8025ef:	89 d0                	mov    %edx,%eax
  8025f1:	89 ea                	mov    %ebp,%edx
  8025f3:	f7 f6                	div    %esi
  8025f5:	89 d5                	mov    %edx,%ebp
  8025f7:	89 c3                	mov    %eax,%ebx
  8025f9:	f7 64 24 0c          	mull   0xc(%esp)
  8025fd:	39 d5                	cmp    %edx,%ebp
  8025ff:	72 10                	jb     802611 <__udivdi3+0xc1>
  802601:	8b 74 24 08          	mov    0x8(%esp),%esi
  802605:	89 f9                	mov    %edi,%ecx
  802607:	d3 e6                	shl    %cl,%esi
  802609:	39 c6                	cmp    %eax,%esi
  80260b:	73 07                	jae    802614 <__udivdi3+0xc4>
  80260d:	39 d5                	cmp    %edx,%ebp
  80260f:	75 03                	jne    802614 <__udivdi3+0xc4>
  802611:	83 eb 01             	sub    $0x1,%ebx
  802614:	31 ff                	xor    %edi,%edi
  802616:	89 d8                	mov    %ebx,%eax
  802618:	89 fa                	mov    %edi,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	31 ff                	xor    %edi,%edi
  80262a:	31 db                	xor    %ebx,%ebx
  80262c:	89 d8                	mov    %ebx,%eax
  80262e:	89 fa                	mov    %edi,%edx
  802630:	83 c4 1c             	add    $0x1c,%esp
  802633:	5b                   	pop    %ebx
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
  802638:	90                   	nop
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	89 d8                	mov    %ebx,%eax
  802642:	f7 f7                	div    %edi
  802644:	31 ff                	xor    %edi,%edi
  802646:	89 c3                	mov    %eax,%ebx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 fa                	mov    %edi,%edx
  80264c:	83 c4 1c             	add    $0x1c,%esp
  80264f:	5b                   	pop    %ebx
  802650:	5e                   	pop    %esi
  802651:	5f                   	pop    %edi
  802652:	5d                   	pop    %ebp
  802653:	c3                   	ret    
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	39 ce                	cmp    %ecx,%esi
  80265a:	72 0c                	jb     802668 <__udivdi3+0x118>
  80265c:	31 db                	xor    %ebx,%ebx
  80265e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802662:	0f 87 34 ff ff ff    	ja     80259c <__udivdi3+0x4c>
  802668:	bb 01 00 00 00       	mov    $0x1,%ebx
  80266d:	e9 2a ff ff ff       	jmp    80259c <__udivdi3+0x4c>
  802672:	66 90                	xchg   %ax,%ax
  802674:	66 90                	xchg   %ax,%ax
  802676:	66 90                	xchg   %ax,%ax
  802678:	66 90                	xchg   %ax,%ax
  80267a:	66 90                	xchg   %ax,%ax
  80267c:	66 90                	xchg   %ax,%ax
  80267e:	66 90                	xchg   %ax,%ax

00802680 <__umoddi3>:
  802680:	55                   	push   %ebp
  802681:	57                   	push   %edi
  802682:	56                   	push   %esi
  802683:	53                   	push   %ebx
  802684:	83 ec 1c             	sub    $0x1c,%esp
  802687:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80268b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80268f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802693:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802697:	85 d2                	test   %edx,%edx
  802699:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80269d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026a1:	89 f3                	mov    %esi,%ebx
  8026a3:	89 3c 24             	mov    %edi,(%esp)
  8026a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026aa:	75 1c                	jne    8026c8 <__umoddi3+0x48>
  8026ac:	39 f7                	cmp    %esi,%edi
  8026ae:	76 50                	jbe    802700 <__umoddi3+0x80>
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	f7 f7                	div    %edi
  8026b6:	89 d0                	mov    %edx,%eax
  8026b8:	31 d2                	xor    %edx,%edx
  8026ba:	83 c4 1c             	add    $0x1c,%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5e                   	pop    %esi
  8026bf:	5f                   	pop    %edi
  8026c0:	5d                   	pop    %ebp
  8026c1:	c3                   	ret    
  8026c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026c8:	39 f2                	cmp    %esi,%edx
  8026ca:	89 d0                	mov    %edx,%eax
  8026cc:	77 52                	ja     802720 <__umoddi3+0xa0>
  8026ce:	0f bd ea             	bsr    %edx,%ebp
  8026d1:	83 f5 1f             	xor    $0x1f,%ebp
  8026d4:	75 5a                	jne    802730 <__umoddi3+0xb0>
  8026d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026da:	0f 82 e0 00 00 00    	jb     8027c0 <__umoddi3+0x140>
  8026e0:	39 0c 24             	cmp    %ecx,(%esp)
  8026e3:	0f 86 d7 00 00 00    	jbe    8027c0 <__umoddi3+0x140>
  8026e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026f1:	83 c4 1c             	add    $0x1c,%esp
  8026f4:	5b                   	pop    %ebx
  8026f5:	5e                   	pop    %esi
  8026f6:	5f                   	pop    %edi
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    
  8026f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802700:	85 ff                	test   %edi,%edi
  802702:	89 fd                	mov    %edi,%ebp
  802704:	75 0b                	jne    802711 <__umoddi3+0x91>
  802706:	b8 01 00 00 00       	mov    $0x1,%eax
  80270b:	31 d2                	xor    %edx,%edx
  80270d:	f7 f7                	div    %edi
  80270f:	89 c5                	mov    %eax,%ebp
  802711:	89 f0                	mov    %esi,%eax
  802713:	31 d2                	xor    %edx,%edx
  802715:	f7 f5                	div    %ebp
  802717:	89 c8                	mov    %ecx,%eax
  802719:	f7 f5                	div    %ebp
  80271b:	89 d0                	mov    %edx,%eax
  80271d:	eb 99                	jmp    8026b8 <__umoddi3+0x38>
  80271f:	90                   	nop
  802720:	89 c8                	mov    %ecx,%eax
  802722:	89 f2                	mov    %esi,%edx
  802724:	83 c4 1c             	add    $0x1c,%esp
  802727:	5b                   	pop    %ebx
  802728:	5e                   	pop    %esi
  802729:	5f                   	pop    %edi
  80272a:	5d                   	pop    %ebp
  80272b:	c3                   	ret    
  80272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802730:	8b 34 24             	mov    (%esp),%esi
  802733:	bf 20 00 00 00       	mov    $0x20,%edi
  802738:	89 e9                	mov    %ebp,%ecx
  80273a:	29 ef                	sub    %ebp,%edi
  80273c:	d3 e0                	shl    %cl,%eax
  80273e:	89 f9                	mov    %edi,%ecx
  802740:	89 f2                	mov    %esi,%edx
  802742:	d3 ea                	shr    %cl,%edx
  802744:	89 e9                	mov    %ebp,%ecx
  802746:	09 c2                	or     %eax,%edx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 14 24             	mov    %edx,(%esp)
  80274d:	89 f2                	mov    %esi,%edx
  80274f:	d3 e2                	shl    %cl,%edx
  802751:	89 f9                	mov    %edi,%ecx
  802753:	89 54 24 04          	mov    %edx,0x4(%esp)
  802757:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80275b:	d3 e8                	shr    %cl,%eax
  80275d:	89 e9                	mov    %ebp,%ecx
  80275f:	89 c6                	mov    %eax,%esi
  802761:	d3 e3                	shl    %cl,%ebx
  802763:	89 f9                	mov    %edi,%ecx
  802765:	89 d0                	mov    %edx,%eax
  802767:	d3 e8                	shr    %cl,%eax
  802769:	89 e9                	mov    %ebp,%ecx
  80276b:	09 d8                	or     %ebx,%eax
  80276d:	89 d3                	mov    %edx,%ebx
  80276f:	89 f2                	mov    %esi,%edx
  802771:	f7 34 24             	divl   (%esp)
  802774:	89 d6                	mov    %edx,%esi
  802776:	d3 e3                	shl    %cl,%ebx
  802778:	f7 64 24 04          	mull   0x4(%esp)
  80277c:	39 d6                	cmp    %edx,%esi
  80277e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802782:	89 d1                	mov    %edx,%ecx
  802784:	89 c3                	mov    %eax,%ebx
  802786:	72 08                	jb     802790 <__umoddi3+0x110>
  802788:	75 11                	jne    80279b <__umoddi3+0x11b>
  80278a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80278e:	73 0b                	jae    80279b <__umoddi3+0x11b>
  802790:	2b 44 24 04          	sub    0x4(%esp),%eax
  802794:	1b 14 24             	sbb    (%esp),%edx
  802797:	89 d1                	mov    %edx,%ecx
  802799:	89 c3                	mov    %eax,%ebx
  80279b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80279f:	29 da                	sub    %ebx,%edx
  8027a1:	19 ce                	sbb    %ecx,%esi
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 f0                	mov    %esi,%eax
  8027a7:	d3 e0                	shl    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	d3 ea                	shr    %cl,%edx
  8027ad:	89 e9                	mov    %ebp,%ecx
  8027af:	d3 ee                	shr    %cl,%esi
  8027b1:	09 d0                	or     %edx,%eax
  8027b3:	89 f2                	mov    %esi,%edx
  8027b5:	83 c4 1c             	add    $0x1c,%esp
  8027b8:	5b                   	pop    %ebx
  8027b9:	5e                   	pop    %esi
  8027ba:	5f                   	pop    %edi
  8027bb:	5d                   	pop    %ebp
  8027bc:	c3                   	ret    
  8027bd:	8d 76 00             	lea    0x0(%esi),%esi
  8027c0:	29 f9                	sub    %edi,%ecx
  8027c2:	19 d6                	sbb    %edx,%esi
  8027c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027cc:	e9 18 ff ff ff       	jmp    8026e9 <__umoddi3+0x69>
