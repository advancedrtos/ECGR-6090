
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
  800039:	68 e0 20 80 00       	push   $0x8020e0
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
  800067:	e8 05 0d 00 00       	call   800d71 <argstart>
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
  800091:	e8 0b 0d 00 00       	call   800da1 <argnext>
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
  8000ad:	e8 07 13 00 00       	call   8013b9 <fstat>
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
  8000ce:	68 f4 20 80 00       	push   $0x8020f4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 ad 16 00 00       	call   801787 <fprintf>
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
  8000f0:	68 f4 20 80 00       	push   $0x8020f4
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
  80012a:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80025b:	e8 f0 1b 00 00       	call   801e50 <__udivdi3>
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
  80029e:	e8 dd 1c 00 00       	call   801f80 <__umoddi3>
  8002a3:	83 c4 14             	add    $0x14,%esp
  8002a6:	0f be 80 26 21 80 00 	movsbl 0x802126(%eax),%eax
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
  8003a2:	ff 24 85 60 22 80 00 	jmp    *0x802260(,%eax,4)
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
  800466:	8b 14 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%edx
  80046d:	85 d2                	test   %edx,%edx
  80046f:	75 18                	jne    800489 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800471:	50                   	push   %eax
  800472:	68 3e 21 80 00       	push   $0x80213e
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
  80048a:	68 1a 25 80 00       	push   $0x80251a
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
  8004ae:	b8 37 21 80 00       	mov    $0x802137,%eax
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
  800b29:	68 1f 24 80 00       	push   $0x80241f
  800b2e:	6a 23                	push   $0x23
  800b30:	68 3c 24 80 00       	push   $0x80243c
  800b35:	e8 59 11 00 00       	call   801c93 <_panic>

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
  800baa:	68 1f 24 80 00       	push   $0x80241f
  800baf:	6a 23                	push   $0x23
  800bb1:	68 3c 24 80 00       	push   $0x80243c
  800bb6:	e8 d8 10 00 00       	call   801c93 <_panic>

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
  800bec:	68 1f 24 80 00       	push   $0x80241f
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 3c 24 80 00       	push   $0x80243c
  800bf8:	e8 96 10 00 00       	call   801c93 <_panic>

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
  800c2e:	68 1f 24 80 00       	push   $0x80241f
  800c33:	6a 23                	push   $0x23
  800c35:	68 3c 24 80 00       	push   $0x80243c
  800c3a:	e8 54 10 00 00       	call   801c93 <_panic>

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
  800c70:	68 1f 24 80 00       	push   $0x80241f
  800c75:	6a 23                	push   $0x23
  800c77:	68 3c 24 80 00       	push   $0x80243c
  800c7c:	e8 12 10 00 00       	call   801c93 <_panic>

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
  800cb2:	68 1f 24 80 00       	push   $0x80241f
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 3c 24 80 00       	push   $0x80243c
  800cbe:	e8 d0 0f 00 00       	call   801c93 <_panic>

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
  800cf4:	68 1f 24 80 00       	push   $0x80241f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 3c 24 80 00       	push   $0x80243c
  800d00:	e8 8e 0f 00 00       	call   801c93 <_panic>

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
  800d58:	68 1f 24 80 00       	push   $0x80241f
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 3c 24 80 00       	push   $0x80243c
  800d64:	e8 2a 0f 00 00       	call   801c93 <_panic>

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

00800d71 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800d7d:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800d7f:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800d82:	83 3a 01             	cmpl   $0x1,(%edx)
  800d85:	7e 09                	jle    800d90 <argstart+0x1f>
  800d87:	ba f1 20 80 00       	mov    $0x8020f1,%edx
  800d8c:	85 c9                	test   %ecx,%ecx
  800d8e:	75 05                	jne    800d95 <argstart+0x24>
  800d90:	ba 00 00 00 00       	mov    $0x0,%edx
  800d95:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800d98:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <argnext>:

int
argnext(struct Argstate *args)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	53                   	push   %ebx
  800da5:	83 ec 04             	sub    $0x4,%esp
  800da8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800dab:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800db2:	8b 43 08             	mov    0x8(%ebx),%eax
  800db5:	85 c0                	test   %eax,%eax
  800db7:	74 6f                	je     800e28 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800db9:	80 38 00             	cmpb   $0x0,(%eax)
  800dbc:	75 4e                	jne    800e0c <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800dbe:	8b 0b                	mov    (%ebx),%ecx
  800dc0:	83 39 01             	cmpl   $0x1,(%ecx)
  800dc3:	74 55                	je     800e1a <argnext+0x79>
		    || args->argv[1][0] != '-'
  800dc5:	8b 53 04             	mov    0x4(%ebx),%edx
  800dc8:	8b 42 04             	mov    0x4(%edx),%eax
  800dcb:	80 38 2d             	cmpb   $0x2d,(%eax)
  800dce:	75 4a                	jne    800e1a <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800dd0:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800dd4:	74 44                	je     800e1a <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800dd6:	83 c0 01             	add    $0x1,%eax
  800dd9:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	8b 01                	mov    (%ecx),%eax
  800de1:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800de8:	50                   	push   %eax
  800de9:	8d 42 08             	lea    0x8(%edx),%eax
  800dec:	50                   	push   %eax
  800ded:	83 c2 04             	add    $0x4,%edx
  800df0:	52                   	push   %edx
  800df1:	e8 19 fb ff ff       	call   80090f <memmove>
		(*args->argc)--;
  800df6:	8b 03                	mov    (%ebx),%eax
  800df8:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800dfb:	8b 43 08             	mov    0x8(%ebx),%eax
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e04:	75 06                	jne    800e0c <argnext+0x6b>
  800e06:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e0a:	74 0e                	je     800e1a <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e0c:	8b 53 08             	mov    0x8(%ebx),%edx
  800e0f:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e12:	83 c2 01             	add    $0x1,%edx
  800e15:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e18:	eb 13                	jmp    800e2d <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e1a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e26:	eb 05                	jmp    800e2d <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    

00800e32 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	53                   	push   %ebx
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e3c:	8b 43 08             	mov    0x8(%ebx),%eax
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	74 58                	je     800e9b <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e43:	80 38 00             	cmpb   $0x0,(%eax)
  800e46:	74 0c                	je     800e54 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e48:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e4b:	c7 43 08 f1 20 80 00 	movl   $0x8020f1,0x8(%ebx)
  800e52:	eb 42                	jmp    800e96 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800e54:	8b 13                	mov    (%ebx),%edx
  800e56:	83 3a 01             	cmpl   $0x1,(%edx)
  800e59:	7e 2d                	jle    800e88 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800e5b:	8b 43 04             	mov    0x4(%ebx),%eax
  800e5e:	8b 48 04             	mov    0x4(%eax),%ecx
  800e61:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	8b 12                	mov    (%edx),%edx
  800e69:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800e70:	52                   	push   %edx
  800e71:	8d 50 08             	lea    0x8(%eax),%edx
  800e74:	52                   	push   %edx
  800e75:	83 c0 04             	add    $0x4,%eax
  800e78:	50                   	push   %eax
  800e79:	e8 91 fa ff ff       	call   80090f <memmove>
		(*args->argc)--;
  800e7e:	8b 03                	mov    (%ebx),%eax
  800e80:	83 28 01             	subl   $0x1,(%eax)
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	eb 0e                	jmp    800e96 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800e88:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800e8f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800e96:	8b 43 0c             	mov    0xc(%ebx),%eax
  800e99:	eb 05                	jmp    800ea0 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ea0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800eae:	8b 51 0c             	mov    0xc(%ecx),%edx
  800eb1:	89 d0                	mov    %edx,%eax
  800eb3:	85 d2                	test   %edx,%edx
  800eb5:	75 0c                	jne    800ec3 <argvalue+0x1e>
  800eb7:	83 ec 0c             	sub    $0xc,%esp
  800eba:	51                   	push   %ecx
  800ebb:	e8 72 ff ff ff       	call   800e32 <argnextvalue>
  800ec0:	83 c4 10             	add    $0x10,%esp
}
  800ec3:	c9                   	leave  
  800ec4:	c3                   	ret    

00800ec5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed0:	c1 e8 0c             	shr    $0xc,%eax
}
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  800edb:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ef7:	89 c2                	mov    %eax,%edx
  800ef9:	c1 ea 16             	shr    $0x16,%edx
  800efc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f03:	f6 c2 01             	test   $0x1,%dl
  800f06:	74 11                	je     800f19 <fd_alloc+0x2d>
  800f08:	89 c2                	mov    %eax,%edx
  800f0a:	c1 ea 0c             	shr    $0xc,%edx
  800f0d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f14:	f6 c2 01             	test   $0x1,%dl
  800f17:	75 09                	jne    800f22 <fd_alloc+0x36>
			*fd_store = fd;
  800f19:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f20:	eb 17                	jmp    800f39 <fd_alloc+0x4d>
  800f22:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f27:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f2c:	75 c9                	jne    800ef7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f2e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f34:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f41:	83 f8 1f             	cmp    $0x1f,%eax
  800f44:	77 36                	ja     800f7c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f46:	c1 e0 0c             	shl    $0xc,%eax
  800f49:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f4e:	89 c2                	mov    %eax,%edx
  800f50:	c1 ea 16             	shr    $0x16,%edx
  800f53:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f5a:	f6 c2 01             	test   $0x1,%dl
  800f5d:	74 24                	je     800f83 <fd_lookup+0x48>
  800f5f:	89 c2                	mov    %eax,%edx
  800f61:	c1 ea 0c             	shr    $0xc,%edx
  800f64:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6b:	f6 c2 01             	test   $0x1,%dl
  800f6e:	74 1a                	je     800f8a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f73:	89 02                	mov    %eax,(%edx)
	return 0;
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7a:	eb 13                	jmp    800f8f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f81:	eb 0c                	jmp    800f8f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f88:	eb 05                	jmp    800f8f <fd_lookup+0x54>
  800f8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	83 ec 08             	sub    $0x8,%esp
  800f97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9a:	ba c8 24 80 00       	mov    $0x8024c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f9f:	eb 13                	jmp    800fb4 <dev_lookup+0x23>
  800fa1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fa4:	39 08                	cmp    %ecx,(%eax)
  800fa6:	75 0c                	jne    800fb4 <dev_lookup+0x23>
			*dev = devtab[i];
  800fa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fab:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb2:	eb 2e                	jmp    800fe2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fb4:	8b 02                	mov    (%edx),%eax
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	75 e7                	jne    800fa1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fba:	a1 04 40 80 00       	mov    0x804004,%eax
  800fbf:	8b 40 48             	mov    0x48(%eax),%eax
  800fc2:	83 ec 04             	sub    $0x4,%esp
  800fc5:	51                   	push   %ecx
  800fc6:	50                   	push   %eax
  800fc7:	68 4c 24 80 00       	push   $0x80244c
  800fcc:	e8 27 f2 ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  800fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 10             	sub    $0x10,%esp
  800fec:	8b 75 08             	mov    0x8(%ebp),%esi
  800fef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff5:	50                   	push   %eax
  800ff6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ffc:	c1 e8 0c             	shr    $0xc,%eax
  800fff:	50                   	push   %eax
  801000:	e8 36 ff ff ff       	call   800f3b <fd_lookup>
  801005:	83 c4 08             	add    $0x8,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 05                	js     801011 <fd_close+0x2d>
	    || fd != fd2)
  80100c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80100f:	74 0c                	je     80101d <fd_close+0x39>
		return (must_exist ? r : 0);
  801011:	84 db                	test   %bl,%bl
  801013:	ba 00 00 00 00       	mov    $0x0,%edx
  801018:	0f 44 c2             	cmove  %edx,%eax
  80101b:	eb 41                	jmp    80105e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80101d:	83 ec 08             	sub    $0x8,%esp
  801020:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801023:	50                   	push   %eax
  801024:	ff 36                	pushl  (%esi)
  801026:	e8 66 ff ff ff       	call   800f91 <dev_lookup>
  80102b:	89 c3                	mov    %eax,%ebx
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	78 1a                	js     80104e <fd_close+0x6a>
		if (dev->dev_close)
  801034:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801037:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80103a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80103f:	85 c0                	test   %eax,%eax
  801041:	74 0b                	je     80104e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	56                   	push   %esi
  801047:	ff d0                	call   *%eax
  801049:	89 c3                	mov    %eax,%ebx
  80104b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	56                   	push   %esi
  801052:	6a 00                	push   $0x0
  801054:	e8 ac fb ff ff       	call   800c05 <sys_page_unmap>
	return r;
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	89 d8                	mov    %ebx,%eax
}
  80105e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80106b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106e:	50                   	push   %eax
  80106f:	ff 75 08             	pushl  0x8(%ebp)
  801072:	e8 c4 fe ff ff       	call   800f3b <fd_lookup>
  801077:	83 c4 08             	add    $0x8,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 10                	js     80108e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80107e:	83 ec 08             	sub    $0x8,%esp
  801081:	6a 01                	push   $0x1
  801083:	ff 75 f4             	pushl  -0xc(%ebp)
  801086:	e8 59 ff ff ff       	call   800fe4 <fd_close>
  80108b:	83 c4 10             	add    $0x10,%esp
}
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <close_all>:

void
close_all(void)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	53                   	push   %ebx
  801094:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801097:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	53                   	push   %ebx
  8010a0:	e8 c0 ff ff ff       	call   801065 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a5:	83 c3 01             	add    $0x1,%ebx
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	83 fb 20             	cmp    $0x20,%ebx
  8010ae:	75 ec                	jne    80109c <close_all+0xc>
		close(i);
}
  8010b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b3:	c9                   	leave  
  8010b4:	c3                   	ret    

008010b5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	57                   	push   %edi
  8010b9:	56                   	push   %esi
  8010ba:	53                   	push   %ebx
  8010bb:	83 ec 2c             	sub    $0x2c,%esp
  8010be:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010c1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010c4:	50                   	push   %eax
  8010c5:	ff 75 08             	pushl  0x8(%ebp)
  8010c8:	e8 6e fe ff ff       	call   800f3b <fd_lookup>
  8010cd:	83 c4 08             	add    $0x8,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	0f 88 c1 00 00 00    	js     801199 <dup+0xe4>
		return r;
	close(newfdnum);
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	56                   	push   %esi
  8010dc:	e8 84 ff ff ff       	call   801065 <close>

	newfd = INDEX2FD(newfdnum);
  8010e1:	89 f3                	mov    %esi,%ebx
  8010e3:	c1 e3 0c             	shl    $0xc,%ebx
  8010e6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010ec:	83 c4 04             	add    $0x4,%esp
  8010ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f2:	e8 de fd ff ff       	call   800ed5 <fd2data>
  8010f7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010f9:	89 1c 24             	mov    %ebx,(%esp)
  8010fc:	e8 d4 fd ff ff       	call   800ed5 <fd2data>
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801107:	89 f8                	mov    %edi,%eax
  801109:	c1 e8 16             	shr    $0x16,%eax
  80110c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801113:	a8 01                	test   $0x1,%al
  801115:	74 37                	je     80114e <dup+0x99>
  801117:	89 f8                	mov    %edi,%eax
  801119:	c1 e8 0c             	shr    $0xc,%eax
  80111c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801123:	f6 c2 01             	test   $0x1,%dl
  801126:	74 26                	je     80114e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801128:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	25 07 0e 00 00       	and    $0xe07,%eax
  801137:	50                   	push   %eax
  801138:	ff 75 d4             	pushl  -0x2c(%ebp)
  80113b:	6a 00                	push   $0x0
  80113d:	57                   	push   %edi
  80113e:	6a 00                	push   $0x0
  801140:	e8 7e fa ff ff       	call   800bc3 <sys_page_map>
  801145:	89 c7                	mov    %eax,%edi
  801147:	83 c4 20             	add    $0x20,%esp
  80114a:	85 c0                	test   %eax,%eax
  80114c:	78 2e                	js     80117c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801151:	89 d0                	mov    %edx,%eax
  801153:	c1 e8 0c             	shr    $0xc,%eax
  801156:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	25 07 0e 00 00       	and    $0xe07,%eax
  801165:	50                   	push   %eax
  801166:	53                   	push   %ebx
  801167:	6a 00                	push   $0x0
  801169:	52                   	push   %edx
  80116a:	6a 00                	push   $0x0
  80116c:	e8 52 fa ff ff       	call   800bc3 <sys_page_map>
  801171:	89 c7                	mov    %eax,%edi
  801173:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801176:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801178:	85 ff                	test   %edi,%edi
  80117a:	79 1d                	jns    801199 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80117c:	83 ec 08             	sub    $0x8,%esp
  80117f:	53                   	push   %ebx
  801180:	6a 00                	push   $0x0
  801182:	e8 7e fa ff ff       	call   800c05 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801187:	83 c4 08             	add    $0x8,%esp
  80118a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80118d:	6a 00                	push   $0x0
  80118f:	e8 71 fa ff ff       	call   800c05 <sys_page_unmap>
	return r;
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	89 f8                	mov    %edi,%eax
}
  801199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 14             	sub    $0x14,%esp
  8011a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ae:	50                   	push   %eax
  8011af:	53                   	push   %ebx
  8011b0:	e8 86 fd ff ff       	call   800f3b <fd_lookup>
  8011b5:	83 c4 08             	add    $0x8,%esp
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 6d                	js     80122b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c4:	50                   	push   %eax
  8011c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c8:	ff 30                	pushl  (%eax)
  8011ca:	e8 c2 fd ff ff       	call   800f91 <dev_lookup>
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 4c                	js     801222 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011d9:	8b 42 08             	mov    0x8(%edx),%eax
  8011dc:	83 e0 03             	and    $0x3,%eax
  8011df:	83 f8 01             	cmp    $0x1,%eax
  8011e2:	75 21                	jne    801205 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e9:	8b 40 48             	mov    0x48(%eax),%eax
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	53                   	push   %ebx
  8011f0:	50                   	push   %eax
  8011f1:	68 8d 24 80 00       	push   $0x80248d
  8011f6:	e8 fd ef ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801203:	eb 26                	jmp    80122b <read+0x8a>
	}
	if (!dev->dev_read)
  801205:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801208:	8b 40 08             	mov    0x8(%eax),%eax
  80120b:	85 c0                	test   %eax,%eax
  80120d:	74 17                	je     801226 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	ff 75 10             	pushl  0x10(%ebp)
  801215:	ff 75 0c             	pushl  0xc(%ebp)
  801218:	52                   	push   %edx
  801219:	ff d0                	call   *%eax
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	eb 09                	jmp    80122b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801222:	89 c2                	mov    %eax,%edx
  801224:	eb 05                	jmp    80122b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801226:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80122b:	89 d0                	mov    %edx,%eax
  80122d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	57                   	push   %edi
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	83 ec 0c             	sub    $0xc,%esp
  80123b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801241:	bb 00 00 00 00       	mov    $0x0,%ebx
  801246:	eb 21                	jmp    801269 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	89 f0                	mov    %esi,%eax
  80124d:	29 d8                	sub    %ebx,%eax
  80124f:	50                   	push   %eax
  801250:	89 d8                	mov    %ebx,%eax
  801252:	03 45 0c             	add    0xc(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	57                   	push   %edi
  801257:	e8 45 ff ff ff       	call   8011a1 <read>
		if (m < 0)
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 10                	js     801273 <readn+0x41>
			return m;
		if (m == 0)
  801263:	85 c0                	test   %eax,%eax
  801265:	74 0a                	je     801271 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801267:	01 c3                	add    %eax,%ebx
  801269:	39 f3                	cmp    %esi,%ebx
  80126b:	72 db                	jb     801248 <readn+0x16>
  80126d:	89 d8                	mov    %ebx,%eax
  80126f:	eb 02                	jmp    801273 <readn+0x41>
  801271:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801276:	5b                   	pop    %ebx
  801277:	5e                   	pop    %esi
  801278:	5f                   	pop    %edi
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	83 ec 14             	sub    $0x14,%esp
  801282:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801285:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801288:	50                   	push   %eax
  801289:	53                   	push   %ebx
  80128a:	e8 ac fc ff ff       	call   800f3b <fd_lookup>
  80128f:	83 c4 08             	add    $0x8,%esp
  801292:	89 c2                	mov    %eax,%edx
  801294:	85 c0                	test   %eax,%eax
  801296:	78 68                	js     801300 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129e:	50                   	push   %eax
  80129f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a2:	ff 30                	pushl  (%eax)
  8012a4:	e8 e8 fc ff ff       	call   800f91 <dev_lookup>
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 47                	js     8012f7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b7:	75 21                	jne    8012da <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012be:	8b 40 48             	mov    0x48(%eax),%eax
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	53                   	push   %ebx
  8012c5:	50                   	push   %eax
  8012c6:	68 a9 24 80 00       	push   $0x8024a9
  8012cb:	e8 28 ef ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d8:	eb 26                	jmp    801300 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8012e0:	85 d2                	test   %edx,%edx
  8012e2:	74 17                	je     8012fb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012e4:	83 ec 04             	sub    $0x4,%esp
  8012e7:	ff 75 10             	pushl  0x10(%ebp)
  8012ea:	ff 75 0c             	pushl  0xc(%ebp)
  8012ed:	50                   	push   %eax
  8012ee:	ff d2                	call   *%edx
  8012f0:	89 c2                	mov    %eax,%edx
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	eb 09                	jmp    801300 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	eb 05                	jmp    801300 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801300:	89 d0                	mov    %edx,%eax
  801302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801305:	c9                   	leave  
  801306:	c3                   	ret    

00801307 <seek>:

int
seek(int fdnum, off_t offset)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	ff 75 08             	pushl  0x8(%ebp)
  801314:	e8 22 fc ff ff       	call   800f3b <fd_lookup>
  801319:	83 c4 08             	add    $0x8,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 0e                	js     80132e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801320:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801323:	8b 55 0c             	mov    0xc(%ebp),%edx
  801326:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80132e:	c9                   	leave  
  80132f:	c3                   	ret    

00801330 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	53                   	push   %ebx
  801334:	83 ec 14             	sub    $0x14,%esp
  801337:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	53                   	push   %ebx
  80133f:	e8 f7 fb ff ff       	call   800f3b <fd_lookup>
  801344:	83 c4 08             	add    $0x8,%esp
  801347:	89 c2                	mov    %eax,%edx
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 65                	js     8013b2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801357:	ff 30                	pushl  (%eax)
  801359:	e8 33 fc ff ff       	call   800f91 <dev_lookup>
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 44                	js     8013a9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801365:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801368:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80136c:	75 21                	jne    80138f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80136e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801373:	8b 40 48             	mov    0x48(%eax),%eax
  801376:	83 ec 04             	sub    $0x4,%esp
  801379:	53                   	push   %ebx
  80137a:	50                   	push   %eax
  80137b:	68 6c 24 80 00       	push   $0x80246c
  801380:	e8 73 ee ff ff       	call   8001f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80138d:	eb 23                	jmp    8013b2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80138f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801392:	8b 52 18             	mov    0x18(%edx),%edx
  801395:	85 d2                	test   %edx,%edx
  801397:	74 14                	je     8013ad <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	ff 75 0c             	pushl  0xc(%ebp)
  80139f:	50                   	push   %eax
  8013a0:	ff d2                	call   *%edx
  8013a2:	89 c2                	mov    %eax,%edx
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	eb 09                	jmp    8013b2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	eb 05                	jmp    8013b2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013b2:	89 d0                	mov    %edx,%eax
  8013b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b7:	c9                   	leave  
  8013b8:	c3                   	ret    

008013b9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 14             	sub    $0x14,%esp
  8013c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c6:	50                   	push   %eax
  8013c7:	ff 75 08             	pushl  0x8(%ebp)
  8013ca:	e8 6c fb ff ff       	call   800f3b <fd_lookup>
  8013cf:	83 c4 08             	add    $0x8,%esp
  8013d2:	89 c2                	mov    %eax,%edx
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	78 58                	js     801430 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013de:	50                   	push   %eax
  8013df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e2:	ff 30                	pushl  (%eax)
  8013e4:	e8 a8 fb ff ff       	call   800f91 <dev_lookup>
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 37                	js     801427 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013f7:	74 32                	je     80142b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013f9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013fc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801403:	00 00 00 
	stat->st_isdir = 0;
  801406:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80140d:	00 00 00 
	stat->st_dev = dev;
  801410:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801416:	83 ec 08             	sub    $0x8,%esp
  801419:	53                   	push   %ebx
  80141a:	ff 75 f0             	pushl  -0x10(%ebp)
  80141d:	ff 50 14             	call   *0x14(%eax)
  801420:	89 c2                	mov    %eax,%edx
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	eb 09                	jmp    801430 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801427:	89 c2                	mov    %eax,%edx
  801429:	eb 05                	jmp    801430 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80142b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801430:	89 d0                	mov    %edx,%eax
  801432:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	56                   	push   %esi
  80143b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80143c:	83 ec 08             	sub    $0x8,%esp
  80143f:	6a 00                	push   $0x0
  801441:	ff 75 08             	pushl  0x8(%ebp)
  801444:	e8 b7 01 00 00       	call   801600 <open>
  801449:	89 c3                	mov    %eax,%ebx
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 1b                	js     80146d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801452:	83 ec 08             	sub    $0x8,%esp
  801455:	ff 75 0c             	pushl  0xc(%ebp)
  801458:	50                   	push   %eax
  801459:	e8 5b ff ff ff       	call   8013b9 <fstat>
  80145e:	89 c6                	mov    %eax,%esi
	close(fd);
  801460:	89 1c 24             	mov    %ebx,(%esp)
  801463:	e8 fd fb ff ff       	call   801065 <close>
	return r;
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	89 f0                	mov    %esi,%eax
}
  80146d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801470:	5b                   	pop    %ebx
  801471:	5e                   	pop    %esi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	89 c6                	mov    %eax,%esi
  80147b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80147d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801484:	75 12                	jne    801498 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801486:	83 ec 0c             	sub    $0xc,%esp
  801489:	6a 01                	push   $0x1
  80148b:	e8 4a 09 00 00       	call   801dda <ipc_find_env>
  801490:	a3 00 40 80 00       	mov    %eax,0x804000
  801495:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801498:	6a 07                	push   $0x7
  80149a:	68 00 50 80 00       	push   $0x805000
  80149f:	56                   	push   %esi
  8014a0:	ff 35 00 40 80 00    	pushl  0x804000
  8014a6:	e8 a3 08 00 00       	call   801d4e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014ab:	83 c4 0c             	add    $0xc,%esp
  8014ae:	6a 00                	push   $0x0
  8014b0:	53                   	push   %ebx
  8014b1:	6a 00                	push   $0x0
  8014b3:	e8 21 08 00 00       	call   801cd9 <ipc_recv>
}
  8014b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5e                   	pop    %esi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    

008014bf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014dd:	b8 02 00 00 00       	mov    $0x2,%eax
  8014e2:	e8 8d ff ff ff       	call   801474 <fsipc>
}
  8014e7:	c9                   	leave  
  8014e8:	c3                   	ret    

008014e9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ff:	b8 06 00 00 00       	mov    $0x6,%eax
  801504:	e8 6b ff ff ff       	call   801474 <fsipc>
}
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	53                   	push   %ebx
  80150f:	83 ec 04             	sub    $0x4,%esp
  801512:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801515:	8b 45 08             	mov    0x8(%ebp),%eax
  801518:	8b 40 0c             	mov    0xc(%eax),%eax
  80151b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801520:	ba 00 00 00 00       	mov    $0x0,%edx
  801525:	b8 05 00 00 00       	mov    $0x5,%eax
  80152a:	e8 45 ff ff ff       	call   801474 <fsipc>
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 2c                	js     80155f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	68 00 50 80 00       	push   $0x805000
  80153b:	53                   	push   %ebx
  80153c:	e8 3c f2 ff ff       	call   80077d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801541:	a1 80 50 80 00       	mov    0x805080,%eax
  801546:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80154c:	a1 84 50 80 00       	mov    0x805084,%eax
  801551:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80156a:	68 d8 24 80 00       	push   $0x8024d8
  80156f:	68 90 00 00 00       	push   $0x90
  801574:	68 f6 24 80 00       	push   $0x8024f6
  801579:	e8 15 07 00 00       	call   801c93 <_panic>

0080157e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	56                   	push   %esi
  801582:	53                   	push   %ebx
  801583:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801586:	8b 45 08             	mov    0x8(%ebp),%eax
  801589:	8b 40 0c             	mov    0xc(%eax),%eax
  80158c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801591:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801597:	ba 00 00 00 00       	mov    $0x0,%edx
  80159c:	b8 03 00 00 00       	mov    $0x3,%eax
  8015a1:	e8 ce fe ff ff       	call   801474 <fsipc>
  8015a6:	89 c3                	mov    %eax,%ebx
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 4b                	js     8015f7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015ac:	39 c6                	cmp    %eax,%esi
  8015ae:	73 16                	jae    8015c6 <devfile_read+0x48>
  8015b0:	68 01 25 80 00       	push   $0x802501
  8015b5:	68 08 25 80 00       	push   $0x802508
  8015ba:	6a 7c                	push   $0x7c
  8015bc:	68 f6 24 80 00       	push   $0x8024f6
  8015c1:	e8 cd 06 00 00       	call   801c93 <_panic>
	assert(r <= PGSIZE);
  8015c6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015cb:	7e 16                	jle    8015e3 <devfile_read+0x65>
  8015cd:	68 1d 25 80 00       	push   $0x80251d
  8015d2:	68 08 25 80 00       	push   $0x802508
  8015d7:	6a 7d                	push   $0x7d
  8015d9:	68 f6 24 80 00       	push   $0x8024f6
  8015de:	e8 b0 06 00 00       	call   801c93 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015e3:	83 ec 04             	sub    $0x4,%esp
  8015e6:	50                   	push   %eax
  8015e7:	68 00 50 80 00       	push   $0x805000
  8015ec:	ff 75 0c             	pushl  0xc(%ebp)
  8015ef:	e8 1b f3 ff ff       	call   80090f <memmove>
	return r;
  8015f4:	83 c4 10             	add    $0x10,%esp
}
  8015f7:	89 d8                	mov    %ebx,%eax
  8015f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5e                   	pop    %esi
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	83 ec 20             	sub    $0x20,%esp
  801607:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80160a:	53                   	push   %ebx
  80160b:	e8 34 f1 ff ff       	call   800744 <strlen>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801618:	7f 67                	jg     801681 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	e8 c6 f8 ff ff       	call   800eec <fd_alloc>
  801626:	83 c4 10             	add    $0x10,%esp
		return r;
  801629:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 57                	js     801686 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	53                   	push   %ebx
  801633:	68 00 50 80 00       	push   $0x805000
  801638:	e8 40 f1 ff ff       	call   80077d <strcpy>
	fsipcbuf.open.req_omode = mode;
  80163d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801640:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801645:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801648:	b8 01 00 00 00       	mov    $0x1,%eax
  80164d:	e8 22 fe ff ff       	call   801474 <fsipc>
  801652:	89 c3                	mov    %eax,%ebx
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	79 14                	jns    80166f <open+0x6f>
		fd_close(fd, 0);
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	6a 00                	push   $0x0
  801660:	ff 75 f4             	pushl  -0xc(%ebp)
  801663:	e8 7c f9 ff ff       	call   800fe4 <fd_close>
		return r;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	89 da                	mov    %ebx,%edx
  80166d:	eb 17                	jmp    801686 <open+0x86>
	}

	return fd2num(fd);
  80166f:	83 ec 0c             	sub    $0xc,%esp
  801672:	ff 75 f4             	pushl  -0xc(%ebp)
  801675:	e8 4b f8 ff ff       	call   800ec5 <fd2num>
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	eb 05                	jmp    801686 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801681:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801686:	89 d0                	mov    %edx,%eax
  801688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801693:	ba 00 00 00 00       	mov    $0x0,%edx
  801698:	b8 08 00 00 00       	mov    $0x8,%eax
  80169d:	e8 d2 fd ff ff       	call   801474 <fsipc>
}
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016a4:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016a8:	7e 37                	jle    8016e1 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016b3:	ff 70 04             	pushl  0x4(%eax)
  8016b6:	8d 40 10             	lea    0x10(%eax),%eax
  8016b9:	50                   	push   %eax
  8016ba:	ff 33                	pushl  (%ebx)
  8016bc:	e8 ba fb ff ff       	call   80127b <write>
		if (result > 0)
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	7e 03                	jle    8016cb <writebuf+0x27>
			b->result += result;
  8016c8:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016cb:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016ce:	74 0d                	je     8016dd <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d7:	0f 4f c2             	cmovg  %edx,%eax
  8016da:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e0:	c9                   	leave  
  8016e1:	f3 c3                	repz ret 

008016e3 <putch>:

static void
putch(int ch, void *thunk)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 04             	sub    $0x4,%esp
  8016ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016ed:	8b 53 04             	mov    0x4(%ebx),%edx
  8016f0:	8d 42 01             	lea    0x1(%edx),%eax
  8016f3:	89 43 04             	mov    %eax,0x4(%ebx)
  8016f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f9:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016fd:	3d 00 01 00 00       	cmp    $0x100,%eax
  801702:	75 0e                	jne    801712 <putch+0x2f>
		writebuf(b);
  801704:	89 d8                	mov    %ebx,%eax
  801706:	e8 99 ff ff ff       	call   8016a4 <writebuf>
		b->idx = 0;
  80170b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801712:	83 c4 04             	add    $0x4,%esp
  801715:	5b                   	pop    %ebx
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801721:	8b 45 08             	mov    0x8(%ebp),%eax
  801724:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80172a:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801731:	00 00 00 
	b.result = 0;
  801734:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80173b:	00 00 00 
	b.error = 1;
  80173e:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801745:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801748:	ff 75 10             	pushl  0x10(%ebp)
  80174b:	ff 75 0c             	pushl  0xc(%ebp)
  80174e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801754:	50                   	push   %eax
  801755:	68 e3 16 80 00       	push   $0x8016e3
  80175a:	e8 d0 eb ff ff       	call   80032f <vprintfmt>
	if (b.idx > 0)
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801769:	7e 0b                	jle    801776 <vfprintf+0x5e>
		writebuf(&b);
  80176b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801771:	e8 2e ff ff ff       	call   8016a4 <writebuf>

	return (b.result ? b.result : b.error);
  801776:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80177c:	85 c0                	test   %eax,%eax
  80177e:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80178d:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801790:	50                   	push   %eax
  801791:	ff 75 0c             	pushl  0xc(%ebp)
  801794:	ff 75 08             	pushl  0x8(%ebp)
  801797:	e8 7c ff ff ff       	call   801718 <vfprintf>
	va_end(ap);

	return cnt;
}
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <printf>:

int
printf(const char *fmt, ...)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017a4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017a7:	50                   	push   %eax
  8017a8:	ff 75 08             	pushl  0x8(%ebp)
  8017ab:	6a 01                	push   $0x1
  8017ad:	e8 66 ff ff ff       	call   801718 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017b2:	c9                   	leave  
  8017b3:	c3                   	ret    

008017b4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	56                   	push   %esi
  8017b8:	53                   	push   %ebx
  8017b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017bc:	83 ec 0c             	sub    $0xc,%esp
  8017bf:	ff 75 08             	pushl  0x8(%ebp)
  8017c2:	e8 0e f7 ff ff       	call   800ed5 <fd2data>
  8017c7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017c9:	83 c4 08             	add    $0x8,%esp
  8017cc:	68 29 25 80 00       	push   $0x802529
  8017d1:	53                   	push   %ebx
  8017d2:	e8 a6 ef ff ff       	call   80077d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017d7:	8b 46 04             	mov    0x4(%esi),%eax
  8017da:	2b 06                	sub    (%esi),%eax
  8017dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017e9:	00 00 00 
	stat->st_dev = &devpipe;
  8017ec:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017f3:	30 80 00 
	return 0;
}
  8017f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	53                   	push   %ebx
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80180c:	53                   	push   %ebx
  80180d:	6a 00                	push   $0x0
  80180f:	e8 f1 f3 ff ff       	call   800c05 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801814:	89 1c 24             	mov    %ebx,(%esp)
  801817:	e8 b9 f6 ff ff       	call   800ed5 <fd2data>
  80181c:	83 c4 08             	add    $0x8,%esp
  80181f:	50                   	push   %eax
  801820:	6a 00                	push   $0x0
  801822:	e8 de f3 ff ff       	call   800c05 <sys_page_unmap>
}
  801827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182a:	c9                   	leave  
  80182b:	c3                   	ret    

0080182c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	57                   	push   %edi
  801830:	56                   	push   %esi
  801831:	53                   	push   %ebx
  801832:	83 ec 1c             	sub    $0x1c,%esp
  801835:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801838:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80183a:	a1 04 40 80 00       	mov    0x804004,%eax
  80183f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801842:	83 ec 0c             	sub    $0xc,%esp
  801845:	ff 75 e0             	pushl  -0x20(%ebp)
  801848:	e8 c6 05 00 00       	call   801e13 <pageref>
  80184d:	89 c3                	mov    %eax,%ebx
  80184f:	89 3c 24             	mov    %edi,(%esp)
  801852:	e8 bc 05 00 00       	call   801e13 <pageref>
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	39 c3                	cmp    %eax,%ebx
  80185c:	0f 94 c1             	sete   %cl
  80185f:	0f b6 c9             	movzbl %cl,%ecx
  801862:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801865:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80186b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80186e:	39 ce                	cmp    %ecx,%esi
  801870:	74 1b                	je     80188d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801872:	39 c3                	cmp    %eax,%ebx
  801874:	75 c4                	jne    80183a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801876:	8b 42 58             	mov    0x58(%edx),%eax
  801879:	ff 75 e4             	pushl  -0x1c(%ebp)
  80187c:	50                   	push   %eax
  80187d:	56                   	push   %esi
  80187e:	68 30 25 80 00       	push   $0x802530
  801883:	e8 70 e9 ff ff       	call   8001f8 <cprintf>
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	eb ad                	jmp    80183a <_pipeisclosed+0xe>
	}
}
  80188d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801890:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801893:	5b                   	pop    %ebx
  801894:	5e                   	pop    %esi
  801895:	5f                   	pop    %edi
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	57                   	push   %edi
  80189c:	56                   	push   %esi
  80189d:	53                   	push   %ebx
  80189e:	83 ec 28             	sub    $0x28,%esp
  8018a1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018a4:	56                   	push   %esi
  8018a5:	e8 2b f6 ff ff       	call   800ed5 <fd2data>
  8018aa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	bf 00 00 00 00       	mov    $0x0,%edi
  8018b4:	eb 4b                	jmp    801901 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018b6:	89 da                	mov    %ebx,%edx
  8018b8:	89 f0                	mov    %esi,%eax
  8018ba:	e8 6d ff ff ff       	call   80182c <_pipeisclosed>
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	75 48                	jne    80190b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018c3:	e8 99 f2 ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018c8:	8b 43 04             	mov    0x4(%ebx),%eax
  8018cb:	8b 0b                	mov    (%ebx),%ecx
  8018cd:	8d 51 20             	lea    0x20(%ecx),%edx
  8018d0:	39 d0                	cmp    %edx,%eax
  8018d2:	73 e2                	jae    8018b6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018db:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018de:	89 c2                	mov    %eax,%edx
  8018e0:	c1 fa 1f             	sar    $0x1f,%edx
  8018e3:	89 d1                	mov    %edx,%ecx
  8018e5:	c1 e9 1b             	shr    $0x1b,%ecx
  8018e8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018eb:	83 e2 1f             	and    $0x1f,%edx
  8018ee:	29 ca                	sub    %ecx,%edx
  8018f0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018f8:	83 c0 01             	add    $0x1,%eax
  8018fb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fe:	83 c7 01             	add    $0x1,%edi
  801901:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801904:	75 c2                	jne    8018c8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801906:	8b 45 10             	mov    0x10(%ebp),%eax
  801909:	eb 05                	jmp    801910 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801910:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801913:	5b                   	pop    %ebx
  801914:	5e                   	pop    %esi
  801915:	5f                   	pop    %edi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	57                   	push   %edi
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	83 ec 18             	sub    $0x18,%esp
  801921:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801924:	57                   	push   %edi
  801925:	e8 ab f5 ff ff       	call   800ed5 <fd2data>
  80192a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801934:	eb 3d                	jmp    801973 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801936:	85 db                	test   %ebx,%ebx
  801938:	74 04                	je     80193e <devpipe_read+0x26>
				return i;
  80193a:	89 d8                	mov    %ebx,%eax
  80193c:	eb 44                	jmp    801982 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80193e:	89 f2                	mov    %esi,%edx
  801940:	89 f8                	mov    %edi,%eax
  801942:	e8 e5 fe ff ff       	call   80182c <_pipeisclosed>
  801947:	85 c0                	test   %eax,%eax
  801949:	75 32                	jne    80197d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80194b:	e8 11 f2 ff ff       	call   800b61 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801950:	8b 06                	mov    (%esi),%eax
  801952:	3b 46 04             	cmp    0x4(%esi),%eax
  801955:	74 df                	je     801936 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801957:	99                   	cltd   
  801958:	c1 ea 1b             	shr    $0x1b,%edx
  80195b:	01 d0                	add    %edx,%eax
  80195d:	83 e0 1f             	and    $0x1f,%eax
  801960:	29 d0                	sub    %edx,%eax
  801962:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801967:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80196a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80196d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801970:	83 c3 01             	add    $0x1,%ebx
  801973:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801976:	75 d8                	jne    801950 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801978:	8b 45 10             	mov    0x10(%ebp),%eax
  80197b:	eb 05                	jmp    801982 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80197d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801982:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801985:	5b                   	pop    %ebx
  801986:	5e                   	pop    %esi
  801987:	5f                   	pop    %edi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	56                   	push   %esi
  80198e:	53                   	push   %ebx
  80198f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801992:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801995:	50                   	push   %eax
  801996:	e8 51 f5 ff ff       	call   800eec <fd_alloc>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	89 c2                	mov    %eax,%edx
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	0f 88 2c 01 00 00    	js     801ad4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a8:	83 ec 04             	sub    $0x4,%esp
  8019ab:	68 07 04 00 00       	push   $0x407
  8019b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b3:	6a 00                	push   $0x0
  8019b5:	e8 c6 f1 ff ff       	call   800b80 <sys_page_alloc>
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	89 c2                	mov    %eax,%edx
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	0f 88 0d 01 00 00    	js     801ad4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019c7:	83 ec 0c             	sub    $0xc,%esp
  8019ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019cd:	50                   	push   %eax
  8019ce:	e8 19 f5 ff ff       	call   800eec <fd_alloc>
  8019d3:	89 c3                	mov    %eax,%ebx
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	0f 88 e2 00 00 00    	js     801ac2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e0:	83 ec 04             	sub    $0x4,%esp
  8019e3:	68 07 04 00 00       	push   $0x407
  8019e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8019eb:	6a 00                	push   $0x0
  8019ed:	e8 8e f1 ff ff       	call   800b80 <sys_page_alloc>
  8019f2:	89 c3                	mov    %eax,%ebx
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	0f 88 c3 00 00 00    	js     801ac2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	ff 75 f4             	pushl  -0xc(%ebp)
  801a05:	e8 cb f4 ff ff       	call   800ed5 <fd2data>
  801a0a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a0c:	83 c4 0c             	add    $0xc,%esp
  801a0f:	68 07 04 00 00       	push   $0x407
  801a14:	50                   	push   %eax
  801a15:	6a 00                	push   $0x0
  801a17:	e8 64 f1 ff ff       	call   800b80 <sys_page_alloc>
  801a1c:	89 c3                	mov    %eax,%ebx
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	85 c0                	test   %eax,%eax
  801a23:	0f 88 89 00 00 00    	js     801ab2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a2f:	e8 a1 f4 ff ff       	call   800ed5 <fd2data>
  801a34:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a3b:	50                   	push   %eax
  801a3c:	6a 00                	push   $0x0
  801a3e:	56                   	push   %esi
  801a3f:	6a 00                	push   $0x0
  801a41:	e8 7d f1 ff ff       	call   800bc3 <sys_page_map>
  801a46:	89 c3                	mov    %eax,%ebx
  801a48:	83 c4 20             	add    $0x20,%esp
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	78 55                	js     801aa4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a4f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a58:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a64:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a72:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7f:	e8 41 f4 ff ff       	call   800ec5 <fd2num>
  801a84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a87:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a89:	83 c4 04             	add    $0x4,%esp
  801a8c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a8f:	e8 31 f4 ff ff       	call   800ec5 <fd2num>
  801a94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a97:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa2:	eb 30                	jmp    801ad4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801aa4:	83 ec 08             	sub    $0x8,%esp
  801aa7:	56                   	push   %esi
  801aa8:	6a 00                	push   $0x0
  801aaa:	e8 56 f1 ff ff       	call   800c05 <sys_page_unmap>
  801aaf:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ab2:	83 ec 08             	sub    $0x8,%esp
  801ab5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab8:	6a 00                	push   $0x0
  801aba:	e8 46 f1 ff ff       	call   800c05 <sys_page_unmap>
  801abf:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac8:	6a 00                	push   $0x0
  801aca:	e8 36 f1 ff ff       	call   800c05 <sys_page_unmap>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ad4:	89 d0                	mov    %edx,%eax
  801ad6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae6:	50                   	push   %eax
  801ae7:	ff 75 08             	pushl  0x8(%ebp)
  801aea:	e8 4c f4 ff ff       	call   800f3b <fd_lookup>
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	85 c0                	test   %eax,%eax
  801af4:	78 18                	js     801b0e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	ff 75 f4             	pushl  -0xc(%ebp)
  801afc:	e8 d4 f3 ff ff       	call   800ed5 <fd2data>
	return _pipeisclosed(fd, p);
  801b01:	89 c2                	mov    %eax,%edx
  801b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b06:	e8 21 fd ff ff       	call   80182c <_pipeisclosed>
  801b0b:	83 c4 10             	add    $0x10,%esp
}
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b20:	68 48 25 80 00       	push   $0x802548
  801b25:	ff 75 0c             	pushl  0xc(%ebp)
  801b28:	e8 50 ec ff ff       	call   80077d <strcpy>
	return 0;
}
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b32:	c9                   	leave  
  801b33:	c3                   	ret    

00801b34 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	57                   	push   %edi
  801b38:	56                   	push   %esi
  801b39:	53                   	push   %ebx
  801b3a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b40:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b45:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b4b:	eb 2d                	jmp    801b7a <devcons_write+0x46>
		m = n - tot;
  801b4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b50:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801b52:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b55:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801b5a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b5d:	83 ec 04             	sub    $0x4,%esp
  801b60:	53                   	push   %ebx
  801b61:	03 45 0c             	add    0xc(%ebp),%eax
  801b64:	50                   	push   %eax
  801b65:	57                   	push   %edi
  801b66:	e8 a4 ed ff ff       	call   80090f <memmove>
		sys_cputs(buf, m);
  801b6b:	83 c4 08             	add    $0x8,%esp
  801b6e:	53                   	push   %ebx
  801b6f:	57                   	push   %edi
  801b70:	e8 4f ef ff ff       	call   800ac4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b75:	01 de                	add    %ebx,%esi
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	89 f0                	mov    %esi,%eax
  801b7c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b7f:	72 cc                	jb     801b4d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b84:	5b                   	pop    %ebx
  801b85:	5e                   	pop    %esi
  801b86:	5f                   	pop    %edi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801b94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b98:	74 2a                	je     801bc4 <devcons_read+0x3b>
  801b9a:	eb 05                	jmp    801ba1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b9c:	e8 c0 ef ff ff       	call   800b61 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ba1:	e8 3c ef ff ff       	call   800ae2 <sys_cgetc>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	74 f2                	je     801b9c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 16                	js     801bc4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bae:	83 f8 04             	cmp    $0x4,%eax
  801bb1:	74 0c                	je     801bbf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb6:	88 02                	mov    %al,(%edx)
	return 1;
  801bb8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbd:	eb 05                	jmp    801bc4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801bbf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bd2:	6a 01                	push   $0x1
  801bd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bd7:	50                   	push   %eax
  801bd8:	e8 e7 ee ff ff       	call   800ac4 <sys_cputs>
}
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <getchar>:

int
getchar(void)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801be8:	6a 01                	push   $0x1
  801bea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bed:	50                   	push   %eax
  801bee:	6a 00                	push   $0x0
  801bf0:	e8 ac f5 ff ff       	call   8011a1 <read>
	if (r < 0)
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	78 0f                	js     801c0b <getchar+0x29>
		return r;
	if (r < 1)
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	7e 06                	jle    801c06 <getchar+0x24>
		return -E_EOF;
	return c;
  801c00:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c04:	eb 05                	jmp    801c0b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c06:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c0b:	c9                   	leave  
  801c0c:	c3                   	ret    

00801c0d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c16:	50                   	push   %eax
  801c17:	ff 75 08             	pushl  0x8(%ebp)
  801c1a:	e8 1c f3 ff ff       	call   800f3b <fd_lookup>
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	85 c0                	test   %eax,%eax
  801c24:	78 11                	js     801c37 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c29:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c2f:	39 10                	cmp    %edx,(%eax)
  801c31:	0f 94 c0             	sete   %al
  801c34:	0f b6 c0             	movzbl %al,%eax
}
  801c37:	c9                   	leave  
  801c38:	c3                   	ret    

00801c39 <opencons>:

int
opencons(void)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c42:	50                   	push   %eax
  801c43:	e8 a4 f2 ff ff       	call   800eec <fd_alloc>
  801c48:	83 c4 10             	add    $0x10,%esp
		return r;
  801c4b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 3e                	js     801c8f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c51:	83 ec 04             	sub    $0x4,%esp
  801c54:	68 07 04 00 00       	push   $0x407
  801c59:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 1d ef ff ff       	call   800b80 <sys_page_alloc>
  801c63:	83 c4 10             	add    $0x10,%esp
		return r;
  801c66:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 23                	js     801c8f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c6c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c75:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c81:	83 ec 0c             	sub    $0xc,%esp
  801c84:	50                   	push   %eax
  801c85:	e8 3b f2 ff ff       	call   800ec5 <fd2num>
  801c8a:	89 c2                	mov    %eax,%edx
  801c8c:	83 c4 10             	add    $0x10,%esp
}
  801c8f:	89 d0                	mov    %edx,%eax
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801c98:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c9b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ca1:	e8 9c ee ff ff       	call   800b42 <sys_getenvid>
  801ca6:	83 ec 0c             	sub    $0xc,%esp
  801ca9:	ff 75 0c             	pushl  0xc(%ebp)
  801cac:	ff 75 08             	pushl  0x8(%ebp)
  801caf:	56                   	push   %esi
  801cb0:	50                   	push   %eax
  801cb1:	68 54 25 80 00       	push   $0x802554
  801cb6:	e8 3d e5 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cbb:	83 c4 18             	add    $0x18,%esp
  801cbe:	53                   	push   %ebx
  801cbf:	ff 75 10             	pushl  0x10(%ebp)
  801cc2:	e8 e0 e4 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  801cc7:	c7 04 24 f0 20 80 00 	movl   $0x8020f0,(%esp)
  801cce:	e8 25 e5 ff ff       	call   8001f8 <cprintf>
  801cd3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cd6:	cc                   	int3   
  801cd7:	eb fd                	jmp    801cd6 <_panic+0x43>

00801cd9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	56                   	push   %esi
  801cdd:	53                   	push   %ebx
  801cde:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce4:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	74 0e                	je     801cf9 <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	50                   	push   %eax
  801cef:	e8 3c f0 ff ff       	call   800d30 <sys_ipc_recv>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	eb 10                	jmp    801d09 <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	68 00 00 00 f0       	push   $0xf0000000
  801d01:	e8 2a f0 ff ff       	call   800d30 <sys_ipc_recv>
  801d06:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	74 16                	je     801d23 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  801d0d:	85 db                	test   %ebx,%ebx
  801d0f:	74 36                	je     801d47 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  801d11:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  801d17:	85 f6                	test   %esi,%esi
  801d19:	74 2c                	je     801d47 <ipc_recv+0x6e>
				*perm_store = 0;
  801d1b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801d21:	eb 24                	jmp    801d47 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  801d23:	85 db                	test   %ebx,%ebx
  801d25:	74 18                	je     801d3f <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  801d27:	a1 04 40 80 00       	mov    0x804004,%eax
  801d2c:	8b 40 74             	mov    0x74(%eax),%eax
  801d2f:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  801d31:	85 f6                	test   %esi,%esi
  801d33:	74 0a                	je     801d3f <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  801d35:	a1 04 40 80 00       	mov    0x804004,%eax
  801d3a:	8b 40 78             	mov    0x78(%eax),%eax
  801d3d:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  801d3f:	a1 04 40 80 00       	mov    0x804004,%eax
  801d44:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  801d47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d5a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  801d5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d61:	75 39                	jne    801d9c <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  801d63:	6a 00                	push   $0x0
  801d65:	68 00 00 00 f0       	push   $0xf0000000
  801d6a:	56                   	push   %esi
  801d6b:	57                   	push   %edi
  801d6c:	e8 9c ef ff ff       	call   800d0d <sys_ipc_try_send>
  801d71:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d79:	74 16                	je     801d91 <ipc_send+0x43>
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	74 12                	je     801d91 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801d7f:	50                   	push   %eax
  801d80:	68 78 25 80 00       	push   $0x802578
  801d85:	6a 4f                	push   $0x4f
  801d87:	68 b0 25 80 00       	push   $0x8025b0
  801d8c:	e8 02 ff ff ff       	call   801c93 <_panic>
			sys_yield();
  801d91:	e8 cb ed ff ff       	call   800b61 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  801d96:	85 db                	test   %ebx,%ebx
  801d98:	75 c9                	jne    801d63 <ipc_send+0x15>
  801d9a:	eb 36                	jmp    801dd2 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  801d9c:	ff 75 14             	pushl  0x14(%ebp)
  801d9f:	ff 75 10             	pushl  0x10(%ebp)
  801da2:	56                   	push   %esi
  801da3:	57                   	push   %edi
  801da4:	e8 64 ef ff ff       	call   800d0d <sys_ipc_try_send>
  801da9:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801db1:	74 16                	je     801dc9 <ipc_send+0x7b>
  801db3:	85 c0                	test   %eax,%eax
  801db5:	74 12                	je     801dc9 <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801db7:	50                   	push   %eax
  801db8:	68 78 25 80 00       	push   $0x802578
  801dbd:	6a 5a                	push   $0x5a
  801dbf:	68 b0 25 80 00       	push   $0x8025b0
  801dc4:	e8 ca fe ff ff       	call   801c93 <_panic>
			sys_yield();
  801dc9:	e8 93 ed ff ff       	call   800b61 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  801dce:	85 db                	test   %ebx,%ebx
  801dd0:	75 ca                	jne    801d9c <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  801dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd5:	5b                   	pop    %ebx
  801dd6:	5e                   	pop    %esi
  801dd7:	5f                   	pop    %edi
  801dd8:	5d                   	pop    %ebp
  801dd9:	c3                   	ret    

00801dda <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801de0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801de5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801de8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801dee:	8b 52 50             	mov    0x50(%edx),%edx
  801df1:	39 ca                	cmp    %ecx,%edx
  801df3:	75 0d                	jne    801e02 <ipc_find_env+0x28>
			return envs[i].env_id;
  801df5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801df8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801dfd:	8b 40 48             	mov    0x48(%eax),%eax
  801e00:	eb 0f                	jmp    801e11 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e02:	83 c0 01             	add    $0x1,%eax
  801e05:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e0a:	75 d9                	jne    801de5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    

00801e13 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e19:	89 d0                	mov    %edx,%eax
  801e1b:	c1 e8 16             	shr    $0x16,%eax
  801e1e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e25:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e2a:	f6 c1 01             	test   $0x1,%cl
  801e2d:	74 1d                	je     801e4c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e2f:	c1 ea 0c             	shr    $0xc,%edx
  801e32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e39:	f6 c2 01             	test   $0x1,%dl
  801e3c:	74 0e                	je     801e4c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e3e:	c1 ea 0c             	shr    $0xc,%edx
  801e41:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e48:	ef 
  801e49:	0f b7 c0             	movzwl %ax,%eax
}
  801e4c:	5d                   	pop    %ebp
  801e4d:	c3                   	ret    
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__udivdi3>:
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	83 ec 1c             	sub    $0x1c,%esp
  801e57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801e5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e67:	85 f6                	test   %esi,%esi
  801e69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e6d:	89 ca                	mov    %ecx,%edx
  801e6f:	89 f8                	mov    %edi,%eax
  801e71:	75 3d                	jne    801eb0 <__udivdi3+0x60>
  801e73:	39 cf                	cmp    %ecx,%edi
  801e75:	0f 87 c5 00 00 00    	ja     801f40 <__udivdi3+0xf0>
  801e7b:	85 ff                	test   %edi,%edi
  801e7d:	89 fd                	mov    %edi,%ebp
  801e7f:	75 0b                	jne    801e8c <__udivdi3+0x3c>
  801e81:	b8 01 00 00 00       	mov    $0x1,%eax
  801e86:	31 d2                	xor    %edx,%edx
  801e88:	f7 f7                	div    %edi
  801e8a:	89 c5                	mov    %eax,%ebp
  801e8c:	89 c8                	mov    %ecx,%eax
  801e8e:	31 d2                	xor    %edx,%edx
  801e90:	f7 f5                	div    %ebp
  801e92:	89 c1                	mov    %eax,%ecx
  801e94:	89 d8                	mov    %ebx,%eax
  801e96:	89 cf                	mov    %ecx,%edi
  801e98:	f7 f5                	div    %ebp
  801e9a:	89 c3                	mov    %eax,%ebx
  801e9c:	89 d8                	mov    %ebx,%eax
  801e9e:	89 fa                	mov    %edi,%edx
  801ea0:	83 c4 1c             	add    $0x1c,%esp
  801ea3:	5b                   	pop    %ebx
  801ea4:	5e                   	pop    %esi
  801ea5:	5f                   	pop    %edi
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    
  801ea8:	90                   	nop
  801ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801eb0:	39 ce                	cmp    %ecx,%esi
  801eb2:	77 74                	ja     801f28 <__udivdi3+0xd8>
  801eb4:	0f bd fe             	bsr    %esi,%edi
  801eb7:	83 f7 1f             	xor    $0x1f,%edi
  801eba:	0f 84 98 00 00 00    	je     801f58 <__udivdi3+0x108>
  801ec0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ec5:	89 f9                	mov    %edi,%ecx
  801ec7:	89 c5                	mov    %eax,%ebp
  801ec9:	29 fb                	sub    %edi,%ebx
  801ecb:	d3 e6                	shl    %cl,%esi
  801ecd:	89 d9                	mov    %ebx,%ecx
  801ecf:	d3 ed                	shr    %cl,%ebp
  801ed1:	89 f9                	mov    %edi,%ecx
  801ed3:	d3 e0                	shl    %cl,%eax
  801ed5:	09 ee                	or     %ebp,%esi
  801ed7:	89 d9                	mov    %ebx,%ecx
  801ed9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801edd:	89 d5                	mov    %edx,%ebp
  801edf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ee3:	d3 ed                	shr    %cl,%ebp
  801ee5:	89 f9                	mov    %edi,%ecx
  801ee7:	d3 e2                	shl    %cl,%edx
  801ee9:	89 d9                	mov    %ebx,%ecx
  801eeb:	d3 e8                	shr    %cl,%eax
  801eed:	09 c2                	or     %eax,%edx
  801eef:	89 d0                	mov    %edx,%eax
  801ef1:	89 ea                	mov    %ebp,%edx
  801ef3:	f7 f6                	div    %esi
  801ef5:	89 d5                	mov    %edx,%ebp
  801ef7:	89 c3                	mov    %eax,%ebx
  801ef9:	f7 64 24 0c          	mull   0xc(%esp)
  801efd:	39 d5                	cmp    %edx,%ebp
  801eff:	72 10                	jb     801f11 <__udivdi3+0xc1>
  801f01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f05:	89 f9                	mov    %edi,%ecx
  801f07:	d3 e6                	shl    %cl,%esi
  801f09:	39 c6                	cmp    %eax,%esi
  801f0b:	73 07                	jae    801f14 <__udivdi3+0xc4>
  801f0d:	39 d5                	cmp    %edx,%ebp
  801f0f:	75 03                	jne    801f14 <__udivdi3+0xc4>
  801f11:	83 eb 01             	sub    $0x1,%ebx
  801f14:	31 ff                	xor    %edi,%edi
  801f16:	89 d8                	mov    %ebx,%eax
  801f18:	89 fa                	mov    %edi,%edx
  801f1a:	83 c4 1c             	add    $0x1c,%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5f                   	pop    %edi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    
  801f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f28:	31 ff                	xor    %edi,%edi
  801f2a:	31 db                	xor    %ebx,%ebx
  801f2c:	89 d8                	mov    %ebx,%eax
  801f2e:	89 fa                	mov    %edi,%edx
  801f30:	83 c4 1c             	add    $0x1c,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    
  801f38:	90                   	nop
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	89 d8                	mov    %ebx,%eax
  801f42:	f7 f7                	div    %edi
  801f44:	31 ff                	xor    %edi,%edi
  801f46:	89 c3                	mov    %eax,%ebx
  801f48:	89 d8                	mov    %ebx,%eax
  801f4a:	89 fa                	mov    %edi,%edx
  801f4c:	83 c4 1c             	add    $0x1c,%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    
  801f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f58:	39 ce                	cmp    %ecx,%esi
  801f5a:	72 0c                	jb     801f68 <__udivdi3+0x118>
  801f5c:	31 db                	xor    %ebx,%ebx
  801f5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801f62:	0f 87 34 ff ff ff    	ja     801e9c <__udivdi3+0x4c>
  801f68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801f6d:	e9 2a ff ff ff       	jmp    801e9c <__udivdi3+0x4c>
  801f72:	66 90                	xchg   %ax,%ax
  801f74:	66 90                	xchg   %ax,%ax
  801f76:	66 90                	xchg   %ax,%ax
  801f78:	66 90                	xchg   %ax,%ax
  801f7a:	66 90                	xchg   %ax,%ax
  801f7c:	66 90                	xchg   %ax,%ax
  801f7e:	66 90                	xchg   %ax,%ax

00801f80 <__umoddi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 d2                	test   %edx,%edx
  801f99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fa1:	89 f3                	mov    %esi,%ebx
  801fa3:	89 3c 24             	mov    %edi,(%esp)
  801fa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801faa:	75 1c                	jne    801fc8 <__umoddi3+0x48>
  801fac:	39 f7                	cmp    %esi,%edi
  801fae:	76 50                	jbe    802000 <__umoddi3+0x80>
  801fb0:	89 c8                	mov    %ecx,%eax
  801fb2:	89 f2                	mov    %esi,%edx
  801fb4:	f7 f7                	div    %edi
  801fb6:	89 d0                	mov    %edx,%eax
  801fb8:	31 d2                	xor    %edx,%edx
  801fba:	83 c4 1c             	add    $0x1c,%esp
  801fbd:	5b                   	pop    %ebx
  801fbe:	5e                   	pop    %esi
  801fbf:	5f                   	pop    %edi
  801fc0:	5d                   	pop    %ebp
  801fc1:	c3                   	ret    
  801fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fc8:	39 f2                	cmp    %esi,%edx
  801fca:	89 d0                	mov    %edx,%eax
  801fcc:	77 52                	ja     802020 <__umoddi3+0xa0>
  801fce:	0f bd ea             	bsr    %edx,%ebp
  801fd1:	83 f5 1f             	xor    $0x1f,%ebp
  801fd4:	75 5a                	jne    802030 <__umoddi3+0xb0>
  801fd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801fda:	0f 82 e0 00 00 00    	jb     8020c0 <__umoddi3+0x140>
  801fe0:	39 0c 24             	cmp    %ecx,(%esp)
  801fe3:	0f 86 d7 00 00 00    	jbe    8020c0 <__umoddi3+0x140>
  801fe9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fed:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ff1:	83 c4 1c             	add    $0x1c,%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	85 ff                	test   %edi,%edi
  802002:	89 fd                	mov    %edi,%ebp
  802004:	75 0b                	jne    802011 <__umoddi3+0x91>
  802006:	b8 01 00 00 00       	mov    $0x1,%eax
  80200b:	31 d2                	xor    %edx,%edx
  80200d:	f7 f7                	div    %edi
  80200f:	89 c5                	mov    %eax,%ebp
  802011:	89 f0                	mov    %esi,%eax
  802013:	31 d2                	xor    %edx,%edx
  802015:	f7 f5                	div    %ebp
  802017:	89 c8                	mov    %ecx,%eax
  802019:	f7 f5                	div    %ebp
  80201b:	89 d0                	mov    %edx,%eax
  80201d:	eb 99                	jmp    801fb8 <__umoddi3+0x38>
  80201f:	90                   	nop
  802020:	89 c8                	mov    %ecx,%eax
  802022:	89 f2                	mov    %esi,%edx
  802024:	83 c4 1c             	add    $0x1c,%esp
  802027:	5b                   	pop    %ebx
  802028:	5e                   	pop    %esi
  802029:	5f                   	pop    %edi
  80202a:	5d                   	pop    %ebp
  80202b:	c3                   	ret    
  80202c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802030:	8b 34 24             	mov    (%esp),%esi
  802033:	bf 20 00 00 00       	mov    $0x20,%edi
  802038:	89 e9                	mov    %ebp,%ecx
  80203a:	29 ef                	sub    %ebp,%edi
  80203c:	d3 e0                	shl    %cl,%eax
  80203e:	89 f9                	mov    %edi,%ecx
  802040:	89 f2                	mov    %esi,%edx
  802042:	d3 ea                	shr    %cl,%edx
  802044:	89 e9                	mov    %ebp,%ecx
  802046:	09 c2                	or     %eax,%edx
  802048:	89 d8                	mov    %ebx,%eax
  80204a:	89 14 24             	mov    %edx,(%esp)
  80204d:	89 f2                	mov    %esi,%edx
  80204f:	d3 e2                	shl    %cl,%edx
  802051:	89 f9                	mov    %edi,%ecx
  802053:	89 54 24 04          	mov    %edx,0x4(%esp)
  802057:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	89 e9                	mov    %ebp,%ecx
  80205f:	89 c6                	mov    %eax,%esi
  802061:	d3 e3                	shl    %cl,%ebx
  802063:	89 f9                	mov    %edi,%ecx
  802065:	89 d0                	mov    %edx,%eax
  802067:	d3 e8                	shr    %cl,%eax
  802069:	89 e9                	mov    %ebp,%ecx
  80206b:	09 d8                	or     %ebx,%eax
  80206d:	89 d3                	mov    %edx,%ebx
  80206f:	89 f2                	mov    %esi,%edx
  802071:	f7 34 24             	divl   (%esp)
  802074:	89 d6                	mov    %edx,%esi
  802076:	d3 e3                	shl    %cl,%ebx
  802078:	f7 64 24 04          	mull   0x4(%esp)
  80207c:	39 d6                	cmp    %edx,%esi
  80207e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802082:	89 d1                	mov    %edx,%ecx
  802084:	89 c3                	mov    %eax,%ebx
  802086:	72 08                	jb     802090 <__umoddi3+0x110>
  802088:	75 11                	jne    80209b <__umoddi3+0x11b>
  80208a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80208e:	73 0b                	jae    80209b <__umoddi3+0x11b>
  802090:	2b 44 24 04          	sub    0x4(%esp),%eax
  802094:	1b 14 24             	sbb    (%esp),%edx
  802097:	89 d1                	mov    %edx,%ecx
  802099:	89 c3                	mov    %eax,%ebx
  80209b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80209f:	29 da                	sub    %ebx,%edx
  8020a1:	19 ce                	sbb    %ecx,%esi
  8020a3:	89 f9                	mov    %edi,%ecx
  8020a5:	89 f0                	mov    %esi,%eax
  8020a7:	d3 e0                	shl    %cl,%eax
  8020a9:	89 e9                	mov    %ebp,%ecx
  8020ab:	d3 ea                	shr    %cl,%edx
  8020ad:	89 e9                	mov    %ebp,%ecx
  8020af:	d3 ee                	shr    %cl,%esi
  8020b1:	09 d0                	or     %edx,%eax
  8020b3:	89 f2                	mov    %esi,%edx
  8020b5:	83 c4 1c             	add    $0x1c,%esp
  8020b8:	5b                   	pop    %ebx
  8020b9:	5e                   	pop    %esi
  8020ba:	5f                   	pop    %edi
  8020bb:	5d                   	pop    %ebp
  8020bc:	c3                   	ret    
  8020bd:	8d 76 00             	lea    0x0(%esi),%esi
  8020c0:	29 f9                	sub    %edi,%ecx
  8020c2:	19 d6                	sbb    %edx,%esi
  8020c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020cc:	e9 18 ff ff ff       	jmp    801fe9 <__umoddi3+0x69>
