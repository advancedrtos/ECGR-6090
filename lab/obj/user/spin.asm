
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 e0 13 80 00       	push   $0x8013e0
  80003f:	e8 5c 01 00 00       	call   8001a0 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 df 0d 00 00       	call   800e28 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 58 14 80 00       	push   $0x801458
  800058:	e8 43 01 00 00       	call   8001a0 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 08 14 80 00       	push   $0x801408
  80006c:	e8 2f 01 00 00       	call   8001a0 <cprintf>
	sys_yield();
  800071:	e8 93 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  800076:	e8 8e 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  80007b:	e8 89 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  800080:	e8 84 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  800085:	e8 7f 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  80008a:	e8 7a 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  80008f:	e8 75 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  800094:	e8 70 0a 00 00       	call   800b09 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 30 14 80 00 	movl   $0x801430,(%esp)
  8000a0:	e8 fb 00 00 00       	call   8001a0 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 fc 09 00 00       	call   800aa9 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  8000c0:	e8 25 0a 00 00       	call   800aea <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 a1 09 00 00       	call   800aa9 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	75 1a                	jne    800146 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	68 ff 00 00 00       	push   $0xff
  800134:	8d 43 08             	lea    0x8(%ebx),%eax
  800137:	50                   	push   %eax
  800138:	e8 2f 09 00 00       	call   800a6c <sys_cputs>
		b->idx = 0;
  80013d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800143:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800146:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 0d 01 80 00       	push   $0x80010d
  80017e:	e8 54 01 00 00       	call   8002d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 d4 08 00 00       	call   800a6c <sys_cputs>

	return b.cnt;
}
  800198:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 1c             	sub    $0x1c,%esp
  8001bd:	89 c7                	mov    %eax,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001db:	39 d3                	cmp    %edx,%ebx
  8001dd:	72 05                	jb     8001e4 <printnum+0x30>
  8001df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e2:	77 45                	ja     800229 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 18             	pushl  0x18(%ebp)
  8001ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ed:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f0:	53                   	push   %ebx
  8001f1:	ff 75 10             	pushl  0x10(%ebp)
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800200:	ff 75 d8             	pushl  -0x28(%ebp)
  800203:	e8 48 0f 00 00       	call   801150 <__udivdi3>
  800208:	83 c4 18             	add    $0x18,%esp
  80020b:	52                   	push   %edx
  80020c:	50                   	push   %eax
  80020d:	89 f2                	mov    %esi,%edx
  80020f:	89 f8                	mov    %edi,%eax
  800211:	e8 9e ff ff ff       	call   8001b4 <printnum>
  800216:	83 c4 20             	add    $0x20,%esp
  800219:	eb 18                	jmp    800233 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	ff d7                	call   *%edi
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	eb 03                	jmp    80022c <printnum+0x78>
  800229:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f e8                	jg     80021b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023d:	ff 75 e0             	pushl  -0x20(%ebp)
  800240:	ff 75 dc             	pushl  -0x24(%ebp)
  800243:	ff 75 d8             	pushl  -0x28(%ebp)
  800246:	e8 35 10 00 00       	call   801280 <__umoddi3>
  80024b:	83 c4 14             	add    $0x14,%esp
  80024e:	0f be 80 80 14 80 00 	movsbl 0x801480(%eax),%eax
  800255:	50                   	push   %eax
  800256:	ff d7                	call   *%edi
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800266:	83 fa 01             	cmp    $0x1,%edx
  800269:	7e 0e                	jle    800279 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800270:	89 08                	mov    %ecx,(%eax)
  800272:	8b 02                	mov    (%edx),%eax
  800274:	8b 52 04             	mov    0x4(%edx),%edx
  800277:	eb 22                	jmp    80029b <getuint+0x38>
	else if (lflag)
  800279:	85 d2                	test   %edx,%edx
  80027b:	74 10                	je     80028d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	ba 00 00 00 00       	mov    $0x0,%edx
  80028b:	eb 0e                	jmp    80029b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ac:	73 0a                	jae    8002b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	88 02                	mov    %al,(%edx)
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c3:	50                   	push   %eax
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ca:	ff 75 08             	pushl  0x8(%ebp)
  8002cd:	e8 05 00 00 00       	call   8002d7 <vprintfmt>
	va_end(ap);
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 2c             	sub    $0x2c,%esp
  8002e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e9:	eb 12                	jmp    8002fd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	0f 84 89 03 00 00    	je     80067c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	53                   	push   %ebx
  8002f7:	50                   	push   %eax
  8002f8:	ff d6                	call   *%esi
  8002fa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fd:	83 c7 01             	add    $0x1,%edi
  800300:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800304:	83 f8 25             	cmp    $0x25,%eax
  800307:	75 e2                	jne    8002eb <vprintfmt+0x14>
  800309:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80030d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800314:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	eb 07                	jmp    800330 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8d 47 01             	lea    0x1(%edi),%eax
  800333:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800336:	0f b6 07             	movzbl (%edi),%eax
  800339:	0f b6 c8             	movzbl %al,%ecx
  80033c:	83 e8 23             	sub    $0x23,%eax
  80033f:	3c 55                	cmp    $0x55,%al
  800341:	0f 87 1a 03 00 00    	ja     800661 <vprintfmt+0x38a>
  800347:	0f b6 c0             	movzbl %al,%eax
  80034a:	ff 24 85 c0 15 80 00 	jmp    *0x8015c0(,%eax,4)
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800354:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800358:	eb d6                	jmp    800330 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035d:	b8 00 00 00 00       	mov    $0x0,%eax
  800362:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800365:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800368:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80036c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80036f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800372:	83 fa 09             	cmp    $0x9,%edx
  800375:	77 39                	ja     8003b0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800377:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037a:	eb e9                	jmp    800365 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 48 04             	lea    0x4(%eax),%ecx
  800382:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800385:	8b 00                	mov    (%eax),%eax
  800387:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038d:	eb 27                	jmp    8003b6 <vprintfmt+0xdf>
  80038f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800392:	85 c0                	test   %eax,%eax
  800394:	b9 00 00 00 00       	mov    $0x0,%ecx
  800399:	0f 49 c8             	cmovns %eax,%ecx
  80039c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a2:	eb 8c                	jmp    800330 <vprintfmt+0x59>
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ae:	eb 80                	jmp    800330 <vprintfmt+0x59>
  8003b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ba:	0f 89 70 ff ff ff    	jns    800330 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	e9 5e ff ff ff       	jmp    800330 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d8:	e9 53 ff ff ff       	jmp    800330 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	83 ec 08             	sub    $0x8,%esp
  8003e9:	53                   	push   %ebx
  8003ea:	ff 30                	pushl  (%eax)
  8003ec:	ff d6                	call   *%esi
			break;
  8003ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f4:	e9 04 ff ff ff       	jmp    8002fd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 50 04             	lea    0x4(%eax),%edx
  8003ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800402:	8b 00                	mov    (%eax),%eax
  800404:	99                   	cltd   
  800405:	31 d0                	xor    %edx,%eax
  800407:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800409:	83 f8 0f             	cmp    $0xf,%eax
  80040c:	7f 0b                	jg     800419 <vprintfmt+0x142>
  80040e:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  800415:	85 d2                	test   %edx,%edx
  800417:	75 18                	jne    800431 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800419:	50                   	push   %eax
  80041a:	68 98 14 80 00       	push   $0x801498
  80041f:	53                   	push   %ebx
  800420:	56                   	push   %esi
  800421:	e8 94 fe ff ff       	call   8002ba <printfmt>
  800426:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042c:	e9 cc fe ff ff       	jmp    8002fd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800431:	52                   	push   %edx
  800432:	68 a1 14 80 00       	push   $0x8014a1
  800437:	53                   	push   %ebx
  800438:	56                   	push   %esi
  800439:	e8 7c fe ff ff       	call   8002ba <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800444:	e9 b4 fe ff ff       	jmp    8002fd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800454:	85 ff                	test   %edi,%edi
  800456:	b8 91 14 80 00       	mov    $0x801491,%eax
  80045b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80045e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800462:	0f 8e 94 00 00 00    	jle    8004fc <vprintfmt+0x225>
  800468:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046c:	0f 84 98 00 00 00    	je     80050a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 d0             	pushl  -0x30(%ebp)
  800478:	57                   	push   %edi
  800479:	e8 86 02 00 00       	call   800704 <strnlen>
  80047e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800481:	29 c1                	sub    %eax,%ecx
  800483:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800489:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800490:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800493:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	eb 0f                	jmp    8004a6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	53                   	push   %ebx
  80049b:	ff 75 e0             	pushl  -0x20(%ebp)
  80049e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a0:	83 ef 01             	sub    $0x1,%edi
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	85 ff                	test   %edi,%edi
  8004a8:	7f ed                	jg     800497 <vprintfmt+0x1c0>
  8004aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b0:	85 c9                	test   %ecx,%ecx
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	0f 49 c1             	cmovns %ecx,%eax
  8004ba:	29 c1                	sub    %eax,%ecx
  8004bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c5:	89 cb                	mov    %ecx,%ebx
  8004c7:	eb 4d                	jmp    800516 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cd:	74 1b                	je     8004ea <vprintfmt+0x213>
  8004cf:	0f be c0             	movsbl %al,%eax
  8004d2:	83 e8 20             	sub    $0x20,%eax
  8004d5:	83 f8 5e             	cmp    $0x5e,%eax
  8004d8:	76 10                	jbe    8004ea <vprintfmt+0x213>
					putch('?', putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	6a 3f                	push   $0x3f
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb 0d                	jmp    8004f7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	52                   	push   %edx
  8004f1:	ff 55 08             	call   *0x8(%ebp)
  8004f4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f7:	83 eb 01             	sub    $0x1,%ebx
  8004fa:	eb 1a                	jmp    800516 <vprintfmt+0x23f>
  8004fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800502:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800505:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800508:	eb 0c                	jmp    800516 <vprintfmt+0x23f>
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800516:	83 c7 01             	add    $0x1,%edi
  800519:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051d:	0f be d0             	movsbl %al,%edx
  800520:	85 d2                	test   %edx,%edx
  800522:	74 23                	je     800547 <vprintfmt+0x270>
  800524:	85 f6                	test   %esi,%esi
  800526:	78 a1                	js     8004c9 <vprintfmt+0x1f2>
  800528:	83 ee 01             	sub    $0x1,%esi
  80052b:	79 9c                	jns    8004c9 <vprintfmt+0x1f2>
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	eb 18                	jmp    80054f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	6a 20                	push   $0x20
  80053d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053f:	83 ef 01             	sub    $0x1,%edi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb 08                	jmp    80054f <vprintfmt+0x278>
  800547:	89 df                	mov    %ebx,%edi
  800549:	8b 75 08             	mov    0x8(%ebp),%esi
  80054c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054f:	85 ff                	test   %edi,%edi
  800551:	7f e4                	jg     800537 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800556:	e9 a2 fd ff ff       	jmp    8002fd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055b:	83 fa 01             	cmp    $0x1,%edx
  80055e:	7e 16                	jle    800576 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 08             	lea    0x8(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 50 04             	mov    0x4(%eax),%edx
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	eb 32                	jmp    8005a8 <vprintfmt+0x2d1>
	else if (lflag)
  800576:	85 d2                	test   %edx,%edx
  800578:	74 18                	je     800592 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 50 04             	lea    0x4(%eax),%edx
  800580:	89 55 14             	mov    %edx,0x14(%ebp)
  800583:	8b 00                	mov    (%eax),%eax
  800585:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800588:	89 c1                	mov    %eax,%ecx
  80058a:	c1 f9 1f             	sar    $0x1f,%ecx
  80058d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800590:	eb 16                	jmp    8005a8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a0:	89 c1                	mov    %eax,%ecx
  8005a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b7:	79 74                	jns    80062d <vprintfmt+0x356>
				putch('-', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 2d                	push   $0x2d
  8005bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c7:	f7 d8                	neg    %eax
  8005c9:	83 d2 00             	adc    $0x0,%edx
  8005cc:	f7 da                	neg    %edx
  8005ce:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d6:	eb 55                	jmp    80062d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005db:	e8 83 fc ff ff       	call   800263 <getuint>
			base = 10;
  8005e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e5:	eb 46                	jmp    80062d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ea:	e8 74 fc ff ff       	call   800263 <getuint>
			base = 8;
  8005ef:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005f4:	eb 37                	jmp    80062d <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	53                   	push   %ebx
  8005fa:	6a 30                	push   $0x30
  8005fc:	ff d6                	call   *%esi
			putch('x', putdat);
  8005fe:	83 c4 08             	add    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 78                	push   $0x78
  800604:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800616:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800619:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80061e:	eb 0d                	jmp    80062d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800620:	8d 45 14             	lea    0x14(%ebp),%eax
  800623:	e8 3b fc ff ff       	call   800263 <getuint>
			base = 16;
  800628:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800634:	57                   	push   %edi
  800635:	ff 75 e0             	pushl  -0x20(%ebp)
  800638:	51                   	push   %ecx
  800639:	52                   	push   %edx
  80063a:	50                   	push   %eax
  80063b:	89 da                	mov    %ebx,%edx
  80063d:	89 f0                	mov    %esi,%eax
  80063f:	e8 70 fb ff ff       	call   8001b4 <printnum>
			break;
  800644:	83 c4 20             	add    $0x20,%esp
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064a:	e9 ae fc ff ff       	jmp    8002fd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	51                   	push   %ecx
  800654:	ff d6                	call   *%esi
			break;
  800656:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80065c:	e9 9c fc ff ff       	jmp    8002fd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	6a 25                	push   $0x25
  800667:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	eb 03                	jmp    800671 <vprintfmt+0x39a>
  80066e:	83 ef 01             	sub    $0x1,%edi
  800671:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800675:	75 f7                	jne    80066e <vprintfmt+0x397>
  800677:	e9 81 fc ff ff       	jmp    8002fd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80067c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067f:	5b                   	pop    %ebx
  800680:	5e                   	pop    %esi
  800681:	5f                   	pop    %edi
  800682:	5d                   	pop    %ebp
  800683:	c3                   	ret    

00800684 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	83 ec 18             	sub    $0x18,%esp
  80068a:	8b 45 08             	mov    0x8(%ebp),%eax
  80068d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800690:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800693:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800697:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 26                	je     8006cb <vsnprintf+0x47>
  8006a5:	85 d2                	test   %edx,%edx
  8006a7:	7e 22                	jle    8006cb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a9:	ff 75 14             	pushl  0x14(%ebp)
  8006ac:	ff 75 10             	pushl  0x10(%ebp)
  8006af:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b2:	50                   	push   %eax
  8006b3:	68 9d 02 80 00       	push   $0x80029d
  8006b8:	e8 1a fc ff ff       	call   8002d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	eb 05                	jmp    8006d0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    

008006d2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006db:	50                   	push   %eax
  8006dc:	ff 75 10             	pushl  0x10(%ebp)
  8006df:	ff 75 0c             	pushl  0xc(%ebp)
  8006e2:	ff 75 08             	pushl  0x8(%ebp)
  8006e5:	e8 9a ff ff ff       	call   800684 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f7:	eb 03                	jmp    8006fc <strlen+0x10>
		n++;
  8006f9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800700:	75 f7                	jne    8006f9 <strlen+0xd>
		n++;
	return n;
}
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070d:	ba 00 00 00 00       	mov    $0x0,%edx
  800712:	eb 03                	jmp    800717 <strnlen+0x13>
		n++;
  800714:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800717:	39 c2                	cmp    %eax,%edx
  800719:	74 08                	je     800723 <strnlen+0x1f>
  80071b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80071f:	75 f3                	jne    800714 <strnlen+0x10>
  800721:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	53                   	push   %ebx
  800729:	8b 45 08             	mov    0x8(%ebp),%eax
  80072c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072f:	89 c2                	mov    %eax,%edx
  800731:	83 c2 01             	add    $0x1,%edx
  800734:	83 c1 01             	add    $0x1,%ecx
  800737:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80073b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80073e:	84 db                	test   %bl,%bl
  800740:	75 ef                	jne    800731 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800742:	5b                   	pop    %ebx
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	53                   	push   %ebx
  800749:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074c:	53                   	push   %ebx
  80074d:	e8 9a ff ff ff       	call   8006ec <strlen>
  800752:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	01 d8                	add    %ebx,%eax
  80075a:	50                   	push   %eax
  80075b:	e8 c5 ff ff ff       	call   800725 <strcpy>
	return dst;
}
  800760:	89 d8                	mov    %ebx,%eax
  800762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800772:	89 f3                	mov    %esi,%ebx
  800774:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800777:	89 f2                	mov    %esi,%edx
  800779:	eb 0f                	jmp    80078a <strncpy+0x23>
		*dst++ = *src;
  80077b:	83 c2 01             	add    $0x1,%edx
  80077e:	0f b6 01             	movzbl (%ecx),%eax
  800781:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800784:	80 39 01             	cmpb   $0x1,(%ecx)
  800787:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078a:	39 da                	cmp    %ebx,%edx
  80078c:	75 ed                	jne    80077b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078e:	89 f0                	mov    %esi,%eax
  800790:	5b                   	pop    %ebx
  800791:	5e                   	pop    %esi
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	56                   	push   %esi
  800798:	53                   	push   %ebx
  800799:	8b 75 08             	mov    0x8(%ebp),%esi
  80079c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079f:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a4:	85 d2                	test   %edx,%edx
  8007a6:	74 21                	je     8007c9 <strlcpy+0x35>
  8007a8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ac:	89 f2                	mov    %esi,%edx
  8007ae:	eb 09                	jmp    8007b9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b0:	83 c2 01             	add    $0x1,%edx
  8007b3:	83 c1 01             	add    $0x1,%ecx
  8007b6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b9:	39 c2                	cmp    %eax,%edx
  8007bb:	74 09                	je     8007c6 <strlcpy+0x32>
  8007bd:	0f b6 19             	movzbl (%ecx),%ebx
  8007c0:	84 db                	test   %bl,%bl
  8007c2:	75 ec                	jne    8007b0 <strlcpy+0x1c>
  8007c4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c9:	29 f0                	sub    %esi,%eax
}
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d8:	eb 06                	jmp    8007e0 <strcmp+0x11>
		p++, q++;
  8007da:	83 c1 01             	add    $0x1,%ecx
  8007dd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e0:	0f b6 01             	movzbl (%ecx),%eax
  8007e3:	84 c0                	test   %al,%al
  8007e5:	74 04                	je     8007eb <strcmp+0x1c>
  8007e7:	3a 02                	cmp    (%edx),%al
  8007e9:	74 ef                	je     8007da <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007eb:	0f b6 c0             	movzbl %al,%eax
  8007ee:	0f b6 12             	movzbl (%edx),%edx
  8007f1:	29 d0                	sub    %edx,%eax
}
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ff:	89 c3                	mov    %eax,%ebx
  800801:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800804:	eb 06                	jmp    80080c <strncmp+0x17>
		n--, p++, q++;
  800806:	83 c0 01             	add    $0x1,%eax
  800809:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080c:	39 d8                	cmp    %ebx,%eax
  80080e:	74 15                	je     800825 <strncmp+0x30>
  800810:	0f b6 08             	movzbl (%eax),%ecx
  800813:	84 c9                	test   %cl,%cl
  800815:	74 04                	je     80081b <strncmp+0x26>
  800817:	3a 0a                	cmp    (%edx),%cl
  800819:	74 eb                	je     800806 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081b:	0f b6 00             	movzbl (%eax),%eax
  80081e:	0f b6 12             	movzbl (%edx),%edx
  800821:	29 d0                	sub    %edx,%eax
  800823:	eb 05                	jmp    80082a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800825:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80082a:	5b                   	pop    %ebx
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800837:	eb 07                	jmp    800840 <strchr+0x13>
		if (*s == c)
  800839:	38 ca                	cmp    %cl,%dl
  80083b:	74 0f                	je     80084c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	0f b6 10             	movzbl (%eax),%edx
  800843:	84 d2                	test   %dl,%dl
  800845:	75 f2                	jne    800839 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800858:	eb 03                	jmp    80085d <strfind+0xf>
  80085a:	83 c0 01             	add    $0x1,%eax
  80085d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800860:	38 ca                	cmp    %cl,%dl
  800862:	74 04                	je     800868 <strfind+0x1a>
  800864:	84 d2                	test   %dl,%dl
  800866:	75 f2                	jne    80085a <strfind+0xc>
			break;
	return (char *) s;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	57                   	push   %edi
  80086e:	56                   	push   %esi
  80086f:	53                   	push   %ebx
  800870:	8b 7d 08             	mov    0x8(%ebp),%edi
  800873:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800876:	85 c9                	test   %ecx,%ecx
  800878:	74 36                	je     8008b0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800880:	75 28                	jne    8008aa <memset+0x40>
  800882:	f6 c1 03             	test   $0x3,%cl
  800885:	75 23                	jne    8008aa <memset+0x40>
		c &= 0xFF;
  800887:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088b:	89 d3                	mov    %edx,%ebx
  80088d:	c1 e3 08             	shl    $0x8,%ebx
  800890:	89 d6                	mov    %edx,%esi
  800892:	c1 e6 18             	shl    $0x18,%esi
  800895:	89 d0                	mov    %edx,%eax
  800897:	c1 e0 10             	shl    $0x10,%eax
  80089a:	09 f0                	or     %esi,%eax
  80089c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80089e:	89 d8                	mov    %ebx,%eax
  8008a0:	09 d0                	or     %edx,%eax
  8008a2:	c1 e9 02             	shr    $0x2,%ecx
  8008a5:	fc                   	cld    
  8008a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a8:	eb 06                	jmp    8008b0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ad:	fc                   	cld    
  8008ae:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b0:	89 f8                	mov    %edi,%eax
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5f                   	pop    %edi
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c5:	39 c6                	cmp    %eax,%esi
  8008c7:	73 35                	jae    8008fe <memmove+0x47>
  8008c9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cc:	39 d0                	cmp    %edx,%eax
  8008ce:	73 2e                	jae    8008fe <memmove+0x47>
		s += n;
		d += n;
  8008d0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d3:	89 d6                	mov    %edx,%esi
  8008d5:	09 fe                	or     %edi,%esi
  8008d7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008dd:	75 13                	jne    8008f2 <memmove+0x3b>
  8008df:	f6 c1 03             	test   $0x3,%cl
  8008e2:	75 0e                	jne    8008f2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008e4:	83 ef 04             	sub    $0x4,%edi
  8008e7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ea:	c1 e9 02             	shr    $0x2,%ecx
  8008ed:	fd                   	std    
  8008ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f0:	eb 09                	jmp    8008fb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f2:	83 ef 01             	sub    $0x1,%edi
  8008f5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f8:	fd                   	std    
  8008f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fb:	fc                   	cld    
  8008fc:	eb 1d                	jmp    80091b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fe:	89 f2                	mov    %esi,%edx
  800900:	09 c2                	or     %eax,%edx
  800902:	f6 c2 03             	test   $0x3,%dl
  800905:	75 0f                	jne    800916 <memmove+0x5f>
  800907:	f6 c1 03             	test   $0x3,%cl
  80090a:	75 0a                	jne    800916 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80090c:	c1 e9 02             	shr    $0x2,%ecx
  80090f:	89 c7                	mov    %eax,%edi
  800911:	fc                   	cld    
  800912:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800914:	eb 05                	jmp    80091b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800916:	89 c7                	mov    %eax,%edi
  800918:	fc                   	cld    
  800919:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091b:	5e                   	pop    %esi
  80091c:	5f                   	pop    %edi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800922:	ff 75 10             	pushl  0x10(%ebp)
  800925:	ff 75 0c             	pushl  0xc(%ebp)
  800928:	ff 75 08             	pushl  0x8(%ebp)
  80092b:	e8 87 ff ff ff       	call   8008b7 <memmove>
}
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 c6                	mov    %eax,%esi
  80093f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800942:	eb 1a                	jmp    80095e <memcmp+0x2c>
		if (*s1 != *s2)
  800944:	0f b6 08             	movzbl (%eax),%ecx
  800947:	0f b6 1a             	movzbl (%edx),%ebx
  80094a:	38 d9                	cmp    %bl,%cl
  80094c:	74 0a                	je     800958 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80094e:	0f b6 c1             	movzbl %cl,%eax
  800951:	0f b6 db             	movzbl %bl,%ebx
  800954:	29 d8                	sub    %ebx,%eax
  800956:	eb 0f                	jmp    800967 <memcmp+0x35>
		s1++, s2++;
  800958:	83 c0 01             	add    $0x1,%eax
  80095b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095e:	39 f0                	cmp    %esi,%eax
  800960:	75 e2                	jne    800944 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800972:	89 c1                	mov    %eax,%ecx
  800974:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800977:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097b:	eb 0a                	jmp    800987 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	39 da                	cmp    %ebx,%edx
  800982:	74 07                	je     80098b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	39 c8                	cmp    %ecx,%eax
  800989:	72 f2                	jb     80097d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80098b:	5b                   	pop    %ebx
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800997:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099a:	eb 03                	jmp    80099f <strtol+0x11>
		s++;
  80099c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099f:	0f b6 01             	movzbl (%ecx),%eax
  8009a2:	3c 20                	cmp    $0x20,%al
  8009a4:	74 f6                	je     80099c <strtol+0xe>
  8009a6:	3c 09                	cmp    $0x9,%al
  8009a8:	74 f2                	je     80099c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009aa:	3c 2b                	cmp    $0x2b,%al
  8009ac:	75 0a                	jne    8009b8 <strtol+0x2a>
		s++;
  8009ae:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b6:	eb 11                	jmp    8009c9 <strtol+0x3b>
  8009b8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009bd:	3c 2d                	cmp    $0x2d,%al
  8009bf:	75 08                	jne    8009c9 <strtol+0x3b>
		s++, neg = 1;
  8009c1:	83 c1 01             	add    $0x1,%ecx
  8009c4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009cf:	75 15                	jne    8009e6 <strtol+0x58>
  8009d1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d4:	75 10                	jne    8009e6 <strtol+0x58>
  8009d6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009da:	75 7c                	jne    800a58 <strtol+0xca>
		s += 2, base = 16;
  8009dc:	83 c1 02             	add    $0x2,%ecx
  8009df:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e4:	eb 16                	jmp    8009fc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e6:	85 db                	test   %ebx,%ebx
  8009e8:	75 12                	jne    8009fc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ea:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ef:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f2:	75 08                	jne    8009fc <strtol+0x6e>
		s++, base = 8;
  8009f4:	83 c1 01             	add    $0x1,%ecx
  8009f7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a04:	0f b6 11             	movzbl (%ecx),%edx
  800a07:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a0a:	89 f3                	mov    %esi,%ebx
  800a0c:	80 fb 09             	cmp    $0x9,%bl
  800a0f:	77 08                	ja     800a19 <strtol+0x8b>
			dig = *s - '0';
  800a11:	0f be d2             	movsbl %dl,%edx
  800a14:	83 ea 30             	sub    $0x30,%edx
  800a17:	eb 22                	jmp    800a3b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a19:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a1c:	89 f3                	mov    %esi,%ebx
  800a1e:	80 fb 19             	cmp    $0x19,%bl
  800a21:	77 08                	ja     800a2b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a23:	0f be d2             	movsbl %dl,%edx
  800a26:	83 ea 57             	sub    $0x57,%edx
  800a29:	eb 10                	jmp    800a3b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a2b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a2e:	89 f3                	mov    %esi,%ebx
  800a30:	80 fb 19             	cmp    $0x19,%bl
  800a33:	77 16                	ja     800a4b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a35:	0f be d2             	movsbl %dl,%edx
  800a38:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a3b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a3e:	7d 0b                	jge    800a4b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a47:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a49:	eb b9                	jmp    800a04 <strtol+0x76>

	if (endptr)
  800a4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4f:	74 0d                	je     800a5e <strtol+0xd0>
		*endptr = (char *) s;
  800a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a54:	89 0e                	mov    %ecx,(%esi)
  800a56:	eb 06                	jmp    800a5e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a58:	85 db                	test   %ebx,%ebx
  800a5a:	74 98                	je     8009f4 <strtol+0x66>
  800a5c:	eb 9e                	jmp    8009fc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	f7 da                	neg    %edx
  800a62:	85 ff                	test   %edi,%edi
  800a64:	0f 45 c2             	cmovne %edx,%eax
}
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	89 c3                	mov    %eax,%ebx
  800a7f:	89 c7                	mov    %eax,%edi
  800a81:	89 c6                	mov    %eax,%esi
  800a83:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a90:	ba 00 00 00 00       	mov    $0x0,%edx
  800a95:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9a:	89 d1                	mov    %edx,%ecx
  800a9c:	89 d3                	mov    %edx,%ebx
  800a9e:	89 d7                	mov    %edx,%edi
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab7:	b8 03 00 00 00       	mov    $0x3,%eax
  800abc:	8b 55 08             	mov    0x8(%ebp),%edx
  800abf:	89 cb                	mov    %ecx,%ebx
  800ac1:	89 cf                	mov    %ecx,%edi
  800ac3:	89 ce                	mov    %ecx,%esi
  800ac5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac7:	85 c0                	test   %eax,%eax
  800ac9:	7e 17                	jle    800ae2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800acb:	83 ec 0c             	sub    $0xc,%esp
  800ace:	50                   	push   %eax
  800acf:	6a 03                	push   $0x3
  800ad1:	68 7f 17 80 00       	push   $0x80177f
  800ad6:	6a 23                	push   $0x23
  800ad8:	68 9c 17 80 00       	push   $0x80179c
  800add:	e8 7f 05 00 00       	call   801061 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 02 00 00 00       	mov    $0x2,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_yield>:

void
sys_yield(void)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b14:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b19:	89 d1                	mov    %edx,%ecx
  800b1b:	89 d3                	mov    %edx,%ebx
  800b1d:	89 d7                	mov    %edx,%edi
  800b1f:	89 d6                	mov    %edx,%esi
  800b21:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b31:	be 00 00 00 00       	mov    $0x0,%esi
  800b36:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b44:	89 f7                	mov    %esi,%edi
  800b46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	7e 17                	jle    800b63 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4c:	83 ec 0c             	sub    $0xc,%esp
  800b4f:	50                   	push   %eax
  800b50:	6a 04                	push   $0x4
  800b52:	68 7f 17 80 00       	push   $0x80177f
  800b57:	6a 23                	push   $0x23
  800b59:	68 9c 17 80 00       	push   $0x80179c
  800b5e:	e8 fe 04 00 00       	call   801061 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	b8 05 00 00 00       	mov    $0x5,%eax
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b85:	8b 75 18             	mov    0x18(%ebp),%esi
  800b88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	7e 17                	jle    800ba5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	50                   	push   %eax
  800b92:	6a 05                	push   $0x5
  800b94:	68 7f 17 80 00       	push   $0x80177f
  800b99:	6a 23                	push   $0x23
  800b9b:	68 9c 17 80 00       	push   $0x80179c
  800ba0:	e8 bc 04 00 00       	call   801061 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbb:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	89 df                	mov    %ebx,%edi
  800bc8:	89 de                	mov    %ebx,%esi
  800bca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	7e 17                	jle    800be7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 06                	push   $0x6
  800bd6:	68 7f 17 80 00       	push   $0x80177f
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 9c 17 80 00       	push   $0x80179c
  800be2:	e8 7a 04 00 00       	call   801061 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfd:	b8 08 00 00 00       	mov    $0x8,%eax
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	89 df                	mov    %ebx,%edi
  800c0a:	89 de                	mov    %ebx,%esi
  800c0c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7e 17                	jle    800c29 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 08                	push   $0x8
  800c18:	68 7f 17 80 00       	push   $0x80177f
  800c1d:	6a 23                	push   $0x23
  800c1f:	68 9c 17 80 00       	push   $0x80179c
  800c24:	e8 38 04 00 00       	call   801061 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	89 df                	mov    %ebx,%edi
  800c4c:	89 de                	mov    %ebx,%esi
  800c4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	7e 17                	jle    800c6b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	6a 09                	push   $0x9
  800c5a:	68 7f 17 80 00       	push   $0x80177f
  800c5f:	6a 23                	push   $0x23
  800c61:	68 9c 17 80 00       	push   $0x80179c
  800c66:	e8 f6 03 00 00       	call   801061 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c81:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	89 df                	mov    %ebx,%edi
  800c8e:	89 de                	mov    %ebx,%esi
  800c90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7e 17                	jle    800cad <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c96:	83 ec 0c             	sub    $0xc,%esp
  800c99:	50                   	push   %eax
  800c9a:	6a 0a                	push   $0xa
  800c9c:	68 7f 17 80 00       	push   $0x80177f
  800ca1:	6a 23                	push   $0x23
  800ca3:	68 9c 17 80 00       	push   $0x80179c
  800ca8:	e8 b4 03 00 00       	call   801061 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	be 00 00 00 00       	mov    $0x0,%esi
  800cc0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	89 cb                	mov    %ecx,%ebx
  800cf0:	89 cf                	mov    %ecx,%edi
  800cf2:	89 ce                	mov    %ecx,%esi
  800cf4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 17                	jle    800d11 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 0d                	push   $0xd
  800d00:	68 7f 17 80 00       	push   $0x80177f
  800d05:	6a 23                	push   $0x23
  800d07:	68 9c 17 80 00       	push   $0x80179c
  800d0c:	e8 50 03 00 00       	call   801061 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d24:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d29:	89 d1                	mov    %edx,%ecx
  800d2b:	89 d3                	mov    %edx,%ebx
  800d2d:	89 d7                	mov    %edx,%edi
  800d2f:	89 d6                	mov    %edx,%esi
  800d31:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 04             	sub    $0x4,%esp
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d42:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800d44:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d48:	75 14                	jne    800d5e <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800d4a:	83 ec 04             	sub    $0x4,%esp
  800d4d:	68 ac 17 80 00       	push   $0x8017ac
  800d52:	6a 22                	push   $0x22
  800d54:	68 8f 18 80 00       	push   $0x80188f
  800d59:	e8 03 03 00 00       	call   801061 <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800d5e:	89 d8                	mov    %ebx,%eax
  800d60:	c1 e8 0c             	shr    $0xc,%eax
  800d63:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d6a:	f6 c4 08             	test   $0x8,%ah
  800d6d:	75 14                	jne    800d83 <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800d6f:	83 ec 04             	sub    $0x4,%esp
  800d72:	68 e8 17 80 00       	push   $0x8017e8
  800d77:	6a 27                	push   $0x27
  800d79:	68 8f 18 80 00       	push   $0x80188f
  800d7e:	e8 de 02 00 00       	call   801061 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	6a 07                	push   $0x7
  800d88:	68 00 f0 7f 00       	push   $0x7ff000
  800d8d:	6a 00                	push   $0x0
  800d8f:	e8 94 fd ff ff       	call   800b28 <sys_page_alloc>
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	79 14                	jns    800daf <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	68 18 18 80 00       	push   $0x801818
  800da3:	6a 2f                	push   $0x2f
  800da5:	68 8f 18 80 00       	push   $0x80188f
  800daa:	e8 b2 02 00 00       	call   801061 <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800daf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	68 00 10 00 00       	push   $0x1000
  800dbd:	53                   	push   %ebx
  800dbe:	68 00 f0 7f 00       	push   $0x7ff000
  800dc3:	e8 ef fa ff ff       	call   8008b7 <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800dc8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dcf:	53                   	push   %ebx
  800dd0:	6a 00                	push   $0x0
  800dd2:	68 00 f0 7f 00       	push   $0x7ff000
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 8d fd ff ff       	call   800b6b <sys_page_map>
  800dde:	83 c4 20             	add    $0x20,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	79 14                	jns    800df9 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	68 44 18 80 00       	push   $0x801844
  800ded:	6a 34                	push   $0x34
  800def:	68 8f 18 80 00       	push   $0x80188f
  800df4:	e8 68 02 00 00       	call   801061 <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800df9:	83 ec 08             	sub    $0x8,%esp
  800dfc:	68 00 f0 7f 00       	push   $0x7ff000
  800e01:	6a 00                	push   $0x0
  800e03:	e8 a5 fd ff ff       	call   800bad <sys_page_unmap>
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	79 14                	jns    800e23 <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800e0f:	83 ec 04             	sub    $0x4,%esp
  800e12:	68 6c 18 80 00       	push   $0x80186c
  800e17:	6a 37                	push   $0x37
  800e19:	68 8f 18 80 00       	push   $0x80188f
  800e1e:	e8 3e 02 00 00       	call   801061 <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800e23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e26:	c9                   	leave  
  800e27:	c3                   	ret    

00800e28 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800e31:	68 38 0d 80 00       	push   $0x800d38
  800e36:	e8 6c 02 00 00       	call   8010a7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e3b:	b8 07 00 00 00       	mov    $0x7,%eax
  800e40:	cd 30                	int    $0x30
  800e42:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	79 15                	jns    800e64 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800e4f:	50                   	push   %eax
  800e50:	68 9a 18 80 00       	push   $0x80189a
  800e55:	68 8d 00 00 00       	push   $0x8d
  800e5a:	68 8f 18 80 00       	push   $0x80188f
  800e5f:	e8 fd 01 00 00       	call   801061 <_panic>
  800e64:	be 00 00 00 00       	mov    $0x0,%esi
  800e69:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  800e6e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e72:	75 21                	jne    800e95 <fork+0x6d>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  800e74:	e8 71 fc ff ff       	call   800aea <sys_getenvid>
  800e79:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e7e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e81:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e86:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	e9 aa 01 00 00       	jmp    80103f <fork+0x217>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  800e95:	89 f0                	mov    %esi,%eax
  800e97:	c1 e8 16             	shr    $0x16,%eax
  800e9a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea1:	a8 01                	test   $0x1,%al
  800ea3:	0f 84 f9 00 00 00    	je     800fa2 <fork+0x17a>
  800ea9:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800eb0:	a8 05                	test   $0x5,%al
  800eb2:	0f 84 ea 00 00 00    	je     800fa2 <fork+0x17a>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
  800eb8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ebf:	a8 02                	test   $0x2,%al
  800ec1:	75 1c                	jne    800edf <fork+0xb7>
  800ec3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800eca:	f6 c4 08             	test   $0x8,%ah
  800ecd:	75 10                	jne    800edf <fork+0xb7>
  800ecf:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ed6:	f6 c4 04             	test   $0x4,%ah
  800ed9:	0f 84 99 00 00 00    	je     800f78 <fork+0x150>
	{
		if(uvpt[pn] & PTE_SHARE)
  800edf:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ee6:	f6 c4 04             	test   $0x4,%ah
  800ee9:	74 0f                	je     800efa <fork+0xd2>
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
  800eeb:	8b 3c 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edi
  800ef2:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  800ef8:	eb 2d                	jmp    800f27 <fork+0xff>
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  800efa:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
			perm = PTE_P|PTE_U|PTE_COW;
  800f01:	bf 05 08 00 00       	mov    $0x805,%edi
	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
	{
		if(uvpt[pn] & PTE_SHARE)
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  800f06:	a8 02                	test   $0x2,%al
  800f08:	75 1d                	jne    800f27 <fork+0xff>
  800f0a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f11:	25 00 08 00 00       	and    $0x800,%eax
			perm = PTE_P|PTE_U|PTE_COW;
  800f16:	83 f8 01             	cmp    $0x1,%eax
  800f19:	19 ff                	sbb    %edi,%edi
  800f1b:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  800f21:	81 c7 05 08 00 00    	add    $0x805,%edi
		}

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm))) < 0)
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f2f:	56                   	push   %esi
  800f30:	6a 00                	push   $0x0
  800f32:	e8 34 fc ff ff       	call   800b6b <sys_page_map>
  800f37:	83 c4 20             	add    $0x20,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 12                	jns    800f50 <fork+0x128>
			panic("fork: sys_page_map: %e", r);
  800f3e:	50                   	push   %eax
  800f3f:	68 aa 18 80 00       	push   $0x8018aa
  800f44:	6a 62                	push   $0x62
  800f46:	68 8f 18 80 00       	push   $0x80188f
  800f4b:	e8 11 01 00 00       	call   801061 <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm))) < 0)
  800f50:	83 ec 0c             	sub    $0xc,%esp
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	6a 00                	push   $0x0
  800f57:	56                   	push   %esi
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 0c fc ff ff       	call   800b6b <sys_page_map>
  800f5f:	83 c4 20             	add    $0x20,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	79 3c                	jns    800fa2 <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  800f66:	50                   	push   %eax
  800f67:	68 aa 18 80 00       	push   $0x8018aa
  800f6c:	6a 65                	push   $0x65
  800f6e:	68 8f 18 80 00       	push   $0x80188f
  800f73:	e8 e9 00 00 00       	call   801061 <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	6a 05                	push   $0x5
  800f7d:	56                   	push   %esi
  800f7e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f81:	56                   	push   %esi
  800f82:	6a 00                	push   $0x0
  800f84:	e8 e2 fb ff ff       	call   800b6b <sys_page_map>
  800f89:	83 c4 20             	add    $0x20,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	79 12                	jns    800fa2 <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  800f90:	50                   	push   %eax
  800f91:	68 aa 18 80 00       	push   $0x8018aa
  800f96:	6a 6a                	push   $0x6a
  800f98:	68 8f 18 80 00       	push   $0x80188f
  800f9d:	e8 bf 00 00 00       	call   801061 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  800fa2:	83 c3 01             	add    $0x1,%ebx
  800fa5:	81 c6 00 10 00 00    	add    $0x1000,%esi
  800fab:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fb1:	0f 85 de fe ff ff    	jne    800e95 <fork+0x6d>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	6a 07                	push   $0x7
  800fbc:	68 00 f0 bf ee       	push   $0xeebff000
  800fc1:	ff 75 e0             	pushl  -0x20(%ebp)
  800fc4:	e8 5f fb ff ff       	call   800b28 <sys_page_alloc>
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	79 15                	jns    800fe5 <fork+0x1bd>
		panic("sys_page_alloc: %e", r);
  800fd0:	50                   	push   %eax
  800fd1:	68 c1 18 80 00       	push   $0x8018c1
  800fd6:	68 9e 00 00 00       	push   $0x9e
  800fdb:	68 8f 18 80 00       	push   $0x80188f
  800fe0:	e8 7c 00 00 00       	call   801061 <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	68 24 11 80 00       	push   $0x801124
  800fed:	ff 75 e0             	pushl  -0x20(%ebp)
  800ff0:	e8 7e fc ff ff       	call   800c73 <sys_env_set_pgfault_upcall>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	79 17                	jns    801013 <fork+0x1eb>
		panic("sys_pgfault_upcall error");
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 d4 18 80 00       	push   $0x8018d4
  801004:	68 a1 00 00 00       	push   $0xa1
  801009:	68 8f 18 80 00       	push   $0x80188f
  80100e:	e8 4e 00 00 00       	call   801061 <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801013:	83 ec 08             	sub    $0x8,%esp
  801016:	6a 02                	push   $0x2
  801018:	ff 75 e0             	pushl  -0x20(%ebp)
  80101b:	e8 cf fb ff ff       	call   800bef <sys_env_set_status>
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	85 c0                	test   %eax,%eax
  801025:	79 15                	jns    80103c <fork+0x214>
		panic("sys_env_set_status: %e", r);
  801027:	50                   	push   %eax
  801028:	68 ed 18 80 00       	push   $0x8018ed
  80102d:	68 a7 00 00 00       	push   $0xa7
  801032:	68 8f 18 80 00       	push   $0x80188f
  801037:	e8 25 00 00 00       	call   801061 <_panic>

	return envid;
  80103c:	8b 45 e0             	mov    -0x20(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  80103f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5f                   	pop    %edi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <sfork>:

// Challenge!
int
sfork(void)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80104d:	68 04 19 80 00       	push   $0x801904
  801052:	68 b2 00 00 00       	push   $0xb2
  801057:	68 8f 18 80 00       	push   $0x80188f
  80105c:	e8 00 00 00 00       	call   801061 <_panic>

00801061 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801066:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801069:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80106f:	e8 76 fa ff ff       	call   800aea <sys_getenvid>
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	ff 75 0c             	pushl  0xc(%ebp)
  80107a:	ff 75 08             	pushl  0x8(%ebp)
  80107d:	56                   	push   %esi
  80107e:	50                   	push   %eax
  80107f:	68 1c 19 80 00       	push   $0x80191c
  801084:	e8 17 f1 ff ff       	call   8001a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801089:	83 c4 18             	add    $0x18,%esp
  80108c:	53                   	push   %ebx
  80108d:	ff 75 10             	pushl  0x10(%ebp)
  801090:	e8 ba f0 ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  801095:	c7 04 24 74 14 80 00 	movl   $0x801474,(%esp)
  80109c:	e8 ff f0 ff ff       	call   8001a0 <cprintf>
  8010a1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010a4:	cc                   	int3   
  8010a5:	eb fd                	jmp    8010a4 <_panic+0x43>

008010a7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010ad:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010b4:	75 64                	jne    80111a <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8010b6:	a1 04 20 80 00       	mov    0x802004,%eax
  8010bb:	8b 40 48             	mov    0x48(%eax),%eax
  8010be:	83 ec 04             	sub    $0x4,%esp
  8010c1:	6a 07                	push   $0x7
  8010c3:	68 00 f0 bf ee       	push   $0xeebff000
  8010c8:	50                   	push   %eax
  8010c9:	e8 5a fa ff ff       	call   800b28 <sys_page_alloc>
		if ( r != 0)
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	74 14                	je     8010e9 <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  8010d5:	83 ec 04             	sub    $0x4,%esp
  8010d8:	68 40 19 80 00       	push   $0x801940
  8010dd:	6a 24                	push   $0x24
  8010df:	68 90 19 80 00       	push   $0x801990
  8010e4:	e8 78 ff ff ff       	call   801061 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  8010e9:	a1 04 20 80 00       	mov    0x802004,%eax
  8010ee:	8b 40 48             	mov    0x48(%eax),%eax
  8010f1:	83 ec 08             	sub    $0x8,%esp
  8010f4:	68 24 11 80 00       	push   $0x801124
  8010f9:	50                   	push   %eax
  8010fa:	e8 74 fb ff ff       	call   800c73 <sys_env_set_pgfault_upcall>
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	85 c0                	test   %eax,%eax
  801104:	79 14                	jns    80111a <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	68 6c 19 80 00       	push   $0x80196c
  80110e:	6a 27                	push   $0x27
  801110:	68 90 19 80 00       	push   $0x801990
  801115:	e8 47 ff ff ff       	call   801061 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80111a:	8b 45 08             	mov    0x8(%ebp),%eax
  80111d:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801124:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801125:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80112a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80112c:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  80112f:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  801133:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  801135:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  801139:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  80113a:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  80113d:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  80113f:	83 c4 08             	add    $0x8,%esp
popal
  801142:	61                   	popa   
addl $0x4, %esp
  801143:	83 c4 04             	add    $0x4,%esp
popfl
  801146:	9d                   	popf   
popl %esp
  801147:	5c                   	pop    %esp
ret
  801148:	c3                   	ret    
  801149:	66 90                	xchg   %ax,%ax
  80114b:	66 90                	xchg   %ax,%ax
  80114d:	66 90                	xchg   %ax,%ax
  80114f:	90                   	nop

00801150 <__udivdi3>:
  801150:	55                   	push   %ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
  801154:	83 ec 1c             	sub    $0x1c,%esp
  801157:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80115b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80115f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801167:	85 f6                	test   %esi,%esi
  801169:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80116d:	89 ca                	mov    %ecx,%edx
  80116f:	89 f8                	mov    %edi,%eax
  801171:	75 3d                	jne    8011b0 <__udivdi3+0x60>
  801173:	39 cf                	cmp    %ecx,%edi
  801175:	0f 87 c5 00 00 00    	ja     801240 <__udivdi3+0xf0>
  80117b:	85 ff                	test   %edi,%edi
  80117d:	89 fd                	mov    %edi,%ebp
  80117f:	75 0b                	jne    80118c <__udivdi3+0x3c>
  801181:	b8 01 00 00 00       	mov    $0x1,%eax
  801186:	31 d2                	xor    %edx,%edx
  801188:	f7 f7                	div    %edi
  80118a:	89 c5                	mov    %eax,%ebp
  80118c:	89 c8                	mov    %ecx,%eax
  80118e:	31 d2                	xor    %edx,%edx
  801190:	f7 f5                	div    %ebp
  801192:	89 c1                	mov    %eax,%ecx
  801194:	89 d8                	mov    %ebx,%eax
  801196:	89 cf                	mov    %ecx,%edi
  801198:	f7 f5                	div    %ebp
  80119a:	89 c3                	mov    %eax,%ebx
  80119c:	89 d8                	mov    %ebx,%eax
  80119e:	89 fa                	mov    %edi,%edx
  8011a0:	83 c4 1c             	add    $0x1c,%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    
  8011a8:	90                   	nop
  8011a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	39 ce                	cmp    %ecx,%esi
  8011b2:	77 74                	ja     801228 <__udivdi3+0xd8>
  8011b4:	0f bd fe             	bsr    %esi,%edi
  8011b7:	83 f7 1f             	xor    $0x1f,%edi
  8011ba:	0f 84 98 00 00 00    	je     801258 <__udivdi3+0x108>
  8011c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011c5:	89 f9                	mov    %edi,%ecx
  8011c7:	89 c5                	mov    %eax,%ebp
  8011c9:	29 fb                	sub    %edi,%ebx
  8011cb:	d3 e6                	shl    %cl,%esi
  8011cd:	89 d9                	mov    %ebx,%ecx
  8011cf:	d3 ed                	shr    %cl,%ebp
  8011d1:	89 f9                	mov    %edi,%ecx
  8011d3:	d3 e0                	shl    %cl,%eax
  8011d5:	09 ee                	or     %ebp,%esi
  8011d7:	89 d9                	mov    %ebx,%ecx
  8011d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011dd:	89 d5                	mov    %edx,%ebp
  8011df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011e3:	d3 ed                	shr    %cl,%ebp
  8011e5:	89 f9                	mov    %edi,%ecx
  8011e7:	d3 e2                	shl    %cl,%edx
  8011e9:	89 d9                	mov    %ebx,%ecx
  8011eb:	d3 e8                	shr    %cl,%eax
  8011ed:	09 c2                	or     %eax,%edx
  8011ef:	89 d0                	mov    %edx,%eax
  8011f1:	89 ea                	mov    %ebp,%edx
  8011f3:	f7 f6                	div    %esi
  8011f5:	89 d5                	mov    %edx,%ebp
  8011f7:	89 c3                	mov    %eax,%ebx
  8011f9:	f7 64 24 0c          	mull   0xc(%esp)
  8011fd:	39 d5                	cmp    %edx,%ebp
  8011ff:	72 10                	jb     801211 <__udivdi3+0xc1>
  801201:	8b 74 24 08          	mov    0x8(%esp),%esi
  801205:	89 f9                	mov    %edi,%ecx
  801207:	d3 e6                	shl    %cl,%esi
  801209:	39 c6                	cmp    %eax,%esi
  80120b:	73 07                	jae    801214 <__udivdi3+0xc4>
  80120d:	39 d5                	cmp    %edx,%ebp
  80120f:	75 03                	jne    801214 <__udivdi3+0xc4>
  801211:	83 eb 01             	sub    $0x1,%ebx
  801214:	31 ff                	xor    %edi,%edi
  801216:	89 d8                	mov    %ebx,%eax
  801218:	89 fa                	mov    %edi,%edx
  80121a:	83 c4 1c             	add    $0x1c,%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    
  801222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801228:	31 ff                	xor    %edi,%edi
  80122a:	31 db                	xor    %ebx,%ebx
  80122c:	89 d8                	mov    %ebx,%eax
  80122e:	89 fa                	mov    %edi,%edx
  801230:	83 c4 1c             	add    $0x1c,%esp
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    
  801238:	90                   	nop
  801239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801240:	89 d8                	mov    %ebx,%eax
  801242:	f7 f7                	div    %edi
  801244:	31 ff                	xor    %edi,%edi
  801246:	89 c3                	mov    %eax,%ebx
  801248:	89 d8                	mov    %ebx,%eax
  80124a:	89 fa                	mov    %edi,%edx
  80124c:	83 c4 1c             	add    $0x1c,%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5f                   	pop    %edi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	39 ce                	cmp    %ecx,%esi
  80125a:	72 0c                	jb     801268 <__udivdi3+0x118>
  80125c:	31 db                	xor    %ebx,%ebx
  80125e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801262:	0f 87 34 ff ff ff    	ja     80119c <__udivdi3+0x4c>
  801268:	bb 01 00 00 00       	mov    $0x1,%ebx
  80126d:	e9 2a ff ff ff       	jmp    80119c <__udivdi3+0x4c>
  801272:	66 90                	xchg   %ax,%ax
  801274:	66 90                	xchg   %ax,%ax
  801276:	66 90                	xchg   %ax,%ax
  801278:	66 90                	xchg   %ax,%ax
  80127a:	66 90                	xchg   %ax,%ax
  80127c:	66 90                	xchg   %ax,%ax
  80127e:	66 90                	xchg   %ax,%ax

00801280 <__umoddi3>:
  801280:	55                   	push   %ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 1c             	sub    $0x1c,%esp
  801287:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80128b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80128f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801297:	85 d2                	test   %edx,%edx
  801299:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80129d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012a1:	89 f3                	mov    %esi,%ebx
  8012a3:	89 3c 24             	mov    %edi,(%esp)
  8012a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012aa:	75 1c                	jne    8012c8 <__umoddi3+0x48>
  8012ac:	39 f7                	cmp    %esi,%edi
  8012ae:	76 50                	jbe    801300 <__umoddi3+0x80>
  8012b0:	89 c8                	mov    %ecx,%eax
  8012b2:	89 f2                	mov    %esi,%edx
  8012b4:	f7 f7                	div    %edi
  8012b6:	89 d0                	mov    %edx,%eax
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	83 c4 1c             	add    $0x1c,%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    
  8012c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c8:	39 f2                	cmp    %esi,%edx
  8012ca:	89 d0                	mov    %edx,%eax
  8012cc:	77 52                	ja     801320 <__umoddi3+0xa0>
  8012ce:	0f bd ea             	bsr    %edx,%ebp
  8012d1:	83 f5 1f             	xor    $0x1f,%ebp
  8012d4:	75 5a                	jne    801330 <__umoddi3+0xb0>
  8012d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8012da:	0f 82 e0 00 00 00    	jb     8013c0 <__umoddi3+0x140>
  8012e0:	39 0c 24             	cmp    %ecx,(%esp)
  8012e3:	0f 86 d7 00 00 00    	jbe    8013c0 <__umoddi3+0x140>
  8012e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012f1:	83 c4 1c             	add    $0x1c,%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    
  8012f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801300:	85 ff                	test   %edi,%edi
  801302:	89 fd                	mov    %edi,%ebp
  801304:	75 0b                	jne    801311 <__umoddi3+0x91>
  801306:	b8 01 00 00 00       	mov    $0x1,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	f7 f7                	div    %edi
  80130f:	89 c5                	mov    %eax,%ebp
  801311:	89 f0                	mov    %esi,%eax
  801313:	31 d2                	xor    %edx,%edx
  801315:	f7 f5                	div    %ebp
  801317:	89 c8                	mov    %ecx,%eax
  801319:	f7 f5                	div    %ebp
  80131b:	89 d0                	mov    %edx,%eax
  80131d:	eb 99                	jmp    8012b8 <__umoddi3+0x38>
  80131f:	90                   	nop
  801320:	89 c8                	mov    %ecx,%eax
  801322:	89 f2                	mov    %esi,%edx
  801324:	83 c4 1c             	add    $0x1c,%esp
  801327:	5b                   	pop    %ebx
  801328:	5e                   	pop    %esi
  801329:	5f                   	pop    %edi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    
  80132c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801330:	8b 34 24             	mov    (%esp),%esi
  801333:	bf 20 00 00 00       	mov    $0x20,%edi
  801338:	89 e9                	mov    %ebp,%ecx
  80133a:	29 ef                	sub    %ebp,%edi
  80133c:	d3 e0                	shl    %cl,%eax
  80133e:	89 f9                	mov    %edi,%ecx
  801340:	89 f2                	mov    %esi,%edx
  801342:	d3 ea                	shr    %cl,%edx
  801344:	89 e9                	mov    %ebp,%ecx
  801346:	09 c2                	or     %eax,%edx
  801348:	89 d8                	mov    %ebx,%eax
  80134a:	89 14 24             	mov    %edx,(%esp)
  80134d:	89 f2                	mov    %esi,%edx
  80134f:	d3 e2                	shl    %cl,%edx
  801351:	89 f9                	mov    %edi,%ecx
  801353:	89 54 24 04          	mov    %edx,0x4(%esp)
  801357:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80135b:	d3 e8                	shr    %cl,%eax
  80135d:	89 e9                	mov    %ebp,%ecx
  80135f:	89 c6                	mov    %eax,%esi
  801361:	d3 e3                	shl    %cl,%ebx
  801363:	89 f9                	mov    %edi,%ecx
  801365:	89 d0                	mov    %edx,%eax
  801367:	d3 e8                	shr    %cl,%eax
  801369:	89 e9                	mov    %ebp,%ecx
  80136b:	09 d8                	or     %ebx,%eax
  80136d:	89 d3                	mov    %edx,%ebx
  80136f:	89 f2                	mov    %esi,%edx
  801371:	f7 34 24             	divl   (%esp)
  801374:	89 d6                	mov    %edx,%esi
  801376:	d3 e3                	shl    %cl,%ebx
  801378:	f7 64 24 04          	mull   0x4(%esp)
  80137c:	39 d6                	cmp    %edx,%esi
  80137e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801382:	89 d1                	mov    %edx,%ecx
  801384:	89 c3                	mov    %eax,%ebx
  801386:	72 08                	jb     801390 <__umoddi3+0x110>
  801388:	75 11                	jne    80139b <__umoddi3+0x11b>
  80138a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80138e:	73 0b                	jae    80139b <__umoddi3+0x11b>
  801390:	2b 44 24 04          	sub    0x4(%esp),%eax
  801394:	1b 14 24             	sbb    (%esp),%edx
  801397:	89 d1                	mov    %edx,%ecx
  801399:	89 c3                	mov    %eax,%ebx
  80139b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80139f:	29 da                	sub    %ebx,%edx
  8013a1:	19 ce                	sbb    %ecx,%esi
  8013a3:	89 f9                	mov    %edi,%ecx
  8013a5:	89 f0                	mov    %esi,%eax
  8013a7:	d3 e0                	shl    %cl,%eax
  8013a9:	89 e9                	mov    %ebp,%ecx
  8013ab:	d3 ea                	shr    %cl,%edx
  8013ad:	89 e9                	mov    %ebp,%ecx
  8013af:	d3 ee                	shr    %cl,%esi
  8013b1:	09 d0                	or     %edx,%eax
  8013b3:	89 f2                	mov    %esi,%edx
  8013b5:	83 c4 1c             	add    $0x1c,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    
  8013bd:	8d 76 00             	lea    0x0(%esi),%esi
  8013c0:	29 f9                	sub    %edi,%ecx
  8013c2:	19 d6                	sbb    %edx,%esi
  8013c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013cc:	e9 18 ff ff ff       	jmp    8012e9 <__umoddi3+0x69>
