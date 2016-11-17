
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 e0 	movl   $0x8023e0,0x803000
  800045:	23 80 00 

	cprintf("icode startup\n");
  800048:	68 e6 23 80 00       	push   $0x8023e6
  80004d:	e8 13 02 00 00       	call   800265 <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 f5 23 80 00 	movl   $0x8023f5,(%esp)
  800059:	e8 07 02 00 00       	call   800265 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 08 24 80 00       	push   $0x802408
  800068:	e8 ac 14 00 00       	call   801519 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 0e 24 80 00       	push   $0x80240e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 24 24 80 00       	push   $0x802424
  800083:	e8 04 01 00 00       	call   80018c <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 31 24 80 00       	push   $0x802431
  800090:	e8 d0 01 00 00       	call   800265 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 87 0a 00 00       	call   800b31 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 fe 0f 00 00       	call   8010ba <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 44 24 80 00       	push   $0x802444
  8000cb:	e8 95 01 00 00       	call   800265 <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 a6 0e 00 00       	call   800f7e <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 58 24 80 00 	movl   $0x802458,(%esp)
  8000df:	e8 81 01 00 00       	call   800265 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 6c 24 80 00       	push   $0x80246c
  8000f0:	68 75 24 80 00       	push   $0x802475
  8000f5:	68 7f 24 80 00       	push   $0x80247f
  8000fa:	68 7e 24 80 00       	push   $0x80247e
  8000ff:	e8 7c 19 00 00       	call   801a80 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 84 24 80 00       	push   $0x802484
  800111:	6a 1a                	push   $0x1a
  800113:	68 24 24 80 00       	push   $0x802424
  800118:	e8 6f 00 00 00       	call   80018c <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 9b 24 80 00       	push   $0x80249b
  800125:	e8 3b 01 00 00       	call   800265 <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  80013f:	e8 6b 0a 00 00       	call   800baf <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800180:	6a 00                	push   $0x0
  800182:	e8 e7 09 00 00       	call   800b6e <sys_env_destroy>
}
  800187:	83 c4 10             	add    $0x10,%esp
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800191:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800194:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80019a:	e8 10 0a 00 00       	call   800baf <sys_getenvid>
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	ff 75 0c             	pushl  0xc(%ebp)
  8001a5:	ff 75 08             	pushl  0x8(%ebp)
  8001a8:	56                   	push   %esi
  8001a9:	50                   	push   %eax
  8001aa:	68 b8 24 80 00       	push   $0x8024b8
  8001af:	e8 b1 00 00 00       	call   800265 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	53                   	push   %ebx
  8001b8:	ff 75 10             	pushl  0x10(%ebp)
  8001bb:	e8 54 00 00 00       	call   800214 <vcprintf>
	cprintf("\n");
  8001c0:	c7 04 24 9e 29 80 00 	movl   $0x80299e,(%esp)
  8001c7:	e8 99 00 00 00       	call   800265 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cf:	cc                   	int3   
  8001d0:	eb fd                	jmp    8001cf <_panic+0x43>

008001d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 04             	sub    $0x4,%esp
  8001d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001dc:	8b 13                	mov    (%ebx),%edx
  8001de:	8d 42 01             	lea    0x1(%edx),%eax
  8001e1:	89 03                	mov    %eax,(%ebx)
  8001e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ef:	75 1a                	jne    80020b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	68 ff 00 00 00       	push   $0xff
  8001f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fc:	50                   	push   %eax
  8001fd:	e8 2f 09 00 00       	call   800b31 <sys_cputs>
		b->idx = 0;
  800202:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800208:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80020b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80020f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80021d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800224:	00 00 00 
	b.cnt = 0;
  800227:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	ff 75 08             	pushl  0x8(%ebp)
  800237:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023d:	50                   	push   %eax
  80023e:	68 d2 01 80 00       	push   $0x8001d2
  800243:	e8 54 01 00 00       	call   80039c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800248:	83 c4 08             	add    $0x8,%esp
  80024b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800251:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800257:	50                   	push   %eax
  800258:	e8 d4 08 00 00       	call   800b31 <sys_cputs>

	return b.cnt;
}
  80025d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026e:	50                   	push   %eax
  80026f:	ff 75 08             	pushl  0x8(%ebp)
  800272:	e8 9d ff ff ff       	call   800214 <vcprintf>
	va_end(ap);

	return cnt;
}
  800277:	c9                   	leave  
  800278:	c3                   	ret    

00800279 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 1c             	sub    $0x1c,%esp
  800282:	89 c7                	mov    %eax,%edi
  800284:	89 d6                	mov    %edx,%esi
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	8b 55 0c             	mov    0xc(%ebp),%edx
  80028c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800292:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800295:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80029d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a0:	39 d3                	cmp    %edx,%ebx
  8002a2:	72 05                	jb     8002a9 <printnum+0x30>
  8002a4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a7:	77 45                	ja     8002ee <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a9:	83 ec 0c             	sub    $0xc,%esp
  8002ac:	ff 75 18             	pushl  0x18(%ebp)
  8002af:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002b5:	53                   	push   %ebx
  8002b6:	ff 75 10             	pushl  0x10(%ebp)
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c8:	e8 83 1e 00 00       	call   802150 <__udivdi3>
  8002cd:	83 c4 18             	add    $0x18,%esp
  8002d0:	52                   	push   %edx
  8002d1:	50                   	push   %eax
  8002d2:	89 f2                	mov    %esi,%edx
  8002d4:	89 f8                	mov    %edi,%eax
  8002d6:	e8 9e ff ff ff       	call   800279 <printnum>
  8002db:	83 c4 20             	add    $0x20,%esp
  8002de:	eb 18                	jmp    8002f8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	56                   	push   %esi
  8002e4:	ff 75 18             	pushl  0x18(%ebp)
  8002e7:	ff d7                	call   *%edi
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	eb 03                	jmp    8002f1 <printnum+0x78>
  8002ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f1:	83 eb 01             	sub    $0x1,%ebx
  8002f4:	85 db                	test   %ebx,%ebx
  8002f6:	7f e8                	jg     8002e0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f8:	83 ec 08             	sub    $0x8,%esp
  8002fb:	56                   	push   %esi
  8002fc:	83 ec 04             	sub    $0x4,%esp
  8002ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800302:	ff 75 e0             	pushl  -0x20(%ebp)
  800305:	ff 75 dc             	pushl  -0x24(%ebp)
  800308:	ff 75 d8             	pushl  -0x28(%ebp)
  80030b:	e8 70 1f 00 00       	call   802280 <__umoddi3>
  800310:	83 c4 14             	add    $0x14,%esp
  800313:	0f be 80 db 24 80 00 	movsbl 0x8024db(%eax),%eax
  80031a:	50                   	push   %eax
  80031b:	ff d7                	call   *%edi
}
  80031d:	83 c4 10             	add    $0x10,%esp
  800320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032b:	83 fa 01             	cmp    $0x1,%edx
  80032e:	7e 0e                	jle    80033e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800330:	8b 10                	mov    (%eax),%edx
  800332:	8d 4a 08             	lea    0x8(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 02                	mov    (%edx),%eax
  800339:	8b 52 04             	mov    0x4(%edx),%edx
  80033c:	eb 22                	jmp    800360 <getuint+0x38>
	else if (lflag)
  80033e:	85 d2                	test   %edx,%edx
  800340:	74 10                	je     800352 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 4a 04             	lea    0x4(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	eb 0e                	jmp    800360 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 04             	lea    0x4(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    

00800362 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800368:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	3b 50 04             	cmp    0x4(%eax),%edx
  800371:	73 0a                	jae    80037d <sprintputch+0x1b>
		*b->buf++ = ch;
  800373:	8d 4a 01             	lea    0x1(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	88 02                	mov    %al,(%edx)
}
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800385:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800388:	50                   	push   %eax
  800389:	ff 75 10             	pushl  0x10(%ebp)
  80038c:	ff 75 0c             	pushl  0xc(%ebp)
  80038f:	ff 75 08             	pushl  0x8(%ebp)
  800392:	e8 05 00 00 00       	call   80039c <vprintfmt>
	va_end(ap);
}
  800397:	83 c4 10             	add    $0x10,%esp
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	57                   	push   %edi
  8003a0:	56                   	push   %esi
  8003a1:	53                   	push   %ebx
  8003a2:	83 ec 2c             	sub    $0x2c,%esp
  8003a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003ae:	eb 12                	jmp    8003c2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b0:	85 c0                	test   %eax,%eax
  8003b2:	0f 84 89 03 00 00    	je     800741 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003b8:	83 ec 08             	sub    $0x8,%esp
  8003bb:	53                   	push   %ebx
  8003bc:	50                   	push   %eax
  8003bd:	ff d6                	call   *%esi
  8003bf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c2:	83 c7 01             	add    $0x1,%edi
  8003c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003c9:	83 f8 25             	cmp    $0x25,%eax
  8003cc:	75 e2                	jne    8003b0 <vprintfmt+0x14>
  8003ce:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ec:	eb 07                	jmp    8003f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8d 47 01             	lea    0x1(%edi),%eax
  8003f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fb:	0f b6 07             	movzbl (%edi),%eax
  8003fe:	0f b6 c8             	movzbl %al,%ecx
  800401:	83 e8 23             	sub    $0x23,%eax
  800404:	3c 55                	cmp    $0x55,%al
  800406:	0f 87 1a 03 00 00    	ja     800726 <vprintfmt+0x38a>
  80040c:	0f b6 c0             	movzbl %al,%eax
  80040f:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800419:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041d:	eb d6                	jmp    8003f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800431:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800434:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800437:	83 fa 09             	cmp    $0x9,%edx
  80043a:	77 39                	ja     800475 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043f:	eb e9                	jmp    80042a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 48 04             	lea    0x4(%eax),%ecx
  800447:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800452:	eb 27                	jmp    80047b <vprintfmt+0xdf>
  800454:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045e:	0f 49 c8             	cmovns %eax,%ecx
  800461:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800467:	eb 8c                	jmp    8003f5 <vprintfmt+0x59>
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800473:	eb 80                	jmp    8003f5 <vprintfmt+0x59>
  800475:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800478:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80047b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047f:	0f 89 70 ff ff ff    	jns    8003f5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800485:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800488:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800492:	e9 5e ff ff ff       	jmp    8003f5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800497:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049d:	e9 53 ff ff ff       	jmp    8003f5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 50 04             	lea    0x4(%eax),%edx
  8004a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 30                	pushl  (%eax)
  8004b1:	ff d6                	call   *%esi
			break;
  8004b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b9:	e9 04 ff ff ff       	jmp    8003c2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	99                   	cltd   
  8004ca:	31 d0                	xor    %edx,%eax
  8004cc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ce:	83 f8 0f             	cmp    $0xf,%eax
  8004d1:	7f 0b                	jg     8004de <vprintfmt+0x142>
  8004d3:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	75 18                	jne    8004f6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004de:	50                   	push   %eax
  8004df:	68 f3 24 80 00       	push   $0x8024f3
  8004e4:	53                   	push   %ebx
  8004e5:	56                   	push   %esi
  8004e6:	e8 94 fe ff ff       	call   80037f <printfmt>
  8004eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f1:	e9 cc fe ff ff       	jmp    8003c2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f6:	52                   	push   %edx
  8004f7:	68 da 28 80 00       	push   $0x8028da
  8004fc:	53                   	push   %ebx
  8004fd:	56                   	push   %esi
  8004fe:	e8 7c fe ff ff       	call   80037f <printfmt>
  800503:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	e9 b4 fe ff ff       	jmp    8003c2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 04             	lea    0x4(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800519:	85 ff                	test   %edi,%edi
  80051b:	b8 ec 24 80 00       	mov    $0x8024ec,%eax
  800520:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800523:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800527:	0f 8e 94 00 00 00    	jle    8005c1 <vprintfmt+0x225>
  80052d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800531:	0f 84 98 00 00 00    	je     8005cf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 d0             	pushl  -0x30(%ebp)
  80053d:	57                   	push   %edi
  80053e:	e8 86 02 00 00       	call   8007c9 <strnlen>
  800543:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800546:	29 c1                	sub    %eax,%ecx
  800548:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80054b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80054e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800552:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800555:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800558:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055a:	eb 0f                	jmp    80056b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	ff 75 e0             	pushl  -0x20(%ebp)
  800563:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	83 ef 01             	sub    $0x1,%edi
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	85 ff                	test   %edi,%edi
  80056d:	7f ed                	jg     80055c <vprintfmt+0x1c0>
  80056f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800572:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800575:	85 c9                	test   %ecx,%ecx
  800577:	b8 00 00 00 00       	mov    $0x0,%eax
  80057c:	0f 49 c1             	cmovns %ecx,%eax
  80057f:	29 c1                	sub    %eax,%ecx
  800581:	89 75 08             	mov    %esi,0x8(%ebp)
  800584:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800587:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058a:	89 cb                	mov    %ecx,%ebx
  80058c:	eb 4d                	jmp    8005db <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800592:	74 1b                	je     8005af <vprintfmt+0x213>
  800594:	0f be c0             	movsbl %al,%eax
  800597:	83 e8 20             	sub    $0x20,%eax
  80059a:	83 f8 5e             	cmp    $0x5e,%eax
  80059d:	76 10                	jbe    8005af <vprintfmt+0x213>
					putch('?', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	ff 75 0c             	pushl  0xc(%ebp)
  8005a5:	6a 3f                	push   $0x3f
  8005a7:	ff 55 08             	call   *0x8(%ebp)
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	eb 0d                	jmp    8005bc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	ff 75 0c             	pushl  0xc(%ebp)
  8005b5:	52                   	push   %edx
  8005b6:	ff 55 08             	call   *0x8(%ebp)
  8005b9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bc:	83 eb 01             	sub    $0x1,%ebx
  8005bf:	eb 1a                	jmp    8005db <vprintfmt+0x23f>
  8005c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cd:	eb 0c                	jmp    8005db <vprintfmt+0x23f>
  8005cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005db:	83 c7 01             	add    $0x1,%edi
  8005de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e2:	0f be d0             	movsbl %al,%edx
  8005e5:	85 d2                	test   %edx,%edx
  8005e7:	74 23                	je     80060c <vprintfmt+0x270>
  8005e9:	85 f6                	test   %esi,%esi
  8005eb:	78 a1                	js     80058e <vprintfmt+0x1f2>
  8005ed:	83 ee 01             	sub    $0x1,%esi
  8005f0:	79 9c                	jns    80058e <vprintfmt+0x1f2>
  8005f2:	89 df                	mov    %ebx,%edi
  8005f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fa:	eb 18                	jmp    800614 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	6a 20                	push   $0x20
  800602:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800604:	83 ef 01             	sub    $0x1,%edi
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	eb 08                	jmp    800614 <vprintfmt+0x278>
  80060c:	89 df                	mov    %ebx,%edi
  80060e:	8b 75 08             	mov    0x8(%ebp),%esi
  800611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800614:	85 ff                	test   %edi,%edi
  800616:	7f e4                	jg     8005fc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061b:	e9 a2 fd ff ff       	jmp    8003c2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800620:	83 fa 01             	cmp    $0x1,%edx
  800623:	7e 16                	jle    80063b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 08             	lea    0x8(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 50 04             	mov    0x4(%eax),%edx
  800631:	8b 00                	mov    (%eax),%eax
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800639:	eb 32                	jmp    80066d <vprintfmt+0x2d1>
	else if (lflag)
  80063b:	85 d2                	test   %edx,%edx
  80063d:	74 18                	je     800657 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064d:	89 c1                	mov    %eax,%ecx
  80064f:	c1 f9 1f             	sar    $0x1f,%ecx
  800652:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800655:	eb 16                	jmp    80066d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	89 c1                	mov    %eax,%ecx
  800667:	c1 f9 1f             	sar    $0x1f,%ecx
  80066a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800670:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800673:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800678:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067c:	79 74                	jns    8006f2 <vprintfmt+0x356>
				putch('-', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	6a 2d                	push   $0x2d
  800684:	ff d6                	call   *%esi
				num = -(long long) num;
  800686:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800689:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80068c:	f7 d8                	neg    %eax
  80068e:	83 d2 00             	adc    $0x0,%edx
  800691:	f7 da                	neg    %edx
  800693:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800696:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80069b:	eb 55                	jmp    8006f2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80069d:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a0:	e8 83 fc ff ff       	call   800328 <getuint>
			base = 10;
  8006a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006aa:	eb 46                	jmp    8006f2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8006af:	e8 74 fc ff ff       	call   800328 <getuint>
			base = 8;
  8006b4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006b9:	eb 37                	jmp    8006f2 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 30                	push   $0x30
  8006c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c3:	83 c4 08             	add    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 78                	push   $0x78
  8006c9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006db:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006de:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006e3:	eb 0d                	jmp    8006f2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e8:	e8 3b fc ff ff       	call   800328 <getuint>
			base = 16;
  8006ed:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f2:	83 ec 0c             	sub    $0xc,%esp
  8006f5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f9:	57                   	push   %edi
  8006fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fd:	51                   	push   %ecx
  8006fe:	52                   	push   %edx
  8006ff:	50                   	push   %eax
  800700:	89 da                	mov    %ebx,%edx
  800702:	89 f0                	mov    %esi,%eax
  800704:	e8 70 fb ff ff       	call   800279 <printnum>
			break;
  800709:	83 c4 20             	add    $0x20,%esp
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070f:	e9 ae fc ff ff       	jmp    8003c2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	51                   	push   %ecx
  800719:	ff d6                	call   *%esi
			break;
  80071b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800721:	e9 9c fc ff ff       	jmp    8003c2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 25                	push   $0x25
  80072c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	eb 03                	jmp    800736 <vprintfmt+0x39a>
  800733:	83 ef 01             	sub    $0x1,%edi
  800736:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80073a:	75 f7                	jne    800733 <vprintfmt+0x397>
  80073c:	e9 81 fc ff ff       	jmp    8003c2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800744:	5b                   	pop    %ebx
  800745:	5e                   	pop    %esi
  800746:	5f                   	pop    %edi
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 18             	sub    $0x18,%esp
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800755:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800758:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800766:	85 c0                	test   %eax,%eax
  800768:	74 26                	je     800790 <vsnprintf+0x47>
  80076a:	85 d2                	test   %edx,%edx
  80076c:	7e 22                	jle    800790 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076e:	ff 75 14             	pushl  0x14(%ebp)
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	68 62 03 80 00       	push   $0x800362
  80077d:	e8 1a fc ff ff       	call   80039c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800782:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800785:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	eb 05                	jmp    800795 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800790:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a0:	50                   	push   %eax
  8007a1:	ff 75 10             	pushl  0x10(%ebp)
  8007a4:	ff 75 0c             	pushl  0xc(%ebp)
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 9a ff ff ff       	call   800749 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bc:	eb 03                	jmp    8007c1 <strlen+0x10>
		n++;
  8007be:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c5:	75 f7                	jne    8007be <strlen+0xd>
		n++;
	return n;
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d7:	eb 03                	jmp    8007dc <strnlen+0x13>
		n++;
  8007d9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dc:	39 c2                	cmp    %eax,%edx
  8007de:	74 08                	je     8007e8 <strnlen+0x1f>
  8007e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e4:	75 f3                	jne    8007d9 <strnlen+0x10>
  8007e6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	83 c1 01             	add    $0x1,%ecx
  8007fc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800800:	88 5a ff             	mov    %bl,-0x1(%edx)
  800803:	84 db                	test   %bl,%bl
  800805:	75 ef                	jne    8007f6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800811:	53                   	push   %ebx
  800812:	e8 9a ff ff ff       	call   8007b1 <strlen>
  800817:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081a:	ff 75 0c             	pushl  0xc(%ebp)
  80081d:	01 d8                	add    %ebx,%eax
  80081f:	50                   	push   %eax
  800820:	e8 c5 ff ff ff       	call   8007ea <strcpy>
	return dst;
}
  800825:	89 d8                	mov    %ebx,%eax
  800827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 75 08             	mov    0x8(%ebp),%esi
  800834:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800837:	89 f3                	mov    %esi,%ebx
  800839:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083c:	89 f2                	mov    %esi,%edx
  80083e:	eb 0f                	jmp    80084f <strncpy+0x23>
		*dst++ = *src;
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	0f b6 01             	movzbl (%ecx),%eax
  800846:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800849:	80 39 01             	cmpb   $0x1,(%ecx)
  80084c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084f:	39 da                	cmp    %ebx,%edx
  800851:	75 ed                	jne    800840 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800853:	89 f0                	mov    %esi,%eax
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800864:	8b 55 10             	mov    0x10(%ebp),%edx
  800867:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800869:	85 d2                	test   %edx,%edx
  80086b:	74 21                	je     80088e <strlcpy+0x35>
  80086d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800871:	89 f2                	mov    %esi,%edx
  800873:	eb 09                	jmp    80087e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800875:	83 c2 01             	add    $0x1,%edx
  800878:	83 c1 01             	add    $0x1,%ecx
  80087b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087e:	39 c2                	cmp    %eax,%edx
  800880:	74 09                	je     80088b <strlcpy+0x32>
  800882:	0f b6 19             	movzbl (%ecx),%ebx
  800885:	84 db                	test   %bl,%bl
  800887:	75 ec                	jne    800875 <strlcpy+0x1c>
  800889:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80088b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088e:	29 f0                	sub    %esi,%eax
}
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089d:	eb 06                	jmp    8008a5 <strcmp+0x11>
		p++, q++;
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a5:	0f b6 01             	movzbl (%ecx),%eax
  8008a8:	84 c0                	test   %al,%al
  8008aa:	74 04                	je     8008b0 <strcmp+0x1c>
  8008ac:	3a 02                	cmp    (%edx),%al
  8008ae:	74 ef                	je     80089f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b0:	0f b6 c0             	movzbl %al,%eax
  8008b3:	0f b6 12             	movzbl (%edx),%edx
  8008b6:	29 d0                	sub    %edx,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c4:	89 c3                	mov    %eax,%ebx
  8008c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c9:	eb 06                	jmp    8008d1 <strncmp+0x17>
		n--, p++, q++;
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d1:	39 d8                	cmp    %ebx,%eax
  8008d3:	74 15                	je     8008ea <strncmp+0x30>
  8008d5:	0f b6 08             	movzbl (%eax),%ecx
  8008d8:	84 c9                	test   %cl,%cl
  8008da:	74 04                	je     8008e0 <strncmp+0x26>
  8008dc:	3a 0a                	cmp    (%edx),%cl
  8008de:	74 eb                	je     8008cb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e0:	0f b6 00             	movzbl (%eax),%eax
  8008e3:	0f b6 12             	movzbl (%edx),%edx
  8008e6:	29 d0                	sub    %edx,%eax
  8008e8:	eb 05                	jmp    8008ef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ef:	5b                   	pop    %ebx
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fc:	eb 07                	jmp    800905 <strchr+0x13>
		if (*s == c)
  8008fe:	38 ca                	cmp    %cl,%dl
  800900:	74 0f                	je     800911 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800902:	83 c0 01             	add    $0x1,%eax
  800905:	0f b6 10             	movzbl (%eax),%edx
  800908:	84 d2                	test   %dl,%dl
  80090a:	75 f2                	jne    8008fe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091d:	eb 03                	jmp    800922 <strfind+0xf>
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 04                	je     80092d <strfind+0x1a>
  800929:	84 d2                	test   %dl,%dl
  80092b:	75 f2                	jne    80091f <strfind+0xc>
			break;
	return (char *) s;
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 7d 08             	mov    0x8(%ebp),%edi
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	74 36                	je     800975 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800945:	75 28                	jne    80096f <memset+0x40>
  800947:	f6 c1 03             	test   $0x3,%cl
  80094a:	75 23                	jne    80096f <memset+0x40>
		c &= 0xFF;
  80094c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800950:	89 d3                	mov    %edx,%ebx
  800952:	c1 e3 08             	shl    $0x8,%ebx
  800955:	89 d6                	mov    %edx,%esi
  800957:	c1 e6 18             	shl    $0x18,%esi
  80095a:	89 d0                	mov    %edx,%eax
  80095c:	c1 e0 10             	shl    $0x10,%eax
  80095f:	09 f0                	or     %esi,%eax
  800961:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800963:	89 d8                	mov    %ebx,%eax
  800965:	09 d0                	or     %edx,%eax
  800967:	c1 e9 02             	shr    $0x2,%ecx
  80096a:	fc                   	cld    
  80096b:	f3 ab                	rep stos %eax,%es:(%edi)
  80096d:	eb 06                	jmp    800975 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	fc                   	cld    
  800973:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800975:	89 f8                	mov    %edi,%eax
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 75 0c             	mov    0xc(%ebp),%esi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098a:	39 c6                	cmp    %eax,%esi
  80098c:	73 35                	jae    8009c3 <memmove+0x47>
  80098e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800991:	39 d0                	cmp    %edx,%eax
  800993:	73 2e                	jae    8009c3 <memmove+0x47>
		s += n;
		d += n;
  800995:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800998:	89 d6                	mov    %edx,%esi
  80099a:	09 fe                	or     %edi,%esi
  80099c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a2:	75 13                	jne    8009b7 <memmove+0x3b>
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 0e                	jne    8009b7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a9:	83 ef 04             	sub    $0x4,%edi
  8009ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009af:	c1 e9 02             	shr    $0x2,%ecx
  8009b2:	fd                   	std    
  8009b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b5:	eb 09                	jmp    8009c0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b7:	83 ef 01             	sub    $0x1,%edi
  8009ba:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009bd:	fd                   	std    
  8009be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c0:	fc                   	cld    
  8009c1:	eb 1d                	jmp    8009e0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c3:	89 f2                	mov    %esi,%edx
  8009c5:	09 c2                	or     %eax,%edx
  8009c7:	f6 c2 03             	test   $0x3,%dl
  8009ca:	75 0f                	jne    8009db <memmove+0x5f>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 0a                	jne    8009db <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d1:	c1 e9 02             	shr    $0x2,%ecx
  8009d4:	89 c7                	mov    %eax,%edi
  8009d6:	fc                   	cld    
  8009d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d9:	eb 05                	jmp    8009e0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009db:	89 c7                	mov    %eax,%edi
  8009dd:	fc                   	cld    
  8009de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e7:	ff 75 10             	pushl  0x10(%ebp)
  8009ea:	ff 75 0c             	pushl  0xc(%ebp)
  8009ed:	ff 75 08             	pushl  0x8(%ebp)
  8009f0:	e8 87 ff ff ff       	call   80097c <memmove>
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 c6                	mov    %eax,%esi
  800a04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	eb 1a                	jmp    800a23 <memcmp+0x2c>
		if (*s1 != *s2)
  800a09:	0f b6 08             	movzbl (%eax),%ecx
  800a0c:	0f b6 1a             	movzbl (%edx),%ebx
  800a0f:	38 d9                	cmp    %bl,%cl
  800a11:	74 0a                	je     800a1d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a13:	0f b6 c1             	movzbl %cl,%eax
  800a16:	0f b6 db             	movzbl %bl,%ebx
  800a19:	29 d8                	sub    %ebx,%eax
  800a1b:	eb 0f                	jmp    800a2c <memcmp+0x35>
		s1++, s2++;
  800a1d:	83 c0 01             	add    $0x1,%eax
  800a20:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a23:	39 f0                	cmp    %esi,%eax
  800a25:	75 e2                	jne    800a09 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a37:	89 c1                	mov    %eax,%ecx
  800a39:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a40:	eb 0a                	jmp    800a4c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a42:	0f b6 10             	movzbl (%eax),%edx
  800a45:	39 da                	cmp    %ebx,%edx
  800a47:	74 07                	je     800a50 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	39 c8                	cmp    %ecx,%eax
  800a4e:	72 f2                	jb     800a42 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a50:	5b                   	pop    %ebx
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	eb 03                	jmp    800a64 <strtol+0x11>
		s++;
  800a61:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	3c 20                	cmp    $0x20,%al
  800a69:	74 f6                	je     800a61 <strtol+0xe>
  800a6b:	3c 09                	cmp    $0x9,%al
  800a6d:	74 f2                	je     800a61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6f:	3c 2b                	cmp    $0x2b,%al
  800a71:	75 0a                	jne    800a7d <strtol+0x2a>
		s++;
  800a73:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	eb 11                	jmp    800a8e <strtol+0x3b>
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a82:	3c 2d                	cmp    $0x2d,%al
  800a84:	75 08                	jne    800a8e <strtol+0x3b>
		s++, neg = 1;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a94:	75 15                	jne    800aab <strtol+0x58>
  800a96:	80 39 30             	cmpb   $0x30,(%ecx)
  800a99:	75 10                	jne    800aab <strtol+0x58>
  800a9b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9f:	75 7c                	jne    800b1d <strtol+0xca>
		s += 2, base = 16;
  800aa1:	83 c1 02             	add    $0x2,%ecx
  800aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa9:	eb 16                	jmp    800ac1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 12                	jne    800ac1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aaf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab7:	75 08                	jne    800ac1 <strtol+0x6e>
		s++, base = 8;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac9:	0f b6 11             	movzbl (%ecx),%edx
  800acc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 09             	cmp    $0x9,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x8b>
			dig = *s - '0';
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 30             	sub    $0x30,%edx
  800adc:	eb 22                	jmp    800b00 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ade:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 57             	sub    $0x57,%edx
  800aee:	eb 10                	jmp    800b00 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af3:	89 f3                	mov    %esi,%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 16                	ja     800b10 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800afa:	0f be d2             	movsbl %dl,%edx
  800afd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b00:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b03:	7d 0b                	jge    800b10 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b0e:	eb b9                	jmp    800ac9 <strtol+0x76>

	if (endptr)
  800b10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b14:	74 0d                	je     800b23 <strtol+0xd0>
		*endptr = (char *) s;
  800b16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b19:	89 0e                	mov    %ecx,(%esi)
  800b1b:	eb 06                	jmp    800b23 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1d:	85 db                	test   %ebx,%ebx
  800b1f:	74 98                	je     800ab9 <strtol+0x66>
  800b21:	eb 9e                	jmp    800ac1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	f7 da                	neg    %edx
  800b27:	85 ff                	test   %edi,%edi
  800b29:	0f 45 c2             	cmovne %edx,%eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b37:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	89 c3                	mov    %eax,%ebx
  800b44:	89 c7                	mov    %eax,%edi
  800b46:	89 c6                	mov    %eax,%esi
  800b48:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5f:	89 d1                	mov    %edx,%ecx
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b81:	8b 55 08             	mov    0x8(%ebp),%edx
  800b84:	89 cb                	mov    %ecx,%ebx
  800b86:	89 cf                	mov    %ecx,%edi
  800b88:	89 ce                	mov    %ecx,%esi
  800b8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7e 17                	jle    800ba7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 03                	push   $0x3
  800b96:	68 df 27 80 00       	push   $0x8027df
  800b9b:	6a 23                	push   $0x23
  800b9d:	68 fc 27 80 00       	push   $0x8027fc
  800ba2:	e8 e5 f5 ff ff       	call   80018c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_yield>:

void
sys_yield(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	be 00 00 00 00       	mov    $0x0,%esi
  800bfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c09:	89 f7                	mov    %esi,%edi
  800c0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 17                	jle    800c28 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	50                   	push   %eax
  800c15:	6a 04                	push   $0x4
  800c17:	68 df 27 80 00       	push   $0x8027df
  800c1c:	6a 23                	push   $0x23
  800c1e:	68 fc 27 80 00       	push   $0x8027fc
  800c23:	e8 64 f5 ff ff       	call   80018c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 17                	jle    800c6a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 05                	push   $0x5
  800c59:	68 df 27 80 00       	push   $0x8027df
  800c5e:	6a 23                	push   $0x23
  800c60:	68 fc 27 80 00       	push   $0x8027fc
  800c65:	e8 22 f5 ff ff       	call   80018c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c80:	b8 06 00 00 00       	mov    $0x6,%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	89 df                	mov    %ebx,%edi
  800c8d:	89 de                	mov    %ebx,%esi
  800c8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 17                	jle    800cac <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 06                	push   $0x6
  800c9b:	68 df 27 80 00       	push   $0x8027df
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 fc 27 80 00       	push   $0x8027fc
  800ca7:	e8 e0 f4 ff ff       	call   80018c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 17                	jle    800cee <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 08                	push   $0x8
  800cdd:	68 df 27 80 00       	push   $0x8027df
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 fc 27 80 00       	push   $0x8027fc
  800ce9:	e8 9e f4 ff ff       	call   80018c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d04:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800d17:	7e 17                	jle    800d30 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	50                   	push   %eax
  800d1d:	6a 09                	push   $0x9
  800d1f:	68 df 27 80 00       	push   $0x8027df
  800d24:	6a 23                	push   $0x23
  800d26:	68 fc 27 80 00       	push   $0x8027fc
  800d2b:	e8 5c f4 ff ff       	call   80018c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d46:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d59:	7e 17                	jle    800d72 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	50                   	push   %eax
  800d5f:	6a 0a                	push   $0xa
  800d61:	68 df 27 80 00       	push   $0x8027df
  800d66:	6a 23                	push   $0x23
  800d68:	68 fc 27 80 00       	push   $0x8027fc
  800d6d:	e8 1a f4 ff ff       	call   80018c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d80:	be 00 00 00 00       	mov    $0x0,%esi
  800d85:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d93:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d96:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dab:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 cb                	mov    %ecx,%ebx
  800db5:	89 cf                	mov    %ecx,%edi
  800db7:	89 ce                	mov    %ecx,%esi
  800db9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 17                	jle    800dd6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	50                   	push   %eax
  800dc3:	6a 0d                	push   $0xd
  800dc5:	68 df 27 80 00       	push   $0x8027df
  800dca:	6a 23                	push   $0x23
  800dcc:	68 fc 27 80 00       	push   $0x8027fc
  800dd1:	e8 b6 f3 ff ff       	call   80018c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de1:	8b 45 08             	mov    0x8(%ebp),%eax
  800de4:	05 00 00 00 30       	add    $0x30000000,%eax
  800de9:	c1 e8 0c             	shr    $0xc,%eax
}
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	05 00 00 00 30       	add    $0x30000000,%eax
  800df9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dfe:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e10:	89 c2                	mov    %eax,%edx
  800e12:	c1 ea 16             	shr    $0x16,%edx
  800e15:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1c:	f6 c2 01             	test   $0x1,%dl
  800e1f:	74 11                	je     800e32 <fd_alloc+0x2d>
  800e21:	89 c2                	mov    %eax,%edx
  800e23:	c1 ea 0c             	shr    $0xc,%edx
  800e26:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2d:	f6 c2 01             	test   $0x1,%dl
  800e30:	75 09                	jne    800e3b <fd_alloc+0x36>
			*fd_store = fd;
  800e32:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e34:	b8 00 00 00 00       	mov    $0x0,%eax
  800e39:	eb 17                	jmp    800e52 <fd_alloc+0x4d>
  800e3b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e40:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e45:	75 c9                	jne    800e10 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e47:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e4d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e5a:	83 f8 1f             	cmp    $0x1f,%eax
  800e5d:	77 36                	ja     800e95 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e5f:	c1 e0 0c             	shl    $0xc,%eax
  800e62:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	c1 ea 16             	shr    $0x16,%edx
  800e6c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e73:	f6 c2 01             	test   $0x1,%dl
  800e76:	74 24                	je     800e9c <fd_lookup+0x48>
  800e78:	89 c2                	mov    %eax,%edx
  800e7a:	c1 ea 0c             	shr    $0xc,%edx
  800e7d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e84:	f6 c2 01             	test   $0x1,%dl
  800e87:	74 1a                	je     800ea3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8c:	89 02                	mov    %eax,(%edx)
	return 0;
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e93:	eb 13                	jmp    800ea8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9a:	eb 0c                	jmp    800ea8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea1:	eb 05                	jmp    800ea8 <fd_lookup+0x54>
  800ea3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 08             	sub    $0x8,%esp
  800eb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb3:	ba 88 28 80 00       	mov    $0x802888,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb8:	eb 13                	jmp    800ecd <dev_lookup+0x23>
  800eba:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ebd:	39 08                	cmp    %ecx,(%eax)
  800ebf:	75 0c                	jne    800ecd <dev_lookup+0x23>
			*dev = devtab[i];
  800ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ec6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecb:	eb 2e                	jmp    800efb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ecd:	8b 02                	mov    (%edx),%eax
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	75 e7                	jne    800eba <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed3:	a1 04 40 80 00       	mov    0x804004,%eax
  800ed8:	8b 40 48             	mov    0x48(%eax),%eax
  800edb:	83 ec 04             	sub    $0x4,%esp
  800ede:	51                   	push   %ecx
  800edf:	50                   	push   %eax
  800ee0:	68 0c 28 80 00       	push   $0x80280c
  800ee5:	e8 7b f3 ff ff       	call   800265 <cprintf>
	*dev = 0;
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	83 ec 10             	sub    $0x10,%esp
  800f05:	8b 75 08             	mov    0x8(%ebp),%esi
  800f08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0e:	50                   	push   %eax
  800f0f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f15:	c1 e8 0c             	shr    $0xc,%eax
  800f18:	50                   	push   %eax
  800f19:	e8 36 ff ff ff       	call   800e54 <fd_lookup>
  800f1e:	83 c4 08             	add    $0x8,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	78 05                	js     800f2a <fd_close+0x2d>
	    || fd != fd2)
  800f25:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f28:	74 0c                	je     800f36 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f2a:	84 db                	test   %bl,%bl
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	0f 44 c2             	cmove  %edx,%eax
  800f34:	eb 41                	jmp    800f77 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f36:	83 ec 08             	sub    $0x8,%esp
  800f39:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f3c:	50                   	push   %eax
  800f3d:	ff 36                	pushl  (%esi)
  800f3f:	e8 66 ff ff ff       	call   800eaa <dev_lookup>
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	78 1a                	js     800f67 <fd_close+0x6a>
		if (dev->dev_close)
  800f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f50:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f53:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	74 0b                	je     800f67 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	56                   	push   %esi
  800f60:	ff d0                	call   *%eax
  800f62:	89 c3                	mov    %eax,%ebx
  800f64:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f67:	83 ec 08             	sub    $0x8,%esp
  800f6a:	56                   	push   %esi
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 00 fd ff ff       	call   800c72 <sys_page_unmap>
	return r;
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	89 d8                	mov    %ebx,%eax
}
  800f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	ff 75 08             	pushl  0x8(%ebp)
  800f8b:	e8 c4 fe ff ff       	call   800e54 <fd_lookup>
  800f90:	83 c4 08             	add    $0x8,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	78 10                	js     800fa7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f97:	83 ec 08             	sub    $0x8,%esp
  800f9a:	6a 01                	push   $0x1
  800f9c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f9f:	e8 59 ff ff ff       	call   800efd <fd_close>
  800fa4:	83 c4 10             	add    $0x10,%esp
}
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    

00800fa9 <close_all>:

void
close_all(void)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	53                   	push   %ebx
  800fad:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	53                   	push   %ebx
  800fb9:	e8 c0 ff ff ff       	call   800f7e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fbe:	83 c3 01             	add    $0x1,%ebx
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	83 fb 20             	cmp    $0x20,%ebx
  800fc7:	75 ec                	jne    800fb5 <close_all+0xc>
		close(i);
}
  800fc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 2c             	sub    $0x2c,%esp
  800fd7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fda:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdd:	50                   	push   %eax
  800fde:	ff 75 08             	pushl  0x8(%ebp)
  800fe1:	e8 6e fe ff ff       	call   800e54 <fd_lookup>
  800fe6:	83 c4 08             	add    $0x8,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	0f 88 c1 00 00 00    	js     8010b2 <dup+0xe4>
		return r;
	close(newfdnum);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	56                   	push   %esi
  800ff5:	e8 84 ff ff ff       	call   800f7e <close>

	newfd = INDEX2FD(newfdnum);
  800ffa:	89 f3                	mov    %esi,%ebx
  800ffc:	c1 e3 0c             	shl    $0xc,%ebx
  800fff:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801005:	83 c4 04             	add    $0x4,%esp
  801008:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100b:	e8 de fd ff ff       	call   800dee <fd2data>
  801010:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801012:	89 1c 24             	mov    %ebx,(%esp)
  801015:	e8 d4 fd ff ff       	call   800dee <fd2data>
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801020:	89 f8                	mov    %edi,%eax
  801022:	c1 e8 16             	shr    $0x16,%eax
  801025:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102c:	a8 01                	test   $0x1,%al
  80102e:	74 37                	je     801067 <dup+0x99>
  801030:	89 f8                	mov    %edi,%eax
  801032:	c1 e8 0c             	shr    $0xc,%eax
  801035:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103c:	f6 c2 01             	test   $0x1,%dl
  80103f:	74 26                	je     801067 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801041:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	25 07 0e 00 00       	and    $0xe07,%eax
  801050:	50                   	push   %eax
  801051:	ff 75 d4             	pushl  -0x2c(%ebp)
  801054:	6a 00                	push   $0x0
  801056:	57                   	push   %edi
  801057:	6a 00                	push   $0x0
  801059:	e8 d2 fb ff ff       	call   800c30 <sys_page_map>
  80105e:	89 c7                	mov    %eax,%edi
  801060:	83 c4 20             	add    $0x20,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	78 2e                	js     801095 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801067:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80106a:	89 d0                	mov    %edx,%eax
  80106c:	c1 e8 0c             	shr    $0xc,%eax
  80106f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	25 07 0e 00 00       	and    $0xe07,%eax
  80107e:	50                   	push   %eax
  80107f:	53                   	push   %ebx
  801080:	6a 00                	push   $0x0
  801082:	52                   	push   %edx
  801083:	6a 00                	push   $0x0
  801085:	e8 a6 fb ff ff       	call   800c30 <sys_page_map>
  80108a:	89 c7                	mov    %eax,%edi
  80108c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80108f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801091:	85 ff                	test   %edi,%edi
  801093:	79 1d                	jns    8010b2 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	53                   	push   %ebx
  801099:	6a 00                	push   $0x0
  80109b:	e8 d2 fb ff ff       	call   800c72 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010a0:	83 c4 08             	add    $0x8,%esp
  8010a3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a6:	6a 00                	push   $0x0
  8010a8:	e8 c5 fb ff ff       	call   800c72 <sys_page_unmap>
	return r;
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	89 f8                	mov    %edi,%eax
}
  8010b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 14             	sub    $0x14,%esp
  8010c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	53                   	push   %ebx
  8010c9:	e8 86 fd ff ff       	call   800e54 <fd_lookup>
  8010ce:	83 c4 08             	add    $0x8,%esp
  8010d1:	89 c2                	mov    %eax,%edx
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	78 6d                	js     801144 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e1:	ff 30                	pushl  (%eax)
  8010e3:	e8 c2 fd ff ff       	call   800eaa <dev_lookup>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 4c                	js     80113b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f2:	8b 42 08             	mov    0x8(%edx),%eax
  8010f5:	83 e0 03             	and    $0x3,%eax
  8010f8:	83 f8 01             	cmp    $0x1,%eax
  8010fb:	75 21                	jne    80111e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801102:	8b 40 48             	mov    0x48(%eax),%eax
  801105:	83 ec 04             	sub    $0x4,%esp
  801108:	53                   	push   %ebx
  801109:	50                   	push   %eax
  80110a:	68 4d 28 80 00       	push   $0x80284d
  80110f:	e8 51 f1 ff ff       	call   800265 <cprintf>
		return -E_INVAL;
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80111c:	eb 26                	jmp    801144 <read+0x8a>
	}
	if (!dev->dev_read)
  80111e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801121:	8b 40 08             	mov    0x8(%eax),%eax
  801124:	85 c0                	test   %eax,%eax
  801126:	74 17                	je     80113f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801128:	83 ec 04             	sub    $0x4,%esp
  80112b:	ff 75 10             	pushl  0x10(%ebp)
  80112e:	ff 75 0c             	pushl  0xc(%ebp)
  801131:	52                   	push   %edx
  801132:	ff d0                	call   *%eax
  801134:	89 c2                	mov    %eax,%edx
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	eb 09                	jmp    801144 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	eb 05                	jmp    801144 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80113f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801144:	89 d0                	mov    %edx,%eax
  801146:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	57                   	push   %edi
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
  801151:	83 ec 0c             	sub    $0xc,%esp
  801154:	8b 7d 08             	mov    0x8(%ebp),%edi
  801157:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80115a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115f:	eb 21                	jmp    801182 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	89 f0                	mov    %esi,%eax
  801166:	29 d8                	sub    %ebx,%eax
  801168:	50                   	push   %eax
  801169:	89 d8                	mov    %ebx,%eax
  80116b:	03 45 0c             	add    0xc(%ebp),%eax
  80116e:	50                   	push   %eax
  80116f:	57                   	push   %edi
  801170:	e8 45 ff ff ff       	call   8010ba <read>
		if (m < 0)
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 10                	js     80118c <readn+0x41>
			return m;
		if (m == 0)
  80117c:	85 c0                	test   %eax,%eax
  80117e:	74 0a                	je     80118a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801180:	01 c3                	add    %eax,%ebx
  801182:	39 f3                	cmp    %esi,%ebx
  801184:	72 db                	jb     801161 <readn+0x16>
  801186:	89 d8                	mov    %ebx,%eax
  801188:	eb 02                	jmp    80118c <readn+0x41>
  80118a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80118c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	53                   	push   %ebx
  801198:	83 ec 14             	sub    $0x14,%esp
  80119b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a1:	50                   	push   %eax
  8011a2:	53                   	push   %ebx
  8011a3:	e8 ac fc ff ff       	call   800e54 <fd_lookup>
  8011a8:	83 c4 08             	add    $0x8,%esp
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	78 68                	js     801219 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bb:	ff 30                	pushl  (%eax)
  8011bd:	e8 e8 fc ff ff       	call   800eaa <dev_lookup>
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	78 47                	js     801210 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d0:	75 21                	jne    8011f3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d7:	8b 40 48             	mov    0x48(%eax),%eax
  8011da:	83 ec 04             	sub    $0x4,%esp
  8011dd:	53                   	push   %ebx
  8011de:	50                   	push   %eax
  8011df:	68 69 28 80 00       	push   $0x802869
  8011e4:	e8 7c f0 ff ff       	call   800265 <cprintf>
		return -E_INVAL;
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f1:	eb 26                	jmp    801219 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f9:	85 d2                	test   %edx,%edx
  8011fb:	74 17                	je     801214 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	ff 75 10             	pushl  0x10(%ebp)
  801203:	ff 75 0c             	pushl  0xc(%ebp)
  801206:	50                   	push   %eax
  801207:	ff d2                	call   *%edx
  801209:	89 c2                	mov    %eax,%edx
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	eb 09                	jmp    801219 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801210:	89 c2                	mov    %eax,%edx
  801212:	eb 05                	jmp    801219 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801214:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801219:	89 d0                	mov    %edx,%eax
  80121b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <seek>:

int
seek(int fdnum, off_t offset)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801226:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801229:	50                   	push   %eax
  80122a:	ff 75 08             	pushl  0x8(%ebp)
  80122d:	e8 22 fc ff ff       	call   800e54 <fd_lookup>
  801232:	83 c4 08             	add    $0x8,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	78 0e                	js     801247 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801239:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80123c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801242:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801247:	c9                   	leave  
  801248:	c3                   	ret    

00801249 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	53                   	push   %ebx
  80124d:	83 ec 14             	sub    $0x14,%esp
  801250:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801253:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801256:	50                   	push   %eax
  801257:	53                   	push   %ebx
  801258:	e8 f7 fb ff ff       	call   800e54 <fd_lookup>
  80125d:	83 c4 08             	add    $0x8,%esp
  801260:	89 c2                	mov    %eax,%edx
  801262:	85 c0                	test   %eax,%eax
  801264:	78 65                	js     8012cb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801266:	83 ec 08             	sub    $0x8,%esp
  801269:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	ff 30                	pushl  (%eax)
  801272:	e8 33 fc ff ff       	call   800eaa <dev_lookup>
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	85 c0                	test   %eax,%eax
  80127c:	78 44                	js     8012c2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801285:	75 21                	jne    8012a8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801287:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80128c:	8b 40 48             	mov    0x48(%eax),%eax
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	53                   	push   %ebx
  801293:	50                   	push   %eax
  801294:	68 2c 28 80 00       	push   $0x80282c
  801299:	e8 c7 ef ff ff       	call   800265 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a6:	eb 23                	jmp    8012cb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ab:	8b 52 18             	mov    0x18(%edx),%edx
  8012ae:	85 d2                	test   %edx,%edx
  8012b0:	74 14                	je     8012c6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	ff 75 0c             	pushl  0xc(%ebp)
  8012b8:	50                   	push   %eax
  8012b9:	ff d2                	call   *%edx
  8012bb:	89 c2                	mov    %eax,%edx
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	eb 09                	jmp    8012cb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	eb 05                	jmp    8012cb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012cb:	89 d0                	mov    %edx,%eax
  8012cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d0:	c9                   	leave  
  8012d1:	c3                   	ret    

008012d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 14             	sub    $0x14,%esp
  8012d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 75 08             	pushl  0x8(%ebp)
  8012e3:	e8 6c fb ff ff       	call   800e54 <fd_lookup>
  8012e8:	83 c4 08             	add    $0x8,%esp
  8012eb:	89 c2                	mov    %eax,%edx
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 58                	js     801349 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fb:	ff 30                	pushl  (%eax)
  8012fd:	e8 a8 fb ff ff       	call   800eaa <dev_lookup>
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	78 37                	js     801340 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801309:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801310:	74 32                	je     801344 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801312:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801315:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131c:	00 00 00 
	stat->st_isdir = 0;
  80131f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801326:	00 00 00 
	stat->st_dev = dev;
  801329:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	53                   	push   %ebx
  801333:	ff 75 f0             	pushl  -0x10(%ebp)
  801336:	ff 50 14             	call   *0x14(%eax)
  801339:	89 c2                	mov    %eax,%edx
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	eb 09                	jmp    801349 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801340:	89 c2                	mov    %eax,%edx
  801342:	eb 05                	jmp    801349 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801344:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801349:	89 d0                	mov    %edx,%eax
  80134b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134e:	c9                   	leave  
  80134f:	c3                   	ret    

00801350 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	56                   	push   %esi
  801354:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	6a 00                	push   $0x0
  80135a:	ff 75 08             	pushl  0x8(%ebp)
  80135d:	e8 b7 01 00 00       	call   801519 <open>
  801362:	89 c3                	mov    %eax,%ebx
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	78 1b                	js     801386 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	ff 75 0c             	pushl  0xc(%ebp)
  801371:	50                   	push   %eax
  801372:	e8 5b ff ff ff       	call   8012d2 <fstat>
  801377:	89 c6                	mov    %eax,%esi
	close(fd);
  801379:	89 1c 24             	mov    %ebx,(%esp)
  80137c:	e8 fd fb ff ff       	call   800f7e <close>
	return r;
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	89 f0                	mov    %esi,%eax
}
  801386:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801389:	5b                   	pop    %ebx
  80138a:	5e                   	pop    %esi
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	56                   	push   %esi
  801391:	53                   	push   %ebx
  801392:	89 c6                	mov    %eax,%esi
  801394:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801396:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139d:	75 12                	jne    8013b1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	6a 01                	push   $0x1
  8013a4:	e8 2a 0d 00 00       	call   8020d3 <ipc_find_env>
  8013a9:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ae:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b1:	6a 07                	push   $0x7
  8013b3:	68 00 50 80 00       	push   $0x805000
  8013b8:	56                   	push   %esi
  8013b9:	ff 35 00 40 80 00    	pushl  0x804000
  8013bf:	e8 83 0c 00 00       	call   802047 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013c4:	83 c4 0c             	add    $0xc,%esp
  8013c7:	6a 00                	push   $0x0
  8013c9:	53                   	push   %ebx
  8013ca:	6a 00                	push   $0x0
  8013cc:	e8 01 0c 00 00       	call   801fd2 <ipc_recv>
}
  8013d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ec:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8013fb:	e8 8d ff ff ff       	call   80138d <fsipc>
}
  801400:	c9                   	leave  
  801401:	c3                   	ret    

00801402 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801408:	8b 45 08             	mov    0x8(%ebp),%eax
  80140b:	8b 40 0c             	mov    0xc(%eax),%eax
  80140e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801413:	ba 00 00 00 00       	mov    $0x0,%edx
  801418:	b8 06 00 00 00       	mov    $0x6,%eax
  80141d:	e8 6b ff ff ff       	call   80138d <fsipc>
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	53                   	push   %ebx
  801428:	83 ec 04             	sub    $0x4,%esp
  80142b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80142e:	8b 45 08             	mov    0x8(%ebp),%eax
  801431:	8b 40 0c             	mov    0xc(%eax),%eax
  801434:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801439:	ba 00 00 00 00       	mov    $0x0,%edx
  80143e:	b8 05 00 00 00       	mov    $0x5,%eax
  801443:	e8 45 ff ff ff       	call   80138d <fsipc>
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 2c                	js     801478 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	68 00 50 80 00       	push   $0x805000
  801454:	53                   	push   %ebx
  801455:	e8 90 f3 ff ff       	call   8007ea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80145a:	a1 80 50 80 00       	mov    0x805080,%eax
  80145f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801465:	a1 84 50 80 00       	mov    0x805084,%eax
  80146a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801478:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801483:	68 98 28 80 00       	push   $0x802898
  801488:	68 90 00 00 00       	push   $0x90
  80148d:	68 b6 28 80 00       	push   $0x8028b6
  801492:	e8 f5 ec ff ff       	call   80018c <_panic>

00801497 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	56                   	push   %esi
  80149b:	53                   	push   %ebx
  80149c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80149f:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014aa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b5:	b8 03 00 00 00       	mov    $0x3,%eax
  8014ba:	e8 ce fe ff ff       	call   80138d <fsipc>
  8014bf:	89 c3                	mov    %eax,%ebx
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 4b                	js     801510 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014c5:	39 c6                	cmp    %eax,%esi
  8014c7:	73 16                	jae    8014df <devfile_read+0x48>
  8014c9:	68 c1 28 80 00       	push   $0x8028c1
  8014ce:	68 c8 28 80 00       	push   $0x8028c8
  8014d3:	6a 7c                	push   $0x7c
  8014d5:	68 b6 28 80 00       	push   $0x8028b6
  8014da:	e8 ad ec ff ff       	call   80018c <_panic>
	assert(r <= PGSIZE);
  8014df:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014e4:	7e 16                	jle    8014fc <devfile_read+0x65>
  8014e6:	68 dd 28 80 00       	push   $0x8028dd
  8014eb:	68 c8 28 80 00       	push   $0x8028c8
  8014f0:	6a 7d                	push   $0x7d
  8014f2:	68 b6 28 80 00       	push   $0x8028b6
  8014f7:	e8 90 ec ff ff       	call   80018c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014fc:	83 ec 04             	sub    $0x4,%esp
  8014ff:	50                   	push   %eax
  801500:	68 00 50 80 00       	push   $0x805000
  801505:	ff 75 0c             	pushl  0xc(%ebp)
  801508:	e8 6f f4 ff ff       	call   80097c <memmove>
	return r;
  80150d:	83 c4 10             	add    $0x10,%esp
}
  801510:	89 d8                	mov    %ebx,%eax
  801512:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801515:	5b                   	pop    %ebx
  801516:	5e                   	pop    %esi
  801517:	5d                   	pop    %ebp
  801518:	c3                   	ret    

00801519 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	53                   	push   %ebx
  80151d:	83 ec 20             	sub    $0x20,%esp
  801520:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801523:	53                   	push   %ebx
  801524:	e8 88 f2 ff ff       	call   8007b1 <strlen>
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801531:	7f 67                	jg     80159a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801533:	83 ec 0c             	sub    $0xc,%esp
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	e8 c6 f8 ff ff       	call   800e05 <fd_alloc>
  80153f:	83 c4 10             	add    $0x10,%esp
		return r;
  801542:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801544:	85 c0                	test   %eax,%eax
  801546:	78 57                	js     80159f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	53                   	push   %ebx
  80154c:	68 00 50 80 00       	push   $0x805000
  801551:	e8 94 f2 ff ff       	call   8007ea <strcpy>
	fsipcbuf.open.req_omode = mode;
  801556:	8b 45 0c             	mov    0xc(%ebp),%eax
  801559:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801561:	b8 01 00 00 00       	mov    $0x1,%eax
  801566:	e8 22 fe ff ff       	call   80138d <fsipc>
  80156b:	89 c3                	mov    %eax,%ebx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	79 14                	jns    801588 <open+0x6f>
		fd_close(fd, 0);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	6a 00                	push   $0x0
  801579:	ff 75 f4             	pushl  -0xc(%ebp)
  80157c:	e8 7c f9 ff ff       	call   800efd <fd_close>
		return r;
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	89 da                	mov    %ebx,%edx
  801586:	eb 17                	jmp    80159f <open+0x86>
	}

	return fd2num(fd);
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	ff 75 f4             	pushl  -0xc(%ebp)
  80158e:	e8 4b f8 ff ff       	call   800dde <fd2num>
  801593:	89 c2                	mov    %eax,%edx
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	eb 05                	jmp    80159f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80159a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80159f:	89 d0                	mov    %edx,%eax
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8015b6:	e8 d2 fd ff ff       	call   80138d <fsipc>
}
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	57                   	push   %edi
  8015c1:	56                   	push   %esi
  8015c2:	53                   	push   %ebx
  8015c3:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015c9:	6a 00                	push   $0x0
  8015cb:	ff 75 08             	pushl  0x8(%ebp)
  8015ce:	e8 46 ff ff ff       	call   801519 <open>
  8015d3:	89 c7                	mov    %eax,%edi
  8015d5:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	0f 88 30 04 00 00    	js     801a16 <spawn+0x459>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015e6:	83 ec 04             	sub    $0x4,%esp
  8015e9:	68 00 02 00 00       	push   $0x200
  8015ee:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	57                   	push   %edi
  8015f6:	e8 50 fb ff ff       	call   80114b <readn>
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	3d 00 02 00 00       	cmp    $0x200,%eax
  801603:	75 0c                	jne    801611 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801605:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80160c:	45 4c 46 
  80160f:	74 33                	je     801644 <spawn+0x87>
		close(fd);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80161a:	e8 5f f9 ff ff       	call   800f7e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80161f:	83 c4 0c             	add    $0xc,%esp
  801622:	68 7f 45 4c 46       	push   $0x464c457f
  801627:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80162d:	68 e9 28 80 00       	push   $0x8028e9
  801632:	e8 2e ec ff ff       	call   800265 <cprintf>
		return -E_NOT_EXEC;
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80163f:	e9 32 04 00 00       	jmp    801a76 <spawn+0x4b9>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801644:	b8 07 00 00 00       	mov    $0x7,%eax
  801649:	cd 30                	int    $0x30
  80164b:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801651:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801657:	85 c0                	test   %eax,%eax
  801659:	0f 88 bf 03 00 00    	js     801a1e <spawn+0x461>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80165f:	89 c6                	mov    %eax,%esi
  801661:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801667:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80166a:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801670:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801676:	b9 11 00 00 00       	mov    $0x11,%ecx
  80167b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80167d:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801683:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801689:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80168e:	be 00 00 00 00       	mov    $0x0,%esi
  801693:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801696:	eb 13                	jmp    8016ab <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801698:	83 ec 0c             	sub    $0xc,%esp
  80169b:	50                   	push   %eax
  80169c:	e8 10 f1 ff ff       	call   8007b1 <strlen>
  8016a1:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016a5:	83 c3 01             	add    $0x1,%ebx
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016b2:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	75 df                	jne    801698 <spawn+0xdb>
  8016b9:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016bf:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016c5:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016ca:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016cc:	89 fa                	mov    %edi,%edx
  8016ce:	83 e2 fc             	and    $0xfffffffc,%edx
  8016d1:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016d8:	29 c2                	sub    %eax,%edx
  8016da:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016e0:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016e3:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016e8:	0f 86 40 03 00 00    	jbe    801a2e <spawn+0x471>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016ee:	83 ec 04             	sub    $0x4,%esp
  8016f1:	6a 07                	push   $0x7
  8016f3:	68 00 00 40 00       	push   $0x400000
  8016f8:	6a 00                	push   $0x0
  8016fa:	e8 ee f4 ff ff       	call   800bed <sys_page_alloc>
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	85 c0                	test   %eax,%eax
  801704:	0f 88 2b 03 00 00    	js     801a35 <spawn+0x478>
  80170a:	be 00 00 00 00       	mov    $0x0,%esi
  80170f:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801718:	eb 30                	jmp    80174a <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80171a:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801720:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801726:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80172f:	57                   	push   %edi
  801730:	e8 b5 f0 ff ff       	call   8007ea <strcpy>
		string_store += strlen(argv[i]) + 1;
  801735:	83 c4 04             	add    $0x4,%esp
  801738:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80173b:	e8 71 f0 ff ff       	call   8007b1 <strlen>
  801740:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801744:	83 c6 01             	add    $0x1,%esi
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801750:	7f c8                	jg     80171a <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801752:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801758:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80175e:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801765:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80176b:	74 19                	je     801786 <spawn+0x1c9>
  80176d:	68 60 29 80 00       	push   $0x802960
  801772:	68 c8 28 80 00       	push   $0x8028c8
  801777:	68 f1 00 00 00       	push   $0xf1
  80177c:	68 03 29 80 00       	push   $0x802903
  801781:	e8 06 ea ff ff       	call   80018c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801786:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80178c:	89 c8                	mov    %ecx,%eax
  80178e:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801793:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801796:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80179c:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80179f:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  8017a5:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017ab:	83 ec 0c             	sub    $0xc,%esp
  8017ae:	6a 07                	push   $0x7
  8017b0:	68 00 d0 bf ee       	push   $0xeebfd000
  8017b5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017bb:	68 00 00 40 00       	push   $0x400000
  8017c0:	6a 00                	push   $0x0
  8017c2:	e8 69 f4 ff ff       	call   800c30 <sys_page_map>
  8017c7:	89 c3                	mov    %eax,%ebx
  8017c9:	83 c4 20             	add    $0x20,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	0f 88 90 02 00 00    	js     801a64 <spawn+0x4a7>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	68 00 00 40 00       	push   $0x400000
  8017dc:	6a 00                	push   $0x0
  8017de:	e8 8f f4 ff ff       	call   800c72 <sys_page_unmap>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	0f 88 74 02 00 00    	js     801a64 <spawn+0x4a7>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017f0:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017f6:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017fd:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801803:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80180a:	00 00 00 
  80180d:	e9 86 01 00 00       	jmp    801998 <spawn+0x3db>
		if (ph->p_type != ELF_PROG_LOAD)
  801812:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801818:	83 38 01             	cmpl   $0x1,(%eax)
  80181b:	0f 85 69 01 00 00    	jne    80198a <spawn+0x3cd>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801821:	89 c1                	mov    %eax,%ecx
  801823:	8b 40 18             	mov    0x18(%eax),%eax
  801826:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80182c:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80182f:	83 f8 01             	cmp    $0x1,%eax
  801832:	19 c0                	sbb    %eax,%eax
  801834:	83 e0 fe             	and    $0xfffffffe,%eax
  801837:	83 c0 07             	add    $0x7,%eax
  80183a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801840:	89 c8                	mov    %ecx,%eax
  801842:	8b 49 04             	mov    0x4(%ecx),%ecx
  801845:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  80184b:	8b 78 10             	mov    0x10(%eax),%edi
  80184e:	8b 50 14             	mov    0x14(%eax),%edx
  801851:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801857:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80185a:	89 f0                	mov    %esi,%eax
  80185c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801861:	74 14                	je     801877 <spawn+0x2ba>
		va -= i;
  801863:	29 c6                	sub    %eax,%esi
		memsz += i;
  801865:	01 c2                	add    %eax,%edx
  801867:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80186d:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80186f:	29 c1                	sub    %eax,%ecx
  801871:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801877:	bb 00 00 00 00       	mov    $0x0,%ebx
  80187c:	e9 f7 00 00 00       	jmp    801978 <spawn+0x3bb>
		if (i >= filesz) {
  801881:	39 df                	cmp    %ebx,%edi
  801883:	77 27                	ja     8018ac <spawn+0x2ef>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801885:	83 ec 04             	sub    $0x4,%esp
  801888:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80188e:	56                   	push   %esi
  80188f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801895:	e8 53 f3 ff ff       	call   800bed <sys_page_alloc>
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	85 c0                	test   %eax,%eax
  80189f:	0f 89 c7 00 00 00    	jns    80196c <spawn+0x3af>
  8018a5:	89 c3                	mov    %eax,%ebx
  8018a7:	e9 97 01 00 00       	jmp    801a43 <spawn+0x486>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018ac:	83 ec 04             	sub    $0x4,%esp
  8018af:	6a 07                	push   $0x7
  8018b1:	68 00 00 40 00       	push   $0x400000
  8018b6:	6a 00                	push   $0x0
  8018b8:	e8 30 f3 ff ff       	call   800bed <sys_page_alloc>
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	0f 88 71 01 00 00    	js     801a39 <spawn+0x47c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018d1:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8018d7:	50                   	push   %eax
  8018d8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018de:	e8 3d f9 ff ff       	call   801220 <seek>
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	0f 88 4f 01 00 00    	js     801a3d <spawn+0x480>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018ee:	83 ec 04             	sub    $0x4,%esp
  8018f1:	89 f8                	mov    %edi,%eax
  8018f3:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018f9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018fe:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801903:	0f 47 c1             	cmova  %ecx,%eax
  801906:	50                   	push   %eax
  801907:	68 00 00 40 00       	push   $0x400000
  80190c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801912:	e8 34 f8 ff ff       	call   80114b <readn>
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 c0                	test   %eax,%eax
  80191c:	0f 88 1f 01 00 00    	js     801a41 <spawn+0x484>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80192b:	56                   	push   %esi
  80192c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801932:	68 00 00 40 00       	push   $0x400000
  801937:	6a 00                	push   $0x0
  801939:	e8 f2 f2 ff ff       	call   800c30 <sys_page_map>
  80193e:	83 c4 20             	add    $0x20,%esp
  801941:	85 c0                	test   %eax,%eax
  801943:	79 15                	jns    80195a <spawn+0x39d>
				panic("spawn: sys_page_map data: %e", r);
  801945:	50                   	push   %eax
  801946:	68 0f 29 80 00       	push   $0x80290f
  80194b:	68 24 01 00 00       	push   $0x124
  801950:	68 03 29 80 00       	push   $0x802903
  801955:	e8 32 e8 ff ff       	call   80018c <_panic>
			sys_page_unmap(0, UTEMP);
  80195a:	83 ec 08             	sub    $0x8,%esp
  80195d:	68 00 00 40 00       	push   $0x400000
  801962:	6a 00                	push   $0x0
  801964:	e8 09 f3 ff ff       	call   800c72 <sys_page_unmap>
  801969:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80196c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801972:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801978:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80197e:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801984:	0f 87 f7 fe ff ff    	ja     801881 <spawn+0x2c4>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80198a:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801991:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801998:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80199f:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019a5:	0f 8c 67 fe ff ff    	jl     801812 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019ab:	83 ec 0c             	sub    $0xc,%esp
  8019ae:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019b4:	e8 c5 f5 ff ff       	call   800f7e <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8019b9:	83 c4 08             	add    $0x8,%esp
  8019bc:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8019c2:	50                   	push   %eax
  8019c3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019c9:	e8 28 f3 ff ff       	call   800cf6 <sys_env_set_trapframe>
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	79 15                	jns    8019ea <spawn+0x42d>
		panic("sys_env_set_trapframe: %e", r);
  8019d5:	50                   	push   %eax
  8019d6:	68 2c 29 80 00       	push   $0x80292c
  8019db:	68 85 00 00 00       	push   $0x85
  8019e0:	68 03 29 80 00       	push   $0x802903
  8019e5:	e8 a2 e7 ff ff       	call   80018c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8019ea:	83 ec 08             	sub    $0x8,%esp
  8019ed:	6a 02                	push   $0x2
  8019ef:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019f5:	e8 ba f2 ff ff       	call   800cb4 <sys_env_set_status>
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	79 25                	jns    801a26 <spawn+0x469>
		panic("sys_env_set_status: %e", r);
  801a01:	50                   	push   %eax
  801a02:	68 46 29 80 00       	push   $0x802946
  801a07:	68 88 00 00 00       	push   $0x88
  801a0c:	68 03 29 80 00       	push   $0x802903
  801a11:	e8 76 e7 ff ff       	call   80018c <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a16:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a1c:	eb 58                	jmp    801a76 <spawn+0x4b9>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a1e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a24:	eb 50                	jmp    801a76 <spawn+0x4b9>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a26:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a2c:	eb 48                	jmp    801a76 <spawn+0x4b9>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a2e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a33:	eb 41                	jmp    801a76 <spawn+0x4b9>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a35:	89 c3                	mov    %eax,%ebx
  801a37:	eb 3d                	jmp    801a76 <spawn+0x4b9>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a39:	89 c3                	mov    %eax,%ebx
  801a3b:	eb 06                	jmp    801a43 <spawn+0x486>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a3d:	89 c3                	mov    %eax,%ebx
  801a3f:	eb 02                	jmp    801a43 <spawn+0x486>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a41:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a4c:	e8 1d f1 ff ff       	call   800b6e <sys_env_destroy>
	close(fd);
  801a51:	83 c4 04             	add    $0x4,%esp
  801a54:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a5a:	e8 1f f5 ff ff       	call   800f7e <close>
	return r;
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	eb 12                	jmp    801a76 <spawn+0x4b9>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a64:	83 ec 08             	sub    $0x8,%esp
  801a67:	68 00 00 40 00       	push   $0x400000
  801a6c:	6a 00                	push   $0x0
  801a6e:	e8 ff f1 ff ff       	call   800c72 <sys_page_unmap>
  801a73:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801a76:	89 d8                	mov    %ebx,%eax
  801a78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5f                   	pop    %edi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a85:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801a88:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a8d:	eb 03                	jmp    801a92 <spawnl+0x12>
		argc++;
  801a8f:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801a92:	83 c2 04             	add    $0x4,%edx
  801a95:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801a99:	75 f4                	jne    801a8f <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801a9b:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801aa2:	83 e2 f0             	and    $0xfffffff0,%edx
  801aa5:	29 d4                	sub    %edx,%esp
  801aa7:	8d 54 24 03          	lea    0x3(%esp),%edx
  801aab:	c1 ea 02             	shr    $0x2,%edx
  801aae:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801ab5:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aba:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801ac1:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ac8:	00 
  801ac9:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801acb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad0:	eb 0a                	jmp    801adc <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801ad2:	83 c0 01             	add    $0x1,%eax
  801ad5:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801ad9:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801adc:	39 d0                	cmp    %edx,%eax
  801ade:	75 f2                	jne    801ad2 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	56                   	push   %esi
  801ae4:	ff 75 08             	pushl  0x8(%ebp)
  801ae7:	e8 d1 fa ff ff       	call   8015bd <spawn>
}
  801aec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	56                   	push   %esi
  801af7:	53                   	push   %ebx
  801af8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	ff 75 08             	pushl  0x8(%ebp)
  801b01:	e8 e8 f2 ff ff       	call   800dee <fd2data>
  801b06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b08:	83 c4 08             	add    $0x8,%esp
  801b0b:	68 86 29 80 00       	push   $0x802986
  801b10:	53                   	push   %ebx
  801b11:	e8 d4 ec ff ff       	call   8007ea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b16:	8b 46 04             	mov    0x4(%esi),%eax
  801b19:	2b 06                	sub    (%esi),%eax
  801b1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b28:	00 00 00 
	stat->st_dev = &devpipe;
  801b2b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b32:	30 80 00 
	return 0;
}
  801b35:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	53                   	push   %ebx
  801b45:	83 ec 0c             	sub    $0xc,%esp
  801b48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b4b:	53                   	push   %ebx
  801b4c:	6a 00                	push   $0x0
  801b4e:	e8 1f f1 ff ff       	call   800c72 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b53:	89 1c 24             	mov    %ebx,(%esp)
  801b56:	e8 93 f2 ff ff       	call   800dee <fd2data>
  801b5b:	83 c4 08             	add    $0x8,%esp
  801b5e:	50                   	push   %eax
  801b5f:	6a 00                	push   $0x0
  801b61:	e8 0c f1 ff ff       	call   800c72 <sys_page_unmap>
}
  801b66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	57                   	push   %edi
  801b6f:	56                   	push   %esi
  801b70:	53                   	push   %ebx
  801b71:	83 ec 1c             	sub    $0x1c,%esp
  801b74:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b77:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b79:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b81:	83 ec 0c             	sub    $0xc,%esp
  801b84:	ff 75 e0             	pushl  -0x20(%ebp)
  801b87:	e8 80 05 00 00       	call   80210c <pageref>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	89 3c 24             	mov    %edi,(%esp)
  801b91:	e8 76 05 00 00       	call   80210c <pageref>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	39 c3                	cmp    %eax,%ebx
  801b9b:	0f 94 c1             	sete   %cl
  801b9e:	0f b6 c9             	movzbl %cl,%ecx
  801ba1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ba4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801baa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bad:	39 ce                	cmp    %ecx,%esi
  801baf:	74 1b                	je     801bcc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bb1:	39 c3                	cmp    %eax,%ebx
  801bb3:	75 c4                	jne    801b79 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bb5:	8b 42 58             	mov    0x58(%edx),%eax
  801bb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bbb:	50                   	push   %eax
  801bbc:	56                   	push   %esi
  801bbd:	68 8d 29 80 00       	push   $0x80298d
  801bc2:	e8 9e e6 ff ff       	call   800265 <cprintf>
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	eb ad                	jmp    801b79 <_pipeisclosed+0xe>
	}
}
  801bcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd2:	5b                   	pop    %ebx
  801bd3:	5e                   	pop    %esi
  801bd4:	5f                   	pop    %edi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	57                   	push   %edi
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 28             	sub    $0x28,%esp
  801be0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801be3:	56                   	push   %esi
  801be4:	e8 05 f2 ff ff       	call   800dee <fd2data>
  801be9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	bf 00 00 00 00       	mov    $0x0,%edi
  801bf3:	eb 4b                	jmp    801c40 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801bf5:	89 da                	mov    %ebx,%edx
  801bf7:	89 f0                	mov    %esi,%eax
  801bf9:	e8 6d ff ff ff       	call   801b6b <_pipeisclosed>
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	75 48                	jne    801c4a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c02:	e8 c7 ef ff ff       	call   800bce <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c07:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0a:	8b 0b                	mov    (%ebx),%ecx
  801c0c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c0f:	39 d0                	cmp    %edx,%eax
  801c11:	73 e2                	jae    801bf5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c16:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c1a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c1d:	89 c2                	mov    %eax,%edx
  801c1f:	c1 fa 1f             	sar    $0x1f,%edx
  801c22:	89 d1                	mov    %edx,%ecx
  801c24:	c1 e9 1b             	shr    $0x1b,%ecx
  801c27:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c2a:	83 e2 1f             	and    $0x1f,%edx
  801c2d:	29 ca                	sub    %ecx,%edx
  801c2f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c33:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c37:	83 c0 01             	add    $0x1,%eax
  801c3a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c3d:	83 c7 01             	add    $0x1,%edi
  801c40:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c43:	75 c2                	jne    801c07 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c45:	8b 45 10             	mov    0x10(%ebp),%eax
  801c48:	eb 05                	jmp    801c4f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c4a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5f                   	pop    %edi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	57                   	push   %edi
  801c5b:	56                   	push   %esi
  801c5c:	53                   	push   %ebx
  801c5d:	83 ec 18             	sub    $0x18,%esp
  801c60:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c63:	57                   	push   %edi
  801c64:	e8 85 f1 ff ff       	call   800dee <fd2data>
  801c69:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c73:	eb 3d                	jmp    801cb2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c75:	85 db                	test   %ebx,%ebx
  801c77:	74 04                	je     801c7d <devpipe_read+0x26>
				return i;
  801c79:	89 d8                	mov    %ebx,%eax
  801c7b:	eb 44                	jmp    801cc1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c7d:	89 f2                	mov    %esi,%edx
  801c7f:	89 f8                	mov    %edi,%eax
  801c81:	e8 e5 fe ff ff       	call   801b6b <_pipeisclosed>
  801c86:	85 c0                	test   %eax,%eax
  801c88:	75 32                	jne    801cbc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c8a:	e8 3f ef ff ff       	call   800bce <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c8f:	8b 06                	mov    (%esi),%eax
  801c91:	3b 46 04             	cmp    0x4(%esi),%eax
  801c94:	74 df                	je     801c75 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c96:	99                   	cltd   
  801c97:	c1 ea 1b             	shr    $0x1b,%edx
  801c9a:	01 d0                	add    %edx,%eax
  801c9c:	83 e0 1f             	and    $0x1f,%eax
  801c9f:	29 d0                	sub    %edx,%eax
  801ca1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cac:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801caf:	83 c3 01             	add    $0x1,%ebx
  801cb2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cb5:	75 d8                	jne    801c8f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cb7:	8b 45 10             	mov    0x10(%ebp),%eax
  801cba:	eb 05                	jmp    801cc1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc4:	5b                   	pop    %ebx
  801cc5:	5e                   	pop    %esi
  801cc6:	5f                   	pop    %edi
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	56                   	push   %esi
  801ccd:	53                   	push   %ebx
  801cce:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801cd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd4:	50                   	push   %eax
  801cd5:	e8 2b f1 ff ff       	call   800e05 <fd_alloc>
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	89 c2                	mov    %eax,%edx
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	0f 88 2c 01 00 00    	js     801e13 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce7:	83 ec 04             	sub    $0x4,%esp
  801cea:	68 07 04 00 00       	push   $0x407
  801cef:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf2:	6a 00                	push   $0x0
  801cf4:	e8 f4 ee ff ff       	call   800bed <sys_page_alloc>
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	89 c2                	mov    %eax,%edx
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	0f 88 0d 01 00 00    	js     801e13 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d06:	83 ec 0c             	sub    $0xc,%esp
  801d09:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d0c:	50                   	push   %eax
  801d0d:	e8 f3 f0 ff ff       	call   800e05 <fd_alloc>
  801d12:	89 c3                	mov    %eax,%ebx
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	85 c0                	test   %eax,%eax
  801d19:	0f 88 e2 00 00 00    	js     801e01 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	68 07 04 00 00       	push   $0x407
  801d27:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 bc ee ff ff       	call   800bed <sys_page_alloc>
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	0f 88 c3 00 00 00    	js     801e01 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	ff 75 f4             	pushl  -0xc(%ebp)
  801d44:	e8 a5 f0 ff ff       	call   800dee <fd2data>
  801d49:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4b:	83 c4 0c             	add    $0xc,%esp
  801d4e:	68 07 04 00 00       	push   $0x407
  801d53:	50                   	push   %eax
  801d54:	6a 00                	push   $0x0
  801d56:	e8 92 ee ff ff       	call   800bed <sys_page_alloc>
  801d5b:	89 c3                	mov    %eax,%ebx
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	85 c0                	test   %eax,%eax
  801d62:	0f 88 89 00 00 00    	js     801df1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6e:	e8 7b f0 ff ff       	call   800dee <fd2data>
  801d73:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d7a:	50                   	push   %eax
  801d7b:	6a 00                	push   $0x0
  801d7d:	56                   	push   %esi
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 ab ee ff ff       	call   800c30 <sys_page_map>
  801d85:	89 c3                	mov    %eax,%ebx
  801d87:	83 c4 20             	add    $0x20,%esp
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	78 55                	js     801de3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d8e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d97:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801da3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dac:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbe:	e8 1b f0 ff ff       	call   800dde <fd2num>
  801dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc8:	83 c4 04             	add    $0x4,%esp
  801dcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dce:	e8 0b f0 ff ff       	call   800dde <fd2num>
  801dd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	ba 00 00 00 00       	mov    $0x0,%edx
  801de1:	eb 30                	jmp    801e13 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801de3:	83 ec 08             	sub    $0x8,%esp
  801de6:	56                   	push   %esi
  801de7:	6a 00                	push   $0x0
  801de9:	e8 84 ee ff ff       	call   800c72 <sys_page_unmap>
  801dee:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801df1:	83 ec 08             	sub    $0x8,%esp
  801df4:	ff 75 f0             	pushl  -0x10(%ebp)
  801df7:	6a 00                	push   $0x0
  801df9:	e8 74 ee ff ff       	call   800c72 <sys_page_unmap>
  801dfe:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e01:	83 ec 08             	sub    $0x8,%esp
  801e04:	ff 75 f4             	pushl  -0xc(%ebp)
  801e07:	6a 00                	push   $0x0
  801e09:	e8 64 ee ff ff       	call   800c72 <sys_page_unmap>
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e13:	89 d0                	mov    %edx,%eax
  801e15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    

00801e1c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e25:	50                   	push   %eax
  801e26:	ff 75 08             	pushl  0x8(%ebp)
  801e29:	e8 26 f0 ff ff       	call   800e54 <fd_lookup>
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 18                	js     801e4d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e35:	83 ec 0c             	sub    $0xc,%esp
  801e38:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3b:	e8 ae ef ff ff       	call   800dee <fd2data>
	return _pipeisclosed(fd, p);
  801e40:	89 c2                	mov    %eax,%edx
  801e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e45:	e8 21 fd ff ff       	call   801b6b <_pipeisclosed>
  801e4a:	83 c4 10             	add    $0x10,%esp
}
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e52:	b8 00 00 00 00       	mov    $0x0,%eax
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    

00801e59 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e5f:	68 a5 29 80 00       	push   $0x8029a5
  801e64:	ff 75 0c             	pushl  0xc(%ebp)
  801e67:	e8 7e e9 ff ff       	call   8007ea <strcpy>
	return 0;
}
  801e6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	57                   	push   %edi
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e7f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e84:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e8a:	eb 2d                	jmp    801eb9 <devcons_write+0x46>
		m = n - tot;
  801e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e8f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e91:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e94:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e99:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e9c:	83 ec 04             	sub    $0x4,%esp
  801e9f:	53                   	push   %ebx
  801ea0:	03 45 0c             	add    0xc(%ebp),%eax
  801ea3:	50                   	push   %eax
  801ea4:	57                   	push   %edi
  801ea5:	e8 d2 ea ff ff       	call   80097c <memmove>
		sys_cputs(buf, m);
  801eaa:	83 c4 08             	add    $0x8,%esp
  801ead:	53                   	push   %ebx
  801eae:	57                   	push   %edi
  801eaf:	e8 7d ec ff ff       	call   800b31 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb4:	01 de                	add    %ebx,%esi
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	89 f0                	mov    %esi,%eax
  801ebb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ebe:	72 cc                	jb     801e8c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec3:	5b                   	pop    %ebx
  801ec4:	5e                   	pop    %esi
  801ec5:	5f                   	pop    %edi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	83 ec 08             	sub    $0x8,%esp
  801ece:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ed3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed7:	74 2a                	je     801f03 <devcons_read+0x3b>
  801ed9:	eb 05                	jmp    801ee0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801edb:	e8 ee ec ff ff       	call   800bce <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ee0:	e8 6a ec ff ff       	call   800b4f <sys_cgetc>
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	74 f2                	je     801edb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	78 16                	js     801f03 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eed:	83 f8 04             	cmp    $0x4,%eax
  801ef0:	74 0c                	je     801efe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ef2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef5:	88 02                	mov    %al,(%edx)
	return 1;
  801ef7:	b8 01 00 00 00       	mov    $0x1,%eax
  801efc:	eb 05                	jmp    801f03 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f11:	6a 01                	push   $0x1
  801f13:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f16:	50                   	push   %eax
  801f17:	e8 15 ec ff ff       	call   800b31 <sys_cputs>
}
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    

00801f21 <getchar>:

int
getchar(void)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f27:	6a 01                	push   $0x1
  801f29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f2c:	50                   	push   %eax
  801f2d:	6a 00                	push   $0x0
  801f2f:	e8 86 f1 ff ff       	call   8010ba <read>
	if (r < 0)
  801f34:	83 c4 10             	add    $0x10,%esp
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 0f                	js     801f4a <getchar+0x29>
		return r;
	if (r < 1)
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	7e 06                	jle    801f45 <getchar+0x24>
		return -E_EOF;
	return c;
  801f3f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f43:	eb 05                	jmp    801f4a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f45:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f55:	50                   	push   %eax
  801f56:	ff 75 08             	pushl  0x8(%ebp)
  801f59:	e8 f6 ee ff ff       	call   800e54 <fd_lookup>
  801f5e:	83 c4 10             	add    $0x10,%esp
  801f61:	85 c0                	test   %eax,%eax
  801f63:	78 11                	js     801f76 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f68:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f6e:	39 10                	cmp    %edx,(%eax)
  801f70:	0f 94 c0             	sete   %al
  801f73:	0f b6 c0             	movzbl %al,%eax
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <opencons>:

int
opencons(void)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f81:	50                   	push   %eax
  801f82:	e8 7e ee ff ff       	call   800e05 <fd_alloc>
  801f87:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 3e                	js     801fce <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f90:	83 ec 04             	sub    $0x4,%esp
  801f93:	68 07 04 00 00       	push   $0x407
  801f98:	ff 75 f4             	pushl  -0xc(%ebp)
  801f9b:	6a 00                	push   $0x0
  801f9d:	e8 4b ec ff ff       	call   800bed <sys_page_alloc>
  801fa2:	83 c4 10             	add    $0x10,%esp
		return r;
  801fa5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	78 23                	js     801fce <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	50                   	push   %eax
  801fc4:	e8 15 ee ff ff       	call   800dde <fd2num>
  801fc9:	89 c2                	mov    %eax,%edx
  801fcb:	83 c4 10             	add    $0x10,%esp
}
  801fce:	89 d0                	mov    %edx,%eax
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	56                   	push   %esi
  801fd6:	53                   	push   %ebx
  801fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fdd:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	74 0e                	je     801ff2 <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  801fe4:	83 ec 0c             	sub    $0xc,%esp
  801fe7:	50                   	push   %eax
  801fe8:	e8 b0 ed ff ff       	call   800d9d <sys_ipc_recv>
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	eb 10                	jmp    802002 <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  801ff2:	83 ec 0c             	sub    $0xc,%esp
  801ff5:	68 00 00 00 f0       	push   $0xf0000000
  801ffa:	e8 9e ed ff ff       	call   800d9d <sys_ipc_recv>
  801fff:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  802002:	85 c0                	test   %eax,%eax
  802004:	74 16                	je     80201c <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  802006:	85 db                	test   %ebx,%ebx
  802008:	74 36                	je     802040 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  80200a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  802010:	85 f6                	test   %esi,%esi
  802012:	74 2c                	je     802040 <ipc_recv+0x6e>
				*perm_store = 0;
  802014:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80201a:	eb 24                	jmp    802040 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  80201c:	85 db                	test   %ebx,%ebx
  80201e:	74 18                	je     802038 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  802020:	a1 04 40 80 00       	mov    0x804004,%eax
  802025:	8b 40 74             	mov    0x74(%eax),%eax
  802028:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  80202a:	85 f6                	test   %esi,%esi
  80202c:	74 0a                	je     802038 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  80202e:	a1 04 40 80 00       	mov    0x804004,%eax
  802033:	8b 40 78             	mov    0x78(%eax),%eax
  802036:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  802038:	a1 04 40 80 00       	mov    0x804004,%eax
  80203d:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  802040:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    

00802047 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	57                   	push   %edi
  80204b:	56                   	push   %esi
  80204c:	53                   	push   %ebx
  80204d:	83 ec 0c             	sub    $0xc,%esp
  802050:	8b 7d 08             	mov    0x8(%ebp),%edi
  802053:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  802056:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80205a:	75 39                	jne    802095 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  80205c:	6a 00                	push   $0x0
  80205e:	68 00 00 00 f0       	push   $0xf0000000
  802063:	56                   	push   %esi
  802064:	57                   	push   %edi
  802065:	e8 10 ed ff ff       	call   800d7a <sys_ipc_try_send>
  80206a:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802072:	74 16                	je     80208a <ipc_send+0x43>
  802074:	85 c0                	test   %eax,%eax
  802076:	74 12                	je     80208a <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802078:	50                   	push   %eax
  802079:	68 b4 29 80 00       	push   $0x8029b4
  80207e:	6a 4f                	push   $0x4f
  802080:	68 ec 29 80 00       	push   $0x8029ec
  802085:	e8 02 e1 ff ff       	call   80018c <_panic>
			sys_yield();
  80208a:	e8 3f eb ff ff       	call   800bce <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  80208f:	85 db                	test   %ebx,%ebx
  802091:	75 c9                	jne    80205c <ipc_send+0x15>
  802093:	eb 36                	jmp    8020cb <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  802095:	ff 75 14             	pushl  0x14(%ebp)
  802098:	ff 75 10             	pushl  0x10(%ebp)
  80209b:	56                   	push   %esi
  80209c:	57                   	push   %edi
  80209d:	e8 d8 ec ff ff       	call   800d7a <sys_ipc_try_send>
  8020a2:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  8020a4:	83 c4 10             	add    $0x10,%esp
  8020a7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020aa:	74 16                	je     8020c2 <ipc_send+0x7b>
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	74 12                	je     8020c2 <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  8020b0:	50                   	push   %eax
  8020b1:	68 b4 29 80 00       	push   $0x8029b4
  8020b6:	6a 5a                	push   $0x5a
  8020b8:	68 ec 29 80 00       	push   $0x8029ec
  8020bd:	e8 ca e0 ff ff       	call   80018c <_panic>
			sys_yield();
  8020c2:	e8 07 eb ff ff       	call   800bce <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  8020c7:	85 db                	test   %ebx,%ebx
  8020c9:	75 ca                	jne    802095 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  8020cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ce:	5b                   	pop    %ebx
  8020cf:	5e                   	pop    %esi
  8020d0:	5f                   	pop    %edi
  8020d1:	5d                   	pop    %ebp
  8020d2:	c3                   	ret    

008020d3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020d3:	55                   	push   %ebp
  8020d4:	89 e5                	mov    %esp,%ebp
  8020d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020d9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020de:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020e1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020e7:	8b 52 50             	mov    0x50(%edx),%edx
  8020ea:	39 ca                	cmp    %ecx,%edx
  8020ec:	75 0d                	jne    8020fb <ipc_find_env+0x28>
			return envs[i].env_id;
  8020ee:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020f1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020f6:	8b 40 48             	mov    0x48(%eax),%eax
  8020f9:	eb 0f                	jmp    80210a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020fb:	83 c0 01             	add    $0x1,%eax
  8020fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802103:	75 d9                	jne    8020de <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802105:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    

0080210c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802112:	89 d0                	mov    %edx,%eax
  802114:	c1 e8 16             	shr    $0x16,%eax
  802117:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80211e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802123:	f6 c1 01             	test   $0x1,%cl
  802126:	74 1d                	je     802145 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802128:	c1 ea 0c             	shr    $0xc,%edx
  80212b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802132:	f6 c2 01             	test   $0x1,%dl
  802135:	74 0e                	je     802145 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802137:	c1 ea 0c             	shr    $0xc,%edx
  80213a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802141:	ef 
  802142:	0f b7 c0             	movzwl %ax,%eax
}
  802145:	5d                   	pop    %ebp
  802146:	c3                   	ret    
  802147:	66 90                	xchg   %ax,%ax
  802149:	66 90                	xchg   %ax,%ax
  80214b:	66 90                	xchg   %ax,%ax
  80214d:	66 90                	xchg   %ax,%ax
  80214f:	90                   	nop

00802150 <__udivdi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	83 ec 1c             	sub    $0x1c,%esp
  802157:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80215b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80215f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802167:	85 f6                	test   %esi,%esi
  802169:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80216d:	89 ca                	mov    %ecx,%edx
  80216f:	89 f8                	mov    %edi,%eax
  802171:	75 3d                	jne    8021b0 <__udivdi3+0x60>
  802173:	39 cf                	cmp    %ecx,%edi
  802175:	0f 87 c5 00 00 00    	ja     802240 <__udivdi3+0xf0>
  80217b:	85 ff                	test   %edi,%edi
  80217d:	89 fd                	mov    %edi,%ebp
  80217f:	75 0b                	jne    80218c <__udivdi3+0x3c>
  802181:	b8 01 00 00 00       	mov    $0x1,%eax
  802186:	31 d2                	xor    %edx,%edx
  802188:	f7 f7                	div    %edi
  80218a:	89 c5                	mov    %eax,%ebp
  80218c:	89 c8                	mov    %ecx,%eax
  80218e:	31 d2                	xor    %edx,%edx
  802190:	f7 f5                	div    %ebp
  802192:	89 c1                	mov    %eax,%ecx
  802194:	89 d8                	mov    %ebx,%eax
  802196:	89 cf                	mov    %ecx,%edi
  802198:	f7 f5                	div    %ebp
  80219a:	89 c3                	mov    %eax,%ebx
  80219c:	89 d8                	mov    %ebx,%eax
  80219e:	89 fa                	mov    %edi,%edx
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
  8021a8:	90                   	nop
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	39 ce                	cmp    %ecx,%esi
  8021b2:	77 74                	ja     802228 <__udivdi3+0xd8>
  8021b4:	0f bd fe             	bsr    %esi,%edi
  8021b7:	83 f7 1f             	xor    $0x1f,%edi
  8021ba:	0f 84 98 00 00 00    	je     802258 <__udivdi3+0x108>
  8021c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	89 c5                	mov    %eax,%ebp
  8021c9:	29 fb                	sub    %edi,%ebx
  8021cb:	d3 e6                	shl    %cl,%esi
  8021cd:	89 d9                	mov    %ebx,%ecx
  8021cf:	d3 ed                	shr    %cl,%ebp
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	d3 e0                	shl    %cl,%eax
  8021d5:	09 ee                	or     %ebp,%esi
  8021d7:	89 d9                	mov    %ebx,%ecx
  8021d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021dd:	89 d5                	mov    %edx,%ebp
  8021df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021e3:	d3 ed                	shr    %cl,%ebp
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	d3 e2                	shl    %cl,%edx
  8021e9:	89 d9                	mov    %ebx,%ecx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	09 c2                	or     %eax,%edx
  8021ef:	89 d0                	mov    %edx,%eax
  8021f1:	89 ea                	mov    %ebp,%edx
  8021f3:	f7 f6                	div    %esi
  8021f5:	89 d5                	mov    %edx,%ebp
  8021f7:	89 c3                	mov    %eax,%ebx
  8021f9:	f7 64 24 0c          	mull   0xc(%esp)
  8021fd:	39 d5                	cmp    %edx,%ebp
  8021ff:	72 10                	jb     802211 <__udivdi3+0xc1>
  802201:	8b 74 24 08          	mov    0x8(%esp),%esi
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e6                	shl    %cl,%esi
  802209:	39 c6                	cmp    %eax,%esi
  80220b:	73 07                	jae    802214 <__udivdi3+0xc4>
  80220d:	39 d5                	cmp    %edx,%ebp
  80220f:	75 03                	jne    802214 <__udivdi3+0xc4>
  802211:	83 eb 01             	sub    $0x1,%ebx
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 d8                	mov    %ebx,%eax
  802218:	89 fa                	mov    %edi,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	31 ff                	xor    %edi,%edi
  80222a:	31 db                	xor    %ebx,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 d8                	mov    %ebx,%eax
  802242:	f7 f7                	div    %edi
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 c3                	mov    %eax,%ebx
  802248:	89 d8                	mov    %ebx,%eax
  80224a:	89 fa                	mov    %edi,%edx
  80224c:	83 c4 1c             	add    $0x1c,%esp
  80224f:	5b                   	pop    %ebx
  802250:	5e                   	pop    %esi
  802251:	5f                   	pop    %edi
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    
  802254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802258:	39 ce                	cmp    %ecx,%esi
  80225a:	72 0c                	jb     802268 <__udivdi3+0x118>
  80225c:	31 db                	xor    %ebx,%ebx
  80225e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802262:	0f 87 34 ff ff ff    	ja     80219c <__udivdi3+0x4c>
  802268:	bb 01 00 00 00       	mov    $0x1,%ebx
  80226d:	e9 2a ff ff ff       	jmp    80219c <__udivdi3+0x4c>
  802272:	66 90                	xchg   %ax,%ax
  802274:	66 90                	xchg   %ax,%ax
  802276:	66 90                	xchg   %ax,%ax
  802278:	66 90                	xchg   %ax,%ax
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	66 90                	xchg   %ax,%ax
  80227e:	66 90                	xchg   %ax,%ax

00802280 <__umoddi3>:
  802280:	55                   	push   %ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	53                   	push   %ebx
  802284:	83 ec 1c             	sub    $0x1c,%esp
  802287:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80228b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80228f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802297:	85 d2                	test   %edx,%edx
  802299:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80229d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022a1:	89 f3                	mov    %esi,%ebx
  8022a3:	89 3c 24             	mov    %edi,(%esp)
  8022a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022aa:	75 1c                	jne    8022c8 <__umoddi3+0x48>
  8022ac:	39 f7                	cmp    %esi,%edi
  8022ae:	76 50                	jbe    802300 <__umoddi3+0x80>
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	f7 f7                	div    %edi
  8022b6:	89 d0                	mov    %edx,%eax
  8022b8:	31 d2                	xor    %edx,%edx
  8022ba:	83 c4 1c             	add    $0x1c,%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
  8022c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c8:	39 f2                	cmp    %esi,%edx
  8022ca:	89 d0                	mov    %edx,%eax
  8022cc:	77 52                	ja     802320 <__umoddi3+0xa0>
  8022ce:	0f bd ea             	bsr    %edx,%ebp
  8022d1:	83 f5 1f             	xor    $0x1f,%ebp
  8022d4:	75 5a                	jne    802330 <__umoddi3+0xb0>
  8022d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022da:	0f 82 e0 00 00 00    	jb     8023c0 <__umoddi3+0x140>
  8022e0:	39 0c 24             	cmp    %ecx,(%esp)
  8022e3:	0f 86 d7 00 00 00    	jbe    8023c0 <__umoddi3+0x140>
  8022e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022f1:	83 c4 1c             	add    $0x1c,%esp
  8022f4:	5b                   	pop    %ebx
  8022f5:	5e                   	pop    %esi
  8022f6:	5f                   	pop    %edi
  8022f7:	5d                   	pop    %ebp
  8022f8:	c3                   	ret    
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	85 ff                	test   %edi,%edi
  802302:	89 fd                	mov    %edi,%ebp
  802304:	75 0b                	jne    802311 <__umoddi3+0x91>
  802306:	b8 01 00 00 00       	mov    $0x1,%eax
  80230b:	31 d2                	xor    %edx,%edx
  80230d:	f7 f7                	div    %edi
  80230f:	89 c5                	mov    %eax,%ebp
  802311:	89 f0                	mov    %esi,%eax
  802313:	31 d2                	xor    %edx,%edx
  802315:	f7 f5                	div    %ebp
  802317:	89 c8                	mov    %ecx,%eax
  802319:	f7 f5                	div    %ebp
  80231b:	89 d0                	mov    %edx,%eax
  80231d:	eb 99                	jmp    8022b8 <__umoddi3+0x38>
  80231f:	90                   	nop
  802320:	89 c8                	mov    %ecx,%eax
  802322:	89 f2                	mov    %esi,%edx
  802324:	83 c4 1c             	add    $0x1c,%esp
  802327:	5b                   	pop    %ebx
  802328:	5e                   	pop    %esi
  802329:	5f                   	pop    %edi
  80232a:	5d                   	pop    %ebp
  80232b:	c3                   	ret    
  80232c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802330:	8b 34 24             	mov    (%esp),%esi
  802333:	bf 20 00 00 00       	mov    $0x20,%edi
  802338:	89 e9                	mov    %ebp,%ecx
  80233a:	29 ef                	sub    %ebp,%edi
  80233c:	d3 e0                	shl    %cl,%eax
  80233e:	89 f9                	mov    %edi,%ecx
  802340:	89 f2                	mov    %esi,%edx
  802342:	d3 ea                	shr    %cl,%edx
  802344:	89 e9                	mov    %ebp,%ecx
  802346:	09 c2                	or     %eax,%edx
  802348:	89 d8                	mov    %ebx,%eax
  80234a:	89 14 24             	mov    %edx,(%esp)
  80234d:	89 f2                	mov    %esi,%edx
  80234f:	d3 e2                	shl    %cl,%edx
  802351:	89 f9                	mov    %edi,%ecx
  802353:	89 54 24 04          	mov    %edx,0x4(%esp)
  802357:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80235b:	d3 e8                	shr    %cl,%eax
  80235d:	89 e9                	mov    %ebp,%ecx
  80235f:	89 c6                	mov    %eax,%esi
  802361:	d3 e3                	shl    %cl,%ebx
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 d0                	mov    %edx,%eax
  802367:	d3 e8                	shr    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	09 d8                	or     %ebx,%eax
  80236d:	89 d3                	mov    %edx,%ebx
  80236f:	89 f2                	mov    %esi,%edx
  802371:	f7 34 24             	divl   (%esp)
  802374:	89 d6                	mov    %edx,%esi
  802376:	d3 e3                	shl    %cl,%ebx
  802378:	f7 64 24 04          	mull   0x4(%esp)
  80237c:	39 d6                	cmp    %edx,%esi
  80237e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802382:	89 d1                	mov    %edx,%ecx
  802384:	89 c3                	mov    %eax,%ebx
  802386:	72 08                	jb     802390 <__umoddi3+0x110>
  802388:	75 11                	jne    80239b <__umoddi3+0x11b>
  80238a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80238e:	73 0b                	jae    80239b <__umoddi3+0x11b>
  802390:	2b 44 24 04          	sub    0x4(%esp),%eax
  802394:	1b 14 24             	sbb    (%esp),%edx
  802397:	89 d1                	mov    %edx,%ecx
  802399:	89 c3                	mov    %eax,%ebx
  80239b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80239f:	29 da                	sub    %ebx,%edx
  8023a1:	19 ce                	sbb    %ecx,%esi
  8023a3:	89 f9                	mov    %edi,%ecx
  8023a5:	89 f0                	mov    %esi,%eax
  8023a7:	d3 e0                	shl    %cl,%eax
  8023a9:	89 e9                	mov    %ebp,%ecx
  8023ab:	d3 ea                	shr    %cl,%edx
  8023ad:	89 e9                	mov    %ebp,%ecx
  8023af:	d3 ee                	shr    %cl,%esi
  8023b1:	09 d0                	or     %edx,%eax
  8023b3:	89 f2                	mov    %esi,%edx
  8023b5:	83 c4 1c             	add    $0x1c,%esp
  8023b8:	5b                   	pop    %ebx
  8023b9:	5e                   	pop    %esi
  8023ba:	5f                   	pop    %edi
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    
  8023bd:	8d 76 00             	lea    0x0(%esi),%esi
  8023c0:	29 f9                	sub    %edi,%ecx
  8023c2:	19 d6                	sbb    %edx,%esi
  8023c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023cc:	e9 18 ff ff ff       	jmp    8022e9 <__umoddi3+0x69>
