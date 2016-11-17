
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 d2 14 00 00       	call   801523 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 20 23 80 00       	push   $0x802320
  80006d:	6a 15                	push   $0x15
  80006f:	68 4f 23 80 00       	push   $0x80234f
  800074:	e8 17 02 00 00       	call   800290 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 61 23 80 00       	push   $0x802361
  800084:	e8 e0 02 00 00       	call   800369 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 da 1a 00 00       	call   801b6b <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 65 23 80 00       	push   $0x802365
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 4f 23 80 00       	push   $0x80234f
  8000a8:	e8 e3 01 00 00       	call   800290 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 20 0f 00 00       	call   800fd2 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 21 28 80 00       	push   $0x802821
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 4f 23 80 00       	push   $0x80234f
  8000c3:	e8 c8 01 00 00       	call   800290 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 81 12 00 00       	call   801356 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 76 12 00 00       	call   801356 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 60 12 00 00       	call   801356 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 18 14 00 00       	call   801523 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 6e 23 80 00       	push   $0x80236e
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 4f 23 80 00       	push   $0x80234f
  800132:	e8 59 01 00 00       	call   800290 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 1e 14 00 00       	call   80156c <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 8a 23 80 00       	push   $0x80238a
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 4f 23 80 00       	push   $0x80234f
  800174:	e8 17 01 00 00       	call   800290 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 a4 	movl   $0x8023a4,0x803000
  800187:	23 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 d8 19 00 00       	call   801b6b <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 65 23 80 00       	push   $0x802365
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 4f 23 80 00       	push   $0x80234f
  8001aa:	e8 e1 00 00 00       	call   800290 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 1e 0e 00 00       	call   800fd2 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 21 28 80 00       	push   $0x802821
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 4f 23 80 00       	push   $0x80234f
  8001c5:	e8 c6 00 00 00       	call   800290 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 7d 11 00 00       	call   801356 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 67 11 00 00       	call   801356 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 62 13 00 00       	call   80156c <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 af 23 80 00       	push   $0x8023af
  800226:	6a 4a                	push   $0x4a
  800228:	68 4f 23 80 00       	push   $0x80234f
  80022d:	e8 5e 00 00 00       	call   800290 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  800243:	e8 6b 0a 00 00       	call   800cb3 <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800284:	6a 00                	push   $0x0
  800286:	e8 e7 09 00 00       	call   800c72 <sys_env_destroy>
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800295:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800298:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80029e:	e8 10 0a 00 00       	call   800cb3 <sys_getenvid>
  8002a3:	83 ec 0c             	sub    $0xc,%esp
  8002a6:	ff 75 0c             	pushl  0xc(%ebp)
  8002a9:	ff 75 08             	pushl  0x8(%ebp)
  8002ac:	56                   	push   %esi
  8002ad:	50                   	push   %eax
  8002ae:	68 d4 23 80 00       	push   $0x8023d4
  8002b3:	e8 b1 00 00 00       	call   800369 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b8:	83 c4 18             	add    $0x18,%esp
  8002bb:	53                   	push   %ebx
  8002bc:	ff 75 10             	pushl  0x10(%ebp)
  8002bf:	e8 54 00 00 00       	call   800318 <vcprintf>
	cprintf("\n");
  8002c4:	c7 04 24 63 23 80 00 	movl   $0x802363,(%esp)
  8002cb:	e8 99 00 00 00       	call   800369 <cprintf>
  8002d0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d3:	cc                   	int3   
  8002d4:	eb fd                	jmp    8002d3 <_panic+0x43>

008002d6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 04             	sub    $0x4,%esp
  8002dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e0:	8b 13                	mov    (%ebx),%edx
  8002e2:	8d 42 01             	lea    0x1(%edx),%eax
  8002e5:	89 03                	mov    %eax,(%ebx)
  8002e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f3:	75 1a                	jne    80030f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002f5:	83 ec 08             	sub    $0x8,%esp
  8002f8:	68 ff 00 00 00       	push   $0xff
  8002fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800300:	50                   	push   %eax
  800301:	e8 2f 09 00 00       	call   800c35 <sys_cputs>
		b->idx = 0;
  800306:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80030c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80030f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800313:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800321:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800328:	00 00 00 
	b.cnt = 0;
  80032b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800332:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800335:	ff 75 0c             	pushl  0xc(%ebp)
  800338:	ff 75 08             	pushl  0x8(%ebp)
  80033b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800341:	50                   	push   %eax
  800342:	68 d6 02 80 00       	push   $0x8002d6
  800347:	e8 54 01 00 00       	call   8004a0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80034c:	83 c4 08             	add    $0x8,%esp
  80034f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800355:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80035b:	50                   	push   %eax
  80035c:	e8 d4 08 00 00       	call   800c35 <sys_cputs>

	return b.cnt;
}
  800361:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80036f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800372:	50                   	push   %eax
  800373:	ff 75 08             	pushl  0x8(%ebp)
  800376:	e8 9d ff ff ff       	call   800318 <vcprintf>
	va_end(ap);

	return cnt;
}
  80037b:	c9                   	leave  
  80037c:	c3                   	ret    

0080037d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	57                   	push   %edi
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
  800383:	83 ec 1c             	sub    $0x1c,%esp
  800386:	89 c7                	mov    %eax,%edi
  800388:	89 d6                	mov    %edx,%esi
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800390:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800393:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800396:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800399:	bb 00 00 00 00       	mov    $0x0,%ebx
  80039e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003a4:	39 d3                	cmp    %edx,%ebx
  8003a6:	72 05                	jb     8003ad <printnum+0x30>
  8003a8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ab:	77 45                	ja     8003f2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ad:	83 ec 0c             	sub    $0xc,%esp
  8003b0:	ff 75 18             	pushl  0x18(%ebp)
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003b9:	53                   	push   %ebx
  8003ba:	ff 75 10             	pushl  0x10(%ebp)
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cc:	e8 bf 1c 00 00       	call   802090 <__udivdi3>
  8003d1:	83 c4 18             	add    $0x18,%esp
  8003d4:	52                   	push   %edx
  8003d5:	50                   	push   %eax
  8003d6:	89 f2                	mov    %esi,%edx
  8003d8:	89 f8                	mov    %edi,%eax
  8003da:	e8 9e ff ff ff       	call   80037d <printnum>
  8003df:	83 c4 20             	add    $0x20,%esp
  8003e2:	eb 18                	jmp    8003fc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003e4:	83 ec 08             	sub    $0x8,%esp
  8003e7:	56                   	push   %esi
  8003e8:	ff 75 18             	pushl  0x18(%ebp)
  8003eb:	ff d7                	call   *%edi
  8003ed:	83 c4 10             	add    $0x10,%esp
  8003f0:	eb 03                	jmp    8003f5 <printnum+0x78>
  8003f2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003f5:	83 eb 01             	sub    $0x1,%ebx
  8003f8:	85 db                	test   %ebx,%ebx
  8003fa:	7f e8                	jg     8003e4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003fc:	83 ec 08             	sub    $0x8,%esp
  8003ff:	56                   	push   %esi
  800400:	83 ec 04             	sub    $0x4,%esp
  800403:	ff 75 e4             	pushl  -0x1c(%ebp)
  800406:	ff 75 e0             	pushl  -0x20(%ebp)
  800409:	ff 75 dc             	pushl  -0x24(%ebp)
  80040c:	ff 75 d8             	pushl  -0x28(%ebp)
  80040f:	e8 ac 1d 00 00       	call   8021c0 <__umoddi3>
  800414:	83 c4 14             	add    $0x14,%esp
  800417:	0f be 80 f7 23 80 00 	movsbl 0x8023f7(%eax),%eax
  80041e:	50                   	push   %eax
  80041f:	ff d7                	call   *%edi
}
  800421:	83 c4 10             	add    $0x10,%esp
  800424:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800427:	5b                   	pop    %ebx
  800428:	5e                   	pop    %esi
  800429:	5f                   	pop    %edi
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80042f:	83 fa 01             	cmp    $0x1,%edx
  800432:	7e 0e                	jle    800442 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 4a 08             	lea    0x8(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	8b 52 04             	mov    0x4(%edx),%edx
  800440:	eb 22                	jmp    800464 <getuint+0x38>
	else if (lflag)
  800442:	85 d2                	test   %edx,%edx
  800444:	74 10                	je     800456 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800446:	8b 10                	mov    (%eax),%edx
  800448:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044b:	89 08                	mov    %ecx,(%eax)
  80044d:	8b 02                	mov    (%edx),%eax
  80044f:	ba 00 00 00 00       	mov    $0x0,%edx
  800454:	eb 0e                	jmp    800464 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800456:	8b 10                	mov    (%eax),%edx
  800458:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045b:	89 08                	mov    %ecx,(%eax)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800470:	8b 10                	mov    (%eax),%edx
  800472:	3b 50 04             	cmp    0x4(%eax),%edx
  800475:	73 0a                	jae    800481 <sprintputch+0x1b>
		*b->buf++ = ch;
  800477:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047a:	89 08                	mov    %ecx,(%eax)
  80047c:	8b 45 08             	mov    0x8(%ebp),%eax
  80047f:	88 02                	mov    %al,(%edx)
}
  800481:	5d                   	pop    %ebp
  800482:	c3                   	ret    

00800483 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800483:	55                   	push   %ebp
  800484:	89 e5                	mov    %esp,%ebp
  800486:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800489:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80048c:	50                   	push   %eax
  80048d:	ff 75 10             	pushl  0x10(%ebp)
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	ff 75 08             	pushl  0x8(%ebp)
  800496:	e8 05 00 00 00       	call   8004a0 <vprintfmt>
	va_end(ap);
}
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	c9                   	leave  
  80049f:	c3                   	ret    

008004a0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 2c             	sub    $0x2c,%esp
  8004a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004af:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004b2:	eb 12                	jmp    8004c6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b4:	85 c0                	test   %eax,%eax
  8004b6:	0f 84 89 03 00 00    	je     800845 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	53                   	push   %ebx
  8004c0:	50                   	push   %eax
  8004c1:	ff d6                	call   *%esi
  8004c3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c6:	83 c7 01             	add    $0x1,%edi
  8004c9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cd:	83 f8 25             	cmp    $0x25,%eax
  8004d0:	75 e2                	jne    8004b4 <vprintfmt+0x14>
  8004d2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004d6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004e4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f0:	eb 07                	jmp    8004f9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8d 47 01             	lea    0x1(%edi),%eax
  8004fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ff:	0f b6 07             	movzbl (%edi),%eax
  800502:	0f b6 c8             	movzbl %al,%ecx
  800505:	83 e8 23             	sub    $0x23,%eax
  800508:	3c 55                	cmp    $0x55,%al
  80050a:	0f 87 1a 03 00 00    	ja     80082a <vprintfmt+0x38a>
  800510:	0f b6 c0             	movzbl %al,%eax
  800513:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80051d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800521:	eb d6                	jmp    8004f9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800526:	b8 00 00 00 00       	mov    $0x0,%eax
  80052b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80052e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800531:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800535:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800538:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80053b:	83 fa 09             	cmp    $0x9,%edx
  80053e:	77 39                	ja     800579 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800540:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800543:	eb e9                	jmp    80052e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 48 04             	lea    0x4(%eax),%ecx
  80054b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800556:	eb 27                	jmp    80057f <vprintfmt+0xdf>
  800558:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055b:	85 c0                	test   %eax,%eax
  80055d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800562:	0f 49 c8             	cmovns %eax,%ecx
  800565:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056b:	eb 8c                	jmp    8004f9 <vprintfmt+0x59>
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800570:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800577:	eb 80                	jmp    8004f9 <vprintfmt+0x59>
  800579:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80057c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80057f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800583:	0f 89 70 ff ff ff    	jns    8004f9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800589:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80058c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800596:	e9 5e ff ff ff       	jmp    8004f9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80059b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a1:	e9 53 ff ff ff       	jmp    8004f9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	ff 30                	pushl  (%eax)
  8005b5:	ff d6                	call   *%esi
			break;
  8005b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005bd:	e9 04 ff ff ff       	jmp    8004c6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	99                   	cltd   
  8005ce:	31 d0                	xor    %edx,%eax
  8005d0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d2:	83 f8 0f             	cmp    $0xf,%eax
  8005d5:	7f 0b                	jg     8005e2 <vprintfmt+0x142>
  8005d7:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	75 18                	jne    8005fa <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005e2:	50                   	push   %eax
  8005e3:	68 0f 24 80 00       	push   $0x80240f
  8005e8:	53                   	push   %ebx
  8005e9:	56                   	push   %esi
  8005ea:	e8 94 fe ff ff       	call   800483 <printfmt>
  8005ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005f5:	e9 cc fe ff ff       	jmp    8004c6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005fa:	52                   	push   %edx
  8005fb:	68 6a 29 80 00       	push   $0x80296a
  800600:	53                   	push   %ebx
  800601:	56                   	push   %esi
  800602:	e8 7c fe ff ff       	call   800483 <printfmt>
  800607:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060d:	e9 b4 fe ff ff       	jmp    8004c6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80061d:	85 ff                	test   %edi,%edi
  80061f:	b8 08 24 80 00       	mov    $0x802408,%eax
  800624:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800627:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80062b:	0f 8e 94 00 00 00    	jle    8006c5 <vprintfmt+0x225>
  800631:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800635:	0f 84 98 00 00 00    	je     8006d3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 d0             	pushl  -0x30(%ebp)
  800641:	57                   	push   %edi
  800642:	e8 86 02 00 00       	call   8008cd <strnlen>
  800647:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80064a:	29 c1                	sub    %eax,%ecx
  80064c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80064f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800652:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800656:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800659:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80065c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065e:	eb 0f                	jmp    80066f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	ff 75 e0             	pushl  -0x20(%ebp)
  800667:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800669:	83 ef 01             	sub    $0x1,%edi
  80066c:	83 c4 10             	add    $0x10,%esp
  80066f:	85 ff                	test   %edi,%edi
  800671:	7f ed                	jg     800660 <vprintfmt+0x1c0>
  800673:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800676:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800679:	85 c9                	test   %ecx,%ecx
  80067b:	b8 00 00 00 00       	mov    $0x0,%eax
  800680:	0f 49 c1             	cmovns %ecx,%eax
  800683:	29 c1                	sub    %eax,%ecx
  800685:	89 75 08             	mov    %esi,0x8(%ebp)
  800688:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80068e:	89 cb                	mov    %ecx,%ebx
  800690:	eb 4d                	jmp    8006df <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800692:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800696:	74 1b                	je     8006b3 <vprintfmt+0x213>
  800698:	0f be c0             	movsbl %al,%eax
  80069b:	83 e8 20             	sub    $0x20,%eax
  80069e:	83 f8 5e             	cmp    $0x5e,%eax
  8006a1:	76 10                	jbe    8006b3 <vprintfmt+0x213>
					putch('?', putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	ff 75 0c             	pushl  0xc(%ebp)
  8006a9:	6a 3f                	push   $0x3f
  8006ab:	ff 55 08             	call   *0x8(%ebp)
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	eb 0d                	jmp    8006c0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	ff 75 0c             	pushl  0xc(%ebp)
  8006b9:	52                   	push   %edx
  8006ba:	ff 55 08             	call   *0x8(%ebp)
  8006bd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c0:	83 eb 01             	sub    $0x1,%ebx
  8006c3:	eb 1a                	jmp    8006df <vprintfmt+0x23f>
  8006c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d1:	eb 0c                	jmp    8006df <vprintfmt+0x23f>
  8006d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006df:	83 c7 01             	add    $0x1,%edi
  8006e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e6:	0f be d0             	movsbl %al,%edx
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	74 23                	je     800710 <vprintfmt+0x270>
  8006ed:	85 f6                	test   %esi,%esi
  8006ef:	78 a1                	js     800692 <vprintfmt+0x1f2>
  8006f1:	83 ee 01             	sub    $0x1,%esi
  8006f4:	79 9c                	jns    800692 <vprintfmt+0x1f2>
  8006f6:	89 df                	mov    %ebx,%edi
  8006f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fe:	eb 18                	jmp    800718 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	6a 20                	push   $0x20
  800706:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800708:	83 ef 01             	sub    $0x1,%edi
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	eb 08                	jmp    800718 <vprintfmt+0x278>
  800710:	89 df                	mov    %ebx,%edi
  800712:	8b 75 08             	mov    0x8(%ebp),%esi
  800715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800718:	85 ff                	test   %edi,%edi
  80071a:	7f e4                	jg     800700 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071f:	e9 a2 fd ff ff       	jmp    8004c6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800724:	83 fa 01             	cmp    $0x1,%edx
  800727:	7e 16                	jle    80073f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8d 50 08             	lea    0x8(%eax),%edx
  80072f:	89 55 14             	mov    %edx,0x14(%ebp)
  800732:	8b 50 04             	mov    0x4(%eax),%edx
  800735:	8b 00                	mov    (%eax),%eax
  800737:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80073d:	eb 32                	jmp    800771 <vprintfmt+0x2d1>
	else if (lflag)
  80073f:	85 d2                	test   %edx,%edx
  800741:	74 18                	je     80075b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8d 50 04             	lea    0x4(%eax),%edx
  800749:	89 55 14             	mov    %edx,0x14(%ebp)
  80074c:	8b 00                	mov    (%eax),%eax
  80074e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800751:	89 c1                	mov    %eax,%ecx
  800753:	c1 f9 1f             	sar    $0x1f,%ecx
  800756:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800759:	eb 16                	jmp    800771 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 50 04             	lea    0x4(%eax),%edx
  800761:	89 55 14             	mov    %edx,0x14(%ebp)
  800764:	8b 00                	mov    (%eax),%eax
  800766:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800769:	89 c1                	mov    %eax,%ecx
  80076b:	c1 f9 1f             	sar    $0x1f,%ecx
  80076e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800771:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800774:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800777:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80077c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800780:	79 74                	jns    8007f6 <vprintfmt+0x356>
				putch('-', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	53                   	push   %ebx
  800786:	6a 2d                	push   $0x2d
  800788:	ff d6                	call   *%esi
				num = -(long long) num;
  80078a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80078d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800790:	f7 d8                	neg    %eax
  800792:	83 d2 00             	adc    $0x0,%edx
  800795:	f7 da                	neg    %edx
  800797:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80079a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80079f:	eb 55                	jmp    8007f6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a4:	e8 83 fc ff ff       	call   80042c <getuint>
			base = 10;
  8007a9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007ae:	eb 46                	jmp    8007f6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b3:	e8 74 fc ff ff       	call   80042c <getuint>
			base = 8;
  8007b8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007bd:	eb 37                	jmp    8007f6 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	6a 30                	push   $0x30
  8007c5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007c7:	83 c4 08             	add    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 78                	push   $0x78
  8007cd:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 50 04             	lea    0x4(%eax),%edx
  8007d5:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007d8:	8b 00                	mov    (%eax),%eax
  8007da:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007df:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007e2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007e7:	eb 0d                	jmp    8007f6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ec:	e8 3b fc ff ff       	call   80042c <getuint>
			base = 16;
  8007f1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f6:	83 ec 0c             	sub    $0xc,%esp
  8007f9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007fd:	57                   	push   %edi
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	51                   	push   %ecx
  800802:	52                   	push   %edx
  800803:	50                   	push   %eax
  800804:	89 da                	mov    %ebx,%edx
  800806:	89 f0                	mov    %esi,%eax
  800808:	e8 70 fb ff ff       	call   80037d <printnum>
			break;
  80080d:	83 c4 20             	add    $0x20,%esp
  800810:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800813:	e9 ae fc ff ff       	jmp    8004c6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	51                   	push   %ecx
  80081d:	ff d6                	call   *%esi
			break;
  80081f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800822:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800825:	e9 9c fc ff ff       	jmp    8004c6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	53                   	push   %ebx
  80082e:	6a 25                	push   $0x25
  800830:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	eb 03                	jmp    80083a <vprintfmt+0x39a>
  800837:	83 ef 01             	sub    $0x1,%edi
  80083a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80083e:	75 f7                	jne    800837 <vprintfmt+0x397>
  800840:	e9 81 fc ff ff       	jmp    8004c6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800845:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5f                   	pop    %edi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	83 ec 18             	sub    $0x18,%esp
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800859:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800860:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800863:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086a:	85 c0                	test   %eax,%eax
  80086c:	74 26                	je     800894 <vsnprintf+0x47>
  80086e:	85 d2                	test   %edx,%edx
  800870:	7e 22                	jle    800894 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800872:	ff 75 14             	pushl  0x14(%ebp)
  800875:	ff 75 10             	pushl  0x10(%ebp)
  800878:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087b:	50                   	push   %eax
  80087c:	68 66 04 80 00       	push   $0x800466
  800881:	e8 1a fc ff ff       	call   8004a0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800886:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800889:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	eb 05                	jmp    800899 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800894:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a4:	50                   	push   %eax
  8008a5:	ff 75 10             	pushl  0x10(%ebp)
  8008a8:	ff 75 0c             	pushl  0xc(%ebp)
  8008ab:	ff 75 08             	pushl  0x8(%ebp)
  8008ae:	e8 9a ff ff ff       	call   80084d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c0:	eb 03                	jmp    8008c5 <strlen+0x10>
		n++;
  8008c2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c9:	75 f7                	jne    8008c2 <strlen+0xd>
		n++;
	return n;
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8008db:	eb 03                	jmp    8008e0 <strnlen+0x13>
		n++;
  8008dd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e0:	39 c2                	cmp    %eax,%edx
  8008e2:	74 08                	je     8008ec <strnlen+0x1f>
  8008e4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008e8:	75 f3                	jne    8008dd <strnlen+0x10>
  8008ea:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	53                   	push   %ebx
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f8:	89 c2                	mov    %eax,%edx
  8008fa:	83 c2 01             	add    $0x1,%edx
  8008fd:	83 c1 01             	add    $0x1,%ecx
  800900:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800904:	88 5a ff             	mov    %bl,-0x1(%edx)
  800907:	84 db                	test   %bl,%bl
  800909:	75 ef                	jne    8008fa <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090b:	5b                   	pop    %ebx
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	53                   	push   %ebx
  800912:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800915:	53                   	push   %ebx
  800916:	e8 9a ff ff ff       	call   8008b5 <strlen>
  80091b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80091e:	ff 75 0c             	pushl  0xc(%ebp)
  800921:	01 d8                	add    %ebx,%eax
  800923:	50                   	push   %eax
  800924:	e8 c5 ff ff ff       	call   8008ee <strcpy>
	return dst;
}
  800929:	89 d8                	mov    %ebx,%eax
  80092b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 75 08             	mov    0x8(%ebp),%esi
  800938:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093b:	89 f3                	mov    %esi,%ebx
  80093d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800940:	89 f2                	mov    %esi,%edx
  800942:	eb 0f                	jmp    800953 <strncpy+0x23>
		*dst++ = *src;
  800944:	83 c2 01             	add    $0x1,%edx
  800947:	0f b6 01             	movzbl (%ecx),%eax
  80094a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094d:	80 39 01             	cmpb   $0x1,(%ecx)
  800950:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800953:	39 da                	cmp    %ebx,%edx
  800955:	75 ed                	jne    800944 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800957:	89 f0                	mov    %esi,%eax
  800959:	5b                   	pop    %ebx
  80095a:	5e                   	pop    %esi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 75 08             	mov    0x8(%ebp),%esi
  800965:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800968:	8b 55 10             	mov    0x10(%ebp),%edx
  80096b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096d:	85 d2                	test   %edx,%edx
  80096f:	74 21                	je     800992 <strlcpy+0x35>
  800971:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800975:	89 f2                	mov    %esi,%edx
  800977:	eb 09                	jmp    800982 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800979:	83 c2 01             	add    $0x1,%edx
  80097c:	83 c1 01             	add    $0x1,%ecx
  80097f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800982:	39 c2                	cmp    %eax,%edx
  800984:	74 09                	je     80098f <strlcpy+0x32>
  800986:	0f b6 19             	movzbl (%ecx),%ebx
  800989:	84 db                	test   %bl,%bl
  80098b:	75 ec                	jne    800979 <strlcpy+0x1c>
  80098d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80098f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800992:	29 f0                	sub    %esi,%eax
}
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a1:	eb 06                	jmp    8009a9 <strcmp+0x11>
		p++, q++;
  8009a3:	83 c1 01             	add    $0x1,%ecx
  8009a6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a9:	0f b6 01             	movzbl (%ecx),%eax
  8009ac:	84 c0                	test   %al,%al
  8009ae:	74 04                	je     8009b4 <strcmp+0x1c>
  8009b0:	3a 02                	cmp    (%edx),%al
  8009b2:	74 ef                	je     8009a3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b4:	0f b6 c0             	movzbl %al,%eax
  8009b7:	0f b6 12             	movzbl (%edx),%edx
  8009ba:	29 d0                	sub    %edx,%eax
}
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	53                   	push   %ebx
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c8:	89 c3                	mov    %eax,%ebx
  8009ca:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cd:	eb 06                	jmp    8009d5 <strncmp+0x17>
		n--, p++, q++;
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d5:	39 d8                	cmp    %ebx,%eax
  8009d7:	74 15                	je     8009ee <strncmp+0x30>
  8009d9:	0f b6 08             	movzbl (%eax),%ecx
  8009dc:	84 c9                	test   %cl,%cl
  8009de:	74 04                	je     8009e4 <strncmp+0x26>
  8009e0:	3a 0a                	cmp    (%edx),%cl
  8009e2:	74 eb                	je     8009cf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e4:	0f b6 00             	movzbl (%eax),%eax
  8009e7:	0f b6 12             	movzbl (%edx),%edx
  8009ea:	29 d0                	sub    %edx,%eax
  8009ec:	eb 05                	jmp    8009f3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a00:	eb 07                	jmp    800a09 <strchr+0x13>
		if (*s == c)
  800a02:	38 ca                	cmp    %cl,%dl
  800a04:	74 0f                	je     800a15 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	0f b6 10             	movzbl (%eax),%edx
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	75 f2                	jne    800a02 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a21:	eb 03                	jmp    800a26 <strfind+0xf>
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a29:	38 ca                	cmp    %cl,%dl
  800a2b:	74 04                	je     800a31 <strfind+0x1a>
  800a2d:	84 d2                	test   %dl,%dl
  800a2f:	75 f2                	jne    800a23 <strfind+0xc>
			break;
	return (char *) s;
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3f:	85 c9                	test   %ecx,%ecx
  800a41:	74 36                	je     800a79 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a43:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a49:	75 28                	jne    800a73 <memset+0x40>
  800a4b:	f6 c1 03             	test   $0x3,%cl
  800a4e:	75 23                	jne    800a73 <memset+0x40>
		c &= 0xFF;
  800a50:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a54:	89 d3                	mov    %edx,%ebx
  800a56:	c1 e3 08             	shl    $0x8,%ebx
  800a59:	89 d6                	mov    %edx,%esi
  800a5b:	c1 e6 18             	shl    $0x18,%esi
  800a5e:	89 d0                	mov    %edx,%eax
  800a60:	c1 e0 10             	shl    $0x10,%eax
  800a63:	09 f0                	or     %esi,%eax
  800a65:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a67:	89 d8                	mov    %ebx,%eax
  800a69:	09 d0                	or     %edx,%eax
  800a6b:	c1 e9 02             	shr    $0x2,%ecx
  800a6e:	fc                   	cld    
  800a6f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a71:	eb 06                	jmp    800a79 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	fc                   	cld    
  800a77:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a79:	89 f8                	mov    %edi,%eax
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8e:	39 c6                	cmp    %eax,%esi
  800a90:	73 35                	jae    800ac7 <memmove+0x47>
  800a92:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a95:	39 d0                	cmp    %edx,%eax
  800a97:	73 2e                	jae    800ac7 <memmove+0x47>
		s += n;
		d += n;
  800a99:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9c:	89 d6                	mov    %edx,%esi
  800a9e:	09 fe                	or     %edi,%esi
  800aa0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa6:	75 13                	jne    800abb <memmove+0x3b>
  800aa8:	f6 c1 03             	test   $0x3,%cl
  800aab:	75 0e                	jne    800abb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aad:	83 ef 04             	sub    $0x4,%edi
  800ab0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab3:	c1 e9 02             	shr    $0x2,%ecx
  800ab6:	fd                   	std    
  800ab7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab9:	eb 09                	jmp    800ac4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800abb:	83 ef 01             	sub    $0x1,%edi
  800abe:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac1:	fd                   	std    
  800ac2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac4:	fc                   	cld    
  800ac5:	eb 1d                	jmp    800ae4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac7:	89 f2                	mov    %esi,%edx
  800ac9:	09 c2                	or     %eax,%edx
  800acb:	f6 c2 03             	test   $0x3,%dl
  800ace:	75 0f                	jne    800adf <memmove+0x5f>
  800ad0:	f6 c1 03             	test   $0x3,%cl
  800ad3:	75 0a                	jne    800adf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ad5:	c1 e9 02             	shr    $0x2,%ecx
  800ad8:	89 c7                	mov    %eax,%edi
  800ada:	fc                   	cld    
  800adb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800add:	eb 05                	jmp    800ae4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	fc                   	cld    
  800ae2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aeb:	ff 75 10             	pushl  0x10(%ebp)
  800aee:	ff 75 0c             	pushl  0xc(%ebp)
  800af1:	ff 75 08             	pushl  0x8(%ebp)
  800af4:	e8 87 ff ff ff       	call   800a80 <memmove>
}
  800af9:	c9                   	leave  
  800afa:	c3                   	ret    

00800afb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b06:	89 c6                	mov    %eax,%esi
  800b08:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0b:	eb 1a                	jmp    800b27 <memcmp+0x2c>
		if (*s1 != *s2)
  800b0d:	0f b6 08             	movzbl (%eax),%ecx
  800b10:	0f b6 1a             	movzbl (%edx),%ebx
  800b13:	38 d9                	cmp    %bl,%cl
  800b15:	74 0a                	je     800b21 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b17:	0f b6 c1             	movzbl %cl,%eax
  800b1a:	0f b6 db             	movzbl %bl,%ebx
  800b1d:	29 d8                	sub    %ebx,%eax
  800b1f:	eb 0f                	jmp    800b30 <memcmp+0x35>
		s1++, s2++;
  800b21:	83 c0 01             	add    $0x1,%eax
  800b24:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b27:	39 f0                	cmp    %esi,%eax
  800b29:	75 e2                	jne    800b0d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	53                   	push   %ebx
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b3b:	89 c1                	mov    %eax,%ecx
  800b3d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b40:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b44:	eb 0a                	jmp    800b50 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b46:	0f b6 10             	movzbl (%eax),%edx
  800b49:	39 da                	cmp    %ebx,%edx
  800b4b:	74 07                	je     800b54 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4d:	83 c0 01             	add    $0x1,%eax
  800b50:	39 c8                	cmp    %ecx,%eax
  800b52:	72 f2                	jb     800b46 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b54:	5b                   	pop    %ebx
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b63:	eb 03                	jmp    800b68 <strtol+0x11>
		s++;
  800b65:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b68:	0f b6 01             	movzbl (%ecx),%eax
  800b6b:	3c 20                	cmp    $0x20,%al
  800b6d:	74 f6                	je     800b65 <strtol+0xe>
  800b6f:	3c 09                	cmp    $0x9,%al
  800b71:	74 f2                	je     800b65 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b73:	3c 2b                	cmp    $0x2b,%al
  800b75:	75 0a                	jne    800b81 <strtol+0x2a>
		s++;
  800b77:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7f:	eb 11                	jmp    800b92 <strtol+0x3b>
  800b81:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b86:	3c 2d                	cmp    $0x2d,%al
  800b88:	75 08                	jne    800b92 <strtol+0x3b>
		s++, neg = 1;
  800b8a:	83 c1 01             	add    $0x1,%ecx
  800b8d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b98:	75 15                	jne    800baf <strtol+0x58>
  800b9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9d:	75 10                	jne    800baf <strtol+0x58>
  800b9f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba3:	75 7c                	jne    800c21 <strtol+0xca>
		s += 2, base = 16;
  800ba5:	83 c1 02             	add    $0x2,%ecx
  800ba8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bad:	eb 16                	jmp    800bc5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800baf:	85 db                	test   %ebx,%ebx
  800bb1:	75 12                	jne    800bc5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb8:	80 39 30             	cmpb   $0x30,(%ecx)
  800bbb:	75 08                	jne    800bc5 <strtol+0x6e>
		s++, base = 8;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bcd:	0f b6 11             	movzbl (%ecx),%edx
  800bd0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bd3:	89 f3                	mov    %esi,%ebx
  800bd5:	80 fb 09             	cmp    $0x9,%bl
  800bd8:	77 08                	ja     800be2 <strtol+0x8b>
			dig = *s - '0';
  800bda:	0f be d2             	movsbl %dl,%edx
  800bdd:	83 ea 30             	sub    $0x30,%edx
  800be0:	eb 22                	jmp    800c04 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800be2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be5:	89 f3                	mov    %esi,%ebx
  800be7:	80 fb 19             	cmp    $0x19,%bl
  800bea:	77 08                	ja     800bf4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bec:	0f be d2             	movsbl %dl,%edx
  800bef:	83 ea 57             	sub    $0x57,%edx
  800bf2:	eb 10                	jmp    800c04 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bf4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf7:	89 f3                	mov    %esi,%ebx
  800bf9:	80 fb 19             	cmp    $0x19,%bl
  800bfc:	77 16                	ja     800c14 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bfe:	0f be d2             	movsbl %dl,%edx
  800c01:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c04:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c07:	7d 0b                	jge    800c14 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c09:	83 c1 01             	add    $0x1,%ecx
  800c0c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c10:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c12:	eb b9                	jmp    800bcd <strtol+0x76>

	if (endptr)
  800c14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c18:	74 0d                	je     800c27 <strtol+0xd0>
		*endptr = (char *) s;
  800c1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1d:	89 0e                	mov    %ecx,(%esi)
  800c1f:	eb 06                	jmp    800c27 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c21:	85 db                	test   %ebx,%ebx
  800c23:	74 98                	je     800bbd <strtol+0x66>
  800c25:	eb 9e                	jmp    800bc5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c27:	89 c2                	mov    %eax,%edx
  800c29:	f7 da                	neg    %edx
  800c2b:	85 ff                	test   %edi,%edi
  800c2d:	0f 45 c2             	cmovne %edx,%eax
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	89 c3                	mov    %eax,%ebx
  800c48:	89 c7                	mov    %eax,%edi
  800c4a:	89 c6                	mov    %eax,%esi
  800c4c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c59:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c63:	89 d1                	mov    %edx,%ecx
  800c65:	89 d3                	mov    %edx,%ebx
  800c67:	89 d7                	mov    %edx,%edi
  800c69:	89 d6                	mov    %edx,%esi
  800c6b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c80:	b8 03 00 00 00       	mov    $0x3,%eax
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	89 cb                	mov    %ecx,%ebx
  800c8a:	89 cf                	mov    %ecx,%edi
  800c8c:	89 ce                	mov    %ecx,%esi
  800c8e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c90:	85 c0                	test   %eax,%eax
  800c92:	7e 17                	jle    800cab <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 03                	push   $0x3
  800c9a:	68 ff 26 80 00       	push   $0x8026ff
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 1c 27 80 00       	push   $0x80271c
  800ca6:	e8 e5 f5 ff ff       	call   800290 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbe:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc3:	89 d1                	mov    %edx,%ecx
  800cc5:	89 d3                	mov    %edx,%ebx
  800cc7:	89 d7                	mov    %edx,%edi
  800cc9:	89 d6                	mov    %edx,%esi
  800ccb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_yield>:

void
sys_yield(void)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce2:	89 d1                	mov    %edx,%ecx
  800ce4:	89 d3                	mov    %edx,%ebx
  800ce6:	89 d7                	mov    %edx,%edi
  800ce8:	89 d6                	mov    %edx,%esi
  800cea:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	be 00 00 00 00       	mov    $0x0,%esi
  800cff:	b8 04 00 00 00       	mov    $0x4,%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0d:	89 f7                	mov    %esi,%edi
  800d0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 17                	jle    800d2c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 04                	push   $0x4
  800d1b:	68 ff 26 80 00       	push   $0x8026ff
  800d20:	6a 23                	push   $0x23
  800d22:	68 1c 27 80 00       	push   $0x80271c
  800d27:	e8 64 f5 ff ff       	call   800290 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	8b 55 08             	mov    0x8(%ebp),%edx
  800d48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4e:	8b 75 18             	mov    0x18(%ebp),%esi
  800d51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 17                	jle    800d6e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	50                   	push   %eax
  800d5b:	6a 05                	push   $0x5
  800d5d:	68 ff 26 80 00       	push   $0x8026ff
  800d62:	6a 23                	push   $0x23
  800d64:	68 1c 27 80 00       	push   $0x80271c
  800d69:	e8 22 f5 ff ff       	call   800290 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d84:	b8 06 00 00 00       	mov    $0x6,%eax
  800d89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	89 df                	mov    %ebx,%edi
  800d91:	89 de                	mov    %ebx,%esi
  800d93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7e 17                	jle    800db0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	50                   	push   %eax
  800d9d:	6a 06                	push   $0x6
  800d9f:	68 ff 26 80 00       	push   $0x8026ff
  800da4:	6a 23                	push   $0x23
  800da6:	68 1c 27 80 00       	push   $0x80271c
  800dab:	e8 e0 f4 ff ff       	call   800290 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc6:	b8 08 00 00 00       	mov    $0x8,%eax
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 df                	mov    %ebx,%edi
  800dd3:	89 de                	mov    %ebx,%esi
  800dd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	7e 17                	jle    800df2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	50                   	push   %eax
  800ddf:	6a 08                	push   $0x8
  800de1:	68 ff 26 80 00       	push   $0x8026ff
  800de6:	6a 23                	push   $0x23
  800de8:	68 1c 27 80 00       	push   $0x80271c
  800ded:	e8 9e f4 ff ff       	call   800290 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	89 df                	mov    %ebx,%edi
  800e15:	89 de                	mov    %ebx,%esi
  800e17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 17                	jle    800e34 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	50                   	push   %eax
  800e21:	6a 09                	push   $0x9
  800e23:	68 ff 26 80 00       	push   $0x8026ff
  800e28:	6a 23                	push   $0x23
  800e2a:	68 1c 27 80 00       	push   $0x80271c
  800e2f:	e8 5c f4 ff ff       	call   800290 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e52:	8b 55 08             	mov    0x8(%ebp),%edx
  800e55:	89 df                	mov    %ebx,%edi
  800e57:	89 de                	mov    %ebx,%esi
  800e59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	7e 17                	jle    800e76 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	50                   	push   %eax
  800e63:	6a 0a                	push   $0xa
  800e65:	68 ff 26 80 00       	push   $0x8026ff
  800e6a:	6a 23                	push   $0x23
  800e6c:	68 1c 27 80 00       	push   $0x80271c
  800e71:	e8 1a f4 ff ff       	call   800290 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e79:	5b                   	pop    %ebx
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e84:	be 00 00 00 00       	mov    $0x0,%esi
  800e89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e91:	8b 55 08             	mov    0x8(%ebp),%edx
  800e94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
  800ea7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eaf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	89 cb                	mov    %ecx,%ebx
  800eb9:	89 cf                	mov    %ecx,%edi
  800ebb:	89 ce                	mov    %ecx,%esi
  800ebd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7e 17                	jle    800eda <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	50                   	push   %eax
  800ec7:	6a 0d                	push   $0xd
  800ec9:	68 ff 26 80 00       	push   $0x8026ff
  800ece:	6a 23                	push   $0x23
  800ed0:	68 1c 27 80 00       	push   $0x80271c
  800ed5:	e8 b6 f3 ff ff       	call   800290 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	53                   	push   %ebx
  800ee6:	83 ec 04             	sub    $0x4,%esp
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eec:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800eee:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ef2:	75 14                	jne    800f08 <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800ef4:	83 ec 04             	sub    $0x4,%esp
  800ef7:	68 2c 27 80 00       	push   $0x80272c
  800efc:	6a 22                	push   $0x22
  800efe:	68 0f 28 80 00       	push   $0x80280f
  800f03:	e8 88 f3 ff ff       	call   800290 <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	c1 e8 0c             	shr    $0xc,%eax
  800f0d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f14:	f6 c4 08             	test   $0x8,%ah
  800f17:	75 14                	jne    800f2d <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800f19:	83 ec 04             	sub    $0x4,%esp
  800f1c:	68 68 27 80 00       	push   $0x802768
  800f21:	6a 27                	push   $0x27
  800f23:	68 0f 28 80 00       	push   $0x80280f
  800f28:	e8 63 f3 ff ff       	call   800290 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	6a 07                	push   $0x7
  800f32:	68 00 f0 7f 00       	push   $0x7ff000
  800f37:	6a 00                	push   $0x0
  800f39:	e8 b3 fd ff ff       	call   800cf1 <sys_page_alloc>
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	79 14                	jns    800f59 <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800f45:	83 ec 04             	sub    $0x4,%esp
  800f48:	68 98 27 80 00       	push   $0x802798
  800f4d:	6a 2f                	push   $0x2f
  800f4f:	68 0f 28 80 00       	push   $0x80280f
  800f54:	e8 37 f3 ff ff       	call   800290 <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f59:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	68 00 10 00 00       	push   $0x1000
  800f67:	53                   	push   %ebx
  800f68:	68 00 f0 7f 00       	push   $0x7ff000
  800f6d:	e8 0e fb ff ff       	call   800a80 <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f72:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f79:	53                   	push   %ebx
  800f7a:	6a 00                	push   $0x0
  800f7c:	68 00 f0 7f 00       	push   $0x7ff000
  800f81:	6a 00                	push   $0x0
  800f83:	e8 ac fd ff ff       	call   800d34 <sys_page_map>
  800f88:	83 c4 20             	add    $0x20,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	79 14                	jns    800fa3 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800f8f:	83 ec 04             	sub    $0x4,%esp
  800f92:	68 c4 27 80 00       	push   $0x8027c4
  800f97:	6a 34                	push   $0x34
  800f99:	68 0f 28 80 00       	push   $0x80280f
  800f9e:	e8 ed f2 ff ff       	call   800290 <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fa3:	83 ec 08             	sub    $0x8,%esp
  800fa6:	68 00 f0 7f 00       	push   $0x7ff000
  800fab:	6a 00                	push   $0x0
  800fad:	e8 c4 fd ff ff       	call   800d76 <sys_page_unmap>
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 14                	jns    800fcd <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	68 ec 27 80 00       	push   $0x8027ec
  800fc1:	6a 37                	push   $0x37
  800fc3:	68 0f 28 80 00       	push   $0x80280f
  800fc8:	e8 c3 f2 ff ff       	call   800290 <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800fcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800fdb:	68 e2 0e 80 00       	push   $0x800ee2
  800fe0:	e8 8f 0e 00 00       	call   801e74 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fe5:	b8 07 00 00 00       	mov    $0x7,%eax
  800fea:	cd 30                	int    $0x30
  800fec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 15                	jns    80100b <fork+0x39>
		panic("sys_exofork: %e", envid);
  800ff6:	50                   	push   %eax
  800ff7:	68 1a 28 80 00       	push   $0x80281a
  800ffc:	68 87 00 00 00       	push   $0x87
  801001:	68 0f 28 80 00       	push   $0x80280f
  801006:	e8 85 f2 ff ff       	call   800290 <_panic>
  80100b:	89 c7                	mov    %eax,%edi
  80100d:	be 00 00 00 00       	mov    $0x0,%esi
  801012:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  801017:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80101b:	75 21                	jne    80103e <fork+0x6c>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  80101d:	e8 91 fc ff ff       	call   800cb3 <sys_getenvid>
  801022:	25 ff 03 00 00       	and    $0x3ff,%eax
  801027:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80102a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80102f:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801034:	b8 00 00 00 00       	mov    $0x0,%eax
  801039:	e9 56 01 00 00       	jmp    801194 <fork+0x1c2>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  80103e:	89 f0                	mov    %esi,%eax
  801040:	c1 e8 16             	shr    $0x16,%eax
  801043:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104a:	a8 01                	test   $0x1,%al
  80104c:	0f 84 a5 00 00 00    	je     8010f7 <fork+0x125>
  801052:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801059:	a8 05                	test   $0x5,%al
  80105b:	0f 84 96 00 00 00    	je     8010f7 <fork+0x125>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)))
  801061:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801068:	a8 02                	test   $0x2,%al
  80106a:	75 0c                	jne    801078 <fork+0xa6>
  80106c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801073:	f6 c4 08             	test   $0x8,%ah
  801076:	74 57                	je     8010cf <fork+0xfd>
	{

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm | PTE_COW))) < 0)
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	68 05 08 00 00       	push   $0x805
  801080:	56                   	push   %esi
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	6a 00                	push   $0x0
  801085:	e8 aa fc ff ff       	call   800d34 <sys_page_map>
  80108a:	83 c4 20             	add    $0x20,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 12                	jns    8010a3 <fork+0xd1>
			panic("fork: sys_page_map: %e", r);
  801091:	50                   	push   %eax
  801092:	68 2a 28 80 00       	push   $0x80282a
  801097:	6a 5c                	push   $0x5c
  801099:	68 0f 28 80 00       	push   $0x80280f
  80109e:	e8 ed f1 ff ff       	call   800290 <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm|PTE_COW))) < 0)
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	68 05 08 00 00       	push   $0x805
  8010ab:	56                   	push   %esi
  8010ac:	6a 00                	push   $0x0
  8010ae:	56                   	push   %esi
  8010af:	6a 00                	push   $0x0
  8010b1:	e8 7e fc ff ff       	call   800d34 <sys_page_map>
  8010b6:	83 c4 20             	add    $0x20,%esp
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	79 3a                	jns    8010f7 <fork+0x125>
			panic("fork: sys_page_map: %e", r);
  8010bd:	50                   	push   %eax
  8010be:	68 2a 28 80 00       	push   $0x80282a
  8010c3:	6a 5f                	push   $0x5f
  8010c5:	68 0f 28 80 00       	push   $0x80280f
  8010ca:	e8 c1 f1 ff ff       	call   800290 <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	6a 05                	push   $0x5
  8010d4:	56                   	push   %esi
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	6a 00                	push   $0x0
  8010d9:	e8 56 fc ff ff       	call   800d34 <sys_page_map>
  8010de:	83 c4 20             	add    $0x20,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	79 12                	jns    8010f7 <fork+0x125>
			panic("fork: sys_page_map: %e", r);
  8010e5:	50                   	push   %eax
  8010e6:	68 2a 28 80 00       	push   $0x80282a
  8010eb:	6a 64                	push   $0x64
  8010ed:	68 0f 28 80 00       	push   $0x80280f
  8010f2:	e8 99 f1 ff ff       	call   800290 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  8010f7:	83 c3 01             	add    $0x1,%ebx
  8010fa:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801100:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801106:	0f 85 32 ff ff ff    	jne    80103e <fork+0x6c>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	6a 07                	push   $0x7
  801111:	68 00 f0 bf ee       	push   $0xeebff000
  801116:	ff 75 e4             	pushl  -0x1c(%ebp)
  801119:	e8 d3 fb ff ff       	call   800cf1 <sys_page_alloc>
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	79 15                	jns    80113a <fork+0x168>
		panic("sys_page_alloc: %e", r);
  801125:	50                   	push   %eax
  801126:	68 41 28 80 00       	push   $0x802841
  80112b:	68 98 00 00 00       	push   $0x98
  801130:	68 0f 28 80 00       	push   $0x80280f
  801135:	e8 56 f1 ff ff       	call   800290 <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	68 f1 1e 80 00       	push   $0x801ef1
  801142:	ff 75 e4             	pushl  -0x1c(%ebp)
  801145:	e8 f2 fc ff ff       	call   800e3c <sys_env_set_pgfault_upcall>
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 17                	jns    801168 <fork+0x196>
		panic("sys_pgfault_upcall error");
  801151:	83 ec 04             	sub    $0x4,%esp
  801154:	68 54 28 80 00       	push   $0x802854
  801159:	68 9b 00 00 00       	push   $0x9b
  80115e:	68 0f 28 80 00       	push   $0x80280f
  801163:	e8 28 f1 ff ff       	call   800290 <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801168:	83 ec 08             	sub    $0x8,%esp
  80116b:	6a 02                	push   $0x2
  80116d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801170:	e8 43 fc ff ff       	call   800db8 <sys_env_set_status>
  801175:	83 c4 10             	add    $0x10,%esp
  801178:	85 c0                	test   %eax,%eax
  80117a:	79 15                	jns    801191 <fork+0x1bf>
		panic("sys_env_set_status: %e", r);
  80117c:	50                   	push   %eax
  80117d:	68 6d 28 80 00       	push   $0x80286d
  801182:	68 a1 00 00 00       	push   $0xa1
  801187:	68 0f 28 80 00       	push   $0x80280f
  80118c:	e8 ff f0 ff ff       	call   800290 <_panic>

	return envid;
  801191:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <sfork>:

// Challenge!
int
sfork(void)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a2:	68 84 28 80 00       	push   $0x802884
  8011a7:	68 ac 00 00 00       	push   $0xac
  8011ac:	68 0f 28 80 00       	push   $0x80280f
  8011b1:	e8 da f0 ff ff       	call   800290 <_panic>

008011b6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bc:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c1:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cc:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	c1 ea 16             	shr    $0x16,%edx
  8011ed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f4:	f6 c2 01             	test   $0x1,%dl
  8011f7:	74 11                	je     80120a <fd_alloc+0x2d>
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	c1 ea 0c             	shr    $0xc,%edx
  8011fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801205:	f6 c2 01             	test   $0x1,%dl
  801208:	75 09                	jne    801213 <fd_alloc+0x36>
			*fd_store = fd;
  80120a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
  801211:	eb 17                	jmp    80122a <fd_alloc+0x4d>
  801213:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801218:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80121d:	75 c9                	jne    8011e8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80121f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801225:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801232:	83 f8 1f             	cmp    $0x1f,%eax
  801235:	77 36                	ja     80126d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801237:	c1 e0 0c             	shl    $0xc,%eax
  80123a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80123f:	89 c2                	mov    %eax,%edx
  801241:	c1 ea 16             	shr    $0x16,%edx
  801244:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124b:	f6 c2 01             	test   $0x1,%dl
  80124e:	74 24                	je     801274 <fd_lookup+0x48>
  801250:	89 c2                	mov    %eax,%edx
  801252:	c1 ea 0c             	shr    $0xc,%edx
  801255:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125c:	f6 c2 01             	test   $0x1,%dl
  80125f:	74 1a                	je     80127b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801261:	8b 55 0c             	mov    0xc(%ebp),%edx
  801264:	89 02                	mov    %eax,(%edx)
	return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
  80126b:	eb 13                	jmp    801280 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80126d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801272:	eb 0c                	jmp    801280 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801274:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801279:	eb 05                	jmp    801280 <fd_lookup+0x54>
  80127b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128b:	ba 18 29 80 00       	mov    $0x802918,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801290:	eb 13                	jmp    8012a5 <dev_lookup+0x23>
  801292:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801295:	39 08                	cmp    %ecx,(%eax)
  801297:	75 0c                	jne    8012a5 <dev_lookup+0x23>
			*dev = devtab[i];
  801299:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a3:	eb 2e                	jmp    8012d3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a5:	8b 02                	mov    (%edx),%eax
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	75 e7                	jne    801292 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b0:	8b 40 48             	mov    0x48(%eax),%eax
  8012b3:	83 ec 04             	sub    $0x4,%esp
  8012b6:	51                   	push   %ecx
  8012b7:	50                   	push   %eax
  8012b8:	68 9c 28 80 00       	push   $0x80289c
  8012bd:	e8 a7 f0 ff ff       	call   800369 <cprintf>
	*dev = 0;
  8012c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 10             	sub    $0x10,%esp
  8012dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ed:	c1 e8 0c             	shr    $0xc,%eax
  8012f0:	50                   	push   %eax
  8012f1:	e8 36 ff ff ff       	call   80122c <fd_lookup>
  8012f6:	83 c4 08             	add    $0x8,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 05                	js     801302 <fd_close+0x2d>
	    || fd != fd2)
  8012fd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801300:	74 0c                	je     80130e <fd_close+0x39>
		return (must_exist ? r : 0);
  801302:	84 db                	test   %bl,%bl
  801304:	ba 00 00 00 00       	mov    $0x0,%edx
  801309:	0f 44 c2             	cmove  %edx,%eax
  80130c:	eb 41                	jmp    80134f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 36                	pushl  (%esi)
  801317:	e8 66 ff ff ff       	call   801282 <dev_lookup>
  80131c:	89 c3                	mov    %eax,%ebx
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	78 1a                	js     80133f <fd_close+0x6a>
		if (dev->dev_close)
  801325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801328:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80132b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801330:	85 c0                	test   %eax,%eax
  801332:	74 0b                	je     80133f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801334:	83 ec 0c             	sub    $0xc,%esp
  801337:	56                   	push   %esi
  801338:	ff d0                	call   *%eax
  80133a:	89 c3                	mov    %eax,%ebx
  80133c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80133f:	83 ec 08             	sub    $0x8,%esp
  801342:	56                   	push   %esi
  801343:	6a 00                	push   $0x0
  801345:	e8 2c fa ff ff       	call   800d76 <sys_page_unmap>
	return r;
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	89 d8                	mov    %ebx,%eax
}
  80134f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801352:	5b                   	pop    %ebx
  801353:	5e                   	pop    %esi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	ff 75 08             	pushl  0x8(%ebp)
  801363:	e8 c4 fe ff ff       	call   80122c <fd_lookup>
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 10                	js     80137f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	6a 01                	push   $0x1
  801374:	ff 75 f4             	pushl  -0xc(%ebp)
  801377:	e8 59 ff ff ff       	call   8012d5 <fd_close>
  80137c:	83 c4 10             	add    $0x10,%esp
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <close_all>:

void
close_all(void)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	53                   	push   %ebx
  801385:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801388:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	53                   	push   %ebx
  801391:	e8 c0 ff ff ff       	call   801356 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801396:	83 c3 01             	add    $0x1,%ebx
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	83 fb 20             	cmp    $0x20,%ebx
  80139f:	75 ec                	jne    80138d <close_all+0xc>
		close(i);
}
  8013a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a4:	c9                   	leave  
  8013a5:	c3                   	ret    

008013a6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	57                   	push   %edi
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 2c             	sub    $0x2c,%esp
  8013af:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	ff 75 08             	pushl  0x8(%ebp)
  8013b9:	e8 6e fe ff ff       	call   80122c <fd_lookup>
  8013be:	83 c4 08             	add    $0x8,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	0f 88 c1 00 00 00    	js     80148a <dup+0xe4>
		return r;
	close(newfdnum);
  8013c9:	83 ec 0c             	sub    $0xc,%esp
  8013cc:	56                   	push   %esi
  8013cd:	e8 84 ff ff ff       	call   801356 <close>

	newfd = INDEX2FD(newfdnum);
  8013d2:	89 f3                	mov    %esi,%ebx
  8013d4:	c1 e3 0c             	shl    $0xc,%ebx
  8013d7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013dd:	83 c4 04             	add    $0x4,%esp
  8013e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e3:	e8 de fd ff ff       	call   8011c6 <fd2data>
  8013e8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ea:	89 1c 24             	mov    %ebx,(%esp)
  8013ed:	e8 d4 fd ff ff       	call   8011c6 <fd2data>
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f8:	89 f8                	mov    %edi,%eax
  8013fa:	c1 e8 16             	shr    $0x16,%eax
  8013fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801404:	a8 01                	test   $0x1,%al
  801406:	74 37                	je     80143f <dup+0x99>
  801408:	89 f8                	mov    %edi,%eax
  80140a:	c1 e8 0c             	shr    $0xc,%eax
  80140d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801414:	f6 c2 01             	test   $0x1,%dl
  801417:	74 26                	je     80143f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801419:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801420:	83 ec 0c             	sub    $0xc,%esp
  801423:	25 07 0e 00 00       	and    $0xe07,%eax
  801428:	50                   	push   %eax
  801429:	ff 75 d4             	pushl  -0x2c(%ebp)
  80142c:	6a 00                	push   $0x0
  80142e:	57                   	push   %edi
  80142f:	6a 00                	push   $0x0
  801431:	e8 fe f8 ff ff       	call   800d34 <sys_page_map>
  801436:	89 c7                	mov    %eax,%edi
  801438:	83 c4 20             	add    $0x20,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 2e                	js     80146d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801442:	89 d0                	mov    %edx,%eax
  801444:	c1 e8 0c             	shr    $0xc,%eax
  801447:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	25 07 0e 00 00       	and    $0xe07,%eax
  801456:	50                   	push   %eax
  801457:	53                   	push   %ebx
  801458:	6a 00                	push   $0x0
  80145a:	52                   	push   %edx
  80145b:	6a 00                	push   $0x0
  80145d:	e8 d2 f8 ff ff       	call   800d34 <sys_page_map>
  801462:	89 c7                	mov    %eax,%edi
  801464:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801467:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801469:	85 ff                	test   %edi,%edi
  80146b:	79 1d                	jns    80148a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	53                   	push   %ebx
  801471:	6a 00                	push   $0x0
  801473:	e8 fe f8 ff ff       	call   800d76 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801478:	83 c4 08             	add    $0x8,%esp
  80147b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80147e:	6a 00                	push   $0x0
  801480:	e8 f1 f8 ff ff       	call   800d76 <sys_page_unmap>
	return r;
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	89 f8                	mov    %edi,%eax
}
  80148a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148d:	5b                   	pop    %ebx
  80148e:	5e                   	pop    %esi
  80148f:	5f                   	pop    %edi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	53                   	push   %ebx
  801496:	83 ec 14             	sub    $0x14,%esp
  801499:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	53                   	push   %ebx
  8014a1:	e8 86 fd ff ff       	call   80122c <fd_lookup>
  8014a6:	83 c4 08             	add    $0x8,%esp
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 6d                	js     80151c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b9:	ff 30                	pushl  (%eax)
  8014bb:	e8 c2 fd ff ff       	call   801282 <dev_lookup>
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 4c                	js     801513 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ca:	8b 42 08             	mov    0x8(%edx),%eax
  8014cd:	83 e0 03             	and    $0x3,%eax
  8014d0:	83 f8 01             	cmp    $0x1,%eax
  8014d3:	75 21                	jne    8014f6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8014da:	8b 40 48             	mov    0x48(%eax),%eax
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	50                   	push   %eax
  8014e2:	68 dd 28 80 00       	push   $0x8028dd
  8014e7:	e8 7d ee ff ff       	call   800369 <cprintf>
		return -E_INVAL;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f4:	eb 26                	jmp    80151c <read+0x8a>
	}
	if (!dev->dev_read)
  8014f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f9:	8b 40 08             	mov    0x8(%eax),%eax
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	74 17                	je     801517 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	ff 75 10             	pushl  0x10(%ebp)
  801506:	ff 75 0c             	pushl  0xc(%ebp)
  801509:	52                   	push   %edx
  80150a:	ff d0                	call   *%eax
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	eb 09                	jmp    80151c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801513:	89 c2                	mov    %eax,%edx
  801515:	eb 05                	jmp    80151c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801517:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80151c:	89 d0                	mov    %edx,%eax
  80151e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	57                   	push   %edi
  801527:	56                   	push   %esi
  801528:	53                   	push   %ebx
  801529:	83 ec 0c             	sub    $0xc,%esp
  80152c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80152f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801532:	bb 00 00 00 00       	mov    $0x0,%ebx
  801537:	eb 21                	jmp    80155a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801539:	83 ec 04             	sub    $0x4,%esp
  80153c:	89 f0                	mov    %esi,%eax
  80153e:	29 d8                	sub    %ebx,%eax
  801540:	50                   	push   %eax
  801541:	89 d8                	mov    %ebx,%eax
  801543:	03 45 0c             	add    0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	57                   	push   %edi
  801548:	e8 45 ff ff ff       	call   801492 <read>
		if (m < 0)
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	85 c0                	test   %eax,%eax
  801552:	78 10                	js     801564 <readn+0x41>
			return m;
		if (m == 0)
  801554:	85 c0                	test   %eax,%eax
  801556:	74 0a                	je     801562 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801558:	01 c3                	add    %eax,%ebx
  80155a:	39 f3                	cmp    %esi,%ebx
  80155c:	72 db                	jb     801539 <readn+0x16>
  80155e:	89 d8                	mov    %ebx,%eax
  801560:	eb 02                	jmp    801564 <readn+0x41>
  801562:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801564:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5f                   	pop    %edi
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	53                   	push   %ebx
  801570:	83 ec 14             	sub    $0x14,%esp
  801573:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801576:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	53                   	push   %ebx
  80157b:	e8 ac fc ff ff       	call   80122c <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	89 c2                	mov    %eax,%edx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 68                	js     8015f1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	ff 30                	pushl  (%eax)
  801595:	e8 e8 fc ff ff       	call   801282 <dev_lookup>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 47                	js     8015e8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a8:	75 21                	jne    8015cb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8015af:	8b 40 48             	mov    0x48(%eax),%eax
  8015b2:	83 ec 04             	sub    $0x4,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	50                   	push   %eax
  8015b7:	68 f9 28 80 00       	push   $0x8028f9
  8015bc:	e8 a8 ed ff ff       	call   800369 <cprintf>
		return -E_INVAL;
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c9:	eb 26                	jmp    8015f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ce:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d1:	85 d2                	test   %edx,%edx
  8015d3:	74 17                	je     8015ec <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	ff 75 10             	pushl  0x10(%ebp)
  8015db:	ff 75 0c             	pushl  0xc(%ebp)
  8015de:	50                   	push   %eax
  8015df:	ff d2                	call   *%edx
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	eb 09                	jmp    8015f1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	eb 05                	jmp    8015f1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f1:	89 d0                	mov    %edx,%eax
  8015f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	ff 75 08             	pushl  0x8(%ebp)
  801605:	e8 22 fc ff ff       	call   80122c <fd_lookup>
  80160a:	83 c4 08             	add    $0x8,%esp
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 0e                	js     80161f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801611:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801614:	8b 55 0c             	mov    0xc(%ebp),%edx
  801617:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80161a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	53                   	push   %ebx
  801625:	83 ec 14             	sub    $0x14,%esp
  801628:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	53                   	push   %ebx
  801630:	e8 f7 fb ff ff       	call   80122c <fd_lookup>
  801635:	83 c4 08             	add    $0x8,%esp
  801638:	89 c2                	mov    %eax,%edx
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 65                	js     8016a3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801648:	ff 30                	pushl  (%eax)
  80164a:	e8 33 fc ff ff       	call   801282 <dev_lookup>
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 44                	js     80169a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801656:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801659:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165d:	75 21                	jne    801680 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80165f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801664:	8b 40 48             	mov    0x48(%eax),%eax
  801667:	83 ec 04             	sub    $0x4,%esp
  80166a:	53                   	push   %ebx
  80166b:	50                   	push   %eax
  80166c:	68 bc 28 80 00       	push   $0x8028bc
  801671:	e8 f3 ec ff ff       	call   800369 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80167e:	eb 23                	jmp    8016a3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801680:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801683:	8b 52 18             	mov    0x18(%edx),%edx
  801686:	85 d2                	test   %edx,%edx
  801688:	74 14                	je     80169e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	ff 75 0c             	pushl  0xc(%ebp)
  801690:	50                   	push   %eax
  801691:	ff d2                	call   *%edx
  801693:	89 c2                	mov    %eax,%edx
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	eb 09                	jmp    8016a3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	eb 05                	jmp    8016a3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80169e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016a3:	89 d0                	mov    %edx,%eax
  8016a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 14             	sub    $0x14,%esp
  8016b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b7:	50                   	push   %eax
  8016b8:	ff 75 08             	pushl  0x8(%ebp)
  8016bb:	e8 6c fb ff ff       	call   80122c <fd_lookup>
  8016c0:	83 c4 08             	add    $0x8,%esp
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 58                	js     801721 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d3:	ff 30                	pushl  (%eax)
  8016d5:	e8 a8 fb ff ff       	call   801282 <dev_lookup>
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 37                	js     801718 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e8:	74 32                	je     80171c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016f4:	00 00 00 
	stat->st_isdir = 0;
  8016f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016fe:	00 00 00 
	stat->st_dev = dev;
  801701:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	53                   	push   %ebx
  80170b:	ff 75 f0             	pushl  -0x10(%ebp)
  80170e:	ff 50 14             	call   *0x14(%eax)
  801711:	89 c2                	mov    %eax,%edx
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	eb 09                	jmp    801721 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801718:	89 c2                	mov    %eax,%edx
  80171a:	eb 05                	jmp    801721 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80171c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801721:	89 d0                	mov    %edx,%eax
  801723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	6a 00                	push   $0x0
  801732:	ff 75 08             	pushl  0x8(%ebp)
  801735:	e8 b7 01 00 00       	call   8018f1 <open>
  80173a:	89 c3                	mov    %eax,%ebx
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 1b                	js     80175e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	ff 75 0c             	pushl  0xc(%ebp)
  801749:	50                   	push   %eax
  80174a:	e8 5b ff ff ff       	call   8016aa <fstat>
  80174f:	89 c6                	mov    %eax,%esi
	close(fd);
  801751:	89 1c 24             	mov    %ebx,(%esp)
  801754:	e8 fd fb ff ff       	call   801356 <close>
	return r;
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	89 f0                	mov    %esi,%eax
}
  80175e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
  80176a:	89 c6                	mov    %eax,%esi
  80176c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80176e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801775:	75 12                	jne    801789 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801777:	83 ec 0c             	sub    $0xc,%esp
  80177a:	6a 01                	push   $0x1
  80177c:	e8 96 08 00 00       	call   802017 <ipc_find_env>
  801781:	a3 00 40 80 00       	mov    %eax,0x804000
  801786:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801789:	6a 07                	push   $0x7
  80178b:	68 00 50 80 00       	push   $0x805000
  801790:	56                   	push   %esi
  801791:	ff 35 00 40 80 00    	pushl  0x804000
  801797:	e8 ef 07 00 00       	call   801f8b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80179c:	83 c4 0c             	add    $0xc,%esp
  80179f:	6a 00                	push   $0x0
  8017a1:	53                   	push   %ebx
  8017a2:	6a 00                	push   $0x0
  8017a4:	e8 6d 07 00 00       	call   801f16 <ipc_recv>
}
  8017a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8017d3:	e8 8d ff ff ff       	call   801765 <fsipc>
}
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f5:	e8 6b ff ff ff       	call   801765 <fsipc>
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	53                   	push   %ebx
  801800:	83 ec 04             	sub    $0x4,%esp
  801803:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	8b 40 0c             	mov    0xc(%eax),%eax
  80180c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	b8 05 00 00 00       	mov    $0x5,%eax
  80181b:	e8 45 ff ff ff       	call   801765 <fsipc>
  801820:	85 c0                	test   %eax,%eax
  801822:	78 2c                	js     801850 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	68 00 50 80 00       	push   $0x805000
  80182c:	53                   	push   %ebx
  80182d:	e8 bc f0 ff ff       	call   8008ee <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801832:	a1 80 50 80 00       	mov    0x805080,%eax
  801837:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80183d:	a1 84 50 80 00       	mov    0x805084,%eax
  801842:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80185b:	68 28 29 80 00       	push   $0x802928
  801860:	68 90 00 00 00       	push   $0x90
  801865:	68 46 29 80 00       	push   $0x802946
  80186a:	e8 21 ea ff ff       	call   800290 <_panic>

0080186f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	56                   	push   %esi
  801873:	53                   	push   %ebx
  801874:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	8b 40 0c             	mov    0xc(%eax),%eax
  80187d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801882:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801888:	ba 00 00 00 00       	mov    $0x0,%edx
  80188d:	b8 03 00 00 00       	mov    $0x3,%eax
  801892:	e8 ce fe ff ff       	call   801765 <fsipc>
  801897:	89 c3                	mov    %eax,%ebx
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 4b                	js     8018e8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80189d:	39 c6                	cmp    %eax,%esi
  80189f:	73 16                	jae    8018b7 <devfile_read+0x48>
  8018a1:	68 51 29 80 00       	push   $0x802951
  8018a6:	68 58 29 80 00       	push   $0x802958
  8018ab:	6a 7c                	push   $0x7c
  8018ad:	68 46 29 80 00       	push   $0x802946
  8018b2:	e8 d9 e9 ff ff       	call   800290 <_panic>
	assert(r <= PGSIZE);
  8018b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018bc:	7e 16                	jle    8018d4 <devfile_read+0x65>
  8018be:	68 6d 29 80 00       	push   $0x80296d
  8018c3:	68 58 29 80 00       	push   $0x802958
  8018c8:	6a 7d                	push   $0x7d
  8018ca:	68 46 29 80 00       	push   $0x802946
  8018cf:	e8 bc e9 ff ff       	call   800290 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d4:	83 ec 04             	sub    $0x4,%esp
  8018d7:	50                   	push   %eax
  8018d8:	68 00 50 80 00       	push   $0x805000
  8018dd:	ff 75 0c             	pushl  0xc(%ebp)
  8018e0:	e8 9b f1 ff ff       	call   800a80 <memmove>
	return r;
  8018e5:	83 c4 10             	add    $0x10,%esp
}
  8018e8:	89 d8                	mov    %ebx,%eax
  8018ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5e                   	pop    %esi
  8018ef:	5d                   	pop    %ebp
  8018f0:	c3                   	ret    

008018f1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 20             	sub    $0x20,%esp
  8018f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018fb:	53                   	push   %ebx
  8018fc:	e8 b4 ef ff ff       	call   8008b5 <strlen>
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801909:	7f 67                	jg     801972 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190b:	83 ec 0c             	sub    $0xc,%esp
  80190e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801911:	50                   	push   %eax
  801912:	e8 c6 f8 ff ff       	call   8011dd <fd_alloc>
  801917:	83 c4 10             	add    $0x10,%esp
		return r;
  80191a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 57                	js     801977 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801920:	83 ec 08             	sub    $0x8,%esp
  801923:	53                   	push   %ebx
  801924:	68 00 50 80 00       	push   $0x805000
  801929:	e8 c0 ef ff ff       	call   8008ee <strcpy>
	fsipcbuf.open.req_omode = mode;
  80192e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801931:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801936:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801939:	b8 01 00 00 00       	mov    $0x1,%eax
  80193e:	e8 22 fe ff ff       	call   801765 <fsipc>
  801943:	89 c3                	mov    %eax,%ebx
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	85 c0                	test   %eax,%eax
  80194a:	79 14                	jns    801960 <open+0x6f>
		fd_close(fd, 0);
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	6a 00                	push   $0x0
  801951:	ff 75 f4             	pushl  -0xc(%ebp)
  801954:	e8 7c f9 ff ff       	call   8012d5 <fd_close>
		return r;
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	89 da                	mov    %ebx,%edx
  80195e:	eb 17                	jmp    801977 <open+0x86>
	}

	return fd2num(fd);
  801960:	83 ec 0c             	sub    $0xc,%esp
  801963:	ff 75 f4             	pushl  -0xc(%ebp)
  801966:	e8 4b f8 ff ff       	call   8011b6 <fd2num>
  80196b:	89 c2                	mov    %eax,%edx
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	eb 05                	jmp    801977 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801972:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801977:	89 d0                	mov    %edx,%eax
  801979:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801984:	ba 00 00 00 00       	mov    $0x0,%edx
  801989:	b8 08 00 00 00       	mov    $0x8,%eax
  80198e:	e8 d2 fd ff ff       	call   801765 <fsipc>
}
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	ff 75 08             	pushl  0x8(%ebp)
  8019a3:	e8 1e f8 ff ff       	call   8011c6 <fd2data>
  8019a8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019aa:	83 c4 08             	add    $0x8,%esp
  8019ad:	68 79 29 80 00       	push   $0x802979
  8019b2:	53                   	push   %ebx
  8019b3:	e8 36 ef ff ff       	call   8008ee <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019b8:	8b 46 04             	mov    0x4(%esi),%eax
  8019bb:	2b 06                	sub    (%esi),%eax
  8019bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019c3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ca:	00 00 00 
	stat->st_dev = &devpipe;
  8019cd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019d4:	30 80 00 
	return 0;
}
  8019d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019df:	5b                   	pop    %ebx
  8019e0:	5e                   	pop    %esi
  8019e1:	5d                   	pop    %ebp
  8019e2:	c3                   	ret    

008019e3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 0c             	sub    $0xc,%esp
  8019ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019ed:	53                   	push   %ebx
  8019ee:	6a 00                	push   $0x0
  8019f0:	e8 81 f3 ff ff       	call   800d76 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f5:	89 1c 24             	mov    %ebx,(%esp)
  8019f8:	e8 c9 f7 ff ff       	call   8011c6 <fd2data>
  8019fd:	83 c4 08             	add    $0x8,%esp
  801a00:	50                   	push   %eax
  801a01:	6a 00                	push   $0x0
  801a03:	e8 6e f3 ff ff       	call   800d76 <sys_page_unmap>
}
  801a08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	57                   	push   %edi
  801a11:	56                   	push   %esi
  801a12:	53                   	push   %ebx
  801a13:	83 ec 1c             	sub    $0x1c,%esp
  801a16:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a19:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a1b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a20:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a23:	83 ec 0c             	sub    $0xc,%esp
  801a26:	ff 75 e0             	pushl  -0x20(%ebp)
  801a29:	e8 22 06 00 00       	call   802050 <pageref>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	89 3c 24             	mov    %edi,(%esp)
  801a33:	e8 18 06 00 00       	call   802050 <pageref>
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	39 c3                	cmp    %eax,%ebx
  801a3d:	0f 94 c1             	sete   %cl
  801a40:	0f b6 c9             	movzbl %cl,%ecx
  801a43:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a46:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a4c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a4f:	39 ce                	cmp    %ecx,%esi
  801a51:	74 1b                	je     801a6e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a53:	39 c3                	cmp    %eax,%ebx
  801a55:	75 c4                	jne    801a1b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a57:	8b 42 58             	mov    0x58(%edx),%eax
  801a5a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a5d:	50                   	push   %eax
  801a5e:	56                   	push   %esi
  801a5f:	68 80 29 80 00       	push   $0x802980
  801a64:	e8 00 e9 ff ff       	call   800369 <cprintf>
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	eb ad                	jmp    801a1b <_pipeisclosed+0xe>
	}
}
  801a6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5f                   	pop    %edi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	57                   	push   %edi
  801a7d:	56                   	push   %esi
  801a7e:	53                   	push   %ebx
  801a7f:	83 ec 28             	sub    $0x28,%esp
  801a82:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a85:	56                   	push   %esi
  801a86:	e8 3b f7 ff ff       	call   8011c6 <fd2data>
  801a8b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	bf 00 00 00 00       	mov    $0x0,%edi
  801a95:	eb 4b                	jmp    801ae2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a97:	89 da                	mov    %ebx,%edx
  801a99:	89 f0                	mov    %esi,%eax
  801a9b:	e8 6d ff ff ff       	call   801a0d <_pipeisclosed>
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	75 48                	jne    801aec <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801aa4:	e8 29 f2 ff ff       	call   800cd2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa9:	8b 43 04             	mov    0x4(%ebx),%eax
  801aac:	8b 0b                	mov    (%ebx),%ecx
  801aae:	8d 51 20             	lea    0x20(%ecx),%edx
  801ab1:	39 d0                	cmp    %edx,%eax
  801ab3:	73 e2                	jae    801a97 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801abc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801abf:	89 c2                	mov    %eax,%edx
  801ac1:	c1 fa 1f             	sar    $0x1f,%edx
  801ac4:	89 d1                	mov    %edx,%ecx
  801ac6:	c1 e9 1b             	shr    $0x1b,%ecx
  801ac9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801acc:	83 e2 1f             	and    $0x1f,%edx
  801acf:	29 ca                	sub    %ecx,%edx
  801ad1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ad5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ad9:	83 c0 01             	add    $0x1,%eax
  801adc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801adf:	83 c7 01             	add    $0x1,%edi
  801ae2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ae5:	75 c2                	jne    801aa9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  801aea:	eb 05                	jmp    801af1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aec:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801af1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af4:	5b                   	pop    %ebx
  801af5:	5e                   	pop    %esi
  801af6:	5f                   	pop    %edi
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	57                   	push   %edi
  801afd:	56                   	push   %esi
  801afe:	53                   	push   %ebx
  801aff:	83 ec 18             	sub    $0x18,%esp
  801b02:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b05:	57                   	push   %edi
  801b06:	e8 bb f6 ff ff       	call   8011c6 <fd2data>
  801b0b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b15:	eb 3d                	jmp    801b54 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b17:	85 db                	test   %ebx,%ebx
  801b19:	74 04                	je     801b1f <devpipe_read+0x26>
				return i;
  801b1b:	89 d8                	mov    %ebx,%eax
  801b1d:	eb 44                	jmp    801b63 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b1f:	89 f2                	mov    %esi,%edx
  801b21:	89 f8                	mov    %edi,%eax
  801b23:	e8 e5 fe ff ff       	call   801a0d <_pipeisclosed>
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	75 32                	jne    801b5e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b2c:	e8 a1 f1 ff ff       	call   800cd2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b31:	8b 06                	mov    (%esi),%eax
  801b33:	3b 46 04             	cmp    0x4(%esi),%eax
  801b36:	74 df                	je     801b17 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b38:	99                   	cltd   
  801b39:	c1 ea 1b             	shr    $0x1b,%edx
  801b3c:	01 d0                	add    %edx,%eax
  801b3e:	83 e0 1f             	and    $0x1f,%eax
  801b41:	29 d0                	sub    %edx,%eax
  801b43:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b4e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b51:	83 c3 01             	add    $0x1,%ebx
  801b54:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b57:	75 d8                	jne    801b31 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b59:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5c:	eb 05                	jmp    801b63 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b5e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5e                   	pop    %esi
  801b68:	5f                   	pop    %edi
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    

00801b6b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	56                   	push   %esi
  801b6f:	53                   	push   %ebx
  801b70:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b76:	50                   	push   %eax
  801b77:	e8 61 f6 ff ff       	call   8011dd <fd_alloc>
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	89 c2                	mov    %eax,%edx
  801b81:	85 c0                	test   %eax,%eax
  801b83:	0f 88 2c 01 00 00    	js     801cb5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	68 07 04 00 00       	push   $0x407
  801b91:	ff 75 f4             	pushl  -0xc(%ebp)
  801b94:	6a 00                	push   $0x0
  801b96:	e8 56 f1 ff ff       	call   800cf1 <sys_page_alloc>
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	89 c2                	mov    %eax,%edx
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	0f 88 0d 01 00 00    	js     801cb5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ba8:	83 ec 0c             	sub    $0xc,%esp
  801bab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bae:	50                   	push   %eax
  801baf:	e8 29 f6 ff ff       	call   8011dd <fd_alloc>
  801bb4:	89 c3                	mov    %eax,%ebx
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	0f 88 e2 00 00 00    	js     801ca3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	68 07 04 00 00       	push   $0x407
  801bc9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 1e f1 ff ff       	call   800cf1 <sys_page_alloc>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 c3 00 00 00    	js     801ca3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	ff 75 f4             	pushl  -0xc(%ebp)
  801be6:	e8 db f5 ff ff       	call   8011c6 <fd2data>
  801beb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bed:	83 c4 0c             	add    $0xc,%esp
  801bf0:	68 07 04 00 00       	push   $0x407
  801bf5:	50                   	push   %eax
  801bf6:	6a 00                	push   $0x0
  801bf8:	e8 f4 f0 ff ff       	call   800cf1 <sys_page_alloc>
  801bfd:	89 c3                	mov    %eax,%ebx
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	85 c0                	test   %eax,%eax
  801c04:	0f 88 89 00 00 00    	js     801c93 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0a:	83 ec 0c             	sub    $0xc,%esp
  801c0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c10:	e8 b1 f5 ff ff       	call   8011c6 <fd2data>
  801c15:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c1c:	50                   	push   %eax
  801c1d:	6a 00                	push   $0x0
  801c1f:	56                   	push   %esi
  801c20:	6a 00                	push   $0x0
  801c22:	e8 0d f1 ff ff       	call   800d34 <sys_page_map>
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	83 c4 20             	add    $0x20,%esp
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	78 55                	js     801c85 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c30:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c39:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c45:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c53:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c5a:	83 ec 0c             	sub    $0xc,%esp
  801c5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c60:	e8 51 f5 ff ff       	call   8011b6 <fd2num>
  801c65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c68:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c6a:	83 c4 04             	add    $0x4,%esp
  801c6d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c70:	e8 41 f5 ff ff       	call   8011b6 <fd2num>
  801c75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c78:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c83:	eb 30                	jmp    801cb5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c85:	83 ec 08             	sub    $0x8,%esp
  801c88:	56                   	push   %esi
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 e6 f0 ff ff       	call   800d76 <sys_page_unmap>
  801c90:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c93:	83 ec 08             	sub    $0x8,%esp
  801c96:	ff 75 f0             	pushl  -0x10(%ebp)
  801c99:	6a 00                	push   $0x0
  801c9b:	e8 d6 f0 ff ff       	call   800d76 <sys_page_unmap>
  801ca0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca3:	83 ec 08             	sub    $0x8,%esp
  801ca6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca9:	6a 00                	push   $0x0
  801cab:	e8 c6 f0 ff ff       	call   800d76 <sys_page_unmap>
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cb5:	89 d0                	mov    %edx,%eax
  801cb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cba:	5b                   	pop    %ebx
  801cbb:	5e                   	pop    %esi
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    

00801cbe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc7:	50                   	push   %eax
  801cc8:	ff 75 08             	pushl  0x8(%ebp)
  801ccb:	e8 5c f5 ff ff       	call   80122c <fd_lookup>
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 18                	js     801cef <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cd7:	83 ec 0c             	sub    $0xc,%esp
  801cda:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdd:	e8 e4 f4 ff ff       	call   8011c6 <fd2data>
	return _pipeisclosed(fd, p);
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce7:	e8 21 fd ff ff       	call   801a0d <_pipeisclosed>
  801cec:	83 c4 10             	add    $0x10,%esp
}
  801cef:	c9                   	leave  
  801cf0:	c3                   	ret    

00801cf1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d01:	68 93 29 80 00       	push   $0x802993
  801d06:	ff 75 0c             	pushl  0xc(%ebp)
  801d09:	e8 e0 eb ff ff       	call   8008ee <strcpy>
	return 0;
}
  801d0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	57                   	push   %edi
  801d19:	56                   	push   %esi
  801d1a:	53                   	push   %ebx
  801d1b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d21:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d26:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2c:	eb 2d                	jmp    801d5b <devcons_write+0x46>
		m = n - tot;
  801d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d31:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d33:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d36:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d3b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d3e:	83 ec 04             	sub    $0x4,%esp
  801d41:	53                   	push   %ebx
  801d42:	03 45 0c             	add    0xc(%ebp),%eax
  801d45:	50                   	push   %eax
  801d46:	57                   	push   %edi
  801d47:	e8 34 ed ff ff       	call   800a80 <memmove>
		sys_cputs(buf, m);
  801d4c:	83 c4 08             	add    $0x8,%esp
  801d4f:	53                   	push   %ebx
  801d50:	57                   	push   %edi
  801d51:	e8 df ee ff ff       	call   800c35 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d56:	01 de                	add    %ebx,%esi
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	89 f0                	mov    %esi,%eax
  801d5d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d60:	72 cc                	jb     801d2e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5f                   	pop    %edi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 08             	sub    $0x8,%esp
  801d70:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d79:	74 2a                	je     801da5 <devcons_read+0x3b>
  801d7b:	eb 05                	jmp    801d82 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d7d:	e8 50 ef ff ff       	call   800cd2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d82:	e8 cc ee ff ff       	call   800c53 <sys_cgetc>
  801d87:	85 c0                	test   %eax,%eax
  801d89:	74 f2                	je     801d7d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	78 16                	js     801da5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d8f:	83 f8 04             	cmp    $0x4,%eax
  801d92:	74 0c                	je     801da0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d97:	88 02                	mov    %al,(%edx)
	return 1;
  801d99:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9e:	eb 05                	jmp    801da5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801da0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dad:	8b 45 08             	mov    0x8(%ebp),%eax
  801db0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801db3:	6a 01                	push   $0x1
  801db5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db8:	50                   	push   %eax
  801db9:	e8 77 ee ff ff       	call   800c35 <sys_cputs>
}
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <getchar>:

int
getchar(void)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dc9:	6a 01                	push   $0x1
  801dcb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dce:	50                   	push   %eax
  801dcf:	6a 00                	push   $0x0
  801dd1:	e8 bc f6 ff ff       	call   801492 <read>
	if (r < 0)
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 0f                	js     801dec <getchar+0x29>
		return r;
	if (r < 1)
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	7e 06                	jle    801de7 <getchar+0x24>
		return -E_EOF;
	return c;
  801de1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801de5:	eb 05                	jmp    801dec <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801de7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df7:	50                   	push   %eax
  801df8:	ff 75 08             	pushl  0x8(%ebp)
  801dfb:	e8 2c f4 ff ff       	call   80122c <fd_lookup>
  801e00:	83 c4 10             	add    $0x10,%esp
  801e03:	85 c0                	test   %eax,%eax
  801e05:	78 11                	js     801e18 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e10:	39 10                	cmp    %edx,(%eax)
  801e12:	0f 94 c0             	sete   %al
  801e15:	0f b6 c0             	movzbl %al,%eax
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <opencons>:

int
opencons(void)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e23:	50                   	push   %eax
  801e24:	e8 b4 f3 ff ff       	call   8011dd <fd_alloc>
  801e29:	83 c4 10             	add    $0x10,%esp
		return r;
  801e2c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 3e                	js     801e70 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e32:	83 ec 04             	sub    $0x4,%esp
  801e35:	68 07 04 00 00       	push   $0x407
  801e3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3d:	6a 00                	push   $0x0
  801e3f:	e8 ad ee ff ff       	call   800cf1 <sys_page_alloc>
  801e44:	83 c4 10             	add    $0x10,%esp
		return r;
  801e47:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 23                	js     801e70 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e4d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e62:	83 ec 0c             	sub    $0xc,%esp
  801e65:	50                   	push   %eax
  801e66:	e8 4b f3 ff ff       	call   8011b6 <fd2num>
  801e6b:	89 c2                	mov    %eax,%edx
  801e6d:	83 c4 10             	add    $0x10,%esp
}
  801e70:	89 d0                	mov    %edx,%eax
  801e72:	c9                   	leave  
  801e73:	c3                   	ret    

00801e74 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e7a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e81:	75 64                	jne    801ee7 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801e83:	a1 04 40 80 00       	mov    0x804004,%eax
  801e88:	8b 40 48             	mov    0x48(%eax),%eax
  801e8b:	83 ec 04             	sub    $0x4,%esp
  801e8e:	6a 07                	push   $0x7
  801e90:	68 00 f0 bf ee       	push   $0xeebff000
  801e95:	50                   	push   %eax
  801e96:	e8 56 ee ff ff       	call   800cf1 <sys_page_alloc>
		if ( r != 0)
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	74 14                	je     801eb6 <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  801ea2:	83 ec 04             	sub    $0x4,%esp
  801ea5:	68 a0 29 80 00       	push   $0x8029a0
  801eaa:	6a 24                	push   $0x24
  801eac:	68 ee 29 80 00       	push   $0x8029ee
  801eb1:	e8 da e3 ff ff       	call   800290 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  801eb6:	a1 04 40 80 00       	mov    0x804004,%eax
  801ebb:	8b 40 48             	mov    0x48(%eax),%eax
  801ebe:	83 ec 08             	sub    $0x8,%esp
  801ec1:	68 f1 1e 80 00       	push   $0x801ef1
  801ec6:	50                   	push   %eax
  801ec7:	e8 70 ef ff ff       	call   800e3c <sys_env_set_pgfault_upcall>
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	79 14                	jns    801ee7 <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  801ed3:	83 ec 04             	sub    $0x4,%esp
  801ed6:	68 cc 29 80 00       	push   $0x8029cc
  801edb:	6a 27                	push   $0x27
  801edd:	68 ee 29 80 00       	push   $0x8029ee
  801ee2:	e8 a9 e3 ff ff       	call   800290 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eea:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801eef:	c9                   	leave  
  801ef0:	c3                   	ret    

00801ef1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ef1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ef2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ef7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ef9:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  801efc:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  801f00:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  801f02:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  801f06:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  801f07:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  801f0a:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  801f0c:	83 c4 08             	add    $0x8,%esp
popal
  801f0f:	61                   	popa   
addl $0x4, %esp
  801f10:	83 c4 04             	add    $0x4,%esp
popfl
  801f13:	9d                   	popf   
popl %esp
  801f14:	5c                   	pop    %esp
ret
  801f15:	c3                   	ret    

00801f16 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	56                   	push   %esi
  801f1a:	53                   	push   %ebx
  801f1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f21:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  801f24:	85 c0                	test   %eax,%eax
  801f26:	74 0e                	je     801f36 <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	50                   	push   %eax
  801f2c:	e8 70 ef ff ff       	call   800ea1 <sys_ipc_recv>
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	eb 10                	jmp    801f46 <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  801f36:	83 ec 0c             	sub    $0xc,%esp
  801f39:	68 00 00 00 f0       	push   $0xf0000000
  801f3e:	e8 5e ef ff ff       	call   800ea1 <sys_ipc_recv>
  801f43:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  801f46:	85 c0                	test   %eax,%eax
  801f48:	74 16                	je     801f60 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  801f4a:	85 db                	test   %ebx,%ebx
  801f4c:	74 36                	je     801f84 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  801f4e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  801f54:	85 f6                	test   %esi,%esi
  801f56:	74 2c                	je     801f84 <ipc_recv+0x6e>
				*perm_store = 0;
  801f58:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f5e:	eb 24                	jmp    801f84 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  801f60:	85 db                	test   %ebx,%ebx
  801f62:	74 18                	je     801f7c <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  801f64:	a1 04 40 80 00       	mov    0x804004,%eax
  801f69:	8b 40 74             	mov    0x74(%eax),%eax
  801f6c:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  801f6e:	85 f6                	test   %esi,%esi
  801f70:	74 0a                	je     801f7c <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  801f72:	a1 04 40 80 00       	mov    0x804004,%eax
  801f77:	8b 40 78             	mov    0x78(%eax),%eax
  801f7a:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  801f7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801f81:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  801f84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f87:	5b                   	pop    %ebx
  801f88:	5e                   	pop    %esi
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	57                   	push   %edi
  801f8f:	56                   	push   %esi
  801f90:	53                   	push   %ebx
  801f91:	83 ec 0c             	sub    $0xc,%esp
  801f94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f97:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  801f9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f9e:	75 39                	jne    801fd9 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  801fa0:	6a 00                	push   $0x0
  801fa2:	68 00 00 00 f0       	push   $0xf0000000
  801fa7:	56                   	push   %esi
  801fa8:	57                   	push   %edi
  801fa9:	e8 d0 ee ff ff       	call   800e7e <sys_ipc_try_send>
  801fae:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801fb0:	83 c4 10             	add    $0x10,%esp
  801fb3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb6:	74 16                	je     801fce <ipc_send+0x43>
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	74 12                	je     801fce <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801fbc:	50                   	push   %eax
  801fbd:	68 fc 29 80 00       	push   $0x8029fc
  801fc2:	6a 4f                	push   $0x4f
  801fc4:	68 34 2a 80 00       	push   $0x802a34
  801fc9:	e8 c2 e2 ff ff       	call   800290 <_panic>
			sys_yield();
  801fce:	e8 ff ec ff ff       	call   800cd2 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  801fd3:	85 db                	test   %ebx,%ebx
  801fd5:	75 c9                	jne    801fa0 <ipc_send+0x15>
  801fd7:	eb 36                	jmp    80200f <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  801fd9:	ff 75 14             	pushl  0x14(%ebp)
  801fdc:	ff 75 10             	pushl  0x10(%ebp)
  801fdf:	56                   	push   %esi
  801fe0:	57                   	push   %edi
  801fe1:	e8 98 ee ff ff       	call   800e7e <sys_ipc_try_send>
  801fe6:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fee:	74 16                	je     802006 <ipc_send+0x7b>
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	74 12                	je     802006 <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801ff4:	50                   	push   %eax
  801ff5:	68 fc 29 80 00       	push   $0x8029fc
  801ffa:	6a 5a                	push   $0x5a
  801ffc:	68 34 2a 80 00       	push   $0x802a34
  802001:	e8 8a e2 ff ff       	call   800290 <_panic>
			sys_yield();
  802006:	e8 c7 ec ff ff       	call   800cd2 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  80200b:	85 db                	test   %ebx,%ebx
  80200d:	75 ca                	jne    801fd9 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  80200f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802012:	5b                   	pop    %ebx
  802013:	5e                   	pop    %esi
  802014:	5f                   	pop    %edi
  802015:	5d                   	pop    %ebp
  802016:	c3                   	ret    

00802017 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80201d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802022:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802025:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80202b:	8b 52 50             	mov    0x50(%edx),%edx
  80202e:	39 ca                	cmp    %ecx,%edx
  802030:	75 0d                	jne    80203f <ipc_find_env+0x28>
			return envs[i].env_id;
  802032:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802035:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80203a:	8b 40 48             	mov    0x48(%eax),%eax
  80203d:	eb 0f                	jmp    80204e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80203f:	83 c0 01             	add    $0x1,%eax
  802042:	3d 00 04 00 00       	cmp    $0x400,%eax
  802047:	75 d9                	jne    802022 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802049:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    

00802050 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802056:	89 d0                	mov    %edx,%eax
  802058:	c1 e8 16             	shr    $0x16,%eax
  80205b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802062:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802067:	f6 c1 01             	test   $0x1,%cl
  80206a:	74 1d                	je     802089 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80206c:	c1 ea 0c             	shr    $0xc,%edx
  80206f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802076:	f6 c2 01             	test   $0x1,%dl
  802079:	74 0e                	je     802089 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80207b:	c1 ea 0c             	shr    $0xc,%edx
  80207e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802085:	ef 
  802086:	0f b7 c0             	movzwl %ax,%eax
}
  802089:	5d                   	pop    %ebp
  80208a:	c3                   	ret    
  80208b:	66 90                	xchg   %ax,%ax
  80208d:	66 90                	xchg   %ax,%ax
  80208f:	90                   	nop

00802090 <__udivdi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80209b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80209f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ad:	89 ca                	mov    %ecx,%edx
  8020af:	89 f8                	mov    %edi,%eax
  8020b1:	75 3d                	jne    8020f0 <__udivdi3+0x60>
  8020b3:	39 cf                	cmp    %ecx,%edi
  8020b5:	0f 87 c5 00 00 00    	ja     802180 <__udivdi3+0xf0>
  8020bb:	85 ff                	test   %edi,%edi
  8020bd:	89 fd                	mov    %edi,%ebp
  8020bf:	75 0b                	jne    8020cc <__udivdi3+0x3c>
  8020c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c6:	31 d2                	xor    %edx,%edx
  8020c8:	f7 f7                	div    %edi
  8020ca:	89 c5                	mov    %eax,%ebp
  8020cc:	89 c8                	mov    %ecx,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	f7 f5                	div    %ebp
  8020d2:	89 c1                	mov    %eax,%ecx
  8020d4:	89 d8                	mov    %ebx,%eax
  8020d6:	89 cf                	mov    %ecx,%edi
  8020d8:	f7 f5                	div    %ebp
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	39 ce                	cmp    %ecx,%esi
  8020f2:	77 74                	ja     802168 <__udivdi3+0xd8>
  8020f4:	0f bd fe             	bsr    %esi,%edi
  8020f7:	83 f7 1f             	xor    $0x1f,%edi
  8020fa:	0f 84 98 00 00 00    	je     802198 <__udivdi3+0x108>
  802100:	bb 20 00 00 00       	mov    $0x20,%ebx
  802105:	89 f9                	mov    %edi,%ecx
  802107:	89 c5                	mov    %eax,%ebp
  802109:	29 fb                	sub    %edi,%ebx
  80210b:	d3 e6                	shl    %cl,%esi
  80210d:	89 d9                	mov    %ebx,%ecx
  80210f:	d3 ed                	shr    %cl,%ebp
  802111:	89 f9                	mov    %edi,%ecx
  802113:	d3 e0                	shl    %cl,%eax
  802115:	09 ee                	or     %ebp,%esi
  802117:	89 d9                	mov    %ebx,%ecx
  802119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80211d:	89 d5                	mov    %edx,%ebp
  80211f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802123:	d3 ed                	shr    %cl,%ebp
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e2                	shl    %cl,%edx
  802129:	89 d9                	mov    %ebx,%ecx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	09 c2                	or     %eax,%edx
  80212f:	89 d0                	mov    %edx,%eax
  802131:	89 ea                	mov    %ebp,%edx
  802133:	f7 f6                	div    %esi
  802135:	89 d5                	mov    %edx,%ebp
  802137:	89 c3                	mov    %eax,%ebx
  802139:	f7 64 24 0c          	mull   0xc(%esp)
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	72 10                	jb     802151 <__udivdi3+0xc1>
  802141:	8b 74 24 08          	mov    0x8(%esp),%esi
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e6                	shl    %cl,%esi
  802149:	39 c6                	cmp    %eax,%esi
  80214b:	73 07                	jae    802154 <__udivdi3+0xc4>
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	75 03                	jne    802154 <__udivdi3+0xc4>
  802151:	83 eb 01             	sub    $0x1,%ebx
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 d8                	mov    %ebx,%eax
  802158:	89 fa                	mov    %edi,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	31 ff                	xor    %edi,%edi
  80216a:	31 db                	xor    %ebx,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d8                	mov    %ebx,%eax
  802182:	f7 f7                	div    %edi
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 c3                	mov    %eax,%ebx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 fa                	mov    %edi,%edx
  80218c:	83 c4 1c             	add    $0x1c,%esp
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5f                   	pop    %edi
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	39 ce                	cmp    %ecx,%esi
  80219a:	72 0c                	jb     8021a8 <__udivdi3+0x118>
  80219c:	31 db                	xor    %ebx,%ebx
  80219e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021a2:	0f 87 34 ff ff ff    	ja     8020dc <__udivdi3+0x4c>
  8021a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ad:	e9 2a ff ff ff       	jmp    8020dc <__udivdi3+0x4c>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 d2                	test   %edx,%edx
  8021d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 f3                	mov    %esi,%ebx
  8021e3:	89 3c 24             	mov    %edi,(%esp)
  8021e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ea:	75 1c                	jne    802208 <__umoddi3+0x48>
  8021ec:	39 f7                	cmp    %esi,%edi
  8021ee:	76 50                	jbe    802240 <__umoddi3+0x80>
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	f7 f7                	div    %edi
  8021f6:	89 d0                	mov    %edx,%eax
  8021f8:	31 d2                	xor    %edx,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	89 d0                	mov    %edx,%eax
  80220c:	77 52                	ja     802260 <__umoddi3+0xa0>
  80220e:	0f bd ea             	bsr    %edx,%ebp
  802211:	83 f5 1f             	xor    $0x1f,%ebp
  802214:	75 5a                	jne    802270 <__umoddi3+0xb0>
  802216:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80221a:	0f 82 e0 00 00 00    	jb     802300 <__umoddi3+0x140>
  802220:	39 0c 24             	cmp    %ecx,(%esp)
  802223:	0f 86 d7 00 00 00    	jbe    802300 <__umoddi3+0x140>
  802229:	8b 44 24 08          	mov    0x8(%esp),%eax
  80222d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	85 ff                	test   %edi,%edi
  802242:	89 fd                	mov    %edi,%ebp
  802244:	75 0b                	jne    802251 <__umoddi3+0x91>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f7                	div    %edi
  80224f:	89 c5                	mov    %eax,%ebp
  802251:	89 f0                	mov    %esi,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f5                	div    %ebp
  802257:	89 c8                	mov    %ecx,%eax
  802259:	f7 f5                	div    %ebp
  80225b:	89 d0                	mov    %edx,%eax
  80225d:	eb 99                	jmp    8021f8 <__umoddi3+0x38>
  80225f:	90                   	nop
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 1c             	add    $0x1c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	8b 34 24             	mov    (%esp),%esi
  802273:	bf 20 00 00 00       	mov    $0x20,%edi
  802278:	89 e9                	mov    %ebp,%ecx
  80227a:	29 ef                	sub    %ebp,%edi
  80227c:	d3 e0                	shl    %cl,%eax
  80227e:	89 f9                	mov    %edi,%ecx
  802280:	89 f2                	mov    %esi,%edx
  802282:	d3 ea                	shr    %cl,%edx
  802284:	89 e9                	mov    %ebp,%ecx
  802286:	09 c2                	or     %eax,%edx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 14 24             	mov    %edx,(%esp)
  80228d:	89 f2                	mov    %esi,%edx
  80228f:	d3 e2                	shl    %cl,%edx
  802291:	89 f9                	mov    %edi,%ecx
  802293:	89 54 24 04          	mov    %edx,0x4(%esp)
  802297:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	89 c6                	mov    %eax,%esi
  8022a1:	d3 e3                	shl    %cl,%ebx
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 d0                	mov    %edx,%eax
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	09 d8                	or     %ebx,%eax
  8022ad:	89 d3                	mov    %edx,%ebx
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	f7 34 24             	divl   (%esp)
  8022b4:	89 d6                	mov    %edx,%esi
  8022b6:	d3 e3                	shl    %cl,%ebx
  8022b8:	f7 64 24 04          	mull   0x4(%esp)
  8022bc:	39 d6                	cmp    %edx,%esi
  8022be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c2:	89 d1                	mov    %edx,%ecx
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	72 08                	jb     8022d0 <__umoddi3+0x110>
  8022c8:	75 11                	jne    8022db <__umoddi3+0x11b>
  8022ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ce:	73 0b                	jae    8022db <__umoddi3+0x11b>
  8022d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022d4:	1b 14 24             	sbb    (%esp),%edx
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	89 c3                	mov    %eax,%ebx
  8022db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022df:	29 da                	sub    %ebx,%edx
  8022e1:	19 ce                	sbb    %ecx,%esi
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	d3 e0                	shl    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	d3 ea                	shr    %cl,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	d3 ee                	shr    %cl,%esi
  8022f1:	09 d0                	or     %edx,%eax
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	83 c4 1c             	add    $0x1c,%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5f                   	pop    %edi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    
  8022fd:	8d 76 00             	lea    0x0(%esi),%esi
  802300:	29 f9                	sub    %edi,%ecx
  802302:	19 d6                	sbb    %edx,%esi
  802304:	89 74 24 04          	mov    %esi,0x4(%esp)
  802308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80230c:	e9 18 ff ff ff       	jmp    802229 <__umoddi3+0x69>
