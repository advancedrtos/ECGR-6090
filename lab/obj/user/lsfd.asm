
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 a0 25 80 00       	push   $0x8025a0
  80003e:	e8 b5 01 00 00       	call   8001f8 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 24 0d 00 00       	call   800d90 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 2a 0d 00 00       	call   800dc0 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 26 13 00 00       	call   8013d8 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 b4 25 80 00       	push   $0x8025b4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 f8 16 00 00       	call   8017d2 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 b4 25 80 00       	push   $0x8025b4
  8000f5:	e8 fe 00 00 00       	call   8001f8 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  800118:	e8 25 0a 00 00       	call   800b42 <sys_getenvid>
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800159:	6a 00                	push   $0x0
  80015b:	e8 a1 09 00 00       	call   800b01 <sys_env_destroy>
}
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	53                   	push   %ebx
  800169:	83 ec 04             	sub    $0x4,%esp
  80016c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016f:	8b 13                	mov    (%ebx),%edx
  800171:	8d 42 01             	lea    0x1(%edx),%eax
  800174:	89 03                	mov    %eax,(%ebx)
  800176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800179:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800182:	75 1a                	jne    80019e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800184:	83 ec 08             	sub    $0x8,%esp
  800187:	68 ff 00 00 00       	push   $0xff
  80018c:	8d 43 08             	lea    0x8(%ebx),%eax
  80018f:	50                   	push   %eax
  800190:	e8 2f 09 00 00       	call   800ac4 <sys_cputs>
		b->idx = 0;
  800195:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 65 01 80 00       	push   $0x800165
  8001d6:	e8 54 01 00 00       	call   80032f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 d4 08 00 00       	call   800ac4 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 c7                	mov    %eax,%edi
  800217:	89 d6                	mov    %edx,%esi
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800222:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800225:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800230:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800233:	39 d3                	cmp    %edx,%ebx
  800235:	72 05                	jb     80023c <printnum+0x30>
  800237:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023a:	77 45                	ja     800281 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	8b 45 14             	mov    0x14(%ebp),%eax
  800245:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800248:	53                   	push   %ebx
  800249:	ff 75 10             	pushl  0x10(%ebp)
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800252:	ff 75 e0             	pushl  -0x20(%ebp)
  800255:	ff 75 dc             	pushl  -0x24(%ebp)
  800258:	ff 75 d8             	pushl  -0x28(%ebp)
  80025b:	e8 a0 20 00 00       	call   802300 <__udivdi3>
  800260:	83 c4 18             	add    $0x18,%esp
  800263:	52                   	push   %edx
  800264:	50                   	push   %eax
  800265:	89 f2                	mov    %esi,%edx
  800267:	89 f8                	mov    %edi,%eax
  800269:	e8 9e ff ff ff       	call   80020c <printnum>
  80026e:	83 c4 20             	add    $0x20,%esp
  800271:	eb 18                	jmp    80028b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	56                   	push   %esi
  800277:	ff 75 18             	pushl  0x18(%ebp)
  80027a:	ff d7                	call   *%edi
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	eb 03                	jmp    800284 <printnum+0x78>
  800281:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800284:	83 eb 01             	sub    $0x1,%ebx
  800287:	85 db                	test   %ebx,%ebx
  800289:	7f e8                	jg     800273 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	56                   	push   %esi
  80028f:	83 ec 04             	sub    $0x4,%esp
  800292:	ff 75 e4             	pushl  -0x1c(%ebp)
  800295:	ff 75 e0             	pushl  -0x20(%ebp)
  800298:	ff 75 dc             	pushl  -0x24(%ebp)
  80029b:	ff 75 d8             	pushl  -0x28(%ebp)
  80029e:	e8 8d 21 00 00       	call   802430 <__umoddi3>
  8002a3:	83 c4 14             	add    $0x14,%esp
  8002a6:	0f be 80 e6 25 80 00 	movsbl 0x8025e6(%eax),%eax
  8002ad:	50                   	push   %eax
  8002ae:	ff d7                	call   *%edi
}
  8002b0:	83 c4 10             	add    $0x10,%esp
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002be:	83 fa 01             	cmp    $0x1,%edx
  8002c1:	7e 0e                	jle    8002d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 02                	mov    (%edx),%eax
  8002cc:	8b 52 04             	mov    0x4(%edx),%edx
  8002cf:	eb 22                	jmp    8002f3 <getuint+0x38>
	else if (lflag)
  8002d1:	85 d2                	test   %edx,%edx
  8002d3:	74 10                	je     8002e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d5:	8b 10                	mov    (%eax),%edx
  8002d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 02                	mov    (%edx),%eax
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	eb 0e                	jmp    8002f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	3b 50 04             	cmp    0x4(%eax),%edx
  800304:	73 0a                	jae    800310 <sprintputch+0x1b>
		*b->buf++ = ch;
  800306:	8d 4a 01             	lea    0x1(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 45 08             	mov    0x8(%ebp),%eax
  80030e:	88 02                	mov    %al,(%edx)
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800318:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031b:	50                   	push   %eax
  80031c:	ff 75 10             	pushl  0x10(%ebp)
  80031f:	ff 75 0c             	pushl  0xc(%ebp)
  800322:	ff 75 08             	pushl  0x8(%ebp)
  800325:	e8 05 00 00 00       	call   80032f <vprintfmt>
	va_end(ap);
}
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	c9                   	leave  
  80032e:	c3                   	ret    

0080032f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	57                   	push   %edi
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	83 ec 2c             	sub    $0x2c,%esp
  800338:	8b 75 08             	mov    0x8(%ebp),%esi
  80033b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800341:	eb 12                	jmp    800355 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800343:	85 c0                	test   %eax,%eax
  800345:	0f 84 89 03 00 00    	je     8006d4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	53                   	push   %ebx
  80034f:	50                   	push   %eax
  800350:	ff d6                	call   *%esi
  800352:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800355:	83 c7 01             	add    $0x1,%edi
  800358:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035c:	83 f8 25             	cmp    $0x25,%eax
  80035f:	75 e2                	jne    800343 <vprintfmt+0x14>
  800361:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800365:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800373:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
  80037f:	eb 07                	jmp    800388 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800384:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8d 47 01             	lea    0x1(%edi),%eax
  80038b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038e:	0f b6 07             	movzbl (%edi),%eax
  800391:	0f b6 c8             	movzbl %al,%ecx
  800394:	83 e8 23             	sub    $0x23,%eax
  800397:	3c 55                	cmp    $0x55,%al
  800399:	0f 87 1a 03 00 00    	ja     8006b9 <vprintfmt+0x38a>
  80039f:	0f b6 c0             	movzbl %al,%eax
  8003a2:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b0:	eb d6                	jmp    800388 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ca:	83 fa 09             	cmp    $0x9,%edx
  8003cd:	77 39                	ja     800408 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d2:	eb e9                	jmp    8003bd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003da:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e5:	eb 27                	jmp    80040e <vprintfmt+0xdf>
  8003e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f1:	0f 49 c8             	cmovns %eax,%ecx
  8003f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fa:	eb 8c                	jmp    800388 <vprintfmt+0x59>
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ff:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800406:	eb 80                	jmp    800388 <vprintfmt+0x59>
  800408:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800412:	0f 89 70 ff ff ff    	jns    800388 <vprintfmt+0x59>
				width = precision, precision = -1;
  800418:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800425:	e9 5e ff ff ff       	jmp    800388 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800430:	e9 53 ff ff ff       	jmp    800388 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	53                   	push   %ebx
  800442:	ff 30                	pushl  (%eax)
  800444:	ff d6                	call   *%esi
			break;
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044c:	e9 04 ff ff ff       	jmp    800355 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	99                   	cltd   
  80045d:	31 d0                	xor    %edx,%eax
  80045f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800461:	83 f8 0f             	cmp    $0xf,%eax
  800464:	7f 0b                	jg     800471 <vprintfmt+0x142>
  800466:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  80046d:	85 d2                	test   %edx,%edx
  80046f:	75 18                	jne    800489 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800471:	50                   	push   %eax
  800472:	68 fe 25 80 00       	push   $0x8025fe
  800477:	53                   	push   %ebx
  800478:	56                   	push   %esi
  800479:	e8 94 fe ff ff       	call   800312 <printfmt>
  80047e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800484:	e9 cc fe ff ff       	jmp    800355 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800489:	52                   	push   %edx
  80048a:	68 b5 29 80 00       	push   $0x8029b5
  80048f:	53                   	push   %ebx
  800490:	56                   	push   %esi
  800491:	e8 7c fe ff ff       	call   800312 <printfmt>
  800496:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049c:	e9 b4 fe ff ff       	jmp    800355 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	b8 f7 25 80 00       	mov    $0x8025f7,%eax
  8004b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ba:	0f 8e 94 00 00 00    	jle    800554 <vprintfmt+0x225>
  8004c0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c4:	0f 84 98 00 00 00    	je     800562 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d0:	57                   	push   %edi
  8004d1:	e8 86 02 00 00       	call   80075c <strnlen>
  8004d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d9:	29 c1                	sub    %eax,%ecx
  8004db:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004eb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	eb 0f                	jmp    8004fe <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7f ed                	jg     8004ef <vprintfmt+0x1c0>
  800502:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800505:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c1             	cmovns %ecx,%eax
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	89 cb                	mov    %ecx,%ebx
  80051f:	eb 4d                	jmp    80056e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	74 1b                	je     800542 <vprintfmt+0x213>
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	83 e8 20             	sub    $0x20,%eax
  80052d:	83 f8 5e             	cmp    $0x5e,%eax
  800530:	76 10                	jbe    800542 <vprintfmt+0x213>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	6a 3f                	push   $0x3f
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	eb 0d                	jmp    80054f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	52                   	push   %edx
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	eb 1a                	jmp    80056e <vprintfmt+0x23f>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	eb 0c                	jmp    80056e <vprintfmt+0x23f>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800575:	0f be d0             	movsbl %al,%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 23                	je     80059f <vprintfmt+0x270>
  80057c:	85 f6                	test   %esi,%esi
  80057e:	78 a1                	js     800521 <vprintfmt+0x1f2>
  800580:	83 ee 01             	sub    $0x1,%esi
  800583:	79 9c                	jns    800521 <vprintfmt+0x1f2>
  800585:	89 df                	mov    %ebx,%edi
  800587:	8b 75 08             	mov    0x8(%ebp),%esi
  80058a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058d:	eb 18                	jmp    8005a7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 20                	push   $0x20
  800595:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 ef 01             	sub    $0x1,%edi
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 08                	jmp    8005a7 <vprintfmt+0x278>
  80059f:	89 df                	mov    %ebx,%edi
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a7:	85 ff                	test   %edi,%edi
  8005a9:	7f e4                	jg     80058f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ae:	e9 a2 fd ff ff       	jmp    800355 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b3:	83 fa 01             	cmp    $0x1,%edx
  8005b6:	7e 16                	jle    8005ce <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 08             	lea    0x8(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 50 04             	mov    0x4(%eax),%edx
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	eb 32                	jmp    800600 <vprintfmt+0x2d1>
	else if (lflag)
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	74 18                	je     8005ea <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e0:	89 c1                	mov    %eax,%ecx
  8005e2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e8:	eb 16                	jmp    800600 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	89 c1                	mov    %eax,%ecx
  8005fa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800600:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800603:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800606:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060f:	79 74                	jns    800685 <vprintfmt+0x356>
				putch('-', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 2d                	push   $0x2d
  800617:	ff d6                	call   *%esi
				num = -(long long) num;
  800619:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061f:	f7 d8                	neg    %eax
  800621:	83 d2 00             	adc    $0x0,%edx
  800624:	f7 da                	neg    %edx
  800626:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800629:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062e:	eb 55                	jmp    800685 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800630:	8d 45 14             	lea    0x14(%ebp),%eax
  800633:	e8 83 fc ff ff       	call   8002bb <getuint>
			base = 10;
  800638:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063d:	eb 46                	jmp    800685 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 74 fc ff ff       	call   8002bb <getuint>
			base = 8;
  800647:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80064c:	eb 37                	jmp    800685 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 30                	push   $0x30
  800654:	ff d6                	call   *%esi
			putch('x', putdat);
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 78                	push   $0x78
  80065c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800671:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800676:	eb 0d                	jmp    800685 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	e8 3b fc ff ff       	call   8002bb <getuint>
			base = 16;
  800680:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800685:	83 ec 0c             	sub    $0xc,%esp
  800688:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068c:	57                   	push   %edi
  80068d:	ff 75 e0             	pushl  -0x20(%ebp)
  800690:	51                   	push   %ecx
  800691:	52                   	push   %edx
  800692:	50                   	push   %eax
  800693:	89 da                	mov    %ebx,%edx
  800695:	89 f0                	mov    %esi,%eax
  800697:	e8 70 fb ff ff       	call   80020c <printnum>
			break;
  80069c:	83 c4 20             	add    $0x20,%esp
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a2:	e9 ae fc ff ff       	jmp    800355 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	51                   	push   %ecx
  8006ac:	ff d6                	call   *%esi
			break;
  8006ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b4:	e9 9c fc ff ff       	jmp    800355 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 25                	push   $0x25
  8006bf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb 03                	jmp    8006c9 <vprintfmt+0x39a>
  8006c6:	83 ef 01             	sub    $0x1,%edi
  8006c9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006cd:	75 f7                	jne    8006c6 <vprintfmt+0x397>
  8006cf:	e9 81 fc ff ff       	jmp    800355 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d7:	5b                   	pop    %ebx
  8006d8:	5e                   	pop    %esi
  8006d9:	5f                   	pop    %edi
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 18             	sub    $0x18,%esp
  8006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006eb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 26                	je     800723 <vsnprintf+0x47>
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	7e 22                	jle    800723 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800701:	ff 75 14             	pushl  0x14(%ebp)
  800704:	ff 75 10             	pushl  0x10(%ebp)
  800707:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	68 f5 02 80 00       	push   $0x8002f5
  800710:	e8 1a fc ff ff       	call   80032f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800715:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800718:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb 05                	jmp    800728 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800723:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800733:	50                   	push   %eax
  800734:	ff 75 10             	pushl  0x10(%ebp)
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	ff 75 08             	pushl  0x8(%ebp)
  80073d:	e8 9a ff ff ff       	call   8006dc <vsnprintf>
	va_end(ap);

	return rc;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
  80074f:	eb 03                	jmp    800754 <strlen+0x10>
		n++;
  800751:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800754:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800758:	75 f7                	jne    800751 <strlen+0xd>
		n++;
	return n;
}
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	ba 00 00 00 00       	mov    $0x0,%edx
  80076a:	eb 03                	jmp    80076f <strnlen+0x13>
		n++;
  80076c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	39 c2                	cmp    %eax,%edx
  800771:	74 08                	je     80077b <strnlen+0x1f>
  800773:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800777:	75 f3                	jne    80076c <strnlen+0x10>
  800779:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	53                   	push   %ebx
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800787:	89 c2                	mov    %eax,%edx
  800789:	83 c2 01             	add    $0x1,%edx
  80078c:	83 c1 01             	add    $0x1,%ecx
  80078f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800793:	88 5a ff             	mov    %bl,-0x1(%edx)
  800796:	84 db                	test   %bl,%bl
  800798:	75 ef                	jne    800789 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079a:	5b                   	pop    %ebx
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	53                   	push   %ebx
  8007a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a4:	53                   	push   %ebx
  8007a5:	e8 9a ff ff ff       	call   800744 <strlen>
  8007aa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ad:	ff 75 0c             	pushl  0xc(%ebp)
  8007b0:	01 d8                	add    %ebx,%eax
  8007b2:	50                   	push   %eax
  8007b3:	e8 c5 ff ff ff       	call   80077d <strcpy>
	return dst;
}
  8007b8:	89 d8                	mov    %ebx,%eax
  8007ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	56                   	push   %esi
  8007c3:	53                   	push   %ebx
  8007c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ca:	89 f3                	mov    %esi,%ebx
  8007cc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cf:	89 f2                	mov    %esi,%edx
  8007d1:	eb 0f                	jmp    8007e2 <strncpy+0x23>
		*dst++ = *src;
  8007d3:	83 c2 01             	add    $0x1,%edx
  8007d6:	0f b6 01             	movzbl (%ecx),%eax
  8007d9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007dc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007df:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e2:	39 da                	cmp    %ebx,%edx
  8007e4:	75 ed                	jne    8007d3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	56                   	push   %esi
  8007f0:	53                   	push   %ebx
  8007f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fc:	85 d2                	test   %edx,%edx
  8007fe:	74 21                	je     800821 <strlcpy+0x35>
  800800:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800804:	89 f2                	mov    %esi,%edx
  800806:	eb 09                	jmp    800811 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800808:	83 c2 01             	add    $0x1,%edx
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800811:	39 c2                	cmp    %eax,%edx
  800813:	74 09                	je     80081e <strlcpy+0x32>
  800815:	0f b6 19             	movzbl (%ecx),%ebx
  800818:	84 db                	test   %bl,%bl
  80081a:	75 ec                	jne    800808 <strlcpy+0x1c>
  80081c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800821:	29 f0                	sub    %esi,%eax
}
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800830:	eb 06                	jmp    800838 <strcmp+0x11>
		p++, q++;
  800832:	83 c1 01             	add    $0x1,%ecx
  800835:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800838:	0f b6 01             	movzbl (%ecx),%eax
  80083b:	84 c0                	test   %al,%al
  80083d:	74 04                	je     800843 <strcmp+0x1c>
  80083f:	3a 02                	cmp    (%edx),%al
  800841:	74 ef                	je     800832 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 c0             	movzbl %al,%eax
  800846:	0f b6 12             	movzbl (%edx),%edx
  800849:	29 d0                	sub    %edx,%eax
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	53                   	push   %ebx
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
  800857:	89 c3                	mov    %eax,%ebx
  800859:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085c:	eb 06                	jmp    800864 <strncmp+0x17>
		n--, p++, q++;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800864:	39 d8                	cmp    %ebx,%eax
  800866:	74 15                	je     80087d <strncmp+0x30>
  800868:	0f b6 08             	movzbl (%eax),%ecx
  80086b:	84 c9                	test   %cl,%cl
  80086d:	74 04                	je     800873 <strncmp+0x26>
  80086f:	3a 0a                	cmp    (%edx),%cl
  800871:	74 eb                	je     80085e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 00             	movzbl (%eax),%eax
  800876:	0f b6 12             	movzbl (%edx),%edx
  800879:	29 d0                	sub    %edx,%eax
  80087b:	eb 05                	jmp    800882 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800882:	5b                   	pop    %ebx
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088f:	eb 07                	jmp    800898 <strchr+0x13>
		if (*s == c)
  800891:	38 ca                	cmp    %cl,%dl
  800893:	74 0f                	je     8008a4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800895:	83 c0 01             	add    $0x1,%eax
  800898:	0f b6 10             	movzbl (%eax),%edx
  80089b:	84 d2                	test   %dl,%dl
  80089d:	75 f2                	jne    800891 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b0:	eb 03                	jmp    8008b5 <strfind+0xf>
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 04                	je     8008c0 <strfind+0x1a>
  8008bc:	84 d2                	test   %dl,%dl
  8008be:	75 f2                	jne    8008b2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ce:	85 c9                	test   %ecx,%ecx
  8008d0:	74 36                	je     800908 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d8:	75 28                	jne    800902 <memset+0x40>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 23                	jne    800902 <memset+0x40>
		c &= 0xFF;
  8008df:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e3:	89 d3                	mov    %edx,%ebx
  8008e5:	c1 e3 08             	shl    $0x8,%ebx
  8008e8:	89 d6                	mov    %edx,%esi
  8008ea:	c1 e6 18             	shl    $0x18,%esi
  8008ed:	89 d0                	mov    %edx,%eax
  8008ef:	c1 e0 10             	shl    $0x10,%eax
  8008f2:	09 f0                	or     %esi,%eax
  8008f4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f6:	89 d8                	mov    %ebx,%eax
  8008f8:	09 d0                	or     %edx,%eax
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
  8008fd:	fc                   	cld    
  8008fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800900:	eb 06                	jmp    800908 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800902:	8b 45 0c             	mov    0xc(%ebp),%eax
  800905:	fc                   	cld    
  800906:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800908:	89 f8                	mov    %edi,%eax
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5f                   	pop    %edi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	57                   	push   %edi
  800913:	56                   	push   %esi
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091d:	39 c6                	cmp    %eax,%esi
  80091f:	73 35                	jae    800956 <memmove+0x47>
  800921:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800924:	39 d0                	cmp    %edx,%eax
  800926:	73 2e                	jae    800956 <memmove+0x47>
		s += n;
		d += n;
  800928:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	09 fe                	or     %edi,%esi
  80092f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800935:	75 13                	jne    80094a <memmove+0x3b>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 0e                	jne    80094a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093c:	83 ef 04             	sub    $0x4,%edi
  80093f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800942:	c1 e9 02             	shr    $0x2,%ecx
  800945:	fd                   	std    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 09                	jmp    800953 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 1d                	jmp    800973 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	89 f2                	mov    %esi,%edx
  800958:	09 c2                	or     %eax,%edx
  80095a:	f6 c2 03             	test   $0x3,%dl
  80095d:	75 0f                	jne    80096e <memmove+0x5f>
  80095f:	f6 c1 03             	test   $0x3,%cl
  800962:	75 0a                	jne    80096e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800964:	c1 e9 02             	shr    $0x2,%ecx
  800967:	89 c7                	mov    %eax,%edi
  800969:	fc                   	cld    
  80096a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096c:	eb 05                	jmp    800973 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096e:	89 c7                	mov    %eax,%edi
  800970:	fc                   	cld    
  800971:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097a:	ff 75 10             	pushl  0x10(%ebp)
  80097d:	ff 75 0c             	pushl  0xc(%ebp)
  800980:	ff 75 08             	pushl  0x8(%ebp)
  800983:	e8 87 ff ff ff       	call   80090f <memmove>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	89 c6                	mov    %eax,%esi
  800997:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099a:	eb 1a                	jmp    8009b6 <memcmp+0x2c>
		if (*s1 != *s2)
  80099c:	0f b6 08             	movzbl (%eax),%ecx
  80099f:	0f b6 1a             	movzbl (%edx),%ebx
  8009a2:	38 d9                	cmp    %bl,%cl
  8009a4:	74 0a                	je     8009b0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a6:	0f b6 c1             	movzbl %cl,%eax
  8009a9:	0f b6 db             	movzbl %bl,%ebx
  8009ac:	29 d8                	sub    %ebx,%eax
  8009ae:	eb 0f                	jmp    8009bf <memcmp+0x35>
		s1++, s2++;
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b6:	39 f0                	cmp    %esi,%eax
  8009b8:	75 e2                	jne    80099c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5e                   	pop    %esi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ca:	89 c1                	mov    %eax,%ecx
  8009cc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d3:	eb 0a                	jmp    8009df <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	39 da                	cmp    %ebx,%edx
  8009da:	74 07                	je     8009e3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	39 c8                	cmp    %ecx,%eax
  8009e1:	72 f2                	jb     8009d5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f2:	eb 03                	jmp    8009f7 <strtol+0x11>
		s++;
  8009f4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f7:	0f b6 01             	movzbl (%ecx),%eax
  8009fa:	3c 20                	cmp    $0x20,%al
  8009fc:	74 f6                	je     8009f4 <strtol+0xe>
  8009fe:	3c 09                	cmp    $0x9,%al
  800a00:	74 f2                	je     8009f4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a02:	3c 2b                	cmp    $0x2b,%al
  800a04:	75 0a                	jne    800a10 <strtol+0x2a>
		s++;
  800a06:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a09:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0e:	eb 11                	jmp    800a21 <strtol+0x3b>
  800a10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a15:	3c 2d                	cmp    $0x2d,%al
  800a17:	75 08                	jne    800a21 <strtol+0x3b>
		s++, neg = 1;
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a21:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a27:	75 15                	jne    800a3e <strtol+0x58>
  800a29:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2c:	75 10                	jne    800a3e <strtol+0x58>
  800a2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a32:	75 7c                	jne    800ab0 <strtol+0xca>
		s += 2, base = 16;
  800a34:	83 c1 02             	add    $0x2,%ecx
  800a37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3c:	eb 16                	jmp    800a54 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3e:	85 db                	test   %ebx,%ebx
  800a40:	75 12                	jne    800a54 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a47:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4a:	75 08                	jne    800a54 <strtol+0x6e>
		s++, base = 8;
  800a4c:	83 c1 01             	add    $0x1,%ecx
  800a4f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5c:	0f b6 11             	movzbl (%ecx),%edx
  800a5f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 09             	cmp    $0x9,%bl
  800a67:	77 08                	ja     800a71 <strtol+0x8b>
			dig = *s - '0';
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 30             	sub    $0x30,%edx
  800a6f:	eb 22                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a71:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	80 fb 19             	cmp    $0x19,%bl
  800a79:	77 08                	ja     800a83 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7b:	0f be d2             	movsbl %dl,%edx
  800a7e:	83 ea 57             	sub    $0x57,%edx
  800a81:	eb 10                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a83:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 19             	cmp    $0x19,%bl
  800a8b:	77 16                	ja     800aa3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8d:	0f be d2             	movsbl %dl,%edx
  800a90:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a93:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a96:	7d 0b                	jge    800aa3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa1:	eb b9                	jmp    800a5c <strtol+0x76>

	if (endptr)
  800aa3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa7:	74 0d                	je     800ab6 <strtol+0xd0>
		*endptr = (char *) s;
  800aa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aac:	89 0e                	mov    %ecx,(%esi)
  800aae:	eb 06                	jmp    800ab6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab0:	85 db                	test   %ebx,%ebx
  800ab2:	74 98                	je     800a4c <strtol+0x66>
  800ab4:	eb 9e                	jmp    800a54 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab6:	89 c2                	mov    %eax,%edx
  800ab8:	f7 da                	neg    %edx
  800aba:	85 ff                	test   %edi,%edi
  800abc:	0f 45 c2             	cmovne %edx,%eax
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 cb                	mov    %ecx,%ebx
  800b19:	89 cf                	mov    %ecx,%edi
  800b1b:	89 ce                	mov    %ecx,%esi
  800b1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	7e 17                	jle    800b3a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	50                   	push   %eax
  800b27:	6a 03                	push   $0x3
  800b29:	68 df 28 80 00       	push   $0x8028df
  800b2e:	6a 23                	push   $0x23
  800b30:	68 fc 28 80 00       	push   $0x8028fc
  800b35:	e8 0b 16 00 00       	call   802145 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_yield>:

void
sys_yield(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	be 00 00 00 00       	mov    $0x0,%esi
  800b8e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9c:	89 f7                	mov    %esi,%edi
  800b9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba0:	85 c0                	test   %eax,%eax
  800ba2:	7e 17                	jle    800bbb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	50                   	push   %eax
  800ba8:	6a 04                	push   $0x4
  800baa:	68 df 28 80 00       	push   $0x8028df
  800baf:	6a 23                	push   $0x23
  800bb1:	68 fc 28 80 00       	push   $0x8028fc
  800bb6:	e8 8a 15 00 00       	call   802145 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdd:	8b 75 18             	mov    0x18(%ebp),%esi
  800be0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7e 17                	jle    800bfd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 05                	push   $0x5
  800bec:	68 df 28 80 00       	push   $0x8028df
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 fc 28 80 00       	push   $0x8028fc
  800bf8:	e8 48 15 00 00       	call   802145 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c13:	b8 06 00 00 00       	mov    $0x6,%eax
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	89 df                	mov    %ebx,%edi
  800c20:	89 de                	mov    %ebx,%esi
  800c22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7e 17                	jle    800c3f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 06                	push   $0x6
  800c2e:	68 df 28 80 00       	push   $0x8028df
  800c33:	6a 23                	push   $0x23
  800c35:	68 fc 28 80 00       	push   $0x8028fc
  800c3a:	e8 06 15 00 00       	call   802145 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 08                	push   $0x8
  800c70:	68 df 28 80 00       	push   $0x8028df
  800c75:	6a 23                	push   $0x23
  800c77:	68 fc 28 80 00       	push   $0x8028fc
  800c7c:	e8 c4 14 00 00       	call   802145 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 09                	push   $0x9
  800cb2:	68 df 28 80 00       	push   $0x8028df
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 fc 28 80 00       	push   $0x8028fc
  800cbe:	e8 82 14 00 00       	call   802145 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 0a                	push   $0xa
  800cf4:	68 df 28 80 00       	push   $0x8028df
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 fc 28 80 00       	push   $0x8028fc
  800d00:	e8 40 14 00 00       	call   802145 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	be 00 00 00 00       	mov    $0x0,%esi
  800d18:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 cb                	mov    %ecx,%ebx
  800d48:	89 cf                	mov    %ecx,%edi
  800d4a:	89 ce                	mov    %ecx,%esi
  800d4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	7e 17                	jle    800d69 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 0d                	push   $0xd
  800d58:	68 df 28 80 00       	push   $0x8028df
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 fc 28 80 00       	push   $0x8028fc
  800d64:	e8 dc 13 00 00       	call   802145 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d81:	89 d1                	mov    %edx,%ecx
  800d83:	89 d3                	mov    %edx,%ebx
  800d85:	89 d7                	mov    %edx,%edi
  800d87:	89 d6                	mov    %edx,%esi
  800d89:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800d9c:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800d9e:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800da1:	83 3a 01             	cmpl   $0x1,(%edx)
  800da4:	7e 09                	jle    800daf <argstart+0x1f>
  800da6:	ba b1 25 80 00       	mov    $0x8025b1,%edx
  800dab:	85 c9                	test   %ecx,%ecx
  800dad:	75 05                	jne    800db4 <argstart+0x24>
  800daf:	ba 00 00 00 00       	mov    $0x0,%edx
  800db4:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800db7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <argnext>:

int
argnext(struct Argstate *args)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 04             	sub    $0x4,%esp
  800dc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dca:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800dd1:	8b 43 08             	mov    0x8(%ebx),%eax
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	74 6f                	je     800e47 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800dd8:	80 38 00             	cmpb   $0x0,(%eax)
  800ddb:	75 4e                	jne    800e2b <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800ddd:	8b 0b                	mov    (%ebx),%ecx
  800ddf:	83 39 01             	cmpl   $0x1,(%ecx)
  800de2:	74 55                	je     800e39 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800de4:	8b 53 04             	mov    0x4(%ebx),%edx
  800de7:	8b 42 04             	mov    0x4(%edx),%eax
  800dea:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ded:	75 4a                	jne    800e39 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800def:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800df3:	74 44                	je     800e39 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800df5:	83 c0 01             	add    $0x1,%eax
  800df8:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800dfb:	83 ec 04             	sub    $0x4,%esp
  800dfe:	8b 01                	mov    (%ecx),%eax
  800e00:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e07:	50                   	push   %eax
  800e08:	8d 42 08             	lea    0x8(%edx),%eax
  800e0b:	50                   	push   %eax
  800e0c:	83 c2 04             	add    $0x4,%edx
  800e0f:	52                   	push   %edx
  800e10:	e8 fa fa ff ff       	call   80090f <memmove>
		(*args->argc)--;
  800e15:	8b 03                	mov    (%ebx),%eax
  800e17:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e1a:	8b 43 08             	mov    0x8(%ebx),%eax
  800e1d:	83 c4 10             	add    $0x10,%esp
  800e20:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e23:	75 06                	jne    800e2b <argnext+0x6b>
  800e25:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e29:	74 0e                	je     800e39 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e2b:	8b 53 08             	mov    0x8(%ebx),%edx
  800e2e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e31:	83 c2 01             	add    $0x1,%edx
  800e34:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e37:	eb 13                	jmp    800e4c <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e39:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e45:	eb 05                	jmp    800e4c <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    

00800e51 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	53                   	push   %ebx
  800e55:	83 ec 04             	sub    $0x4,%esp
  800e58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e5b:	8b 43 08             	mov    0x8(%ebx),%eax
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	74 58                	je     800eba <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e62:	80 38 00             	cmpb   $0x0,(%eax)
  800e65:	74 0c                	je     800e73 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e67:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e6a:	c7 43 08 b1 25 80 00 	movl   $0x8025b1,0x8(%ebx)
  800e71:	eb 42                	jmp    800eb5 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800e73:	8b 13                	mov    (%ebx),%edx
  800e75:	83 3a 01             	cmpl   $0x1,(%edx)
  800e78:	7e 2d                	jle    800ea7 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800e7a:	8b 43 04             	mov    0x4(%ebx),%eax
  800e7d:	8b 48 04             	mov    0x4(%eax),%ecx
  800e80:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e83:	83 ec 04             	sub    $0x4,%esp
  800e86:	8b 12                	mov    (%edx),%edx
  800e88:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e8f:	52                   	push   %edx
  800e90:	8d 50 08             	lea    0x8(%eax),%edx
  800e93:	52                   	push   %edx
  800e94:	83 c0 04             	add    $0x4,%eax
  800e97:	50                   	push   %eax
  800e98:	e8 72 fa ff ff       	call   80090f <memmove>
		(*args->argc)--;
  800e9d:	8b 03                	mov    (%ebx),%eax
  800e9f:	83 28 01             	subl   $0x1,(%eax)
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	eb 0e                	jmp    800eb5 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800ea7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800eae:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800eb5:	8b 43 0c             	mov    0xc(%ebx),%eax
  800eb8:	eb 05                	jmp    800ebf <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ebf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 08             	sub    $0x8,%esp
  800eca:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800ecd:	8b 51 0c             	mov    0xc(%ecx),%edx
  800ed0:	89 d0                	mov    %edx,%eax
  800ed2:	85 d2                	test   %edx,%edx
  800ed4:	75 0c                	jne    800ee2 <argvalue+0x1e>
  800ed6:	83 ec 0c             	sub    $0xc,%esp
  800ed9:	51                   	push   %ecx
  800eda:	e8 72 ff ff ff       	call   800e51 <argnextvalue>
  800edf:	83 c4 10             	add    $0x10,%esp
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	05 00 00 00 30       	add    $0x30000000,%eax
  800eef:	c1 e8 0c             	shr    $0xc,%eax
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	05 00 00 00 30       	add    $0x30000000,%eax
  800eff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f04:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f11:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	c1 ea 16             	shr    $0x16,%edx
  800f1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f22:	f6 c2 01             	test   $0x1,%dl
  800f25:	74 11                	je     800f38 <fd_alloc+0x2d>
  800f27:	89 c2                	mov    %eax,%edx
  800f29:	c1 ea 0c             	shr    $0xc,%edx
  800f2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f33:	f6 c2 01             	test   $0x1,%dl
  800f36:	75 09                	jne    800f41 <fd_alloc+0x36>
			*fd_store = fd;
  800f38:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3f:	eb 17                	jmp    800f58 <fd_alloc+0x4d>
  800f41:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f46:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f4b:	75 c9                	jne    800f16 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f4d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f53:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f60:	83 f8 1f             	cmp    $0x1f,%eax
  800f63:	77 36                	ja     800f9b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f65:	c1 e0 0c             	shl    $0xc,%eax
  800f68:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f6d:	89 c2                	mov    %eax,%edx
  800f6f:	c1 ea 16             	shr    $0x16,%edx
  800f72:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f79:	f6 c2 01             	test   $0x1,%dl
  800f7c:	74 24                	je     800fa2 <fd_lookup+0x48>
  800f7e:	89 c2                	mov    %eax,%edx
  800f80:	c1 ea 0c             	shr    $0xc,%edx
  800f83:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f8a:	f6 c2 01             	test   $0x1,%dl
  800f8d:	74 1a                	je     800fa9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f92:	89 02                	mov    %eax,(%edx)
	return 0;
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
  800f99:	eb 13                	jmp    800fae <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa0:	eb 0c                	jmp    800fae <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa7:	eb 05                	jmp    800fae <fd_lookup+0x54>
  800fa9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 08             	sub    $0x8,%esp
  800fb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb9:	ba 88 29 80 00       	mov    $0x802988,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fbe:	eb 13                	jmp    800fd3 <dev_lookup+0x23>
  800fc0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fc3:	39 08                	cmp    %ecx,(%eax)
  800fc5:	75 0c                	jne    800fd3 <dev_lookup+0x23>
			*dev = devtab[i];
  800fc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fca:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd1:	eb 2e                	jmp    801001 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fd3:	8b 02                	mov    (%edx),%eax
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	75 e7                	jne    800fc0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd9:	a1 08 40 80 00       	mov    0x804008,%eax
  800fde:	8b 40 48             	mov    0x48(%eax),%eax
  800fe1:	83 ec 04             	sub    $0x4,%esp
  800fe4:	51                   	push   %ecx
  800fe5:	50                   	push   %eax
  800fe6:	68 0c 29 80 00       	push   $0x80290c
  800feb:	e8 08 f2 ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  800ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801001:	c9                   	leave  
  801002:	c3                   	ret    

00801003 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
  801008:	83 ec 10             	sub    $0x10,%esp
  80100b:	8b 75 08             	mov    0x8(%ebp),%esi
  80100e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801011:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801014:	50                   	push   %eax
  801015:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80101b:	c1 e8 0c             	shr    $0xc,%eax
  80101e:	50                   	push   %eax
  80101f:	e8 36 ff ff ff       	call   800f5a <fd_lookup>
  801024:	83 c4 08             	add    $0x8,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	78 05                	js     801030 <fd_close+0x2d>
	    || fd != fd2)
  80102b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80102e:	74 0c                	je     80103c <fd_close+0x39>
		return (must_exist ? r : 0);
  801030:	84 db                	test   %bl,%bl
  801032:	ba 00 00 00 00       	mov    $0x0,%edx
  801037:	0f 44 c2             	cmove  %edx,%eax
  80103a:	eb 41                	jmp    80107d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80103c:	83 ec 08             	sub    $0x8,%esp
  80103f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801042:	50                   	push   %eax
  801043:	ff 36                	pushl  (%esi)
  801045:	e8 66 ff ff ff       	call   800fb0 <dev_lookup>
  80104a:	89 c3                	mov    %eax,%ebx
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 1a                	js     80106d <fd_close+0x6a>
		if (dev->dev_close)
  801053:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801056:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801059:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80105e:	85 c0                	test   %eax,%eax
  801060:	74 0b                	je     80106d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	56                   	push   %esi
  801066:	ff d0                	call   *%eax
  801068:	89 c3                	mov    %eax,%ebx
  80106a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80106d:	83 ec 08             	sub    $0x8,%esp
  801070:	56                   	push   %esi
  801071:	6a 00                	push   $0x0
  801073:	e8 8d fb ff ff       	call   800c05 <sys_page_unmap>
	return r;
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	89 d8                	mov    %ebx,%eax
}
  80107d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80108a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108d:	50                   	push   %eax
  80108e:	ff 75 08             	pushl  0x8(%ebp)
  801091:	e8 c4 fe ff ff       	call   800f5a <fd_lookup>
  801096:	83 c4 08             	add    $0x8,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 10                	js     8010ad <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	6a 01                	push   $0x1
  8010a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a5:	e8 59 ff ff ff       	call   801003 <fd_close>
  8010aa:	83 c4 10             	add    $0x10,%esp
}
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <close_all>:

void
close_all(void)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	53                   	push   %ebx
  8010bf:	e8 c0 ff ff ff       	call   801084 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c4:	83 c3 01             	add    $0x1,%ebx
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	83 fb 20             	cmp    $0x20,%ebx
  8010cd:	75 ec                	jne    8010bb <close_all+0xc>
		close(i);
}
  8010cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    

008010d4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
  8010da:	83 ec 2c             	sub    $0x2c,%esp
  8010dd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	ff 75 08             	pushl  0x8(%ebp)
  8010e7:	e8 6e fe ff ff       	call   800f5a <fd_lookup>
  8010ec:	83 c4 08             	add    $0x8,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	0f 88 c1 00 00 00    	js     8011b8 <dup+0xe4>
		return r;
	close(newfdnum);
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	56                   	push   %esi
  8010fb:	e8 84 ff ff ff       	call   801084 <close>

	newfd = INDEX2FD(newfdnum);
  801100:	89 f3                	mov    %esi,%ebx
  801102:	c1 e3 0c             	shl    $0xc,%ebx
  801105:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80110b:	83 c4 04             	add    $0x4,%esp
  80110e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801111:	e8 de fd ff ff       	call   800ef4 <fd2data>
  801116:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801118:	89 1c 24             	mov    %ebx,(%esp)
  80111b:	e8 d4 fd ff ff       	call   800ef4 <fd2data>
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801126:	89 f8                	mov    %edi,%eax
  801128:	c1 e8 16             	shr    $0x16,%eax
  80112b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801132:	a8 01                	test   $0x1,%al
  801134:	74 37                	je     80116d <dup+0x99>
  801136:	89 f8                	mov    %edi,%eax
  801138:	c1 e8 0c             	shr    $0xc,%eax
  80113b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801142:	f6 c2 01             	test   $0x1,%dl
  801145:	74 26                	je     80116d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801147:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	25 07 0e 00 00       	and    $0xe07,%eax
  801156:	50                   	push   %eax
  801157:	ff 75 d4             	pushl  -0x2c(%ebp)
  80115a:	6a 00                	push   $0x0
  80115c:	57                   	push   %edi
  80115d:	6a 00                	push   $0x0
  80115f:	e8 5f fa ff ff       	call   800bc3 <sys_page_map>
  801164:	89 c7                	mov    %eax,%edi
  801166:	83 c4 20             	add    $0x20,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	78 2e                	js     80119b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80116d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801170:	89 d0                	mov    %edx,%eax
  801172:	c1 e8 0c             	shr    $0xc,%eax
  801175:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80117c:	83 ec 0c             	sub    $0xc,%esp
  80117f:	25 07 0e 00 00       	and    $0xe07,%eax
  801184:	50                   	push   %eax
  801185:	53                   	push   %ebx
  801186:	6a 00                	push   $0x0
  801188:	52                   	push   %edx
  801189:	6a 00                	push   $0x0
  80118b:	e8 33 fa ff ff       	call   800bc3 <sys_page_map>
  801190:	89 c7                	mov    %eax,%edi
  801192:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801195:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801197:	85 ff                	test   %edi,%edi
  801199:	79 1d                	jns    8011b8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80119b:	83 ec 08             	sub    $0x8,%esp
  80119e:	53                   	push   %ebx
  80119f:	6a 00                	push   $0x0
  8011a1:	e8 5f fa ff ff       	call   800c05 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011a6:	83 c4 08             	add    $0x8,%esp
  8011a9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011ac:	6a 00                	push   $0x0
  8011ae:	e8 52 fa ff ff       	call   800c05 <sys_page_unmap>
	return r;
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	89 f8                	mov    %edi,%eax
}
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 14             	sub    $0x14,%esp
  8011c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	53                   	push   %ebx
  8011cf:	e8 86 fd ff ff       	call   800f5a <fd_lookup>
  8011d4:	83 c4 08             	add    $0x8,%esp
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 6d                	js     80124a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e7:	ff 30                	pushl  (%eax)
  8011e9:	e8 c2 fd ff ff       	call   800fb0 <dev_lookup>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 4c                	js     801241 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011f8:	8b 42 08             	mov    0x8(%edx),%eax
  8011fb:	83 e0 03             	and    $0x3,%eax
  8011fe:	83 f8 01             	cmp    $0x1,%eax
  801201:	75 21                	jne    801224 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801203:	a1 08 40 80 00       	mov    0x804008,%eax
  801208:	8b 40 48             	mov    0x48(%eax),%eax
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	53                   	push   %ebx
  80120f:	50                   	push   %eax
  801210:	68 4d 29 80 00       	push   $0x80294d
  801215:	e8 de ef ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801222:	eb 26                	jmp    80124a <read+0x8a>
	}
	if (!dev->dev_read)
  801224:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801227:	8b 40 08             	mov    0x8(%eax),%eax
  80122a:	85 c0                	test   %eax,%eax
  80122c:	74 17                	je     801245 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	ff 75 10             	pushl  0x10(%ebp)
  801234:	ff 75 0c             	pushl  0xc(%ebp)
  801237:	52                   	push   %edx
  801238:	ff d0                	call   *%eax
  80123a:	89 c2                	mov    %eax,%edx
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	eb 09                	jmp    80124a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801241:	89 c2                	mov    %eax,%edx
  801243:	eb 05                	jmp    80124a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801245:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80124a:	89 d0                	mov    %edx,%eax
  80124c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	57                   	push   %edi
  801255:	56                   	push   %esi
  801256:	53                   	push   %ebx
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80125d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801260:	bb 00 00 00 00       	mov    $0x0,%ebx
  801265:	eb 21                	jmp    801288 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801267:	83 ec 04             	sub    $0x4,%esp
  80126a:	89 f0                	mov    %esi,%eax
  80126c:	29 d8                	sub    %ebx,%eax
  80126e:	50                   	push   %eax
  80126f:	89 d8                	mov    %ebx,%eax
  801271:	03 45 0c             	add    0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	57                   	push   %edi
  801276:	e8 45 ff ff ff       	call   8011c0 <read>
		if (m < 0)
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 10                	js     801292 <readn+0x41>
			return m;
		if (m == 0)
  801282:	85 c0                	test   %eax,%eax
  801284:	74 0a                	je     801290 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801286:	01 c3                	add    %eax,%ebx
  801288:	39 f3                	cmp    %esi,%ebx
  80128a:	72 db                	jb     801267 <readn+0x16>
  80128c:	89 d8                	mov    %ebx,%eax
  80128e:	eb 02                	jmp    801292 <readn+0x41>
  801290:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    

0080129a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	53                   	push   %ebx
  80129e:	83 ec 14             	sub    $0x14,%esp
  8012a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	53                   	push   %ebx
  8012a9:	e8 ac fc ff ff       	call   800f5a <fd_lookup>
  8012ae:	83 c4 08             	add    $0x8,%esp
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 68                	js     80131f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	50                   	push   %eax
  8012be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c1:	ff 30                	pushl  (%eax)
  8012c3:	e8 e8 fc ff ff       	call   800fb0 <dev_lookup>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 47                	js     801316 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d6:	75 21                	jne    8012f9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d8:	a1 08 40 80 00       	mov    0x804008,%eax
  8012dd:	8b 40 48             	mov    0x48(%eax),%eax
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	53                   	push   %ebx
  8012e4:	50                   	push   %eax
  8012e5:	68 69 29 80 00       	push   $0x802969
  8012ea:	e8 09 ef ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f7:	eb 26                	jmp    80131f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fc:	8b 52 0c             	mov    0xc(%edx),%edx
  8012ff:	85 d2                	test   %edx,%edx
  801301:	74 17                	je     80131a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801303:	83 ec 04             	sub    $0x4,%esp
  801306:	ff 75 10             	pushl  0x10(%ebp)
  801309:	ff 75 0c             	pushl  0xc(%ebp)
  80130c:	50                   	push   %eax
  80130d:	ff d2                	call   *%edx
  80130f:	89 c2                	mov    %eax,%edx
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	eb 09                	jmp    80131f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801316:	89 c2                	mov    %eax,%edx
  801318:	eb 05                	jmp    80131f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80131a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80131f:	89 d0                	mov    %edx,%eax
  801321:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <seek>:

int
seek(int fdnum, off_t offset)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	ff 75 08             	pushl  0x8(%ebp)
  801333:	e8 22 fc ff ff       	call   800f5a <fd_lookup>
  801338:	83 c4 08             	add    $0x8,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 0e                	js     80134d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80133f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801342:	8b 55 0c             	mov    0xc(%ebp),%edx
  801345:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801348:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	53                   	push   %ebx
  801353:	83 ec 14             	sub    $0x14,%esp
  801356:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801359:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	53                   	push   %ebx
  80135e:	e8 f7 fb ff ff       	call   800f5a <fd_lookup>
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	89 c2                	mov    %eax,%edx
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 65                	js     8013d1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136c:	83 ec 08             	sub    $0x8,%esp
  80136f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801372:	50                   	push   %eax
  801373:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801376:	ff 30                	pushl  (%eax)
  801378:	e8 33 fc ff ff       	call   800fb0 <dev_lookup>
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	85 c0                	test   %eax,%eax
  801382:	78 44                	js     8013c8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801384:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801387:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80138b:	75 21                	jne    8013ae <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80138d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801392:	8b 40 48             	mov    0x48(%eax),%eax
  801395:	83 ec 04             	sub    $0x4,%esp
  801398:	53                   	push   %ebx
  801399:	50                   	push   %eax
  80139a:	68 2c 29 80 00       	push   $0x80292c
  80139f:	e8 54 ee ff ff       	call   8001f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ac:	eb 23                	jmp    8013d1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013b1:	8b 52 18             	mov    0x18(%edx),%edx
  8013b4:	85 d2                	test   %edx,%edx
  8013b6:	74 14                	je     8013cc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	ff 75 0c             	pushl  0xc(%ebp)
  8013be:	50                   	push   %eax
  8013bf:	ff d2                	call   *%edx
  8013c1:	89 c2                	mov    %eax,%edx
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	eb 09                	jmp    8013d1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c8:	89 c2                	mov    %eax,%edx
  8013ca:	eb 05                	jmp    8013d1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013d1:	89 d0                	mov    %edx,%eax
  8013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 14             	sub    $0x14,%esp
  8013df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e5:	50                   	push   %eax
  8013e6:	ff 75 08             	pushl  0x8(%ebp)
  8013e9:	e8 6c fb ff ff       	call   800f5a <fd_lookup>
  8013ee:	83 c4 08             	add    $0x8,%esp
  8013f1:	89 c2                	mov    %eax,%edx
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 58                	js     80144f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801401:	ff 30                	pushl  (%eax)
  801403:	e8 a8 fb ff ff       	call   800fb0 <dev_lookup>
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 37                	js     801446 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80140f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801412:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801416:	74 32                	je     80144a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801418:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80141b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801422:	00 00 00 
	stat->st_isdir = 0;
  801425:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80142c:	00 00 00 
	stat->st_dev = dev;
  80142f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	53                   	push   %ebx
  801439:	ff 75 f0             	pushl  -0x10(%ebp)
  80143c:	ff 50 14             	call   *0x14(%eax)
  80143f:	89 c2                	mov    %eax,%edx
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	eb 09                	jmp    80144f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801446:	89 c2                	mov    %eax,%edx
  801448:	eb 05                	jmp    80144f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80144a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80144f:	89 d0                	mov    %edx,%eax
  801451:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	56                   	push   %esi
  80145a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	6a 00                	push   $0x0
  801460:	ff 75 08             	pushl  0x8(%ebp)
  801463:	e8 e3 01 00 00       	call   80164b <open>
  801468:	89 c3                	mov    %eax,%ebx
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 1b                	js     80148c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	50                   	push   %eax
  801478:	e8 5b ff ff ff       	call   8013d8 <fstat>
  80147d:	89 c6                	mov    %eax,%esi
	close(fd);
  80147f:	89 1c 24             	mov    %ebx,(%esp)
  801482:	e8 fd fb ff ff       	call   801084 <close>
	return r;
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	89 f0                	mov    %esi,%eax
}
  80148c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	56                   	push   %esi
  801497:	53                   	push   %ebx
  801498:	89 c6                	mov    %eax,%esi
  80149a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80149c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014a3:	75 12                	jne    8014b7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	6a 01                	push   $0x1
  8014aa:	e8 dd 0d 00 00       	call   80228c <ipc_find_env>
  8014af:	a3 00 40 80 00       	mov    %eax,0x804000
  8014b4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014b7:	6a 07                	push   $0x7
  8014b9:	68 00 50 80 00       	push   $0x805000
  8014be:	56                   	push   %esi
  8014bf:	ff 35 00 40 80 00    	pushl  0x804000
  8014c5:	e8 36 0d 00 00       	call   802200 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014ca:	83 c4 0c             	add    $0xc,%esp
  8014cd:	6a 00                	push   $0x0
  8014cf:	53                   	push   %ebx
  8014d0:	6a 00                	push   $0x0
  8014d2:	e8 b4 0c 00 00       	call   80218b <ipc_recv>
}
  8014d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014da:	5b                   	pop    %ebx
  8014db:	5e                   	pop    %esi
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801501:	e8 8d ff ff ff       	call   801493 <fsipc>
}
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80150e:	8b 45 08             	mov    0x8(%ebp),%eax
  801511:	8b 40 0c             	mov    0xc(%eax),%eax
  801514:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801519:	ba 00 00 00 00       	mov    $0x0,%edx
  80151e:	b8 06 00 00 00       	mov    $0x6,%eax
  801523:	e8 6b ff ff ff       	call   801493 <fsipc>
}
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <devfile_stat>:
                return ((ssize_t)r);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801534:	8b 45 08             	mov    0x8(%ebp),%eax
  801537:	8b 40 0c             	mov    0xc(%eax),%eax
  80153a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80153f:	ba 00 00 00 00       	mov    $0x0,%edx
  801544:	b8 05 00 00 00       	mov    $0x5,%eax
  801549:	e8 45 ff ff ff       	call   801493 <fsipc>
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 2c                	js     80157e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	68 00 50 80 00       	push   $0x805000
  80155a:	53                   	push   %ebx
  80155b:	e8 1d f2 ff ff       	call   80077d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801560:	a1 80 50 80 00       	mov    0x805080,%eax
  801565:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80156b:	a1 84 50 80 00       	mov    0x805084,%eax
  801570:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	8b 45 10             	mov    0x10(%ebp),%eax
  80158c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801591:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801596:	0f 47 c2             	cmova  %edx,%eax
	int r;
	if(n > (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t))))
	{
		n = (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t)));
	}
		fsipcbuf.write.req_fileid = fd->fd_file.id;
  801599:	8b 55 08             	mov    0x8(%ebp),%edx
  80159c:	8b 52 0c             	mov    0xc(%edx),%edx
  80159f:	89 15 00 50 80 00    	mov    %edx,0x805000
		fsipcbuf.write.req_n = n;
  8015a5:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove((void *)fsipcbuf.write.req_buf, buf, n);
  8015aa:	50                   	push   %eax
  8015ab:	ff 75 0c             	pushl  0xc(%ebp)
  8015ae:	68 08 50 80 00       	push   $0x805008
  8015b3:	e8 57 f3 ff ff       	call   80090f <memmove>
		r = fsipc(FSREQ_WRITE, NULL);
  8015b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bd:	b8 04 00 00 00       	mov    $0x4,%eax
  8015c2:	e8 cc fe ff ff       	call   801493 <fsipc>
                return ((ssize_t)r);
}
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	56                   	push   %esi
  8015cd:	53                   	push   %ebx
  8015ce:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8015d7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015dc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ec:	e8 a2 fe ff ff       	call   801493 <fsipc>
  8015f1:	89 c3                	mov    %eax,%ebx
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 4b                	js     801642 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015f7:	39 c6                	cmp    %eax,%esi
  8015f9:	73 16                	jae    801611 <devfile_read+0x48>
  8015fb:	68 9c 29 80 00       	push   $0x80299c
  801600:	68 a3 29 80 00       	push   $0x8029a3
  801605:	6a 7c                	push   $0x7c
  801607:	68 b8 29 80 00       	push   $0x8029b8
  80160c:	e8 34 0b 00 00       	call   802145 <_panic>
	assert(r <= PGSIZE);
  801611:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801616:	7e 16                	jle    80162e <devfile_read+0x65>
  801618:	68 c3 29 80 00       	push   $0x8029c3
  80161d:	68 a3 29 80 00       	push   $0x8029a3
  801622:	6a 7d                	push   $0x7d
  801624:	68 b8 29 80 00       	push   $0x8029b8
  801629:	e8 17 0b 00 00       	call   802145 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80162e:	83 ec 04             	sub    $0x4,%esp
  801631:	50                   	push   %eax
  801632:	68 00 50 80 00       	push   $0x805000
  801637:	ff 75 0c             	pushl  0xc(%ebp)
  80163a:	e8 d0 f2 ff ff       	call   80090f <memmove>
	return r;
  80163f:	83 c4 10             	add    $0x10,%esp
}
  801642:	89 d8                	mov    %ebx,%eax
  801644:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	53                   	push   %ebx
  80164f:	83 ec 20             	sub    $0x20,%esp
  801652:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801655:	53                   	push   %ebx
  801656:	e8 e9 f0 ff ff       	call   800744 <strlen>
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801663:	7f 67                	jg     8016cc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	e8 9a f8 ff ff       	call   800f0b <fd_alloc>
  801671:	83 c4 10             	add    $0x10,%esp
		return r;
  801674:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801676:	85 c0                	test   %eax,%eax
  801678:	78 57                	js     8016d1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80167a:	83 ec 08             	sub    $0x8,%esp
  80167d:	53                   	push   %ebx
  80167e:	68 00 50 80 00       	push   $0x805000
  801683:	e8 f5 f0 ff ff       	call   80077d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801688:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801690:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801693:	b8 01 00 00 00       	mov    $0x1,%eax
  801698:	e8 f6 fd ff ff       	call   801493 <fsipc>
  80169d:	89 c3                	mov    %eax,%ebx
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	79 14                	jns    8016ba <open+0x6f>
		fd_close(fd, 0);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	6a 00                	push   $0x0
  8016ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ae:	e8 50 f9 ff ff       	call   801003 <fd_close>
		return r;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	89 da                	mov    %ebx,%edx
  8016b8:	eb 17                	jmp    8016d1 <open+0x86>
	}

	return fd2num(fd);
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c0:	e8 1f f8 ff ff       	call   800ee4 <fd2num>
  8016c5:	89 c2                	mov    %eax,%edx
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	eb 05                	jmp    8016d1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016cc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016d1:	89 d0                	mov    %edx,%eax
  8016d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016de:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8016e8:	e8 a6 fd ff ff       	call   801493 <fsipc>
}
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016ef:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016f3:	7e 37                	jle    80172c <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	53                   	push   %ebx
  8016f9:	83 ec 08             	sub    $0x8,%esp
  8016fc:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016fe:	ff 70 04             	pushl  0x4(%eax)
  801701:	8d 40 10             	lea    0x10(%eax),%eax
  801704:	50                   	push   %eax
  801705:	ff 33                	pushl  (%ebx)
  801707:	e8 8e fb ff ff       	call   80129a <write>
		if (result > 0)
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	7e 03                	jle    801716 <writebuf+0x27>
			b->result += result;
  801713:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801716:	3b 43 04             	cmp    0x4(%ebx),%eax
  801719:	74 0d                	je     801728 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80171b:	85 c0                	test   %eax,%eax
  80171d:	ba 00 00 00 00       	mov    $0x0,%edx
  801722:	0f 4f c2             	cmovg  %edx,%eax
  801725:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801728:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172b:	c9                   	leave  
  80172c:	f3 c3                	repz ret 

0080172e <putch>:

static void
putch(int ch, void *thunk)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801738:	8b 53 04             	mov    0x4(%ebx),%edx
  80173b:	8d 42 01             	lea    0x1(%edx),%eax
  80173e:	89 43 04             	mov    %eax,0x4(%ebx)
  801741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801744:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801748:	3d 00 01 00 00       	cmp    $0x100,%eax
  80174d:	75 0e                	jne    80175d <putch+0x2f>
		writebuf(b);
  80174f:	89 d8                	mov    %ebx,%eax
  801751:	e8 99 ff ff ff       	call   8016ef <writebuf>
		b->idx = 0;
  801756:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80175d:	83 c4 04             	add    $0x4,%esp
  801760:	5b                   	pop    %ebx
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80176c:	8b 45 08             	mov    0x8(%ebp),%eax
  80176f:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801775:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80177c:	00 00 00 
	b.result = 0;
  80177f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801786:	00 00 00 
	b.error = 1;
  801789:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801790:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801793:	ff 75 10             	pushl  0x10(%ebp)
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80179f:	50                   	push   %eax
  8017a0:	68 2e 17 80 00       	push   $0x80172e
  8017a5:	e8 85 eb ff ff       	call   80032f <vprintfmt>
	if (b.idx > 0)
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017b4:	7e 0b                	jle    8017c1 <vfprintf+0x5e>
		writebuf(&b);
  8017b6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017bc:	e8 2e ff ff ff       	call   8016ef <writebuf>

	return (b.result ? b.result : b.error);
  8017c1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017d8:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017db:	50                   	push   %eax
  8017dc:	ff 75 0c             	pushl  0xc(%ebp)
  8017df:	ff 75 08             	pushl  0x8(%ebp)
  8017e2:	e8 7c ff ff ff       	call   801763 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <printf>:

int
printf(const char *fmt, ...)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017f2:	50                   	push   %eax
  8017f3:	ff 75 08             	pushl  0x8(%ebp)
  8017f6:	6a 01                	push   $0x1
  8017f8:	e8 66 ff ff ff       	call   801763 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801805:	68 cf 29 80 00       	push   $0x8029cf
  80180a:	ff 75 0c             	pushl  0xc(%ebp)
  80180d:	e8 6b ef ff ff       	call   80077d <strcpy>
	return 0;
}
  801812:	b8 00 00 00 00       	mov    $0x0,%eax
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	53                   	push   %ebx
  80181d:	83 ec 10             	sub    $0x10,%esp
  801820:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801823:	53                   	push   %ebx
  801824:	e8 9c 0a 00 00       	call   8022c5 <pageref>
  801829:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80182c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801831:	83 f8 01             	cmp    $0x1,%eax
  801834:	75 10                	jne    801846 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	ff 73 0c             	pushl  0xc(%ebx)
  80183c:	e8 c0 02 00 00       	call   801b01 <nsipc_close>
  801841:	89 c2                	mov    %eax,%edx
  801843:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801846:	89 d0                	mov    %edx,%eax
  801848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801853:	6a 00                	push   $0x0
  801855:	ff 75 10             	pushl  0x10(%ebp)
  801858:	ff 75 0c             	pushl  0xc(%ebp)
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	ff 70 0c             	pushl  0xc(%eax)
  801861:	e8 78 03 00 00       	call   801bde <nsipc_send>
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80186e:	6a 00                	push   $0x0
  801870:	ff 75 10             	pushl  0x10(%ebp)
  801873:	ff 75 0c             	pushl  0xc(%ebp)
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	ff 70 0c             	pushl  0xc(%eax)
  80187c:	e8 f1 02 00 00       	call   801b72 <nsipc_recv>
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801889:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80188c:	52                   	push   %edx
  80188d:	50                   	push   %eax
  80188e:	e8 c7 f6 ff ff       	call   800f5a <fd_lookup>
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	85 c0                	test   %eax,%eax
  801898:	78 17                	js     8018b1 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80189a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018a3:	39 08                	cmp    %ecx,(%eax)
  8018a5:	75 05                	jne    8018ac <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018aa:	eb 05                	jmp    8018b1 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018b1:	c9                   	leave  
  8018b2:	c3                   	ret    

008018b3 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	56                   	push   %esi
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 1c             	sub    $0x1c,%esp
  8018bb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c0:	50                   	push   %eax
  8018c1:	e8 45 f6 ff ff       	call   800f0b <fd_alloc>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 1b                	js     8018ea <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018cf:	83 ec 04             	sub    $0x4,%esp
  8018d2:	68 07 04 00 00       	push   $0x407
  8018d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018da:	6a 00                	push   $0x0
  8018dc:	e8 9f f2 ff ff       	call   800b80 <sys_page_alloc>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	79 10                	jns    8018fa <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8018ea:	83 ec 0c             	sub    $0xc,%esp
  8018ed:	56                   	push   %esi
  8018ee:	e8 0e 02 00 00       	call   801b01 <nsipc_close>
		return r;
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	89 d8                	mov    %ebx,%eax
  8018f8:	eb 24                	jmp    80191e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8018fa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801900:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801903:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801905:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801908:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80190f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	50                   	push   %eax
  801916:	e8 c9 f5 ff ff       	call   800ee4 <fd2num>
  80191b:	83 c4 10             	add    $0x10,%esp
}
  80191e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801921:	5b                   	pop    %ebx
  801922:	5e                   	pop    %esi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80192b:	8b 45 08             	mov    0x8(%ebp),%eax
  80192e:	e8 50 ff ff ff       	call   801883 <fd2sockid>
		return r;
  801933:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801935:	85 c0                	test   %eax,%eax
  801937:	78 1f                	js     801958 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801939:	83 ec 04             	sub    $0x4,%esp
  80193c:	ff 75 10             	pushl  0x10(%ebp)
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	50                   	push   %eax
  801943:	e8 12 01 00 00       	call   801a5a <nsipc_accept>
  801948:	83 c4 10             	add    $0x10,%esp
		return r;
  80194b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 07                	js     801958 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801951:	e8 5d ff ff ff       	call   8018b3 <alloc_sockfd>
  801956:	89 c1                	mov    %eax,%ecx
}
  801958:	89 c8                	mov    %ecx,%eax
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	e8 19 ff ff ff       	call   801883 <fd2sockid>
  80196a:	85 c0                	test   %eax,%eax
  80196c:	78 12                	js     801980 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80196e:	83 ec 04             	sub    $0x4,%esp
  801971:	ff 75 10             	pushl  0x10(%ebp)
  801974:	ff 75 0c             	pushl  0xc(%ebp)
  801977:	50                   	push   %eax
  801978:	e8 2d 01 00 00       	call   801aaa <nsipc_bind>
  80197d:	83 c4 10             	add    $0x10,%esp
}
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <shutdown>:

int
shutdown(int s, int how)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801988:	8b 45 08             	mov    0x8(%ebp),%eax
  80198b:	e8 f3 fe ff ff       	call   801883 <fd2sockid>
  801990:	85 c0                	test   %eax,%eax
  801992:	78 0f                	js     8019a3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	50                   	push   %eax
  80199b:	e8 3f 01 00 00       	call   801adf <nsipc_shutdown>
  8019a0:	83 c4 10             	add    $0x10,%esp
}
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    

008019a5 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	e8 d0 fe ff ff       	call   801883 <fd2sockid>
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 12                	js     8019c9 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8019b7:	83 ec 04             	sub    $0x4,%esp
  8019ba:	ff 75 10             	pushl  0x10(%ebp)
  8019bd:	ff 75 0c             	pushl  0xc(%ebp)
  8019c0:	50                   	push   %eax
  8019c1:	e8 55 01 00 00       	call   801b1b <nsipc_connect>
  8019c6:	83 c4 10             	add    $0x10,%esp
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <listen>:

int
listen(int s, int backlog)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	e8 aa fe ff ff       	call   801883 <fd2sockid>
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 0f                	js     8019ec <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	ff 75 0c             	pushl  0xc(%ebp)
  8019e3:	50                   	push   %eax
  8019e4:	e8 67 01 00 00       	call   801b50 <nsipc_listen>
  8019e9:	83 c4 10             	add    $0x10,%esp
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019f4:	ff 75 10             	pushl  0x10(%ebp)
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	ff 75 08             	pushl  0x8(%ebp)
  8019fd:	e8 3a 02 00 00       	call   801c3c <nsipc_socket>
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 05                	js     801a0e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a09:	e8 a5 fe ff ff       	call   8018b3 <alloc_sockfd>
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	53                   	push   %ebx
  801a14:	83 ec 04             	sub    $0x4,%esp
  801a17:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a19:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a20:	75 12                	jne    801a34 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	6a 02                	push   $0x2
  801a27:	e8 60 08 00 00       	call   80228c <ipc_find_env>
  801a2c:	a3 04 40 80 00       	mov    %eax,0x804004
  801a31:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a34:	6a 07                	push   $0x7
  801a36:	68 00 60 80 00       	push   $0x806000
  801a3b:	53                   	push   %ebx
  801a3c:	ff 35 04 40 80 00    	pushl  0x804004
  801a42:	e8 b9 07 00 00       	call   802200 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a47:	83 c4 0c             	add    $0xc,%esp
  801a4a:	6a 00                	push   $0x0
  801a4c:	6a 00                	push   $0x0
  801a4e:	6a 00                	push   $0x0
  801a50:	e8 36 07 00 00       	call   80218b <ipc_recv>
}
  801a55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a58:	c9                   	leave  
  801a59:	c3                   	ret    

00801a5a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	56                   	push   %esi
  801a5e:	53                   	push   %ebx
  801a5f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a62:	8b 45 08             	mov    0x8(%ebp),%eax
  801a65:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a6a:	8b 06                	mov    (%esi),%eax
  801a6c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a71:	b8 01 00 00 00       	mov    $0x1,%eax
  801a76:	e8 95 ff ff ff       	call   801a10 <nsipc>
  801a7b:	89 c3                	mov    %eax,%ebx
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 20                	js     801aa1 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a81:	83 ec 04             	sub    $0x4,%esp
  801a84:	ff 35 10 60 80 00    	pushl  0x806010
  801a8a:	68 00 60 80 00       	push   $0x806000
  801a8f:	ff 75 0c             	pushl  0xc(%ebp)
  801a92:	e8 78 ee ff ff       	call   80090f <memmove>
		*addrlen = ret->ret_addrlen;
  801a97:	a1 10 60 80 00       	mov    0x806010,%eax
  801a9c:	89 06                	mov    %eax,(%esi)
  801a9e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801aa1:	89 d8                	mov    %ebx,%eax
  801aa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	53                   	push   %ebx
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801abc:	53                   	push   %ebx
  801abd:	ff 75 0c             	pushl  0xc(%ebp)
  801ac0:	68 04 60 80 00       	push   $0x806004
  801ac5:	e8 45 ee ff ff       	call   80090f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801aca:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ad0:	b8 02 00 00 00       	mov    $0x2,%eax
  801ad5:	e8 36 ff ff ff       	call   801a10 <nsipc>
}
  801ada:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801af5:	b8 03 00 00 00       	mov    $0x3,%eax
  801afa:	e8 11 ff ff ff       	call   801a10 <nsipc>
}
  801aff:	c9                   	leave  
  801b00:	c3                   	ret    

00801b01 <nsipc_close>:

int
nsipc_close(int s)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b0f:	b8 04 00 00 00       	mov    $0x4,%eax
  801b14:	e8 f7 fe ff ff       	call   801a10 <nsipc>
}
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	53                   	push   %ebx
  801b1f:	83 ec 08             	sub    $0x8,%esp
  801b22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b2d:	53                   	push   %ebx
  801b2e:	ff 75 0c             	pushl  0xc(%ebp)
  801b31:	68 04 60 80 00       	push   $0x806004
  801b36:	e8 d4 ed ff ff       	call   80090f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b3b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b41:	b8 05 00 00 00       	mov    $0x5,%eax
  801b46:	e8 c5 fe ff ff       	call   801a10 <nsipc>
}
  801b4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b61:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b66:	b8 06 00 00 00       	mov    $0x6,%eax
  801b6b:	e8 a0 fe ff ff       	call   801a10 <nsipc>
}
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    

00801b72 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	56                   	push   %esi
  801b76:	53                   	push   %ebx
  801b77:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b82:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b88:	8b 45 14             	mov    0x14(%ebp),%eax
  801b8b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b90:	b8 07 00 00 00       	mov    $0x7,%eax
  801b95:	e8 76 fe ff ff       	call   801a10 <nsipc>
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	78 35                	js     801bd5 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ba0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ba5:	7f 04                	jg     801bab <nsipc_recv+0x39>
  801ba7:	39 c6                	cmp    %eax,%esi
  801ba9:	7d 16                	jge    801bc1 <nsipc_recv+0x4f>
  801bab:	68 db 29 80 00       	push   $0x8029db
  801bb0:	68 a3 29 80 00       	push   $0x8029a3
  801bb5:	6a 62                	push   $0x62
  801bb7:	68 f0 29 80 00       	push   $0x8029f0
  801bbc:	e8 84 05 00 00       	call   802145 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	50                   	push   %eax
  801bc5:	68 00 60 80 00       	push   $0x806000
  801bca:	ff 75 0c             	pushl  0xc(%ebp)
  801bcd:	e8 3d ed ff ff       	call   80090f <memmove>
  801bd2:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801bd5:	89 d8                	mov    %ebx,%eax
  801bd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	53                   	push   %ebx
  801be2:	83 ec 04             	sub    $0x4,%esp
  801be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801be8:	8b 45 08             	mov    0x8(%ebp),%eax
  801beb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801bf0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801bf6:	7e 16                	jle    801c0e <nsipc_send+0x30>
  801bf8:	68 fc 29 80 00       	push   $0x8029fc
  801bfd:	68 a3 29 80 00       	push   $0x8029a3
  801c02:	6a 6d                	push   $0x6d
  801c04:	68 f0 29 80 00       	push   $0x8029f0
  801c09:	e8 37 05 00 00       	call   802145 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c0e:	83 ec 04             	sub    $0x4,%esp
  801c11:	53                   	push   %ebx
  801c12:	ff 75 0c             	pushl  0xc(%ebp)
  801c15:	68 0c 60 80 00       	push   $0x80600c
  801c1a:	e8 f0 ec ff ff       	call   80090f <memmove>
	nsipcbuf.send.req_size = size;
  801c1f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c25:	8b 45 14             	mov    0x14(%ebp),%eax
  801c28:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c2d:	b8 08 00 00 00       	mov    $0x8,%eax
  801c32:	e8 d9 fd ff ff       	call   801a10 <nsipc>
}
  801c37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c52:	8b 45 10             	mov    0x10(%ebp),%eax
  801c55:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c5a:	b8 09 00 00 00       	mov    $0x9,%eax
  801c5f:	e8 ac fd ff ff       	call   801a10 <nsipc>
}
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    

00801c66 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	56                   	push   %esi
  801c6a:	53                   	push   %ebx
  801c6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c6e:	83 ec 0c             	sub    $0xc,%esp
  801c71:	ff 75 08             	pushl  0x8(%ebp)
  801c74:	e8 7b f2 ff ff       	call   800ef4 <fd2data>
  801c79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c7b:	83 c4 08             	add    $0x8,%esp
  801c7e:	68 08 2a 80 00       	push   $0x802a08
  801c83:	53                   	push   %ebx
  801c84:	e8 f4 ea ff ff       	call   80077d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c89:	8b 46 04             	mov    0x4(%esi),%eax
  801c8c:	2b 06                	sub    (%esi),%eax
  801c8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c9b:	00 00 00 
	stat->st_dev = &devpipe;
  801c9e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ca5:	30 80 00 
	return 0;
}
  801ca8:	b8 00 00 00 00       	mov    $0x0,%eax
  801cad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	53                   	push   %ebx
  801cb8:	83 ec 0c             	sub    $0xc,%esp
  801cbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cbe:	53                   	push   %ebx
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 3f ef ff ff       	call   800c05 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cc6:	89 1c 24             	mov    %ebx,(%esp)
  801cc9:	e8 26 f2 ff ff       	call   800ef4 <fd2data>
  801cce:	83 c4 08             	add    $0x8,%esp
  801cd1:	50                   	push   %eax
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 2c ef ff ff       	call   800c05 <sys_page_unmap>
}
  801cd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cea:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cec:	a1 08 40 80 00       	mov    0x804008,%eax
  801cf1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801cf4:	83 ec 0c             	sub    $0xc,%esp
  801cf7:	ff 75 e0             	pushl  -0x20(%ebp)
  801cfa:	e8 c6 05 00 00       	call   8022c5 <pageref>
  801cff:	89 c3                	mov    %eax,%ebx
  801d01:	89 3c 24             	mov    %edi,(%esp)
  801d04:	e8 bc 05 00 00       	call   8022c5 <pageref>
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	39 c3                	cmp    %eax,%ebx
  801d0e:	0f 94 c1             	sete   %cl
  801d11:	0f b6 c9             	movzbl %cl,%ecx
  801d14:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d17:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d1d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d20:	39 ce                	cmp    %ecx,%esi
  801d22:	74 1b                	je     801d3f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d24:	39 c3                	cmp    %eax,%ebx
  801d26:	75 c4                	jne    801cec <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d28:	8b 42 58             	mov    0x58(%edx),%eax
  801d2b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d2e:	50                   	push   %eax
  801d2f:	56                   	push   %esi
  801d30:	68 0f 2a 80 00       	push   $0x802a0f
  801d35:	e8 be e4 ff ff       	call   8001f8 <cprintf>
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	eb ad                	jmp    801cec <_pipeisclosed+0xe>
	}
}
  801d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d45:	5b                   	pop    %ebx
  801d46:	5e                   	pop    %esi
  801d47:	5f                   	pop    %edi
  801d48:	5d                   	pop    %ebp
  801d49:	c3                   	ret    

00801d4a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	57                   	push   %edi
  801d4e:	56                   	push   %esi
  801d4f:	53                   	push   %ebx
  801d50:	83 ec 28             	sub    $0x28,%esp
  801d53:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d56:	56                   	push   %esi
  801d57:	e8 98 f1 ff ff       	call   800ef4 <fd2data>
  801d5c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	bf 00 00 00 00       	mov    $0x0,%edi
  801d66:	eb 4b                	jmp    801db3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d68:	89 da                	mov    %ebx,%edx
  801d6a:	89 f0                	mov    %esi,%eax
  801d6c:	e8 6d ff ff ff       	call   801cde <_pipeisclosed>
  801d71:	85 c0                	test   %eax,%eax
  801d73:	75 48                	jne    801dbd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d75:	e8 e7 ed ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d7a:	8b 43 04             	mov    0x4(%ebx),%eax
  801d7d:	8b 0b                	mov    (%ebx),%ecx
  801d7f:	8d 51 20             	lea    0x20(%ecx),%edx
  801d82:	39 d0                	cmp    %edx,%eax
  801d84:	73 e2                	jae    801d68 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d89:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d8d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d90:	89 c2                	mov    %eax,%edx
  801d92:	c1 fa 1f             	sar    $0x1f,%edx
  801d95:	89 d1                	mov    %edx,%ecx
  801d97:	c1 e9 1b             	shr    $0x1b,%ecx
  801d9a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d9d:	83 e2 1f             	and    $0x1f,%edx
  801da0:	29 ca                	sub    %ecx,%edx
  801da2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801da6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801daa:	83 c0 01             	add    $0x1,%eax
  801dad:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801db0:	83 c7 01             	add    $0x1,%edi
  801db3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801db6:	75 c2                	jne    801d7a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801db8:	8b 45 10             	mov    0x10(%ebp),%eax
  801dbb:	eb 05                	jmp    801dc2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dbd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    

00801dca <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	57                   	push   %edi
  801dce:	56                   	push   %esi
  801dcf:	53                   	push   %ebx
  801dd0:	83 ec 18             	sub    $0x18,%esp
  801dd3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dd6:	57                   	push   %edi
  801dd7:	e8 18 f1 ff ff       	call   800ef4 <fd2data>
  801ddc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de6:	eb 3d                	jmp    801e25 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801de8:	85 db                	test   %ebx,%ebx
  801dea:	74 04                	je     801df0 <devpipe_read+0x26>
				return i;
  801dec:	89 d8                	mov    %ebx,%eax
  801dee:	eb 44                	jmp    801e34 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801df0:	89 f2                	mov    %esi,%edx
  801df2:	89 f8                	mov    %edi,%eax
  801df4:	e8 e5 fe ff ff       	call   801cde <_pipeisclosed>
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	75 32                	jne    801e2f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dfd:	e8 5f ed ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e02:	8b 06                	mov    (%esi),%eax
  801e04:	3b 46 04             	cmp    0x4(%esi),%eax
  801e07:	74 df                	je     801de8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e09:	99                   	cltd   
  801e0a:	c1 ea 1b             	shr    $0x1b,%edx
  801e0d:	01 d0                	add    %edx,%eax
  801e0f:	83 e0 1f             	and    $0x1f,%eax
  801e12:	29 d0                	sub    %edx,%eax
  801e14:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e1c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e1f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e22:	83 c3 01             	add    $0x1,%ebx
  801e25:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e28:	75 d8                	jne    801e02 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2d:	eb 05                	jmp    801e34 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e37:	5b                   	pop    %ebx
  801e38:	5e                   	pop    %esi
  801e39:	5f                   	pop    %edi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    

00801e3c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	e8 be f0 ff ff       	call   800f0b <fd_alloc>
  801e4d:	83 c4 10             	add    $0x10,%esp
  801e50:	89 c2                	mov    %eax,%edx
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 2c 01 00 00    	js     801f86 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5a:	83 ec 04             	sub    $0x4,%esp
  801e5d:	68 07 04 00 00       	push   $0x407
  801e62:	ff 75 f4             	pushl  -0xc(%ebp)
  801e65:	6a 00                	push   $0x0
  801e67:	e8 14 ed ff ff       	call   800b80 <sys_page_alloc>
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	89 c2                	mov    %eax,%edx
  801e71:	85 c0                	test   %eax,%eax
  801e73:	0f 88 0d 01 00 00    	js     801f86 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	e8 86 f0 ff ff       	call   800f0b <fd_alloc>
  801e85:	89 c3                	mov    %eax,%ebx
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	0f 88 e2 00 00 00    	js     801f74 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e92:	83 ec 04             	sub    $0x4,%esp
  801e95:	68 07 04 00 00       	push   $0x407
  801e9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9d:	6a 00                	push   $0x0
  801e9f:	e8 dc ec ff ff       	call   800b80 <sys_page_alloc>
  801ea4:	89 c3                	mov    %eax,%ebx
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	0f 88 c3 00 00 00    	js     801f74 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eb1:	83 ec 0c             	sub    $0xc,%esp
  801eb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb7:	e8 38 f0 ff ff       	call   800ef4 <fd2data>
  801ebc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebe:	83 c4 0c             	add    $0xc,%esp
  801ec1:	68 07 04 00 00       	push   $0x407
  801ec6:	50                   	push   %eax
  801ec7:	6a 00                	push   $0x0
  801ec9:	e8 b2 ec ff ff       	call   800b80 <sys_page_alloc>
  801ece:	89 c3                	mov    %eax,%ebx
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	0f 88 89 00 00 00    	js     801f64 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801edb:	83 ec 0c             	sub    $0xc,%esp
  801ede:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee1:	e8 0e f0 ff ff       	call   800ef4 <fd2data>
  801ee6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eed:	50                   	push   %eax
  801eee:	6a 00                	push   $0x0
  801ef0:	56                   	push   %esi
  801ef1:	6a 00                	push   $0x0
  801ef3:	e8 cb ec ff ff       	call   800bc3 <sys_page_map>
  801ef8:	89 c3                	mov    %eax,%ebx
  801efa:	83 c4 20             	add    $0x20,%esp
  801efd:	85 c0                	test   %eax,%eax
  801eff:	78 55                	js     801f56 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f16:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f1f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f24:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f2b:	83 ec 0c             	sub    $0xc,%esp
  801f2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f31:	e8 ae ef ff ff       	call   800ee4 <fd2num>
  801f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f39:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f3b:	83 c4 04             	add    $0x4,%esp
  801f3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801f41:	e8 9e ef ff ff       	call   800ee4 <fd2num>
  801f46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f49:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f54:	eb 30                	jmp    801f86 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f56:	83 ec 08             	sub    $0x8,%esp
  801f59:	56                   	push   %esi
  801f5a:	6a 00                	push   $0x0
  801f5c:	e8 a4 ec ff ff       	call   800c05 <sys_page_unmap>
  801f61:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f64:	83 ec 08             	sub    $0x8,%esp
  801f67:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6a:	6a 00                	push   $0x0
  801f6c:	e8 94 ec ff ff       	call   800c05 <sys_page_unmap>
  801f71:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f74:	83 ec 08             	sub    $0x8,%esp
  801f77:	ff 75 f4             	pushl  -0xc(%ebp)
  801f7a:	6a 00                	push   $0x0
  801f7c:	e8 84 ec ff ff       	call   800c05 <sys_page_unmap>
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f86:	89 d0                	mov    %edx,%eax
  801f88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8b:	5b                   	pop    %ebx
  801f8c:	5e                   	pop    %esi
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    

00801f8f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f98:	50                   	push   %eax
  801f99:	ff 75 08             	pushl  0x8(%ebp)
  801f9c:	e8 b9 ef ff ff       	call   800f5a <fd_lookup>
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 18                	js     801fc0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fa8:	83 ec 0c             	sub    $0xc,%esp
  801fab:	ff 75 f4             	pushl  -0xc(%ebp)
  801fae:	e8 41 ef ff ff       	call   800ef4 <fd2data>
	return _pipeisclosed(fd, p);
  801fb3:	89 c2                	mov    %eax,%edx
  801fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb8:	e8 21 fd ff ff       	call   801cde <_pipeisclosed>
  801fbd:	83 c4 10             	add    $0x10,%esp
}
  801fc0:	c9                   	leave  
  801fc1:	c3                   	ret    

00801fc2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    

00801fcc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fd2:	68 27 2a 80 00       	push   $0x802a27
  801fd7:	ff 75 0c             	pushl  0xc(%ebp)
  801fda:	e8 9e e7 ff ff       	call   80077d <strcpy>
	return 0;
}
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	57                   	push   %edi
  801fea:	56                   	push   %esi
  801feb:	53                   	push   %ebx
  801fec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ff7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ffd:	eb 2d                	jmp    80202c <devcons_write+0x46>
		m = n - tot;
  801fff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802002:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802004:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802007:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80200c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80200f:	83 ec 04             	sub    $0x4,%esp
  802012:	53                   	push   %ebx
  802013:	03 45 0c             	add    0xc(%ebp),%eax
  802016:	50                   	push   %eax
  802017:	57                   	push   %edi
  802018:	e8 f2 e8 ff ff       	call   80090f <memmove>
		sys_cputs(buf, m);
  80201d:	83 c4 08             	add    $0x8,%esp
  802020:	53                   	push   %ebx
  802021:	57                   	push   %edi
  802022:	e8 9d ea ff ff       	call   800ac4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802027:	01 de                	add    %ebx,%esi
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	89 f0                	mov    %esi,%eax
  80202e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802031:	72 cc                	jb     801fff <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802033:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802036:	5b                   	pop    %ebx
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    

0080203b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	83 ec 08             	sub    $0x8,%esp
  802041:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802046:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80204a:	74 2a                	je     802076 <devcons_read+0x3b>
  80204c:	eb 05                	jmp    802053 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80204e:	e8 0e eb ff ff       	call   800b61 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802053:	e8 8a ea ff ff       	call   800ae2 <sys_cgetc>
  802058:	85 c0                	test   %eax,%eax
  80205a:	74 f2                	je     80204e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80205c:	85 c0                	test   %eax,%eax
  80205e:	78 16                	js     802076 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802060:	83 f8 04             	cmp    $0x4,%eax
  802063:	74 0c                	je     802071 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802065:	8b 55 0c             	mov    0xc(%ebp),%edx
  802068:	88 02                	mov    %al,(%edx)
	return 1;
  80206a:	b8 01 00 00 00       	mov    $0x1,%eax
  80206f:	eb 05                	jmp    802076 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802071:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802076:	c9                   	leave  
  802077:	c3                   	ret    

00802078 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80207e:	8b 45 08             	mov    0x8(%ebp),%eax
  802081:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802084:	6a 01                	push   $0x1
  802086:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802089:	50                   	push   %eax
  80208a:	e8 35 ea ff ff       	call   800ac4 <sys_cputs>
}
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	c9                   	leave  
  802093:	c3                   	ret    

00802094 <getchar>:

int
getchar(void)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80209a:	6a 01                	push   $0x1
  80209c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209f:	50                   	push   %eax
  8020a0:	6a 00                	push   $0x0
  8020a2:	e8 19 f1 ff ff       	call   8011c0 <read>
	if (r < 0)
  8020a7:	83 c4 10             	add    $0x10,%esp
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	78 0f                	js     8020bd <getchar+0x29>
		return r;
	if (r < 1)
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	7e 06                	jle    8020b8 <getchar+0x24>
		return -E_EOF;
	return c;
  8020b2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020b6:	eb 05                	jmp    8020bd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020b8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    

008020bf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c8:	50                   	push   %eax
  8020c9:	ff 75 08             	pushl  0x8(%ebp)
  8020cc:	e8 89 ee ff ff       	call   800f5a <fd_lookup>
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	78 11                	js     8020e9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020db:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020e1:	39 10                	cmp    %edx,(%eax)
  8020e3:	0f 94 c0             	sete   %al
  8020e6:	0f b6 c0             	movzbl %al,%eax
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <opencons>:

int
opencons(void)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f4:	50                   	push   %eax
  8020f5:	e8 11 ee ff ff       	call   800f0b <fd_alloc>
  8020fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8020fd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ff:	85 c0                	test   %eax,%eax
  802101:	78 3e                	js     802141 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802103:	83 ec 04             	sub    $0x4,%esp
  802106:	68 07 04 00 00       	push   $0x407
  80210b:	ff 75 f4             	pushl  -0xc(%ebp)
  80210e:	6a 00                	push   $0x0
  802110:	e8 6b ea ff ff       	call   800b80 <sys_page_alloc>
  802115:	83 c4 10             	add    $0x10,%esp
		return r;
  802118:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80211a:	85 c0                	test   %eax,%eax
  80211c:	78 23                	js     802141 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80211e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802124:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802127:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802133:	83 ec 0c             	sub    $0xc,%esp
  802136:	50                   	push   %eax
  802137:	e8 a8 ed ff ff       	call   800ee4 <fd2num>
  80213c:	89 c2                	mov    %eax,%edx
  80213e:	83 c4 10             	add    $0x10,%esp
}
  802141:	89 d0                	mov    %edx,%eax
  802143:	c9                   	leave  
  802144:	c3                   	ret    

00802145 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	56                   	push   %esi
  802149:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80214a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80214d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802153:	e8 ea e9 ff ff       	call   800b42 <sys_getenvid>
  802158:	83 ec 0c             	sub    $0xc,%esp
  80215b:	ff 75 0c             	pushl  0xc(%ebp)
  80215e:	ff 75 08             	pushl  0x8(%ebp)
  802161:	56                   	push   %esi
  802162:	50                   	push   %eax
  802163:	68 34 2a 80 00       	push   $0x802a34
  802168:	e8 8b e0 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80216d:	83 c4 18             	add    $0x18,%esp
  802170:	53                   	push   %ebx
  802171:	ff 75 10             	pushl  0x10(%ebp)
  802174:	e8 2e e0 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  802179:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  802180:	e8 73 e0 ff ff       	call   8001f8 <cprintf>
  802185:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802188:	cc                   	int3   
  802189:	eb fd                	jmp    802188 <_panic+0x43>

0080218b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	56                   	push   %esi
  80218f:	53                   	push   %ebx
  802190:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802193:	8b 45 0c             	mov    0xc(%ebp),%eax
  802196:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  802199:	85 c0                	test   %eax,%eax
  80219b:	74 0e                	je     8021ab <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  80219d:	83 ec 0c             	sub    $0xc,%esp
  8021a0:	50                   	push   %eax
  8021a1:	e8 8a eb ff ff       	call   800d30 <sys_ipc_recv>
  8021a6:	83 c4 10             	add    $0x10,%esp
  8021a9:	eb 10                	jmp    8021bb <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  8021ab:	83 ec 0c             	sub    $0xc,%esp
  8021ae:	68 00 00 00 f0       	push   $0xf0000000
  8021b3:	e8 78 eb ff ff       	call   800d30 <sys_ipc_recv>
  8021b8:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  8021bb:	85 c0                	test   %eax,%eax
  8021bd:	74 16                	je     8021d5 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  8021bf:	85 db                	test   %ebx,%ebx
  8021c1:	74 36                	je     8021f9 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  8021c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  8021c9:	85 f6                	test   %esi,%esi
  8021cb:	74 2c                	je     8021f9 <ipc_recv+0x6e>
				*perm_store = 0;
  8021cd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8021d3:	eb 24                	jmp    8021f9 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  8021d5:	85 db                	test   %ebx,%ebx
  8021d7:	74 18                	je     8021f1 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  8021d9:	a1 08 40 80 00       	mov    0x804008,%eax
  8021de:	8b 40 74             	mov    0x74(%eax),%eax
  8021e1:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  8021e3:	85 f6                	test   %esi,%esi
  8021e5:	74 0a                	je     8021f1 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  8021e7:	a1 08 40 80 00       	mov    0x804008,%eax
  8021ec:	8b 40 78             	mov    0x78(%eax),%eax
  8021ef:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  8021f1:	a1 08 40 80 00       	mov    0x804008,%eax
  8021f6:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  8021f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fc:	5b                   	pop    %ebx
  8021fd:	5e                   	pop    %esi
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	57                   	push   %edi
  802204:	56                   	push   %esi
  802205:	53                   	push   %ebx
  802206:	83 ec 0c             	sub    $0xc,%esp
  802209:	8b 7d 08             	mov    0x8(%ebp),%edi
  80220c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  80220f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802213:	75 39                	jne    80224e <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  802215:	6a 00                	push   $0x0
  802217:	68 00 00 00 f0       	push   $0xf0000000
  80221c:	56                   	push   %esi
  80221d:	57                   	push   %edi
  80221e:	e8 ea ea ff ff       	call   800d0d <sys_ipc_try_send>
  802223:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  802225:	83 c4 10             	add    $0x10,%esp
  802228:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80222b:	74 16                	je     802243 <ipc_send+0x43>
  80222d:	85 c0                	test   %eax,%eax
  80222f:	74 12                	je     802243 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802231:	50                   	push   %eax
  802232:	68 58 2a 80 00       	push   $0x802a58
  802237:	6a 4f                	push   $0x4f
  802239:	68 90 2a 80 00       	push   $0x802a90
  80223e:	e8 02 ff ff ff       	call   802145 <_panic>
			sys_yield();
  802243:	e8 19 e9 ff ff       	call   800b61 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  802248:	85 db                	test   %ebx,%ebx
  80224a:	75 c9                	jne    802215 <ipc_send+0x15>
  80224c:	eb 36                	jmp    802284 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  80224e:	ff 75 14             	pushl  0x14(%ebp)
  802251:	ff 75 10             	pushl  0x10(%ebp)
  802254:	56                   	push   %esi
  802255:	57                   	push   %edi
  802256:	e8 b2 ea ff ff       	call   800d0d <sys_ipc_try_send>
  80225b:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  80225d:	83 c4 10             	add    $0x10,%esp
  802260:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802263:	74 16                	je     80227b <ipc_send+0x7b>
  802265:	85 c0                	test   %eax,%eax
  802267:	74 12                	je     80227b <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802269:	50                   	push   %eax
  80226a:	68 58 2a 80 00       	push   $0x802a58
  80226f:	6a 5a                	push   $0x5a
  802271:	68 90 2a 80 00       	push   $0x802a90
  802276:	e8 ca fe ff ff       	call   802145 <_panic>
			sys_yield();
  80227b:	e8 e1 e8 ff ff       	call   800b61 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  802280:	85 db                	test   %ebx,%ebx
  802282:	75 ca                	jne    80224e <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  802284:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802287:	5b                   	pop    %ebx
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    

0080228c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802292:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802297:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80229a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022a0:	8b 52 50             	mov    0x50(%edx),%edx
  8022a3:	39 ca                	cmp    %ecx,%edx
  8022a5:	75 0d                	jne    8022b4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8022a7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022aa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022af:	8b 40 48             	mov    0x48(%eax),%eax
  8022b2:	eb 0f                	jmp    8022c3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022b4:	83 c0 01             	add    $0x1,%eax
  8022b7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022bc:	75 d9                	jne    802297 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    

008022c5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	c1 e8 16             	shr    $0x16,%eax
  8022d0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022d7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022dc:	f6 c1 01             	test   $0x1,%cl
  8022df:	74 1d                	je     8022fe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022e1:	c1 ea 0c             	shr    $0xc,%edx
  8022e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022eb:	f6 c2 01             	test   $0x1,%dl
  8022ee:	74 0e                	je     8022fe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022f0:	c1 ea 0c             	shr    $0xc,%edx
  8022f3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022fa:	ef 
  8022fb:	0f b7 c0             	movzwl %ax,%eax
}
  8022fe:	5d                   	pop    %ebp
  8022ff:	c3                   	ret    

00802300 <__udivdi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80230b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80230f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 f6                	test   %esi,%esi
  802319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231d:	89 ca                	mov    %ecx,%edx
  80231f:	89 f8                	mov    %edi,%eax
  802321:	75 3d                	jne    802360 <__udivdi3+0x60>
  802323:	39 cf                	cmp    %ecx,%edi
  802325:	0f 87 c5 00 00 00    	ja     8023f0 <__udivdi3+0xf0>
  80232b:	85 ff                	test   %edi,%edi
  80232d:	89 fd                	mov    %edi,%ebp
  80232f:	75 0b                	jne    80233c <__udivdi3+0x3c>
  802331:	b8 01 00 00 00       	mov    $0x1,%eax
  802336:	31 d2                	xor    %edx,%edx
  802338:	f7 f7                	div    %edi
  80233a:	89 c5                	mov    %eax,%ebp
  80233c:	89 c8                	mov    %ecx,%eax
  80233e:	31 d2                	xor    %edx,%edx
  802340:	f7 f5                	div    %ebp
  802342:	89 c1                	mov    %eax,%ecx
  802344:	89 d8                	mov    %ebx,%eax
  802346:	89 cf                	mov    %ecx,%edi
  802348:	f7 f5                	div    %ebp
  80234a:	89 c3                	mov    %eax,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	39 ce                	cmp    %ecx,%esi
  802362:	77 74                	ja     8023d8 <__udivdi3+0xd8>
  802364:	0f bd fe             	bsr    %esi,%edi
  802367:	83 f7 1f             	xor    $0x1f,%edi
  80236a:	0f 84 98 00 00 00    	je     802408 <__udivdi3+0x108>
  802370:	bb 20 00 00 00       	mov    $0x20,%ebx
  802375:	89 f9                	mov    %edi,%ecx
  802377:	89 c5                	mov    %eax,%ebp
  802379:	29 fb                	sub    %edi,%ebx
  80237b:	d3 e6                	shl    %cl,%esi
  80237d:	89 d9                	mov    %ebx,%ecx
  80237f:	d3 ed                	shr    %cl,%ebp
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e0                	shl    %cl,%eax
  802385:	09 ee                	or     %ebp,%esi
  802387:	89 d9                	mov    %ebx,%ecx
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	89 d5                	mov    %edx,%ebp
  80238f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802393:	d3 ed                	shr    %cl,%ebp
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e2                	shl    %cl,%edx
  802399:	89 d9                	mov    %ebx,%ecx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	09 c2                	or     %eax,%edx
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	89 ea                	mov    %ebp,%edx
  8023a3:	f7 f6                	div    %esi
  8023a5:	89 d5                	mov    %edx,%ebp
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	72 10                	jb     8023c1 <__udivdi3+0xc1>
  8023b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	d3 e6                	shl    %cl,%esi
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	73 07                	jae    8023c4 <__udivdi3+0xc4>
  8023bd:	39 d5                	cmp    %edx,%ebp
  8023bf:	75 03                	jne    8023c4 <__udivdi3+0xc4>
  8023c1:	83 eb 01             	sub    $0x1,%ebx
  8023c4:	31 ff                	xor    %edi,%edi
  8023c6:	89 d8                	mov    %ebx,%eax
  8023c8:	89 fa                	mov    %edi,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 ff                	xor    %edi,%edi
  8023da:	31 db                	xor    %ebx,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 d8                	mov    %ebx,%eax
  8023f2:	f7 f7                	div    %edi
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 c3                	mov    %eax,%ebx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 fa                	mov    %edi,%edx
  8023fc:	83 c4 1c             	add    $0x1c,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	39 ce                	cmp    %ecx,%esi
  80240a:	72 0c                	jb     802418 <__udivdi3+0x118>
  80240c:	31 db                	xor    %ebx,%ebx
  80240e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802412:	0f 87 34 ff ff ff    	ja     80234c <__udivdi3+0x4c>
  802418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80241d:	e9 2a ff ff ff       	jmp    80234c <__udivdi3+0x4c>
  802422:	66 90                	xchg   %ax,%ax
  802424:	66 90                	xchg   %ax,%ax
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__umoddi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80243b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80243f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 d2                	test   %edx,%edx
  802449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f3                	mov    %esi,%ebx
  802453:	89 3c 24             	mov    %edi,(%esp)
  802456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245a:	75 1c                	jne    802478 <__umoddi3+0x48>
  80245c:	39 f7                	cmp    %esi,%edi
  80245e:	76 50                	jbe    8024b0 <__umoddi3+0x80>
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	f7 f7                	div    %edi
  802466:	89 d0                	mov    %edx,%eax
  802468:	31 d2                	xor    %edx,%edx
  80246a:	83 c4 1c             	add    $0x1c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	39 f2                	cmp    %esi,%edx
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	77 52                	ja     8024d0 <__umoddi3+0xa0>
  80247e:	0f bd ea             	bsr    %edx,%ebp
  802481:	83 f5 1f             	xor    $0x1f,%ebp
  802484:	75 5a                	jne    8024e0 <__umoddi3+0xb0>
  802486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80248a:	0f 82 e0 00 00 00    	jb     802570 <__umoddi3+0x140>
  802490:	39 0c 24             	cmp    %ecx,(%esp)
  802493:	0f 86 d7 00 00 00    	jbe    802570 <__umoddi3+0x140>
  802499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80249d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	85 ff                	test   %edi,%edi
  8024b2:	89 fd                	mov    %edi,%ebp
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x91>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f7                	div    %edi
  8024bf:	89 c5                	mov    %eax,%ebp
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f5                	div    %ebp
  8024c7:	89 c8                	mov    %ecx,%eax
  8024c9:	f7 f5                	div    %ebp
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	eb 99                	jmp    802468 <__umoddi3+0x38>
  8024cf:	90                   	nop
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	83 c4 1c             	add    $0x1c,%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
  8024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	8b 34 24             	mov    (%esp),%esi
  8024e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	29 ef                	sub    %ebp,%edi
  8024ec:	d3 e0                	shl    %cl,%eax
  8024ee:	89 f9                	mov    %edi,%ecx
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	d3 ea                	shr    %cl,%edx
  8024f4:	89 e9                	mov    %ebp,%ecx
  8024f6:	09 c2                	or     %eax,%edx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 14 24             	mov    %edx,(%esp)
  8024fd:	89 f2                	mov    %esi,%edx
  8024ff:	d3 e2                	shl    %cl,%edx
  802501:	89 f9                	mov    %edi,%ecx
  802503:	89 54 24 04          	mov    %edx,0x4(%esp)
  802507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	89 e9                	mov    %ebp,%ecx
  80250f:	89 c6                	mov    %eax,%esi
  802511:	d3 e3                	shl    %cl,%ebx
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 d0                	mov    %edx,%eax
  802517:	d3 e8                	shr    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	09 d8                	or     %ebx,%eax
  80251d:	89 d3                	mov    %edx,%ebx
  80251f:	89 f2                	mov    %esi,%edx
  802521:	f7 34 24             	divl   (%esp)
  802524:	89 d6                	mov    %edx,%esi
  802526:	d3 e3                	shl    %cl,%ebx
  802528:	f7 64 24 04          	mull   0x4(%esp)
  80252c:	39 d6                	cmp    %edx,%esi
  80252e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802532:	89 d1                	mov    %edx,%ecx
  802534:	89 c3                	mov    %eax,%ebx
  802536:	72 08                	jb     802540 <__umoddi3+0x110>
  802538:	75 11                	jne    80254b <__umoddi3+0x11b>
  80253a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80253e:	73 0b                	jae    80254b <__umoddi3+0x11b>
  802540:	2b 44 24 04          	sub    0x4(%esp),%eax
  802544:	1b 14 24             	sbb    (%esp),%edx
  802547:	89 d1                	mov    %edx,%ecx
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80254f:	29 da                	sub    %ebx,%edx
  802551:	19 ce                	sbb    %ecx,%esi
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 f0                	mov    %esi,%eax
  802557:	d3 e0                	shl    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	d3 ea                	shr    %cl,%edx
  80255d:	89 e9                	mov    %ebp,%ecx
  80255f:	d3 ee                	shr    %cl,%esi
  802561:	09 d0                	or     %edx,%eax
  802563:	89 f2                	mov    %esi,%edx
  802565:	83 c4 1c             	add    $0x1c,%esp
  802568:	5b                   	pop    %ebx
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
  802570:	29 f9                	sub    %edi,%ecx
  802572:	19 d6                	sbb    %edx,%esi
  802574:	89 74 24 04          	mov    %esi,0x4(%esp)
  802578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257c:	e9 18 ff ff ff       	jmp    802499 <__umoddi3+0x69>
