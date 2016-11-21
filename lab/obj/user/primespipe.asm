
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
  80004c:	e8 46 15 00 00       	call   801597 <readn>
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
  800068:	68 40 28 80 00       	push   $0x802840
  80006d:	6a 15                	push   $0x15
  80006f:	68 6f 28 80 00       	push   $0x80286f
  800074:	e8 17 02 00 00       	call   800290 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 81 28 80 00       	push   $0x802881
  800084:	e8 e0 02 00 00       	call   800369 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 e1 1f 00 00       	call   802072 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 85 28 80 00       	push   $0x802885
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 6f 28 80 00       	push   $0x80286f
  8000a8:	e8 e3 01 00 00       	call   800290 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 3f 0f 00 00       	call   800ff1 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 41 2d 80 00       	push   $0x802d41
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 6f 28 80 00       	push   $0x80286f
  8000c3:	e8 c8 01 00 00       	call   800290 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 f5 12 00 00       	call   8013ca <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 ea 12 00 00       	call   8013ca <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 d4 12 00 00       	call   8013ca <close>
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
  800106:	e8 8c 14 00 00       	call   801597 <readn>
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
  800126:	68 8e 28 80 00       	push   $0x80288e
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 6f 28 80 00       	push   $0x80286f
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
  800149:	e8 92 14 00 00       	call   8015e0 <write>
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
  800168:	68 aa 28 80 00       	push   $0x8028aa
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 6f 28 80 00       	push   $0x80286f
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
  800180:	c7 05 00 30 80 00 c4 	movl   $0x8028c4,0x803000
  800187:	28 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 df 1e 00 00       	call   802072 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 85 28 80 00       	push   $0x802885
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 6f 28 80 00       	push   $0x80286f
  8001aa:	e8 e1 00 00 00       	call   800290 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 3d 0e 00 00       	call   800ff1 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 41 2d 80 00       	push   $0x802d41
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 6f 28 80 00       	push   $0x80286f
  8001c5:	e8 c6 00 00 00       	call   800290 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 f1 11 00 00       	call   8013ca <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 db 11 00 00       	call   8013ca <close>

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
  800205:	e8 d6 13 00 00       	call   8015e0 <write>
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
  800221:	68 cf 28 80 00       	push   $0x8028cf
  800226:	6a 4a                	push   $0x4a
  800228:	68 6f 28 80 00       	push   $0x80286f
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
  800255:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8002ae:	68 f4 28 80 00       	push   $0x8028f4
  8002b3:	e8 b1 00 00 00       	call   800369 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b8:	83 c4 18             	add    $0x18,%esp
  8002bb:	53                   	push   %ebx
  8002bc:	ff 75 10             	pushl  0x10(%ebp)
  8002bf:	e8 54 00 00 00       	call   800318 <vcprintf>
	cprintf("\n");
  8002c4:	c7 04 24 83 28 80 00 	movl   $0x802883,(%esp)
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
  8003cc:	e8 cf 21 00 00       	call   8025a0 <__udivdi3>
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
  80040f:	e8 bc 22 00 00       	call   8026d0 <__umoddi3>
  800414:	83 c4 14             	add    $0x14,%esp
  800417:	0f be 80 17 29 80 00 	movsbl 0x802917(%eax),%eax
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
  800513:	ff 24 85 60 2a 80 00 	jmp    *0x802a60(,%eax,4)
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
  8005d7:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	75 18                	jne    8005fa <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005e2:	50                   	push   %eax
  8005e3:	68 2f 29 80 00       	push   $0x80292f
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
  8005fb:	68 65 2e 80 00       	push   $0x802e65
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
  80061f:	b8 28 29 80 00       	mov    $0x802928,%eax
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
  800c9a:	68 1f 2c 80 00       	push   $0x802c1f
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 3c 2c 80 00       	push   $0x802c3c
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
  800d1b:	68 1f 2c 80 00       	push   $0x802c1f
  800d20:	6a 23                	push   $0x23
  800d22:	68 3c 2c 80 00       	push   $0x802c3c
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
  800d5d:	68 1f 2c 80 00       	push   $0x802c1f
  800d62:	6a 23                	push   $0x23
  800d64:	68 3c 2c 80 00       	push   $0x802c3c
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
  800d9f:	68 1f 2c 80 00       	push   $0x802c1f
  800da4:	6a 23                	push   $0x23
  800da6:	68 3c 2c 80 00       	push   $0x802c3c
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
  800de1:	68 1f 2c 80 00       	push   $0x802c1f
  800de6:	6a 23                	push   $0x23
  800de8:	68 3c 2c 80 00       	push   $0x802c3c
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
  800e23:	68 1f 2c 80 00       	push   $0x802c1f
  800e28:	6a 23                	push   $0x23
  800e2a:	68 3c 2c 80 00       	push   $0x802c3c
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
  800e65:	68 1f 2c 80 00       	push   $0x802c1f
  800e6a:	6a 23                	push   $0x23
  800e6c:	68 3c 2c 80 00       	push   $0x802c3c
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
  800ec9:	68 1f 2c 80 00       	push   $0x802c1f
  800ece:	6a 23                	push   $0x23
  800ed0:	68 3c 2c 80 00       	push   $0x802c3c
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

00800ee2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee8:	ba 00 00 00 00       	mov    $0x0,%edx
  800eed:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ef2:	89 d1                	mov    %edx,%ecx
  800ef4:	89 d3                	mov    %edx,%ebx
  800ef6:	89 d7                	mov    %edx,%edi
  800ef8:	89 d6                	mov    %edx,%esi
  800efa:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	53                   	push   %ebx
  800f05:	83 ec 04             	sub    $0x4,%esp
  800f08:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f0b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800f0d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f11:	75 14                	jne    800f27 <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800f13:	83 ec 04             	sub    $0x4,%esp
  800f16:	68 4c 2c 80 00       	push   $0x802c4c
  800f1b:	6a 22                	push   $0x22
  800f1d:	68 2f 2d 80 00       	push   $0x802d2f
  800f22:	e8 69 f3 ff ff       	call   800290 <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800f27:	89 d8                	mov    %ebx,%eax
  800f29:	c1 e8 0c             	shr    $0xc,%eax
  800f2c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f33:	f6 c4 08             	test   $0x8,%ah
  800f36:	75 14                	jne    800f4c <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	68 88 2c 80 00       	push   $0x802c88
  800f40:	6a 27                	push   $0x27
  800f42:	68 2f 2d 80 00       	push   $0x802d2f
  800f47:	e8 44 f3 ff ff       	call   800290 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800f4c:	83 ec 04             	sub    $0x4,%esp
  800f4f:	6a 07                	push   $0x7
  800f51:	68 00 f0 7f 00       	push   $0x7ff000
  800f56:	6a 00                	push   $0x0
  800f58:	e8 94 fd ff ff       	call   800cf1 <sys_page_alloc>
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	79 14                	jns    800f78 <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 b8 2c 80 00       	push   $0x802cb8
  800f6c:	6a 2f                	push   $0x2f
  800f6e:	68 2f 2d 80 00       	push   $0x802d2f
  800f73:	e8 18 f3 ff ff       	call   800290 <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f78:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f7e:	83 ec 04             	sub    $0x4,%esp
  800f81:	68 00 10 00 00       	push   $0x1000
  800f86:	53                   	push   %ebx
  800f87:	68 00 f0 7f 00       	push   $0x7ff000
  800f8c:	e8 ef fa ff ff       	call   800a80 <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f91:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f98:	53                   	push   %ebx
  800f99:	6a 00                	push   $0x0
  800f9b:	68 00 f0 7f 00       	push   $0x7ff000
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 8d fd ff ff       	call   800d34 <sys_page_map>
  800fa7:	83 c4 20             	add    $0x20,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	79 14                	jns    800fc2 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	68 e4 2c 80 00       	push   $0x802ce4
  800fb6:	6a 34                	push   $0x34
  800fb8:	68 2f 2d 80 00       	push   $0x802d2f
  800fbd:	e8 ce f2 ff ff       	call   800290 <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fc2:	83 ec 08             	sub    $0x8,%esp
  800fc5:	68 00 f0 7f 00       	push   $0x7ff000
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 a5 fd ff ff       	call   800d76 <sys_page_unmap>
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	79 14                	jns    800fec <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800fd8:	83 ec 04             	sub    $0x4,%esp
  800fdb:	68 0c 2d 80 00       	push   $0x802d0c
  800fe0:	6a 37                	push   $0x37
  800fe2:	68 2f 2d 80 00       	push   $0x802d2f
  800fe7:	e8 a4 f2 ff ff       	call   800290 <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800fec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	57                   	push   %edi
  800ff5:	56                   	push   %esi
  800ff6:	53                   	push   %ebx
  800ff7:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800ffa:	68 01 0f 80 00       	push   $0x800f01
  800fff:	e8 77 13 00 00       	call   80237b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801004:	b8 07 00 00 00       	mov    $0x7,%eax
  801009:	cd 30                	int    $0x30
  80100b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80100e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  801011:	83 c4 10             	add    $0x10,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	79 15                	jns    80102d <fork+0x3c>
		panic("sys_exofork: %e", envid);
  801018:	50                   	push   %eax
  801019:	68 3a 2d 80 00       	push   $0x802d3a
  80101e:	68 8d 00 00 00       	push   $0x8d
  801023:	68 2f 2d 80 00       	push   $0x802d2f
  801028:	e8 63 f2 ff ff       	call   800290 <_panic>
  80102d:	be 00 00 00 00       	mov    $0x0,%esi
  801032:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  801037:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80103b:	75 21                	jne    80105e <fork+0x6d>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  80103d:	e8 71 fc ff ff       	call   800cb3 <sys_getenvid>
  801042:	25 ff 03 00 00       	and    $0x3ff,%eax
  801047:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80104a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80104f:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801054:	b8 00 00 00 00       	mov    $0x0,%eax
  801059:	e9 aa 01 00 00       	jmp    801208 <fork+0x217>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  80105e:	89 f0                	mov    %esi,%eax
  801060:	c1 e8 16             	shr    $0x16,%eax
  801063:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106a:	a8 01                	test   $0x1,%al
  80106c:	0f 84 f9 00 00 00    	je     80116b <fork+0x17a>
  801072:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801079:	a8 05                	test   $0x5,%al
  80107b:	0f 84 ea 00 00 00    	je     80116b <fork+0x17a>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
  801081:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801088:	a8 02                	test   $0x2,%al
  80108a:	75 1c                	jne    8010a8 <fork+0xb7>
  80108c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801093:	f6 c4 08             	test   $0x8,%ah
  801096:	75 10                	jne    8010a8 <fork+0xb7>
  801098:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80109f:	f6 c4 04             	test   $0x4,%ah
  8010a2:	0f 84 99 00 00 00    	je     801141 <fork+0x150>
	{
		if(uvpt[pn] & PTE_SHARE)
  8010a8:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010af:	f6 c4 04             	test   $0x4,%ah
  8010b2:	74 0f                	je     8010c3 <fork+0xd2>
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
  8010b4:	8b 3c 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edi
  8010bb:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8010c1:	eb 2d                	jmp    8010f0 <fork+0xff>
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  8010c3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
			perm = PTE_P|PTE_U|PTE_COW;
  8010ca:	bf 05 08 00 00       	mov    $0x805,%edi
	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
	{
		if(uvpt[pn] & PTE_SHARE)
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  8010cf:	a8 02                	test   $0x2,%al
  8010d1:	75 1d                	jne    8010f0 <fork+0xff>
  8010d3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010da:	25 00 08 00 00       	and    $0x800,%eax
			perm = PTE_P|PTE_U|PTE_COW;
  8010df:	83 f8 01             	cmp    $0x1,%eax
  8010e2:	19 ff                	sbb    %edi,%edi
  8010e4:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  8010ea:	81 c7 05 08 00 00    	add    $0x805,%edi
		}

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm))) < 0)
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f8:	56                   	push   %esi
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 34 fc ff ff       	call   800d34 <sys_page_map>
  801100:	83 c4 20             	add    $0x20,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	79 12                	jns    801119 <fork+0x128>
			panic("fork: sys_page_map: %e", r);
  801107:	50                   	push   %eax
  801108:	68 4a 2d 80 00       	push   $0x802d4a
  80110d:	6a 62                	push   $0x62
  80110f:	68 2f 2d 80 00       	push   $0x802d2f
  801114:	e8 77 f1 ff ff       	call   800290 <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm))) < 0)
  801119:	83 ec 0c             	sub    $0xc,%esp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	6a 00                	push   $0x0
  801120:	56                   	push   %esi
  801121:	6a 00                	push   $0x0
  801123:	e8 0c fc ff ff       	call   800d34 <sys_page_map>
  801128:	83 c4 20             	add    $0x20,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	79 3c                	jns    80116b <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  80112f:	50                   	push   %eax
  801130:	68 4a 2d 80 00       	push   $0x802d4a
  801135:	6a 65                	push   $0x65
  801137:	68 2f 2d 80 00       	push   $0x802d2f
  80113c:	e8 4f f1 ff ff       	call   800290 <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	6a 05                	push   $0x5
  801146:	56                   	push   %esi
  801147:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114a:	56                   	push   %esi
  80114b:	6a 00                	push   $0x0
  80114d:	e8 e2 fb ff ff       	call   800d34 <sys_page_map>
  801152:	83 c4 20             	add    $0x20,%esp
  801155:	85 c0                	test   %eax,%eax
  801157:	79 12                	jns    80116b <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  801159:	50                   	push   %eax
  80115a:	68 4a 2d 80 00       	push   $0x802d4a
  80115f:	6a 6a                	push   $0x6a
  801161:	68 2f 2d 80 00       	push   $0x802d2f
  801166:	e8 25 f1 ff ff       	call   800290 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  80116b:	83 c3 01             	add    $0x1,%ebx
  80116e:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801174:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80117a:	0f 85 de fe ff ff    	jne    80105e <fork+0x6d>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	6a 07                	push   $0x7
  801185:	68 00 f0 bf ee       	push   $0xeebff000
  80118a:	ff 75 e0             	pushl  -0x20(%ebp)
  80118d:	e8 5f fb ff ff       	call   800cf1 <sys_page_alloc>
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	79 15                	jns    8011ae <fork+0x1bd>
		panic("sys_page_alloc: %e", r);
  801199:	50                   	push   %eax
  80119a:	68 61 2d 80 00       	push   $0x802d61
  80119f:	68 9e 00 00 00       	push   $0x9e
  8011a4:	68 2f 2d 80 00       	push   $0x802d2f
  8011a9:	e8 e2 f0 ff ff       	call   800290 <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	68 f8 23 80 00       	push   $0x8023f8
  8011b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b9:	e8 7e fc ff ff       	call   800e3c <sys_env_set_pgfault_upcall>
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	79 17                	jns    8011dc <fork+0x1eb>
		panic("sys_pgfault_upcall error");
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	68 74 2d 80 00       	push   $0x802d74
  8011cd:	68 a1 00 00 00       	push   $0xa1
  8011d2:	68 2f 2d 80 00       	push   $0x802d2f
  8011d7:	e8 b4 f0 ff ff       	call   800290 <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	6a 02                	push   $0x2
  8011e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e4:	e8 cf fb ff ff       	call   800db8 <sys_env_set_status>
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	79 15                	jns    801205 <fork+0x214>
		panic("sys_env_set_status: %e", r);
  8011f0:	50                   	push   %eax
  8011f1:	68 8d 2d 80 00       	push   $0x802d8d
  8011f6:	68 a7 00 00 00       	push   $0xa7
  8011fb:	68 2f 2d 80 00       	push   $0x802d2f
  801200:	e8 8b f0 ff ff       	call   800290 <_panic>

	return envid;
  801205:	8b 45 e0             	mov    -0x20(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  801208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <sfork>:

// Challenge!
int
sfork(void)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801216:	68 a4 2d 80 00       	push   $0x802da4
  80121b:	68 b2 00 00 00       	push   $0xb2
  801220:	68 2f 2d 80 00       	push   $0x802d2f
  801225:	e8 66 f0 ff ff       	call   800290 <_panic>

0080122a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122d:	8b 45 08             	mov    0x8(%ebp),%eax
  801230:	05 00 00 00 30       	add    $0x30000000,%eax
  801235:	c1 e8 0c             	shr    $0xc,%eax
}
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80123d:	8b 45 08             	mov    0x8(%ebp),%eax
  801240:	05 00 00 00 30       	add    $0x30000000,%eax
  801245:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80124a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801257:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	c1 ea 16             	shr    $0x16,%edx
  801261:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801268:	f6 c2 01             	test   $0x1,%dl
  80126b:	74 11                	je     80127e <fd_alloc+0x2d>
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	c1 ea 0c             	shr    $0xc,%edx
  801272:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801279:	f6 c2 01             	test   $0x1,%dl
  80127c:	75 09                	jne    801287 <fd_alloc+0x36>
			*fd_store = fd;
  80127e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801280:	b8 00 00 00 00       	mov    $0x0,%eax
  801285:	eb 17                	jmp    80129e <fd_alloc+0x4d>
  801287:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80128c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801291:	75 c9                	jne    80125c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801293:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801299:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012a6:	83 f8 1f             	cmp    $0x1f,%eax
  8012a9:	77 36                	ja     8012e1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ab:	c1 e0 0c             	shl    $0xc,%eax
  8012ae:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	c1 ea 16             	shr    $0x16,%edx
  8012b8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012bf:	f6 c2 01             	test   $0x1,%dl
  8012c2:	74 24                	je     8012e8 <fd_lookup+0x48>
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	c1 ea 0c             	shr    $0xc,%edx
  8012c9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d0:	f6 c2 01             	test   $0x1,%dl
  8012d3:	74 1a                	je     8012ef <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d8:	89 02                	mov    %eax,(%edx)
	return 0;
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
  8012df:	eb 13                	jmp    8012f4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e6:	eb 0c                	jmp    8012f4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ed:	eb 05                	jmp    8012f4 <fd_lookup+0x54>
  8012ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ff:	ba 38 2e 80 00       	mov    $0x802e38,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801304:	eb 13                	jmp    801319 <dev_lookup+0x23>
  801306:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801309:	39 08                	cmp    %ecx,(%eax)
  80130b:	75 0c                	jne    801319 <dev_lookup+0x23>
			*dev = devtab[i];
  80130d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801310:	89 01                	mov    %eax,(%ecx)
			return 0;
  801312:	b8 00 00 00 00       	mov    $0x0,%eax
  801317:	eb 2e                	jmp    801347 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801319:	8b 02                	mov    (%edx),%eax
  80131b:	85 c0                	test   %eax,%eax
  80131d:	75 e7                	jne    801306 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80131f:	a1 08 40 80 00       	mov    0x804008,%eax
  801324:	8b 40 48             	mov    0x48(%eax),%eax
  801327:	83 ec 04             	sub    $0x4,%esp
  80132a:	51                   	push   %ecx
  80132b:	50                   	push   %eax
  80132c:	68 bc 2d 80 00       	push   $0x802dbc
  801331:	e8 33 f0 ff ff       	call   800369 <cprintf>
	*dev = 0;
  801336:	8b 45 0c             	mov    0xc(%ebp),%eax
  801339:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	56                   	push   %esi
  80134d:	53                   	push   %ebx
  80134e:	83 ec 10             	sub    $0x10,%esp
  801351:	8b 75 08             	mov    0x8(%ebp),%esi
  801354:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801357:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135a:	50                   	push   %eax
  80135b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801361:	c1 e8 0c             	shr    $0xc,%eax
  801364:	50                   	push   %eax
  801365:	e8 36 ff ff ff       	call   8012a0 <fd_lookup>
  80136a:	83 c4 08             	add    $0x8,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 05                	js     801376 <fd_close+0x2d>
	    || fd != fd2)
  801371:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801374:	74 0c                	je     801382 <fd_close+0x39>
		return (must_exist ? r : 0);
  801376:	84 db                	test   %bl,%bl
  801378:	ba 00 00 00 00       	mov    $0x0,%edx
  80137d:	0f 44 c2             	cmove  %edx,%eax
  801380:	eb 41                	jmp    8013c3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801388:	50                   	push   %eax
  801389:	ff 36                	pushl  (%esi)
  80138b:	e8 66 ff ff ff       	call   8012f6 <dev_lookup>
  801390:	89 c3                	mov    %eax,%ebx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 1a                	js     8013b3 <fd_close+0x6a>
		if (dev->dev_close)
  801399:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80139f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	74 0b                	je     8013b3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	56                   	push   %esi
  8013ac:	ff d0                	call   *%eax
  8013ae:	89 c3                	mov    %eax,%ebx
  8013b0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	56                   	push   %esi
  8013b7:	6a 00                	push   $0x0
  8013b9:	e8 b8 f9 ff ff       	call   800d76 <sys_page_unmap>
	return r;
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	89 d8                	mov    %ebx,%eax
}
  8013c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	ff 75 08             	pushl  0x8(%ebp)
  8013d7:	e8 c4 fe ff ff       	call   8012a0 <fd_lookup>
  8013dc:	83 c4 08             	add    $0x8,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 10                	js     8013f3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	6a 01                	push   $0x1
  8013e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013eb:	e8 59 ff ff ff       	call   801349 <fd_close>
  8013f0:	83 c4 10             	add    $0x10,%esp
}
  8013f3:	c9                   	leave  
  8013f4:	c3                   	ret    

008013f5 <close_all>:

void
close_all(void)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	53                   	push   %ebx
  8013f9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801401:	83 ec 0c             	sub    $0xc,%esp
  801404:	53                   	push   %ebx
  801405:	e8 c0 ff ff ff       	call   8013ca <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80140a:	83 c3 01             	add    $0x1,%ebx
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	83 fb 20             	cmp    $0x20,%ebx
  801413:	75 ec                	jne    801401 <close_all+0xc>
		close(i);
}
  801415:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	57                   	push   %edi
  80141e:	56                   	push   %esi
  80141f:	53                   	push   %ebx
  801420:	83 ec 2c             	sub    $0x2c,%esp
  801423:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801426:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801429:	50                   	push   %eax
  80142a:	ff 75 08             	pushl  0x8(%ebp)
  80142d:	e8 6e fe ff ff       	call   8012a0 <fd_lookup>
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	0f 88 c1 00 00 00    	js     8014fe <dup+0xe4>
		return r;
	close(newfdnum);
  80143d:	83 ec 0c             	sub    $0xc,%esp
  801440:	56                   	push   %esi
  801441:	e8 84 ff ff ff       	call   8013ca <close>

	newfd = INDEX2FD(newfdnum);
  801446:	89 f3                	mov    %esi,%ebx
  801448:	c1 e3 0c             	shl    $0xc,%ebx
  80144b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801451:	83 c4 04             	add    $0x4,%esp
  801454:	ff 75 e4             	pushl  -0x1c(%ebp)
  801457:	e8 de fd ff ff       	call   80123a <fd2data>
  80145c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80145e:	89 1c 24             	mov    %ebx,(%esp)
  801461:	e8 d4 fd ff ff       	call   80123a <fd2data>
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80146c:	89 f8                	mov    %edi,%eax
  80146e:	c1 e8 16             	shr    $0x16,%eax
  801471:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801478:	a8 01                	test   $0x1,%al
  80147a:	74 37                	je     8014b3 <dup+0x99>
  80147c:	89 f8                	mov    %edi,%eax
  80147e:	c1 e8 0c             	shr    $0xc,%eax
  801481:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801488:	f6 c2 01             	test   $0x1,%dl
  80148b:	74 26                	je     8014b3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80148d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801494:	83 ec 0c             	sub    $0xc,%esp
  801497:	25 07 0e 00 00       	and    $0xe07,%eax
  80149c:	50                   	push   %eax
  80149d:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a0:	6a 00                	push   $0x0
  8014a2:	57                   	push   %edi
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 8a f8 ff ff       	call   800d34 <sys_page_map>
  8014aa:	89 c7                	mov    %eax,%edi
  8014ac:	83 c4 20             	add    $0x20,%esp
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	78 2e                	js     8014e1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014b6:	89 d0                	mov    %edx,%eax
  8014b8:	c1 e8 0c             	shr    $0xc,%eax
  8014bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ca:	50                   	push   %eax
  8014cb:	53                   	push   %ebx
  8014cc:	6a 00                	push   $0x0
  8014ce:	52                   	push   %edx
  8014cf:	6a 00                	push   $0x0
  8014d1:	e8 5e f8 ff ff       	call   800d34 <sys_page_map>
  8014d6:	89 c7                	mov    %eax,%edi
  8014d8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014db:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014dd:	85 ff                	test   %edi,%edi
  8014df:	79 1d                	jns    8014fe <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	6a 00                	push   $0x0
  8014e7:	e8 8a f8 ff ff       	call   800d76 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ec:	83 c4 08             	add    $0x8,%esp
  8014ef:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f2:	6a 00                	push   $0x0
  8014f4:	e8 7d f8 ff ff       	call   800d76 <sys_page_unmap>
	return r;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	89 f8                	mov    %edi,%eax
}
  8014fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5f                   	pop    %edi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	53                   	push   %ebx
  80150a:	83 ec 14             	sub    $0x14,%esp
  80150d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801510:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	53                   	push   %ebx
  801515:	e8 86 fd ff ff       	call   8012a0 <fd_lookup>
  80151a:	83 c4 08             	add    $0x8,%esp
  80151d:	89 c2                	mov    %eax,%edx
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 6d                	js     801590 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152d:	ff 30                	pushl  (%eax)
  80152f:	e8 c2 fd ff ff       	call   8012f6 <dev_lookup>
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	78 4c                	js     801587 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80153e:	8b 42 08             	mov    0x8(%edx),%eax
  801541:	83 e0 03             	and    $0x3,%eax
  801544:	83 f8 01             	cmp    $0x1,%eax
  801547:	75 21                	jne    80156a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801549:	a1 08 40 80 00       	mov    0x804008,%eax
  80154e:	8b 40 48             	mov    0x48(%eax),%eax
  801551:	83 ec 04             	sub    $0x4,%esp
  801554:	53                   	push   %ebx
  801555:	50                   	push   %eax
  801556:	68 fd 2d 80 00       	push   $0x802dfd
  80155b:	e8 09 ee ff ff       	call   800369 <cprintf>
		return -E_INVAL;
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801568:	eb 26                	jmp    801590 <read+0x8a>
	}
	if (!dev->dev_read)
  80156a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156d:	8b 40 08             	mov    0x8(%eax),%eax
  801570:	85 c0                	test   %eax,%eax
  801572:	74 17                	je     80158b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801574:	83 ec 04             	sub    $0x4,%esp
  801577:	ff 75 10             	pushl  0x10(%ebp)
  80157a:	ff 75 0c             	pushl  0xc(%ebp)
  80157d:	52                   	push   %edx
  80157e:	ff d0                	call   *%eax
  801580:	89 c2                	mov    %eax,%edx
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	eb 09                	jmp    801590 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801587:	89 c2                	mov    %eax,%edx
  801589:	eb 05                	jmp    801590 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80158b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801590:	89 d0                	mov    %edx,%eax
  801592:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	57                   	push   %edi
  80159b:	56                   	push   %esi
  80159c:	53                   	push   %ebx
  80159d:	83 ec 0c             	sub    $0xc,%esp
  8015a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ab:	eb 21                	jmp    8015ce <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ad:	83 ec 04             	sub    $0x4,%esp
  8015b0:	89 f0                	mov    %esi,%eax
  8015b2:	29 d8                	sub    %ebx,%eax
  8015b4:	50                   	push   %eax
  8015b5:	89 d8                	mov    %ebx,%eax
  8015b7:	03 45 0c             	add    0xc(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	57                   	push   %edi
  8015bc:	e8 45 ff ff ff       	call   801506 <read>
		if (m < 0)
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 10                	js     8015d8 <readn+0x41>
			return m;
		if (m == 0)
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	74 0a                	je     8015d6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015cc:	01 c3                	add    %eax,%ebx
  8015ce:	39 f3                	cmp    %esi,%ebx
  8015d0:	72 db                	jb     8015ad <readn+0x16>
  8015d2:	89 d8                	mov    %ebx,%eax
  8015d4:	eb 02                	jmp    8015d8 <readn+0x41>
  8015d6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5e                   	pop    %esi
  8015dd:	5f                   	pop    %edi
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	53                   	push   %ebx
  8015e4:	83 ec 14             	sub    $0x14,%esp
  8015e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	53                   	push   %ebx
  8015ef:	e8 ac fc ff ff       	call   8012a0 <fd_lookup>
  8015f4:	83 c4 08             	add    $0x8,%esp
  8015f7:	89 c2                	mov    %eax,%edx
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 68                	js     801665 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801607:	ff 30                	pushl  (%eax)
  801609:	e8 e8 fc ff ff       	call   8012f6 <dev_lookup>
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	78 47                	js     80165c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801615:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801618:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80161c:	75 21                	jne    80163f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80161e:	a1 08 40 80 00       	mov    0x804008,%eax
  801623:	8b 40 48             	mov    0x48(%eax),%eax
  801626:	83 ec 04             	sub    $0x4,%esp
  801629:	53                   	push   %ebx
  80162a:	50                   	push   %eax
  80162b:	68 19 2e 80 00       	push   $0x802e19
  801630:	e8 34 ed ff ff       	call   800369 <cprintf>
		return -E_INVAL;
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163d:	eb 26                	jmp    801665 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80163f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801642:	8b 52 0c             	mov    0xc(%edx),%edx
  801645:	85 d2                	test   %edx,%edx
  801647:	74 17                	je     801660 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801649:	83 ec 04             	sub    $0x4,%esp
  80164c:	ff 75 10             	pushl  0x10(%ebp)
  80164f:	ff 75 0c             	pushl  0xc(%ebp)
  801652:	50                   	push   %eax
  801653:	ff d2                	call   *%edx
  801655:	89 c2                	mov    %eax,%edx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	eb 09                	jmp    801665 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	eb 05                	jmp    801665 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801660:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801665:	89 d0                	mov    %edx,%eax
  801667:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <seek>:

int
seek(int fdnum, off_t offset)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801672:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	ff 75 08             	pushl  0x8(%ebp)
  801679:	e8 22 fc ff ff       	call   8012a0 <fd_lookup>
  80167e:	83 c4 08             	add    $0x8,%esp
  801681:	85 c0                	test   %eax,%eax
  801683:	78 0e                	js     801693 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801685:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801688:	8b 55 0c             	mov    0xc(%ebp),%edx
  80168b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80168e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	53                   	push   %ebx
  801699:	83 ec 14             	sub    $0x14,%esp
  80169c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	53                   	push   %ebx
  8016a4:	e8 f7 fb ff ff       	call   8012a0 <fd_lookup>
  8016a9:	83 c4 08             	add    $0x8,%esp
  8016ac:	89 c2                	mov    %eax,%edx
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 65                	js     801717 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b2:	83 ec 08             	sub    $0x8,%esp
  8016b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b8:	50                   	push   %eax
  8016b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bc:	ff 30                	pushl  (%eax)
  8016be:	e8 33 fc ff ff       	call   8012f6 <dev_lookup>
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 44                	js     80170e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d1:	75 21                	jne    8016f4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016d3:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d8:	8b 40 48             	mov    0x48(%eax),%eax
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	53                   	push   %ebx
  8016df:	50                   	push   %eax
  8016e0:	68 dc 2d 80 00       	push   $0x802ddc
  8016e5:	e8 7f ec ff ff       	call   800369 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f2:	eb 23                	jmp    801717 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f7:	8b 52 18             	mov    0x18(%edx),%edx
  8016fa:	85 d2                	test   %edx,%edx
  8016fc:	74 14                	je     801712 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	ff 75 0c             	pushl  0xc(%ebp)
  801704:	50                   	push   %eax
  801705:	ff d2                	call   *%edx
  801707:	89 c2                	mov    %eax,%edx
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	eb 09                	jmp    801717 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170e:	89 c2                	mov    %eax,%edx
  801710:	eb 05                	jmp    801717 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801712:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801717:	89 d0                	mov    %edx,%eax
  801719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	53                   	push   %ebx
  801722:	83 ec 14             	sub    $0x14,%esp
  801725:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801728:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	ff 75 08             	pushl  0x8(%ebp)
  80172f:	e8 6c fb ff ff       	call   8012a0 <fd_lookup>
  801734:	83 c4 08             	add    $0x8,%esp
  801737:	89 c2                	mov    %eax,%edx
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 58                	js     801795 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173d:	83 ec 08             	sub    $0x8,%esp
  801740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801743:	50                   	push   %eax
  801744:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801747:	ff 30                	pushl  (%eax)
  801749:	e8 a8 fb ff ff       	call   8012f6 <dev_lookup>
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 37                	js     80178c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801758:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80175c:	74 32                	je     801790 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80175e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801761:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801768:	00 00 00 
	stat->st_isdir = 0;
  80176b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801772:	00 00 00 
	stat->st_dev = dev;
  801775:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	53                   	push   %ebx
  80177f:	ff 75 f0             	pushl  -0x10(%ebp)
  801782:	ff 50 14             	call   *0x14(%eax)
  801785:	89 c2                	mov    %eax,%edx
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	eb 09                	jmp    801795 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178c:	89 c2                	mov    %eax,%edx
  80178e:	eb 05                	jmp    801795 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801790:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801795:	89 d0                	mov    %edx,%eax
  801797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	56                   	push   %esi
  8017a0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a1:	83 ec 08             	sub    $0x8,%esp
  8017a4:	6a 00                	push   $0x0
  8017a6:	ff 75 08             	pushl  0x8(%ebp)
  8017a9:	e8 e3 01 00 00       	call   801991 <open>
  8017ae:	89 c3                	mov    %eax,%ebx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 1b                	js     8017d2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b7:	83 ec 08             	sub    $0x8,%esp
  8017ba:	ff 75 0c             	pushl  0xc(%ebp)
  8017bd:	50                   	push   %eax
  8017be:	e8 5b ff ff ff       	call   80171e <fstat>
  8017c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c5:	89 1c 24             	mov    %ebx,(%esp)
  8017c8:	e8 fd fb ff ff       	call   8013ca <close>
	return r;
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	89 f0                	mov    %esi,%eax
}
  8017d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d5:	5b                   	pop    %ebx
  8017d6:	5e                   	pop    %esi
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	56                   	push   %esi
  8017dd:	53                   	push   %ebx
  8017de:	89 c6                	mov    %eax,%esi
  8017e0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017e2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e9:	75 12                	jne    8017fd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017eb:	83 ec 0c             	sub    $0xc,%esp
  8017ee:	6a 01                	push   $0x1
  8017f0:	e8 29 0d 00 00       	call   80251e <ipc_find_env>
  8017f5:	a3 00 40 80 00       	mov    %eax,0x804000
  8017fa:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017fd:	6a 07                	push   $0x7
  8017ff:	68 00 50 80 00       	push   $0x805000
  801804:	56                   	push   %esi
  801805:	ff 35 00 40 80 00    	pushl  0x804000
  80180b:	e8 82 0c 00 00       	call   802492 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801810:	83 c4 0c             	add    $0xc,%esp
  801813:	6a 00                	push   $0x0
  801815:	53                   	push   %ebx
  801816:	6a 00                	push   $0x0
  801818:	e8 00 0c 00 00       	call   80241d <ipc_recv>
}
  80181d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801820:	5b                   	pop    %ebx
  801821:	5e                   	pop    %esi
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	8b 40 0c             	mov    0xc(%eax),%eax
  801830:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801835:	8b 45 0c             	mov    0xc(%ebp),%eax
  801838:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	b8 02 00 00 00       	mov    $0x2,%eax
  801847:	e8 8d ff ff ff       	call   8017d9 <fsipc>
}
  80184c:	c9                   	leave  
  80184d:	c3                   	ret    

0080184e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	8b 40 0c             	mov    0xc(%eax),%eax
  80185a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 06 00 00 00       	mov    $0x6,%eax
  801869:	e8 6b ff ff ff       	call   8017d9 <fsipc>
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devfile_stat>:
                return ((ssize_t)r);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	53                   	push   %ebx
  801874:	83 ec 04             	sub    $0x4,%esp
  801877:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 05 00 00 00       	mov    $0x5,%eax
  80188f:	e8 45 ff ff ff       	call   8017d9 <fsipc>
  801894:	85 c0                	test   %eax,%eax
  801896:	78 2c                	js     8018c4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801898:	83 ec 08             	sub    $0x8,%esp
  80189b:	68 00 50 80 00       	push   $0x805000
  8018a0:	53                   	push   %ebx
  8018a1:	e8 48 f0 ff ff       	call   8008ee <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a6:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b1:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	83 ec 0c             	sub    $0xc,%esp
  8018cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018d7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018dc:	0f 47 c2             	cmova  %edx,%eax
	int r;
	if(n > (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t))))
	{
		n = (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t)));
	}
		fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018df:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e5:	89 15 00 50 80 00    	mov    %edx,0x805000
		fsipcbuf.write.req_n = n;
  8018eb:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove((void *)fsipcbuf.write.req_buf, buf, n);
  8018f0:	50                   	push   %eax
  8018f1:	ff 75 0c             	pushl  0xc(%ebp)
  8018f4:	68 08 50 80 00       	push   $0x805008
  8018f9:	e8 82 f1 ff ff       	call   800a80 <memmove>
		r = fsipc(FSREQ_WRITE, NULL);
  8018fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801903:	b8 04 00 00 00       	mov    $0x4,%eax
  801908:	e8 cc fe ff ff       	call   8017d9 <fsipc>
                return ((ssize_t)r);
}
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	8b 40 0c             	mov    0xc(%eax),%eax
  80191d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801922:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801928:	ba 00 00 00 00       	mov    $0x0,%edx
  80192d:	b8 03 00 00 00       	mov    $0x3,%eax
  801932:	e8 a2 fe ff ff       	call   8017d9 <fsipc>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 4b                	js     801988 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80193d:	39 c6                	cmp    %eax,%esi
  80193f:	73 16                	jae    801957 <devfile_read+0x48>
  801941:	68 4c 2e 80 00       	push   $0x802e4c
  801946:	68 53 2e 80 00       	push   $0x802e53
  80194b:	6a 7c                	push   $0x7c
  80194d:	68 68 2e 80 00       	push   $0x802e68
  801952:	e8 39 e9 ff ff       	call   800290 <_panic>
	assert(r <= PGSIZE);
  801957:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195c:	7e 16                	jle    801974 <devfile_read+0x65>
  80195e:	68 73 2e 80 00       	push   $0x802e73
  801963:	68 53 2e 80 00       	push   $0x802e53
  801968:	6a 7d                	push   $0x7d
  80196a:	68 68 2e 80 00       	push   $0x802e68
  80196f:	e8 1c e9 ff ff       	call   800290 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801974:	83 ec 04             	sub    $0x4,%esp
  801977:	50                   	push   %eax
  801978:	68 00 50 80 00       	push   $0x805000
  80197d:	ff 75 0c             	pushl  0xc(%ebp)
  801980:	e8 fb f0 ff ff       	call   800a80 <memmove>
	return r;
  801985:	83 c4 10             	add    $0x10,%esp
}
  801988:	89 d8                	mov    %ebx,%eax
  80198a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5e                   	pop    %esi
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	53                   	push   %ebx
  801995:	83 ec 20             	sub    $0x20,%esp
  801998:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80199b:	53                   	push   %ebx
  80199c:	e8 14 ef ff ff       	call   8008b5 <strlen>
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a9:	7f 67                	jg     801a12 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ab:	83 ec 0c             	sub    $0xc,%esp
  8019ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b1:	50                   	push   %eax
  8019b2:	e8 9a f8 ff ff       	call   801251 <fd_alloc>
  8019b7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ba:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 57                	js     801a17 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019c0:	83 ec 08             	sub    $0x8,%esp
  8019c3:	53                   	push   %ebx
  8019c4:	68 00 50 80 00       	push   $0x805000
  8019c9:	e8 20 ef ff ff       	call   8008ee <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019de:	e8 f6 fd ff ff       	call   8017d9 <fsipc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	79 14                	jns    801a00 <open+0x6f>
		fd_close(fd, 0);
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	6a 00                	push   $0x0
  8019f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f4:	e8 50 f9 ff ff       	call   801349 <fd_close>
		return r;
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	89 da                	mov    %ebx,%edx
  8019fe:	eb 17                	jmp    801a17 <open+0x86>
	}

	return fd2num(fd);
  801a00:	83 ec 0c             	sub    $0xc,%esp
  801a03:	ff 75 f4             	pushl  -0xc(%ebp)
  801a06:	e8 1f f8 ff ff       	call   80122a <fd2num>
  801a0b:	89 c2                	mov    %eax,%edx
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	eb 05                	jmp    801a17 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a12:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a17:	89 d0                	mov    %edx,%eax
  801a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a24:	ba 00 00 00 00       	mov    $0x0,%edx
  801a29:	b8 08 00 00 00       	mov    $0x8,%eax
  801a2e:	e8 a6 fd ff ff       	call   8017d9 <fsipc>
}
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a3b:	68 7f 2e 80 00       	push   $0x802e7f
  801a40:	ff 75 0c             	pushl  0xc(%ebp)
  801a43:	e8 a6 ee ff ff       	call   8008ee <strcpy>
	return 0;
}
  801a48:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	53                   	push   %ebx
  801a53:	83 ec 10             	sub    $0x10,%esp
  801a56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a59:	53                   	push   %ebx
  801a5a:	e8 f8 0a 00 00       	call   802557 <pageref>
  801a5f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a67:	83 f8 01             	cmp    $0x1,%eax
  801a6a:	75 10                	jne    801a7c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	ff 73 0c             	pushl  0xc(%ebx)
  801a72:	e8 c0 02 00 00       	call   801d37 <nsipc_close>
  801a77:	89 c2                	mov    %eax,%edx
  801a79:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a7c:	89 d0                	mov    %edx,%eax
  801a7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a89:	6a 00                	push   $0x0
  801a8b:	ff 75 10             	pushl  0x10(%ebp)
  801a8e:	ff 75 0c             	pushl  0xc(%ebp)
  801a91:	8b 45 08             	mov    0x8(%ebp),%eax
  801a94:	ff 70 0c             	pushl  0xc(%eax)
  801a97:	e8 78 03 00 00       	call   801e14 <nsipc_send>
}
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801aa4:	6a 00                	push   $0x0
  801aa6:	ff 75 10             	pushl  0x10(%ebp)
  801aa9:	ff 75 0c             	pushl  0xc(%ebp)
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	ff 70 0c             	pushl  0xc(%eax)
  801ab2:	e8 f1 02 00 00       	call   801da8 <nsipc_recv>
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801abf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ac2:	52                   	push   %edx
  801ac3:	50                   	push   %eax
  801ac4:	e8 d7 f7 ff ff       	call   8012a0 <fd_lookup>
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 17                	js     801ae7 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad3:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801ad9:	39 08                	cmp    %ecx,(%eax)
  801adb:	75 05                	jne    801ae2 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801add:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae0:	eb 05                	jmp    801ae7 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ae2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	56                   	push   %esi
  801aed:	53                   	push   %ebx
  801aee:	83 ec 1c             	sub    $0x1c,%esp
  801af1:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801af3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af6:	50                   	push   %eax
  801af7:	e8 55 f7 ff ff       	call   801251 <fd_alloc>
  801afc:	89 c3                	mov    %eax,%ebx
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	85 c0                	test   %eax,%eax
  801b03:	78 1b                	js     801b20 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b05:	83 ec 04             	sub    $0x4,%esp
  801b08:	68 07 04 00 00       	push   $0x407
  801b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b10:	6a 00                	push   $0x0
  801b12:	e8 da f1 ff ff       	call   800cf1 <sys_page_alloc>
  801b17:	89 c3                	mov    %eax,%ebx
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	79 10                	jns    801b30 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b20:	83 ec 0c             	sub    $0xc,%esp
  801b23:	56                   	push   %esi
  801b24:	e8 0e 02 00 00       	call   801d37 <nsipc_close>
		return r;
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	89 d8                	mov    %ebx,%eax
  801b2e:	eb 24                	jmp    801b54 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b30:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b39:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b45:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b48:	83 ec 0c             	sub    $0xc,%esp
  801b4b:	50                   	push   %eax
  801b4c:	e8 d9 f6 ff ff       	call   80122a <fd2num>
  801b51:	83 c4 10             	add    $0x10,%esp
}
  801b54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b57:	5b                   	pop    %ebx
  801b58:	5e                   	pop    %esi
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b61:	8b 45 08             	mov    0x8(%ebp),%eax
  801b64:	e8 50 ff ff ff       	call   801ab9 <fd2sockid>
		return r;
  801b69:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 1f                	js     801b8e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b6f:	83 ec 04             	sub    $0x4,%esp
  801b72:	ff 75 10             	pushl  0x10(%ebp)
  801b75:	ff 75 0c             	pushl  0xc(%ebp)
  801b78:	50                   	push   %eax
  801b79:	e8 12 01 00 00       	call   801c90 <nsipc_accept>
  801b7e:	83 c4 10             	add    $0x10,%esp
		return r;
  801b81:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 07                	js     801b8e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b87:	e8 5d ff ff ff       	call   801ae9 <alloc_sockfd>
  801b8c:	89 c1                	mov    %eax,%ecx
}
  801b8e:	89 c8                	mov    %ecx,%eax
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	e8 19 ff ff ff       	call   801ab9 <fd2sockid>
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	78 12                	js     801bb6 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ba4:	83 ec 04             	sub    $0x4,%esp
  801ba7:	ff 75 10             	pushl  0x10(%ebp)
  801baa:	ff 75 0c             	pushl  0xc(%ebp)
  801bad:	50                   	push   %eax
  801bae:	e8 2d 01 00 00       	call   801ce0 <nsipc_bind>
  801bb3:	83 c4 10             	add    $0x10,%esp
}
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <shutdown>:

int
shutdown(int s, int how)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc1:	e8 f3 fe ff ff       	call   801ab9 <fd2sockid>
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 0f                	js     801bd9 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bca:	83 ec 08             	sub    $0x8,%esp
  801bcd:	ff 75 0c             	pushl  0xc(%ebp)
  801bd0:	50                   	push   %eax
  801bd1:	e8 3f 01 00 00       	call   801d15 <nsipc_shutdown>
  801bd6:	83 c4 10             	add    $0x10,%esp
}
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801be1:	8b 45 08             	mov    0x8(%ebp),%eax
  801be4:	e8 d0 fe ff ff       	call   801ab9 <fd2sockid>
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 12                	js     801bff <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801bed:	83 ec 04             	sub    $0x4,%esp
  801bf0:	ff 75 10             	pushl  0x10(%ebp)
  801bf3:	ff 75 0c             	pushl  0xc(%ebp)
  801bf6:	50                   	push   %eax
  801bf7:	e8 55 01 00 00       	call   801d51 <nsipc_connect>
  801bfc:	83 c4 10             	add    $0x10,%esp
}
  801bff:	c9                   	leave  
  801c00:	c3                   	ret    

00801c01 <listen>:

int
listen(int s, int backlog)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c07:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0a:	e8 aa fe ff ff       	call   801ab9 <fd2sockid>
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	78 0f                	js     801c22 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c13:	83 ec 08             	sub    $0x8,%esp
  801c16:	ff 75 0c             	pushl  0xc(%ebp)
  801c19:	50                   	push   %eax
  801c1a:	e8 67 01 00 00       	call   801d86 <nsipc_listen>
  801c1f:	83 c4 10             	add    $0x10,%esp
}
  801c22:	c9                   	leave  
  801c23:	c3                   	ret    

00801c24 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c2a:	ff 75 10             	pushl  0x10(%ebp)
  801c2d:	ff 75 0c             	pushl  0xc(%ebp)
  801c30:	ff 75 08             	pushl  0x8(%ebp)
  801c33:	e8 3a 02 00 00       	call   801e72 <nsipc_socket>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	78 05                	js     801c44 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c3f:	e8 a5 fe ff ff       	call   801ae9 <alloc_sockfd>
}
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    

00801c46 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	53                   	push   %ebx
  801c4a:	83 ec 04             	sub    $0x4,%esp
  801c4d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c4f:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c56:	75 12                	jne    801c6a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	6a 02                	push   $0x2
  801c5d:	e8 bc 08 00 00       	call   80251e <ipc_find_env>
  801c62:	a3 04 40 80 00       	mov    %eax,0x804004
  801c67:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c6a:	6a 07                	push   $0x7
  801c6c:	68 00 60 80 00       	push   $0x806000
  801c71:	53                   	push   %ebx
  801c72:	ff 35 04 40 80 00    	pushl  0x804004
  801c78:	e8 15 08 00 00       	call   802492 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c7d:	83 c4 0c             	add    $0xc,%esp
  801c80:	6a 00                	push   $0x0
  801c82:	6a 00                	push   $0x0
  801c84:	6a 00                	push   $0x0
  801c86:	e8 92 07 00 00       	call   80241d <ipc_recv>
}
  801c8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c98:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ca0:	8b 06                	mov    (%esi),%eax
  801ca2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ca7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cac:	e8 95 ff ff ff       	call   801c46 <nsipc>
  801cb1:	89 c3                	mov    %eax,%ebx
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	78 20                	js     801cd7 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cb7:	83 ec 04             	sub    $0x4,%esp
  801cba:	ff 35 10 60 80 00    	pushl  0x806010
  801cc0:	68 00 60 80 00       	push   $0x806000
  801cc5:	ff 75 0c             	pushl  0xc(%ebp)
  801cc8:	e8 b3 ed ff ff       	call   800a80 <memmove>
		*addrlen = ret->ret_addrlen;
  801ccd:	a1 10 60 80 00       	mov    0x806010,%eax
  801cd2:	89 06                	mov    %eax,(%esi)
  801cd4:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cd7:	89 d8                	mov    %ebx,%eax
  801cd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cdc:	5b                   	pop    %ebx
  801cdd:	5e                   	pop    %esi
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 08             	sub    $0x8,%esp
  801ce7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ced:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cf2:	53                   	push   %ebx
  801cf3:	ff 75 0c             	pushl  0xc(%ebp)
  801cf6:	68 04 60 80 00       	push   $0x806004
  801cfb:	e8 80 ed ff ff       	call   800a80 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d00:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d06:	b8 02 00 00 00       	mov    $0x2,%eax
  801d0b:	e8 36 ff ff ff       	call   801c46 <nsipc>
}
  801d10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d26:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d2b:	b8 03 00 00 00       	mov    $0x3,%eax
  801d30:	e8 11 ff ff ff       	call   801c46 <nsipc>
}
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <nsipc_close>:

int
nsipc_close(int s)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d40:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d45:	b8 04 00 00 00       	mov    $0x4,%eax
  801d4a:	e8 f7 fe ff ff       	call   801c46 <nsipc>
}
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	53                   	push   %ebx
  801d55:	83 ec 08             	sub    $0x8,%esp
  801d58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d63:	53                   	push   %ebx
  801d64:	ff 75 0c             	pushl  0xc(%ebp)
  801d67:	68 04 60 80 00       	push   $0x806004
  801d6c:	e8 0f ed ff ff       	call   800a80 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d71:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d77:	b8 05 00 00 00       	mov    $0x5,%eax
  801d7c:	e8 c5 fe ff ff       	call   801c46 <nsipc>
}
  801d81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d97:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d9c:	b8 06 00 00 00       	mov    $0x6,%eax
  801da1:	e8 a0 fe ff ff       	call   801c46 <nsipc>
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	56                   	push   %esi
  801dac:	53                   	push   %ebx
  801dad:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801db0:	8b 45 08             	mov    0x8(%ebp),%eax
  801db3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801db8:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dbe:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc1:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dc6:	b8 07 00 00 00       	mov    $0x7,%eax
  801dcb:	e8 76 fe ff ff       	call   801c46 <nsipc>
  801dd0:	89 c3                	mov    %eax,%ebx
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	78 35                	js     801e0b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801dd6:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ddb:	7f 04                	jg     801de1 <nsipc_recv+0x39>
  801ddd:	39 c6                	cmp    %eax,%esi
  801ddf:	7d 16                	jge    801df7 <nsipc_recv+0x4f>
  801de1:	68 8b 2e 80 00       	push   $0x802e8b
  801de6:	68 53 2e 80 00       	push   $0x802e53
  801deb:	6a 62                	push   $0x62
  801ded:	68 a0 2e 80 00       	push   $0x802ea0
  801df2:	e8 99 e4 ff ff       	call   800290 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801df7:	83 ec 04             	sub    $0x4,%esp
  801dfa:	50                   	push   %eax
  801dfb:	68 00 60 80 00       	push   $0x806000
  801e00:	ff 75 0c             	pushl  0xc(%ebp)
  801e03:	e8 78 ec ff ff       	call   800a80 <memmove>
  801e08:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e0b:	89 d8                	mov    %ebx,%eax
  801e0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e10:	5b                   	pop    %ebx
  801e11:	5e                   	pop    %esi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	53                   	push   %ebx
  801e18:	83 ec 04             	sub    $0x4,%esp
  801e1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e21:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e26:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e2c:	7e 16                	jle    801e44 <nsipc_send+0x30>
  801e2e:	68 ac 2e 80 00       	push   $0x802eac
  801e33:	68 53 2e 80 00       	push   $0x802e53
  801e38:	6a 6d                	push   $0x6d
  801e3a:	68 a0 2e 80 00       	push   $0x802ea0
  801e3f:	e8 4c e4 ff ff       	call   800290 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e44:	83 ec 04             	sub    $0x4,%esp
  801e47:	53                   	push   %ebx
  801e48:	ff 75 0c             	pushl  0xc(%ebp)
  801e4b:	68 0c 60 80 00       	push   $0x80600c
  801e50:	e8 2b ec ff ff       	call   800a80 <memmove>
	nsipcbuf.send.req_size = size;
  801e55:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801e5e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e63:	b8 08 00 00 00       	mov    $0x8,%eax
  801e68:	e8 d9 fd ff ff       	call   801c46 <nsipc>
}
  801e6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    

00801e72 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e83:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e88:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e90:	b8 09 00 00 00       	mov    $0x9,%eax
  801e95:	e8 ac fd ff ff       	call   801c46 <nsipc>
}
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ea4:	83 ec 0c             	sub    $0xc,%esp
  801ea7:	ff 75 08             	pushl  0x8(%ebp)
  801eaa:	e8 8b f3 ff ff       	call   80123a <fd2data>
  801eaf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801eb1:	83 c4 08             	add    $0x8,%esp
  801eb4:	68 b8 2e 80 00       	push   $0x802eb8
  801eb9:	53                   	push   %ebx
  801eba:	e8 2f ea ff ff       	call   8008ee <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ebf:	8b 46 04             	mov    0x4(%esi),%eax
  801ec2:	2b 06                	sub    (%esi),%eax
  801ec4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ed1:	00 00 00 
	stat->st_dev = &devpipe;
  801ed4:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801edb:	30 80 00 
	return 0;
}
  801ede:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee6:	5b                   	pop    %ebx
  801ee7:	5e                   	pop    %esi
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	53                   	push   %ebx
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ef4:	53                   	push   %ebx
  801ef5:	6a 00                	push   $0x0
  801ef7:	e8 7a ee ff ff       	call   800d76 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801efc:	89 1c 24             	mov    %ebx,(%esp)
  801eff:	e8 36 f3 ff ff       	call   80123a <fd2data>
  801f04:	83 c4 08             	add    $0x8,%esp
  801f07:	50                   	push   %eax
  801f08:	6a 00                	push   $0x0
  801f0a:	e8 67 ee ff ff       	call   800d76 <sys_page_unmap>
}
  801f0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f12:	c9                   	leave  
  801f13:	c3                   	ret    

00801f14 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	57                   	push   %edi
  801f18:	56                   	push   %esi
  801f19:	53                   	push   %ebx
  801f1a:	83 ec 1c             	sub    $0x1c,%esp
  801f1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f20:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f22:	a1 08 40 80 00       	mov    0x804008,%eax
  801f27:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f2a:	83 ec 0c             	sub    $0xc,%esp
  801f2d:	ff 75 e0             	pushl  -0x20(%ebp)
  801f30:	e8 22 06 00 00       	call   802557 <pageref>
  801f35:	89 c3                	mov    %eax,%ebx
  801f37:	89 3c 24             	mov    %edi,(%esp)
  801f3a:	e8 18 06 00 00       	call   802557 <pageref>
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	39 c3                	cmp    %eax,%ebx
  801f44:	0f 94 c1             	sete   %cl
  801f47:	0f b6 c9             	movzbl %cl,%ecx
  801f4a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f4d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f53:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f56:	39 ce                	cmp    %ecx,%esi
  801f58:	74 1b                	je     801f75 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f5a:	39 c3                	cmp    %eax,%ebx
  801f5c:	75 c4                	jne    801f22 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f5e:	8b 42 58             	mov    0x58(%edx),%eax
  801f61:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f64:	50                   	push   %eax
  801f65:	56                   	push   %esi
  801f66:	68 bf 2e 80 00       	push   $0x802ebf
  801f6b:	e8 f9 e3 ff ff       	call   800369 <cprintf>
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	eb ad                	jmp    801f22 <_pipeisclosed+0xe>
	}
}
  801f75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5f                   	pop    %edi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	57                   	push   %edi
  801f84:	56                   	push   %esi
  801f85:	53                   	push   %ebx
  801f86:	83 ec 28             	sub    $0x28,%esp
  801f89:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f8c:	56                   	push   %esi
  801f8d:	e8 a8 f2 ff ff       	call   80123a <fd2data>
  801f92:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	bf 00 00 00 00       	mov    $0x0,%edi
  801f9c:	eb 4b                	jmp    801fe9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f9e:	89 da                	mov    %ebx,%edx
  801fa0:	89 f0                	mov    %esi,%eax
  801fa2:	e8 6d ff ff ff       	call   801f14 <_pipeisclosed>
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	75 48                	jne    801ff3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fab:	e8 22 ed ff ff       	call   800cd2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fb0:	8b 43 04             	mov    0x4(%ebx),%eax
  801fb3:	8b 0b                	mov    (%ebx),%ecx
  801fb5:	8d 51 20             	lea    0x20(%ecx),%edx
  801fb8:	39 d0                	cmp    %edx,%eax
  801fba:	73 e2                	jae    801f9e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fbf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fc3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fc6:	89 c2                	mov    %eax,%edx
  801fc8:	c1 fa 1f             	sar    $0x1f,%edx
  801fcb:	89 d1                	mov    %edx,%ecx
  801fcd:	c1 e9 1b             	shr    $0x1b,%ecx
  801fd0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fd3:	83 e2 1f             	and    $0x1f,%edx
  801fd6:	29 ca                	sub    %ecx,%edx
  801fd8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fdc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fe0:	83 c0 01             	add    $0x1,%eax
  801fe3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe6:	83 c7 01             	add    $0x1,%edi
  801fe9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fec:	75 c2                	jne    801fb0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fee:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff1:	eb 05                	jmp    801ff8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ff3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ff8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffb:	5b                   	pop    %ebx
  801ffc:	5e                   	pop    %esi
  801ffd:	5f                   	pop    %edi
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    

00802000 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	57                   	push   %edi
  802004:	56                   	push   %esi
  802005:	53                   	push   %ebx
  802006:	83 ec 18             	sub    $0x18,%esp
  802009:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80200c:	57                   	push   %edi
  80200d:	e8 28 f2 ff ff       	call   80123a <fd2data>
  802012:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	bb 00 00 00 00       	mov    $0x0,%ebx
  80201c:	eb 3d                	jmp    80205b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80201e:	85 db                	test   %ebx,%ebx
  802020:	74 04                	je     802026 <devpipe_read+0x26>
				return i;
  802022:	89 d8                	mov    %ebx,%eax
  802024:	eb 44                	jmp    80206a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802026:	89 f2                	mov    %esi,%edx
  802028:	89 f8                	mov    %edi,%eax
  80202a:	e8 e5 fe ff ff       	call   801f14 <_pipeisclosed>
  80202f:	85 c0                	test   %eax,%eax
  802031:	75 32                	jne    802065 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802033:	e8 9a ec ff ff       	call   800cd2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802038:	8b 06                	mov    (%esi),%eax
  80203a:	3b 46 04             	cmp    0x4(%esi),%eax
  80203d:	74 df                	je     80201e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80203f:	99                   	cltd   
  802040:	c1 ea 1b             	shr    $0x1b,%edx
  802043:	01 d0                	add    %edx,%eax
  802045:	83 e0 1f             	and    $0x1f,%eax
  802048:	29 d0                	sub    %edx,%eax
  80204a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80204f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802052:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802055:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802058:	83 c3 01             	add    $0x1,%ebx
  80205b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80205e:	75 d8                	jne    802038 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802060:	8b 45 10             	mov    0x10(%ebp),%eax
  802063:	eb 05                	jmp    80206a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802065:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80206a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    

00802072 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	56                   	push   %esi
  802076:	53                   	push   %ebx
  802077:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80207a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207d:	50                   	push   %eax
  80207e:	e8 ce f1 ff ff       	call   801251 <fd_alloc>
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	89 c2                	mov    %eax,%edx
  802088:	85 c0                	test   %eax,%eax
  80208a:	0f 88 2c 01 00 00    	js     8021bc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802090:	83 ec 04             	sub    $0x4,%esp
  802093:	68 07 04 00 00       	push   $0x407
  802098:	ff 75 f4             	pushl  -0xc(%ebp)
  80209b:	6a 00                	push   $0x0
  80209d:	e8 4f ec ff ff       	call   800cf1 <sys_page_alloc>
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	89 c2                	mov    %eax,%edx
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	0f 88 0d 01 00 00    	js     8021bc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020af:	83 ec 0c             	sub    $0xc,%esp
  8020b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020b5:	50                   	push   %eax
  8020b6:	e8 96 f1 ff ff       	call   801251 <fd_alloc>
  8020bb:	89 c3                	mov    %eax,%ebx
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	0f 88 e2 00 00 00    	js     8021aa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c8:	83 ec 04             	sub    $0x4,%esp
  8020cb:	68 07 04 00 00       	push   $0x407
  8020d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d3:	6a 00                	push   $0x0
  8020d5:	e8 17 ec ff ff       	call   800cf1 <sys_page_alloc>
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	0f 88 c3 00 00 00    	js     8021aa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020e7:	83 ec 0c             	sub    $0xc,%esp
  8020ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ed:	e8 48 f1 ff ff       	call   80123a <fd2data>
  8020f2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f4:	83 c4 0c             	add    $0xc,%esp
  8020f7:	68 07 04 00 00       	push   $0x407
  8020fc:	50                   	push   %eax
  8020fd:	6a 00                	push   $0x0
  8020ff:	e8 ed eb ff ff       	call   800cf1 <sys_page_alloc>
  802104:	89 c3                	mov    %eax,%ebx
  802106:	83 c4 10             	add    $0x10,%esp
  802109:	85 c0                	test   %eax,%eax
  80210b:	0f 88 89 00 00 00    	js     80219a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802111:	83 ec 0c             	sub    $0xc,%esp
  802114:	ff 75 f0             	pushl  -0x10(%ebp)
  802117:	e8 1e f1 ff ff       	call   80123a <fd2data>
  80211c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802123:	50                   	push   %eax
  802124:	6a 00                	push   $0x0
  802126:	56                   	push   %esi
  802127:	6a 00                	push   $0x0
  802129:	e8 06 ec ff ff       	call   800d34 <sys_page_map>
  80212e:	89 c3                	mov    %eax,%ebx
  802130:	83 c4 20             	add    $0x20,%esp
  802133:	85 c0                	test   %eax,%eax
  802135:	78 55                	js     80218c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802137:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80213d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802140:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802145:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80214c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802152:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802155:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802157:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80215a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802161:	83 ec 0c             	sub    $0xc,%esp
  802164:	ff 75 f4             	pushl  -0xc(%ebp)
  802167:	e8 be f0 ff ff       	call   80122a <fd2num>
  80216c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80216f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802171:	83 c4 04             	add    $0x4,%esp
  802174:	ff 75 f0             	pushl  -0x10(%ebp)
  802177:	e8 ae f0 ff ff       	call   80122a <fd2num>
  80217c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80217f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802182:	83 c4 10             	add    $0x10,%esp
  802185:	ba 00 00 00 00       	mov    $0x0,%edx
  80218a:	eb 30                	jmp    8021bc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80218c:	83 ec 08             	sub    $0x8,%esp
  80218f:	56                   	push   %esi
  802190:	6a 00                	push   $0x0
  802192:	e8 df eb ff ff       	call   800d76 <sys_page_unmap>
  802197:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80219a:	83 ec 08             	sub    $0x8,%esp
  80219d:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a0:	6a 00                	push   $0x0
  8021a2:	e8 cf eb ff ff       	call   800d76 <sys_page_unmap>
  8021a7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021aa:	83 ec 08             	sub    $0x8,%esp
  8021ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b0:	6a 00                	push   $0x0
  8021b2:	e8 bf eb ff ff       	call   800d76 <sys_page_unmap>
  8021b7:	83 c4 10             	add    $0x10,%esp
  8021ba:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021bc:	89 d0                	mov    %edx,%eax
  8021be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c1:	5b                   	pop    %ebx
  8021c2:	5e                   	pop    %esi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    

008021c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ce:	50                   	push   %eax
  8021cf:	ff 75 08             	pushl  0x8(%ebp)
  8021d2:	e8 c9 f0 ff ff       	call   8012a0 <fd_lookup>
  8021d7:	83 c4 10             	add    $0x10,%esp
  8021da:	85 c0                	test   %eax,%eax
  8021dc:	78 18                	js     8021f6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021de:	83 ec 0c             	sub    $0xc,%esp
  8021e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e4:	e8 51 f0 ff ff       	call   80123a <fd2data>
	return _pipeisclosed(fd, p);
  8021e9:	89 c2                	mov    %eax,%edx
  8021eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ee:	e8 21 fd ff ff       	call   801f14 <_pipeisclosed>
  8021f3:	83 c4 10             	add    $0x10,%esp
}
  8021f6:	c9                   	leave  
  8021f7:	c3                   	ret    

008021f8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    

00802202 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802208:	68 d2 2e 80 00       	push   $0x802ed2
  80220d:	ff 75 0c             	pushl  0xc(%ebp)
  802210:	e8 d9 e6 ff ff       	call   8008ee <strcpy>
	return 0;
}
  802215:	b8 00 00 00 00       	mov    $0x0,%eax
  80221a:	c9                   	leave  
  80221b:	c3                   	ret    

0080221c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	57                   	push   %edi
  802220:	56                   	push   %esi
  802221:	53                   	push   %ebx
  802222:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802228:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80222d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802233:	eb 2d                	jmp    802262 <devcons_write+0x46>
		m = n - tot;
  802235:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802238:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80223a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80223d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802242:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802245:	83 ec 04             	sub    $0x4,%esp
  802248:	53                   	push   %ebx
  802249:	03 45 0c             	add    0xc(%ebp),%eax
  80224c:	50                   	push   %eax
  80224d:	57                   	push   %edi
  80224e:	e8 2d e8 ff ff       	call   800a80 <memmove>
		sys_cputs(buf, m);
  802253:	83 c4 08             	add    $0x8,%esp
  802256:	53                   	push   %ebx
  802257:	57                   	push   %edi
  802258:	e8 d8 e9 ff ff       	call   800c35 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80225d:	01 de                	add    %ebx,%esi
  80225f:	83 c4 10             	add    $0x10,%esp
  802262:	89 f0                	mov    %esi,%eax
  802264:	3b 75 10             	cmp    0x10(%ebp),%esi
  802267:	72 cc                	jb     802235 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80226c:	5b                   	pop    %ebx
  80226d:	5e                   	pop    %esi
  80226e:	5f                   	pop    %edi
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    

00802271 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	83 ec 08             	sub    $0x8,%esp
  802277:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80227c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802280:	74 2a                	je     8022ac <devcons_read+0x3b>
  802282:	eb 05                	jmp    802289 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802284:	e8 49 ea ff ff       	call   800cd2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802289:	e8 c5 e9 ff ff       	call   800c53 <sys_cgetc>
  80228e:	85 c0                	test   %eax,%eax
  802290:	74 f2                	je     802284 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802292:	85 c0                	test   %eax,%eax
  802294:	78 16                	js     8022ac <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802296:	83 f8 04             	cmp    $0x4,%eax
  802299:	74 0c                	je     8022a7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80229b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80229e:	88 02                	mov    %al,(%edx)
	return 1;
  8022a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a5:	eb 05                	jmp    8022ac <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022a7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022ac:	c9                   	leave  
  8022ad:	c3                   	ret    

008022ae <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022ba:	6a 01                	push   $0x1
  8022bc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022bf:	50                   	push   %eax
  8022c0:	e8 70 e9 ff ff       	call   800c35 <sys_cputs>
}
  8022c5:	83 c4 10             	add    $0x10,%esp
  8022c8:	c9                   	leave  
  8022c9:	c3                   	ret    

008022ca <getchar>:

int
getchar(void)
{
  8022ca:	55                   	push   %ebp
  8022cb:	89 e5                	mov    %esp,%ebp
  8022cd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022d0:	6a 01                	push   $0x1
  8022d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022d5:	50                   	push   %eax
  8022d6:	6a 00                	push   $0x0
  8022d8:	e8 29 f2 ff ff       	call   801506 <read>
	if (r < 0)
  8022dd:	83 c4 10             	add    $0x10,%esp
  8022e0:	85 c0                	test   %eax,%eax
  8022e2:	78 0f                	js     8022f3 <getchar+0x29>
		return r;
	if (r < 1)
  8022e4:	85 c0                	test   %eax,%eax
  8022e6:	7e 06                	jle    8022ee <getchar+0x24>
		return -E_EOF;
	return c;
  8022e8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022ec:	eb 05                	jmp    8022f3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022ee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022fe:	50                   	push   %eax
  8022ff:	ff 75 08             	pushl  0x8(%ebp)
  802302:	e8 99 ef ff ff       	call   8012a0 <fd_lookup>
  802307:	83 c4 10             	add    $0x10,%esp
  80230a:	85 c0                	test   %eax,%eax
  80230c:	78 11                	js     80231f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80230e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802311:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802317:	39 10                	cmp    %edx,(%eax)
  802319:	0f 94 c0             	sete   %al
  80231c:	0f b6 c0             	movzbl %al,%eax
}
  80231f:	c9                   	leave  
  802320:	c3                   	ret    

00802321 <opencons>:

int
opencons(void)
{
  802321:	55                   	push   %ebp
  802322:	89 e5                	mov    %esp,%ebp
  802324:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80232a:	50                   	push   %eax
  80232b:	e8 21 ef ff ff       	call   801251 <fd_alloc>
  802330:	83 c4 10             	add    $0x10,%esp
		return r;
  802333:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802335:	85 c0                	test   %eax,%eax
  802337:	78 3e                	js     802377 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802339:	83 ec 04             	sub    $0x4,%esp
  80233c:	68 07 04 00 00       	push   $0x407
  802341:	ff 75 f4             	pushl  -0xc(%ebp)
  802344:	6a 00                	push   $0x0
  802346:	e8 a6 e9 ff ff       	call   800cf1 <sys_page_alloc>
  80234b:	83 c4 10             	add    $0x10,%esp
		return r;
  80234e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802350:	85 c0                	test   %eax,%eax
  802352:	78 23                	js     802377 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802354:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80235a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80235f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802362:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802369:	83 ec 0c             	sub    $0xc,%esp
  80236c:	50                   	push   %eax
  80236d:	e8 b8 ee ff ff       	call   80122a <fd2num>
  802372:	89 c2                	mov    %eax,%edx
  802374:	83 c4 10             	add    $0x10,%esp
}
  802377:	89 d0                	mov    %edx,%eax
  802379:	c9                   	leave  
  80237a:	c3                   	ret    

0080237b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80237b:	55                   	push   %ebp
  80237c:	89 e5                	mov    %esp,%ebp
  80237e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802381:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802388:	75 64                	jne    8023ee <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80238a:	a1 08 40 80 00       	mov    0x804008,%eax
  80238f:	8b 40 48             	mov    0x48(%eax),%eax
  802392:	83 ec 04             	sub    $0x4,%esp
  802395:	6a 07                	push   $0x7
  802397:	68 00 f0 bf ee       	push   $0xeebff000
  80239c:	50                   	push   %eax
  80239d:	e8 4f e9 ff ff       	call   800cf1 <sys_page_alloc>
		if ( r != 0)
  8023a2:	83 c4 10             	add    $0x10,%esp
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	74 14                	je     8023bd <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  8023a9:	83 ec 04             	sub    $0x4,%esp
  8023ac:	68 e0 2e 80 00       	push   $0x802ee0
  8023b1:	6a 24                	push   $0x24
  8023b3:	68 2e 2f 80 00       	push   $0x802f2e
  8023b8:	e8 d3 de ff ff       	call   800290 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  8023bd:	a1 08 40 80 00       	mov    0x804008,%eax
  8023c2:	8b 40 48             	mov    0x48(%eax),%eax
  8023c5:	83 ec 08             	sub    $0x8,%esp
  8023c8:	68 f8 23 80 00       	push   $0x8023f8
  8023cd:	50                   	push   %eax
  8023ce:	e8 69 ea ff ff       	call   800e3c <sys_env_set_pgfault_upcall>
  8023d3:	83 c4 10             	add    $0x10,%esp
  8023d6:	85 c0                	test   %eax,%eax
  8023d8:	79 14                	jns    8023ee <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  8023da:	83 ec 04             	sub    $0x4,%esp
  8023dd:	68 0c 2f 80 00       	push   $0x802f0c
  8023e2:	6a 27                	push   $0x27
  8023e4:	68 2e 2f 80 00       	push   $0x802f2e
  8023e9:	e8 a2 de ff ff       	call   800290 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f1:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023f6:	c9                   	leave  
  8023f7:	c3                   	ret    

008023f8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023f8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023f9:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023fe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802400:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  802403:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  802407:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  802409:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  80240d:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  80240e:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  802411:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  802413:	83 c4 08             	add    $0x8,%esp
popal
  802416:	61                   	popa   
addl $0x4, %esp
  802417:	83 c4 04             	add    $0x4,%esp
popfl
  80241a:	9d                   	popf   
popl %esp
  80241b:	5c                   	pop    %esp
ret
  80241c:	c3                   	ret    

0080241d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80241d:	55                   	push   %ebp
  80241e:	89 e5                	mov    %esp,%ebp
  802420:	56                   	push   %esi
  802421:	53                   	push   %ebx
  802422:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802425:	8b 45 0c             	mov    0xc(%ebp),%eax
  802428:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  80242b:	85 c0                	test   %eax,%eax
  80242d:	74 0e                	je     80243d <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  80242f:	83 ec 0c             	sub    $0xc,%esp
  802432:	50                   	push   %eax
  802433:	e8 69 ea ff ff       	call   800ea1 <sys_ipc_recv>
  802438:	83 c4 10             	add    $0x10,%esp
  80243b:	eb 10                	jmp    80244d <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  80243d:	83 ec 0c             	sub    $0xc,%esp
  802440:	68 00 00 00 f0       	push   $0xf0000000
  802445:	e8 57 ea ff ff       	call   800ea1 <sys_ipc_recv>
  80244a:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  80244d:	85 c0                	test   %eax,%eax
  80244f:	74 16                	je     802467 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  802451:	85 db                	test   %ebx,%ebx
  802453:	74 36                	je     80248b <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  802455:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  80245b:	85 f6                	test   %esi,%esi
  80245d:	74 2c                	je     80248b <ipc_recv+0x6e>
				*perm_store = 0;
  80245f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802465:	eb 24                	jmp    80248b <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  802467:	85 db                	test   %ebx,%ebx
  802469:	74 18                	je     802483 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  80246b:	a1 08 40 80 00       	mov    0x804008,%eax
  802470:	8b 40 74             	mov    0x74(%eax),%eax
  802473:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  802475:	85 f6                	test   %esi,%esi
  802477:	74 0a                	je     802483 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  802479:	a1 08 40 80 00       	mov    0x804008,%eax
  80247e:	8b 40 78             	mov    0x78(%eax),%eax
  802481:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  802483:	a1 08 40 80 00       	mov    0x804008,%eax
  802488:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  80248b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80248e:	5b                   	pop    %ebx
  80248f:	5e                   	pop    %esi
  802490:	5d                   	pop    %ebp
  802491:	c3                   	ret    

00802492 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802492:	55                   	push   %ebp
  802493:	89 e5                	mov    %esp,%ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	83 ec 0c             	sub    $0xc,%esp
  80249b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80249e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  8024a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024a5:	75 39                	jne    8024e0 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  8024a7:	6a 00                	push   $0x0
  8024a9:	68 00 00 00 f0       	push   $0xf0000000
  8024ae:	56                   	push   %esi
  8024af:	57                   	push   %edi
  8024b0:	e8 c9 e9 ff ff       	call   800e7e <sys_ipc_try_send>
  8024b5:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  8024b7:	83 c4 10             	add    $0x10,%esp
  8024ba:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024bd:	74 16                	je     8024d5 <ipc_send+0x43>
  8024bf:	85 c0                	test   %eax,%eax
  8024c1:	74 12                	je     8024d5 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  8024c3:	50                   	push   %eax
  8024c4:	68 3c 2f 80 00       	push   $0x802f3c
  8024c9:	6a 4f                	push   $0x4f
  8024cb:	68 74 2f 80 00       	push   $0x802f74
  8024d0:	e8 bb dd ff ff       	call   800290 <_panic>
			sys_yield();
  8024d5:	e8 f8 e7 ff ff       	call   800cd2 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  8024da:	85 db                	test   %ebx,%ebx
  8024dc:	75 c9                	jne    8024a7 <ipc_send+0x15>
  8024de:	eb 36                	jmp    802516 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  8024e0:	ff 75 14             	pushl  0x14(%ebp)
  8024e3:	ff 75 10             	pushl  0x10(%ebp)
  8024e6:	56                   	push   %esi
  8024e7:	57                   	push   %edi
  8024e8:	e8 91 e9 ff ff       	call   800e7e <sys_ipc_try_send>
  8024ed:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  8024ef:	83 c4 10             	add    $0x10,%esp
  8024f2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024f5:	74 16                	je     80250d <ipc_send+0x7b>
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	74 12                	je     80250d <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  8024fb:	50                   	push   %eax
  8024fc:	68 3c 2f 80 00       	push   $0x802f3c
  802501:	6a 5a                	push   $0x5a
  802503:	68 74 2f 80 00       	push   $0x802f74
  802508:	e8 83 dd ff ff       	call   800290 <_panic>
			sys_yield();
  80250d:	e8 c0 e7 ff ff       	call   800cd2 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  802512:	85 db                	test   %ebx,%ebx
  802514:	75 ca                	jne    8024e0 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  802516:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802519:	5b                   	pop    %ebx
  80251a:	5e                   	pop    %esi
  80251b:	5f                   	pop    %edi
  80251c:	5d                   	pop    %ebp
  80251d:	c3                   	ret    

0080251e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80251e:	55                   	push   %ebp
  80251f:	89 e5                	mov    %esp,%ebp
  802521:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802524:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802529:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80252c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802532:	8b 52 50             	mov    0x50(%edx),%edx
  802535:	39 ca                	cmp    %ecx,%edx
  802537:	75 0d                	jne    802546 <ipc_find_env+0x28>
			return envs[i].env_id;
  802539:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80253c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802541:	8b 40 48             	mov    0x48(%eax),%eax
  802544:	eb 0f                	jmp    802555 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802546:	83 c0 01             	add    $0x1,%eax
  802549:	3d 00 04 00 00       	cmp    $0x400,%eax
  80254e:	75 d9                	jne    802529 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802550:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802555:	5d                   	pop    %ebp
  802556:	c3                   	ret    

00802557 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802557:	55                   	push   %ebp
  802558:	89 e5                	mov    %esp,%ebp
  80255a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80255d:	89 d0                	mov    %edx,%eax
  80255f:	c1 e8 16             	shr    $0x16,%eax
  802562:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802569:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80256e:	f6 c1 01             	test   $0x1,%cl
  802571:	74 1d                	je     802590 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802573:	c1 ea 0c             	shr    $0xc,%edx
  802576:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80257d:	f6 c2 01             	test   $0x1,%dl
  802580:	74 0e                	je     802590 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802582:	c1 ea 0c             	shr    $0xc,%edx
  802585:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80258c:	ef 
  80258d:	0f b7 c0             	movzwl %ax,%eax
}
  802590:	5d                   	pop    %ebp
  802591:	c3                   	ret    
  802592:	66 90                	xchg   %ax,%ax
  802594:	66 90                	xchg   %ax,%ax
  802596:	66 90                	xchg   %ax,%ax
  802598:	66 90                	xchg   %ax,%ax
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__udivdi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 1c             	sub    $0x1c,%esp
  8025a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025b7:	85 f6                	test   %esi,%esi
  8025b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025bd:	89 ca                	mov    %ecx,%edx
  8025bf:	89 f8                	mov    %edi,%eax
  8025c1:	75 3d                	jne    802600 <__udivdi3+0x60>
  8025c3:	39 cf                	cmp    %ecx,%edi
  8025c5:	0f 87 c5 00 00 00    	ja     802690 <__udivdi3+0xf0>
  8025cb:	85 ff                	test   %edi,%edi
  8025cd:	89 fd                	mov    %edi,%ebp
  8025cf:	75 0b                	jne    8025dc <__udivdi3+0x3c>
  8025d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d6:	31 d2                	xor    %edx,%edx
  8025d8:	f7 f7                	div    %edi
  8025da:	89 c5                	mov    %eax,%ebp
  8025dc:	89 c8                	mov    %ecx,%eax
  8025de:	31 d2                	xor    %edx,%edx
  8025e0:	f7 f5                	div    %ebp
  8025e2:	89 c1                	mov    %eax,%ecx
  8025e4:	89 d8                	mov    %ebx,%eax
  8025e6:	89 cf                	mov    %ecx,%edi
  8025e8:	f7 f5                	div    %ebp
  8025ea:	89 c3                	mov    %eax,%ebx
  8025ec:	89 d8                	mov    %ebx,%eax
  8025ee:	89 fa                	mov    %edi,%edx
  8025f0:	83 c4 1c             	add    $0x1c,%esp
  8025f3:	5b                   	pop    %ebx
  8025f4:	5e                   	pop    %esi
  8025f5:	5f                   	pop    %edi
  8025f6:	5d                   	pop    %ebp
  8025f7:	c3                   	ret    
  8025f8:	90                   	nop
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	39 ce                	cmp    %ecx,%esi
  802602:	77 74                	ja     802678 <__udivdi3+0xd8>
  802604:	0f bd fe             	bsr    %esi,%edi
  802607:	83 f7 1f             	xor    $0x1f,%edi
  80260a:	0f 84 98 00 00 00    	je     8026a8 <__udivdi3+0x108>
  802610:	bb 20 00 00 00       	mov    $0x20,%ebx
  802615:	89 f9                	mov    %edi,%ecx
  802617:	89 c5                	mov    %eax,%ebp
  802619:	29 fb                	sub    %edi,%ebx
  80261b:	d3 e6                	shl    %cl,%esi
  80261d:	89 d9                	mov    %ebx,%ecx
  80261f:	d3 ed                	shr    %cl,%ebp
  802621:	89 f9                	mov    %edi,%ecx
  802623:	d3 e0                	shl    %cl,%eax
  802625:	09 ee                	or     %ebp,%esi
  802627:	89 d9                	mov    %ebx,%ecx
  802629:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80262d:	89 d5                	mov    %edx,%ebp
  80262f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802633:	d3 ed                	shr    %cl,%ebp
  802635:	89 f9                	mov    %edi,%ecx
  802637:	d3 e2                	shl    %cl,%edx
  802639:	89 d9                	mov    %ebx,%ecx
  80263b:	d3 e8                	shr    %cl,%eax
  80263d:	09 c2                	or     %eax,%edx
  80263f:	89 d0                	mov    %edx,%eax
  802641:	89 ea                	mov    %ebp,%edx
  802643:	f7 f6                	div    %esi
  802645:	89 d5                	mov    %edx,%ebp
  802647:	89 c3                	mov    %eax,%ebx
  802649:	f7 64 24 0c          	mull   0xc(%esp)
  80264d:	39 d5                	cmp    %edx,%ebp
  80264f:	72 10                	jb     802661 <__udivdi3+0xc1>
  802651:	8b 74 24 08          	mov    0x8(%esp),%esi
  802655:	89 f9                	mov    %edi,%ecx
  802657:	d3 e6                	shl    %cl,%esi
  802659:	39 c6                	cmp    %eax,%esi
  80265b:	73 07                	jae    802664 <__udivdi3+0xc4>
  80265d:	39 d5                	cmp    %edx,%ebp
  80265f:	75 03                	jne    802664 <__udivdi3+0xc4>
  802661:	83 eb 01             	sub    $0x1,%ebx
  802664:	31 ff                	xor    %edi,%edi
  802666:	89 d8                	mov    %ebx,%eax
  802668:	89 fa                	mov    %edi,%edx
  80266a:	83 c4 1c             	add    $0x1c,%esp
  80266d:	5b                   	pop    %ebx
  80266e:	5e                   	pop    %esi
  80266f:	5f                   	pop    %edi
  802670:	5d                   	pop    %ebp
  802671:	c3                   	ret    
  802672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802678:	31 ff                	xor    %edi,%edi
  80267a:	31 db                	xor    %ebx,%ebx
  80267c:	89 d8                	mov    %ebx,%eax
  80267e:	89 fa                	mov    %edi,%edx
  802680:	83 c4 1c             	add    $0x1c,%esp
  802683:	5b                   	pop    %ebx
  802684:	5e                   	pop    %esi
  802685:	5f                   	pop    %edi
  802686:	5d                   	pop    %ebp
  802687:	c3                   	ret    
  802688:	90                   	nop
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	89 d8                	mov    %ebx,%eax
  802692:	f7 f7                	div    %edi
  802694:	31 ff                	xor    %edi,%edi
  802696:	89 c3                	mov    %eax,%ebx
  802698:	89 d8                	mov    %ebx,%eax
  80269a:	89 fa                	mov    %edi,%edx
  80269c:	83 c4 1c             	add    $0x1c,%esp
  80269f:	5b                   	pop    %ebx
  8026a0:	5e                   	pop    %esi
  8026a1:	5f                   	pop    %edi
  8026a2:	5d                   	pop    %ebp
  8026a3:	c3                   	ret    
  8026a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a8:	39 ce                	cmp    %ecx,%esi
  8026aa:	72 0c                	jb     8026b8 <__udivdi3+0x118>
  8026ac:	31 db                	xor    %ebx,%ebx
  8026ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026b2:	0f 87 34 ff ff ff    	ja     8025ec <__udivdi3+0x4c>
  8026b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026bd:	e9 2a ff ff ff       	jmp    8025ec <__udivdi3+0x4c>
  8026c2:	66 90                	xchg   %ax,%ax
  8026c4:	66 90                	xchg   %ax,%ax
  8026c6:	66 90                	xchg   %ax,%ax
  8026c8:	66 90                	xchg   %ax,%ax
  8026ca:	66 90                	xchg   %ax,%ax
  8026cc:	66 90                	xchg   %ax,%ax
  8026ce:	66 90                	xchg   %ax,%ax

008026d0 <__umoddi3>:
  8026d0:	55                   	push   %ebp
  8026d1:	57                   	push   %edi
  8026d2:	56                   	push   %esi
  8026d3:	53                   	push   %ebx
  8026d4:	83 ec 1c             	sub    $0x1c,%esp
  8026d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026e7:	85 d2                	test   %edx,%edx
  8026e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026f1:	89 f3                	mov    %esi,%ebx
  8026f3:	89 3c 24             	mov    %edi,(%esp)
  8026f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026fa:	75 1c                	jne    802718 <__umoddi3+0x48>
  8026fc:	39 f7                	cmp    %esi,%edi
  8026fe:	76 50                	jbe    802750 <__umoddi3+0x80>
  802700:	89 c8                	mov    %ecx,%eax
  802702:	89 f2                	mov    %esi,%edx
  802704:	f7 f7                	div    %edi
  802706:	89 d0                	mov    %edx,%eax
  802708:	31 d2                	xor    %edx,%edx
  80270a:	83 c4 1c             	add    $0x1c,%esp
  80270d:	5b                   	pop    %ebx
  80270e:	5e                   	pop    %esi
  80270f:	5f                   	pop    %edi
  802710:	5d                   	pop    %ebp
  802711:	c3                   	ret    
  802712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802718:	39 f2                	cmp    %esi,%edx
  80271a:	89 d0                	mov    %edx,%eax
  80271c:	77 52                	ja     802770 <__umoddi3+0xa0>
  80271e:	0f bd ea             	bsr    %edx,%ebp
  802721:	83 f5 1f             	xor    $0x1f,%ebp
  802724:	75 5a                	jne    802780 <__umoddi3+0xb0>
  802726:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80272a:	0f 82 e0 00 00 00    	jb     802810 <__umoddi3+0x140>
  802730:	39 0c 24             	cmp    %ecx,(%esp)
  802733:	0f 86 d7 00 00 00    	jbe    802810 <__umoddi3+0x140>
  802739:	8b 44 24 08          	mov    0x8(%esp),%eax
  80273d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802741:	83 c4 1c             	add    $0x1c,%esp
  802744:	5b                   	pop    %ebx
  802745:	5e                   	pop    %esi
  802746:	5f                   	pop    %edi
  802747:	5d                   	pop    %ebp
  802748:	c3                   	ret    
  802749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802750:	85 ff                	test   %edi,%edi
  802752:	89 fd                	mov    %edi,%ebp
  802754:	75 0b                	jne    802761 <__umoddi3+0x91>
  802756:	b8 01 00 00 00       	mov    $0x1,%eax
  80275b:	31 d2                	xor    %edx,%edx
  80275d:	f7 f7                	div    %edi
  80275f:	89 c5                	mov    %eax,%ebp
  802761:	89 f0                	mov    %esi,%eax
  802763:	31 d2                	xor    %edx,%edx
  802765:	f7 f5                	div    %ebp
  802767:	89 c8                	mov    %ecx,%eax
  802769:	f7 f5                	div    %ebp
  80276b:	89 d0                	mov    %edx,%eax
  80276d:	eb 99                	jmp    802708 <__umoddi3+0x38>
  80276f:	90                   	nop
  802770:	89 c8                	mov    %ecx,%eax
  802772:	89 f2                	mov    %esi,%edx
  802774:	83 c4 1c             	add    $0x1c,%esp
  802777:	5b                   	pop    %ebx
  802778:	5e                   	pop    %esi
  802779:	5f                   	pop    %edi
  80277a:	5d                   	pop    %ebp
  80277b:	c3                   	ret    
  80277c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802780:	8b 34 24             	mov    (%esp),%esi
  802783:	bf 20 00 00 00       	mov    $0x20,%edi
  802788:	89 e9                	mov    %ebp,%ecx
  80278a:	29 ef                	sub    %ebp,%edi
  80278c:	d3 e0                	shl    %cl,%eax
  80278e:	89 f9                	mov    %edi,%ecx
  802790:	89 f2                	mov    %esi,%edx
  802792:	d3 ea                	shr    %cl,%edx
  802794:	89 e9                	mov    %ebp,%ecx
  802796:	09 c2                	or     %eax,%edx
  802798:	89 d8                	mov    %ebx,%eax
  80279a:	89 14 24             	mov    %edx,(%esp)
  80279d:	89 f2                	mov    %esi,%edx
  80279f:	d3 e2                	shl    %cl,%edx
  8027a1:	89 f9                	mov    %edi,%ecx
  8027a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027ab:	d3 e8                	shr    %cl,%eax
  8027ad:	89 e9                	mov    %ebp,%ecx
  8027af:	89 c6                	mov    %eax,%esi
  8027b1:	d3 e3                	shl    %cl,%ebx
  8027b3:	89 f9                	mov    %edi,%ecx
  8027b5:	89 d0                	mov    %edx,%eax
  8027b7:	d3 e8                	shr    %cl,%eax
  8027b9:	89 e9                	mov    %ebp,%ecx
  8027bb:	09 d8                	or     %ebx,%eax
  8027bd:	89 d3                	mov    %edx,%ebx
  8027bf:	89 f2                	mov    %esi,%edx
  8027c1:	f7 34 24             	divl   (%esp)
  8027c4:	89 d6                	mov    %edx,%esi
  8027c6:	d3 e3                	shl    %cl,%ebx
  8027c8:	f7 64 24 04          	mull   0x4(%esp)
  8027cc:	39 d6                	cmp    %edx,%esi
  8027ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027d2:	89 d1                	mov    %edx,%ecx
  8027d4:	89 c3                	mov    %eax,%ebx
  8027d6:	72 08                	jb     8027e0 <__umoddi3+0x110>
  8027d8:	75 11                	jne    8027eb <__umoddi3+0x11b>
  8027da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027de:	73 0b                	jae    8027eb <__umoddi3+0x11b>
  8027e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027e4:	1b 14 24             	sbb    (%esp),%edx
  8027e7:	89 d1                	mov    %edx,%ecx
  8027e9:	89 c3                	mov    %eax,%ebx
  8027eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027ef:	29 da                	sub    %ebx,%edx
  8027f1:	19 ce                	sbb    %ecx,%esi
  8027f3:	89 f9                	mov    %edi,%ecx
  8027f5:	89 f0                	mov    %esi,%eax
  8027f7:	d3 e0                	shl    %cl,%eax
  8027f9:	89 e9                	mov    %ebp,%ecx
  8027fb:	d3 ea                	shr    %cl,%edx
  8027fd:	89 e9                	mov    %ebp,%ecx
  8027ff:	d3 ee                	shr    %cl,%esi
  802801:	09 d0                	or     %edx,%eax
  802803:	89 f2                	mov    %esi,%edx
  802805:	83 c4 1c             	add    $0x1c,%esp
  802808:	5b                   	pop    %ebx
  802809:	5e                   	pop    %esi
  80280a:	5f                   	pop    %edi
  80280b:	5d                   	pop    %ebp
  80280c:	c3                   	ret    
  80280d:	8d 76 00             	lea    0x0(%esi),%esi
  802810:	29 f9                	sub    %edi,%ecx
  802812:	19 d6                	sbb    %edx,%esi
  802814:	89 74 24 04          	mov    %esi,0x4(%esp)
  802818:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80281c:	e9 18 ff ff ff       	jmp    802739 <__umoddi3+0x69>
