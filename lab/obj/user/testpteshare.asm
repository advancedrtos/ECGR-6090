
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
  800039:	ff 35 00 40 80 00    	pushl  0x804000
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
  800081:	68 8c 2d 80 00       	push   $0x802d8c
  800086:	6a 13                	push   $0x13
  800088:	68 9f 2d 80 00       	push   $0x802d9f
  80008d:	e8 3e 01 00 00       	call   8001d0 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 9a 0e 00 00       	call   800f31 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 81 32 80 00       	push   $0x803281
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 9f 2d 80 00       	push   $0x802d9f
  8000aa:	e8 21 01 00 00       	call   8001d0 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 68 07 00 00       	call   80082e <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 53 16 00 00       	call   80172a <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 ee 07 00 00       	call   8008d8 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 86 2d 80 00       	mov    $0x802d86,%edx
  8000f4:	b8 80 2d 80 00       	mov    $0x802d80,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 b3 2d 80 00       	push   $0x802db3
  800102:	e8 a2 01 00 00       	call   8002a9 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 ce 2d 80 00       	push   $0x802dce
  80010e:	68 d3 2d 80 00       	push   $0x802dd3
  800113:	68 d2 2d 80 00       	push   $0x802dd2
  800118:	e8 9a 15 00 00       	call   8016b7 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 e0 2d 80 00       	push   $0x802de0
  80012a:	6a 21                	push   $0x21
  80012c:	68 9f 2d 80 00       	push   $0x802d9f
  800131:	e8 9a 00 00 00       	call   8001d0 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 eb 15 00 00       	call   80172a <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 86 07 00 00       	call   8008d8 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 86 2d 80 00       	mov    $0x802d86,%edx
  80015c:	b8 80 2d 80 00       	mov    $0x802d80,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 ea 2d 80 00       	push   $0x802dea
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
  800195:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8001d8:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001de:	e8 10 0a 00 00       	call   800bf3 <sys_getenvid>
  8001e3:	83 ec 0c             	sub    $0xc,%esp
  8001e6:	ff 75 0c             	pushl  0xc(%ebp)
  8001e9:	ff 75 08             	pushl  0x8(%ebp)
  8001ec:	56                   	push   %esi
  8001ed:	50                   	push   %eax
  8001ee:	68 30 2e 80 00       	push   $0x802e30
  8001f3:	e8 b1 00 00 00       	call   8002a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f8:	83 c4 18             	add    $0x18,%esp
  8001fb:	53                   	push   %ebx
  8001fc:	ff 75 10             	pushl  0x10(%ebp)
  8001ff:	e8 54 00 00 00       	call   800258 <vcprintf>
	cprintf("\n");
  800204:	c7 04 24 0b 35 80 00 	movl   $0x80350b,(%esp)
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
  80030c:	e8 df 27 00 00       	call   802af0 <__udivdi3>
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
  80034f:	e8 cc 28 00 00       	call   802c20 <__umoddi3>
  800354:	83 c4 14             	add    $0x14,%esp
  800357:	0f be 80 53 2e 80 00 	movsbl 0x802e53(%eax),%eax
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
  800453:	ff 24 85 a0 2f 80 00 	jmp    *0x802fa0(,%eax,4)
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
  800517:	8b 14 85 00 31 80 00 	mov    0x803100(,%eax,4),%edx
  80051e:	85 d2                	test   %edx,%edx
  800520:	75 18                	jne    80053a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800522:	50                   	push   %eax
  800523:	68 6b 2e 80 00       	push   $0x802e6b
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
  80053b:	68 13 33 80 00       	push   $0x803313
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
  80055f:	b8 64 2e 80 00       	mov    $0x802e64,%eax
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
  800bda:	68 5f 31 80 00       	push   $0x80315f
  800bdf:	6a 23                	push   $0x23
  800be1:	68 7c 31 80 00       	push   $0x80317c
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
  800c5b:	68 5f 31 80 00       	push   $0x80315f
  800c60:	6a 23                	push   $0x23
  800c62:	68 7c 31 80 00       	push   $0x80317c
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
  800c9d:	68 5f 31 80 00       	push   $0x80315f
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 7c 31 80 00       	push   $0x80317c
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
  800cdf:	68 5f 31 80 00       	push   $0x80315f
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 7c 31 80 00       	push   $0x80317c
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
  800d21:	68 5f 31 80 00       	push   $0x80315f
  800d26:	6a 23                	push   $0x23
  800d28:	68 7c 31 80 00       	push   $0x80317c
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
  800d63:	68 5f 31 80 00       	push   $0x80315f
  800d68:	6a 23                	push   $0x23
  800d6a:	68 7c 31 80 00       	push   $0x80317c
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
  800da5:	68 5f 31 80 00       	push   $0x80315f
  800daa:	6a 23                	push   $0x23
  800dac:	68 7c 31 80 00       	push   $0x80317c
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
  800e09:	68 5f 31 80 00       	push   $0x80315f
  800e0e:	6a 23                	push   $0x23
  800e10:	68 7c 31 80 00       	push   $0x80317c
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

00800e22 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e32:	89 d1                	mov    %edx,%ecx
  800e34:	89 d3                	mov    %edx,%ebx
  800e36:	89 d7                	mov    %edx,%edi
  800e38:	89 d6                	mov    %edx,%esi
  800e3a:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	53                   	push   %ebx
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e4b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800e4d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e51:	75 14                	jne    800e67 <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	68 8c 31 80 00       	push   $0x80318c
  800e5b:	6a 22                	push   $0x22
  800e5d:	68 6f 32 80 00       	push   $0x80326f
  800e62:	e8 69 f3 ff ff       	call   8001d0 <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800e67:	89 d8                	mov    %ebx,%eax
  800e69:	c1 e8 0c             	shr    $0xc,%eax
  800e6c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e73:	f6 c4 08             	test   $0x8,%ah
  800e76:	75 14                	jne    800e8c <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	68 c8 31 80 00       	push   $0x8031c8
  800e80:	6a 27                	push   $0x27
  800e82:	68 6f 32 80 00       	push   $0x80326f
  800e87:	e8 44 f3 ff ff       	call   8001d0 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	6a 07                	push   $0x7
  800e91:	68 00 f0 7f 00       	push   $0x7ff000
  800e96:	6a 00                	push   $0x0
  800e98:	e8 94 fd ff ff       	call   800c31 <sys_page_alloc>
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	79 14                	jns    800eb8 <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800ea4:	83 ec 04             	sub    $0x4,%esp
  800ea7:	68 f8 31 80 00       	push   $0x8031f8
  800eac:	6a 2f                	push   $0x2f
  800eae:	68 6f 32 80 00       	push   $0x80326f
  800eb3:	e8 18 f3 ff ff       	call   8001d0 <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800eb8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	68 00 10 00 00       	push   $0x1000
  800ec6:	53                   	push   %ebx
  800ec7:	68 00 f0 7f 00       	push   $0x7ff000
  800ecc:	e8 ef fa ff ff       	call   8009c0 <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800ed1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ed8:	53                   	push   %ebx
  800ed9:	6a 00                	push   $0x0
  800edb:	68 00 f0 7f 00       	push   $0x7ff000
  800ee0:	6a 00                	push   $0x0
  800ee2:	e8 8d fd ff ff       	call   800c74 <sys_page_map>
  800ee7:	83 c4 20             	add    $0x20,%esp
  800eea:	85 c0                	test   %eax,%eax
  800eec:	79 14                	jns    800f02 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	68 24 32 80 00       	push   $0x803224
  800ef6:	6a 34                	push   $0x34
  800ef8:	68 6f 32 80 00       	push   $0x80326f
  800efd:	e8 ce f2 ff ff       	call   8001d0 <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	68 00 f0 7f 00       	push   $0x7ff000
  800f0a:	6a 00                	push   $0x0
  800f0c:	e8 a5 fd ff ff       	call   800cb6 <sys_page_unmap>
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	79 14                	jns    800f2c <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800f18:	83 ec 04             	sub    $0x4,%esp
  800f1b:	68 4c 32 80 00       	push   $0x80324c
  800f20:	6a 37                	push   $0x37
  800f22:	68 6f 32 80 00       	push   $0x80326f
  800f27:	e8 a4 f2 ff ff       	call   8001d0 <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800f2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    

00800f31 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800f3a:	68 41 0e 80 00       	push   $0x800e41
  800f3f:	e8 35 08 00 00       	call   801779 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f44:	b8 07 00 00 00       	mov    $0x7,%eax
  800f49:	cd 30                	int    $0x30
  800f4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	79 15                	jns    800f6d <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800f58:	50                   	push   %eax
  800f59:	68 7a 32 80 00       	push   $0x80327a
  800f5e:	68 8d 00 00 00       	push   $0x8d
  800f63:	68 6f 32 80 00       	push   $0x80326f
  800f68:	e8 63 f2 ff ff       	call   8001d0 <_panic>
  800f6d:	be 00 00 00 00       	mov    $0x0,%esi
  800f72:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  800f77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f7b:	75 21                	jne    800f9e <fork+0x6d>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  800f7d:	e8 71 fc ff ff       	call   800bf3 <sys_getenvid>
  800f82:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f87:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f8a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f8f:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
  800f99:	e9 aa 01 00 00       	jmp    801148 <fork+0x217>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	c1 e8 16             	shr    $0x16,%eax
  800fa3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800faa:	a8 01                	test   $0x1,%al
  800fac:	0f 84 f9 00 00 00    	je     8010ab <fork+0x17a>
  800fb2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fb9:	a8 05                	test   $0x5,%al
  800fbb:	0f 84 ea 00 00 00    	je     8010ab <fork+0x17a>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
  800fc1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fc8:	a8 02                	test   $0x2,%al
  800fca:	75 1c                	jne    800fe8 <fork+0xb7>
  800fcc:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd3:	f6 c4 08             	test   $0x8,%ah
  800fd6:	75 10                	jne    800fe8 <fork+0xb7>
  800fd8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fdf:	f6 c4 04             	test   $0x4,%ah
  800fe2:	0f 84 99 00 00 00    	je     801081 <fork+0x150>
	{
		if(uvpt[pn] & PTE_SHARE)
  800fe8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fef:	f6 c4 04             	test   $0x4,%ah
  800ff2:	74 0f                	je     801003 <fork+0xd2>
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
  800ff4:	8b 3c 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edi
  800ffb:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801001:	eb 2d                	jmp    801030 <fork+0xff>
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  801003:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
			perm = PTE_P|PTE_U|PTE_COW;
  80100a:	bf 05 08 00 00       	mov    $0x805,%edi
	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
	{
		if(uvpt[pn] & PTE_SHARE)
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  80100f:	a8 02                	test   $0x2,%al
  801011:	75 1d                	jne    801030 <fork+0xff>
  801013:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80101a:	25 00 08 00 00       	and    $0x800,%eax
			perm = PTE_P|PTE_U|PTE_COW;
  80101f:	83 f8 01             	cmp    $0x1,%eax
  801022:	19 ff                	sbb    %edi,%edi
  801024:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  80102a:	81 c7 05 08 00 00    	add    $0x805,%edi
		}

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm))) < 0)
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	ff 75 e4             	pushl  -0x1c(%ebp)
  801038:	56                   	push   %esi
  801039:	6a 00                	push   $0x0
  80103b:	e8 34 fc ff ff       	call   800c74 <sys_page_map>
  801040:	83 c4 20             	add    $0x20,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	79 12                	jns    801059 <fork+0x128>
			panic("fork: sys_page_map: %e", r);
  801047:	50                   	push   %eax
  801048:	68 8a 32 80 00       	push   $0x80328a
  80104d:	6a 62                	push   $0x62
  80104f:	68 6f 32 80 00       	push   $0x80326f
  801054:	e8 77 f1 ff ff       	call   8001d0 <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm))) < 0)
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	6a 00                	push   $0x0
  801060:	56                   	push   %esi
  801061:	6a 00                	push   $0x0
  801063:	e8 0c fc ff ff       	call   800c74 <sys_page_map>
  801068:	83 c4 20             	add    $0x20,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	79 3c                	jns    8010ab <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  80106f:	50                   	push   %eax
  801070:	68 8a 32 80 00       	push   $0x80328a
  801075:	6a 65                	push   $0x65
  801077:	68 6f 32 80 00       	push   $0x80326f
  80107c:	e8 4f f1 ff ff       	call   8001d0 <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	6a 05                	push   $0x5
  801086:	56                   	push   %esi
  801087:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108a:	56                   	push   %esi
  80108b:	6a 00                	push   $0x0
  80108d:	e8 e2 fb ff ff       	call   800c74 <sys_page_map>
  801092:	83 c4 20             	add    $0x20,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	79 12                	jns    8010ab <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  801099:	50                   	push   %eax
  80109a:	68 8a 32 80 00       	push   $0x80328a
  80109f:	6a 6a                	push   $0x6a
  8010a1:	68 6f 32 80 00       	push   $0x80326f
  8010a6:	e8 25 f1 ff ff       	call   8001d0 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  8010ab:	83 c3 01             	add    $0x1,%ebx
  8010ae:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8010b4:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8010ba:	0f 85 de fe ff ff    	jne    800f9e <fork+0x6d>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  8010c0:	83 ec 04             	sub    $0x4,%esp
  8010c3:	6a 07                	push   $0x7
  8010c5:	68 00 f0 bf ee       	push   $0xeebff000
  8010ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8010cd:	e8 5f fb ff ff       	call   800c31 <sys_page_alloc>
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 15                	jns    8010ee <fork+0x1bd>
		panic("sys_page_alloc: %e", r);
  8010d9:	50                   	push   %eax
  8010da:	68 8c 2d 80 00       	push   $0x802d8c
  8010df:	68 9e 00 00 00       	push   $0x9e
  8010e4:	68 6f 32 80 00       	push   $0x80326f
  8010e9:	e8 e2 f0 ff ff       	call   8001d0 <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	68 f6 17 80 00       	push   $0x8017f6
  8010f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f9:	e8 7e fc ff ff       	call   800d7c <sys_env_set_pgfault_upcall>
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	79 17                	jns    80111c <fork+0x1eb>
		panic("sys_pgfault_upcall error");
  801105:	83 ec 04             	sub    $0x4,%esp
  801108:	68 a1 32 80 00       	push   $0x8032a1
  80110d:	68 a1 00 00 00       	push   $0xa1
  801112:	68 6f 32 80 00       	push   $0x80326f
  801117:	e8 b4 f0 ff ff       	call   8001d0 <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	6a 02                	push   $0x2
  801121:	ff 75 e0             	pushl  -0x20(%ebp)
  801124:	e8 cf fb ff ff       	call   800cf8 <sys_env_set_status>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	79 15                	jns    801145 <fork+0x214>
		panic("sys_env_set_status: %e", r);
  801130:	50                   	push   %eax
  801131:	68 ba 32 80 00       	push   $0x8032ba
  801136:	68 a7 00 00 00       	push   $0xa7
  80113b:	68 6f 32 80 00       	push   $0x80326f
  801140:	e8 8b f0 ff ff       	call   8001d0 <_panic>

	return envid;
  801145:	8b 45 e0             	mov    -0x20(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  801148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114b:	5b                   	pop    %ebx
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <sfork>:

// Challenge!
int
sfork(void)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801156:	68 d1 32 80 00       	push   $0x8032d1
  80115b:	68 b2 00 00 00       	push   $0xb2
  801160:	68 6f 32 80 00       	push   $0x80326f
  801165:	e8 66 f0 ff ff       	call   8001d0 <_panic>

0080116a <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801176:	6a 00                	push   $0x0
  801178:	ff 75 08             	pushl  0x8(%ebp)
  80117b:	e8 02 0e 00 00       	call   801f82 <open>
  801180:	89 c7                	mov    %eax,%edi
  801182:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	0f 88 ba 04 00 00    	js     80164d <spawn+0x4e3>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801193:	83 ec 04             	sub    $0x4,%esp
  801196:	68 00 02 00 00       	push   $0x200
  80119b:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8011a1:	50                   	push   %eax
  8011a2:	57                   	push   %edi
  8011a3:	e8 e0 09 00 00       	call   801b88 <readn>
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	3d 00 02 00 00       	cmp    $0x200,%eax
  8011b0:	75 0c                	jne    8011be <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8011b2:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8011b9:	45 4c 46 
  8011bc:	74 33                	je     8011f1 <spawn+0x87>
		close(fd);
  8011be:	83 ec 0c             	sub    $0xc,%esp
  8011c1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8011c7:	e8 ef 07 00 00       	call   8019bb <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8011cc:	83 c4 0c             	add    $0xc,%esp
  8011cf:	68 7f 45 4c 46       	push   $0x464c457f
  8011d4:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8011da:	68 e7 32 80 00       	push   $0x8032e7
  8011df:	e8 c5 f0 ff ff       	call   8002a9 <cprintf>
		return -E_NOT_EXEC;
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8011ec:	e9 bc 04 00 00       	jmp    8016ad <spawn+0x543>
  8011f1:	b8 07 00 00 00       	mov    $0x7,%eax
  8011f6:	cd 30                	int    $0x30
  8011f8:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8011fe:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801204:	85 c0                	test   %eax,%eax
  801206:	0f 88 49 04 00 00    	js     801655 <spawn+0x4eb>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80120c:	89 c6                	mov    %eax,%esi
  80120e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801214:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801217:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80121d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801223:	b9 11 00 00 00       	mov    $0x11,%ecx
  801228:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80122a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801230:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80123b:	be 00 00 00 00       	mov    $0x0,%esi
  801240:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801243:	eb 13                	jmp    801258 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801245:	83 ec 0c             	sub    $0xc,%esp
  801248:	50                   	push   %eax
  801249:	e8 a7 f5 ff ff       	call   8007f5 <strlen>
  80124e:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801252:	83 c3 01             	add    $0x1,%ebx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80125f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801262:	85 c0                	test   %eax,%eax
  801264:	75 df                	jne    801245 <spawn+0xdb>
  801266:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80126c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801272:	bf 00 10 40 00       	mov    $0x401000,%edi
  801277:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801279:	89 fa                	mov    %edi,%edx
  80127b:	83 e2 fc             	and    $0xfffffffc,%edx
  80127e:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801285:	29 c2                	sub    %eax,%edx
  801287:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80128d:	8d 42 f8             	lea    -0x8(%edx),%eax
  801290:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801295:	0f 86 ca 03 00 00    	jbe    801665 <spawn+0x4fb>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80129b:	83 ec 04             	sub    $0x4,%esp
  80129e:	6a 07                	push   $0x7
  8012a0:	68 00 00 40 00       	push   $0x400000
  8012a5:	6a 00                	push   $0x0
  8012a7:	e8 85 f9 ff ff       	call   800c31 <sys_page_alloc>
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	0f 88 b5 03 00 00    	js     80166c <spawn+0x502>
  8012b7:	be 00 00 00 00       	mov    $0x0,%esi
  8012bc:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8012c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012c5:	eb 30                	jmp    8012f7 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8012c7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8012cd:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8012d3:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8012dc:	57                   	push   %edi
  8012dd:	e8 4c f5 ff ff       	call   80082e <strcpy>
		string_store += strlen(argv[i]) + 1;
  8012e2:	83 c4 04             	add    $0x4,%esp
  8012e5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8012e8:	e8 08 f5 ff ff       	call   8007f5 <strlen>
  8012ed:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8012f1:	83 c6 01             	add    $0x1,%esi
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8012fd:	7f c8                	jg     8012c7 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8012ff:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801305:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  80130b:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801312:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801318:	74 19                	je     801333 <spawn+0x1c9>
  80131a:	68 74 33 80 00       	push   $0x803374
  80131f:	68 01 33 80 00       	push   $0x803301
  801324:	68 f1 00 00 00       	push   $0xf1
  801329:	68 16 33 80 00       	push   $0x803316
  80132e:	e8 9d ee ff ff       	call   8001d0 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801333:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801339:	89 f8                	mov    %edi,%eax
  80133b:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801340:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801343:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801349:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80134c:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801352:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	6a 07                	push   $0x7
  80135d:	68 00 d0 bf ee       	push   $0xeebfd000
  801362:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801368:	68 00 00 40 00       	push   $0x400000
  80136d:	6a 00                	push   $0x0
  80136f:	e8 00 f9 ff ff       	call   800c74 <sys_page_map>
  801374:	89 c3                	mov    %eax,%ebx
  801376:	83 c4 20             	add    $0x20,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	0f 88 1a 03 00 00    	js     80169b <spawn+0x531>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	68 00 00 40 00       	push   $0x400000
  801389:	6a 00                	push   $0x0
  80138b:	e8 26 f9 ff ff       	call   800cb6 <sys_page_unmap>
  801390:	89 c3                	mov    %eax,%ebx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	0f 88 fe 02 00 00    	js     80169b <spawn+0x531>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80139d:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8013a3:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8013aa:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8013b0:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8013b7:	00 00 00 
  8013ba:	e9 8a 01 00 00       	jmp    801549 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  8013bf:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8013c5:	83 38 01             	cmpl   $0x1,(%eax)
  8013c8:	0f 85 6d 01 00 00    	jne    80153b <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8013ce:	89 c7                	mov    %eax,%edi
  8013d0:	8b 40 18             	mov    0x18(%eax),%eax
  8013d3:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8013d9:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8013dc:	83 f8 01             	cmp    $0x1,%eax
  8013df:	19 c0                	sbb    %eax,%eax
  8013e1:	83 e0 fe             	and    $0xfffffffe,%eax
  8013e4:	83 c0 07             	add    $0x7,%eax
  8013e7:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8013ed:	89 f8                	mov    %edi,%eax
  8013ef:	8b 7f 04             	mov    0x4(%edi),%edi
  8013f2:	89 f9                	mov    %edi,%ecx
  8013f4:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8013fa:	8b 78 10             	mov    0x10(%eax),%edi
  8013fd:	8b 70 14             	mov    0x14(%eax),%esi
  801400:	89 f2                	mov    %esi,%edx
  801402:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801408:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80140b:	89 f0                	mov    %esi,%eax
  80140d:	25 ff 0f 00 00       	and    $0xfff,%eax
  801412:	74 14                	je     801428 <spawn+0x2be>
		va -= i;
  801414:	29 c6                	sub    %eax,%esi
		memsz += i;
  801416:	01 c2                	add    %eax,%edx
  801418:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80141e:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801420:	29 c1                	sub    %eax,%ecx
  801422:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801428:	bb 00 00 00 00       	mov    $0x0,%ebx
  80142d:	e9 f7 00 00 00       	jmp    801529 <spawn+0x3bf>
		if (i >= filesz) {
  801432:	39 df                	cmp    %ebx,%edi
  801434:	77 27                	ja     80145d <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801436:	83 ec 04             	sub    $0x4,%esp
  801439:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80143f:	56                   	push   %esi
  801440:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801446:	e8 e6 f7 ff ff       	call   800c31 <sys_page_alloc>
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	85 c0                	test   %eax,%eax
  801450:	0f 89 c7 00 00 00    	jns    80151d <spawn+0x3b3>
  801456:	89 c3                	mov    %eax,%ebx
  801458:	e9 1d 02 00 00       	jmp    80167a <spawn+0x510>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80145d:	83 ec 04             	sub    $0x4,%esp
  801460:	6a 07                	push   $0x7
  801462:	68 00 00 40 00       	push   $0x400000
  801467:	6a 00                	push   $0x0
  801469:	e8 c3 f7 ff ff       	call   800c31 <sys_page_alloc>
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	0f 88 f7 01 00 00    	js     801670 <spawn+0x506>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801482:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80148f:	e8 c9 07 00 00       	call   801c5d <seek>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	0f 88 d5 01 00 00    	js     801674 <spawn+0x50a>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	89 f8                	mov    %edi,%eax
  8014a4:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8014aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014af:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8014b4:	0f 47 c1             	cmova  %ecx,%eax
  8014b7:	50                   	push   %eax
  8014b8:	68 00 00 40 00       	push   $0x400000
  8014bd:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8014c3:	e8 c0 06 00 00       	call   801b88 <readn>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	0f 88 a5 01 00 00    	js     801678 <spawn+0x50e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8014dc:	56                   	push   %esi
  8014dd:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8014e3:	68 00 00 40 00       	push   $0x400000
  8014e8:	6a 00                	push   $0x0
  8014ea:	e8 85 f7 ff ff       	call   800c74 <sys_page_map>
  8014ef:	83 c4 20             	add    $0x20,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	79 15                	jns    80150b <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  8014f6:	50                   	push   %eax
  8014f7:	68 22 33 80 00       	push   $0x803322
  8014fc:	68 24 01 00 00       	push   $0x124
  801501:	68 16 33 80 00       	push   $0x803316
  801506:	e8 c5 ec ff ff       	call   8001d0 <_panic>
			sys_page_unmap(0, UTEMP);
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	68 00 00 40 00       	push   $0x400000
  801513:	6a 00                	push   $0x0
  801515:	e8 9c f7 ff ff       	call   800cb6 <sys_page_unmap>
  80151a:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80151d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801523:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801529:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80152f:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801535:	0f 87 f7 fe ff ff    	ja     801432 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80153b:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801542:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801549:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801550:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801556:	0f 8c 63 fe ff ff    	jl     8013bf <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80155c:	83 ec 0c             	sub    $0xc,%esp
  80155f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801565:	e8 51 04 00 00       	call   8019bb <close>
  80156a:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint32_t pn;
	int r;
	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++)
  80156d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801572:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801578:	89 d8                	mov    %ebx,%eax
  80157a:	c1 e0 0c             	shl    $0xc,%eax
	{
                if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & PTE_SHARE) && (uvpt[pn] & PTE_P))
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	c1 ea 16             	shr    $0x16,%edx
  801582:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801589:	f6 c2 01             	test   $0x1,%dl
  80158c:	74 57                	je     8015e5 <spawn+0x47b>
  80158e:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801595:	f6 c6 04             	test   $0x4,%dh
  801598:	74 4b                	je     8015e5 <spawn+0x47b>
  80159a:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  8015a1:	f6 c2 01             	test   $0x1,%dl
  8015a4:	74 3f                	je     8015e5 <spawn+0x47b>
		{
                        if ((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), child, 
				(void *)(pn*PGSIZE), (uvpt[pn]&PTE_SYSCALL))) < 0)
  8015a6:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
	int r;
	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++)
	{
                if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & PTE_SHARE) && (uvpt[pn] & PTE_P))
		{
                        if ((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), child, 
  8015ad:	8b 0d 08 50 80 00    	mov    0x805008,%ecx
  8015b3:	8b 49 48             	mov    0x48(%ecx),%ecx
  8015b6:	83 ec 0c             	sub    $0xc,%esp
  8015b9:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015bf:	52                   	push   %edx
  8015c0:	50                   	push   %eax
  8015c1:	56                   	push   %esi
  8015c2:	50                   	push   %eax
  8015c3:	51                   	push   %ecx
  8015c4:	e8 ab f6 ff ff       	call   800c74 <sys_page_map>
  8015c9:	83 c4 20             	add    $0x20,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	79 15                	jns    8015e5 <spawn+0x47b>
				(void *)(pn*PGSIZE), (uvpt[pn]&PTE_SYSCALL))) < 0)
                        	panic("spawn: sys_page_map: %e", r);
  8015d0:	50                   	push   %eax
  8015d1:	68 3f 33 80 00       	push   $0x80333f
  8015d6:	68 38 01 00 00       	push   $0x138
  8015db:	68 16 33 80 00       	push   $0x803316
  8015e0:	e8 eb eb ff ff       	call   8001d0 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint32_t pn;
	int r;
	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++)
  8015e5:	83 c3 01             	add    $0x1,%ebx
  8015e8:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8015ee:	75 88                	jne    801578 <spawn+0x40e>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801600:	e8 35 f7 ff ff       	call   800d3a <sys_env_set_trapframe>
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	85 c0                	test   %eax,%eax
  80160a:	79 15                	jns    801621 <spawn+0x4b7>
		panic("sys_env_set_trapframe: %e", r);
  80160c:	50                   	push   %eax
  80160d:	68 57 33 80 00       	push   $0x803357
  801612:	68 85 00 00 00       	push   $0x85
  801617:	68 16 33 80 00       	push   $0x803316
  80161c:	e8 af eb ff ff       	call   8001d0 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	6a 02                	push   $0x2
  801626:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80162c:	e8 c7 f6 ff ff       	call   800cf8 <sys_env_set_status>
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	85 c0                	test   %eax,%eax
  801636:	79 25                	jns    80165d <spawn+0x4f3>
		panic("sys_env_set_status: %e", r);
  801638:	50                   	push   %eax
  801639:	68 ba 32 80 00       	push   $0x8032ba
  80163e:	68 88 00 00 00       	push   $0x88
  801643:	68 16 33 80 00       	push   $0x803316
  801648:	e8 83 eb ff ff       	call   8001d0 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80164d:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801653:	eb 58                	jmp    8016ad <spawn+0x543>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801655:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80165b:	eb 50                	jmp    8016ad <spawn+0x543>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80165d:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801663:	eb 48                	jmp    8016ad <spawn+0x543>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801665:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80166a:	eb 41                	jmp    8016ad <spawn+0x543>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	eb 3d                	jmp    8016ad <spawn+0x543>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801670:	89 c3                	mov    %eax,%ebx
  801672:	eb 06                	jmp    80167a <spawn+0x510>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801674:	89 c3                	mov    %eax,%ebx
  801676:	eb 02                	jmp    80167a <spawn+0x510>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801678:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  80167a:	83 ec 0c             	sub    $0xc,%esp
  80167d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801683:	e8 2a f5 ff ff       	call   800bb2 <sys_env_destroy>
	close(fd);
  801688:	83 c4 04             	add    $0x4,%esp
  80168b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801691:	e8 25 03 00 00       	call   8019bb <close>
	return r;
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	eb 12                	jmp    8016ad <spawn+0x543>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	68 00 00 40 00       	push   $0x400000
  8016a3:	6a 00                	push   $0x0
  8016a5:	e8 0c f6 ff ff       	call   800cb6 <sys_page_unmap>
  8016aa:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8016ad:	89 d8                	mov    %ebx,%eax
  8016af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b2:	5b                   	pop    %ebx
  8016b3:	5e                   	pop    %esi
  8016b4:	5f                   	pop    %edi
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	56                   	push   %esi
  8016bb:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8016bc:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8016bf:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8016c4:	eb 03                	jmp    8016c9 <spawnl+0x12>
		argc++;
  8016c6:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8016c9:	83 c2 04             	add    $0x4,%edx
  8016cc:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8016d0:	75 f4                	jne    8016c6 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8016d2:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8016d9:	83 e2 f0             	and    $0xfffffff0,%edx
  8016dc:	29 d4                	sub    %edx,%esp
  8016de:	8d 54 24 03          	lea    0x3(%esp),%edx
  8016e2:	c1 ea 02             	shr    $0x2,%edx
  8016e5:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  8016ec:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8016ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f1:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  8016f8:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  8016ff:	00 
  801700:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801702:	b8 00 00 00 00       	mov    $0x0,%eax
  801707:	eb 0a                	jmp    801713 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801709:	83 c0 01             	add    $0x1,%eax
  80170c:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801710:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801713:	39 d0                	cmp    %edx,%eax
  801715:	75 f2                	jne    801709 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	56                   	push   %esi
  80171b:	ff 75 08             	pushl  0x8(%ebp)
  80171e:	e8 47 fa ff ff       	call   80116a <spawn>
}
  801723:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801726:	5b                   	pop    %ebx
  801727:	5e                   	pop    %esi
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801732:	85 f6                	test   %esi,%esi
  801734:	75 16                	jne    80174c <wait+0x22>
  801736:	68 9a 33 80 00       	push   $0x80339a
  80173b:	68 01 33 80 00       	push   $0x803301
  801740:	6a 09                	push   $0x9
  801742:	68 a5 33 80 00       	push   $0x8033a5
  801747:	e8 84 ea ff ff       	call   8001d0 <_panic>
	e = &envs[ENVX(envid)];
  80174c:	89 f3                	mov    %esi,%ebx
  80174e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801754:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801757:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80175d:	eb 05                	jmp    801764 <wait+0x3a>
		sys_yield();
  80175f:	e8 ae f4 ff ff       	call   800c12 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801764:	8b 43 48             	mov    0x48(%ebx),%eax
  801767:	39 c6                	cmp    %eax,%esi
  801769:	75 07                	jne    801772 <wait+0x48>
  80176b:	8b 43 54             	mov    0x54(%ebx),%eax
  80176e:	85 c0                	test   %eax,%eax
  801770:	75 ed                	jne    80175f <wait+0x35>
		sys_yield();
}
  801772:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80177f:	83 3d 0c 50 80 00 00 	cmpl   $0x0,0x80500c
  801786:	75 64                	jne    8017ec <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801788:	a1 08 50 80 00       	mov    0x805008,%eax
  80178d:	8b 40 48             	mov    0x48(%eax),%eax
  801790:	83 ec 04             	sub    $0x4,%esp
  801793:	6a 07                	push   $0x7
  801795:	68 00 f0 bf ee       	push   $0xeebff000
  80179a:	50                   	push   %eax
  80179b:	e8 91 f4 ff ff       	call   800c31 <sys_page_alloc>
		if ( r != 0)
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	74 14                	je     8017bb <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  8017a7:	83 ec 04             	sub    $0x4,%esp
  8017aa:	68 b0 33 80 00       	push   $0x8033b0
  8017af:	6a 24                	push   $0x24
  8017b1:	68 fe 33 80 00       	push   $0x8033fe
  8017b6:	e8 15 ea ff ff       	call   8001d0 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  8017bb:	a1 08 50 80 00       	mov    0x805008,%eax
  8017c0:	8b 40 48             	mov    0x48(%eax),%eax
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	68 f6 17 80 00       	push   $0x8017f6
  8017cb:	50                   	push   %eax
  8017cc:	e8 ab f5 ff ff       	call   800d7c <sys_env_set_pgfault_upcall>
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	79 14                	jns    8017ec <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  8017d8:	83 ec 04             	sub    $0x4,%esp
  8017db:	68 dc 33 80 00       	push   $0x8033dc
  8017e0:	6a 27                	push   $0x27
  8017e2:	68 fe 33 80 00       	push   $0x8033fe
  8017e7:	e8 e4 e9 ff ff       	call   8001d0 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	a3 0c 50 80 00       	mov    %eax,0x80500c
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8017f6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8017f7:	a1 0c 50 80 00       	mov    0x80500c,%eax
	call *%eax
  8017fc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8017fe:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  801801:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  801805:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  801807:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  80180b:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  80180c:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  80180f:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  801811:	83 c4 08             	add    $0x8,%esp
popal
  801814:	61                   	popa   
addl $0x4, %esp
  801815:	83 c4 04             	add    $0x4,%esp
popfl
  801818:	9d                   	popf   
popl %esp
  801819:	5c                   	pop    %esp
ret
  80181a:	c3                   	ret    

0080181b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	05 00 00 00 30       	add    $0x30000000,%eax
  801826:	c1 e8 0c             	shr    $0xc,%eax
}
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    

0080182b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	05 00 00 00 30       	add    $0x30000000,%eax
  801836:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80183b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801840:	5d                   	pop    %ebp
  801841:	c3                   	ret    

00801842 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801848:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80184d:	89 c2                	mov    %eax,%edx
  80184f:	c1 ea 16             	shr    $0x16,%edx
  801852:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801859:	f6 c2 01             	test   $0x1,%dl
  80185c:	74 11                	je     80186f <fd_alloc+0x2d>
  80185e:	89 c2                	mov    %eax,%edx
  801860:	c1 ea 0c             	shr    $0xc,%edx
  801863:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80186a:	f6 c2 01             	test   $0x1,%dl
  80186d:	75 09                	jne    801878 <fd_alloc+0x36>
			*fd_store = fd;
  80186f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801871:	b8 00 00 00 00       	mov    $0x0,%eax
  801876:	eb 17                	jmp    80188f <fd_alloc+0x4d>
  801878:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80187d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801882:	75 c9                	jne    80184d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801884:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80188a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80188f:	5d                   	pop    %ebp
  801890:	c3                   	ret    

00801891 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801897:	83 f8 1f             	cmp    $0x1f,%eax
  80189a:	77 36                	ja     8018d2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80189c:	c1 e0 0c             	shl    $0xc,%eax
  80189f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8018a4:	89 c2                	mov    %eax,%edx
  8018a6:	c1 ea 16             	shr    $0x16,%edx
  8018a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8018b0:	f6 c2 01             	test   $0x1,%dl
  8018b3:	74 24                	je     8018d9 <fd_lookup+0x48>
  8018b5:	89 c2                	mov    %eax,%edx
  8018b7:	c1 ea 0c             	shr    $0xc,%edx
  8018ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018c1:	f6 c2 01             	test   $0x1,%dl
  8018c4:	74 1a                	je     8018e0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8018c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c9:	89 02                	mov    %eax,(%edx)
	return 0;
  8018cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d0:	eb 13                	jmp    8018e5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018d7:	eb 0c                	jmp    8018e5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018de:	eb 05                	jmp    8018e5 <fd_lookup+0x54>
  8018e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f0:	ba 88 34 80 00       	mov    $0x803488,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8018f5:	eb 13                	jmp    80190a <dev_lookup+0x23>
  8018f7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8018fa:	39 08                	cmp    %ecx,(%eax)
  8018fc:	75 0c                	jne    80190a <dev_lookup+0x23>
			*dev = devtab[i];
  8018fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801901:	89 01                	mov    %eax,(%ecx)
			return 0;
  801903:	b8 00 00 00 00       	mov    $0x0,%eax
  801908:	eb 2e                	jmp    801938 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80190a:	8b 02                	mov    (%edx),%eax
  80190c:	85 c0                	test   %eax,%eax
  80190e:	75 e7                	jne    8018f7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801910:	a1 08 50 80 00       	mov    0x805008,%eax
  801915:	8b 40 48             	mov    0x48(%eax),%eax
  801918:	83 ec 04             	sub    $0x4,%esp
  80191b:	51                   	push   %ecx
  80191c:	50                   	push   %eax
  80191d:	68 0c 34 80 00       	push   $0x80340c
  801922:	e8 82 e9 ff ff       	call   8002a9 <cprintf>
	*dev = 0;
  801927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	56                   	push   %esi
  80193e:	53                   	push   %ebx
  80193f:	83 ec 10             	sub    $0x10,%esp
  801942:	8b 75 08             	mov    0x8(%ebp),%esi
  801945:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801948:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194b:	50                   	push   %eax
  80194c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801952:	c1 e8 0c             	shr    $0xc,%eax
  801955:	50                   	push   %eax
  801956:	e8 36 ff ff ff       	call   801891 <fd_lookup>
  80195b:	83 c4 08             	add    $0x8,%esp
  80195e:	85 c0                	test   %eax,%eax
  801960:	78 05                	js     801967 <fd_close+0x2d>
	    || fd != fd2)
  801962:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801965:	74 0c                	je     801973 <fd_close+0x39>
		return (must_exist ? r : 0);
  801967:	84 db                	test   %bl,%bl
  801969:	ba 00 00 00 00       	mov    $0x0,%edx
  80196e:	0f 44 c2             	cmove  %edx,%eax
  801971:	eb 41                	jmp    8019b4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801979:	50                   	push   %eax
  80197a:	ff 36                	pushl  (%esi)
  80197c:	e8 66 ff ff ff       	call   8018e7 <dev_lookup>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	78 1a                	js     8019a4 <fd_close+0x6a>
		if (dev->dev_close)
  80198a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801990:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801995:	85 c0                	test   %eax,%eax
  801997:	74 0b                	je     8019a4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801999:	83 ec 0c             	sub    $0xc,%esp
  80199c:	56                   	push   %esi
  80199d:	ff d0                	call   *%eax
  80199f:	89 c3                	mov    %eax,%ebx
  8019a1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	56                   	push   %esi
  8019a8:	6a 00                	push   $0x0
  8019aa:	e8 07 f3 ff ff       	call   800cb6 <sys_page_unmap>
	return r;
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	89 d8                	mov    %ebx,%eax
}
  8019b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b7:	5b                   	pop    %ebx
  8019b8:	5e                   	pop    %esi
  8019b9:	5d                   	pop    %ebp
  8019ba:	c3                   	ret    

008019bb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c4:	50                   	push   %eax
  8019c5:	ff 75 08             	pushl  0x8(%ebp)
  8019c8:	e8 c4 fe ff ff       	call   801891 <fd_lookup>
  8019cd:	83 c4 08             	add    $0x8,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 10                	js     8019e4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8019d4:	83 ec 08             	sub    $0x8,%esp
  8019d7:	6a 01                	push   $0x1
  8019d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019dc:	e8 59 ff ff ff       	call   80193a <fd_close>
  8019e1:	83 c4 10             	add    $0x10,%esp
}
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <close_all>:

void
close_all(void)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8019ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	53                   	push   %ebx
  8019f6:	e8 c0 ff ff ff       	call   8019bb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8019fb:	83 c3 01             	add    $0x1,%ebx
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	83 fb 20             	cmp    $0x20,%ebx
  801a04:	75 ec                	jne    8019f2 <close_all+0xc>
		close(i);
}
  801a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	57                   	push   %edi
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	83 ec 2c             	sub    $0x2c,%esp
  801a14:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a17:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a1a:	50                   	push   %eax
  801a1b:	ff 75 08             	pushl  0x8(%ebp)
  801a1e:	e8 6e fe ff ff       	call   801891 <fd_lookup>
  801a23:	83 c4 08             	add    $0x8,%esp
  801a26:	85 c0                	test   %eax,%eax
  801a28:	0f 88 c1 00 00 00    	js     801aef <dup+0xe4>
		return r;
	close(newfdnum);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	56                   	push   %esi
  801a32:	e8 84 ff ff ff       	call   8019bb <close>

	newfd = INDEX2FD(newfdnum);
  801a37:	89 f3                	mov    %esi,%ebx
  801a39:	c1 e3 0c             	shl    $0xc,%ebx
  801a3c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801a42:	83 c4 04             	add    $0x4,%esp
  801a45:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a48:	e8 de fd ff ff       	call   80182b <fd2data>
  801a4d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801a4f:	89 1c 24             	mov    %ebx,(%esp)
  801a52:	e8 d4 fd ff ff       	call   80182b <fd2data>
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801a5d:	89 f8                	mov    %edi,%eax
  801a5f:	c1 e8 16             	shr    $0x16,%eax
  801a62:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a69:	a8 01                	test   $0x1,%al
  801a6b:	74 37                	je     801aa4 <dup+0x99>
  801a6d:	89 f8                	mov    %edi,%eax
  801a6f:	c1 e8 0c             	shr    $0xc,%eax
  801a72:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a79:	f6 c2 01             	test   $0x1,%dl
  801a7c:	74 26                	je     801aa4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	25 07 0e 00 00       	and    $0xe07,%eax
  801a8d:	50                   	push   %eax
  801a8e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801a91:	6a 00                	push   $0x0
  801a93:	57                   	push   %edi
  801a94:	6a 00                	push   $0x0
  801a96:	e8 d9 f1 ff ff       	call   800c74 <sys_page_map>
  801a9b:	89 c7                	mov    %eax,%edi
  801a9d:	83 c4 20             	add    $0x20,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 2e                	js     801ad2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801aa4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801aa7:	89 d0                	mov    %edx,%eax
  801aa9:	c1 e8 0c             	shr    $0xc,%eax
  801aac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ab3:	83 ec 0c             	sub    $0xc,%esp
  801ab6:	25 07 0e 00 00       	and    $0xe07,%eax
  801abb:	50                   	push   %eax
  801abc:	53                   	push   %ebx
  801abd:	6a 00                	push   $0x0
  801abf:	52                   	push   %edx
  801ac0:	6a 00                	push   $0x0
  801ac2:	e8 ad f1 ff ff       	call   800c74 <sys_page_map>
  801ac7:	89 c7                	mov    %eax,%edi
  801ac9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801acc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ace:	85 ff                	test   %edi,%edi
  801ad0:	79 1d                	jns    801aef <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ad2:	83 ec 08             	sub    $0x8,%esp
  801ad5:	53                   	push   %ebx
  801ad6:	6a 00                	push   $0x0
  801ad8:	e8 d9 f1 ff ff       	call   800cb6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801add:	83 c4 08             	add    $0x8,%esp
  801ae0:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 cc f1 ff ff       	call   800cb6 <sys_page_unmap>
	return r;
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	89 f8                	mov    %edi,%eax
}
  801aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5f                   	pop    %edi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	53                   	push   %ebx
  801afb:	83 ec 14             	sub    $0x14,%esp
  801afe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b01:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b04:	50                   	push   %eax
  801b05:	53                   	push   %ebx
  801b06:	e8 86 fd ff ff       	call   801891 <fd_lookup>
  801b0b:	83 c4 08             	add    $0x8,%esp
  801b0e:	89 c2                	mov    %eax,%edx
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 6d                	js     801b81 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b14:	83 ec 08             	sub    $0x8,%esp
  801b17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1a:	50                   	push   %eax
  801b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1e:	ff 30                	pushl  (%eax)
  801b20:	e8 c2 fd ff ff       	call   8018e7 <dev_lookup>
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	78 4c                	js     801b78 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b2f:	8b 42 08             	mov    0x8(%edx),%eax
  801b32:	83 e0 03             	and    $0x3,%eax
  801b35:	83 f8 01             	cmp    $0x1,%eax
  801b38:	75 21                	jne    801b5b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801b3a:	a1 08 50 80 00       	mov    0x805008,%eax
  801b3f:	8b 40 48             	mov    0x48(%eax),%eax
  801b42:	83 ec 04             	sub    $0x4,%esp
  801b45:	53                   	push   %ebx
  801b46:	50                   	push   %eax
  801b47:	68 4d 34 80 00       	push   $0x80344d
  801b4c:	e8 58 e7 ff ff       	call   8002a9 <cprintf>
		return -E_INVAL;
  801b51:	83 c4 10             	add    $0x10,%esp
  801b54:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b59:	eb 26                	jmp    801b81 <read+0x8a>
	}
	if (!dev->dev_read)
  801b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5e:	8b 40 08             	mov    0x8(%eax),%eax
  801b61:	85 c0                	test   %eax,%eax
  801b63:	74 17                	je     801b7c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801b65:	83 ec 04             	sub    $0x4,%esp
  801b68:	ff 75 10             	pushl  0x10(%ebp)
  801b6b:	ff 75 0c             	pushl  0xc(%ebp)
  801b6e:	52                   	push   %edx
  801b6f:	ff d0                	call   *%eax
  801b71:	89 c2                	mov    %eax,%edx
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	eb 09                	jmp    801b81 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b78:	89 c2                	mov    %eax,%edx
  801b7a:	eb 05                	jmp    801b81 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801b7c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801b81:	89 d0                	mov    %edx,%eax
  801b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	57                   	push   %edi
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b94:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b9c:	eb 21                	jmp    801bbf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b9e:	83 ec 04             	sub    $0x4,%esp
  801ba1:	89 f0                	mov    %esi,%eax
  801ba3:	29 d8                	sub    %ebx,%eax
  801ba5:	50                   	push   %eax
  801ba6:	89 d8                	mov    %ebx,%eax
  801ba8:	03 45 0c             	add    0xc(%ebp),%eax
  801bab:	50                   	push   %eax
  801bac:	57                   	push   %edi
  801bad:	e8 45 ff ff ff       	call   801af7 <read>
		if (m < 0)
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	78 10                	js     801bc9 <readn+0x41>
			return m;
		if (m == 0)
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	74 0a                	je     801bc7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bbd:	01 c3                	add    %eax,%ebx
  801bbf:	39 f3                	cmp    %esi,%ebx
  801bc1:	72 db                	jb     801b9e <readn+0x16>
  801bc3:	89 d8                	mov    %ebx,%eax
  801bc5:	eb 02                	jmp    801bc9 <readn+0x41>
  801bc7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5f                   	pop    %edi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 14             	sub    $0x14,%esp
  801bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bdb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bde:	50                   	push   %eax
  801bdf:	53                   	push   %ebx
  801be0:	e8 ac fc ff ff       	call   801891 <fd_lookup>
  801be5:	83 c4 08             	add    $0x8,%esp
  801be8:	89 c2                	mov    %eax,%edx
  801bea:	85 c0                	test   %eax,%eax
  801bec:	78 68                	js     801c56 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bee:	83 ec 08             	sub    $0x8,%esp
  801bf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf4:	50                   	push   %eax
  801bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf8:	ff 30                	pushl  (%eax)
  801bfa:	e8 e8 fc ff ff       	call   8018e7 <dev_lookup>
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 47                	js     801c4d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c09:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c0d:	75 21                	jne    801c30 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801c0f:	a1 08 50 80 00       	mov    0x805008,%eax
  801c14:	8b 40 48             	mov    0x48(%eax),%eax
  801c17:	83 ec 04             	sub    $0x4,%esp
  801c1a:	53                   	push   %ebx
  801c1b:	50                   	push   %eax
  801c1c:	68 69 34 80 00       	push   $0x803469
  801c21:	e8 83 e6 ff ff       	call   8002a9 <cprintf>
		return -E_INVAL;
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c2e:	eb 26                	jmp    801c56 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c33:	8b 52 0c             	mov    0xc(%edx),%edx
  801c36:	85 d2                	test   %edx,%edx
  801c38:	74 17                	je     801c51 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c3a:	83 ec 04             	sub    $0x4,%esp
  801c3d:	ff 75 10             	pushl  0x10(%ebp)
  801c40:	ff 75 0c             	pushl  0xc(%ebp)
  801c43:	50                   	push   %eax
  801c44:	ff d2                	call   *%edx
  801c46:	89 c2                	mov    %eax,%edx
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	eb 09                	jmp    801c56 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c4d:	89 c2                	mov    %eax,%edx
  801c4f:	eb 05                	jmp    801c56 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801c51:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801c56:	89 d0                	mov    %edx,%eax
  801c58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <seek>:

int
seek(int fdnum, off_t offset)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c63:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c66:	50                   	push   %eax
  801c67:	ff 75 08             	pushl  0x8(%ebp)
  801c6a:	e8 22 fc ff ff       	call   801891 <fd_lookup>
  801c6f:	83 c4 08             	add    $0x8,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	78 0e                	js     801c84 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801c76:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c79:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c7c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	53                   	push   %ebx
  801c8a:	83 ec 14             	sub    $0x14,%esp
  801c8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c93:	50                   	push   %eax
  801c94:	53                   	push   %ebx
  801c95:	e8 f7 fb ff ff       	call   801891 <fd_lookup>
  801c9a:	83 c4 08             	add    $0x8,%esp
  801c9d:	89 c2                	mov    %eax,%edx
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 65                	js     801d08 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ca3:	83 ec 08             	sub    $0x8,%esp
  801ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca9:	50                   	push   %eax
  801caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cad:	ff 30                	pushl  (%eax)
  801caf:	e8 33 fc ff ff       	call   8018e7 <dev_lookup>
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 44                	js     801cff <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801cc2:	75 21                	jne    801ce5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801cc4:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801cc9:	8b 40 48             	mov    0x48(%eax),%eax
  801ccc:	83 ec 04             	sub    $0x4,%esp
  801ccf:	53                   	push   %ebx
  801cd0:	50                   	push   %eax
  801cd1:	68 2c 34 80 00       	push   $0x80342c
  801cd6:	e8 ce e5 ff ff       	call   8002a9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ce3:	eb 23                	jmp    801d08 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801ce5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce8:	8b 52 18             	mov    0x18(%edx),%edx
  801ceb:	85 d2                	test   %edx,%edx
  801ced:	74 14                	je     801d03 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801cef:	83 ec 08             	sub    $0x8,%esp
  801cf2:	ff 75 0c             	pushl  0xc(%ebp)
  801cf5:	50                   	push   %eax
  801cf6:	ff d2                	call   *%edx
  801cf8:	89 c2                	mov    %eax,%edx
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	eb 09                	jmp    801d08 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cff:	89 c2                	mov    %eax,%edx
  801d01:	eb 05                	jmp    801d08 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801d03:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801d08:	89 d0                	mov    %edx,%eax
  801d0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	53                   	push   %ebx
  801d13:	83 ec 14             	sub    $0x14,%esp
  801d16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d1c:	50                   	push   %eax
  801d1d:	ff 75 08             	pushl  0x8(%ebp)
  801d20:	e8 6c fb ff ff       	call   801891 <fd_lookup>
  801d25:	83 c4 08             	add    $0x8,%esp
  801d28:	89 c2                	mov    %eax,%edx
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 58                	js     801d86 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d34:	50                   	push   %eax
  801d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d38:	ff 30                	pushl  (%eax)
  801d3a:	e8 a8 fb ff ff       	call   8018e7 <dev_lookup>
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 37                	js     801d7d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d49:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801d4d:	74 32                	je     801d81 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d4f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d52:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d59:	00 00 00 
	stat->st_isdir = 0;
  801d5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d63:	00 00 00 
	stat->st_dev = dev;
  801d66:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d6c:	83 ec 08             	sub    $0x8,%esp
  801d6f:	53                   	push   %ebx
  801d70:	ff 75 f0             	pushl  -0x10(%ebp)
  801d73:	ff 50 14             	call   *0x14(%eax)
  801d76:	89 c2                	mov    %eax,%edx
  801d78:	83 c4 10             	add    $0x10,%esp
  801d7b:	eb 09                	jmp    801d86 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d7d:	89 c2                	mov    %eax,%edx
  801d7f:	eb 05                	jmp    801d86 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d81:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d86:	89 d0                	mov    %edx,%eax
  801d88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    

00801d8d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d92:	83 ec 08             	sub    $0x8,%esp
  801d95:	6a 00                	push   $0x0
  801d97:	ff 75 08             	pushl  0x8(%ebp)
  801d9a:	e8 e3 01 00 00       	call   801f82 <open>
  801d9f:	89 c3                	mov    %eax,%ebx
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	85 c0                	test   %eax,%eax
  801da6:	78 1b                	js     801dc3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801da8:	83 ec 08             	sub    $0x8,%esp
  801dab:	ff 75 0c             	pushl  0xc(%ebp)
  801dae:	50                   	push   %eax
  801daf:	e8 5b ff ff ff       	call   801d0f <fstat>
  801db4:	89 c6                	mov    %eax,%esi
	close(fd);
  801db6:	89 1c 24             	mov    %ebx,(%esp)
  801db9:	e8 fd fb ff ff       	call   8019bb <close>
	return r;
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	89 f0                	mov    %esi,%eax
}
  801dc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc6:	5b                   	pop    %ebx
  801dc7:	5e                   	pop    %esi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    

00801dca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	56                   	push   %esi
  801dce:	53                   	push   %ebx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801dd3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801dda:	75 12                	jne    801dee <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ddc:	83 ec 0c             	sub    $0xc,%esp
  801ddf:	6a 01                	push   $0x1
  801de1:	e8 87 0c 00 00       	call   802a6d <ipc_find_env>
  801de6:	a3 00 50 80 00       	mov    %eax,0x805000
  801deb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801dee:	6a 07                	push   $0x7
  801df0:	68 00 60 80 00       	push   $0x806000
  801df5:	56                   	push   %esi
  801df6:	ff 35 00 50 80 00    	pushl  0x805000
  801dfc:	e8 e0 0b 00 00       	call   8029e1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801e01:	83 c4 0c             	add    $0xc,%esp
  801e04:	6a 00                	push   $0x0
  801e06:	53                   	push   %ebx
  801e07:	6a 00                	push   $0x0
  801e09:	e8 5e 0b 00 00       	call   80296c <ipc_recv>
}
  801e0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    

00801e15 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1e:	8b 40 0c             	mov    0xc(%eax),%eax
  801e21:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801e26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e29:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801e2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801e33:	b8 02 00 00 00       	mov    $0x2,%eax
  801e38:	e8 8d ff ff ff       	call   801dca <fsipc>
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e45:	8b 45 08             	mov    0x8(%ebp),%eax
  801e48:	8b 40 0c             	mov    0xc(%eax),%eax
  801e4b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801e50:	ba 00 00 00 00       	mov    $0x0,%edx
  801e55:	b8 06 00 00 00       	mov    $0x6,%eax
  801e5a:	e8 6b ff ff ff       	call   801dca <fsipc>
}
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    

00801e61 <devfile_stat>:
                return ((ssize_t)r);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	53                   	push   %ebx
  801e65:	83 ec 04             	sub    $0x4,%esp
  801e68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	8b 40 0c             	mov    0xc(%eax),%eax
  801e71:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e76:	ba 00 00 00 00       	mov    $0x0,%edx
  801e7b:	b8 05 00 00 00       	mov    $0x5,%eax
  801e80:	e8 45 ff ff ff       	call   801dca <fsipc>
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 2c                	js     801eb5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e89:	83 ec 08             	sub    $0x8,%esp
  801e8c:	68 00 60 80 00       	push   $0x806000
  801e91:	53                   	push   %ebx
  801e92:	e8 97 e9 ff ff       	call   80082e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e97:	a1 80 60 80 00       	mov    0x806080,%eax
  801e9c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ea2:	a1 84 60 80 00       	mov    0x806084,%eax
  801ea7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ead:	83 c4 10             	add    $0x10,%esp
  801eb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 0c             	sub    $0xc,%esp
  801ec0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ec8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ecd:	0f 47 c2             	cmova  %edx,%eax
	int r;
	if(n > (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t))))
	{
		n = (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t)));
	}
		fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ed0:	8b 55 08             	mov    0x8(%ebp),%edx
  801ed3:	8b 52 0c             	mov    0xc(%edx),%edx
  801ed6:	89 15 00 60 80 00    	mov    %edx,0x806000
		fsipcbuf.write.req_n = n;
  801edc:	a3 04 60 80 00       	mov    %eax,0x806004
		memmove((void *)fsipcbuf.write.req_buf, buf, n);
  801ee1:	50                   	push   %eax
  801ee2:	ff 75 0c             	pushl  0xc(%ebp)
  801ee5:	68 08 60 80 00       	push   $0x806008
  801eea:	e8 d1 ea ff ff       	call   8009c0 <memmove>
		r = fsipc(FSREQ_WRITE, NULL);
  801eef:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef4:	b8 04 00 00 00       	mov    $0x4,%eax
  801ef9:	e8 cc fe ff ff       	call   801dca <fsipc>
                return ((ssize_t)r);
}
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801f08:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801f0e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801f13:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801f19:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1e:	b8 03 00 00 00       	mov    $0x3,%eax
  801f23:	e8 a2 fe ff ff       	call   801dca <fsipc>
  801f28:	89 c3                	mov    %eax,%ebx
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	78 4b                	js     801f79 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801f2e:	39 c6                	cmp    %eax,%esi
  801f30:	73 16                	jae    801f48 <devfile_read+0x48>
  801f32:	68 9c 34 80 00       	push   $0x80349c
  801f37:	68 01 33 80 00       	push   $0x803301
  801f3c:	6a 7c                	push   $0x7c
  801f3e:	68 a3 34 80 00       	push   $0x8034a3
  801f43:	e8 88 e2 ff ff       	call   8001d0 <_panic>
	assert(r <= PGSIZE);
  801f48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f4d:	7e 16                	jle    801f65 <devfile_read+0x65>
  801f4f:	68 ae 34 80 00       	push   $0x8034ae
  801f54:	68 01 33 80 00       	push   $0x803301
  801f59:	6a 7d                	push   $0x7d
  801f5b:	68 a3 34 80 00       	push   $0x8034a3
  801f60:	e8 6b e2 ff ff       	call   8001d0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801f65:	83 ec 04             	sub    $0x4,%esp
  801f68:	50                   	push   %eax
  801f69:	68 00 60 80 00       	push   $0x806000
  801f6e:	ff 75 0c             	pushl  0xc(%ebp)
  801f71:	e8 4a ea ff ff       	call   8009c0 <memmove>
	return r;
  801f76:	83 c4 10             	add    $0x10,%esp
}
  801f79:	89 d8                	mov    %ebx,%eax
  801f7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7e:	5b                   	pop    %ebx
  801f7f:	5e                   	pop    %esi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    

00801f82 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	53                   	push   %ebx
  801f86:	83 ec 20             	sub    $0x20,%esp
  801f89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f8c:	53                   	push   %ebx
  801f8d:	e8 63 e8 ff ff       	call   8007f5 <strlen>
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f9a:	7f 67                	jg     802003 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa2:	50                   	push   %eax
  801fa3:	e8 9a f8 ff ff       	call   801842 <fd_alloc>
  801fa8:	83 c4 10             	add    $0x10,%esp
		return r;
  801fab:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801fad:	85 c0                	test   %eax,%eax
  801faf:	78 57                	js     802008 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801fb1:	83 ec 08             	sub    $0x8,%esp
  801fb4:	53                   	push   %ebx
  801fb5:	68 00 60 80 00       	push   $0x806000
  801fba:	e8 6f e8 ff ff       	call   80082e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc2:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801fc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fca:	b8 01 00 00 00       	mov    $0x1,%eax
  801fcf:	e8 f6 fd ff ff       	call   801dca <fsipc>
  801fd4:	89 c3                	mov    %eax,%ebx
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	79 14                	jns    801ff1 <open+0x6f>
		fd_close(fd, 0);
  801fdd:	83 ec 08             	sub    $0x8,%esp
  801fe0:	6a 00                	push   $0x0
  801fe2:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe5:	e8 50 f9 ff ff       	call   80193a <fd_close>
		return r;
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	89 da                	mov    %ebx,%edx
  801fef:	eb 17                	jmp    802008 <open+0x86>
	}

	return fd2num(fd);
  801ff1:	83 ec 0c             	sub    $0xc,%esp
  801ff4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff7:	e8 1f f8 ff ff       	call   80181b <fd2num>
  801ffc:	89 c2                	mov    %eax,%edx
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	eb 05                	jmp    802008 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802003:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802008:	89 d0                	mov    %edx,%eax
  80200a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80200d:	c9                   	leave  
  80200e:	c3                   	ret    

0080200f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802015:	ba 00 00 00 00       	mov    $0x0,%edx
  80201a:	b8 08 00 00 00       	mov    $0x8,%eax
  80201f:	e8 a6 fd ff ff       	call   801dca <fsipc>
}
  802024:	c9                   	leave  
  802025:	c3                   	ret    

00802026 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80202c:	68 ba 34 80 00       	push   $0x8034ba
  802031:	ff 75 0c             	pushl  0xc(%ebp)
  802034:	e8 f5 e7 ff ff       	call   80082e <strcpy>
	return 0;
}
  802039:	b8 00 00 00 00       	mov    $0x0,%eax
  80203e:	c9                   	leave  
  80203f:	c3                   	ret    

00802040 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	53                   	push   %ebx
  802044:	83 ec 10             	sub    $0x10,%esp
  802047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80204a:	53                   	push   %ebx
  80204b:	e8 56 0a 00 00       	call   802aa6 <pageref>
  802050:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802053:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802058:	83 f8 01             	cmp    $0x1,%eax
  80205b:	75 10                	jne    80206d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80205d:	83 ec 0c             	sub    $0xc,%esp
  802060:	ff 73 0c             	pushl  0xc(%ebx)
  802063:	e8 c0 02 00 00       	call   802328 <nsipc_close>
  802068:	89 c2                	mov    %eax,%edx
  80206a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80206d:	89 d0                	mov    %edx,%eax
  80206f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80207a:	6a 00                	push   $0x0
  80207c:	ff 75 10             	pushl  0x10(%ebp)
  80207f:	ff 75 0c             	pushl  0xc(%ebp)
  802082:	8b 45 08             	mov    0x8(%ebp),%eax
  802085:	ff 70 0c             	pushl  0xc(%eax)
  802088:	e8 78 03 00 00       	call   802405 <nsipc_send>
}
  80208d:	c9                   	leave  
  80208e:	c3                   	ret    

0080208f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802095:	6a 00                	push   $0x0
  802097:	ff 75 10             	pushl  0x10(%ebp)
  80209a:	ff 75 0c             	pushl  0xc(%ebp)
  80209d:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a0:	ff 70 0c             	pushl  0xc(%eax)
  8020a3:	e8 f1 02 00 00       	call   802399 <nsipc_recv>
}
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8020b0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8020b3:	52                   	push   %edx
  8020b4:	50                   	push   %eax
  8020b5:	e8 d7 f7 ff ff       	call   801891 <fd_lookup>
  8020ba:	83 c4 10             	add    $0x10,%esp
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	78 17                	js     8020d8 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8020c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c4:	8b 0d 28 40 80 00    	mov    0x804028,%ecx
  8020ca:	39 08                	cmp    %ecx,(%eax)
  8020cc:	75 05                	jne    8020d3 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8020ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8020d1:	eb 05                	jmp    8020d8 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8020d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8020d8:	c9                   	leave  
  8020d9:	c3                   	ret    

008020da <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8020da:	55                   	push   %ebp
  8020db:	89 e5                	mov    %esp,%ebp
  8020dd:	56                   	push   %esi
  8020de:	53                   	push   %ebx
  8020df:	83 ec 1c             	sub    $0x1c,%esp
  8020e2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e7:	50                   	push   %eax
  8020e8:	e8 55 f7 ff ff       	call   801842 <fd_alloc>
  8020ed:	89 c3                	mov    %eax,%ebx
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	78 1b                	js     802111 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8020f6:	83 ec 04             	sub    $0x4,%esp
  8020f9:	68 07 04 00 00       	push   $0x407
  8020fe:	ff 75 f4             	pushl  -0xc(%ebp)
  802101:	6a 00                	push   $0x0
  802103:	e8 29 eb ff ff       	call   800c31 <sys_page_alloc>
  802108:	89 c3                	mov    %eax,%ebx
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	85 c0                	test   %eax,%eax
  80210f:	79 10                	jns    802121 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802111:	83 ec 0c             	sub    $0xc,%esp
  802114:	56                   	push   %esi
  802115:	e8 0e 02 00 00       	call   802328 <nsipc_close>
		return r;
  80211a:	83 c4 10             	add    $0x10,%esp
  80211d:	89 d8                	mov    %ebx,%eax
  80211f:	eb 24                	jmp    802145 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802121:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80212c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802136:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802139:	83 ec 0c             	sub    $0xc,%esp
  80213c:	50                   	push   %eax
  80213d:	e8 d9 f6 ff ff       	call   80181b <fd2num>
  802142:	83 c4 10             	add    $0x10,%esp
}
  802145:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802148:	5b                   	pop    %ebx
  802149:	5e                   	pop    %esi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    

0080214c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802152:	8b 45 08             	mov    0x8(%ebp),%eax
  802155:	e8 50 ff ff ff       	call   8020aa <fd2sockid>
		return r;
  80215a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80215c:	85 c0                	test   %eax,%eax
  80215e:	78 1f                	js     80217f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802160:	83 ec 04             	sub    $0x4,%esp
  802163:	ff 75 10             	pushl  0x10(%ebp)
  802166:	ff 75 0c             	pushl  0xc(%ebp)
  802169:	50                   	push   %eax
  80216a:	e8 12 01 00 00       	call   802281 <nsipc_accept>
  80216f:	83 c4 10             	add    $0x10,%esp
		return r;
  802172:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802174:	85 c0                	test   %eax,%eax
  802176:	78 07                	js     80217f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802178:	e8 5d ff ff ff       	call   8020da <alloc_sockfd>
  80217d:	89 c1                	mov    %eax,%ecx
}
  80217f:	89 c8                	mov    %ecx,%eax
  802181:	c9                   	leave  
  802182:	c3                   	ret    

00802183 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802183:	55                   	push   %ebp
  802184:	89 e5                	mov    %esp,%ebp
  802186:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802189:	8b 45 08             	mov    0x8(%ebp),%eax
  80218c:	e8 19 ff ff ff       	call   8020aa <fd2sockid>
  802191:	85 c0                	test   %eax,%eax
  802193:	78 12                	js     8021a7 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802195:	83 ec 04             	sub    $0x4,%esp
  802198:	ff 75 10             	pushl  0x10(%ebp)
  80219b:	ff 75 0c             	pushl  0xc(%ebp)
  80219e:	50                   	push   %eax
  80219f:	e8 2d 01 00 00       	call   8022d1 <nsipc_bind>
  8021a4:	83 c4 10             	add    $0x10,%esp
}
  8021a7:	c9                   	leave  
  8021a8:	c3                   	ret    

008021a9 <shutdown>:

int
shutdown(int s, int how)
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021af:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b2:	e8 f3 fe ff ff       	call   8020aa <fd2sockid>
  8021b7:	85 c0                	test   %eax,%eax
  8021b9:	78 0f                	js     8021ca <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8021bb:	83 ec 08             	sub    $0x8,%esp
  8021be:	ff 75 0c             	pushl  0xc(%ebp)
  8021c1:	50                   	push   %eax
  8021c2:	e8 3f 01 00 00       	call   802306 <nsipc_shutdown>
  8021c7:	83 c4 10             	add    $0x10,%esp
}
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d5:	e8 d0 fe ff ff       	call   8020aa <fd2sockid>
  8021da:	85 c0                	test   %eax,%eax
  8021dc:	78 12                	js     8021f0 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8021de:	83 ec 04             	sub    $0x4,%esp
  8021e1:	ff 75 10             	pushl  0x10(%ebp)
  8021e4:	ff 75 0c             	pushl  0xc(%ebp)
  8021e7:	50                   	push   %eax
  8021e8:	e8 55 01 00 00       	call   802342 <nsipc_connect>
  8021ed:	83 c4 10             	add    $0x10,%esp
}
  8021f0:	c9                   	leave  
  8021f1:	c3                   	ret    

008021f2 <listen>:

int
listen(int s, int backlog)
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fb:	e8 aa fe ff ff       	call   8020aa <fd2sockid>
  802200:	85 c0                	test   %eax,%eax
  802202:	78 0f                	js     802213 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802204:	83 ec 08             	sub    $0x8,%esp
  802207:	ff 75 0c             	pushl  0xc(%ebp)
  80220a:	50                   	push   %eax
  80220b:	e8 67 01 00 00       	call   802377 <nsipc_listen>
  802210:	83 c4 10             	add    $0x10,%esp
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80221b:	ff 75 10             	pushl  0x10(%ebp)
  80221e:	ff 75 0c             	pushl  0xc(%ebp)
  802221:	ff 75 08             	pushl  0x8(%ebp)
  802224:	e8 3a 02 00 00       	call   802463 <nsipc_socket>
  802229:	83 c4 10             	add    $0x10,%esp
  80222c:	85 c0                	test   %eax,%eax
  80222e:	78 05                	js     802235 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802230:	e8 a5 fe ff ff       	call   8020da <alloc_sockfd>
}
  802235:	c9                   	leave  
  802236:	c3                   	ret    

00802237 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	53                   	push   %ebx
  80223b:	83 ec 04             	sub    $0x4,%esp
  80223e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802240:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802247:	75 12                	jne    80225b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802249:	83 ec 0c             	sub    $0xc,%esp
  80224c:	6a 02                	push   $0x2
  80224e:	e8 1a 08 00 00       	call   802a6d <ipc_find_env>
  802253:	a3 04 50 80 00       	mov    %eax,0x805004
  802258:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80225b:	6a 07                	push   $0x7
  80225d:	68 00 70 80 00       	push   $0x807000
  802262:	53                   	push   %ebx
  802263:	ff 35 04 50 80 00    	pushl  0x805004
  802269:	e8 73 07 00 00       	call   8029e1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80226e:	83 c4 0c             	add    $0xc,%esp
  802271:	6a 00                	push   $0x0
  802273:	6a 00                	push   $0x0
  802275:	6a 00                	push   $0x0
  802277:	e8 f0 06 00 00       	call   80296c <ipc_recv>
}
  80227c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80227f:	c9                   	leave  
  802280:	c3                   	ret    

00802281 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	56                   	push   %esi
  802285:	53                   	push   %ebx
  802286:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802289:	8b 45 08             	mov    0x8(%ebp),%eax
  80228c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802291:	8b 06                	mov    (%esi),%eax
  802293:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802298:	b8 01 00 00 00       	mov    $0x1,%eax
  80229d:	e8 95 ff ff ff       	call   802237 <nsipc>
  8022a2:	89 c3                	mov    %eax,%ebx
  8022a4:	85 c0                	test   %eax,%eax
  8022a6:	78 20                	js     8022c8 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8022a8:	83 ec 04             	sub    $0x4,%esp
  8022ab:	ff 35 10 70 80 00    	pushl  0x807010
  8022b1:	68 00 70 80 00       	push   $0x807000
  8022b6:	ff 75 0c             	pushl  0xc(%ebp)
  8022b9:	e8 02 e7 ff ff       	call   8009c0 <memmove>
		*addrlen = ret->ret_addrlen;
  8022be:	a1 10 70 80 00       	mov    0x807010,%eax
  8022c3:	89 06                	mov    %eax,(%esi)
  8022c5:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    

008022d1 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	53                   	push   %ebx
  8022d5:	83 ec 08             	sub    $0x8,%esp
  8022d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8022db:	8b 45 08             	mov    0x8(%ebp),%eax
  8022de:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8022e3:	53                   	push   %ebx
  8022e4:	ff 75 0c             	pushl  0xc(%ebp)
  8022e7:	68 04 70 80 00       	push   $0x807004
  8022ec:	e8 cf e6 ff ff       	call   8009c0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8022f1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8022f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8022fc:	e8 36 ff ff ff       	call   802237 <nsipc>
}
  802301:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802304:	c9                   	leave  
  802305:	c3                   	ret    

00802306 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80230c:	8b 45 08             	mov    0x8(%ebp),%eax
  80230f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802314:	8b 45 0c             	mov    0xc(%ebp),%eax
  802317:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80231c:	b8 03 00 00 00       	mov    $0x3,%eax
  802321:	e8 11 ff ff ff       	call   802237 <nsipc>
}
  802326:	c9                   	leave  
  802327:	c3                   	ret    

00802328 <nsipc_close>:

int
nsipc_close(int s)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80232e:	8b 45 08             	mov    0x8(%ebp),%eax
  802331:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802336:	b8 04 00 00 00       	mov    $0x4,%eax
  80233b:	e8 f7 fe ff ff       	call   802237 <nsipc>
}
  802340:	c9                   	leave  
  802341:	c3                   	ret    

00802342 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	53                   	push   %ebx
  802346:	83 ec 08             	sub    $0x8,%esp
  802349:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80234c:	8b 45 08             	mov    0x8(%ebp),%eax
  80234f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802354:	53                   	push   %ebx
  802355:	ff 75 0c             	pushl  0xc(%ebp)
  802358:	68 04 70 80 00       	push   $0x807004
  80235d:	e8 5e e6 ff ff       	call   8009c0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802362:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802368:	b8 05 00 00 00       	mov    $0x5,%eax
  80236d:	e8 c5 fe ff ff       	call   802237 <nsipc>
}
  802372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802375:	c9                   	leave  
  802376:	c3                   	ret    

00802377 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80237d:	8b 45 08             	mov    0x8(%ebp),%eax
  802380:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802385:	8b 45 0c             	mov    0xc(%ebp),%eax
  802388:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80238d:	b8 06 00 00 00       	mov    $0x6,%eax
  802392:	e8 a0 fe ff ff       	call   802237 <nsipc>
}
  802397:	c9                   	leave  
  802398:	c3                   	ret    

00802399 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802399:	55                   	push   %ebp
  80239a:	89 e5                	mov    %esp,%ebp
  80239c:	56                   	push   %esi
  80239d:	53                   	push   %ebx
  80239e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8023a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8023a9:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8023af:	8b 45 14             	mov    0x14(%ebp),%eax
  8023b2:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8023b7:	b8 07 00 00 00       	mov    $0x7,%eax
  8023bc:	e8 76 fe ff ff       	call   802237 <nsipc>
  8023c1:	89 c3                	mov    %eax,%ebx
  8023c3:	85 c0                	test   %eax,%eax
  8023c5:	78 35                	js     8023fc <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8023c7:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8023cc:	7f 04                	jg     8023d2 <nsipc_recv+0x39>
  8023ce:	39 c6                	cmp    %eax,%esi
  8023d0:	7d 16                	jge    8023e8 <nsipc_recv+0x4f>
  8023d2:	68 c6 34 80 00       	push   $0x8034c6
  8023d7:	68 01 33 80 00       	push   $0x803301
  8023dc:	6a 62                	push   $0x62
  8023de:	68 db 34 80 00       	push   $0x8034db
  8023e3:	e8 e8 dd ff ff       	call   8001d0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8023e8:	83 ec 04             	sub    $0x4,%esp
  8023eb:	50                   	push   %eax
  8023ec:	68 00 70 80 00       	push   $0x807000
  8023f1:	ff 75 0c             	pushl  0xc(%ebp)
  8023f4:	e8 c7 e5 ff ff       	call   8009c0 <memmove>
  8023f9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8023fc:	89 d8                	mov    %ebx,%eax
  8023fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802401:	5b                   	pop    %ebx
  802402:	5e                   	pop    %esi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    

00802405 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802405:	55                   	push   %ebp
  802406:	89 e5                	mov    %esp,%ebp
  802408:	53                   	push   %ebx
  802409:	83 ec 04             	sub    $0x4,%esp
  80240c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80240f:	8b 45 08             	mov    0x8(%ebp),%eax
  802412:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802417:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80241d:	7e 16                	jle    802435 <nsipc_send+0x30>
  80241f:	68 e7 34 80 00       	push   $0x8034e7
  802424:	68 01 33 80 00       	push   $0x803301
  802429:	6a 6d                	push   $0x6d
  80242b:	68 db 34 80 00       	push   $0x8034db
  802430:	e8 9b dd ff ff       	call   8001d0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802435:	83 ec 04             	sub    $0x4,%esp
  802438:	53                   	push   %ebx
  802439:	ff 75 0c             	pushl  0xc(%ebp)
  80243c:	68 0c 70 80 00       	push   $0x80700c
  802441:	e8 7a e5 ff ff       	call   8009c0 <memmove>
	nsipcbuf.send.req_size = size;
  802446:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80244c:	8b 45 14             	mov    0x14(%ebp),%eax
  80244f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802454:	b8 08 00 00 00       	mov    $0x8,%eax
  802459:	e8 d9 fd ff ff       	call   802237 <nsipc>
}
  80245e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802461:	c9                   	leave  
  802462:	c3                   	ret    

00802463 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802463:	55                   	push   %ebp
  802464:	89 e5                	mov    %esp,%ebp
  802466:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802469:	8b 45 08             	mov    0x8(%ebp),%eax
  80246c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802471:	8b 45 0c             	mov    0xc(%ebp),%eax
  802474:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802479:	8b 45 10             	mov    0x10(%ebp),%eax
  80247c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802481:	b8 09 00 00 00       	mov    $0x9,%eax
  802486:	e8 ac fd ff ff       	call   802237 <nsipc>
}
  80248b:	c9                   	leave  
  80248c:	c3                   	ret    

0080248d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80248d:	55                   	push   %ebp
  80248e:	89 e5                	mov    %esp,%ebp
  802490:	56                   	push   %esi
  802491:	53                   	push   %ebx
  802492:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802495:	83 ec 0c             	sub    $0xc,%esp
  802498:	ff 75 08             	pushl  0x8(%ebp)
  80249b:	e8 8b f3 ff ff       	call   80182b <fd2data>
  8024a0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8024a2:	83 c4 08             	add    $0x8,%esp
  8024a5:	68 f3 34 80 00       	push   $0x8034f3
  8024aa:	53                   	push   %ebx
  8024ab:	e8 7e e3 ff ff       	call   80082e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8024b0:	8b 46 04             	mov    0x4(%esi),%eax
  8024b3:	2b 06                	sub    (%esi),%eax
  8024b5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8024bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8024c2:	00 00 00 
	stat->st_dev = &devpipe;
  8024c5:	c7 83 88 00 00 00 44 	movl   $0x804044,0x88(%ebx)
  8024cc:	40 80 00 
	return 0;
}
  8024cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5d                   	pop    %ebp
  8024da:	c3                   	ret    

008024db <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8024db:	55                   	push   %ebp
  8024dc:	89 e5                	mov    %esp,%ebp
  8024de:	53                   	push   %ebx
  8024df:	83 ec 0c             	sub    $0xc,%esp
  8024e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8024e5:	53                   	push   %ebx
  8024e6:	6a 00                	push   $0x0
  8024e8:	e8 c9 e7 ff ff       	call   800cb6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8024ed:	89 1c 24             	mov    %ebx,(%esp)
  8024f0:	e8 36 f3 ff ff       	call   80182b <fd2data>
  8024f5:	83 c4 08             	add    $0x8,%esp
  8024f8:	50                   	push   %eax
  8024f9:	6a 00                	push   $0x0
  8024fb:	e8 b6 e7 ff ff       	call   800cb6 <sys_page_unmap>
}
  802500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802503:	c9                   	leave  
  802504:	c3                   	ret    

00802505 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802505:	55                   	push   %ebp
  802506:	89 e5                	mov    %esp,%ebp
  802508:	57                   	push   %edi
  802509:	56                   	push   %esi
  80250a:	53                   	push   %ebx
  80250b:	83 ec 1c             	sub    $0x1c,%esp
  80250e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802511:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802513:	a1 08 50 80 00       	mov    0x805008,%eax
  802518:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80251b:	83 ec 0c             	sub    $0xc,%esp
  80251e:	ff 75 e0             	pushl  -0x20(%ebp)
  802521:	e8 80 05 00 00       	call   802aa6 <pageref>
  802526:	89 c3                	mov    %eax,%ebx
  802528:	89 3c 24             	mov    %edi,(%esp)
  80252b:	e8 76 05 00 00       	call   802aa6 <pageref>
  802530:	83 c4 10             	add    $0x10,%esp
  802533:	39 c3                	cmp    %eax,%ebx
  802535:	0f 94 c1             	sete   %cl
  802538:	0f b6 c9             	movzbl %cl,%ecx
  80253b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80253e:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802544:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802547:	39 ce                	cmp    %ecx,%esi
  802549:	74 1b                	je     802566 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80254b:	39 c3                	cmp    %eax,%ebx
  80254d:	75 c4                	jne    802513 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80254f:	8b 42 58             	mov    0x58(%edx),%eax
  802552:	ff 75 e4             	pushl  -0x1c(%ebp)
  802555:	50                   	push   %eax
  802556:	56                   	push   %esi
  802557:	68 fa 34 80 00       	push   $0x8034fa
  80255c:	e8 48 dd ff ff       	call   8002a9 <cprintf>
  802561:	83 c4 10             	add    $0x10,%esp
  802564:	eb ad                	jmp    802513 <_pipeisclosed+0xe>
	}
}
  802566:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802569:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80256c:	5b                   	pop    %ebx
  80256d:	5e                   	pop    %esi
  80256e:	5f                   	pop    %edi
  80256f:	5d                   	pop    %ebp
  802570:	c3                   	ret    

00802571 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802571:	55                   	push   %ebp
  802572:	89 e5                	mov    %esp,%ebp
  802574:	57                   	push   %edi
  802575:	56                   	push   %esi
  802576:	53                   	push   %ebx
  802577:	83 ec 28             	sub    $0x28,%esp
  80257a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80257d:	56                   	push   %esi
  80257e:	e8 a8 f2 ff ff       	call   80182b <fd2data>
  802583:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802585:	83 c4 10             	add    $0x10,%esp
  802588:	bf 00 00 00 00       	mov    $0x0,%edi
  80258d:	eb 4b                	jmp    8025da <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80258f:	89 da                	mov    %ebx,%edx
  802591:	89 f0                	mov    %esi,%eax
  802593:	e8 6d ff ff ff       	call   802505 <_pipeisclosed>
  802598:	85 c0                	test   %eax,%eax
  80259a:	75 48                	jne    8025e4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80259c:	e8 71 e6 ff ff       	call   800c12 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025a1:	8b 43 04             	mov    0x4(%ebx),%eax
  8025a4:	8b 0b                	mov    (%ebx),%ecx
  8025a6:	8d 51 20             	lea    0x20(%ecx),%edx
  8025a9:	39 d0                	cmp    %edx,%eax
  8025ab:	73 e2                	jae    80258f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8025ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8025b4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8025b7:	89 c2                	mov    %eax,%edx
  8025b9:	c1 fa 1f             	sar    $0x1f,%edx
  8025bc:	89 d1                	mov    %edx,%ecx
  8025be:	c1 e9 1b             	shr    $0x1b,%ecx
  8025c1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8025c4:	83 e2 1f             	and    $0x1f,%edx
  8025c7:	29 ca                	sub    %ecx,%edx
  8025c9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8025cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8025d1:	83 c0 01             	add    $0x1,%eax
  8025d4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025d7:	83 c7 01             	add    $0x1,%edi
  8025da:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025dd:	75 c2                	jne    8025a1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8025df:	8b 45 10             	mov    0x10(%ebp),%eax
  8025e2:	eb 05                	jmp    8025e9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025e4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8025e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ec:	5b                   	pop    %ebx
  8025ed:	5e                   	pop    %esi
  8025ee:	5f                   	pop    %edi
  8025ef:	5d                   	pop    %ebp
  8025f0:	c3                   	ret    

008025f1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025f1:	55                   	push   %ebp
  8025f2:	89 e5                	mov    %esp,%ebp
  8025f4:	57                   	push   %edi
  8025f5:	56                   	push   %esi
  8025f6:	53                   	push   %ebx
  8025f7:	83 ec 18             	sub    $0x18,%esp
  8025fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8025fd:	57                   	push   %edi
  8025fe:	e8 28 f2 ff ff       	call   80182b <fd2data>
  802603:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802605:	83 c4 10             	add    $0x10,%esp
  802608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80260d:	eb 3d                	jmp    80264c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80260f:	85 db                	test   %ebx,%ebx
  802611:	74 04                	je     802617 <devpipe_read+0x26>
				return i;
  802613:	89 d8                	mov    %ebx,%eax
  802615:	eb 44                	jmp    80265b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802617:	89 f2                	mov    %esi,%edx
  802619:	89 f8                	mov    %edi,%eax
  80261b:	e8 e5 fe ff ff       	call   802505 <_pipeisclosed>
  802620:	85 c0                	test   %eax,%eax
  802622:	75 32                	jne    802656 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802624:	e8 e9 e5 ff ff       	call   800c12 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802629:	8b 06                	mov    (%esi),%eax
  80262b:	3b 46 04             	cmp    0x4(%esi),%eax
  80262e:	74 df                	je     80260f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802630:	99                   	cltd   
  802631:	c1 ea 1b             	shr    $0x1b,%edx
  802634:	01 d0                	add    %edx,%eax
  802636:	83 e0 1f             	and    $0x1f,%eax
  802639:	29 d0                	sub    %edx,%eax
  80263b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802640:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802643:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802646:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802649:	83 c3 01             	add    $0x1,%ebx
  80264c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80264f:	75 d8                	jne    802629 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802651:	8b 45 10             	mov    0x10(%ebp),%eax
  802654:	eb 05                	jmp    80265b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802656:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80265b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80265e:	5b                   	pop    %ebx
  80265f:	5e                   	pop    %esi
  802660:	5f                   	pop    %edi
  802661:	5d                   	pop    %ebp
  802662:	c3                   	ret    

00802663 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802663:	55                   	push   %ebp
  802664:	89 e5                	mov    %esp,%ebp
  802666:	56                   	push   %esi
  802667:	53                   	push   %ebx
  802668:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80266b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80266e:	50                   	push   %eax
  80266f:	e8 ce f1 ff ff       	call   801842 <fd_alloc>
  802674:	83 c4 10             	add    $0x10,%esp
  802677:	89 c2                	mov    %eax,%edx
  802679:	85 c0                	test   %eax,%eax
  80267b:	0f 88 2c 01 00 00    	js     8027ad <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802681:	83 ec 04             	sub    $0x4,%esp
  802684:	68 07 04 00 00       	push   $0x407
  802689:	ff 75 f4             	pushl  -0xc(%ebp)
  80268c:	6a 00                	push   $0x0
  80268e:	e8 9e e5 ff ff       	call   800c31 <sys_page_alloc>
  802693:	83 c4 10             	add    $0x10,%esp
  802696:	89 c2                	mov    %eax,%edx
  802698:	85 c0                	test   %eax,%eax
  80269a:	0f 88 0d 01 00 00    	js     8027ad <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8026a0:	83 ec 0c             	sub    $0xc,%esp
  8026a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026a6:	50                   	push   %eax
  8026a7:	e8 96 f1 ff ff       	call   801842 <fd_alloc>
  8026ac:	89 c3                	mov    %eax,%ebx
  8026ae:	83 c4 10             	add    $0x10,%esp
  8026b1:	85 c0                	test   %eax,%eax
  8026b3:	0f 88 e2 00 00 00    	js     80279b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026b9:	83 ec 04             	sub    $0x4,%esp
  8026bc:	68 07 04 00 00       	push   $0x407
  8026c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8026c4:	6a 00                	push   $0x0
  8026c6:	e8 66 e5 ff ff       	call   800c31 <sys_page_alloc>
  8026cb:	89 c3                	mov    %eax,%ebx
  8026cd:	83 c4 10             	add    $0x10,%esp
  8026d0:	85 c0                	test   %eax,%eax
  8026d2:	0f 88 c3 00 00 00    	js     80279b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8026d8:	83 ec 0c             	sub    $0xc,%esp
  8026db:	ff 75 f4             	pushl  -0xc(%ebp)
  8026de:	e8 48 f1 ff ff       	call   80182b <fd2data>
  8026e3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026e5:	83 c4 0c             	add    $0xc,%esp
  8026e8:	68 07 04 00 00       	push   $0x407
  8026ed:	50                   	push   %eax
  8026ee:	6a 00                	push   $0x0
  8026f0:	e8 3c e5 ff ff       	call   800c31 <sys_page_alloc>
  8026f5:	89 c3                	mov    %eax,%ebx
  8026f7:	83 c4 10             	add    $0x10,%esp
  8026fa:	85 c0                	test   %eax,%eax
  8026fc:	0f 88 89 00 00 00    	js     80278b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802702:	83 ec 0c             	sub    $0xc,%esp
  802705:	ff 75 f0             	pushl  -0x10(%ebp)
  802708:	e8 1e f1 ff ff       	call   80182b <fd2data>
  80270d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802714:	50                   	push   %eax
  802715:	6a 00                	push   $0x0
  802717:	56                   	push   %esi
  802718:	6a 00                	push   $0x0
  80271a:	e8 55 e5 ff ff       	call   800c74 <sys_page_map>
  80271f:	89 c3                	mov    %eax,%ebx
  802721:	83 c4 20             	add    $0x20,%esp
  802724:	85 c0                	test   %eax,%eax
  802726:	78 55                	js     80277d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802728:	8b 15 44 40 80 00    	mov    0x804044,%edx
  80272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802731:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802736:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80273d:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802746:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802748:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80274b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802752:	83 ec 0c             	sub    $0xc,%esp
  802755:	ff 75 f4             	pushl  -0xc(%ebp)
  802758:	e8 be f0 ff ff       	call   80181b <fd2num>
  80275d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802760:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802762:	83 c4 04             	add    $0x4,%esp
  802765:	ff 75 f0             	pushl  -0x10(%ebp)
  802768:	e8 ae f0 ff ff       	call   80181b <fd2num>
  80276d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802770:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802773:	83 c4 10             	add    $0x10,%esp
  802776:	ba 00 00 00 00       	mov    $0x0,%edx
  80277b:	eb 30                	jmp    8027ad <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80277d:	83 ec 08             	sub    $0x8,%esp
  802780:	56                   	push   %esi
  802781:	6a 00                	push   $0x0
  802783:	e8 2e e5 ff ff       	call   800cb6 <sys_page_unmap>
  802788:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80278b:	83 ec 08             	sub    $0x8,%esp
  80278e:	ff 75 f0             	pushl  -0x10(%ebp)
  802791:	6a 00                	push   $0x0
  802793:	e8 1e e5 ff ff       	call   800cb6 <sys_page_unmap>
  802798:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80279b:	83 ec 08             	sub    $0x8,%esp
  80279e:	ff 75 f4             	pushl  -0xc(%ebp)
  8027a1:	6a 00                	push   $0x0
  8027a3:	e8 0e e5 ff ff       	call   800cb6 <sys_page_unmap>
  8027a8:	83 c4 10             	add    $0x10,%esp
  8027ab:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8027ad:	89 d0                	mov    %edx,%eax
  8027af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027b2:	5b                   	pop    %ebx
  8027b3:	5e                   	pop    %esi
  8027b4:	5d                   	pop    %ebp
  8027b5:	c3                   	ret    

008027b6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8027b6:	55                   	push   %ebp
  8027b7:	89 e5                	mov    %esp,%ebp
  8027b9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027bf:	50                   	push   %eax
  8027c0:	ff 75 08             	pushl  0x8(%ebp)
  8027c3:	e8 c9 f0 ff ff       	call   801891 <fd_lookup>
  8027c8:	83 c4 10             	add    $0x10,%esp
  8027cb:	85 c0                	test   %eax,%eax
  8027cd:	78 18                	js     8027e7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8027cf:	83 ec 0c             	sub    $0xc,%esp
  8027d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8027d5:	e8 51 f0 ff ff       	call   80182b <fd2data>
	return _pipeisclosed(fd, p);
  8027da:	89 c2                	mov    %eax,%edx
  8027dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027df:	e8 21 fd ff ff       	call   802505 <_pipeisclosed>
  8027e4:	83 c4 10             	add    $0x10,%esp
}
  8027e7:	c9                   	leave  
  8027e8:	c3                   	ret    

008027e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8027e9:	55                   	push   %ebp
  8027ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8027ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8027f1:	5d                   	pop    %ebp
  8027f2:	c3                   	ret    

008027f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8027f3:	55                   	push   %ebp
  8027f4:	89 e5                	mov    %esp,%ebp
  8027f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8027f9:	68 12 35 80 00       	push   $0x803512
  8027fe:	ff 75 0c             	pushl  0xc(%ebp)
  802801:	e8 28 e0 ff ff       	call   80082e <strcpy>
	return 0;
}
  802806:	b8 00 00 00 00       	mov    $0x0,%eax
  80280b:	c9                   	leave  
  80280c:	c3                   	ret    

0080280d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80280d:	55                   	push   %ebp
  80280e:	89 e5                	mov    %esp,%ebp
  802810:	57                   	push   %edi
  802811:	56                   	push   %esi
  802812:	53                   	push   %ebx
  802813:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802819:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80281e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802824:	eb 2d                	jmp    802853 <devcons_write+0x46>
		m = n - tot;
  802826:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802829:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80282b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80282e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802833:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802836:	83 ec 04             	sub    $0x4,%esp
  802839:	53                   	push   %ebx
  80283a:	03 45 0c             	add    0xc(%ebp),%eax
  80283d:	50                   	push   %eax
  80283e:	57                   	push   %edi
  80283f:	e8 7c e1 ff ff       	call   8009c0 <memmove>
		sys_cputs(buf, m);
  802844:	83 c4 08             	add    $0x8,%esp
  802847:	53                   	push   %ebx
  802848:	57                   	push   %edi
  802849:	e8 27 e3 ff ff       	call   800b75 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80284e:	01 de                	add    %ebx,%esi
  802850:	83 c4 10             	add    $0x10,%esp
  802853:	89 f0                	mov    %esi,%eax
  802855:	3b 75 10             	cmp    0x10(%ebp),%esi
  802858:	72 cc                	jb     802826 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80285a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80285d:	5b                   	pop    %ebx
  80285e:	5e                   	pop    %esi
  80285f:	5f                   	pop    %edi
  802860:	5d                   	pop    %ebp
  802861:	c3                   	ret    

00802862 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802862:	55                   	push   %ebp
  802863:	89 e5                	mov    %esp,%ebp
  802865:	83 ec 08             	sub    $0x8,%esp
  802868:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80286d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802871:	74 2a                	je     80289d <devcons_read+0x3b>
  802873:	eb 05                	jmp    80287a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802875:	e8 98 e3 ff ff       	call   800c12 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80287a:	e8 14 e3 ff ff       	call   800b93 <sys_cgetc>
  80287f:	85 c0                	test   %eax,%eax
  802881:	74 f2                	je     802875 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802883:	85 c0                	test   %eax,%eax
  802885:	78 16                	js     80289d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802887:	83 f8 04             	cmp    $0x4,%eax
  80288a:	74 0c                	je     802898 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80288c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80288f:	88 02                	mov    %al,(%edx)
	return 1;
  802891:	b8 01 00 00 00       	mov    $0x1,%eax
  802896:	eb 05                	jmp    80289d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802898:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80289d:	c9                   	leave  
  80289e:	c3                   	ret    

0080289f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80289f:	55                   	push   %ebp
  8028a0:	89 e5                	mov    %esp,%ebp
  8028a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8028a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8028a8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8028ab:	6a 01                	push   $0x1
  8028ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8028b0:	50                   	push   %eax
  8028b1:	e8 bf e2 ff ff       	call   800b75 <sys_cputs>
}
  8028b6:	83 c4 10             	add    $0x10,%esp
  8028b9:	c9                   	leave  
  8028ba:	c3                   	ret    

008028bb <getchar>:

int
getchar(void)
{
  8028bb:	55                   	push   %ebp
  8028bc:	89 e5                	mov    %esp,%ebp
  8028be:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8028c1:	6a 01                	push   $0x1
  8028c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8028c6:	50                   	push   %eax
  8028c7:	6a 00                	push   $0x0
  8028c9:	e8 29 f2 ff ff       	call   801af7 <read>
	if (r < 0)
  8028ce:	83 c4 10             	add    $0x10,%esp
  8028d1:	85 c0                	test   %eax,%eax
  8028d3:	78 0f                	js     8028e4 <getchar+0x29>
		return r;
	if (r < 1)
  8028d5:	85 c0                	test   %eax,%eax
  8028d7:	7e 06                	jle    8028df <getchar+0x24>
		return -E_EOF;
	return c;
  8028d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8028dd:	eb 05                	jmp    8028e4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8028df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8028e4:	c9                   	leave  
  8028e5:	c3                   	ret    

008028e6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8028e6:	55                   	push   %ebp
  8028e7:	89 e5                	mov    %esp,%ebp
  8028e9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8028ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028ef:	50                   	push   %eax
  8028f0:	ff 75 08             	pushl  0x8(%ebp)
  8028f3:	e8 99 ef ff ff       	call   801891 <fd_lookup>
  8028f8:	83 c4 10             	add    $0x10,%esp
  8028fb:	85 c0                	test   %eax,%eax
  8028fd:	78 11                	js     802910 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8028ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802902:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802908:	39 10                	cmp    %edx,(%eax)
  80290a:	0f 94 c0             	sete   %al
  80290d:	0f b6 c0             	movzbl %al,%eax
}
  802910:	c9                   	leave  
  802911:	c3                   	ret    

00802912 <opencons>:

int
opencons(void)
{
  802912:	55                   	push   %ebp
  802913:	89 e5                	mov    %esp,%ebp
  802915:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802918:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80291b:	50                   	push   %eax
  80291c:	e8 21 ef ff ff       	call   801842 <fd_alloc>
  802921:	83 c4 10             	add    $0x10,%esp
		return r;
  802924:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802926:	85 c0                	test   %eax,%eax
  802928:	78 3e                	js     802968 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80292a:	83 ec 04             	sub    $0x4,%esp
  80292d:	68 07 04 00 00       	push   $0x407
  802932:	ff 75 f4             	pushl  -0xc(%ebp)
  802935:	6a 00                	push   $0x0
  802937:	e8 f5 e2 ff ff       	call   800c31 <sys_page_alloc>
  80293c:	83 c4 10             	add    $0x10,%esp
		return r;
  80293f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802941:	85 c0                	test   %eax,%eax
  802943:	78 23                	js     802968 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802945:	8b 15 60 40 80 00    	mov    0x804060,%edx
  80294b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80294e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802953:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80295a:	83 ec 0c             	sub    $0xc,%esp
  80295d:	50                   	push   %eax
  80295e:	e8 b8 ee ff ff       	call   80181b <fd2num>
  802963:	89 c2                	mov    %eax,%edx
  802965:	83 c4 10             	add    $0x10,%esp
}
  802968:	89 d0                	mov    %edx,%eax
  80296a:	c9                   	leave  
  80296b:	c3                   	ret    

0080296c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80296c:	55                   	push   %ebp
  80296d:	89 e5                	mov    %esp,%ebp
  80296f:	56                   	push   %esi
  802970:	53                   	push   %ebx
  802971:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802974:	8b 45 0c             	mov    0xc(%ebp),%eax
  802977:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  80297a:	85 c0                	test   %eax,%eax
  80297c:	74 0e                	je     80298c <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  80297e:	83 ec 0c             	sub    $0xc,%esp
  802981:	50                   	push   %eax
  802982:	e8 5a e4 ff ff       	call   800de1 <sys_ipc_recv>
  802987:	83 c4 10             	add    $0x10,%esp
  80298a:	eb 10                	jmp    80299c <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  80298c:	83 ec 0c             	sub    $0xc,%esp
  80298f:	68 00 00 00 f0       	push   $0xf0000000
  802994:	e8 48 e4 ff ff       	call   800de1 <sys_ipc_recv>
  802999:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  80299c:	85 c0                	test   %eax,%eax
  80299e:	74 16                	je     8029b6 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  8029a0:	85 db                	test   %ebx,%ebx
  8029a2:	74 36                	je     8029da <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  8029a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  8029aa:	85 f6                	test   %esi,%esi
  8029ac:	74 2c                	je     8029da <ipc_recv+0x6e>
				*perm_store = 0;
  8029ae:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8029b4:	eb 24                	jmp    8029da <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  8029b6:	85 db                	test   %ebx,%ebx
  8029b8:	74 18                	je     8029d2 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  8029ba:	a1 08 50 80 00       	mov    0x805008,%eax
  8029bf:	8b 40 74             	mov    0x74(%eax),%eax
  8029c2:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  8029c4:	85 f6                	test   %esi,%esi
  8029c6:	74 0a                	je     8029d2 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  8029c8:	a1 08 50 80 00       	mov    0x805008,%eax
  8029cd:	8b 40 78             	mov    0x78(%eax),%eax
  8029d0:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  8029d2:	a1 08 50 80 00       	mov    0x805008,%eax
  8029d7:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  8029da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029dd:	5b                   	pop    %ebx
  8029de:	5e                   	pop    %esi
  8029df:	5d                   	pop    %ebp
  8029e0:	c3                   	ret    

008029e1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029e1:	55                   	push   %ebp
  8029e2:	89 e5                	mov    %esp,%ebp
  8029e4:	57                   	push   %edi
  8029e5:	56                   	push   %esi
  8029e6:	53                   	push   %ebx
  8029e7:	83 ec 0c             	sub    $0xc,%esp
  8029ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029ed:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  8029f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8029f4:	75 39                	jne    802a2f <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  8029f6:	6a 00                	push   $0x0
  8029f8:	68 00 00 00 f0       	push   $0xf0000000
  8029fd:	56                   	push   %esi
  8029fe:	57                   	push   %edi
  8029ff:	e8 ba e3 ff ff       	call   800dbe <sys_ipc_try_send>
  802a04:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  802a06:	83 c4 10             	add    $0x10,%esp
  802a09:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a0c:	74 16                	je     802a24 <ipc_send+0x43>
  802a0e:	85 c0                	test   %eax,%eax
  802a10:	74 12                	je     802a24 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802a12:	50                   	push   %eax
  802a13:	68 20 35 80 00       	push   $0x803520
  802a18:	6a 4f                	push   $0x4f
  802a1a:	68 58 35 80 00       	push   $0x803558
  802a1f:	e8 ac d7 ff ff       	call   8001d0 <_panic>
			sys_yield();
  802a24:	e8 e9 e1 ff ff       	call   800c12 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  802a29:	85 db                	test   %ebx,%ebx
  802a2b:	75 c9                	jne    8029f6 <ipc_send+0x15>
  802a2d:	eb 36                	jmp    802a65 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  802a2f:	ff 75 14             	pushl  0x14(%ebp)
  802a32:	ff 75 10             	pushl  0x10(%ebp)
  802a35:	56                   	push   %esi
  802a36:	57                   	push   %edi
  802a37:	e8 82 e3 ff ff       	call   800dbe <sys_ipc_try_send>
  802a3c:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  802a3e:	83 c4 10             	add    $0x10,%esp
  802a41:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a44:	74 16                	je     802a5c <ipc_send+0x7b>
  802a46:	85 c0                	test   %eax,%eax
  802a48:	74 12                	je     802a5c <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802a4a:	50                   	push   %eax
  802a4b:	68 20 35 80 00       	push   $0x803520
  802a50:	6a 5a                	push   $0x5a
  802a52:	68 58 35 80 00       	push   $0x803558
  802a57:	e8 74 d7 ff ff       	call   8001d0 <_panic>
			sys_yield();
  802a5c:	e8 b1 e1 ff ff       	call   800c12 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  802a61:	85 db                	test   %ebx,%ebx
  802a63:	75 ca                	jne    802a2f <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  802a65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a68:	5b                   	pop    %ebx
  802a69:	5e                   	pop    %esi
  802a6a:	5f                   	pop    %edi
  802a6b:	5d                   	pop    %ebp
  802a6c:	c3                   	ret    

00802a6d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a6d:	55                   	push   %ebp
  802a6e:	89 e5                	mov    %esp,%ebp
  802a70:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a73:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a78:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a7b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a81:	8b 52 50             	mov    0x50(%edx),%edx
  802a84:	39 ca                	cmp    %ecx,%edx
  802a86:	75 0d                	jne    802a95 <ipc_find_env+0x28>
			return envs[i].env_id;
  802a88:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a8b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a90:	8b 40 48             	mov    0x48(%eax),%eax
  802a93:	eb 0f                	jmp    802aa4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a95:	83 c0 01             	add    $0x1,%eax
  802a98:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a9d:	75 d9                	jne    802a78 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802aa4:	5d                   	pop    %ebp
  802aa5:	c3                   	ret    

00802aa6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802aa6:	55                   	push   %ebp
  802aa7:	89 e5                	mov    %esp,%ebp
  802aa9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802aac:	89 d0                	mov    %edx,%eax
  802aae:	c1 e8 16             	shr    $0x16,%eax
  802ab1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802ab8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802abd:	f6 c1 01             	test   $0x1,%cl
  802ac0:	74 1d                	je     802adf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ac2:	c1 ea 0c             	shr    $0xc,%edx
  802ac5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802acc:	f6 c2 01             	test   $0x1,%dl
  802acf:	74 0e                	je     802adf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ad1:	c1 ea 0c             	shr    $0xc,%edx
  802ad4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802adb:	ef 
  802adc:	0f b7 c0             	movzwl %ax,%eax
}
  802adf:	5d                   	pop    %ebp
  802ae0:	c3                   	ret    
  802ae1:	66 90                	xchg   %ax,%ax
  802ae3:	66 90                	xchg   %ax,%ax
  802ae5:	66 90                	xchg   %ax,%ax
  802ae7:	66 90                	xchg   %ax,%ax
  802ae9:	66 90                	xchg   %ax,%ax
  802aeb:	66 90                	xchg   %ax,%ax
  802aed:	66 90                	xchg   %ax,%ax
  802aef:	90                   	nop

00802af0 <__udivdi3>:
  802af0:	55                   	push   %ebp
  802af1:	57                   	push   %edi
  802af2:	56                   	push   %esi
  802af3:	53                   	push   %ebx
  802af4:	83 ec 1c             	sub    $0x1c,%esp
  802af7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802afb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802aff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802b03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b07:	85 f6                	test   %esi,%esi
  802b09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802b0d:	89 ca                	mov    %ecx,%edx
  802b0f:	89 f8                	mov    %edi,%eax
  802b11:	75 3d                	jne    802b50 <__udivdi3+0x60>
  802b13:	39 cf                	cmp    %ecx,%edi
  802b15:	0f 87 c5 00 00 00    	ja     802be0 <__udivdi3+0xf0>
  802b1b:	85 ff                	test   %edi,%edi
  802b1d:	89 fd                	mov    %edi,%ebp
  802b1f:	75 0b                	jne    802b2c <__udivdi3+0x3c>
  802b21:	b8 01 00 00 00       	mov    $0x1,%eax
  802b26:	31 d2                	xor    %edx,%edx
  802b28:	f7 f7                	div    %edi
  802b2a:	89 c5                	mov    %eax,%ebp
  802b2c:	89 c8                	mov    %ecx,%eax
  802b2e:	31 d2                	xor    %edx,%edx
  802b30:	f7 f5                	div    %ebp
  802b32:	89 c1                	mov    %eax,%ecx
  802b34:	89 d8                	mov    %ebx,%eax
  802b36:	89 cf                	mov    %ecx,%edi
  802b38:	f7 f5                	div    %ebp
  802b3a:	89 c3                	mov    %eax,%ebx
  802b3c:	89 d8                	mov    %ebx,%eax
  802b3e:	89 fa                	mov    %edi,%edx
  802b40:	83 c4 1c             	add    $0x1c,%esp
  802b43:	5b                   	pop    %ebx
  802b44:	5e                   	pop    %esi
  802b45:	5f                   	pop    %edi
  802b46:	5d                   	pop    %ebp
  802b47:	c3                   	ret    
  802b48:	90                   	nop
  802b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b50:	39 ce                	cmp    %ecx,%esi
  802b52:	77 74                	ja     802bc8 <__udivdi3+0xd8>
  802b54:	0f bd fe             	bsr    %esi,%edi
  802b57:	83 f7 1f             	xor    $0x1f,%edi
  802b5a:	0f 84 98 00 00 00    	je     802bf8 <__udivdi3+0x108>
  802b60:	bb 20 00 00 00       	mov    $0x20,%ebx
  802b65:	89 f9                	mov    %edi,%ecx
  802b67:	89 c5                	mov    %eax,%ebp
  802b69:	29 fb                	sub    %edi,%ebx
  802b6b:	d3 e6                	shl    %cl,%esi
  802b6d:	89 d9                	mov    %ebx,%ecx
  802b6f:	d3 ed                	shr    %cl,%ebp
  802b71:	89 f9                	mov    %edi,%ecx
  802b73:	d3 e0                	shl    %cl,%eax
  802b75:	09 ee                	or     %ebp,%esi
  802b77:	89 d9                	mov    %ebx,%ecx
  802b79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b7d:	89 d5                	mov    %edx,%ebp
  802b7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b83:	d3 ed                	shr    %cl,%ebp
  802b85:	89 f9                	mov    %edi,%ecx
  802b87:	d3 e2                	shl    %cl,%edx
  802b89:	89 d9                	mov    %ebx,%ecx
  802b8b:	d3 e8                	shr    %cl,%eax
  802b8d:	09 c2                	or     %eax,%edx
  802b8f:	89 d0                	mov    %edx,%eax
  802b91:	89 ea                	mov    %ebp,%edx
  802b93:	f7 f6                	div    %esi
  802b95:	89 d5                	mov    %edx,%ebp
  802b97:	89 c3                	mov    %eax,%ebx
  802b99:	f7 64 24 0c          	mull   0xc(%esp)
  802b9d:	39 d5                	cmp    %edx,%ebp
  802b9f:	72 10                	jb     802bb1 <__udivdi3+0xc1>
  802ba1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802ba5:	89 f9                	mov    %edi,%ecx
  802ba7:	d3 e6                	shl    %cl,%esi
  802ba9:	39 c6                	cmp    %eax,%esi
  802bab:	73 07                	jae    802bb4 <__udivdi3+0xc4>
  802bad:	39 d5                	cmp    %edx,%ebp
  802baf:	75 03                	jne    802bb4 <__udivdi3+0xc4>
  802bb1:	83 eb 01             	sub    $0x1,%ebx
  802bb4:	31 ff                	xor    %edi,%edi
  802bb6:	89 d8                	mov    %ebx,%eax
  802bb8:	89 fa                	mov    %edi,%edx
  802bba:	83 c4 1c             	add    $0x1c,%esp
  802bbd:	5b                   	pop    %ebx
  802bbe:	5e                   	pop    %esi
  802bbf:	5f                   	pop    %edi
  802bc0:	5d                   	pop    %ebp
  802bc1:	c3                   	ret    
  802bc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802bc8:	31 ff                	xor    %edi,%edi
  802bca:	31 db                	xor    %ebx,%ebx
  802bcc:	89 d8                	mov    %ebx,%eax
  802bce:	89 fa                	mov    %edi,%edx
  802bd0:	83 c4 1c             	add    $0x1c,%esp
  802bd3:	5b                   	pop    %ebx
  802bd4:	5e                   	pop    %esi
  802bd5:	5f                   	pop    %edi
  802bd6:	5d                   	pop    %ebp
  802bd7:	c3                   	ret    
  802bd8:	90                   	nop
  802bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802be0:	89 d8                	mov    %ebx,%eax
  802be2:	f7 f7                	div    %edi
  802be4:	31 ff                	xor    %edi,%edi
  802be6:	89 c3                	mov    %eax,%ebx
  802be8:	89 d8                	mov    %ebx,%eax
  802bea:	89 fa                	mov    %edi,%edx
  802bec:	83 c4 1c             	add    $0x1c,%esp
  802bef:	5b                   	pop    %ebx
  802bf0:	5e                   	pop    %esi
  802bf1:	5f                   	pop    %edi
  802bf2:	5d                   	pop    %ebp
  802bf3:	c3                   	ret    
  802bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bf8:	39 ce                	cmp    %ecx,%esi
  802bfa:	72 0c                	jb     802c08 <__udivdi3+0x118>
  802bfc:	31 db                	xor    %ebx,%ebx
  802bfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802c02:	0f 87 34 ff ff ff    	ja     802b3c <__udivdi3+0x4c>
  802c08:	bb 01 00 00 00       	mov    $0x1,%ebx
  802c0d:	e9 2a ff ff ff       	jmp    802b3c <__udivdi3+0x4c>
  802c12:	66 90                	xchg   %ax,%ax
  802c14:	66 90                	xchg   %ax,%ax
  802c16:	66 90                	xchg   %ax,%ax
  802c18:	66 90                	xchg   %ax,%ax
  802c1a:	66 90                	xchg   %ax,%ax
  802c1c:	66 90                	xchg   %ax,%ax
  802c1e:	66 90                	xchg   %ax,%ax

00802c20 <__umoddi3>:
  802c20:	55                   	push   %ebp
  802c21:	57                   	push   %edi
  802c22:	56                   	push   %esi
  802c23:	53                   	push   %ebx
  802c24:	83 ec 1c             	sub    $0x1c,%esp
  802c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802c2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802c33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802c37:	85 d2                	test   %edx,%edx
  802c39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c41:	89 f3                	mov    %esi,%ebx
  802c43:	89 3c 24             	mov    %edi,(%esp)
  802c46:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c4a:	75 1c                	jne    802c68 <__umoddi3+0x48>
  802c4c:	39 f7                	cmp    %esi,%edi
  802c4e:	76 50                	jbe    802ca0 <__umoddi3+0x80>
  802c50:	89 c8                	mov    %ecx,%eax
  802c52:	89 f2                	mov    %esi,%edx
  802c54:	f7 f7                	div    %edi
  802c56:	89 d0                	mov    %edx,%eax
  802c58:	31 d2                	xor    %edx,%edx
  802c5a:	83 c4 1c             	add    $0x1c,%esp
  802c5d:	5b                   	pop    %ebx
  802c5e:	5e                   	pop    %esi
  802c5f:	5f                   	pop    %edi
  802c60:	5d                   	pop    %ebp
  802c61:	c3                   	ret    
  802c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c68:	39 f2                	cmp    %esi,%edx
  802c6a:	89 d0                	mov    %edx,%eax
  802c6c:	77 52                	ja     802cc0 <__umoddi3+0xa0>
  802c6e:	0f bd ea             	bsr    %edx,%ebp
  802c71:	83 f5 1f             	xor    $0x1f,%ebp
  802c74:	75 5a                	jne    802cd0 <__umoddi3+0xb0>
  802c76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802c7a:	0f 82 e0 00 00 00    	jb     802d60 <__umoddi3+0x140>
  802c80:	39 0c 24             	cmp    %ecx,(%esp)
  802c83:	0f 86 d7 00 00 00    	jbe    802d60 <__umoddi3+0x140>
  802c89:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c91:	83 c4 1c             	add    $0x1c,%esp
  802c94:	5b                   	pop    %ebx
  802c95:	5e                   	pop    %esi
  802c96:	5f                   	pop    %edi
  802c97:	5d                   	pop    %ebp
  802c98:	c3                   	ret    
  802c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ca0:	85 ff                	test   %edi,%edi
  802ca2:	89 fd                	mov    %edi,%ebp
  802ca4:	75 0b                	jne    802cb1 <__umoddi3+0x91>
  802ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  802cab:	31 d2                	xor    %edx,%edx
  802cad:	f7 f7                	div    %edi
  802caf:	89 c5                	mov    %eax,%ebp
  802cb1:	89 f0                	mov    %esi,%eax
  802cb3:	31 d2                	xor    %edx,%edx
  802cb5:	f7 f5                	div    %ebp
  802cb7:	89 c8                	mov    %ecx,%eax
  802cb9:	f7 f5                	div    %ebp
  802cbb:	89 d0                	mov    %edx,%eax
  802cbd:	eb 99                	jmp    802c58 <__umoddi3+0x38>
  802cbf:	90                   	nop
  802cc0:	89 c8                	mov    %ecx,%eax
  802cc2:	89 f2                	mov    %esi,%edx
  802cc4:	83 c4 1c             	add    $0x1c,%esp
  802cc7:	5b                   	pop    %ebx
  802cc8:	5e                   	pop    %esi
  802cc9:	5f                   	pop    %edi
  802cca:	5d                   	pop    %ebp
  802ccb:	c3                   	ret    
  802ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802cd0:	8b 34 24             	mov    (%esp),%esi
  802cd3:	bf 20 00 00 00       	mov    $0x20,%edi
  802cd8:	89 e9                	mov    %ebp,%ecx
  802cda:	29 ef                	sub    %ebp,%edi
  802cdc:	d3 e0                	shl    %cl,%eax
  802cde:	89 f9                	mov    %edi,%ecx
  802ce0:	89 f2                	mov    %esi,%edx
  802ce2:	d3 ea                	shr    %cl,%edx
  802ce4:	89 e9                	mov    %ebp,%ecx
  802ce6:	09 c2                	or     %eax,%edx
  802ce8:	89 d8                	mov    %ebx,%eax
  802cea:	89 14 24             	mov    %edx,(%esp)
  802ced:	89 f2                	mov    %esi,%edx
  802cef:	d3 e2                	shl    %cl,%edx
  802cf1:	89 f9                	mov    %edi,%ecx
  802cf3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802cf7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802cfb:	d3 e8                	shr    %cl,%eax
  802cfd:	89 e9                	mov    %ebp,%ecx
  802cff:	89 c6                	mov    %eax,%esi
  802d01:	d3 e3                	shl    %cl,%ebx
  802d03:	89 f9                	mov    %edi,%ecx
  802d05:	89 d0                	mov    %edx,%eax
  802d07:	d3 e8                	shr    %cl,%eax
  802d09:	89 e9                	mov    %ebp,%ecx
  802d0b:	09 d8                	or     %ebx,%eax
  802d0d:	89 d3                	mov    %edx,%ebx
  802d0f:	89 f2                	mov    %esi,%edx
  802d11:	f7 34 24             	divl   (%esp)
  802d14:	89 d6                	mov    %edx,%esi
  802d16:	d3 e3                	shl    %cl,%ebx
  802d18:	f7 64 24 04          	mull   0x4(%esp)
  802d1c:	39 d6                	cmp    %edx,%esi
  802d1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d22:	89 d1                	mov    %edx,%ecx
  802d24:	89 c3                	mov    %eax,%ebx
  802d26:	72 08                	jb     802d30 <__umoddi3+0x110>
  802d28:	75 11                	jne    802d3b <__umoddi3+0x11b>
  802d2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802d2e:	73 0b                	jae    802d3b <__umoddi3+0x11b>
  802d30:	2b 44 24 04          	sub    0x4(%esp),%eax
  802d34:	1b 14 24             	sbb    (%esp),%edx
  802d37:	89 d1                	mov    %edx,%ecx
  802d39:	89 c3                	mov    %eax,%ebx
  802d3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802d3f:	29 da                	sub    %ebx,%edx
  802d41:	19 ce                	sbb    %ecx,%esi
  802d43:	89 f9                	mov    %edi,%ecx
  802d45:	89 f0                	mov    %esi,%eax
  802d47:	d3 e0                	shl    %cl,%eax
  802d49:	89 e9                	mov    %ebp,%ecx
  802d4b:	d3 ea                	shr    %cl,%edx
  802d4d:	89 e9                	mov    %ebp,%ecx
  802d4f:	d3 ee                	shr    %cl,%esi
  802d51:	09 d0                	or     %edx,%eax
  802d53:	89 f2                	mov    %esi,%edx
  802d55:	83 c4 1c             	add    $0x1c,%esp
  802d58:	5b                   	pop    %ebx
  802d59:	5e                   	pop    %esi
  802d5a:	5f                   	pop    %edi
  802d5b:	5d                   	pop    %ebp
  802d5c:	c3                   	ret    
  802d5d:	8d 76 00             	lea    0x0(%esi),%esi
  802d60:	29 f9                	sub    %edi,%ecx
  802d62:	19 d6                	sbb    %edx,%esi
  802d64:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d6c:	e9 18 ff ff ff       	jmp    802c89 <__umoddi3+0x69>
