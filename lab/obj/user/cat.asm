
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 65 11 00 00       	call   8011b2 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 80 24 80 00       	push   $0x802480
  800060:	6a 0d                	push   $0xd
  800062:	68 9b 24 80 00       	push   $0x80249b
  800067:	e8 1f 01 00 00       	call   80018b <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 59 10 00 00       	call   8010d8 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 a6 24 80 00       	push   $0x8024a6
  800098:	6a 0f                	push   $0xf
  80009a:	68 9b 24 80 00       	push   $0x80249b
  80009f:	e8 e7 00 00 00       	call   80018b <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 bb 	movl   $0x8024bb,0x803000
  8000be:	24 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 bf 24 80 00       	push   $0x8024bf
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 76 14 00 00       	call   801563 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 c7 24 80 00       	push   $0x8024c7
  800102:	e8 fa 15 00 00       	call   801701 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 7c 0e 00 00       	call   800f9c <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  80013e:	e8 6b 0a 00 00       	call   800bae <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80017f:	6a 00                	push   $0x0
  800181:	e8 e7 09 00 00       	call   800b6d <sys_env_destroy>
}
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	56                   	push   %esi
  80018f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800190:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800193:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800199:	e8 10 0a 00 00       	call   800bae <sys_getenvid>
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 0c             	pushl  0xc(%ebp)
  8001a4:	ff 75 08             	pushl  0x8(%ebp)
  8001a7:	56                   	push   %esi
  8001a8:	50                   	push   %eax
  8001a9:	68 e4 24 80 00       	push   $0x8024e4
  8001ae:	e8 b1 00 00 00       	call   800264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	53                   	push   %ebx
  8001b7:	ff 75 10             	pushl  0x10(%ebp)
  8001ba:	e8 54 00 00 00       	call   800213 <vcprintf>
	cprintf("\n");
  8001bf:	c7 04 24 40 29 80 00 	movl   $0x802940,(%esp)
  8001c6:	e8 99 00 00 00       	call   800264 <cprintf>
  8001cb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ce:	cc                   	int3   
  8001cf:	eb fd                	jmp    8001ce <_panic+0x43>

008001d1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 04             	sub    $0x4,%esp
  8001d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001db:	8b 13                	mov    (%ebx),%edx
  8001dd:	8d 42 01             	lea    0x1(%edx),%eax
  8001e0:	89 03                	mov    %eax,(%ebx)
  8001e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001e9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ee:	75 1a                	jne    80020a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	68 ff 00 00 00       	push   $0xff
  8001f8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fb:	50                   	push   %eax
  8001fc:	e8 2f 09 00 00       	call   800b30 <sys_cputs>
		b->idx = 0;
  800201:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800207:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80020a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80020e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80021c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800223:	00 00 00 
	b.cnt = 0;
  800226:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800230:	ff 75 0c             	pushl  0xc(%ebp)
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023c:	50                   	push   %eax
  80023d:	68 d1 01 80 00       	push   $0x8001d1
  800242:	e8 54 01 00 00       	call   80039b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800247:	83 c4 08             	add    $0x8,%esp
  80024a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800250:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800256:	50                   	push   %eax
  800257:	e8 d4 08 00 00       	call   800b30 <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026d:	50                   	push   %eax
  80026e:	ff 75 08             	pushl  0x8(%ebp)
  800271:	e8 9d ff ff ff       	call   800213 <vcprintf>
	va_end(ap);

	return cnt;
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 1c             	sub    $0x1c,%esp
  800281:	89 c7                	mov    %eax,%edi
  800283:	89 d6                	mov    %edx,%esi
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	8b 55 0c             	mov    0xc(%ebp),%edx
  80028b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800291:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80029c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80029f:	39 d3                	cmp    %edx,%ebx
  8002a1:	72 05                	jb     8002a8 <printnum+0x30>
  8002a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a6:	77 45                	ja     8002ed <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a8:	83 ec 0c             	sub    $0xc,%esp
  8002ab:	ff 75 18             	pushl  0x18(%ebp)
  8002ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002b4:	53                   	push   %ebx
  8002b5:	ff 75 10             	pushl  0x10(%ebp)
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002be:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c7:	e8 14 1f 00 00       	call   8021e0 <__udivdi3>
  8002cc:	83 c4 18             	add    $0x18,%esp
  8002cf:	52                   	push   %edx
  8002d0:	50                   	push   %eax
  8002d1:	89 f2                	mov    %esi,%edx
  8002d3:	89 f8                	mov    %edi,%eax
  8002d5:	e8 9e ff ff ff       	call   800278 <printnum>
  8002da:	83 c4 20             	add    $0x20,%esp
  8002dd:	eb 18                	jmp    8002f7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	ff 75 18             	pushl  0x18(%ebp)
  8002e6:	ff d7                	call   *%edi
  8002e8:	83 c4 10             	add    $0x10,%esp
  8002eb:	eb 03                	jmp    8002f0 <printnum+0x78>
  8002ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f0:	83 eb 01             	sub    $0x1,%ebx
  8002f3:	85 db                	test   %ebx,%ebx
  8002f5:	7f e8                	jg     8002df <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f7:	83 ec 08             	sub    $0x8,%esp
  8002fa:	56                   	push   %esi
  8002fb:	83 ec 04             	sub    $0x4,%esp
  8002fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800301:	ff 75 e0             	pushl  -0x20(%ebp)
  800304:	ff 75 dc             	pushl  -0x24(%ebp)
  800307:	ff 75 d8             	pushl  -0x28(%ebp)
  80030a:	e8 01 20 00 00       	call   802310 <__umoddi3>
  80030f:	83 c4 14             	add    $0x14,%esp
  800312:	0f be 80 07 25 80 00 	movsbl 0x802507(%eax),%eax
  800319:	50                   	push   %eax
  80031a:	ff d7                	call   *%edi
}
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800322:	5b                   	pop    %ebx
  800323:	5e                   	pop    %esi
  800324:	5f                   	pop    %edi
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032a:	83 fa 01             	cmp    $0x1,%edx
  80032d:	7e 0e                	jle    80033d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	8d 4a 08             	lea    0x8(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 02                	mov    (%edx),%eax
  800338:	8b 52 04             	mov    0x4(%edx),%edx
  80033b:	eb 22                	jmp    80035f <getuint+0x38>
	else if (lflag)
  80033d:	85 d2                	test   %edx,%edx
  80033f:	74 10                	je     800351 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800341:	8b 10                	mov    (%eax),%edx
  800343:	8d 4a 04             	lea    0x4(%edx),%ecx
  800346:	89 08                	mov    %ecx,(%eax)
  800348:	8b 02                	mov    (%edx),%eax
  80034a:	ba 00 00 00 00       	mov    $0x0,%edx
  80034f:	eb 0e                	jmp    80035f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800351:	8b 10                	mov    (%eax),%edx
  800353:	8d 4a 04             	lea    0x4(%edx),%ecx
  800356:	89 08                	mov    %ecx,(%eax)
  800358:	8b 02                	mov    (%edx),%eax
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800367:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036b:	8b 10                	mov    (%eax),%edx
  80036d:	3b 50 04             	cmp    0x4(%eax),%edx
  800370:	73 0a                	jae    80037c <sprintputch+0x1b>
		*b->buf++ = ch;
  800372:	8d 4a 01             	lea    0x1(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	88 02                	mov    %al,(%edx)
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800384:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800387:	50                   	push   %eax
  800388:	ff 75 10             	pushl  0x10(%ebp)
  80038b:	ff 75 0c             	pushl  0xc(%ebp)
  80038e:	ff 75 08             	pushl  0x8(%ebp)
  800391:	e8 05 00 00 00       	call   80039b <vprintfmt>
	va_end(ap);
}
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	c9                   	leave  
  80039a:	c3                   	ret    

0080039b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	57                   	push   %edi
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
  8003a1:	83 ec 2c             	sub    $0x2c,%esp
  8003a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003aa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003ad:	eb 12                	jmp    8003c1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003af:	85 c0                	test   %eax,%eax
  8003b1:	0f 84 89 03 00 00    	je     800740 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	53                   	push   %ebx
  8003bb:	50                   	push   %eax
  8003bc:	ff d6                	call   *%esi
  8003be:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c1:	83 c7 01             	add    $0x1,%edi
  8003c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003c8:	83 f8 25             	cmp    $0x25,%eax
  8003cb:	75 e2                	jne    8003af <vprintfmt+0x14>
  8003cd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003df:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003eb:	eb 07                	jmp    8003f4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8d 47 01             	lea    0x1(%edi),%eax
  8003f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fa:	0f b6 07             	movzbl (%edi),%eax
  8003fd:	0f b6 c8             	movzbl %al,%ecx
  800400:	83 e8 23             	sub    $0x23,%eax
  800403:	3c 55                	cmp    $0x55,%al
  800405:	0f 87 1a 03 00 00    	ja     800725 <vprintfmt+0x38a>
  80040b:	0f b6 c0             	movzbl %al,%eax
  80040e:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800418:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041c:	eb d6                	jmp    8003f4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800421:	b8 00 00 00 00       	mov    $0x0,%eax
  800426:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800429:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800430:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800433:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800436:	83 fa 09             	cmp    $0x9,%edx
  800439:	77 39                	ja     800474 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043e:	eb e9                	jmp    800429 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 48 04             	lea    0x4(%eax),%ecx
  800446:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800451:	eb 27                	jmp    80047a <vprintfmt+0xdf>
  800453:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800456:	85 c0                	test   %eax,%eax
  800458:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045d:	0f 49 c8             	cmovns %eax,%ecx
  800460:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800466:	eb 8c                	jmp    8003f4 <vprintfmt+0x59>
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800472:	eb 80                	jmp    8003f4 <vprintfmt+0x59>
  800474:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800477:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80047a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047e:	0f 89 70 ff ff ff    	jns    8003f4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800484:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800487:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800491:	e9 5e ff ff ff       	jmp    8003f4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800496:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049c:	e9 53 ff ff ff       	jmp    8003f4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	ff 30                	pushl  (%eax)
  8004b0:	ff d6                	call   *%esi
			break;
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b8:	e9 04 ff ff ff       	jmp    8003c1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 50 04             	lea    0x4(%eax),%edx
  8004c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c6:	8b 00                	mov    (%eax),%eax
  8004c8:	99                   	cltd   
  8004c9:	31 d0                	xor    %edx,%eax
  8004cb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cd:	83 f8 0f             	cmp    $0xf,%eax
  8004d0:	7f 0b                	jg     8004dd <vprintfmt+0x142>
  8004d2:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  8004d9:	85 d2                	test   %edx,%edx
  8004db:	75 18                	jne    8004f5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004dd:	50                   	push   %eax
  8004de:	68 1f 25 80 00       	push   $0x80251f
  8004e3:	53                   	push   %ebx
  8004e4:	56                   	push   %esi
  8004e5:	e8 94 fe ff ff       	call   80037e <printfmt>
  8004ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f0:	e9 cc fe ff ff       	jmp    8003c1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004f5:	52                   	push   %edx
  8004f6:	68 d5 28 80 00       	push   $0x8028d5
  8004fb:	53                   	push   %ebx
  8004fc:	56                   	push   %esi
  8004fd:	e8 7c fe ff ff       	call   80037e <printfmt>
  800502:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800508:	e9 b4 fe ff ff       	jmp    8003c1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800518:	85 ff                	test   %edi,%edi
  80051a:	b8 18 25 80 00       	mov    $0x802518,%eax
  80051f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800522:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800526:	0f 8e 94 00 00 00    	jle    8005c0 <vprintfmt+0x225>
  80052c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800530:	0f 84 98 00 00 00    	je     8005ce <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	ff 75 d0             	pushl  -0x30(%ebp)
  80053c:	57                   	push   %edi
  80053d:	e8 86 02 00 00       	call   8007c8 <strnlen>
  800542:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800545:	29 c1                	sub    %eax,%ecx
  800547:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80054a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80054d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800551:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800554:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800557:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800559:	eb 0f                	jmp    80056a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	53                   	push   %ebx
  80055f:	ff 75 e0             	pushl  -0x20(%ebp)
  800562:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800564:	83 ef 01             	sub    $0x1,%edi
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	85 ff                	test   %edi,%edi
  80056c:	7f ed                	jg     80055b <vprintfmt+0x1c0>
  80056e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800571:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800574:	85 c9                	test   %ecx,%ecx
  800576:	b8 00 00 00 00       	mov    $0x0,%eax
  80057b:	0f 49 c1             	cmovns %ecx,%eax
  80057e:	29 c1                	sub    %eax,%ecx
  800580:	89 75 08             	mov    %esi,0x8(%ebp)
  800583:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800586:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800589:	89 cb                	mov    %ecx,%ebx
  80058b:	eb 4d                	jmp    8005da <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800591:	74 1b                	je     8005ae <vprintfmt+0x213>
  800593:	0f be c0             	movsbl %al,%eax
  800596:	83 e8 20             	sub    $0x20,%eax
  800599:	83 f8 5e             	cmp    $0x5e,%eax
  80059c:	76 10                	jbe    8005ae <vprintfmt+0x213>
					putch('?', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	ff 75 0c             	pushl  0xc(%ebp)
  8005a4:	6a 3f                	push   $0x3f
  8005a6:	ff 55 08             	call   *0x8(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	eb 0d                	jmp    8005bb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	ff 75 0c             	pushl  0xc(%ebp)
  8005b4:	52                   	push   %edx
  8005b5:	ff 55 08             	call   *0x8(%ebp)
  8005b8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bb:	83 eb 01             	sub    $0x1,%ebx
  8005be:	eb 1a                	jmp    8005da <vprintfmt+0x23f>
  8005c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cc:	eb 0c                	jmp    8005da <vprintfmt+0x23f>
  8005ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005da:	83 c7 01             	add    $0x1,%edi
  8005dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e1:	0f be d0             	movsbl %al,%edx
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	74 23                	je     80060b <vprintfmt+0x270>
  8005e8:	85 f6                	test   %esi,%esi
  8005ea:	78 a1                	js     80058d <vprintfmt+0x1f2>
  8005ec:	83 ee 01             	sub    $0x1,%esi
  8005ef:	79 9c                	jns    80058d <vprintfmt+0x1f2>
  8005f1:	89 df                	mov    %ebx,%edi
  8005f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f9:	eb 18                	jmp    800613 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	53                   	push   %ebx
  8005ff:	6a 20                	push   $0x20
  800601:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800603:	83 ef 01             	sub    $0x1,%edi
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	eb 08                	jmp    800613 <vprintfmt+0x278>
  80060b:	89 df                	mov    %ebx,%edi
  80060d:	8b 75 08             	mov    0x8(%ebp),%esi
  800610:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800613:	85 ff                	test   %edi,%edi
  800615:	7f e4                	jg     8005fb <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061a:	e9 a2 fd ff ff       	jmp    8003c1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 fa 01             	cmp    $0x1,%edx
  800622:	7e 16                	jle    80063a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 08             	lea    0x8(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 50 04             	mov    0x4(%eax),%edx
  800630:	8b 00                	mov    (%eax),%eax
  800632:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800635:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800638:	eb 32                	jmp    80066c <vprintfmt+0x2d1>
	else if (lflag)
  80063a:	85 d2                	test   %edx,%edx
  80063c:	74 18                	je     800656 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064c:	89 c1                	mov    %eax,%ecx
  80064e:	c1 f9 1f             	sar    $0x1f,%ecx
  800651:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800654:	eb 16                	jmp    80066c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 c1                	mov    %eax,%ecx
  800666:	c1 f9 1f             	sar    $0x1f,%ecx
  800669:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80066f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800672:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800677:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067b:	79 74                	jns    8006f1 <vprintfmt+0x356>
				putch('-', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 2d                	push   $0x2d
  800683:	ff d6                	call   *%esi
				num = -(long long) num;
  800685:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800688:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80068b:	f7 d8                	neg    %eax
  80068d:	83 d2 00             	adc    $0x0,%edx
  800690:	f7 da                	neg    %edx
  800692:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800695:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80069a:	eb 55                	jmp    8006f1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80069c:	8d 45 14             	lea    0x14(%ebp),%eax
  80069f:	e8 83 fc ff ff       	call   800327 <getuint>
			base = 10;
  8006a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006a9:	eb 46                	jmp    8006f1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 74 fc ff ff       	call   800327 <getuint>
			base = 8;
  8006b3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006b8:	eb 37                	jmp    8006f1 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	53                   	push   %ebx
  8006be:	6a 30                	push   $0x30
  8006c0:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c2:	83 c4 08             	add    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 78                	push   $0x78
  8006c8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d3:	8b 00                	mov    (%eax),%eax
  8006d5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006da:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006dd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006e2:	eb 0d                	jmp    8006f1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e7:	e8 3b fc ff ff       	call   800327 <getuint>
			base = 16;
  8006ec:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f1:	83 ec 0c             	sub    $0xc,%esp
  8006f4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f8:	57                   	push   %edi
  8006f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fc:	51                   	push   %ecx
  8006fd:	52                   	push   %edx
  8006fe:	50                   	push   %eax
  8006ff:	89 da                	mov    %ebx,%edx
  800701:	89 f0                	mov    %esi,%eax
  800703:	e8 70 fb ff ff       	call   800278 <printnum>
			break;
  800708:	83 c4 20             	add    $0x20,%esp
  80070b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070e:	e9 ae fc ff ff       	jmp    8003c1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	51                   	push   %ecx
  800718:	ff d6                	call   *%esi
			break;
  80071a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800720:	e9 9c fc ff ff       	jmp    8003c1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	6a 25                	push   $0x25
  80072b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb 03                	jmp    800735 <vprintfmt+0x39a>
  800732:	83 ef 01             	sub    $0x1,%edi
  800735:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800739:	75 f7                	jne    800732 <vprintfmt+0x397>
  80073b:	e9 81 fc ff ff       	jmp    8003c1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800743:	5b                   	pop    %ebx
  800744:	5e                   	pop    %esi
  800745:	5f                   	pop    %edi
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	83 ec 18             	sub    $0x18,%esp
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800754:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800757:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800765:	85 c0                	test   %eax,%eax
  800767:	74 26                	je     80078f <vsnprintf+0x47>
  800769:	85 d2                	test   %edx,%edx
  80076b:	7e 22                	jle    80078f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076d:	ff 75 14             	pushl  0x14(%ebp)
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	68 61 03 80 00       	push   $0x800361
  80077c:	e8 1a fc ff ff       	call   80039b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800781:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800784:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800787:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	eb 05                	jmp    800794 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079f:	50                   	push   %eax
  8007a0:	ff 75 10             	pushl  0x10(%ebp)
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	ff 75 08             	pushl  0x8(%ebp)
  8007a9:	e8 9a ff ff ff       	call   800748 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 03                	jmp    8007c0 <strlen+0x10>
		n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c4:	75 f7                	jne    8007bd <strlen+0xd>
		n++;
	return n;
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d6:	eb 03                	jmp    8007db <strnlen+0x13>
		n++;
  8007d8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	39 c2                	cmp    %eax,%edx
  8007dd:	74 08                	je     8007e7 <strnlen+0x1f>
  8007df:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e3:	75 f3                	jne    8007d8 <strnlen+0x10>
  8007e5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f3:	89 c2                	mov    %eax,%edx
  8007f5:	83 c2 01             	add    $0x1,%edx
  8007f8:	83 c1 01             	add    $0x1,%ecx
  8007fb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ff:	88 5a ff             	mov    %bl,-0x1(%edx)
  800802:	84 db                	test   %bl,%bl
  800804:	75 ef                	jne    8007f5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800806:	5b                   	pop    %ebx
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800810:	53                   	push   %ebx
  800811:	e8 9a ff ff ff       	call   8007b0 <strlen>
  800816:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800819:	ff 75 0c             	pushl  0xc(%ebp)
  80081c:	01 d8                	add    %ebx,%eax
  80081e:	50                   	push   %eax
  80081f:	e8 c5 ff ff ff       	call   8007e9 <strcpy>
	return dst;
}
  800824:	89 d8                	mov    %ebx,%eax
  800826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 75 08             	mov    0x8(%ebp),%esi
  800833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800836:	89 f3                	mov    %esi,%ebx
  800838:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083b:	89 f2                	mov    %esi,%edx
  80083d:	eb 0f                	jmp    80084e <strncpy+0x23>
		*dst++ = *src;
  80083f:	83 c2 01             	add    $0x1,%edx
  800842:	0f b6 01             	movzbl (%ecx),%eax
  800845:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800848:	80 39 01             	cmpb   $0x1,(%ecx)
  80084b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084e:	39 da                	cmp    %ebx,%edx
  800850:	75 ed                	jne    80083f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800852:	89 f0                	mov    %esi,%eax
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 75 08             	mov    0x8(%ebp),%esi
  800860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800863:	8b 55 10             	mov    0x10(%ebp),%edx
  800866:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800868:	85 d2                	test   %edx,%edx
  80086a:	74 21                	je     80088d <strlcpy+0x35>
  80086c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800870:	89 f2                	mov    %esi,%edx
  800872:	eb 09                	jmp    80087d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800874:	83 c2 01             	add    $0x1,%edx
  800877:	83 c1 01             	add    $0x1,%ecx
  80087a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087d:	39 c2                	cmp    %eax,%edx
  80087f:	74 09                	je     80088a <strlcpy+0x32>
  800881:	0f b6 19             	movzbl (%ecx),%ebx
  800884:	84 db                	test   %bl,%bl
  800886:	75 ec                	jne    800874 <strlcpy+0x1c>
  800888:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80088a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088d:	29 f0                	sub    %esi,%eax
}
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089c:	eb 06                	jmp    8008a4 <strcmp+0x11>
		p++, q++;
  80089e:	83 c1 01             	add    $0x1,%ecx
  8008a1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a4:	0f b6 01             	movzbl (%ecx),%eax
  8008a7:	84 c0                	test   %al,%al
  8008a9:	74 04                	je     8008af <strcmp+0x1c>
  8008ab:	3a 02                	cmp    (%edx),%al
  8008ad:	74 ef                	je     80089e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 c0             	movzbl %al,%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c3:	89 c3                	mov    %eax,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c8:	eb 06                	jmp    8008d0 <strncmp+0x17>
		n--, p++, q++;
  8008ca:	83 c0 01             	add    $0x1,%eax
  8008cd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d0:	39 d8                	cmp    %ebx,%eax
  8008d2:	74 15                	je     8008e9 <strncmp+0x30>
  8008d4:	0f b6 08             	movzbl (%eax),%ecx
  8008d7:	84 c9                	test   %cl,%cl
  8008d9:	74 04                	je     8008df <strncmp+0x26>
  8008db:	3a 0a                	cmp    (%edx),%cl
  8008dd:	74 eb                	je     8008ca <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 00             	movzbl (%eax),%eax
  8008e2:	0f b6 12             	movzbl (%edx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
  8008e7:	eb 05                	jmp    8008ee <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fb:	eb 07                	jmp    800904 <strchr+0x13>
		if (*s == c)
  8008fd:	38 ca                	cmp    %cl,%dl
  8008ff:	74 0f                	je     800910 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	0f b6 10             	movzbl (%eax),%edx
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f2                	jne    8008fd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091c:	eb 03                	jmp    800921 <strfind+0xf>
  80091e:	83 c0 01             	add    $0x1,%eax
  800921:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 04                	je     80092c <strfind+0x1a>
  800928:	84 d2                	test   %dl,%dl
  80092a:	75 f2                	jne    80091e <strfind+0xc>
			break;
	return (char *) s;
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	57                   	push   %edi
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 7d 08             	mov    0x8(%ebp),%edi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093a:	85 c9                	test   %ecx,%ecx
  80093c:	74 36                	je     800974 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800944:	75 28                	jne    80096e <memset+0x40>
  800946:	f6 c1 03             	test   $0x3,%cl
  800949:	75 23                	jne    80096e <memset+0x40>
		c &= 0xFF;
  80094b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094f:	89 d3                	mov    %edx,%ebx
  800951:	c1 e3 08             	shl    $0x8,%ebx
  800954:	89 d6                	mov    %edx,%esi
  800956:	c1 e6 18             	shl    $0x18,%esi
  800959:	89 d0                	mov    %edx,%eax
  80095b:	c1 e0 10             	shl    $0x10,%eax
  80095e:	09 f0                	or     %esi,%eax
  800960:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800962:	89 d8                	mov    %ebx,%eax
  800964:	09 d0                	or     %edx,%eax
  800966:	c1 e9 02             	shr    $0x2,%ecx
  800969:	fc                   	cld    
  80096a:	f3 ab                	rep stos %eax,%es:(%edi)
  80096c:	eb 06                	jmp    800974 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	fc                   	cld    
  800972:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800974:	89 f8                	mov    %edi,%eax
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 75 0c             	mov    0xc(%ebp),%esi
  800986:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800989:	39 c6                	cmp    %eax,%esi
  80098b:	73 35                	jae    8009c2 <memmove+0x47>
  80098d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800990:	39 d0                	cmp    %edx,%eax
  800992:	73 2e                	jae    8009c2 <memmove+0x47>
		s += n;
		d += n;
  800994:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	89 d6                	mov    %edx,%esi
  800999:	09 fe                	or     %edi,%esi
  80099b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a1:	75 13                	jne    8009b6 <memmove+0x3b>
  8009a3:	f6 c1 03             	test   $0x3,%cl
  8009a6:	75 0e                	jne    8009b6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a8:	83 ef 04             	sub    $0x4,%edi
  8009ab:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ae:	c1 e9 02             	shr    $0x2,%ecx
  8009b1:	fd                   	std    
  8009b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b4:	eb 09                	jmp    8009bf <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b6:	83 ef 01             	sub    $0x1,%edi
  8009b9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009bc:	fd                   	std    
  8009bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bf:	fc                   	cld    
  8009c0:	eb 1d                	jmp    8009df <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	09 c2                	or     %eax,%edx
  8009c6:	f6 c2 03             	test   $0x3,%dl
  8009c9:	75 0f                	jne    8009da <memmove+0x5f>
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 0a                	jne    8009da <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d0:	c1 e9 02             	shr    $0x2,%ecx
  8009d3:	89 c7                	mov    %eax,%edi
  8009d5:	fc                   	cld    
  8009d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d8:	eb 05                	jmp    8009df <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009da:	89 c7                	mov    %eax,%edi
  8009dc:	fc                   	cld    
  8009dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009df:	5e                   	pop    %esi
  8009e0:	5f                   	pop    %edi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e6:	ff 75 10             	pushl  0x10(%ebp)
  8009e9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ec:	ff 75 08             	pushl  0x8(%ebp)
  8009ef:	e8 87 ff ff ff       	call   80097b <memmove>
}
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a01:	89 c6                	mov    %eax,%esi
  800a03:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a06:	eb 1a                	jmp    800a22 <memcmp+0x2c>
		if (*s1 != *s2)
  800a08:	0f b6 08             	movzbl (%eax),%ecx
  800a0b:	0f b6 1a             	movzbl (%edx),%ebx
  800a0e:	38 d9                	cmp    %bl,%cl
  800a10:	74 0a                	je     800a1c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a12:	0f b6 c1             	movzbl %cl,%eax
  800a15:	0f b6 db             	movzbl %bl,%ebx
  800a18:	29 d8                	sub    %ebx,%eax
  800a1a:	eb 0f                	jmp    800a2b <memcmp+0x35>
		s1++, s2++;
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	39 f0                	cmp    %esi,%eax
  800a24:	75 e2                	jne    800a08 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a36:	89 c1                	mov    %eax,%ecx
  800a38:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3f:	eb 0a                	jmp    800a4b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a41:	0f b6 10             	movzbl (%eax),%edx
  800a44:	39 da                	cmp    %ebx,%edx
  800a46:	74 07                	je     800a4f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	39 c8                	cmp    %ecx,%eax
  800a4d:	72 f2                	jb     800a41 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5e:	eb 03                	jmp    800a63 <strtol+0x11>
		s++;
  800a60:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	0f b6 01             	movzbl (%ecx),%eax
  800a66:	3c 20                	cmp    $0x20,%al
  800a68:	74 f6                	je     800a60 <strtol+0xe>
  800a6a:	3c 09                	cmp    $0x9,%al
  800a6c:	74 f2                	je     800a60 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6e:	3c 2b                	cmp    $0x2b,%al
  800a70:	75 0a                	jne    800a7c <strtol+0x2a>
		s++;
  800a72:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7a:	eb 11                	jmp    800a8d <strtol+0x3b>
  800a7c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a81:	3c 2d                	cmp    $0x2d,%al
  800a83:	75 08                	jne    800a8d <strtol+0x3b>
		s++, neg = 1;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a93:	75 15                	jne    800aaa <strtol+0x58>
  800a95:	80 39 30             	cmpb   $0x30,(%ecx)
  800a98:	75 10                	jne    800aaa <strtol+0x58>
  800a9a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9e:	75 7c                	jne    800b1c <strtol+0xca>
		s += 2, base = 16;
  800aa0:	83 c1 02             	add    $0x2,%ecx
  800aa3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa8:	eb 16                	jmp    800ac0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	75 12                	jne    800ac0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aae:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab6:	75 08                	jne    800ac0 <strtol+0x6e>
		s++, base = 8;
  800ab8:	83 c1 01             	add    $0x1,%ecx
  800abb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac8:	0f b6 11             	movzbl (%ecx),%edx
  800acb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	80 fb 09             	cmp    $0x9,%bl
  800ad3:	77 08                	ja     800add <strtol+0x8b>
			dig = *s - '0';
  800ad5:	0f be d2             	movsbl %dl,%edx
  800ad8:	83 ea 30             	sub    $0x30,%edx
  800adb:	eb 22                	jmp    800aff <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800add:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 08                	ja     800aef <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae7:	0f be d2             	movsbl %dl,%edx
  800aea:	83 ea 57             	sub    $0x57,%edx
  800aed:	eb 10                	jmp    800aff <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aef:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 19             	cmp    $0x19,%bl
  800af7:	77 16                	ja     800b0f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af9:	0f be d2             	movsbl %dl,%edx
  800afc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aff:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b02:	7d 0b                	jge    800b0f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b04:	83 c1 01             	add    $0x1,%ecx
  800b07:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b0d:	eb b9                	jmp    800ac8 <strtol+0x76>

	if (endptr)
  800b0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b13:	74 0d                	je     800b22 <strtol+0xd0>
		*endptr = (char *) s;
  800b15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b18:	89 0e                	mov    %ecx,(%esi)
  800b1a:	eb 06                	jmp    800b22 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1c:	85 db                	test   %ebx,%ebx
  800b1e:	74 98                	je     800ab8 <strtol+0x66>
  800b20:	eb 9e                	jmp    800ac0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b22:	89 c2                	mov    %eax,%edx
  800b24:	f7 da                	neg    %edx
  800b26:	85 ff                	test   %edi,%edi
  800b28:	0f 45 c2             	cmovne %edx,%eax
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	89 c7                	mov    %eax,%edi
  800b45:	89 c6                	mov    %eax,%esi
  800b47:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
  800b83:	89 cb                	mov    %ecx,%ebx
  800b85:	89 cf                	mov    %ecx,%edi
  800b87:	89 ce                	mov    %ecx,%esi
  800b89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7e 17                	jle    800ba6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	50                   	push   %eax
  800b93:	6a 03                	push   $0x3
  800b95:	68 ff 27 80 00       	push   $0x8027ff
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 1c 28 80 00       	push   $0x80281c
  800ba1:	e8 e5 f5 ff ff       	call   80018b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_yield>:

void
sys_yield(void)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bdd:	89 d1                	mov    %edx,%ecx
  800bdf:	89 d3                	mov    %edx,%ebx
  800be1:	89 d7                	mov    %edx,%edi
  800be3:	89 d6                	mov    %edx,%esi
  800be5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	be 00 00 00 00       	mov    $0x0,%esi
  800bfa:	b8 04 00 00 00       	mov    $0x4,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	89 f7                	mov    %esi,%edi
  800c0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7e 17                	jle    800c27 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	50                   	push   %eax
  800c14:	6a 04                	push   $0x4
  800c16:	68 ff 27 80 00       	push   $0x8027ff
  800c1b:	6a 23                	push   $0x23
  800c1d:	68 1c 28 80 00       	push   $0x80281c
  800c22:	e8 64 f5 ff ff       	call   80018b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c49:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	7e 17                	jle    800c69 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c52:	83 ec 0c             	sub    $0xc,%esp
  800c55:	50                   	push   %eax
  800c56:	6a 05                	push   $0x5
  800c58:	68 ff 27 80 00       	push   $0x8027ff
  800c5d:	6a 23                	push   $0x23
  800c5f:	68 1c 28 80 00       	push   $0x80281c
  800c64:	e8 22 f5 ff ff       	call   80018b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	89 df                	mov    %ebx,%edi
  800c8c:	89 de                	mov    %ebx,%esi
  800c8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c90:	85 c0                	test   %eax,%eax
  800c92:	7e 17                	jle    800cab <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 06                	push   $0x6
  800c9a:	68 ff 27 80 00       	push   $0x8027ff
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 1c 28 80 00       	push   $0x80281c
  800ca6:	e8 e0 f4 ff ff       	call   80018b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	89 df                	mov    %ebx,%edi
  800cce:	89 de                	mov    %ebx,%esi
  800cd0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	7e 17                	jle    800ced <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd6:	83 ec 0c             	sub    $0xc,%esp
  800cd9:	50                   	push   %eax
  800cda:	6a 08                	push   $0x8
  800cdc:	68 ff 27 80 00       	push   $0x8027ff
  800ce1:	6a 23                	push   $0x23
  800ce3:	68 1c 28 80 00       	push   $0x80281c
  800ce8:	e8 9e f4 ff ff       	call   80018b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	b8 09 00 00 00       	mov    $0x9,%eax
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	89 df                	mov    %ebx,%edi
  800d10:	89 de                	mov    %ebx,%esi
  800d12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7e 17                	jle    800d2f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	50                   	push   %eax
  800d1c:	6a 09                	push   $0x9
  800d1e:	68 ff 27 80 00       	push   $0x8027ff
  800d23:	6a 23                	push   $0x23
  800d25:	68 1c 28 80 00       	push   $0x80281c
  800d2a:	e8 5c f4 ff ff       	call   80018b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	89 df                	mov    %ebx,%edi
  800d52:	89 de                	mov    %ebx,%esi
  800d54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7e 17                	jle    800d71 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5a:	83 ec 0c             	sub    $0xc,%esp
  800d5d:	50                   	push   %eax
  800d5e:	6a 0a                	push   $0xa
  800d60:	68 ff 27 80 00       	push   $0x8027ff
  800d65:	6a 23                	push   $0x23
  800d67:	68 1c 28 80 00       	push   $0x80281c
  800d6c:	e8 1a f4 ff ff       	call   80018b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	be 00 00 00 00       	mov    $0x0,%esi
  800d84:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d95:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
  800da2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800daa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	89 cb                	mov    %ecx,%ebx
  800db4:	89 cf                	mov    %ecx,%edi
  800db6:	89 ce                	mov    %ecx,%esi
  800db8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7e 17                	jle    800dd5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 0d                	push   $0xd
  800dc4:	68 ff 27 80 00       	push   $0x8027ff
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 1c 28 80 00       	push   $0x80281c
  800dd0:	e8 b6 f3 ff ff       	call   80018b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	ba 00 00 00 00       	mov    $0x0,%edx
  800de8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ded:	89 d1                	mov    %edx,%ecx
  800def:	89 d3                	mov    %edx,%ebx
  800df1:	89 d7                	mov    %edx,%edi
  800df3:	89 d6                	mov    %edx,%esi
  800df5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	05 00 00 00 30       	add    $0x30000000,%eax
  800e07:	c1 e8 0c             	shr    $0xc,%eax
}
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	05 00 00 00 30       	add    $0x30000000,%eax
  800e17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e1c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e29:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	c1 ea 16             	shr    $0x16,%edx
  800e33:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e3a:	f6 c2 01             	test   $0x1,%dl
  800e3d:	74 11                	je     800e50 <fd_alloc+0x2d>
  800e3f:	89 c2                	mov    %eax,%edx
  800e41:	c1 ea 0c             	shr    $0xc,%edx
  800e44:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4b:	f6 c2 01             	test   $0x1,%dl
  800e4e:	75 09                	jne    800e59 <fd_alloc+0x36>
			*fd_store = fd;
  800e50:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e52:	b8 00 00 00 00       	mov    $0x0,%eax
  800e57:	eb 17                	jmp    800e70 <fd_alloc+0x4d>
  800e59:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e5e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e63:	75 c9                	jne    800e2e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e65:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e6b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e78:	83 f8 1f             	cmp    $0x1f,%eax
  800e7b:	77 36                	ja     800eb3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e7d:	c1 e0 0c             	shl    $0xc,%eax
  800e80:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e85:	89 c2                	mov    %eax,%edx
  800e87:	c1 ea 16             	shr    $0x16,%edx
  800e8a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e91:	f6 c2 01             	test   $0x1,%dl
  800e94:	74 24                	je     800eba <fd_lookup+0x48>
  800e96:	89 c2                	mov    %eax,%edx
  800e98:	c1 ea 0c             	shr    $0xc,%edx
  800e9b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea2:	f6 c2 01             	test   $0x1,%dl
  800ea5:	74 1a                	je     800ec1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ea7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eaa:	89 02                	mov    %eax,(%edx)
	return 0;
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb1:	eb 13                	jmp    800ec6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb8:	eb 0c                	jmp    800ec6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ebf:	eb 05                	jmp    800ec6 <fd_lookup+0x54>
  800ec1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 08             	sub    $0x8,%esp
  800ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed1:	ba a8 28 80 00       	mov    $0x8028a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ed6:	eb 13                	jmp    800eeb <dev_lookup+0x23>
  800ed8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800edb:	39 08                	cmp    %ecx,(%eax)
  800edd:	75 0c                	jne    800eeb <dev_lookup+0x23>
			*dev = devtab[i];
  800edf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee9:	eb 2e                	jmp    800f19 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eeb:	8b 02                	mov    (%edx),%eax
  800eed:	85 c0                	test   %eax,%eax
  800eef:	75 e7                	jne    800ed8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef1:	a1 20 60 80 00       	mov    0x806020,%eax
  800ef6:	8b 40 48             	mov    0x48(%eax),%eax
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	51                   	push   %ecx
  800efd:	50                   	push   %eax
  800efe:	68 2c 28 80 00       	push   $0x80282c
  800f03:	e8 5c f3 ff ff       	call   800264 <cprintf>
	*dev = 0;
  800f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 10             	sub    $0x10,%esp
  800f23:	8b 75 08             	mov    0x8(%ebp),%esi
  800f26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2c:	50                   	push   %eax
  800f2d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f33:	c1 e8 0c             	shr    $0xc,%eax
  800f36:	50                   	push   %eax
  800f37:	e8 36 ff ff ff       	call   800e72 <fd_lookup>
  800f3c:	83 c4 08             	add    $0x8,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 05                	js     800f48 <fd_close+0x2d>
	    || fd != fd2)
  800f43:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f46:	74 0c                	je     800f54 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f48:	84 db                	test   %bl,%bl
  800f4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4f:	0f 44 c2             	cmove  %edx,%eax
  800f52:	eb 41                	jmp    800f95 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f54:	83 ec 08             	sub    $0x8,%esp
  800f57:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f5a:	50                   	push   %eax
  800f5b:	ff 36                	pushl  (%esi)
  800f5d:	e8 66 ff ff ff       	call   800ec8 <dev_lookup>
  800f62:	89 c3                	mov    %eax,%ebx
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 1a                	js     800f85 <fd_close+0x6a>
		if (dev->dev_close)
  800f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f71:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	74 0b                	je     800f85 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	56                   	push   %esi
  800f7e:	ff d0                	call   *%eax
  800f80:	89 c3                	mov    %eax,%ebx
  800f82:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f85:	83 ec 08             	sub    $0x8,%esp
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 e1 fc ff ff       	call   800c71 <sys_page_unmap>
	return r;
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	89 d8                	mov    %ebx,%eax
}
  800f95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa5:	50                   	push   %eax
  800fa6:	ff 75 08             	pushl  0x8(%ebp)
  800fa9:	e8 c4 fe ff ff       	call   800e72 <fd_lookup>
  800fae:	83 c4 08             	add    $0x8,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 10                	js     800fc5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	6a 01                	push   $0x1
  800fba:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbd:	e8 59 ff ff ff       	call   800f1b <fd_close>
  800fc2:	83 c4 10             	add    $0x10,%esp
}
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    

00800fc7 <close_all>:

void
close_all(void)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fce:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fd3:	83 ec 0c             	sub    $0xc,%esp
  800fd6:	53                   	push   %ebx
  800fd7:	e8 c0 ff ff ff       	call   800f9c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdc:	83 c3 01             	add    $0x1,%ebx
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	83 fb 20             	cmp    $0x20,%ebx
  800fe5:	75 ec                	jne    800fd3 <close_all+0xc>
		close(i);
}
  800fe7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    

00800fec <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	57                   	push   %edi
  800ff0:	56                   	push   %esi
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 2c             	sub    $0x2c,%esp
  800ff5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ff8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	ff 75 08             	pushl  0x8(%ebp)
  800fff:	e8 6e fe ff ff       	call   800e72 <fd_lookup>
  801004:	83 c4 08             	add    $0x8,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	0f 88 c1 00 00 00    	js     8010d0 <dup+0xe4>
		return r;
	close(newfdnum);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	56                   	push   %esi
  801013:	e8 84 ff ff ff       	call   800f9c <close>

	newfd = INDEX2FD(newfdnum);
  801018:	89 f3                	mov    %esi,%ebx
  80101a:	c1 e3 0c             	shl    $0xc,%ebx
  80101d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801023:	83 c4 04             	add    $0x4,%esp
  801026:	ff 75 e4             	pushl  -0x1c(%ebp)
  801029:	e8 de fd ff ff       	call   800e0c <fd2data>
  80102e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801030:	89 1c 24             	mov    %ebx,(%esp)
  801033:	e8 d4 fd ff ff       	call   800e0c <fd2data>
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80103e:	89 f8                	mov    %edi,%eax
  801040:	c1 e8 16             	shr    $0x16,%eax
  801043:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104a:	a8 01                	test   $0x1,%al
  80104c:	74 37                	je     801085 <dup+0x99>
  80104e:	89 f8                	mov    %edi,%eax
  801050:	c1 e8 0c             	shr    $0xc,%eax
  801053:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80105a:	f6 c2 01             	test   $0x1,%dl
  80105d:	74 26                	je     801085 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80105f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	25 07 0e 00 00       	and    $0xe07,%eax
  80106e:	50                   	push   %eax
  80106f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801072:	6a 00                	push   $0x0
  801074:	57                   	push   %edi
  801075:	6a 00                	push   $0x0
  801077:	e8 b3 fb ff ff       	call   800c2f <sys_page_map>
  80107c:	89 c7                	mov    %eax,%edi
  80107e:	83 c4 20             	add    $0x20,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	78 2e                	js     8010b3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801085:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801088:	89 d0                	mov    %edx,%eax
  80108a:	c1 e8 0c             	shr    $0xc,%eax
  80108d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	25 07 0e 00 00       	and    $0xe07,%eax
  80109c:	50                   	push   %eax
  80109d:	53                   	push   %ebx
  80109e:	6a 00                	push   $0x0
  8010a0:	52                   	push   %edx
  8010a1:	6a 00                	push   $0x0
  8010a3:	e8 87 fb ff ff       	call   800c2f <sys_page_map>
  8010a8:	89 c7                	mov    %eax,%edi
  8010aa:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010ad:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010af:	85 ff                	test   %edi,%edi
  8010b1:	79 1d                	jns    8010d0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010b3:	83 ec 08             	sub    $0x8,%esp
  8010b6:	53                   	push   %ebx
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 b3 fb ff ff       	call   800c71 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010be:	83 c4 08             	add    $0x8,%esp
  8010c1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c4:	6a 00                	push   $0x0
  8010c6:	e8 a6 fb ff ff       	call   800c71 <sys_page_unmap>
	return r;
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	89 f8                	mov    %edi,%eax
}
  8010d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	53                   	push   %ebx
  8010dc:	83 ec 14             	sub    $0x14,%esp
  8010df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e5:	50                   	push   %eax
  8010e6:	53                   	push   %ebx
  8010e7:	e8 86 fd ff ff       	call   800e72 <fd_lookup>
  8010ec:	83 c4 08             	add    $0x8,%esp
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 6d                	js     801162 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f5:	83 ec 08             	sub    $0x8,%esp
  8010f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fb:	50                   	push   %eax
  8010fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ff:	ff 30                	pushl  (%eax)
  801101:	e8 c2 fd ff ff       	call   800ec8 <dev_lookup>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	78 4c                	js     801159 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80110d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801110:	8b 42 08             	mov    0x8(%edx),%eax
  801113:	83 e0 03             	and    $0x3,%eax
  801116:	83 f8 01             	cmp    $0x1,%eax
  801119:	75 21                	jne    80113c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111b:	a1 20 60 80 00       	mov    0x806020,%eax
  801120:	8b 40 48             	mov    0x48(%eax),%eax
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	53                   	push   %ebx
  801127:	50                   	push   %eax
  801128:	68 6d 28 80 00       	push   $0x80286d
  80112d:	e8 32 f1 ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80113a:	eb 26                	jmp    801162 <read+0x8a>
	}
	if (!dev->dev_read)
  80113c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113f:	8b 40 08             	mov    0x8(%eax),%eax
  801142:	85 c0                	test   %eax,%eax
  801144:	74 17                	je     80115d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	ff 75 10             	pushl  0x10(%ebp)
  80114c:	ff 75 0c             	pushl  0xc(%ebp)
  80114f:	52                   	push   %edx
  801150:	ff d0                	call   *%eax
  801152:	89 c2                	mov    %eax,%edx
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	eb 09                	jmp    801162 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801159:	89 c2                	mov    %eax,%edx
  80115b:	eb 05                	jmp    801162 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80115d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801162:	89 d0                	mov    %edx,%eax
  801164:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801167:	c9                   	leave  
  801168:	c3                   	ret    

00801169 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	57                   	push   %edi
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	8b 7d 08             	mov    0x8(%ebp),%edi
  801175:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801178:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117d:	eb 21                	jmp    8011a0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80117f:	83 ec 04             	sub    $0x4,%esp
  801182:	89 f0                	mov    %esi,%eax
  801184:	29 d8                	sub    %ebx,%eax
  801186:	50                   	push   %eax
  801187:	89 d8                	mov    %ebx,%eax
  801189:	03 45 0c             	add    0xc(%ebp),%eax
  80118c:	50                   	push   %eax
  80118d:	57                   	push   %edi
  80118e:	e8 45 ff ff ff       	call   8010d8 <read>
		if (m < 0)
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	78 10                	js     8011aa <readn+0x41>
			return m;
		if (m == 0)
  80119a:	85 c0                	test   %eax,%eax
  80119c:	74 0a                	je     8011a8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80119e:	01 c3                	add    %eax,%ebx
  8011a0:	39 f3                	cmp    %esi,%ebx
  8011a2:	72 db                	jb     80117f <readn+0x16>
  8011a4:	89 d8                	mov    %ebx,%eax
  8011a6:	eb 02                	jmp    8011aa <readn+0x41>
  8011a8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    

008011b2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 14             	sub    $0x14,%esp
  8011b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	53                   	push   %ebx
  8011c1:	e8 ac fc ff ff       	call   800e72 <fd_lookup>
  8011c6:	83 c4 08             	add    $0x8,%esp
  8011c9:	89 c2                	mov    %eax,%edx
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 68                	js     801237 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cf:	83 ec 08             	sub    $0x8,%esp
  8011d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d9:	ff 30                	pushl  (%eax)
  8011db:	e8 e8 fc ff ff       	call   800ec8 <dev_lookup>
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	78 47                	js     80122e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ee:	75 21                	jne    801211 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f0:	a1 20 60 80 00       	mov    0x806020,%eax
  8011f5:	8b 40 48             	mov    0x48(%eax),%eax
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	53                   	push   %ebx
  8011fc:	50                   	push   %eax
  8011fd:	68 89 28 80 00       	push   $0x802889
  801202:	e8 5d f0 ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80120f:	eb 26                	jmp    801237 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801211:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801214:	8b 52 0c             	mov    0xc(%edx),%edx
  801217:	85 d2                	test   %edx,%edx
  801219:	74 17                	je     801232 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	ff 75 10             	pushl  0x10(%ebp)
  801221:	ff 75 0c             	pushl  0xc(%ebp)
  801224:	50                   	push   %eax
  801225:	ff d2                	call   *%edx
  801227:	89 c2                	mov    %eax,%edx
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	eb 09                	jmp    801237 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122e:	89 c2                	mov    %eax,%edx
  801230:	eb 05                	jmp    801237 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801232:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801237:	89 d0                	mov    %edx,%eax
  801239:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <seek>:

int
seek(int fdnum, off_t offset)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801244:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	ff 75 08             	pushl  0x8(%ebp)
  80124b:	e8 22 fc ff ff       	call   800e72 <fd_lookup>
  801250:	83 c4 08             	add    $0x8,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 0e                	js     801265 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801257:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80125a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801260:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	53                   	push   %ebx
  80126b:	83 ec 14             	sub    $0x14,%esp
  80126e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801271:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	53                   	push   %ebx
  801276:	e8 f7 fb ff ff       	call   800e72 <fd_lookup>
  80127b:	83 c4 08             	add    $0x8,%esp
  80127e:	89 c2                	mov    %eax,%edx
  801280:	85 c0                	test   %eax,%eax
  801282:	78 65                	js     8012e9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128a:	50                   	push   %eax
  80128b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128e:	ff 30                	pushl  (%eax)
  801290:	e8 33 fc ff ff       	call   800ec8 <dev_lookup>
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 44                	js     8012e0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a3:	75 21                	jne    8012c6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a5:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012aa:	8b 40 48             	mov    0x48(%eax),%eax
  8012ad:	83 ec 04             	sub    $0x4,%esp
  8012b0:	53                   	push   %ebx
  8012b1:	50                   	push   %eax
  8012b2:	68 4c 28 80 00       	push   $0x80284c
  8012b7:	e8 a8 ef ff ff       	call   800264 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012c4:	eb 23                	jmp    8012e9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c9:	8b 52 18             	mov    0x18(%edx),%edx
  8012cc:	85 d2                	test   %edx,%edx
  8012ce:	74 14                	je     8012e4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	ff 75 0c             	pushl  0xc(%ebp)
  8012d6:	50                   	push   %eax
  8012d7:	ff d2                	call   *%edx
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	eb 09                	jmp    8012e9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	eb 05                	jmp    8012e9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012e9:	89 d0                	mov    %edx,%eax
  8012eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 14             	sub    $0x14,%esp
  8012f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fd:	50                   	push   %eax
  8012fe:	ff 75 08             	pushl  0x8(%ebp)
  801301:	e8 6c fb ff ff       	call   800e72 <fd_lookup>
  801306:	83 c4 08             	add    $0x8,%esp
  801309:	89 c2                	mov    %eax,%edx
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 58                	js     801367 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801315:	50                   	push   %eax
  801316:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801319:	ff 30                	pushl  (%eax)
  80131b:	e8 a8 fb ff ff       	call   800ec8 <dev_lookup>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 37                	js     80135e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80132e:	74 32                	je     801362 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801330:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801333:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133a:	00 00 00 
	stat->st_isdir = 0;
  80133d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801344:	00 00 00 
	stat->st_dev = dev;
  801347:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	53                   	push   %ebx
  801351:	ff 75 f0             	pushl  -0x10(%ebp)
  801354:	ff 50 14             	call   *0x14(%eax)
  801357:	89 c2                	mov    %eax,%edx
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	eb 09                	jmp    801367 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135e:	89 c2                	mov    %eax,%edx
  801360:	eb 05                	jmp    801367 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801362:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801367:	89 d0                	mov    %edx,%eax
  801369:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	56                   	push   %esi
  801372:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	6a 00                	push   $0x0
  801378:	ff 75 08             	pushl  0x8(%ebp)
  80137b:	e8 e3 01 00 00       	call   801563 <open>
  801380:	89 c3                	mov    %eax,%ebx
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 1b                	js     8013a4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	ff 75 0c             	pushl  0xc(%ebp)
  80138f:	50                   	push   %eax
  801390:	e8 5b ff ff ff       	call   8012f0 <fstat>
  801395:	89 c6                	mov    %eax,%esi
	close(fd);
  801397:	89 1c 24             	mov    %ebx,(%esp)
  80139a:	e8 fd fb ff ff       	call   800f9c <close>
	return r;
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	89 f0                	mov    %esi,%eax
}
  8013a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	56                   	push   %esi
  8013af:	53                   	push   %ebx
  8013b0:	89 c6                	mov    %eax,%esi
  8013b2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013bb:	75 12                	jne    8013cf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013bd:	83 ec 0c             	sub    $0xc,%esp
  8013c0:	6a 01                	push   $0x1
  8013c2:	e8 97 0d 00 00       	call   80215e <ipc_find_env>
  8013c7:	a3 00 40 80 00       	mov    %eax,0x804000
  8013cc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013cf:	6a 07                	push   $0x7
  8013d1:	68 00 70 80 00       	push   $0x807000
  8013d6:	56                   	push   %esi
  8013d7:	ff 35 00 40 80 00    	pushl  0x804000
  8013dd:	e8 f0 0c 00 00       	call   8020d2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e2:	83 c4 0c             	add    $0xc,%esp
  8013e5:	6a 00                	push   $0x0
  8013e7:	53                   	push   %ebx
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 6e 0c 00 00       	call   80205d <ipc_recv>
}
  8013ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801402:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801407:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140a:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80140f:	ba 00 00 00 00       	mov    $0x0,%edx
  801414:	b8 02 00 00 00       	mov    $0x2,%eax
  801419:	e8 8d ff ff ff       	call   8013ab <fsipc>
}
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
  801429:	8b 40 0c             	mov    0xc(%eax),%eax
  80142c:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801431:	ba 00 00 00 00       	mov    $0x0,%edx
  801436:	b8 06 00 00 00       	mov    $0x6,%eax
  80143b:	e8 6b ff ff ff       	call   8013ab <fsipc>
}
  801440:	c9                   	leave  
  801441:	c3                   	ret    

00801442 <devfile_stat>:
                return ((ssize_t)r);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	53                   	push   %ebx
  801446:	83 ec 04             	sub    $0x4,%esp
  801449:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	8b 40 0c             	mov    0xc(%eax),%eax
  801452:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801457:	ba 00 00 00 00       	mov    $0x0,%edx
  80145c:	b8 05 00 00 00       	mov    $0x5,%eax
  801461:	e8 45 ff ff ff       	call   8013ab <fsipc>
  801466:	85 c0                	test   %eax,%eax
  801468:	78 2c                	js     801496 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	68 00 70 80 00       	push   $0x807000
  801472:	53                   	push   %ebx
  801473:	e8 71 f3 ff ff       	call   8007e9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801478:	a1 80 70 80 00       	mov    0x807080,%eax
  80147d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801483:	a1 84 70 80 00       	mov    0x807084,%eax
  801488:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801496:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	83 ec 0c             	sub    $0xc,%esp
  8014a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8014a4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014a9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014ae:	0f 47 c2             	cmova  %edx,%eax
	int r;
	if(n > (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t))))
	{
		n = (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t)));
	}
		fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b7:	89 15 00 70 80 00    	mov    %edx,0x807000
		fsipcbuf.write.req_n = n;
  8014bd:	a3 04 70 80 00       	mov    %eax,0x807004
		memmove((void *)fsipcbuf.write.req_buf, buf, n);
  8014c2:	50                   	push   %eax
  8014c3:	ff 75 0c             	pushl  0xc(%ebp)
  8014c6:	68 08 70 80 00       	push   $0x807008
  8014cb:	e8 ab f4 ff ff       	call   80097b <memmove>
		r = fsipc(FSREQ_WRITE, NULL);
  8014d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d5:	b8 04 00 00 00       	mov    $0x4,%eax
  8014da:	e8 cc fe ff ff       	call   8013ab <fsipc>
                return ((ssize_t)r);
}
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	56                   	push   %esi
  8014e5:	53                   	push   %ebx
  8014e6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ef:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8014f4:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801504:	e8 a2 fe ff ff       	call   8013ab <fsipc>
  801509:	89 c3                	mov    %eax,%ebx
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 4b                	js     80155a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80150f:	39 c6                	cmp    %eax,%esi
  801511:	73 16                	jae    801529 <devfile_read+0x48>
  801513:	68 bc 28 80 00       	push   $0x8028bc
  801518:	68 c3 28 80 00       	push   $0x8028c3
  80151d:	6a 7c                	push   $0x7c
  80151f:	68 d8 28 80 00       	push   $0x8028d8
  801524:	e8 62 ec ff ff       	call   80018b <_panic>
	assert(r <= PGSIZE);
  801529:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80152e:	7e 16                	jle    801546 <devfile_read+0x65>
  801530:	68 e3 28 80 00       	push   $0x8028e3
  801535:	68 c3 28 80 00       	push   $0x8028c3
  80153a:	6a 7d                	push   $0x7d
  80153c:	68 d8 28 80 00       	push   $0x8028d8
  801541:	e8 45 ec ff ff       	call   80018b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801546:	83 ec 04             	sub    $0x4,%esp
  801549:	50                   	push   %eax
  80154a:	68 00 70 80 00       	push   $0x807000
  80154f:	ff 75 0c             	pushl  0xc(%ebp)
  801552:	e8 24 f4 ff ff       	call   80097b <memmove>
	return r;
  801557:	83 c4 10             	add    $0x10,%esp
}
  80155a:	89 d8                	mov    %ebx,%eax
  80155c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    

00801563 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 20             	sub    $0x20,%esp
  80156a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80156d:	53                   	push   %ebx
  80156e:	e8 3d f2 ff ff       	call   8007b0 <strlen>
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80157b:	7f 67                	jg     8015e4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80157d:	83 ec 0c             	sub    $0xc,%esp
  801580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	e8 9a f8 ff ff       	call   800e23 <fd_alloc>
  801589:	83 c4 10             	add    $0x10,%esp
		return r;
  80158c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 57                	js     8015e9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	53                   	push   %ebx
  801596:	68 00 70 80 00       	push   $0x807000
  80159b:	e8 49 f2 ff ff       	call   8007e9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a3:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b0:	e8 f6 fd ff ff       	call   8013ab <fsipc>
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	79 14                	jns    8015d2 <open+0x6f>
		fd_close(fd, 0);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	6a 00                	push   $0x0
  8015c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c6:	e8 50 f9 ff ff       	call   800f1b <fd_close>
		return r;
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	89 da                	mov    %ebx,%edx
  8015d0:	eb 17                	jmp    8015e9 <open+0x86>
	}

	return fd2num(fd);
  8015d2:	83 ec 0c             	sub    $0xc,%esp
  8015d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d8:	e8 1f f8 ff ff       	call   800dfc <fd2num>
  8015dd:	89 c2                	mov    %eax,%edx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	eb 05                	jmp    8015e9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015e4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015e9:	89 d0                	mov    %edx,%eax
  8015eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801600:	e8 a6 fd ff ff       	call   8013ab <fsipc>
}
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801607:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80160b:	7e 37                	jle    801644 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	53                   	push   %ebx
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801616:	ff 70 04             	pushl  0x4(%eax)
  801619:	8d 40 10             	lea    0x10(%eax),%eax
  80161c:	50                   	push   %eax
  80161d:	ff 33                	pushl  (%ebx)
  80161f:	e8 8e fb ff ff       	call   8011b2 <write>
		if (result > 0)
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	7e 03                	jle    80162e <writebuf+0x27>
			b->result += result;
  80162b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80162e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801631:	74 0d                	je     801640 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801633:	85 c0                	test   %eax,%eax
  801635:	ba 00 00 00 00       	mov    $0x0,%edx
  80163a:	0f 4f c2             	cmovg  %edx,%eax
  80163d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801643:	c9                   	leave  
  801644:	f3 c3                	repz ret 

00801646 <putch>:

static void
putch(int ch, void *thunk)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 04             	sub    $0x4,%esp
  80164d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801650:	8b 53 04             	mov    0x4(%ebx),%edx
  801653:	8d 42 01             	lea    0x1(%edx),%eax
  801656:	89 43 04             	mov    %eax,0x4(%ebx)
  801659:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80165c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801660:	3d 00 01 00 00       	cmp    $0x100,%eax
  801665:	75 0e                	jne    801675 <putch+0x2f>
		writebuf(b);
  801667:	89 d8                	mov    %ebx,%eax
  801669:	e8 99 ff ff ff       	call   801607 <writebuf>
		b->idx = 0;
  80166e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801675:	83 c4 04             	add    $0x4,%esp
  801678:	5b                   	pop    %ebx
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801684:	8b 45 08             	mov    0x8(%ebp),%eax
  801687:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80168d:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801694:	00 00 00 
	b.result = 0;
  801697:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80169e:	00 00 00 
	b.error = 1;
  8016a1:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016a8:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016ab:	ff 75 10             	pushl  0x10(%ebp)
  8016ae:	ff 75 0c             	pushl  0xc(%ebp)
  8016b1:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	68 46 16 80 00       	push   $0x801646
  8016bd:	e8 d9 ec ff ff       	call   80039b <vprintfmt>
	if (b.idx > 0)
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016cc:	7e 0b                	jle    8016d9 <vfprintf+0x5e>
		writebuf(&b);
  8016ce:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016d4:	e8 2e ff ff ff       	call   801607 <writebuf>

	return (b.result ? b.result : b.error);
  8016d9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016f0:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8016f3:	50                   	push   %eax
  8016f4:	ff 75 0c             	pushl  0xc(%ebp)
  8016f7:	ff 75 08             	pushl  0x8(%ebp)
  8016fa:	e8 7c ff ff ff       	call   80167b <vfprintf>
	va_end(ap);

	return cnt;
}
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <printf>:

int
printf(const char *fmt, ...)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801707:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80170a:	50                   	push   %eax
  80170b:	ff 75 08             	pushl  0x8(%ebp)
  80170e:	6a 01                	push   $0x1
  801710:	e8 66 ff ff ff       	call   80167b <vfprintf>
	va_end(ap);

	return cnt;
}
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80171d:	68 ef 28 80 00       	push   $0x8028ef
  801722:	ff 75 0c             	pushl  0xc(%ebp)
  801725:	e8 bf f0 ff ff       	call   8007e9 <strcpy>
	return 0;
}
  80172a:	b8 00 00 00 00       	mov    $0x0,%eax
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	53                   	push   %ebx
  801735:	83 ec 10             	sub    $0x10,%esp
  801738:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80173b:	53                   	push   %ebx
  80173c:	e8 56 0a 00 00       	call   802197 <pageref>
  801741:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801744:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801749:	83 f8 01             	cmp    $0x1,%eax
  80174c:	75 10                	jne    80175e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80174e:	83 ec 0c             	sub    $0xc,%esp
  801751:	ff 73 0c             	pushl  0xc(%ebx)
  801754:	e8 c0 02 00 00       	call   801a19 <nsipc_close>
  801759:	89 c2                	mov    %eax,%edx
  80175b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80175e:	89 d0                	mov    %edx,%eax
  801760:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801763:	c9                   	leave  
  801764:	c3                   	ret    

00801765 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80176b:	6a 00                	push   $0x0
  80176d:	ff 75 10             	pushl  0x10(%ebp)
  801770:	ff 75 0c             	pushl  0xc(%ebp)
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	ff 70 0c             	pushl  0xc(%eax)
  801779:	e8 78 03 00 00       	call   801af6 <nsipc_send>
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801786:	6a 00                	push   $0x0
  801788:	ff 75 10             	pushl  0x10(%ebp)
  80178b:	ff 75 0c             	pushl  0xc(%ebp)
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	ff 70 0c             	pushl  0xc(%eax)
  801794:	e8 f1 02 00 00       	call   801a8a <nsipc_recv>
}
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017a1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017a4:	52                   	push   %edx
  8017a5:	50                   	push   %eax
  8017a6:	e8 c7 f6 ff ff       	call   800e72 <fd_lookup>
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 17                	js     8017c9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8017b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8017bb:	39 08                	cmp    %ecx,(%eax)
  8017bd:	75 05                	jne    8017c4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8017bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c2:	eb 05                	jmp    8017c9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8017c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8017c9:	c9                   	leave  
  8017ca:	c3                   	ret    

008017cb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	56                   	push   %esi
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 1c             	sub    $0x1c,%esp
  8017d3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8017d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d8:	50                   	push   %eax
  8017d9:	e8 45 f6 ff ff       	call   800e23 <fd_alloc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 1b                	js     801802 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	68 07 04 00 00       	push   $0x407
  8017ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f2:	6a 00                	push   $0x0
  8017f4:	e8 f3 f3 ff ff       	call   800bec <sys_page_alloc>
  8017f9:	89 c3                	mov    %eax,%ebx
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	85 c0                	test   %eax,%eax
  801800:	79 10                	jns    801812 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	56                   	push   %esi
  801806:	e8 0e 02 00 00       	call   801a19 <nsipc_close>
		return r;
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	89 d8                	mov    %ebx,%eax
  801810:	eb 24                	jmp    801836 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801812:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801818:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80181d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801820:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801827:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	50                   	push   %eax
  80182e:	e8 c9 f5 ff ff       	call   800dfc <fd2num>
  801833:	83 c4 10             	add    $0x10,%esp
}
  801836:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    

0080183d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	e8 50 ff ff ff       	call   80179b <fd2sockid>
		return r;
  80184b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 1f                	js     801870 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	ff 75 10             	pushl  0x10(%ebp)
  801857:	ff 75 0c             	pushl  0xc(%ebp)
  80185a:	50                   	push   %eax
  80185b:	e8 12 01 00 00       	call   801972 <nsipc_accept>
  801860:	83 c4 10             	add    $0x10,%esp
		return r;
  801863:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801865:	85 c0                	test   %eax,%eax
  801867:	78 07                	js     801870 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801869:	e8 5d ff ff ff       	call   8017cb <alloc_sockfd>
  80186e:	89 c1                	mov    %eax,%ecx
}
  801870:	89 c8                	mov    %ecx,%eax
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	e8 19 ff ff ff       	call   80179b <fd2sockid>
  801882:	85 c0                	test   %eax,%eax
  801884:	78 12                	js     801898 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	ff 75 10             	pushl  0x10(%ebp)
  80188c:	ff 75 0c             	pushl  0xc(%ebp)
  80188f:	50                   	push   %eax
  801890:	e8 2d 01 00 00       	call   8019c2 <nsipc_bind>
  801895:	83 c4 10             	add    $0x10,%esp
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <shutdown>:

int
shutdown(int s, int how)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	e8 f3 fe ff ff       	call   80179b <fd2sockid>
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 0f                	js     8018bb <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8018ac:	83 ec 08             	sub    $0x8,%esp
  8018af:	ff 75 0c             	pushl  0xc(%ebp)
  8018b2:	50                   	push   %eax
  8018b3:	e8 3f 01 00 00       	call   8019f7 <nsipc_shutdown>
  8018b8:	83 c4 10             	add    $0x10,%esp
}
  8018bb:	c9                   	leave  
  8018bc:	c3                   	ret    

008018bd <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	e8 d0 fe ff ff       	call   80179b <fd2sockid>
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 12                	js     8018e1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8018cf:	83 ec 04             	sub    $0x4,%esp
  8018d2:	ff 75 10             	pushl  0x10(%ebp)
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	50                   	push   %eax
  8018d9:	e8 55 01 00 00       	call   801a33 <nsipc_connect>
  8018de:	83 c4 10             	add    $0x10,%esp
}
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <listen>:

int
listen(int s, int backlog)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8018e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ec:	e8 aa fe ff ff       	call   80179b <fd2sockid>
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 0f                	js     801904 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8018f5:	83 ec 08             	sub    $0x8,%esp
  8018f8:	ff 75 0c             	pushl  0xc(%ebp)
  8018fb:	50                   	push   %eax
  8018fc:	e8 67 01 00 00       	call   801a68 <nsipc_listen>
  801901:	83 c4 10             	add    $0x10,%esp
}
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80190c:	ff 75 10             	pushl  0x10(%ebp)
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	ff 75 08             	pushl  0x8(%ebp)
  801915:	e8 3a 02 00 00       	call   801b54 <nsipc_socket>
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 05                	js     801926 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801921:	e8 a5 fe ff ff       	call   8017cb <alloc_sockfd>
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	53                   	push   %ebx
  80192c:	83 ec 04             	sub    $0x4,%esp
  80192f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801931:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801938:	75 12                	jne    80194c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	6a 02                	push   $0x2
  80193f:	e8 1a 08 00 00       	call   80215e <ipc_find_env>
  801944:	a3 04 40 80 00       	mov    %eax,0x804004
  801949:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80194c:	6a 07                	push   $0x7
  80194e:	68 00 80 80 00       	push   $0x808000
  801953:	53                   	push   %ebx
  801954:	ff 35 04 40 80 00    	pushl  0x804004
  80195a:	e8 73 07 00 00       	call   8020d2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80195f:	83 c4 0c             	add    $0xc,%esp
  801962:	6a 00                	push   $0x0
  801964:	6a 00                	push   $0x0
  801966:	6a 00                	push   $0x0
  801968:	e8 f0 06 00 00       	call   80205d <ipc_recv>
}
  80196d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	56                   	push   %esi
  801976:	53                   	push   %ebx
  801977:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801982:	8b 06                	mov    (%esi),%eax
  801984:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801989:	b8 01 00 00 00       	mov    $0x1,%eax
  80198e:	e8 95 ff ff ff       	call   801928 <nsipc>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	85 c0                	test   %eax,%eax
  801997:	78 20                	js     8019b9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801999:	83 ec 04             	sub    $0x4,%esp
  80199c:	ff 35 10 80 80 00    	pushl  0x808010
  8019a2:	68 00 80 80 00       	push   $0x808000
  8019a7:	ff 75 0c             	pushl  0xc(%ebp)
  8019aa:	e8 cc ef ff ff       	call   80097b <memmove>
		*addrlen = ret->ret_addrlen;
  8019af:	a1 10 80 80 00       	mov    0x808010,%eax
  8019b4:	89 06                	mov    %eax,(%esi)
  8019b6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8019b9:	89 d8                	mov    %ebx,%eax
  8019bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5e                   	pop    %esi
  8019c0:	5d                   	pop    %ebp
  8019c1:	c3                   	ret    

008019c2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 08             	sub    $0x8,%esp
  8019c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cf:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019d4:	53                   	push   %ebx
  8019d5:	ff 75 0c             	pushl  0xc(%ebp)
  8019d8:	68 04 80 80 00       	push   $0x808004
  8019dd:	e8 99 ef ff ff       	call   80097b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019e2:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  8019e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ed:	e8 36 ff ff ff       	call   801928 <nsipc>
}
  8019f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801a00:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a08:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801a0d:	b8 03 00 00 00       	mov    $0x3,%eax
  801a12:	e8 11 ff ff ff       	call   801928 <nsipc>
}
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <nsipc_close>:

int
nsipc_close(int s)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a22:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801a27:	b8 04 00 00 00       	mov    $0x4,%eax
  801a2c:	e8 f7 fe ff ff       	call   801928 <nsipc>
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	53                   	push   %ebx
  801a37:	83 ec 08             	sub    $0x8,%esp
  801a3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a40:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a45:	53                   	push   %ebx
  801a46:	ff 75 0c             	pushl  0xc(%ebp)
  801a49:	68 04 80 80 00       	push   $0x808004
  801a4e:	e8 28 ef ff ff       	call   80097b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a53:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801a59:	b8 05 00 00 00       	mov    $0x5,%eax
  801a5e:	e8 c5 fe ff ff       	call   801928 <nsipc>
}
  801a63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    

00801a68 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a79:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801a7e:	b8 06 00 00 00       	mov    $0x6,%eax
  801a83:	e8 a0 fe ff ff       	call   801928 <nsipc>
}
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801a9a:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa3:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801aa8:	b8 07 00 00 00       	mov    $0x7,%eax
  801aad:	e8 76 fe ff ff       	call   801928 <nsipc>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	78 35                	js     801aed <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ab8:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801abd:	7f 04                	jg     801ac3 <nsipc_recv+0x39>
  801abf:	39 c6                	cmp    %eax,%esi
  801ac1:	7d 16                	jge    801ad9 <nsipc_recv+0x4f>
  801ac3:	68 fb 28 80 00       	push   $0x8028fb
  801ac8:	68 c3 28 80 00       	push   $0x8028c3
  801acd:	6a 62                	push   $0x62
  801acf:	68 10 29 80 00       	push   $0x802910
  801ad4:	e8 b2 e6 ff ff       	call   80018b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ad9:	83 ec 04             	sub    $0x4,%esp
  801adc:	50                   	push   %eax
  801add:	68 00 80 80 00       	push   $0x808000
  801ae2:	ff 75 0c             	pushl  0xc(%ebp)
  801ae5:	e8 91 ee ff ff       	call   80097b <memmove>
  801aea:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801aed:	89 d8                	mov    %ebx,%eax
  801aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	53                   	push   %ebx
  801afa:	83 ec 04             	sub    $0x4,%esp
  801afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b00:	8b 45 08             	mov    0x8(%ebp),%eax
  801b03:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801b08:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b0e:	7e 16                	jle    801b26 <nsipc_send+0x30>
  801b10:	68 1c 29 80 00       	push   $0x80291c
  801b15:	68 c3 28 80 00       	push   $0x8028c3
  801b1a:	6a 6d                	push   $0x6d
  801b1c:	68 10 29 80 00       	push   $0x802910
  801b21:	e8 65 e6 ff ff       	call   80018b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b26:	83 ec 04             	sub    $0x4,%esp
  801b29:	53                   	push   %ebx
  801b2a:	ff 75 0c             	pushl  0xc(%ebp)
  801b2d:	68 0c 80 80 00       	push   $0x80800c
  801b32:	e8 44 ee ff ff       	call   80097b <memmove>
	nsipcbuf.send.req_size = size;
  801b37:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801b3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801b40:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801b45:	b8 08 00 00 00       	mov    $0x8,%eax
  801b4a:	e8 d9 fd ff ff       	call   801928 <nsipc>
}
  801b4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b65:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801b6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6d:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801b72:	b8 09 00 00 00       	mov    $0x9,%eax
  801b77:	e8 ac fd ff ff       	call   801928 <nsipc>
}
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	56                   	push   %esi
  801b82:	53                   	push   %ebx
  801b83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	ff 75 08             	pushl  0x8(%ebp)
  801b8c:	e8 7b f2 ff ff       	call   800e0c <fd2data>
  801b91:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b93:	83 c4 08             	add    $0x8,%esp
  801b96:	68 28 29 80 00       	push   $0x802928
  801b9b:	53                   	push   %ebx
  801b9c:	e8 48 ec ff ff       	call   8007e9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ba1:	8b 46 04             	mov    0x4(%esi),%eax
  801ba4:	2b 06                	sub    (%esi),%eax
  801ba6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bb3:	00 00 00 
	stat->st_dev = &devpipe;
  801bb6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801bbd:	30 80 00 
	return 0;
}
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	53                   	push   %ebx
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bd6:	53                   	push   %ebx
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 93 f0 ff ff       	call   800c71 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bde:	89 1c 24             	mov    %ebx,(%esp)
  801be1:	e8 26 f2 ff ff       	call   800e0c <fd2data>
  801be6:	83 c4 08             	add    $0x8,%esp
  801be9:	50                   	push   %eax
  801bea:	6a 00                	push   $0x0
  801bec:	e8 80 f0 ff ff       	call   800c71 <sys_page_unmap>
}
  801bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	57                   	push   %edi
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	83 ec 1c             	sub    $0x1c,%esp
  801bff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c02:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c04:	a1 20 60 80 00       	mov    0x806020,%eax
  801c09:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	ff 75 e0             	pushl  -0x20(%ebp)
  801c12:	e8 80 05 00 00       	call   802197 <pageref>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	89 3c 24             	mov    %edi,(%esp)
  801c1c:	e8 76 05 00 00       	call   802197 <pageref>
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	39 c3                	cmp    %eax,%ebx
  801c26:	0f 94 c1             	sete   %cl
  801c29:	0f b6 c9             	movzbl %cl,%ecx
  801c2c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c2f:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801c35:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c38:	39 ce                	cmp    %ecx,%esi
  801c3a:	74 1b                	je     801c57 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c3c:	39 c3                	cmp    %eax,%ebx
  801c3e:	75 c4                	jne    801c04 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c40:	8b 42 58             	mov    0x58(%edx),%eax
  801c43:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c46:	50                   	push   %eax
  801c47:	56                   	push   %esi
  801c48:	68 2f 29 80 00       	push   $0x80292f
  801c4d:	e8 12 e6 ff ff       	call   800264 <cprintf>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	eb ad                	jmp    801c04 <_pipeisclosed+0xe>
	}
}
  801c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 28             	sub    $0x28,%esp
  801c6b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c6e:	56                   	push   %esi
  801c6f:	e8 98 f1 ff ff       	call   800e0c <fd2data>
  801c74:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	bf 00 00 00 00       	mov    $0x0,%edi
  801c7e:	eb 4b                	jmp    801ccb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c80:	89 da                	mov    %ebx,%edx
  801c82:	89 f0                	mov    %esi,%eax
  801c84:	e8 6d ff ff ff       	call   801bf6 <_pipeisclosed>
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	75 48                	jne    801cd5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c8d:	e8 3b ef ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c92:	8b 43 04             	mov    0x4(%ebx),%eax
  801c95:	8b 0b                	mov    (%ebx),%ecx
  801c97:	8d 51 20             	lea    0x20(%ecx),%edx
  801c9a:	39 d0                	cmp    %edx,%eax
  801c9c:	73 e2                	jae    801c80 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ca5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ca8:	89 c2                	mov    %eax,%edx
  801caa:	c1 fa 1f             	sar    $0x1f,%edx
  801cad:	89 d1                	mov    %edx,%ecx
  801caf:	c1 e9 1b             	shr    $0x1b,%ecx
  801cb2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cb5:	83 e2 1f             	and    $0x1f,%edx
  801cb8:	29 ca                	sub    %ecx,%edx
  801cba:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cbe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cc2:	83 c0 01             	add    $0x1,%eax
  801cc5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc8:	83 c7 01             	add    $0x1,%edi
  801ccb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cce:	75 c2                	jne    801c92 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cd0:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd3:	eb 05                	jmp    801cda <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	57                   	push   %edi
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 18             	sub    $0x18,%esp
  801ceb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cee:	57                   	push   %edi
  801cef:	e8 18 f1 ff ff       	call   800e0c <fd2data>
  801cf4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cfe:	eb 3d                	jmp    801d3d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d00:	85 db                	test   %ebx,%ebx
  801d02:	74 04                	je     801d08 <devpipe_read+0x26>
				return i;
  801d04:	89 d8                	mov    %ebx,%eax
  801d06:	eb 44                	jmp    801d4c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d08:	89 f2                	mov    %esi,%edx
  801d0a:	89 f8                	mov    %edi,%eax
  801d0c:	e8 e5 fe ff ff       	call   801bf6 <_pipeisclosed>
  801d11:	85 c0                	test   %eax,%eax
  801d13:	75 32                	jne    801d47 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d15:	e8 b3 ee ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d1a:	8b 06                	mov    (%esi),%eax
  801d1c:	3b 46 04             	cmp    0x4(%esi),%eax
  801d1f:	74 df                	je     801d00 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d21:	99                   	cltd   
  801d22:	c1 ea 1b             	shr    $0x1b,%edx
  801d25:	01 d0                	add    %edx,%eax
  801d27:	83 e0 1f             	and    $0x1f,%eax
  801d2a:	29 d0                	sub    %edx,%eax
  801d2c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d34:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d37:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d3a:	83 c3 01             	add    $0x1,%ebx
  801d3d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d40:	75 d8                	jne    801d1a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d42:	8b 45 10             	mov    0x10(%ebp),%eax
  801d45:	eb 05                	jmp    801d4c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5f                   	pop    %edi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	56                   	push   %esi
  801d58:	53                   	push   %ebx
  801d59:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5f:	50                   	push   %eax
  801d60:	e8 be f0 ff ff       	call   800e23 <fd_alloc>
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	89 c2                	mov    %eax,%edx
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	0f 88 2c 01 00 00    	js     801e9e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d72:	83 ec 04             	sub    $0x4,%esp
  801d75:	68 07 04 00 00       	push   $0x407
  801d7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 68 ee ff ff       	call   800bec <sys_page_alloc>
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	89 c2                	mov    %eax,%edx
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	0f 88 0d 01 00 00    	js     801e9e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d91:	83 ec 0c             	sub    $0xc,%esp
  801d94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d97:	50                   	push   %eax
  801d98:	e8 86 f0 ff ff       	call   800e23 <fd_alloc>
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	83 c4 10             	add    $0x10,%esp
  801da2:	85 c0                	test   %eax,%eax
  801da4:	0f 88 e2 00 00 00    	js     801e8c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801daa:	83 ec 04             	sub    $0x4,%esp
  801dad:	68 07 04 00 00       	push   $0x407
  801db2:	ff 75 f0             	pushl  -0x10(%ebp)
  801db5:	6a 00                	push   $0x0
  801db7:	e8 30 ee ff ff       	call   800bec <sys_page_alloc>
  801dbc:	89 c3                	mov    %eax,%ebx
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	0f 88 c3 00 00 00    	js     801e8c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dc9:	83 ec 0c             	sub    $0xc,%esp
  801dcc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcf:	e8 38 f0 ff ff       	call   800e0c <fd2data>
  801dd4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd6:	83 c4 0c             	add    $0xc,%esp
  801dd9:	68 07 04 00 00       	push   $0x407
  801dde:	50                   	push   %eax
  801ddf:	6a 00                	push   $0x0
  801de1:	e8 06 ee ff ff       	call   800bec <sys_page_alloc>
  801de6:	89 c3                	mov    %eax,%ebx
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	85 c0                	test   %eax,%eax
  801ded:	0f 88 89 00 00 00    	js     801e7c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	ff 75 f0             	pushl  -0x10(%ebp)
  801df9:	e8 0e f0 ff ff       	call   800e0c <fd2data>
  801dfe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e05:	50                   	push   %eax
  801e06:	6a 00                	push   $0x0
  801e08:	56                   	push   %esi
  801e09:	6a 00                	push   $0x0
  801e0b:	e8 1f ee ff ff       	call   800c2f <sys_page_map>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	83 c4 20             	add    $0x20,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 55                	js     801e6e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e19:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e22:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e27:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e37:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e43:	83 ec 0c             	sub    $0xc,%esp
  801e46:	ff 75 f4             	pushl  -0xc(%ebp)
  801e49:	e8 ae ef ff ff       	call   800dfc <fd2num>
  801e4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e51:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e53:	83 c4 04             	add    $0x4,%esp
  801e56:	ff 75 f0             	pushl  -0x10(%ebp)
  801e59:	e8 9e ef ff ff       	call   800dfc <fd2num>
  801e5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e61:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	ba 00 00 00 00       	mov    $0x0,%edx
  801e6c:	eb 30                	jmp    801e9e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e6e:	83 ec 08             	sub    $0x8,%esp
  801e71:	56                   	push   %esi
  801e72:	6a 00                	push   $0x0
  801e74:	e8 f8 ed ff ff       	call   800c71 <sys_page_unmap>
  801e79:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e7c:	83 ec 08             	sub    $0x8,%esp
  801e7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e82:	6a 00                	push   $0x0
  801e84:	e8 e8 ed ff ff       	call   800c71 <sys_page_unmap>
  801e89:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e8c:	83 ec 08             	sub    $0x8,%esp
  801e8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e92:	6a 00                	push   $0x0
  801e94:	e8 d8 ed ff ff       	call   800c71 <sys_page_unmap>
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e9e:	89 d0                	mov    %edx,%eax
  801ea0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ead:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb0:	50                   	push   %eax
  801eb1:	ff 75 08             	pushl  0x8(%ebp)
  801eb4:	e8 b9 ef ff ff       	call   800e72 <fd_lookup>
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 18                	js     801ed8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ec0:	83 ec 0c             	sub    $0xc,%esp
  801ec3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec6:	e8 41 ef ff ff       	call   800e0c <fd2data>
	return _pipeisclosed(fd, p);
  801ecb:	89 c2                	mov    %eax,%edx
  801ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed0:	e8 21 fd ff ff       	call   801bf6 <_pipeisclosed>
  801ed5:	83 c4 10             	add    $0x10,%esp
}
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801edd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    

00801ee4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eea:	68 47 29 80 00       	push   $0x802947
  801eef:	ff 75 0c             	pushl  0xc(%ebp)
  801ef2:	e8 f2 e8 ff ff       	call   8007e9 <strcpy>
	return 0;
}
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f0a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f0f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f15:	eb 2d                	jmp    801f44 <devcons_write+0x46>
		m = n - tot;
  801f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f1a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f1c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f1f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f24:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f27:	83 ec 04             	sub    $0x4,%esp
  801f2a:	53                   	push   %ebx
  801f2b:	03 45 0c             	add    0xc(%ebp),%eax
  801f2e:	50                   	push   %eax
  801f2f:	57                   	push   %edi
  801f30:	e8 46 ea ff ff       	call   80097b <memmove>
		sys_cputs(buf, m);
  801f35:	83 c4 08             	add    $0x8,%esp
  801f38:	53                   	push   %ebx
  801f39:	57                   	push   %edi
  801f3a:	e8 f1 eb ff ff       	call   800b30 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f3f:	01 de                	add    %ebx,%esi
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	89 f0                	mov    %esi,%eax
  801f46:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f49:	72 cc                	jb     801f17 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5e                   	pop    %esi
  801f50:	5f                   	pop    %edi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	83 ec 08             	sub    $0x8,%esp
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f62:	74 2a                	je     801f8e <devcons_read+0x3b>
  801f64:	eb 05                	jmp    801f6b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f66:	e8 62 ec ff ff       	call   800bcd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f6b:	e8 de eb ff ff       	call   800b4e <sys_cgetc>
  801f70:	85 c0                	test   %eax,%eax
  801f72:	74 f2                	je     801f66 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f74:	85 c0                	test   %eax,%eax
  801f76:	78 16                	js     801f8e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f78:	83 f8 04             	cmp    $0x4,%eax
  801f7b:	74 0c                	je     801f89 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f80:	88 02                	mov    %al,(%edx)
	return 1;
  801f82:	b8 01 00 00 00       	mov    $0x1,%eax
  801f87:	eb 05                	jmp    801f8e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f8e:	c9                   	leave  
  801f8f:	c3                   	ret    

00801f90 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f96:	8b 45 08             	mov    0x8(%ebp),%eax
  801f99:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f9c:	6a 01                	push   $0x1
  801f9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa1:	50                   	push   %eax
  801fa2:	e8 89 eb ff ff       	call   800b30 <sys_cputs>
}
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <getchar>:

int
getchar(void)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fb2:	6a 01                	push   $0x1
  801fb4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fb7:	50                   	push   %eax
  801fb8:	6a 00                	push   $0x0
  801fba:	e8 19 f1 ff ff       	call   8010d8 <read>
	if (r < 0)
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	78 0f                	js     801fd5 <getchar+0x29>
		return r;
	if (r < 1)
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	7e 06                	jle    801fd0 <getchar+0x24>
		return -E_EOF;
	return c;
  801fca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fce:	eb 05                	jmp    801fd5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fd0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe0:	50                   	push   %eax
  801fe1:	ff 75 08             	pushl  0x8(%ebp)
  801fe4:	e8 89 ee ff ff       	call   800e72 <fd_lookup>
  801fe9:	83 c4 10             	add    $0x10,%esp
  801fec:	85 c0                	test   %eax,%eax
  801fee:	78 11                	js     802001 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ff9:	39 10                	cmp    %edx,(%eax)
  801ffb:	0f 94 c0             	sete   %al
  801ffe:	0f b6 c0             	movzbl %al,%eax
}
  802001:	c9                   	leave  
  802002:	c3                   	ret    

00802003 <opencons>:

int
opencons(void)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802009:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200c:	50                   	push   %eax
  80200d:	e8 11 ee ff ff       	call   800e23 <fd_alloc>
  802012:	83 c4 10             	add    $0x10,%esp
		return r;
  802015:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802017:	85 c0                	test   %eax,%eax
  802019:	78 3e                	js     802059 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80201b:	83 ec 04             	sub    $0x4,%esp
  80201e:	68 07 04 00 00       	push   $0x407
  802023:	ff 75 f4             	pushl  -0xc(%ebp)
  802026:	6a 00                	push   $0x0
  802028:	e8 bf eb ff ff       	call   800bec <sys_page_alloc>
  80202d:	83 c4 10             	add    $0x10,%esp
		return r;
  802030:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802032:	85 c0                	test   %eax,%eax
  802034:	78 23                	js     802059 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802036:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80203c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802044:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80204b:	83 ec 0c             	sub    $0xc,%esp
  80204e:	50                   	push   %eax
  80204f:	e8 a8 ed ff ff       	call   800dfc <fd2num>
  802054:	89 c2                	mov    %eax,%edx
  802056:	83 c4 10             	add    $0x10,%esp
}
  802059:	89 d0                	mov    %edx,%eax
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	56                   	push   %esi
  802061:	53                   	push   %ebx
  802062:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802065:	8b 45 0c             	mov    0xc(%ebp),%eax
  802068:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  80206b:	85 c0                	test   %eax,%eax
  80206d:	74 0e                	je     80207d <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  80206f:	83 ec 0c             	sub    $0xc,%esp
  802072:	50                   	push   %eax
  802073:	e8 24 ed ff ff       	call   800d9c <sys_ipc_recv>
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	eb 10                	jmp    80208d <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  80207d:	83 ec 0c             	sub    $0xc,%esp
  802080:	68 00 00 00 f0       	push   $0xf0000000
  802085:	e8 12 ed ff ff       	call   800d9c <sys_ipc_recv>
  80208a:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  80208d:	85 c0                	test   %eax,%eax
  80208f:	74 16                	je     8020a7 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  802091:	85 db                	test   %ebx,%ebx
  802093:	74 36                	je     8020cb <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  802095:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  80209b:	85 f6                	test   %esi,%esi
  80209d:	74 2c                	je     8020cb <ipc_recv+0x6e>
				*perm_store = 0;
  80209f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8020a5:	eb 24                	jmp    8020cb <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  8020a7:	85 db                	test   %ebx,%ebx
  8020a9:	74 18                	je     8020c3 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  8020ab:	a1 20 60 80 00       	mov    0x806020,%eax
  8020b0:	8b 40 74             	mov    0x74(%eax),%eax
  8020b3:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  8020b5:	85 f6                	test   %esi,%esi
  8020b7:	74 0a                	je     8020c3 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  8020b9:	a1 20 60 80 00       	mov    0x806020,%eax
  8020be:	8b 40 78             	mov    0x78(%eax),%eax
  8020c1:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  8020c3:	a1 20 60 80 00       	mov    0x806020,%eax
  8020c8:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  8020cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ce:	5b                   	pop    %ebx
  8020cf:	5e                   	pop    %esi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    

008020d2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020d2:	55                   	push   %ebp
  8020d3:	89 e5                	mov    %esp,%ebp
  8020d5:	57                   	push   %edi
  8020d6:	56                   	push   %esi
  8020d7:	53                   	push   %ebx
  8020d8:	83 ec 0c             	sub    $0xc,%esp
  8020db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  8020e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020e5:	75 39                	jne    802120 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  8020e7:	6a 00                	push   $0x0
  8020e9:	68 00 00 00 f0       	push   $0xf0000000
  8020ee:	56                   	push   %esi
  8020ef:	57                   	push   %edi
  8020f0:	e8 84 ec ff ff       	call   800d79 <sys_ipc_try_send>
  8020f5:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020fd:	74 16                	je     802115 <ipc_send+0x43>
  8020ff:	85 c0                	test   %eax,%eax
  802101:	74 12                	je     802115 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802103:	50                   	push   %eax
  802104:	68 54 29 80 00       	push   $0x802954
  802109:	6a 4f                	push   $0x4f
  80210b:	68 8c 29 80 00       	push   $0x80298c
  802110:	e8 76 e0 ff ff       	call   80018b <_panic>
			sys_yield();
  802115:	e8 b3 ea ff ff       	call   800bcd <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  80211a:	85 db                	test   %ebx,%ebx
  80211c:	75 c9                	jne    8020e7 <ipc_send+0x15>
  80211e:	eb 36                	jmp    802156 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  802120:	ff 75 14             	pushl  0x14(%ebp)
  802123:	ff 75 10             	pushl  0x10(%ebp)
  802126:	56                   	push   %esi
  802127:	57                   	push   %edi
  802128:	e8 4c ec ff ff       	call   800d79 <sys_ipc_try_send>
  80212d:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802135:	74 16                	je     80214d <ipc_send+0x7b>
  802137:	85 c0                	test   %eax,%eax
  802139:	74 12                	je     80214d <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  80213b:	50                   	push   %eax
  80213c:	68 54 29 80 00       	push   $0x802954
  802141:	6a 5a                	push   $0x5a
  802143:	68 8c 29 80 00       	push   $0x80298c
  802148:	e8 3e e0 ff ff       	call   80018b <_panic>
			sys_yield();
  80214d:	e8 7b ea ff ff       	call   800bcd <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  802152:	85 db                	test   %ebx,%ebx
  802154:	75 ca                	jne    802120 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  802156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802159:	5b                   	pop    %ebx
  80215a:	5e                   	pop    %esi
  80215b:	5f                   	pop    %edi
  80215c:	5d                   	pop    %ebp
  80215d:	c3                   	ret    

0080215e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80215e:	55                   	push   %ebp
  80215f:	89 e5                	mov    %esp,%ebp
  802161:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802164:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802169:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80216c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802172:	8b 52 50             	mov    0x50(%edx),%edx
  802175:	39 ca                	cmp    %ecx,%edx
  802177:	75 0d                	jne    802186 <ipc_find_env+0x28>
			return envs[i].env_id;
  802179:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80217c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802181:	8b 40 48             	mov    0x48(%eax),%eax
  802184:	eb 0f                	jmp    802195 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802186:	83 c0 01             	add    $0x1,%eax
  802189:	3d 00 04 00 00       	cmp    $0x400,%eax
  80218e:	75 d9                	jne    802169 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802190:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802195:	5d                   	pop    %ebp
  802196:	c3                   	ret    

00802197 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802197:	55                   	push   %ebp
  802198:	89 e5                	mov    %esp,%ebp
  80219a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80219d:	89 d0                	mov    %edx,%eax
  80219f:	c1 e8 16             	shr    $0x16,%eax
  8021a2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021a9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ae:	f6 c1 01             	test   $0x1,%cl
  8021b1:	74 1d                	je     8021d0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b3:	c1 ea 0c             	shr    $0xc,%edx
  8021b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021bd:	f6 c2 01             	test   $0x1,%dl
  8021c0:	74 0e                	je     8021d0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c2:	c1 ea 0c             	shr    $0xc,%edx
  8021c5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021cc:	ef 
  8021cd:	0f b7 c0             	movzwl %ax,%eax
}
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	66 90                	xchg   %ax,%ax
  8021d4:	66 90                	xchg   %ax,%ax
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
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
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
