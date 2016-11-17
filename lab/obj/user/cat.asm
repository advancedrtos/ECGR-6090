
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
  800048:	e8 46 11 00 00       	call   801193 <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 c0 1f 80 00       	push   $0x801fc0
  800060:	6a 0d                	push   $0xd
  800062:	68 db 1f 80 00       	push   $0x801fdb
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
  80007a:	e8 3a 10 00 00       	call   8010b9 <read>
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
  800093:	68 e6 1f 80 00       	push   $0x801fe6
  800098:	6a 0f                	push   $0xf
  80009a:	68 db 1f 80 00       	push   $0x801fdb
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
  8000b7:	c7 05 00 30 80 00 fb 	movl   $0x801ffb,0x803000
  8000be:	1f 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 ff 1f 80 00       	push   $0x801fff
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
  8000e8:	e8 2b 14 00 00       	call   801518 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 07 20 80 00       	push   $0x802007
  800102:	e8 af 15 00 00       	call   8016b6 <printf>
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
  80011b:	e8 5d 0e 00 00       	call   800f7d <close>
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
  8001a9:	68 24 20 80 00       	push   $0x802024
  8001ae:	e8 b1 00 00 00       	call   800264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	53                   	push   %ebx
  8001b7:	ff 75 10             	pushl  0x10(%ebp)
  8001ba:	e8 54 00 00 00       	call   800213 <vcprintf>
	cprintf("\n");
  8001bf:	c7 04 24 61 24 80 00 	movl   $0x802461,(%esp)
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
  8002c7:	e8 54 1a 00 00       	call   801d20 <__udivdi3>
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
  80030a:	e8 41 1b 00 00       	call   801e50 <__umoddi3>
  80030f:	83 c4 14             	add    $0x14,%esp
  800312:	0f be 80 47 20 80 00 	movsbl 0x802047(%eax),%eax
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
  80040e:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
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
  8004d2:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  8004d9:	85 d2                	test   %edx,%edx
  8004db:	75 18                	jne    8004f5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004dd:	50                   	push   %eax
  8004de:	68 5f 20 80 00       	push   $0x80205f
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
  8004f6:	68 3a 24 80 00       	push   $0x80243a
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
  80051a:	b8 58 20 80 00       	mov    $0x802058,%eax
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
  800b95:	68 3f 23 80 00       	push   $0x80233f
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 5c 23 80 00       	push   $0x80235c
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
  800c16:	68 3f 23 80 00       	push   $0x80233f
  800c1b:	6a 23                	push   $0x23
  800c1d:	68 5c 23 80 00       	push   $0x80235c
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
  800c58:	68 3f 23 80 00       	push   $0x80233f
  800c5d:	6a 23                	push   $0x23
  800c5f:	68 5c 23 80 00       	push   $0x80235c
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
  800c9a:	68 3f 23 80 00       	push   $0x80233f
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 5c 23 80 00       	push   $0x80235c
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
  800cdc:	68 3f 23 80 00       	push   $0x80233f
  800ce1:	6a 23                	push   $0x23
  800ce3:	68 5c 23 80 00       	push   $0x80235c
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
  800d1e:	68 3f 23 80 00       	push   $0x80233f
  800d23:	6a 23                	push   $0x23
  800d25:	68 5c 23 80 00       	push   $0x80235c
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
  800d60:	68 3f 23 80 00       	push   $0x80233f
  800d65:	6a 23                	push   $0x23
  800d67:	68 5c 23 80 00       	push   $0x80235c
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
  800dc4:	68 3f 23 80 00       	push   $0x80233f
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 5c 23 80 00       	push   $0x80235c
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

00800ddd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	05 00 00 00 30       	add    $0x30000000,%eax
  800de8:	c1 e8 0c             	shr    $0xc,%eax
}
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	05 00 00 00 30       	add    $0x30000000,%eax
  800df8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dfd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e0f:	89 c2                	mov    %eax,%edx
  800e11:	c1 ea 16             	shr    $0x16,%edx
  800e14:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1b:	f6 c2 01             	test   $0x1,%dl
  800e1e:	74 11                	je     800e31 <fd_alloc+0x2d>
  800e20:	89 c2                	mov    %eax,%edx
  800e22:	c1 ea 0c             	shr    $0xc,%edx
  800e25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2c:	f6 c2 01             	test   $0x1,%dl
  800e2f:	75 09                	jne    800e3a <fd_alloc+0x36>
			*fd_store = fd;
  800e31:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e33:	b8 00 00 00 00       	mov    $0x0,%eax
  800e38:	eb 17                	jmp    800e51 <fd_alloc+0x4d>
  800e3a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e3f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e44:	75 c9                	jne    800e0f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e46:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e4c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e59:	83 f8 1f             	cmp    $0x1f,%eax
  800e5c:	77 36                	ja     800e94 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e5e:	c1 e0 0c             	shl    $0xc,%eax
  800e61:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e66:	89 c2                	mov    %eax,%edx
  800e68:	c1 ea 16             	shr    $0x16,%edx
  800e6b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e72:	f6 c2 01             	test   $0x1,%dl
  800e75:	74 24                	je     800e9b <fd_lookup+0x48>
  800e77:	89 c2                	mov    %eax,%edx
  800e79:	c1 ea 0c             	shr    $0xc,%edx
  800e7c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e83:	f6 c2 01             	test   $0x1,%dl
  800e86:	74 1a                	je     800ea2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e92:	eb 13                	jmp    800ea7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e99:	eb 0c                	jmp    800ea7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea0:	eb 05                	jmp    800ea7 <fd_lookup+0x54>
  800ea2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb2:	ba e8 23 80 00       	mov    $0x8023e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb7:	eb 13                	jmp    800ecc <dev_lookup+0x23>
  800eb9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ebc:	39 08                	cmp    %ecx,(%eax)
  800ebe:	75 0c                	jne    800ecc <dev_lookup+0x23>
			*dev = devtab[i];
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	eb 2e                	jmp    800efa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ecc:	8b 02                	mov    (%edx),%eax
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	75 e7                	jne    800eb9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed2:	a1 20 60 80 00       	mov    0x806020,%eax
  800ed7:	8b 40 48             	mov    0x48(%eax),%eax
  800eda:	83 ec 04             	sub    $0x4,%esp
  800edd:	51                   	push   %ecx
  800ede:	50                   	push   %eax
  800edf:	68 6c 23 80 00       	push   $0x80236c
  800ee4:	e8 7b f3 ff ff       	call   800264 <cprintf>
	*dev = 0;
  800ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 10             	sub    $0x10,%esp
  800f04:	8b 75 08             	mov    0x8(%ebp),%esi
  800f07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0d:	50                   	push   %eax
  800f0e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f14:	c1 e8 0c             	shr    $0xc,%eax
  800f17:	50                   	push   %eax
  800f18:	e8 36 ff ff ff       	call   800e53 <fd_lookup>
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 05                	js     800f29 <fd_close+0x2d>
	    || fd != fd2)
  800f24:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f27:	74 0c                	je     800f35 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f29:	84 db                	test   %bl,%bl
  800f2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f30:	0f 44 c2             	cmove  %edx,%eax
  800f33:	eb 41                	jmp    800f76 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f3b:	50                   	push   %eax
  800f3c:	ff 36                	pushl  (%esi)
  800f3e:	e8 66 ff ff ff       	call   800ea9 <dev_lookup>
  800f43:	89 c3                	mov    %eax,%ebx
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	78 1a                	js     800f66 <fd_close+0x6a>
		if (dev->dev_close)
  800f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f57:	85 c0                	test   %eax,%eax
  800f59:	74 0b                	je     800f66 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	56                   	push   %esi
  800f5f:	ff d0                	call   *%eax
  800f61:	89 c3                	mov    %eax,%ebx
  800f63:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f66:	83 ec 08             	sub    $0x8,%esp
  800f69:	56                   	push   %esi
  800f6a:	6a 00                	push   $0x0
  800f6c:	e8 00 fd ff ff       	call   800c71 <sys_page_unmap>
	return r;
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	89 d8                	mov    %ebx,%eax
}
  800f76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f86:	50                   	push   %eax
  800f87:	ff 75 08             	pushl  0x8(%ebp)
  800f8a:	e8 c4 fe ff ff       	call   800e53 <fd_lookup>
  800f8f:	83 c4 08             	add    $0x8,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	78 10                	js     800fa6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	6a 01                	push   $0x1
  800f9b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f9e:	e8 59 ff ff ff       	call   800efc <fd_close>
  800fa3:	83 c4 10             	add    $0x10,%esp
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <close_all>:

void
close_all(void)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	53                   	push   %ebx
  800fac:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800faf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	53                   	push   %ebx
  800fb8:	e8 c0 ff ff ff       	call   800f7d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fbd:	83 c3 01             	add    $0x1,%ebx
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	83 fb 20             	cmp    $0x20,%ebx
  800fc6:	75 ec                	jne    800fb4 <close_all+0xc>
		close(i);
}
  800fc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 2c             	sub    $0x2c,%esp
  800fd6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	ff 75 08             	pushl  0x8(%ebp)
  800fe0:	e8 6e fe ff ff       	call   800e53 <fd_lookup>
  800fe5:	83 c4 08             	add    $0x8,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	0f 88 c1 00 00 00    	js     8010b1 <dup+0xe4>
		return r;
	close(newfdnum);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	56                   	push   %esi
  800ff4:	e8 84 ff ff ff       	call   800f7d <close>

	newfd = INDEX2FD(newfdnum);
  800ff9:	89 f3                	mov    %esi,%ebx
  800ffb:	c1 e3 0c             	shl    $0xc,%ebx
  800ffe:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801004:	83 c4 04             	add    $0x4,%esp
  801007:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100a:	e8 de fd ff ff       	call   800ded <fd2data>
  80100f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801011:	89 1c 24             	mov    %ebx,(%esp)
  801014:	e8 d4 fd ff ff       	call   800ded <fd2data>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80101f:	89 f8                	mov    %edi,%eax
  801021:	c1 e8 16             	shr    $0x16,%eax
  801024:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102b:	a8 01                	test   $0x1,%al
  80102d:	74 37                	je     801066 <dup+0x99>
  80102f:	89 f8                	mov    %edi,%eax
  801031:	c1 e8 0c             	shr    $0xc,%eax
  801034:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103b:	f6 c2 01             	test   $0x1,%dl
  80103e:	74 26                	je     801066 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801040:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	25 07 0e 00 00       	and    $0xe07,%eax
  80104f:	50                   	push   %eax
  801050:	ff 75 d4             	pushl  -0x2c(%ebp)
  801053:	6a 00                	push   $0x0
  801055:	57                   	push   %edi
  801056:	6a 00                	push   $0x0
  801058:	e8 d2 fb ff ff       	call   800c2f <sys_page_map>
  80105d:	89 c7                	mov    %eax,%edi
  80105f:	83 c4 20             	add    $0x20,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	78 2e                	js     801094 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801066:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801069:	89 d0                	mov    %edx,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
  80106e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	25 07 0e 00 00       	and    $0xe07,%eax
  80107d:	50                   	push   %eax
  80107e:	53                   	push   %ebx
  80107f:	6a 00                	push   $0x0
  801081:	52                   	push   %edx
  801082:	6a 00                	push   $0x0
  801084:	e8 a6 fb ff ff       	call   800c2f <sys_page_map>
  801089:	89 c7                	mov    %eax,%edi
  80108b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80108e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801090:	85 ff                	test   %edi,%edi
  801092:	79 1d                	jns    8010b1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801094:	83 ec 08             	sub    $0x8,%esp
  801097:	53                   	push   %ebx
  801098:	6a 00                	push   $0x0
  80109a:	e8 d2 fb ff ff       	call   800c71 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80109f:	83 c4 08             	add    $0x8,%esp
  8010a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 c5 fb ff ff       	call   800c71 <sys_page_unmap>
	return r;
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	89 f8                	mov    %edi,%eax
}
  8010b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 14             	sub    $0x14,%esp
  8010c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	53                   	push   %ebx
  8010c8:	e8 86 fd ff ff       	call   800e53 <fd_lookup>
  8010cd:	83 c4 08             	add    $0x8,%esp
  8010d0:	89 c2                	mov    %eax,%edx
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 6d                	js     801143 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dc:	50                   	push   %eax
  8010dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e0:	ff 30                	pushl  (%eax)
  8010e2:	e8 c2 fd ff ff       	call   800ea9 <dev_lookup>
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 4c                	js     80113a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f1:	8b 42 08             	mov    0x8(%edx),%eax
  8010f4:	83 e0 03             	and    $0x3,%eax
  8010f7:	83 f8 01             	cmp    $0x1,%eax
  8010fa:	75 21                	jne    80111d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010fc:	a1 20 60 80 00       	mov    0x806020,%eax
  801101:	8b 40 48             	mov    0x48(%eax),%eax
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	53                   	push   %ebx
  801108:	50                   	push   %eax
  801109:	68 ad 23 80 00       	push   $0x8023ad
  80110e:	e8 51 f1 ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80111b:	eb 26                	jmp    801143 <read+0x8a>
	}
	if (!dev->dev_read)
  80111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801120:	8b 40 08             	mov    0x8(%eax),%eax
  801123:	85 c0                	test   %eax,%eax
  801125:	74 17                	je     80113e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801127:	83 ec 04             	sub    $0x4,%esp
  80112a:	ff 75 10             	pushl  0x10(%ebp)
  80112d:	ff 75 0c             	pushl  0xc(%ebp)
  801130:	52                   	push   %edx
  801131:	ff d0                	call   *%eax
  801133:	89 c2                	mov    %eax,%edx
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	eb 09                	jmp    801143 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113a:	89 c2                	mov    %eax,%edx
  80113c:	eb 05                	jmp    801143 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80113e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801143:	89 d0                	mov    %edx,%eax
  801145:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	57                   	push   %edi
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	83 ec 0c             	sub    $0xc,%esp
  801153:	8b 7d 08             	mov    0x8(%ebp),%edi
  801156:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801159:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115e:	eb 21                	jmp    801181 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801160:	83 ec 04             	sub    $0x4,%esp
  801163:	89 f0                	mov    %esi,%eax
  801165:	29 d8                	sub    %ebx,%eax
  801167:	50                   	push   %eax
  801168:	89 d8                	mov    %ebx,%eax
  80116a:	03 45 0c             	add    0xc(%ebp),%eax
  80116d:	50                   	push   %eax
  80116e:	57                   	push   %edi
  80116f:	e8 45 ff ff ff       	call   8010b9 <read>
		if (m < 0)
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	78 10                	js     80118b <readn+0x41>
			return m;
		if (m == 0)
  80117b:	85 c0                	test   %eax,%eax
  80117d:	74 0a                	je     801189 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117f:	01 c3                	add    %eax,%ebx
  801181:	39 f3                	cmp    %esi,%ebx
  801183:	72 db                	jb     801160 <readn+0x16>
  801185:	89 d8                	mov    %ebx,%eax
  801187:	eb 02                	jmp    80118b <readn+0x41>
  801189:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80118b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	53                   	push   %ebx
  801197:	83 ec 14             	sub    $0x14,%esp
  80119a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a0:	50                   	push   %eax
  8011a1:	53                   	push   %ebx
  8011a2:	e8 ac fc ff ff       	call   800e53 <fd_lookup>
  8011a7:	83 c4 08             	add    $0x8,%esp
  8011aa:	89 c2                	mov    %eax,%edx
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	78 68                	js     801218 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ba:	ff 30                	pushl  (%eax)
  8011bc:	e8 e8 fc ff ff       	call   800ea9 <dev_lookup>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 47                	js     80120f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011cf:	75 21                	jne    8011f2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d1:	a1 20 60 80 00       	mov    0x806020,%eax
  8011d6:	8b 40 48             	mov    0x48(%eax),%eax
  8011d9:	83 ec 04             	sub    $0x4,%esp
  8011dc:	53                   	push   %ebx
  8011dd:	50                   	push   %eax
  8011de:	68 c9 23 80 00       	push   $0x8023c9
  8011e3:	e8 7c f0 ff ff       	call   800264 <cprintf>
		return -E_INVAL;
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f0:	eb 26                	jmp    801218 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f8:	85 d2                	test   %edx,%edx
  8011fa:	74 17                	je     801213 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	ff 75 10             	pushl  0x10(%ebp)
  801202:	ff 75 0c             	pushl  0xc(%ebp)
  801205:	50                   	push   %eax
  801206:	ff d2                	call   *%edx
  801208:	89 c2                	mov    %eax,%edx
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	eb 09                	jmp    801218 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120f:	89 c2                	mov    %eax,%edx
  801211:	eb 05                	jmp    801218 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801213:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801218:	89 d0                	mov    %edx,%eax
  80121a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <seek>:

int
seek(int fdnum, off_t offset)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801225:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	ff 75 08             	pushl  0x8(%ebp)
  80122c:	e8 22 fc ff ff       	call   800e53 <fd_lookup>
  801231:	83 c4 08             	add    $0x8,%esp
  801234:	85 c0                	test   %eax,%eax
  801236:	78 0e                	js     801246 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801238:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80123b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801241:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801246:	c9                   	leave  
  801247:	c3                   	ret    

00801248 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	53                   	push   %ebx
  80124c:	83 ec 14             	sub    $0x14,%esp
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801252:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	53                   	push   %ebx
  801257:	e8 f7 fb ff ff       	call   800e53 <fd_lookup>
  80125c:	83 c4 08             	add    $0x8,%esp
  80125f:	89 c2                	mov    %eax,%edx
  801261:	85 c0                	test   %eax,%eax
  801263:	78 65                	js     8012ca <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126f:	ff 30                	pushl  (%eax)
  801271:	e8 33 fc ff ff       	call   800ea9 <dev_lookup>
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 44                	js     8012c1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801280:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801284:	75 21                	jne    8012a7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801286:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80128b:	8b 40 48             	mov    0x48(%eax),%eax
  80128e:	83 ec 04             	sub    $0x4,%esp
  801291:	53                   	push   %ebx
  801292:	50                   	push   %eax
  801293:	68 8c 23 80 00       	push   $0x80238c
  801298:	e8 c7 ef ff ff       	call   800264 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a5:	eb 23                	jmp    8012ca <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012aa:	8b 52 18             	mov    0x18(%edx),%edx
  8012ad:	85 d2                	test   %edx,%edx
  8012af:	74 14                	je     8012c5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	ff 75 0c             	pushl  0xc(%ebp)
  8012b7:	50                   	push   %eax
  8012b8:	ff d2                	call   *%edx
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	eb 09                	jmp    8012ca <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c1:	89 c2                	mov    %eax,%edx
  8012c3:	eb 05                	jmp    8012ca <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012ca:	89 d0                	mov    %edx,%eax
  8012cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 14             	sub    $0x14,%esp
  8012d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	ff 75 08             	pushl  0x8(%ebp)
  8012e2:	e8 6c fb ff ff       	call   800e53 <fd_lookup>
  8012e7:	83 c4 08             	add    $0x8,%esp
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 58                	js     801348 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fa:	ff 30                	pushl  (%eax)
  8012fc:	e8 a8 fb ff ff       	call   800ea9 <dev_lookup>
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 37                	js     80133f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801308:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80130f:	74 32                	je     801343 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801311:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801314:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131b:	00 00 00 
	stat->st_isdir = 0;
  80131e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801325:	00 00 00 
	stat->st_dev = dev;
  801328:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	53                   	push   %ebx
  801332:	ff 75 f0             	pushl  -0x10(%ebp)
  801335:	ff 50 14             	call   *0x14(%eax)
  801338:	89 c2                	mov    %eax,%edx
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	eb 09                	jmp    801348 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133f:	89 c2                	mov    %eax,%edx
  801341:	eb 05                	jmp    801348 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801343:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801348:	89 d0                	mov    %edx,%eax
  80134a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	56                   	push   %esi
  801353:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	6a 00                	push   $0x0
  801359:	ff 75 08             	pushl  0x8(%ebp)
  80135c:	e8 b7 01 00 00       	call   801518 <open>
  801361:	89 c3                	mov    %eax,%ebx
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 1b                	js     801385 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	ff 75 0c             	pushl  0xc(%ebp)
  801370:	50                   	push   %eax
  801371:	e8 5b ff ff ff       	call   8012d1 <fstat>
  801376:	89 c6                	mov    %eax,%esi
	close(fd);
  801378:	89 1c 24             	mov    %ebx,(%esp)
  80137b:	e8 fd fb ff ff       	call   800f7d <close>
	return r;
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	89 f0                	mov    %esi,%eax
}
  801385:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	5d                   	pop    %ebp
  80138b:	c3                   	ret    

0080138c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	89 c6                	mov    %eax,%esi
  801393:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801395:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139c:	75 12                	jne    8013b0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	6a 01                	push   $0x1
  8013a3:	e8 04 09 00 00       	call   801cac <ipc_find_env>
  8013a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b0:	6a 07                	push   $0x7
  8013b2:	68 00 70 80 00       	push   $0x807000
  8013b7:	56                   	push   %esi
  8013b8:	ff 35 00 40 80 00    	pushl  0x804000
  8013be:	e8 5d 08 00 00       	call   801c20 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013c3:	83 c4 0c             	add    $0xc,%esp
  8013c6:	6a 00                	push   $0x0
  8013c8:	53                   	push   %ebx
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 db 07 00 00       	call   801bab <ipc_recv>
}
  8013d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    

008013d7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e3:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8013e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013eb:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f5:	b8 02 00 00 00       	mov    $0x2,%eax
  8013fa:	e8 8d ff ff ff       	call   80138c <fsipc>
}
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801407:	8b 45 08             	mov    0x8(%ebp),%eax
  80140a:	8b 40 0c             	mov    0xc(%eax),%eax
  80140d:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801412:	ba 00 00 00 00       	mov    $0x0,%edx
  801417:	b8 06 00 00 00       	mov    $0x6,%eax
  80141c:	e8 6b ff ff ff       	call   80138c <fsipc>
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	53                   	push   %ebx
  801427:	83 ec 04             	sub    $0x4,%esp
  80142a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	8b 40 0c             	mov    0xc(%eax),%eax
  801433:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801438:	ba 00 00 00 00       	mov    $0x0,%edx
  80143d:	b8 05 00 00 00       	mov    $0x5,%eax
  801442:	e8 45 ff ff ff       	call   80138c <fsipc>
  801447:	85 c0                	test   %eax,%eax
  801449:	78 2c                	js     801477 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	68 00 70 80 00       	push   $0x807000
  801453:	53                   	push   %ebx
  801454:	e8 90 f3 ff ff       	call   8007e9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801459:	a1 80 70 80 00       	mov    0x807080,%eax
  80145e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801464:	a1 84 70 80 00       	mov    0x807084,%eax
  801469:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801477:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801482:	68 f8 23 80 00       	push   $0x8023f8
  801487:	68 90 00 00 00       	push   $0x90
  80148c:	68 16 24 80 00       	push   $0x802416
  801491:	e8 f5 ec ff ff       	call   80018b <_panic>

00801496 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	56                   	push   %esi
  80149a:	53                   	push   %ebx
  80149b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80149e:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a4:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8014a9:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014af:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b4:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b9:	e8 ce fe ff ff       	call   80138c <fsipc>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 4b                	js     80150f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014c4:	39 c6                	cmp    %eax,%esi
  8014c6:	73 16                	jae    8014de <devfile_read+0x48>
  8014c8:	68 21 24 80 00       	push   $0x802421
  8014cd:	68 28 24 80 00       	push   $0x802428
  8014d2:	6a 7c                	push   $0x7c
  8014d4:	68 16 24 80 00       	push   $0x802416
  8014d9:	e8 ad ec ff ff       	call   80018b <_panic>
	assert(r <= PGSIZE);
  8014de:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014e3:	7e 16                	jle    8014fb <devfile_read+0x65>
  8014e5:	68 3d 24 80 00       	push   $0x80243d
  8014ea:	68 28 24 80 00       	push   $0x802428
  8014ef:	6a 7d                	push   $0x7d
  8014f1:	68 16 24 80 00       	push   $0x802416
  8014f6:	e8 90 ec ff ff       	call   80018b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	50                   	push   %eax
  8014ff:	68 00 70 80 00       	push   $0x807000
  801504:	ff 75 0c             	pushl  0xc(%ebp)
  801507:	e8 6f f4 ff ff       	call   80097b <memmove>
	return r;
  80150c:	83 c4 10             	add    $0x10,%esp
}
  80150f:	89 d8                	mov    %ebx,%eax
  801511:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801514:	5b                   	pop    %ebx
  801515:	5e                   	pop    %esi
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    

00801518 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	53                   	push   %ebx
  80151c:	83 ec 20             	sub    $0x20,%esp
  80151f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801522:	53                   	push   %ebx
  801523:	e8 88 f2 ff ff       	call   8007b0 <strlen>
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801530:	7f 67                	jg     801599 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801532:	83 ec 0c             	sub    $0xc,%esp
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	e8 c6 f8 ff ff       	call   800e04 <fd_alloc>
  80153e:	83 c4 10             	add    $0x10,%esp
		return r;
  801541:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801543:	85 c0                	test   %eax,%eax
  801545:	78 57                	js     80159e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	53                   	push   %ebx
  80154b:	68 00 70 80 00       	push   $0x807000
  801550:	e8 94 f2 ff ff       	call   8007e9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801555:	8b 45 0c             	mov    0xc(%ebp),%eax
  801558:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80155d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801560:	b8 01 00 00 00       	mov    $0x1,%eax
  801565:	e8 22 fe ff ff       	call   80138c <fsipc>
  80156a:	89 c3                	mov    %eax,%ebx
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	79 14                	jns    801587 <open+0x6f>
		fd_close(fd, 0);
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	6a 00                	push   $0x0
  801578:	ff 75 f4             	pushl  -0xc(%ebp)
  80157b:	e8 7c f9 ff ff       	call   800efc <fd_close>
		return r;
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	89 da                	mov    %ebx,%edx
  801585:	eb 17                	jmp    80159e <open+0x86>
	}

	return fd2num(fd);
  801587:	83 ec 0c             	sub    $0xc,%esp
  80158a:	ff 75 f4             	pushl  -0xc(%ebp)
  80158d:	e8 4b f8 ff ff       	call   800ddd <fd2num>
  801592:	89 c2                	mov    %eax,%edx
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	eb 05                	jmp    80159e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801599:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80159e:	89 d0                	mov    %edx,%eax
  8015a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8015b5:	e8 d2 fd ff ff       	call   80138c <fsipc>
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8015bc:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8015c0:	7e 37                	jle    8015f9 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	53                   	push   %ebx
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8015cb:	ff 70 04             	pushl  0x4(%eax)
  8015ce:	8d 40 10             	lea    0x10(%eax),%eax
  8015d1:	50                   	push   %eax
  8015d2:	ff 33                	pushl  (%ebx)
  8015d4:	e8 ba fb ff ff       	call   801193 <write>
		if (result > 0)
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	7e 03                	jle    8015e3 <writebuf+0x27>
			b->result += result;
  8015e0:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8015e3:	3b 43 04             	cmp    0x4(%ebx),%eax
  8015e6:	74 0d                	je     8015f5 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ef:	0f 4f c2             	cmovg  %edx,%eax
  8015f2:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8015f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f8:	c9                   	leave  
  8015f9:	f3 c3                	repz ret 

008015fb <putch>:

static void
putch(int ch, void *thunk)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	53                   	push   %ebx
  8015ff:	83 ec 04             	sub    $0x4,%esp
  801602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801605:	8b 53 04             	mov    0x4(%ebx),%edx
  801608:	8d 42 01             	lea    0x1(%edx),%eax
  80160b:	89 43 04             	mov    %eax,0x4(%ebx)
  80160e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801611:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801615:	3d 00 01 00 00       	cmp    $0x100,%eax
  80161a:	75 0e                	jne    80162a <putch+0x2f>
		writebuf(b);
  80161c:	89 d8                	mov    %ebx,%eax
  80161e:	e8 99 ff ff ff       	call   8015bc <writebuf>
		b->idx = 0;
  801623:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80162a:	83 c4 04             	add    $0x4,%esp
  80162d:	5b                   	pop    %ebx
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801639:	8b 45 08             	mov    0x8(%ebp),%eax
  80163c:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801642:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801649:	00 00 00 
	b.result = 0;
  80164c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801653:	00 00 00 
	b.error = 1;
  801656:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80165d:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801660:	ff 75 10             	pushl  0x10(%ebp)
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	68 fb 15 80 00       	push   $0x8015fb
  801672:	e8 24 ed ff ff       	call   80039b <vprintfmt>
	if (b.idx > 0)
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801681:	7e 0b                	jle    80168e <vfprintf+0x5e>
		writebuf(&b);
  801683:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801689:	e8 2e ff ff ff       	call   8015bc <writebuf>

	return (b.result ? b.result : b.error);
  80168e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801694:	85 c0                	test   %eax,%eax
  801696:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016a5:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8016a8:	50                   	push   %eax
  8016a9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ac:	ff 75 08             	pushl  0x8(%ebp)
  8016af:	e8 7c ff ff ff       	call   801630 <vfprintf>
	va_end(ap);

	return cnt;
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <printf>:

int
printf(const char *fmt, ...)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016bc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8016bf:	50                   	push   %eax
  8016c0:	ff 75 08             	pushl  0x8(%ebp)
  8016c3:	6a 01                	push   $0x1
  8016c5:	e8 66 ff ff ff       	call   801630 <vfprintf>
	va_end(ap);

	return cnt;
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	ff 75 08             	pushl  0x8(%ebp)
  8016da:	e8 0e f7 ff ff       	call   800ded <fd2data>
  8016df:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016e1:	83 c4 08             	add    $0x8,%esp
  8016e4:	68 49 24 80 00       	push   $0x802449
  8016e9:	53                   	push   %ebx
  8016ea:	e8 fa f0 ff ff       	call   8007e9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016ef:	8b 46 04             	mov    0x4(%esi),%eax
  8016f2:	2b 06                	sub    (%esi),%eax
  8016f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801701:	00 00 00 
	stat->st_dev = &devpipe;
  801704:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80170b:	30 80 00 
	return 0;
}
  80170e:	b8 00 00 00 00       	mov    $0x0,%eax
  801713:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801716:	5b                   	pop    %ebx
  801717:	5e                   	pop    %esi
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	53                   	push   %ebx
  80171e:	83 ec 0c             	sub    $0xc,%esp
  801721:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801724:	53                   	push   %ebx
  801725:	6a 00                	push   $0x0
  801727:	e8 45 f5 ff ff       	call   800c71 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80172c:	89 1c 24             	mov    %ebx,(%esp)
  80172f:	e8 b9 f6 ff ff       	call   800ded <fd2data>
  801734:	83 c4 08             	add    $0x8,%esp
  801737:	50                   	push   %eax
  801738:	6a 00                	push   $0x0
  80173a:	e8 32 f5 ff ff       	call   800c71 <sys_page_unmap>
}
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	57                   	push   %edi
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	83 ec 1c             	sub    $0x1c,%esp
  80174d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801750:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801752:	a1 20 60 80 00       	mov    0x806020,%eax
  801757:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80175a:	83 ec 0c             	sub    $0xc,%esp
  80175d:	ff 75 e0             	pushl  -0x20(%ebp)
  801760:	e8 80 05 00 00       	call   801ce5 <pageref>
  801765:	89 c3                	mov    %eax,%ebx
  801767:	89 3c 24             	mov    %edi,(%esp)
  80176a:	e8 76 05 00 00       	call   801ce5 <pageref>
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	39 c3                	cmp    %eax,%ebx
  801774:	0f 94 c1             	sete   %cl
  801777:	0f b6 c9             	movzbl %cl,%ecx
  80177a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80177d:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801783:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801786:	39 ce                	cmp    %ecx,%esi
  801788:	74 1b                	je     8017a5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80178a:	39 c3                	cmp    %eax,%ebx
  80178c:	75 c4                	jne    801752 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80178e:	8b 42 58             	mov    0x58(%edx),%eax
  801791:	ff 75 e4             	pushl  -0x1c(%ebp)
  801794:	50                   	push   %eax
  801795:	56                   	push   %esi
  801796:	68 50 24 80 00       	push   $0x802450
  80179b:	e8 c4 ea ff ff       	call   800264 <cprintf>
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	eb ad                	jmp    801752 <_pipeisclosed+0xe>
	}
}
  8017a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ab:	5b                   	pop    %ebx
  8017ac:	5e                   	pop    %esi
  8017ad:	5f                   	pop    %edi
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	57                   	push   %edi
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 28             	sub    $0x28,%esp
  8017b9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017bc:	56                   	push   %esi
  8017bd:	e8 2b f6 ff ff       	call   800ded <fd2data>
  8017c2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8017cc:	eb 4b                	jmp    801819 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017ce:	89 da                	mov    %ebx,%edx
  8017d0:	89 f0                	mov    %esi,%eax
  8017d2:	e8 6d ff ff ff       	call   801744 <_pipeisclosed>
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	75 48                	jne    801823 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017db:	e8 ed f3 ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017e0:	8b 43 04             	mov    0x4(%ebx),%eax
  8017e3:	8b 0b                	mov    (%ebx),%ecx
  8017e5:	8d 51 20             	lea    0x20(%ecx),%edx
  8017e8:	39 d0                	cmp    %edx,%eax
  8017ea:	73 e2                	jae    8017ce <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ef:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017f3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017f6:	89 c2                	mov    %eax,%edx
  8017f8:	c1 fa 1f             	sar    $0x1f,%edx
  8017fb:	89 d1                	mov    %edx,%ecx
  8017fd:	c1 e9 1b             	shr    $0x1b,%ecx
  801800:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801803:	83 e2 1f             	and    $0x1f,%edx
  801806:	29 ca                	sub    %ecx,%edx
  801808:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80180c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801810:	83 c0 01             	add    $0x1,%eax
  801813:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801816:	83 c7 01             	add    $0x1,%edi
  801819:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80181c:	75 c2                	jne    8017e0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80181e:	8b 45 10             	mov    0x10(%ebp),%eax
  801821:	eb 05                	jmp    801828 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801823:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801828:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5e                   	pop    %esi
  80182d:	5f                   	pop    %edi
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	57                   	push   %edi
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	83 ec 18             	sub    $0x18,%esp
  801839:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80183c:	57                   	push   %edi
  80183d:	e8 ab f5 ff ff       	call   800ded <fd2data>
  801842:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	bb 00 00 00 00       	mov    $0x0,%ebx
  80184c:	eb 3d                	jmp    80188b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80184e:	85 db                	test   %ebx,%ebx
  801850:	74 04                	je     801856 <devpipe_read+0x26>
				return i;
  801852:	89 d8                	mov    %ebx,%eax
  801854:	eb 44                	jmp    80189a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801856:	89 f2                	mov    %esi,%edx
  801858:	89 f8                	mov    %edi,%eax
  80185a:	e8 e5 fe ff ff       	call   801744 <_pipeisclosed>
  80185f:	85 c0                	test   %eax,%eax
  801861:	75 32                	jne    801895 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801863:	e8 65 f3 ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801868:	8b 06                	mov    (%esi),%eax
  80186a:	3b 46 04             	cmp    0x4(%esi),%eax
  80186d:	74 df                	je     80184e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80186f:	99                   	cltd   
  801870:	c1 ea 1b             	shr    $0x1b,%edx
  801873:	01 d0                	add    %edx,%eax
  801875:	83 e0 1f             	and    $0x1f,%eax
  801878:	29 d0                	sub    %edx,%eax
  80187a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80187f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801882:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801885:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801888:	83 c3 01             	add    $0x1,%ebx
  80188b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80188e:	75 d8                	jne    801868 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801890:	8b 45 10             	mov    0x10(%ebp),%eax
  801893:	eb 05                	jmp    80189a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801895:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80189a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80189d:	5b                   	pop    %ebx
  80189e:	5e                   	pop    %esi
  80189f:	5f                   	pop    %edi
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	56                   	push   %esi
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ad:	50                   	push   %eax
  8018ae:	e8 51 f5 ff ff       	call   800e04 <fd_alloc>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	89 c2                	mov    %eax,%edx
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	0f 88 2c 01 00 00    	js     8019ec <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c0:	83 ec 04             	sub    $0x4,%esp
  8018c3:	68 07 04 00 00       	push   $0x407
  8018c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cb:	6a 00                	push   $0x0
  8018cd:	e8 1a f3 ff ff       	call   800bec <sys_page_alloc>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	0f 88 0d 01 00 00    	js     8019ec <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018df:	83 ec 0c             	sub    $0xc,%esp
  8018e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e5:	50                   	push   %eax
  8018e6:	e8 19 f5 ff ff       	call   800e04 <fd_alloc>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	0f 88 e2 00 00 00    	js     8019da <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f8:	83 ec 04             	sub    $0x4,%esp
  8018fb:	68 07 04 00 00       	push   $0x407
  801900:	ff 75 f0             	pushl  -0x10(%ebp)
  801903:	6a 00                	push   $0x0
  801905:	e8 e2 f2 ff ff       	call   800bec <sys_page_alloc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	0f 88 c3 00 00 00    	js     8019da <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	ff 75 f4             	pushl  -0xc(%ebp)
  80191d:	e8 cb f4 ff ff       	call   800ded <fd2data>
  801922:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801924:	83 c4 0c             	add    $0xc,%esp
  801927:	68 07 04 00 00       	push   $0x407
  80192c:	50                   	push   %eax
  80192d:	6a 00                	push   $0x0
  80192f:	e8 b8 f2 ff ff       	call   800bec <sys_page_alloc>
  801934:	89 c3                	mov    %eax,%ebx
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	85 c0                	test   %eax,%eax
  80193b:	0f 88 89 00 00 00    	js     8019ca <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801941:	83 ec 0c             	sub    $0xc,%esp
  801944:	ff 75 f0             	pushl  -0x10(%ebp)
  801947:	e8 a1 f4 ff ff       	call   800ded <fd2data>
  80194c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801953:	50                   	push   %eax
  801954:	6a 00                	push   $0x0
  801956:	56                   	push   %esi
  801957:	6a 00                	push   $0x0
  801959:	e8 d1 f2 ff ff       	call   800c2f <sys_page_map>
  80195e:	89 c3                	mov    %eax,%ebx
  801960:	83 c4 20             	add    $0x20,%esp
  801963:	85 c0                	test   %eax,%eax
  801965:	78 55                	js     8019bc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801967:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80196d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801970:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801972:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801975:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80197c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801982:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801985:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	ff 75 f4             	pushl  -0xc(%ebp)
  801997:	e8 41 f4 ff ff       	call   800ddd <fd2num>
  80199c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019a1:	83 c4 04             	add    $0x4,%esp
  8019a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a7:	e8 31 f4 ff ff       	call   800ddd <fd2num>
  8019ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019af:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ba:	eb 30                	jmp    8019ec <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8019bc:	83 ec 08             	sub    $0x8,%esp
  8019bf:	56                   	push   %esi
  8019c0:	6a 00                	push   $0x0
  8019c2:	e8 aa f2 ff ff       	call   800c71 <sys_page_unmap>
  8019c7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019ca:	83 ec 08             	sub    $0x8,%esp
  8019cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8019d0:	6a 00                	push   $0x0
  8019d2:	e8 9a f2 ff ff       	call   800c71 <sys_page_unmap>
  8019d7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019da:	83 ec 08             	sub    $0x8,%esp
  8019dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e0:	6a 00                	push   $0x0
  8019e2:	e8 8a f2 ff ff       	call   800c71 <sys_page_unmap>
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019ec:	89 d0                	mov    %edx,%eax
  8019ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f1:	5b                   	pop    %ebx
  8019f2:	5e                   	pop    %esi
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fe:	50                   	push   %eax
  8019ff:	ff 75 08             	pushl  0x8(%ebp)
  801a02:	e8 4c f4 ff ff       	call   800e53 <fd_lookup>
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 18                	js     801a26 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	ff 75 f4             	pushl  -0xc(%ebp)
  801a14:	e8 d4 f3 ff ff       	call   800ded <fd2data>
	return _pipeisclosed(fd, p);
  801a19:	89 c2                	mov    %eax,%edx
  801a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1e:	e8 21 fd ff ff       	call   801744 <_pipeisclosed>
  801a23:	83 c4 10             	add    $0x10,%esp
}
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    

00801a28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a38:	68 68 24 80 00       	push   $0x802468
  801a3d:	ff 75 0c             	pushl  0xc(%ebp)
  801a40:	e8 a4 ed ff ff       	call   8007e9 <strcpy>
	return 0;
}
  801a45:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	57                   	push   %edi
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a58:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a5d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a63:	eb 2d                	jmp    801a92 <devcons_write+0x46>
		m = n - tot;
  801a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a68:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a6a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a6d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a72:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a75:	83 ec 04             	sub    $0x4,%esp
  801a78:	53                   	push   %ebx
  801a79:	03 45 0c             	add    0xc(%ebp),%eax
  801a7c:	50                   	push   %eax
  801a7d:	57                   	push   %edi
  801a7e:	e8 f8 ee ff ff       	call   80097b <memmove>
		sys_cputs(buf, m);
  801a83:	83 c4 08             	add    $0x8,%esp
  801a86:	53                   	push   %ebx
  801a87:	57                   	push   %edi
  801a88:	e8 a3 f0 ff ff       	call   800b30 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a8d:	01 de                	add    %ebx,%esi
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	89 f0                	mov    %esi,%eax
  801a94:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a97:	72 cc                	jb     801a65 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5f                   	pop    %edi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    

00801aa1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 08             	sub    $0x8,%esp
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801aac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ab0:	74 2a                	je     801adc <devcons_read+0x3b>
  801ab2:	eb 05                	jmp    801ab9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ab4:	e8 14 f1 ff ff       	call   800bcd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ab9:	e8 90 f0 ff ff       	call   800b4e <sys_cgetc>
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	74 f2                	je     801ab4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 16                	js     801adc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ac6:	83 f8 04             	cmp    $0x4,%eax
  801ac9:	74 0c                	je     801ad7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801acb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ace:	88 02                	mov    %al,(%edx)
	return 1;
  801ad0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad5:	eb 05                	jmp    801adc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ad7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801aea:	6a 01                	push   $0x1
  801aec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	e8 3b f0 ff ff       	call   800b30 <sys_cputs>
}
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <getchar>:

int
getchar(void)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b00:	6a 01                	push   $0x1
  801b02:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b05:	50                   	push   %eax
  801b06:	6a 00                	push   $0x0
  801b08:	e8 ac f5 ff ff       	call   8010b9 <read>
	if (r < 0)
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 0f                	js     801b23 <getchar+0x29>
		return r;
	if (r < 1)
  801b14:	85 c0                	test   %eax,%eax
  801b16:	7e 06                	jle    801b1e <getchar+0x24>
		return -E_EOF;
	return c;
  801b18:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b1c:	eb 05                	jmp    801b23 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b1e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2e:	50                   	push   %eax
  801b2f:	ff 75 08             	pushl  0x8(%ebp)
  801b32:	e8 1c f3 ff ff       	call   800e53 <fd_lookup>
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 11                	js     801b4f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b41:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b47:	39 10                	cmp    %edx,(%eax)
  801b49:	0f 94 c0             	sete   %al
  801b4c:	0f b6 c0             	movzbl %al,%eax
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <opencons>:

int
opencons(void)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5a:	50                   	push   %eax
  801b5b:	e8 a4 f2 ff ff       	call   800e04 <fd_alloc>
  801b60:	83 c4 10             	add    $0x10,%esp
		return r;
  801b63:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b65:	85 c0                	test   %eax,%eax
  801b67:	78 3e                	js     801ba7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b69:	83 ec 04             	sub    $0x4,%esp
  801b6c:	68 07 04 00 00       	push   $0x407
  801b71:	ff 75 f4             	pushl  -0xc(%ebp)
  801b74:	6a 00                	push   $0x0
  801b76:	e8 71 f0 ff ff       	call   800bec <sys_page_alloc>
  801b7b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b7e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 23                	js     801ba7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b84:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b92:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	50                   	push   %eax
  801b9d:	e8 3b f2 ff ff       	call   800ddd <fd2num>
  801ba2:	89 c2                	mov    %eax,%edx
  801ba4:	83 c4 10             	add    $0x10,%esp
}
  801ba7:	89 d0                	mov    %edx,%eax
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	56                   	push   %esi
  801baf:	53                   	push   %ebx
  801bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	74 0e                	je     801bcb <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	50                   	push   %eax
  801bc1:	e8 d6 f1 ff ff       	call   800d9c <sys_ipc_recv>
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	eb 10                	jmp    801bdb <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  801bcb:	83 ec 0c             	sub    $0xc,%esp
  801bce:	68 00 00 00 f0       	push   $0xf0000000
  801bd3:	e8 c4 f1 ff ff       	call   800d9c <sys_ipc_recv>
  801bd8:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	74 16                	je     801bf5 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  801bdf:	85 db                	test   %ebx,%ebx
  801be1:	74 36                	je     801c19 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  801be3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  801be9:	85 f6                	test   %esi,%esi
  801beb:	74 2c                	je     801c19 <ipc_recv+0x6e>
				*perm_store = 0;
  801bed:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801bf3:	eb 24                	jmp    801c19 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  801bf5:	85 db                	test   %ebx,%ebx
  801bf7:	74 18                	je     801c11 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  801bf9:	a1 20 60 80 00       	mov    0x806020,%eax
  801bfe:	8b 40 74             	mov    0x74(%eax),%eax
  801c01:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  801c03:	85 f6                	test   %esi,%esi
  801c05:	74 0a                	je     801c11 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  801c07:	a1 20 60 80 00       	mov    0x806020,%eax
  801c0c:	8b 40 78             	mov    0x78(%eax),%eax
  801c0f:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  801c11:	a1 20 60 80 00       	mov    0x806020,%eax
  801c16:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  801c19:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1c:	5b                   	pop    %ebx
  801c1d:	5e                   	pop    %esi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	57                   	push   %edi
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c2c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  801c2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c33:	75 39                	jne    801c6e <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  801c35:	6a 00                	push   $0x0
  801c37:	68 00 00 00 f0       	push   $0xf0000000
  801c3c:	56                   	push   %esi
  801c3d:	57                   	push   %edi
  801c3e:	e8 36 f1 ff ff       	call   800d79 <sys_ipc_try_send>
  801c43:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c4b:	74 16                	je     801c63 <ipc_send+0x43>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	74 12                	je     801c63 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801c51:	50                   	push   %eax
  801c52:	68 74 24 80 00       	push   $0x802474
  801c57:	6a 4f                	push   $0x4f
  801c59:	68 ac 24 80 00       	push   $0x8024ac
  801c5e:	e8 28 e5 ff ff       	call   80018b <_panic>
			sys_yield();
  801c63:	e8 65 ef ff ff       	call   800bcd <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  801c68:	85 db                	test   %ebx,%ebx
  801c6a:	75 c9                	jne    801c35 <ipc_send+0x15>
  801c6c:	eb 36                	jmp    801ca4 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  801c6e:	ff 75 14             	pushl  0x14(%ebp)
  801c71:	ff 75 10             	pushl  0x10(%ebp)
  801c74:	56                   	push   %esi
  801c75:	57                   	push   %edi
  801c76:	e8 fe f0 ff ff       	call   800d79 <sys_ipc_try_send>
  801c7b:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c83:	74 16                	je     801c9b <ipc_send+0x7b>
  801c85:	85 c0                	test   %eax,%eax
  801c87:	74 12                	je     801c9b <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801c89:	50                   	push   %eax
  801c8a:	68 74 24 80 00       	push   $0x802474
  801c8f:	6a 5a                	push   $0x5a
  801c91:	68 ac 24 80 00       	push   $0x8024ac
  801c96:	e8 f0 e4 ff ff       	call   80018b <_panic>
			sys_yield();
  801c9b:	e8 2d ef ff ff       	call   800bcd <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  801ca0:	85 db                	test   %ebx,%ebx
  801ca2:	75 ca                	jne    801c6e <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  801ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca7:	5b                   	pop    %ebx
  801ca8:	5e                   	pop    %esi
  801ca9:	5f                   	pop    %edi
  801caa:	5d                   	pop    %ebp
  801cab:	c3                   	ret    

00801cac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cb7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801cba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cc0:	8b 52 50             	mov    0x50(%edx),%edx
  801cc3:	39 ca                	cmp    %ecx,%edx
  801cc5:	75 0d                	jne    801cd4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801cc7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ccf:	8b 40 48             	mov    0x48(%eax),%eax
  801cd2:	eb 0f                	jmp    801ce3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cd4:	83 c0 01             	add    $0x1,%eax
  801cd7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cdc:	75 d9                	jne    801cb7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ceb:	89 d0                	mov    %edx,%eax
  801ced:	c1 e8 16             	shr    $0x16,%eax
  801cf0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cfc:	f6 c1 01             	test   $0x1,%cl
  801cff:	74 1d                	je     801d1e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d01:	c1 ea 0c             	shr    $0xc,%edx
  801d04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d0b:	f6 c2 01             	test   $0x1,%dl
  801d0e:	74 0e                	je     801d1e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d10:	c1 ea 0c             	shr    $0xc,%edx
  801d13:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d1a:	ef 
  801d1b:	0f b7 c0             	movzwl %ax,%eax
}
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <__udivdi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 f6                	test   %esi,%esi
  801d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d3d:	89 ca                	mov    %ecx,%edx
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	75 3d                	jne    801d80 <__udivdi3+0x60>
  801d43:	39 cf                	cmp    %ecx,%edi
  801d45:	0f 87 c5 00 00 00    	ja     801e10 <__udivdi3+0xf0>
  801d4b:	85 ff                	test   %edi,%edi
  801d4d:	89 fd                	mov    %edi,%ebp
  801d4f:	75 0b                	jne    801d5c <__udivdi3+0x3c>
  801d51:	b8 01 00 00 00       	mov    $0x1,%eax
  801d56:	31 d2                	xor    %edx,%edx
  801d58:	f7 f7                	div    %edi
  801d5a:	89 c5                	mov    %eax,%ebp
  801d5c:	89 c8                	mov    %ecx,%eax
  801d5e:	31 d2                	xor    %edx,%edx
  801d60:	f7 f5                	div    %ebp
  801d62:	89 c1                	mov    %eax,%ecx
  801d64:	89 d8                	mov    %ebx,%eax
  801d66:	89 cf                	mov    %ecx,%edi
  801d68:	f7 f5                	div    %ebp
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	39 ce                	cmp    %ecx,%esi
  801d82:	77 74                	ja     801df8 <__udivdi3+0xd8>
  801d84:	0f bd fe             	bsr    %esi,%edi
  801d87:	83 f7 1f             	xor    $0x1f,%edi
  801d8a:	0f 84 98 00 00 00    	je     801e28 <__udivdi3+0x108>
  801d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	89 c5                	mov    %eax,%ebp
  801d99:	29 fb                	sub    %edi,%ebx
  801d9b:	d3 e6                	shl    %cl,%esi
  801d9d:	89 d9                	mov    %ebx,%ecx
  801d9f:	d3 ed                	shr    %cl,%ebp
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	d3 e0                	shl    %cl,%eax
  801da5:	09 ee                	or     %ebp,%esi
  801da7:	89 d9                	mov    %ebx,%ecx
  801da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801dad:	89 d5                	mov    %edx,%ebp
  801daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801db3:	d3 ed                	shr    %cl,%ebp
  801db5:	89 f9                	mov    %edi,%ecx
  801db7:	d3 e2                	shl    %cl,%edx
  801db9:	89 d9                	mov    %ebx,%ecx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	09 c2                	or     %eax,%edx
  801dbf:	89 d0                	mov    %edx,%eax
  801dc1:	89 ea                	mov    %ebp,%edx
  801dc3:	f7 f6                	div    %esi
  801dc5:	89 d5                	mov    %edx,%ebp
  801dc7:	89 c3                	mov    %eax,%ebx
  801dc9:	f7 64 24 0c          	mull   0xc(%esp)
  801dcd:	39 d5                	cmp    %edx,%ebp
  801dcf:	72 10                	jb     801de1 <__udivdi3+0xc1>
  801dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801dd5:	89 f9                	mov    %edi,%ecx
  801dd7:	d3 e6                	shl    %cl,%esi
  801dd9:	39 c6                	cmp    %eax,%esi
  801ddb:	73 07                	jae    801de4 <__udivdi3+0xc4>
  801ddd:	39 d5                	cmp    %edx,%ebp
  801ddf:	75 03                	jne    801de4 <__udivdi3+0xc4>
  801de1:	83 eb 01             	sub    $0x1,%ebx
  801de4:	31 ff                	xor    %edi,%edi
  801de6:	89 d8                	mov    %ebx,%eax
  801de8:	89 fa                	mov    %edi,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	31 ff                	xor    %edi,%edi
  801dfa:	31 db                	xor    %ebx,%ebx
  801dfc:	89 d8                	mov    %ebx,%eax
  801dfe:	89 fa                	mov    %edi,%edx
  801e00:	83 c4 1c             	add    $0x1c,%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
  801e08:	90                   	nop
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	89 d8                	mov    %ebx,%eax
  801e12:	f7 f7                	div    %edi
  801e14:	31 ff                	xor    %edi,%edi
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	89 fa                	mov    %edi,%edx
  801e1c:	83 c4 1c             	add    $0x1c,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    
  801e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e28:	39 ce                	cmp    %ecx,%esi
  801e2a:	72 0c                	jb     801e38 <__udivdi3+0x118>
  801e2c:	31 db                	xor    %ebx,%ebx
  801e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e32:	0f 87 34 ff ff ff    	ja     801d6c <__udivdi3+0x4c>
  801e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e3d:	e9 2a ff ff ff       	jmp    801d6c <__udivdi3+0x4c>
  801e42:	66 90                	xchg   %ax,%ax
  801e44:	66 90                	xchg   %ax,%ax
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__umoddi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 1c             	sub    $0x1c,%esp
  801e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e67:	85 d2                	test   %edx,%edx
  801e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e71:	89 f3                	mov    %esi,%ebx
  801e73:	89 3c 24             	mov    %edi,(%esp)
  801e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7a:	75 1c                	jne    801e98 <__umoddi3+0x48>
  801e7c:	39 f7                	cmp    %esi,%edi
  801e7e:	76 50                	jbe    801ed0 <__umoddi3+0x80>
  801e80:	89 c8                	mov    %ecx,%eax
  801e82:	89 f2                	mov    %esi,%edx
  801e84:	f7 f7                	div    %edi
  801e86:	89 d0                	mov    %edx,%eax
  801e88:	31 d2                	xor    %edx,%edx
  801e8a:	83 c4 1c             	add    $0x1c,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    
  801e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e98:	39 f2                	cmp    %esi,%edx
  801e9a:	89 d0                	mov    %edx,%eax
  801e9c:	77 52                	ja     801ef0 <__umoddi3+0xa0>
  801e9e:	0f bd ea             	bsr    %edx,%ebp
  801ea1:	83 f5 1f             	xor    $0x1f,%ebp
  801ea4:	75 5a                	jne    801f00 <__umoddi3+0xb0>
  801ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eaa:	0f 82 e0 00 00 00    	jb     801f90 <__umoddi3+0x140>
  801eb0:	39 0c 24             	cmp    %ecx,(%esp)
  801eb3:	0f 86 d7 00 00 00    	jbe    801f90 <__umoddi3+0x140>
  801eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ec1:	83 c4 1c             	add    $0x1c,%esp
  801ec4:	5b                   	pop    %ebx
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    
  801ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ed0:	85 ff                	test   %edi,%edi
  801ed2:	89 fd                	mov    %edi,%ebp
  801ed4:	75 0b                	jne    801ee1 <__umoddi3+0x91>
  801ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	f7 f7                	div    %edi
  801edf:	89 c5                	mov    %eax,%ebp
  801ee1:	89 f0                	mov    %esi,%eax
  801ee3:	31 d2                	xor    %edx,%edx
  801ee5:	f7 f5                	div    %ebp
  801ee7:	89 c8                	mov    %ecx,%eax
  801ee9:	f7 f5                	div    %ebp
  801eeb:	89 d0                	mov    %edx,%eax
  801eed:	eb 99                	jmp    801e88 <__umoddi3+0x38>
  801eef:	90                   	nop
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	89 f2                	mov    %esi,%edx
  801ef4:	83 c4 1c             	add    $0x1c,%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5f                   	pop    %edi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    
  801efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f00:	8b 34 24             	mov    (%esp),%esi
  801f03:	bf 20 00 00 00       	mov    $0x20,%edi
  801f08:	89 e9                	mov    %ebp,%ecx
  801f0a:	29 ef                	sub    %ebp,%edi
  801f0c:	d3 e0                	shl    %cl,%eax
  801f0e:	89 f9                	mov    %edi,%ecx
  801f10:	89 f2                	mov    %esi,%edx
  801f12:	d3 ea                	shr    %cl,%edx
  801f14:	89 e9                	mov    %ebp,%ecx
  801f16:	09 c2                	or     %eax,%edx
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	89 14 24             	mov    %edx,(%esp)
  801f1d:	89 f2                	mov    %esi,%edx
  801f1f:	d3 e2                	shl    %cl,%edx
  801f21:	89 f9                	mov    %edi,%ecx
  801f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f2b:	d3 e8                	shr    %cl,%eax
  801f2d:	89 e9                	mov    %ebp,%ecx
  801f2f:	89 c6                	mov    %eax,%esi
  801f31:	d3 e3                	shl    %cl,%ebx
  801f33:	89 f9                	mov    %edi,%ecx
  801f35:	89 d0                	mov    %edx,%eax
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	89 e9                	mov    %ebp,%ecx
  801f3b:	09 d8                	or     %ebx,%eax
  801f3d:	89 d3                	mov    %edx,%ebx
  801f3f:	89 f2                	mov    %esi,%edx
  801f41:	f7 34 24             	divl   (%esp)
  801f44:	89 d6                	mov    %edx,%esi
  801f46:	d3 e3                	shl    %cl,%ebx
  801f48:	f7 64 24 04          	mull   0x4(%esp)
  801f4c:	39 d6                	cmp    %edx,%esi
  801f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f52:	89 d1                	mov    %edx,%ecx
  801f54:	89 c3                	mov    %eax,%ebx
  801f56:	72 08                	jb     801f60 <__umoddi3+0x110>
  801f58:	75 11                	jne    801f6b <__umoddi3+0x11b>
  801f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f5e:	73 0b                	jae    801f6b <__umoddi3+0x11b>
  801f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f64:	1b 14 24             	sbb    (%esp),%edx
  801f67:	89 d1                	mov    %edx,%ecx
  801f69:	89 c3                	mov    %eax,%ebx
  801f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f6f:	29 da                	sub    %ebx,%edx
  801f71:	19 ce                	sbb    %ecx,%esi
  801f73:	89 f9                	mov    %edi,%ecx
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	d3 e0                	shl    %cl,%eax
  801f79:	89 e9                	mov    %ebp,%ecx
  801f7b:	d3 ea                	shr    %cl,%edx
  801f7d:	89 e9                	mov    %ebp,%ecx
  801f7f:	d3 ee                	shr    %cl,%esi
  801f81:	09 d0                	or     %edx,%eax
  801f83:	89 f2                	mov    %esi,%edx
  801f85:	83 c4 1c             	add    $0x1c,%esp
  801f88:	5b                   	pop    %ebx
  801f89:	5e                   	pop    %esi
  801f8a:	5f                   	pop    %edi
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    
  801f8d:	8d 76 00             	lea    0x0(%esi),%esi
  801f90:	29 f9                	sub    %edi,%ecx
  801f92:	19 d6                	sbb    %edx,%esi
  801f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f9c:	e9 18 ff ff ff       	jmp    801eb9 <__umoddi3+0x69>
