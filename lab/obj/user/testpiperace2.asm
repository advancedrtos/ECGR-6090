
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 c0 22 80 00       	push   $0x8022c0
  800041:	e8 c1 02 00 00       	call   800307 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 b8 1a 00 00       	call   801b09 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 0e 23 80 00       	push   $0x80230e
  80005e:	6a 0d                	push   $0xd
  800060:	68 17 23 80 00       	push   $0x802317
  800065:	e8 c4 01 00 00       	call   80022e <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 01 0f 00 00       	call   800f70 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 e1 27 80 00       	push   $0x8027e1
  80007b:	6a 0f                	push   $0xf
  80007d:	68 17 23 80 00       	push   $0x802317
  800082:	e8 a7 01 00 00       	call   80022e <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 5e 12 00 00       	call   8012f4 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 2c 23 80 00       	push   $0x80232c
  8000c3:	e8 3f 02 00 00       	call   800307 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 6c 12 00 00       	call   801344 <dup>
			sys_yield();
  8000d8:	e8 93 0b 00 00       	call   800c70 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 0b 12 00 00       	call   8012f4 <close>
			sys_yield();
  8000e9:	e8 82 0b 00 00       	call   800c70 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 3a 1b 00 00       	call   801c5c <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 30 23 80 00       	push   $0x802330
  800131:	e8 d1 01 00 00       	call   800307 <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 d2 0a 00 00       	call   800c10 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 4c 23 80 00       	push   $0x80234c
  800161:	e8 a1 01 00 00       	call   800307 <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 eb 1a 00 00       	call   801c5c <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 e4 22 80 00       	push   $0x8022e4
  800180:	6a 40                	push   $0x40
  800182:	68 17 23 80 00       	push   $0x802317
  800187:	e8 a2 00 00 00       	call   80022e <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 2f 10 00 00       	call   8011ca <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 62 23 80 00       	push   $0x802362
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 17 23 80 00       	push   $0x802317
  8001af:	e8 7a 00 00 00       	call   80022e <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 a5 0f 00 00       	call   801164 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 7a 23 80 00 	movl   $0x80237a,(%esp)
  8001c6:	e8 3c 01 00 00       	call   800307 <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  8001e1:	e8 6b 0a 00 00       	call   800c51 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800222:	6a 00                	push   $0x0
  800224:	e8 e7 09 00 00       	call   800c10 <sys_env_destroy>
}
  800229:	83 c4 10             	add    $0x10,%esp
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800233:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800236:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023c:	e8 10 0a 00 00       	call   800c51 <sys_getenvid>
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	ff 75 08             	pushl  0x8(%ebp)
  80024a:	56                   	push   %esi
  80024b:	50                   	push   %eax
  80024c:	68 98 23 80 00       	push   $0x802398
  800251:	e8 b1 00 00 00       	call   800307 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	53                   	push   %ebx
  80025a:	ff 75 10             	pushl  0x10(%ebp)
  80025d:	e8 54 00 00 00       	call   8002b6 <vcprintf>
	cprintf("\n");
  800262:	c7 04 24 51 29 80 00 	movl   $0x802951,(%esp)
  800269:	e8 99 00 00 00       	call   800307 <cprintf>
  80026e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800271:	cc                   	int3   
  800272:	eb fd                	jmp    800271 <_panic+0x43>

00800274 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	53                   	push   %ebx
  800278:	83 ec 04             	sub    $0x4,%esp
  80027b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027e:	8b 13                	mov    (%ebx),%edx
  800280:	8d 42 01             	lea    0x1(%edx),%eax
  800283:	89 03                	mov    %eax,(%ebx)
  800285:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800288:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800291:	75 1a                	jne    8002ad <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	68 ff 00 00 00       	push   $0xff
  80029b:	8d 43 08             	lea    0x8(%ebx),%eax
  80029e:	50                   	push   %eax
  80029f:	e8 2f 09 00 00       	call   800bd3 <sys_cputs>
		b->idx = 0;
  8002a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002aa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    

008002b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c6:	00 00 00 
	b.cnt = 0;
  8002c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002df:	50                   	push   %eax
  8002e0:	68 74 02 80 00       	push   $0x800274
  8002e5:	e8 54 01 00 00       	call   80043e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ea:	83 c4 08             	add    $0x8,%esp
  8002ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	e8 d4 08 00 00       	call   800bd3 <sys_cputs>

	return b.cnt;
}
  8002ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800310:	50                   	push   %eax
  800311:	ff 75 08             	pushl  0x8(%ebp)
  800314:	e8 9d ff ff ff       	call   8002b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 1c             	sub    $0x1c,%esp
  800324:	89 c7                	mov    %eax,%edi
  800326:	89 d6                	mov    %edx,%esi
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800331:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800334:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800337:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80033f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800342:	39 d3                	cmp    %edx,%ebx
  800344:	72 05                	jb     80034b <printnum+0x30>
  800346:	39 45 10             	cmp    %eax,0x10(%ebp)
  800349:	77 45                	ja     800390 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034b:	83 ec 0c             	sub    $0xc,%esp
  80034e:	ff 75 18             	pushl  0x18(%ebp)
  800351:	8b 45 14             	mov    0x14(%ebp),%eax
  800354:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800357:	53                   	push   %ebx
  800358:	ff 75 10             	pushl  0x10(%ebp)
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800361:	ff 75 e0             	pushl  -0x20(%ebp)
  800364:	ff 75 dc             	pushl  -0x24(%ebp)
  800367:	ff 75 d8             	pushl  -0x28(%ebp)
  80036a:	e8 c1 1c 00 00       	call   802030 <__udivdi3>
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	52                   	push   %edx
  800373:	50                   	push   %eax
  800374:	89 f2                	mov    %esi,%edx
  800376:	89 f8                	mov    %edi,%eax
  800378:	e8 9e ff ff ff       	call   80031b <printnum>
  80037d:	83 c4 20             	add    $0x20,%esp
  800380:	eb 18                	jmp    80039a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	56                   	push   %esi
  800386:	ff 75 18             	pushl  0x18(%ebp)
  800389:	ff d7                	call   *%edi
  80038b:	83 c4 10             	add    $0x10,%esp
  80038e:	eb 03                	jmp    800393 <printnum+0x78>
  800390:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800393:	83 eb 01             	sub    $0x1,%ebx
  800396:	85 db                	test   %ebx,%ebx
  800398:	7f e8                	jg     800382 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039a:	83 ec 08             	sub    $0x8,%esp
  80039d:	56                   	push   %esi
  80039e:	83 ec 04             	sub    $0x4,%esp
  8003a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8003aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ad:	e8 ae 1d 00 00       	call   802160 <__umoddi3>
  8003b2:	83 c4 14             	add    $0x14,%esp
  8003b5:	0f be 80 bb 23 80 00 	movsbl 0x8023bb(%eax),%eax
  8003bc:	50                   	push   %eax
  8003bd:	ff d7                	call   *%edi
}
  8003bf:	83 c4 10             	add    $0x10,%esp
  8003c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c5:	5b                   	pop    %ebx
  8003c6:	5e                   	pop    %esi
  8003c7:	5f                   	pop    %edi
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cd:	83 fa 01             	cmp    $0x1,%edx
  8003d0:	7e 0e                	jle    8003e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d2:	8b 10                	mov    (%eax),%edx
  8003d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d7:	89 08                	mov    %ecx,(%eax)
  8003d9:	8b 02                	mov    (%edx),%eax
  8003db:	8b 52 04             	mov    0x4(%edx),%edx
  8003de:	eb 22                	jmp    800402 <getuint+0x38>
	else if (lflag)
  8003e0:	85 d2                	test   %edx,%edx
  8003e2:	74 10                	je     8003f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e4:	8b 10                	mov    (%eax),%edx
  8003e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e9:	89 08                	mov    %ecx,(%eax)
  8003eb:	8b 02                	mov    (%edx),%eax
  8003ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f2:	eb 0e                	jmp    800402 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f9:	89 08                	mov    %ecx,(%eax)
  8003fb:	8b 02                	mov    (%edx),%eax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040e:	8b 10                	mov    (%eax),%edx
  800410:	3b 50 04             	cmp    0x4(%eax),%edx
  800413:	73 0a                	jae    80041f <sprintputch+0x1b>
		*b->buf++ = ch;
  800415:	8d 4a 01             	lea    0x1(%edx),%ecx
  800418:	89 08                	mov    %ecx,(%eax)
  80041a:	8b 45 08             	mov    0x8(%ebp),%eax
  80041d:	88 02                	mov    %al,(%edx)
}
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800427:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042a:	50                   	push   %eax
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	ff 75 0c             	pushl  0xc(%ebp)
  800431:	ff 75 08             	pushl  0x8(%ebp)
  800434:	e8 05 00 00 00       	call   80043e <vprintfmt>
	va_end(ap);
}
  800439:	83 c4 10             	add    $0x10,%esp
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	57                   	push   %edi
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
  800444:	83 ec 2c             	sub    $0x2c,%esp
  800447:	8b 75 08             	mov    0x8(%ebp),%esi
  80044a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800450:	eb 12                	jmp    800464 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800452:	85 c0                	test   %eax,%eax
  800454:	0f 84 89 03 00 00    	je     8007e3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	50                   	push   %eax
  80045f:	ff d6                	call   *%esi
  800461:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800464:	83 c7 01             	add    $0x1,%edi
  800467:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80046b:	83 f8 25             	cmp    $0x25,%eax
  80046e:	75 e2                	jne    800452 <vprintfmt+0x14>
  800470:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800474:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80047b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800482:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800489:	ba 00 00 00 00       	mov    $0x0,%edx
  80048e:	eb 07                	jmp    800497 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800493:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8d 47 01             	lea    0x1(%edi),%eax
  80049a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049d:	0f b6 07             	movzbl (%edi),%eax
  8004a0:	0f b6 c8             	movzbl %al,%ecx
  8004a3:	83 e8 23             	sub    $0x23,%eax
  8004a6:	3c 55                	cmp    $0x55,%al
  8004a8:	0f 87 1a 03 00 00    	ja     8007c8 <vprintfmt+0x38a>
  8004ae:	0f b6 c0             	movzbl %al,%eax
  8004b1:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004bf:	eb d6                	jmp    800497 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004cf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004d6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004d9:	83 fa 09             	cmp    $0x9,%edx
  8004dc:	77 39                	ja     800517 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e1:	eb e9                	jmp    8004cc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8004e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f4:	eb 27                	jmp    80051d <vprintfmt+0xdf>
  8004f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800500:	0f 49 c8             	cmovns %eax,%ecx
  800503:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	eb 8c                	jmp    800497 <vprintfmt+0x59>
  80050b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800515:	eb 80                	jmp    800497 <vprintfmt+0x59>
  800517:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80051d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800521:	0f 89 70 ff ff ff    	jns    800497 <vprintfmt+0x59>
				width = precision, precision = -1;
  800527:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80052a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800534:	e9 5e ff ff ff       	jmp    800497 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800539:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053f:	e9 53 ff ff ff       	jmp    800497 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	53                   	push   %ebx
  800551:	ff 30                	pushl  (%eax)
  800553:	ff d6                	call   *%esi
			break;
  800555:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80055b:	e9 04 ff ff ff       	jmp    800464 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	99                   	cltd   
  80056c:	31 d0                	xor    %edx,%eax
  80056e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800570:	83 f8 0f             	cmp    $0xf,%eax
  800573:	7f 0b                	jg     800580 <vprintfmt+0x142>
  800575:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  80057c:	85 d2                	test   %edx,%edx
  80057e:	75 18                	jne    800598 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800580:	50                   	push   %eax
  800581:	68 d3 23 80 00       	push   $0x8023d3
  800586:	53                   	push   %ebx
  800587:	56                   	push   %esi
  800588:	e8 94 fe ff ff       	call   800421 <printfmt>
  80058d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800593:	e9 cc fe ff ff       	jmp    800464 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800598:	52                   	push   %edx
  800599:	68 2a 29 80 00       	push   $0x80292a
  80059e:	53                   	push   %ebx
  80059f:	56                   	push   %esi
  8005a0:	e8 7c fe ff ff       	call   800421 <printfmt>
  8005a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ab:	e9 b4 fe ff ff       	jmp    800464 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005bb:	85 ff                	test   %edi,%edi
  8005bd:	b8 cc 23 80 00       	mov    $0x8023cc,%eax
  8005c2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c9:	0f 8e 94 00 00 00    	jle    800663 <vprintfmt+0x225>
  8005cf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d3:	0f 84 98 00 00 00    	je     800671 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	ff 75 d0             	pushl  -0x30(%ebp)
  8005df:	57                   	push   %edi
  8005e0:	e8 86 02 00 00       	call   80086b <strnlen>
  8005e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e8:	29 c1                	sub    %eax,%ecx
  8005ea:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005ed:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005fa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fc:	eb 0f                	jmp    80060d <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	ff 75 e0             	pushl  -0x20(%ebp)
  800605:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800607:	83 ef 01             	sub    $0x1,%edi
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	85 ff                	test   %edi,%edi
  80060f:	7f ed                	jg     8005fe <vprintfmt+0x1c0>
  800611:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800614:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800617:	85 c9                	test   %ecx,%ecx
  800619:	b8 00 00 00 00       	mov    $0x0,%eax
  80061e:	0f 49 c1             	cmovns %ecx,%eax
  800621:	29 c1                	sub    %eax,%ecx
  800623:	89 75 08             	mov    %esi,0x8(%ebp)
  800626:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800629:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80062c:	89 cb                	mov    %ecx,%ebx
  80062e:	eb 4d                	jmp    80067d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800630:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800634:	74 1b                	je     800651 <vprintfmt+0x213>
  800636:	0f be c0             	movsbl %al,%eax
  800639:	83 e8 20             	sub    $0x20,%eax
  80063c:	83 f8 5e             	cmp    $0x5e,%eax
  80063f:	76 10                	jbe    800651 <vprintfmt+0x213>
					putch('?', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	ff 75 0c             	pushl  0xc(%ebp)
  800647:	6a 3f                	push   $0x3f
  800649:	ff 55 08             	call   *0x8(%ebp)
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	eb 0d                	jmp    80065e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	ff 75 0c             	pushl  0xc(%ebp)
  800657:	52                   	push   %edx
  800658:	ff 55 08             	call   *0x8(%ebp)
  80065b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065e:	83 eb 01             	sub    $0x1,%ebx
  800661:	eb 1a                	jmp    80067d <vprintfmt+0x23f>
  800663:	89 75 08             	mov    %esi,0x8(%ebp)
  800666:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800669:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066f:	eb 0c                	jmp    80067d <vprintfmt+0x23f>
  800671:	89 75 08             	mov    %esi,0x8(%ebp)
  800674:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800677:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067d:	83 c7 01             	add    $0x1,%edi
  800680:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800684:	0f be d0             	movsbl %al,%edx
  800687:	85 d2                	test   %edx,%edx
  800689:	74 23                	je     8006ae <vprintfmt+0x270>
  80068b:	85 f6                	test   %esi,%esi
  80068d:	78 a1                	js     800630 <vprintfmt+0x1f2>
  80068f:	83 ee 01             	sub    $0x1,%esi
  800692:	79 9c                	jns    800630 <vprintfmt+0x1f2>
  800694:	89 df                	mov    %ebx,%edi
  800696:	8b 75 08             	mov    0x8(%ebp),%esi
  800699:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80069c:	eb 18                	jmp    8006b6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 20                	push   $0x20
  8006a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a6:	83 ef 01             	sub    $0x1,%edi
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	eb 08                	jmp    8006b6 <vprintfmt+0x278>
  8006ae:	89 df                	mov    %ebx,%edi
  8006b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b6:	85 ff                	test   %edi,%edi
  8006b8:	7f e4                	jg     80069e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bd:	e9 a2 fd ff ff       	jmp    800464 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c2:	83 fa 01             	cmp    $0x1,%edx
  8006c5:	7e 16                	jle    8006dd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 50 08             	lea    0x8(%eax),%edx
  8006cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d0:	8b 50 04             	mov    0x4(%eax),%edx
  8006d3:	8b 00                	mov    (%eax),%eax
  8006d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006db:	eb 32                	jmp    80070f <vprintfmt+0x2d1>
	else if (lflag)
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	74 18                	je     8006f9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 50 04             	lea    0x4(%eax),%edx
  8006e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ef:	89 c1                	mov    %eax,%ecx
  8006f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f7:	eb 16                	jmp    80070f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8d 50 04             	lea    0x4(%eax),%edx
  8006ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800702:	8b 00                	mov    (%eax),%eax
  800704:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800707:	89 c1                	mov    %eax,%ecx
  800709:	c1 f9 1f             	sar    $0x1f,%ecx
  80070c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800712:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800715:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80071e:	79 74                	jns    800794 <vprintfmt+0x356>
				putch('-', putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	6a 2d                	push   $0x2d
  800726:	ff d6                	call   *%esi
				num = -(long long) num;
  800728:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80072e:	f7 d8                	neg    %eax
  800730:	83 d2 00             	adc    $0x0,%edx
  800733:	f7 da                	neg    %edx
  800735:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800738:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80073d:	eb 55                	jmp    800794 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
  800742:	e8 83 fc ff ff       	call   8003ca <getuint>
			base = 10;
  800747:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80074c:	eb 46                	jmp    800794 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
  800751:	e8 74 fc ff ff       	call   8003ca <getuint>
			base = 8;
  800756:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80075b:	eb 37                	jmp    800794 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	53                   	push   %ebx
  800761:	6a 30                	push   $0x30
  800763:	ff d6                	call   *%esi
			putch('x', putdat);
  800765:	83 c4 08             	add    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	6a 78                	push   $0x78
  80076b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8d 50 04             	lea    0x4(%eax),%edx
  800773:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800776:	8b 00                	mov    (%eax),%eax
  800778:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80077d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800780:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800785:	eb 0d                	jmp    800794 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
  80078a:	e8 3b fc ff ff       	call   8003ca <getuint>
			base = 16;
  80078f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800794:	83 ec 0c             	sub    $0xc,%esp
  800797:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80079b:	57                   	push   %edi
  80079c:	ff 75 e0             	pushl  -0x20(%ebp)
  80079f:	51                   	push   %ecx
  8007a0:	52                   	push   %edx
  8007a1:	50                   	push   %eax
  8007a2:	89 da                	mov    %ebx,%edx
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	e8 70 fb ff ff       	call   80031b <printnum>
			break;
  8007ab:	83 c4 20             	add    $0x20,%esp
  8007ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b1:	e9 ae fc ff ff       	jmp    800464 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	53                   	push   %ebx
  8007ba:	51                   	push   %ecx
  8007bb:	ff d6                	call   *%esi
			break;
  8007bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c3:	e9 9c fc ff ff       	jmp    800464 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	6a 25                	push   $0x25
  8007ce:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	eb 03                	jmp    8007d8 <vprintfmt+0x39a>
  8007d5:	83 ef 01             	sub    $0x1,%edi
  8007d8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007dc:	75 f7                	jne    8007d5 <vprintfmt+0x397>
  8007de:	e9 81 fc ff ff       	jmp    800464 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	5f                   	pop    %edi
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	83 ec 18             	sub    $0x18,%esp
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800801:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800808:	85 c0                	test   %eax,%eax
  80080a:	74 26                	je     800832 <vsnprintf+0x47>
  80080c:	85 d2                	test   %edx,%edx
  80080e:	7e 22                	jle    800832 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800810:	ff 75 14             	pushl  0x14(%ebp)
  800813:	ff 75 10             	pushl  0x10(%ebp)
  800816:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800819:	50                   	push   %eax
  80081a:	68 04 04 80 00       	push   $0x800404
  80081f:	e8 1a fc ff ff       	call   80043e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800824:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800827:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	eb 05                	jmp    800837 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800842:	50                   	push   %eax
  800843:	ff 75 10             	pushl  0x10(%ebp)
  800846:	ff 75 0c             	pushl  0xc(%ebp)
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 9a ff ff ff       	call   8007eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
  80085e:	eb 03                	jmp    800863 <strlen+0x10>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f7                	jne    800860 <strlen+0xd>
		n++;
	return n;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800874:	ba 00 00 00 00       	mov    $0x0,%edx
  800879:	eb 03                	jmp    80087e <strnlen+0x13>
		n++;
  80087b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087e:	39 c2                	cmp    %eax,%edx
  800880:	74 08                	je     80088a <strnlen+0x1f>
  800882:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800886:	75 f3                	jne    80087b <strnlen+0x10>
  800888:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	53                   	push   %ebx
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800896:	89 c2                	mov    %eax,%edx
  800898:	83 c2 01             	add    $0x1,%edx
  80089b:	83 c1 01             	add    $0x1,%ecx
  80089e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a5:	84 db                	test   %bl,%bl
  8008a7:	75 ef                	jne    800898 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b3:	53                   	push   %ebx
  8008b4:	e8 9a ff ff ff       	call   800853 <strlen>
  8008b9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008bc:	ff 75 0c             	pushl  0xc(%ebp)
  8008bf:	01 d8                	add    %ebx,%eax
  8008c1:	50                   	push   %eax
  8008c2:	e8 c5 ff ff ff       	call   80088c <strcpy>
	return dst;
}
  8008c7:	89 d8                	mov    %ebx,%eax
  8008c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    

008008ce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d9:	89 f3                	mov    %esi,%ebx
  8008db:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008de:	89 f2                	mov    %esi,%edx
  8008e0:	eb 0f                	jmp    8008f1 <strncpy+0x23>
		*dst++ = *src;
  8008e2:	83 c2 01             	add    $0x1,%edx
  8008e5:	0f b6 01             	movzbl (%ecx),%eax
  8008e8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008eb:	80 39 01             	cmpb   $0x1,(%ecx)
  8008ee:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f1:	39 da                	cmp    %ebx,%edx
  8008f3:	75 ed                	jne    8008e2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f5:	89 f0                	mov    %esi,%eax
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 75 08             	mov    0x8(%ebp),%esi
  800903:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800906:	8b 55 10             	mov    0x10(%ebp),%edx
  800909:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090b:	85 d2                	test   %edx,%edx
  80090d:	74 21                	je     800930 <strlcpy+0x35>
  80090f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800913:	89 f2                	mov    %esi,%edx
  800915:	eb 09                	jmp    800920 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800917:	83 c2 01             	add    $0x1,%edx
  80091a:	83 c1 01             	add    $0x1,%ecx
  80091d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800920:	39 c2                	cmp    %eax,%edx
  800922:	74 09                	je     80092d <strlcpy+0x32>
  800924:	0f b6 19             	movzbl (%ecx),%ebx
  800927:	84 db                	test   %bl,%bl
  800929:	75 ec                	jne    800917 <strlcpy+0x1c>
  80092b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800930:	29 f0                	sub    %esi,%eax
}
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093f:	eb 06                	jmp    800947 <strcmp+0x11>
		p++, q++;
  800941:	83 c1 01             	add    $0x1,%ecx
  800944:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800947:	0f b6 01             	movzbl (%ecx),%eax
  80094a:	84 c0                	test   %al,%al
  80094c:	74 04                	je     800952 <strcmp+0x1c>
  80094e:	3a 02                	cmp    (%edx),%al
  800950:	74 ef                	je     800941 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800952:	0f b6 c0             	movzbl %al,%eax
  800955:	0f b6 12             	movzbl (%edx),%edx
  800958:	29 d0                	sub    %edx,%eax
}
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 55 0c             	mov    0xc(%ebp),%edx
  800966:	89 c3                	mov    %eax,%ebx
  800968:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80096b:	eb 06                	jmp    800973 <strncmp+0x17>
		n--, p++, q++;
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800973:	39 d8                	cmp    %ebx,%eax
  800975:	74 15                	je     80098c <strncmp+0x30>
  800977:	0f b6 08             	movzbl (%eax),%ecx
  80097a:	84 c9                	test   %cl,%cl
  80097c:	74 04                	je     800982 <strncmp+0x26>
  80097e:	3a 0a                	cmp    (%edx),%cl
  800980:	74 eb                	je     80096d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800982:	0f b6 00             	movzbl (%eax),%eax
  800985:	0f b6 12             	movzbl (%edx),%edx
  800988:	29 d0                	sub    %edx,%eax
  80098a:	eb 05                	jmp    800991 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800991:	5b                   	pop    %ebx
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099e:	eb 07                	jmp    8009a7 <strchr+0x13>
		if (*s == c)
  8009a0:	38 ca                	cmp    %cl,%dl
  8009a2:	74 0f                	je     8009b3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a4:	83 c0 01             	add    $0x1,%eax
  8009a7:	0f b6 10             	movzbl (%eax),%edx
  8009aa:	84 d2                	test   %dl,%dl
  8009ac:	75 f2                	jne    8009a0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bf:	eb 03                	jmp    8009c4 <strfind+0xf>
  8009c1:	83 c0 01             	add    $0x1,%eax
  8009c4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009c7:	38 ca                	cmp    %cl,%dl
  8009c9:	74 04                	je     8009cf <strfind+0x1a>
  8009cb:	84 d2                	test   %dl,%dl
  8009cd:	75 f2                	jne    8009c1 <strfind+0xc>
			break;
	return (char *) s;
}
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009dd:	85 c9                	test   %ecx,%ecx
  8009df:	74 36                	je     800a17 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e7:	75 28                	jne    800a11 <memset+0x40>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 23                	jne    800a11 <memset+0x40>
		c &= 0xFF;
  8009ee:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f2:	89 d3                	mov    %edx,%ebx
  8009f4:	c1 e3 08             	shl    $0x8,%ebx
  8009f7:	89 d6                	mov    %edx,%esi
  8009f9:	c1 e6 18             	shl    $0x18,%esi
  8009fc:	89 d0                	mov    %edx,%eax
  8009fe:	c1 e0 10             	shl    $0x10,%eax
  800a01:	09 f0                	or     %esi,%eax
  800a03:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a05:	89 d8                	mov    %ebx,%eax
  800a07:	09 d0                	or     %edx,%eax
  800a09:	c1 e9 02             	shr    $0x2,%ecx
  800a0c:	fc                   	cld    
  800a0d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a0f:	eb 06                	jmp    800a17 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	fc                   	cld    
  800a15:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a17:	89 f8                	mov    %edi,%eax
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a2c:	39 c6                	cmp    %eax,%esi
  800a2e:	73 35                	jae    800a65 <memmove+0x47>
  800a30:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a33:	39 d0                	cmp    %edx,%eax
  800a35:	73 2e                	jae    800a65 <memmove+0x47>
		s += n;
		d += n;
  800a37:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3a:	89 d6                	mov    %edx,%esi
  800a3c:	09 fe                	or     %edi,%esi
  800a3e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a44:	75 13                	jne    800a59 <memmove+0x3b>
  800a46:	f6 c1 03             	test   $0x3,%cl
  800a49:	75 0e                	jne    800a59 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a4b:	83 ef 04             	sub    $0x4,%edi
  800a4e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a51:	c1 e9 02             	shr    $0x2,%ecx
  800a54:	fd                   	std    
  800a55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a57:	eb 09                	jmp    800a62 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a59:	83 ef 01             	sub    $0x1,%edi
  800a5c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a5f:	fd                   	std    
  800a60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a62:	fc                   	cld    
  800a63:	eb 1d                	jmp    800a82 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a65:	89 f2                	mov    %esi,%edx
  800a67:	09 c2                	or     %eax,%edx
  800a69:	f6 c2 03             	test   $0x3,%dl
  800a6c:	75 0f                	jne    800a7d <memmove+0x5f>
  800a6e:	f6 c1 03             	test   $0x3,%cl
  800a71:	75 0a                	jne    800a7d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a73:	c1 e9 02             	shr    $0x2,%ecx
  800a76:	89 c7                	mov    %eax,%edi
  800a78:	fc                   	cld    
  800a79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7b:	eb 05                	jmp    800a82 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a7d:	89 c7                	mov    %eax,%edi
  800a7f:	fc                   	cld    
  800a80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a89:	ff 75 10             	pushl  0x10(%ebp)
  800a8c:	ff 75 0c             	pushl  0xc(%ebp)
  800a8f:	ff 75 08             	pushl  0x8(%ebp)
  800a92:	e8 87 ff ff ff       	call   800a1e <memmove>
}
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa4:	89 c6                	mov    %eax,%esi
  800aa6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa9:	eb 1a                	jmp    800ac5 <memcmp+0x2c>
		if (*s1 != *s2)
  800aab:	0f b6 08             	movzbl (%eax),%ecx
  800aae:	0f b6 1a             	movzbl (%edx),%ebx
  800ab1:	38 d9                	cmp    %bl,%cl
  800ab3:	74 0a                	je     800abf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab5:	0f b6 c1             	movzbl %cl,%eax
  800ab8:	0f b6 db             	movzbl %bl,%ebx
  800abb:	29 d8                	sub    %ebx,%eax
  800abd:	eb 0f                	jmp    800ace <memcmp+0x35>
		s1++, s2++;
  800abf:	83 c0 01             	add    $0x1,%eax
  800ac2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac5:	39 f0                	cmp    %esi,%eax
  800ac7:	75 e2                	jne    800aab <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	53                   	push   %ebx
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad9:	89 c1                	mov    %eax,%ecx
  800adb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ade:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae2:	eb 0a                	jmp    800aee <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae4:	0f b6 10             	movzbl (%eax),%edx
  800ae7:	39 da                	cmp    %ebx,%edx
  800ae9:	74 07                	je     800af2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	39 c8                	cmp    %ecx,%eax
  800af0:	72 f2                	jb     800ae4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af2:	5b                   	pop    %ebx
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b01:	eb 03                	jmp    800b06 <strtol+0x11>
		s++;
  800b03:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b06:	0f b6 01             	movzbl (%ecx),%eax
  800b09:	3c 20                	cmp    $0x20,%al
  800b0b:	74 f6                	je     800b03 <strtol+0xe>
  800b0d:	3c 09                	cmp    $0x9,%al
  800b0f:	74 f2                	je     800b03 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b11:	3c 2b                	cmp    $0x2b,%al
  800b13:	75 0a                	jne    800b1f <strtol+0x2a>
		s++;
  800b15:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b18:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1d:	eb 11                	jmp    800b30 <strtol+0x3b>
  800b1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b24:	3c 2d                	cmp    $0x2d,%al
  800b26:	75 08                	jne    800b30 <strtol+0x3b>
		s++, neg = 1;
  800b28:	83 c1 01             	add    $0x1,%ecx
  800b2b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b36:	75 15                	jne    800b4d <strtol+0x58>
  800b38:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3b:	75 10                	jne    800b4d <strtol+0x58>
  800b3d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b41:	75 7c                	jne    800bbf <strtol+0xca>
		s += 2, base = 16;
  800b43:	83 c1 02             	add    $0x2,%ecx
  800b46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4b:	eb 16                	jmp    800b63 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b4d:	85 db                	test   %ebx,%ebx
  800b4f:	75 12                	jne    800b63 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b51:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b56:	80 39 30             	cmpb   $0x30,(%ecx)
  800b59:	75 08                	jne    800b63 <strtol+0x6e>
		s++, base = 8;
  800b5b:	83 c1 01             	add    $0x1,%ecx
  800b5e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
  800b68:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b6b:	0f b6 11             	movzbl (%ecx),%edx
  800b6e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b71:	89 f3                	mov    %esi,%ebx
  800b73:	80 fb 09             	cmp    $0x9,%bl
  800b76:	77 08                	ja     800b80 <strtol+0x8b>
			dig = *s - '0';
  800b78:	0f be d2             	movsbl %dl,%edx
  800b7b:	83 ea 30             	sub    $0x30,%edx
  800b7e:	eb 22                	jmp    800ba2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b80:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b83:	89 f3                	mov    %esi,%ebx
  800b85:	80 fb 19             	cmp    $0x19,%bl
  800b88:	77 08                	ja     800b92 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b8a:	0f be d2             	movsbl %dl,%edx
  800b8d:	83 ea 57             	sub    $0x57,%edx
  800b90:	eb 10                	jmp    800ba2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b92:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b95:	89 f3                	mov    %esi,%ebx
  800b97:	80 fb 19             	cmp    $0x19,%bl
  800b9a:	77 16                	ja     800bb2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b9c:	0f be d2             	movsbl %dl,%edx
  800b9f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba5:	7d 0b                	jge    800bb2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bae:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb0:	eb b9                	jmp    800b6b <strtol+0x76>

	if (endptr)
  800bb2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb6:	74 0d                	je     800bc5 <strtol+0xd0>
		*endptr = (char *) s;
  800bb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbb:	89 0e                	mov    %ecx,(%esi)
  800bbd:	eb 06                	jmp    800bc5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbf:	85 db                	test   %ebx,%ebx
  800bc1:	74 98                	je     800b5b <strtol+0x66>
  800bc3:	eb 9e                	jmp    800b63 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bc5:	89 c2                	mov    %eax,%edx
  800bc7:	f7 da                	neg    %edx
  800bc9:	85 ff                	test   %edi,%edi
  800bcb:	0f 45 c2             	cmovne %edx,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be1:	8b 55 08             	mov    0x8(%ebp),%edx
  800be4:	89 c3                	mov    %eax,%ebx
  800be6:	89 c7                	mov    %eax,%edi
  800be8:	89 c6                	mov    %eax,%esi
  800bea:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 01 00 00 00       	mov    $0x1,%eax
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	89 cb                	mov    %ecx,%ebx
  800c28:	89 cf                	mov    %ecx,%edi
  800c2a:	89 ce                	mov    %ecx,%esi
  800c2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 03                	push   $0x3
  800c38:	68 bf 26 80 00       	push   $0x8026bf
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 dc 26 80 00       	push   $0x8026dc
  800c44:	e8 e5 f5 ff ff       	call   80022e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c57:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c61:	89 d1                	mov    %edx,%ecx
  800c63:	89 d3                	mov    %edx,%ebx
  800c65:	89 d7                	mov    %edx,%edi
  800c67:	89 d6                	mov    %edx,%esi
  800c69:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_yield>:

void
sys_yield(void)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c80:	89 d1                	mov    %edx,%ecx
  800c82:	89 d3                	mov    %edx,%ebx
  800c84:	89 d7                	mov    %edx,%edi
  800c86:	89 d6                	mov    %edx,%esi
  800c88:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	be 00 00 00 00       	mov    $0x0,%esi
  800c9d:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cab:	89 f7                	mov    %esi,%edi
  800cad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7e 17                	jle    800cca <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 04                	push   $0x4
  800cb9:	68 bf 26 80 00       	push   $0x8026bf
  800cbe:	6a 23                	push   $0x23
  800cc0:	68 dc 26 80 00       	push   $0x8026dc
  800cc5:	e8 64 f5 ff ff       	call   80022e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cec:	8b 75 18             	mov    0x18(%ebp),%esi
  800cef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7e 17                	jle    800d0c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	83 ec 0c             	sub    $0xc,%esp
  800cf8:	50                   	push   %eax
  800cf9:	6a 05                	push   $0x5
  800cfb:	68 bf 26 80 00       	push   $0x8026bf
  800d00:	6a 23                	push   $0x23
  800d02:	68 dc 26 80 00       	push   $0x8026dc
  800d07:	e8 22 f5 ff ff       	call   80022e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d22:	b8 06 00 00 00       	mov    $0x6,%eax
  800d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 df                	mov    %ebx,%edi
  800d2f:	89 de                	mov    %ebx,%esi
  800d31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7e 17                	jle    800d4e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	50                   	push   %eax
  800d3b:	6a 06                	push   $0x6
  800d3d:	68 bf 26 80 00       	push   $0x8026bf
  800d42:	6a 23                	push   $0x23
  800d44:	68 dc 26 80 00       	push   $0x8026dc
  800d49:	e8 e0 f4 ff ff       	call   80022e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d64:	b8 08 00 00 00       	mov    $0x8,%eax
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	89 df                	mov    %ebx,%edi
  800d71:	89 de                	mov    %ebx,%esi
  800d73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d75:	85 c0                	test   %eax,%eax
  800d77:	7e 17                	jle    800d90 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	50                   	push   %eax
  800d7d:	6a 08                	push   $0x8
  800d7f:	68 bf 26 80 00       	push   $0x8026bf
  800d84:	6a 23                	push   $0x23
  800d86:	68 dc 26 80 00       	push   $0x8026dc
  800d8b:	e8 9e f4 ff ff       	call   80022e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da6:	b8 09 00 00 00       	mov    $0x9,%eax
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	89 df                	mov    %ebx,%edi
  800db3:	89 de                	mov    %ebx,%esi
  800db5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db7:	85 c0                	test   %eax,%eax
  800db9:	7e 17                	jle    800dd2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	50                   	push   %eax
  800dbf:	6a 09                	push   $0x9
  800dc1:	68 bf 26 80 00       	push   $0x8026bf
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 dc 26 80 00       	push   $0x8026dc
  800dcd:	e8 5c f4 ff ff       	call   80022e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 df                	mov    %ebx,%edi
  800df5:	89 de                	mov    %ebx,%esi
  800df7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7e 17                	jle    800e14 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	50                   	push   %eax
  800e01:	6a 0a                	push   $0xa
  800e03:	68 bf 26 80 00       	push   $0x8026bf
  800e08:	6a 23                	push   $0x23
  800e0a:	68 dc 26 80 00       	push   $0x8026dc
  800e0f:	e8 1a f4 ff ff       	call   80022e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e17:	5b                   	pop    %ebx
  800e18:	5e                   	pop    %esi
  800e19:	5f                   	pop    %edi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e22:	be 00 00 00 00       	mov    $0x0,%esi
  800e27:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e38:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e52:	8b 55 08             	mov    0x8(%ebp),%edx
  800e55:	89 cb                	mov    %ecx,%ebx
  800e57:	89 cf                	mov    %ecx,%edi
  800e59:	89 ce                	mov    %ecx,%esi
  800e5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	7e 17                	jle    800e78 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e61:	83 ec 0c             	sub    $0xc,%esp
  800e64:	50                   	push   %eax
  800e65:	6a 0d                	push   $0xd
  800e67:	68 bf 26 80 00       	push   $0x8026bf
  800e6c:	6a 23                	push   $0x23
  800e6e:	68 dc 26 80 00       	push   $0x8026dc
  800e73:	e8 b6 f3 ff ff       	call   80022e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	53                   	push   %ebx
  800e84:	83 ec 04             	sub    $0x4,%esp
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e8a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800e8c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e90:	75 14                	jne    800ea6 <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800e92:	83 ec 04             	sub    $0x4,%esp
  800e95:	68 ec 26 80 00       	push   $0x8026ec
  800e9a:	6a 22                	push   $0x22
  800e9c:	68 cf 27 80 00       	push   $0x8027cf
  800ea1:	e8 88 f3 ff ff       	call   80022e <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800ea6:	89 d8                	mov    %ebx,%eax
  800ea8:	c1 e8 0c             	shr    $0xc,%eax
  800eab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb2:	f6 c4 08             	test   $0x8,%ah
  800eb5:	75 14                	jne    800ecb <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800eb7:	83 ec 04             	sub    $0x4,%esp
  800eba:	68 28 27 80 00       	push   $0x802728
  800ebf:	6a 27                	push   $0x27
  800ec1:	68 cf 27 80 00       	push   $0x8027cf
  800ec6:	e8 63 f3 ff ff       	call   80022e <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800ecb:	83 ec 04             	sub    $0x4,%esp
  800ece:	6a 07                	push   $0x7
  800ed0:	68 00 f0 7f 00       	push   $0x7ff000
  800ed5:	6a 00                	push   $0x0
  800ed7:	e8 b3 fd ff ff       	call   800c8f <sys_page_alloc>
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	79 14                	jns    800ef7 <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800ee3:	83 ec 04             	sub    $0x4,%esp
  800ee6:	68 58 27 80 00       	push   $0x802758
  800eeb:	6a 2f                	push   $0x2f
  800eed:	68 cf 27 80 00       	push   $0x8027cf
  800ef2:	e8 37 f3 ff ff       	call   80022e <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800ef7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800efd:	83 ec 04             	sub    $0x4,%esp
  800f00:	68 00 10 00 00       	push   $0x1000
  800f05:	53                   	push   %ebx
  800f06:	68 00 f0 7f 00       	push   $0x7ff000
  800f0b:	e8 0e fb ff ff       	call   800a1e <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f10:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f17:	53                   	push   %ebx
  800f18:	6a 00                	push   $0x0
  800f1a:	68 00 f0 7f 00       	push   $0x7ff000
  800f1f:	6a 00                	push   $0x0
  800f21:	e8 ac fd ff ff       	call   800cd2 <sys_page_map>
  800f26:	83 c4 20             	add    $0x20,%esp
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	79 14                	jns    800f41 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	68 84 27 80 00       	push   $0x802784
  800f35:	6a 34                	push   $0x34
  800f37:	68 cf 27 80 00       	push   $0x8027cf
  800f3c:	e8 ed f2 ff ff       	call   80022e <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f41:	83 ec 08             	sub    $0x8,%esp
  800f44:	68 00 f0 7f 00       	push   $0x7ff000
  800f49:	6a 00                	push   $0x0
  800f4b:	e8 c4 fd ff ff       	call   800d14 <sys_page_unmap>
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	79 14                	jns    800f6b <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	68 ac 27 80 00       	push   $0x8027ac
  800f5f:	6a 37                	push   $0x37
  800f61:	68 cf 27 80 00       	push   $0x8027cf
  800f66:	e8 c3 f2 ff ff       	call   80022e <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800f6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
  800f76:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800f79:	68 80 0e 80 00       	push   $0x800e80
  800f7e:	e8 8f 0e 00 00       	call   801e12 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f83:	b8 07 00 00 00       	mov    $0x7,%eax
  800f88:	cd 30                	int    $0x30
  800f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	79 15                	jns    800fa9 <fork+0x39>
		panic("sys_exofork: %e", envid);
  800f94:	50                   	push   %eax
  800f95:	68 da 27 80 00       	push   $0x8027da
  800f9a:	68 87 00 00 00       	push   $0x87
  800f9f:	68 cf 27 80 00       	push   $0x8027cf
  800fa4:	e8 85 f2 ff ff       	call   80022e <_panic>
  800fa9:	89 c7                	mov    %eax,%edi
  800fab:	be 00 00 00 00       	mov    $0x0,%esi
  800fb0:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  800fb5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fb9:	75 21                	jne    800fdc <fork+0x6c>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  800fbb:	e8 91 fc ff ff       	call   800c51 <sys_getenvid>
  800fc0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fcd:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd7:	e9 56 01 00 00       	jmp    801132 <fork+0x1c2>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  800fdc:	89 f0                	mov    %esi,%eax
  800fde:	c1 e8 16             	shr    $0x16,%eax
  800fe1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe8:	a8 01                	test   $0x1,%al
  800fea:	0f 84 a5 00 00 00    	je     801095 <fork+0x125>
  800ff0:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ff7:	a8 05                	test   $0x5,%al
  800ff9:	0f 84 96 00 00 00    	je     801095 <fork+0x125>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)))
  800fff:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801006:	a8 02                	test   $0x2,%al
  801008:	75 0c                	jne    801016 <fork+0xa6>
  80100a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801011:	f6 c4 08             	test   $0x8,%ah
  801014:	74 57                	je     80106d <fork+0xfd>
	{

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm | PTE_COW))) < 0)
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	68 05 08 00 00       	push   $0x805
  80101e:	56                   	push   %esi
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	6a 00                	push   $0x0
  801023:	e8 aa fc ff ff       	call   800cd2 <sys_page_map>
  801028:	83 c4 20             	add    $0x20,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	79 12                	jns    801041 <fork+0xd1>
			panic("fork: sys_page_map: %e", r);
  80102f:	50                   	push   %eax
  801030:	68 ea 27 80 00       	push   $0x8027ea
  801035:	6a 5c                	push   $0x5c
  801037:	68 cf 27 80 00       	push   $0x8027cf
  80103c:	e8 ed f1 ff ff       	call   80022e <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm|PTE_COW))) < 0)
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	68 05 08 00 00       	push   $0x805
  801049:	56                   	push   %esi
  80104a:	6a 00                	push   $0x0
  80104c:	56                   	push   %esi
  80104d:	6a 00                	push   $0x0
  80104f:	e8 7e fc ff ff       	call   800cd2 <sys_page_map>
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	79 3a                	jns    801095 <fork+0x125>
			panic("fork: sys_page_map: %e", r);
  80105b:	50                   	push   %eax
  80105c:	68 ea 27 80 00       	push   $0x8027ea
  801061:	6a 5f                	push   $0x5f
  801063:	68 cf 27 80 00       	push   $0x8027cf
  801068:	e8 c1 f1 ff ff       	call   80022e <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	6a 05                	push   $0x5
  801072:	56                   	push   %esi
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	6a 00                	push   $0x0
  801077:	e8 56 fc ff ff       	call   800cd2 <sys_page_map>
  80107c:	83 c4 20             	add    $0x20,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 12                	jns    801095 <fork+0x125>
			panic("fork: sys_page_map: %e", r);
  801083:	50                   	push   %eax
  801084:	68 ea 27 80 00       	push   $0x8027ea
  801089:	6a 64                	push   $0x64
  80108b:	68 cf 27 80 00       	push   $0x8027cf
  801090:	e8 99 f1 ff ff       	call   80022e <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  801095:	83 c3 01             	add    $0x1,%ebx
  801098:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80109e:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8010a4:	0f 85 32 ff ff ff    	jne    800fdc <fork+0x6c>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	6a 07                	push   $0x7
  8010af:	68 00 f0 bf ee       	push   $0xeebff000
  8010b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b7:	e8 d3 fb ff ff       	call   800c8f <sys_page_alloc>
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	79 15                	jns    8010d8 <fork+0x168>
		panic("sys_page_alloc: %e", r);
  8010c3:	50                   	push   %eax
  8010c4:	68 01 28 80 00       	push   $0x802801
  8010c9:	68 98 00 00 00       	push   $0x98
  8010ce:	68 cf 27 80 00       	push   $0x8027cf
  8010d3:	e8 56 f1 ff ff       	call   80022e <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8010d8:	83 ec 08             	sub    $0x8,%esp
  8010db:	68 8f 1e 80 00       	push   $0x801e8f
  8010e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e3:	e8 f2 fc ff ff       	call   800dda <sys_env_set_pgfault_upcall>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	79 17                	jns    801106 <fork+0x196>
		panic("sys_pgfault_upcall error");
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	68 14 28 80 00       	push   $0x802814
  8010f7:	68 9b 00 00 00       	push   $0x9b
  8010fc:	68 cf 27 80 00       	push   $0x8027cf
  801101:	e8 28 f1 ff ff       	call   80022e <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801106:	83 ec 08             	sub    $0x8,%esp
  801109:	6a 02                	push   $0x2
  80110b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110e:	e8 43 fc ff ff       	call   800d56 <sys_env_set_status>
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	79 15                	jns    80112f <fork+0x1bf>
		panic("sys_env_set_status: %e", r);
  80111a:	50                   	push   %eax
  80111b:	68 2d 28 80 00       	push   $0x80282d
  801120:	68 a1 00 00 00       	push   $0xa1
  801125:	68 cf 27 80 00       	push   $0x8027cf
  80112a:	e8 ff f0 ff ff       	call   80022e <_panic>

	return envid;
  80112f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  801132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <sfork>:

// Challenge!
int
sfork(void)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801140:	68 44 28 80 00       	push   $0x802844
  801145:	68 ac 00 00 00       	push   $0xac
  80114a:	68 cf 27 80 00       	push   $0x8027cf
  80114f:	e8 da f0 ff ff       	call   80022e <_panic>

00801154 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801157:	8b 45 08             	mov    0x8(%ebp),%eax
  80115a:	05 00 00 00 30       	add    $0x30000000,%eax
  80115f:	c1 e8 0c             	shr    $0xc,%eax
}
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
  80116a:	05 00 00 00 30       	add    $0x30000000,%eax
  80116f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801174:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801181:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801186:	89 c2                	mov    %eax,%edx
  801188:	c1 ea 16             	shr    $0x16,%edx
  80118b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801192:	f6 c2 01             	test   $0x1,%dl
  801195:	74 11                	je     8011a8 <fd_alloc+0x2d>
  801197:	89 c2                	mov    %eax,%edx
  801199:	c1 ea 0c             	shr    $0xc,%edx
  80119c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a3:	f6 c2 01             	test   $0x1,%dl
  8011a6:	75 09                	jne    8011b1 <fd_alloc+0x36>
			*fd_store = fd;
  8011a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011af:	eb 17                	jmp    8011c8 <fd_alloc+0x4d>
  8011b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011bb:	75 c9                	jne    801186 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d0:	83 f8 1f             	cmp    $0x1f,%eax
  8011d3:	77 36                	ja     80120b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d5:	c1 e0 0c             	shl    $0xc,%eax
  8011d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	c1 ea 16             	shr    $0x16,%edx
  8011e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e9:	f6 c2 01             	test   $0x1,%dl
  8011ec:	74 24                	je     801212 <fd_lookup+0x48>
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	c1 ea 0c             	shr    $0xc,%edx
  8011f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fa:	f6 c2 01             	test   $0x1,%dl
  8011fd:	74 1a                	je     801219 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801202:	89 02                	mov    %eax,(%edx)
	return 0;
  801204:	b8 00 00 00 00       	mov    $0x0,%eax
  801209:	eb 13                	jmp    80121e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80120b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801210:	eb 0c                	jmp    80121e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801212:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801217:	eb 05                	jmp    80121e <fd_lookup+0x54>
  801219:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801229:	ba d8 28 80 00       	mov    $0x8028d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80122e:	eb 13                	jmp    801243 <dev_lookup+0x23>
  801230:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801233:	39 08                	cmp    %ecx,(%eax)
  801235:	75 0c                	jne    801243 <dev_lookup+0x23>
			*dev = devtab[i];
  801237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80123c:	b8 00 00 00 00       	mov    $0x0,%eax
  801241:	eb 2e                	jmp    801271 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801243:	8b 02                	mov    (%edx),%eax
  801245:	85 c0                	test   %eax,%eax
  801247:	75 e7                	jne    801230 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801249:	a1 04 40 80 00       	mov    0x804004,%eax
  80124e:	8b 40 48             	mov    0x48(%eax),%eax
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	51                   	push   %ecx
  801255:	50                   	push   %eax
  801256:	68 5c 28 80 00       	push   $0x80285c
  80125b:	e8 a7 f0 ff ff       	call   800307 <cprintf>
	*dev = 0;
  801260:	8b 45 0c             	mov    0xc(%ebp),%eax
  801263:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	83 ec 10             	sub    $0x10,%esp
  80127b:	8b 75 08             	mov    0x8(%ebp),%esi
  80127e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801281:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80128b:	c1 e8 0c             	shr    $0xc,%eax
  80128e:	50                   	push   %eax
  80128f:	e8 36 ff ff ff       	call   8011ca <fd_lookup>
  801294:	83 c4 08             	add    $0x8,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 05                	js     8012a0 <fd_close+0x2d>
	    || fd != fd2)
  80129b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80129e:	74 0c                	je     8012ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8012a0:	84 db                	test   %bl,%bl
  8012a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a7:	0f 44 c2             	cmove  %edx,%eax
  8012aa:	eb 41                	jmp    8012ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ac:	83 ec 08             	sub    $0x8,%esp
  8012af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b2:	50                   	push   %eax
  8012b3:	ff 36                	pushl  (%esi)
  8012b5:	e8 66 ff ff ff       	call   801220 <dev_lookup>
  8012ba:	89 c3                	mov    %eax,%ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 1a                	js     8012dd <fd_close+0x6a>
		if (dev->dev_close)
  8012c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	74 0b                	je     8012dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012d2:	83 ec 0c             	sub    $0xc,%esp
  8012d5:	56                   	push   %esi
  8012d6:	ff d0                	call   *%eax
  8012d8:	89 c3                	mov    %eax,%ebx
  8012da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	56                   	push   %esi
  8012e1:	6a 00                	push   $0x0
  8012e3:	e8 2c fa ff ff       	call   800d14 <sys_page_unmap>
	return r;
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	89 d8                	mov    %ebx,%eax
}
  8012ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    

008012f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fd:	50                   	push   %eax
  8012fe:	ff 75 08             	pushl  0x8(%ebp)
  801301:	e8 c4 fe ff ff       	call   8011ca <fd_lookup>
  801306:	83 c4 08             	add    $0x8,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 10                	js     80131d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	6a 01                	push   $0x1
  801312:	ff 75 f4             	pushl  -0xc(%ebp)
  801315:	e8 59 ff ff ff       	call   801273 <fd_close>
  80131a:	83 c4 10             	add    $0x10,%esp
}
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <close_all>:

void
close_all(void)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	53                   	push   %ebx
  801323:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801326:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80132b:	83 ec 0c             	sub    $0xc,%esp
  80132e:	53                   	push   %ebx
  80132f:	e8 c0 ff ff ff       	call   8012f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801334:	83 c3 01             	add    $0x1,%ebx
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	83 fb 20             	cmp    $0x20,%ebx
  80133d:	75 ec                	jne    80132b <close_all+0xc>
		close(i);
}
  80133f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	57                   	push   %edi
  801348:	56                   	push   %esi
  801349:	53                   	push   %ebx
  80134a:	83 ec 2c             	sub    $0x2c,%esp
  80134d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801350:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	ff 75 08             	pushl  0x8(%ebp)
  801357:	e8 6e fe ff ff       	call   8011ca <fd_lookup>
  80135c:	83 c4 08             	add    $0x8,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	0f 88 c1 00 00 00    	js     801428 <dup+0xe4>
		return r;
	close(newfdnum);
  801367:	83 ec 0c             	sub    $0xc,%esp
  80136a:	56                   	push   %esi
  80136b:	e8 84 ff ff ff       	call   8012f4 <close>

	newfd = INDEX2FD(newfdnum);
  801370:	89 f3                	mov    %esi,%ebx
  801372:	c1 e3 0c             	shl    $0xc,%ebx
  801375:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80137b:	83 c4 04             	add    $0x4,%esp
  80137e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801381:	e8 de fd ff ff       	call   801164 <fd2data>
  801386:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801388:	89 1c 24             	mov    %ebx,(%esp)
  80138b:	e8 d4 fd ff ff       	call   801164 <fd2data>
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801396:	89 f8                	mov    %edi,%eax
  801398:	c1 e8 16             	shr    $0x16,%eax
  80139b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a2:	a8 01                	test   $0x1,%al
  8013a4:	74 37                	je     8013dd <dup+0x99>
  8013a6:	89 f8                	mov    %edi,%eax
  8013a8:	c1 e8 0c             	shr    $0xc,%eax
  8013ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b2:	f6 c2 01             	test   $0x1,%dl
  8013b5:	74 26                	je     8013dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013be:	83 ec 0c             	sub    $0xc,%esp
  8013c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c6:	50                   	push   %eax
  8013c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ca:	6a 00                	push   $0x0
  8013cc:	57                   	push   %edi
  8013cd:	6a 00                	push   $0x0
  8013cf:	e8 fe f8 ff ff       	call   800cd2 <sys_page_map>
  8013d4:	89 c7                	mov    %eax,%edi
  8013d6:	83 c4 20             	add    $0x20,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 2e                	js     80140b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013e0:	89 d0                	mov    %edx,%eax
  8013e2:	c1 e8 0c             	shr    $0xc,%eax
  8013e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ec:	83 ec 0c             	sub    $0xc,%esp
  8013ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f4:	50                   	push   %eax
  8013f5:	53                   	push   %ebx
  8013f6:	6a 00                	push   $0x0
  8013f8:	52                   	push   %edx
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 d2 f8 ff ff       	call   800cd2 <sys_page_map>
  801400:	89 c7                	mov    %eax,%edi
  801402:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801405:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801407:	85 ff                	test   %edi,%edi
  801409:	79 1d                	jns    801428 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	53                   	push   %ebx
  80140f:	6a 00                	push   $0x0
  801411:	e8 fe f8 ff ff       	call   800d14 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801416:	83 c4 08             	add    $0x8,%esp
  801419:	ff 75 d4             	pushl  -0x2c(%ebp)
  80141c:	6a 00                	push   $0x0
  80141e:	e8 f1 f8 ff ff       	call   800d14 <sys_page_unmap>
	return r;
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	89 f8                	mov    %edi,%eax
}
  801428:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5f                   	pop    %edi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	53                   	push   %ebx
  801434:	83 ec 14             	sub    $0x14,%esp
  801437:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	53                   	push   %ebx
  80143f:	e8 86 fd ff ff       	call   8011ca <fd_lookup>
  801444:	83 c4 08             	add    $0x8,%esp
  801447:	89 c2                	mov    %eax,%edx
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 6d                	js     8014ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801453:	50                   	push   %eax
  801454:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801457:	ff 30                	pushl  (%eax)
  801459:	e8 c2 fd ff ff       	call   801220 <dev_lookup>
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	85 c0                	test   %eax,%eax
  801463:	78 4c                	js     8014b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801465:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801468:	8b 42 08             	mov    0x8(%edx),%eax
  80146b:	83 e0 03             	and    $0x3,%eax
  80146e:	83 f8 01             	cmp    $0x1,%eax
  801471:	75 21                	jne    801494 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801473:	a1 04 40 80 00       	mov    0x804004,%eax
  801478:	8b 40 48             	mov    0x48(%eax),%eax
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	53                   	push   %ebx
  80147f:	50                   	push   %eax
  801480:	68 9d 28 80 00       	push   $0x80289d
  801485:	e8 7d ee ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801492:	eb 26                	jmp    8014ba <read+0x8a>
	}
	if (!dev->dev_read)
  801494:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801497:	8b 40 08             	mov    0x8(%eax),%eax
  80149a:	85 c0                	test   %eax,%eax
  80149c:	74 17                	je     8014b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	ff 75 10             	pushl  0x10(%ebp)
  8014a4:	ff 75 0c             	pushl  0xc(%ebp)
  8014a7:	52                   	push   %edx
  8014a8:	ff d0                	call   *%eax
  8014aa:	89 c2                	mov    %eax,%edx
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	eb 09                	jmp    8014ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	eb 05                	jmp    8014ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014ba:	89 d0                	mov    %edx,%eax
  8014bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	57                   	push   %edi
  8014c5:	56                   	push   %esi
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d5:	eb 21                	jmp    8014f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	89 f0                	mov    %esi,%eax
  8014dc:	29 d8                	sub    %ebx,%eax
  8014de:	50                   	push   %eax
  8014df:	89 d8                	mov    %ebx,%eax
  8014e1:	03 45 0c             	add    0xc(%ebp),%eax
  8014e4:	50                   	push   %eax
  8014e5:	57                   	push   %edi
  8014e6:	e8 45 ff ff ff       	call   801430 <read>
		if (m < 0)
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 10                	js     801502 <readn+0x41>
			return m;
		if (m == 0)
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	74 0a                	je     801500 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f6:	01 c3                	add    %eax,%ebx
  8014f8:	39 f3                	cmp    %esi,%ebx
  8014fa:	72 db                	jb     8014d7 <readn+0x16>
  8014fc:	89 d8                	mov    %ebx,%eax
  8014fe:	eb 02                	jmp    801502 <readn+0x41>
  801500:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801502:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5f                   	pop    %edi
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	53                   	push   %ebx
  80150e:	83 ec 14             	sub    $0x14,%esp
  801511:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801514:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	53                   	push   %ebx
  801519:	e8 ac fc ff ff       	call   8011ca <fd_lookup>
  80151e:	83 c4 08             	add    $0x8,%esp
  801521:	89 c2                	mov    %eax,%edx
  801523:	85 c0                	test   %eax,%eax
  801525:	78 68                	js     80158f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801527:	83 ec 08             	sub    $0x8,%esp
  80152a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152d:	50                   	push   %eax
  80152e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801531:	ff 30                	pushl  (%eax)
  801533:	e8 e8 fc ff ff       	call   801220 <dev_lookup>
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 47                	js     801586 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80153f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801542:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801546:	75 21                	jne    801569 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801548:	a1 04 40 80 00       	mov    0x804004,%eax
  80154d:	8b 40 48             	mov    0x48(%eax),%eax
  801550:	83 ec 04             	sub    $0x4,%esp
  801553:	53                   	push   %ebx
  801554:	50                   	push   %eax
  801555:	68 b9 28 80 00       	push   $0x8028b9
  80155a:	e8 a8 ed ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801567:	eb 26                	jmp    80158f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801569:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156c:	8b 52 0c             	mov    0xc(%edx),%edx
  80156f:	85 d2                	test   %edx,%edx
  801571:	74 17                	je     80158a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	ff 75 10             	pushl  0x10(%ebp)
  801579:	ff 75 0c             	pushl  0xc(%ebp)
  80157c:	50                   	push   %eax
  80157d:	ff d2                	call   *%edx
  80157f:	89 c2                	mov    %eax,%edx
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	eb 09                	jmp    80158f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801586:	89 c2                	mov    %eax,%edx
  801588:	eb 05                	jmp    80158f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80158a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80158f:	89 d0                	mov    %edx,%eax
  801591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <seek>:

int
seek(int fdnum, off_t offset)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	ff 75 08             	pushl  0x8(%ebp)
  8015a3:	e8 22 fc ff ff       	call   8011ca <fd_lookup>
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 0e                	js     8015bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 14             	sub    $0x14,%esp
  8015c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	53                   	push   %ebx
  8015ce:	e8 f7 fb ff ff       	call   8011ca <fd_lookup>
  8015d3:	83 c4 08             	add    $0x8,%esp
  8015d6:	89 c2                	mov    %eax,%edx
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 65                	js     801641 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e6:	ff 30                	pushl  (%eax)
  8015e8:	e8 33 fc ff ff       	call   801220 <dev_lookup>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 44                	js     801638 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015fb:	75 21                	jne    80161e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801602:	8b 40 48             	mov    0x48(%eax),%eax
  801605:	83 ec 04             	sub    $0x4,%esp
  801608:	53                   	push   %ebx
  801609:	50                   	push   %eax
  80160a:	68 7c 28 80 00       	push   $0x80287c
  80160f:	e8 f3 ec ff ff       	call   800307 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80161c:	eb 23                	jmp    801641 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80161e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801621:	8b 52 18             	mov    0x18(%edx),%edx
  801624:	85 d2                	test   %edx,%edx
  801626:	74 14                	je     80163c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	50                   	push   %eax
  80162f:	ff d2                	call   *%edx
  801631:	89 c2                	mov    %eax,%edx
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 09                	jmp    801641 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801638:	89 c2                	mov    %eax,%edx
  80163a:	eb 05                	jmp    801641 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80163c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801641:	89 d0                	mov    %edx,%eax
  801643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	53                   	push   %ebx
  80164c:	83 ec 14             	sub    $0x14,%esp
  80164f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801652:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	ff 75 08             	pushl  0x8(%ebp)
  801659:	e8 6c fb ff ff       	call   8011ca <fd_lookup>
  80165e:	83 c4 08             	add    $0x8,%esp
  801661:	89 c2                	mov    %eax,%edx
  801663:	85 c0                	test   %eax,%eax
  801665:	78 58                	js     8016bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166d:	50                   	push   %eax
  80166e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801671:	ff 30                	pushl  (%eax)
  801673:	e8 a8 fb ff ff       	call   801220 <dev_lookup>
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	85 c0                	test   %eax,%eax
  80167d:	78 37                	js     8016b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80167f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801682:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801686:	74 32                	je     8016ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801688:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80168b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801692:	00 00 00 
	stat->st_isdir = 0;
  801695:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80169c:	00 00 00 
	stat->st_dev = dev;
  80169f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	53                   	push   %ebx
  8016a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ac:	ff 50 14             	call   *0x14(%eax)
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	eb 09                	jmp    8016bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	eb 05                	jmp    8016bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016bf:	89 d0                	mov    %edx,%eax
  8016c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016cb:	83 ec 08             	sub    $0x8,%esp
  8016ce:	6a 00                	push   $0x0
  8016d0:	ff 75 08             	pushl  0x8(%ebp)
  8016d3:	e8 b7 01 00 00       	call   80188f <open>
  8016d8:	89 c3                	mov    %eax,%ebx
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 1b                	js     8016fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e1:	83 ec 08             	sub    $0x8,%esp
  8016e4:	ff 75 0c             	pushl  0xc(%ebp)
  8016e7:	50                   	push   %eax
  8016e8:	e8 5b ff ff ff       	call   801648 <fstat>
  8016ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ef:	89 1c 24             	mov    %ebx,(%esp)
  8016f2:	e8 fd fb ff ff       	call   8012f4 <close>
	return r;
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	89 f0                	mov    %esi,%eax
}
  8016fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	89 c6                	mov    %eax,%esi
  80170a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80170c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801713:	75 12                	jne    801727 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801715:	83 ec 0c             	sub    $0xc,%esp
  801718:	6a 01                	push   $0x1
  80171a:	e8 96 08 00 00       	call   801fb5 <ipc_find_env>
  80171f:	a3 00 40 80 00       	mov    %eax,0x804000
  801724:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801727:	6a 07                	push   $0x7
  801729:	68 00 50 80 00       	push   $0x805000
  80172e:	56                   	push   %esi
  80172f:	ff 35 00 40 80 00    	pushl  0x804000
  801735:	e8 ef 07 00 00       	call   801f29 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80173a:	83 c4 0c             	add    $0xc,%esp
  80173d:	6a 00                	push   $0x0
  80173f:	53                   	push   %ebx
  801740:	6a 00                	push   $0x0
  801742:	e8 6d 07 00 00       	call   801eb4 <ipc_recv>
}
  801747:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174a:	5b                   	pop    %ebx
  80174b:	5e                   	pop    %esi
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
  801757:	8b 40 0c             	mov    0xc(%eax),%eax
  80175a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80175f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801762:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801767:	ba 00 00 00 00       	mov    $0x0,%edx
  80176c:	b8 02 00 00 00       	mov    $0x2,%eax
  801771:	e8 8d ff ff ff       	call   801703 <fsipc>
}
  801776:	c9                   	leave  
  801777:	c3                   	ret    

00801778 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80177e:	8b 45 08             	mov    0x8(%ebp),%eax
  801781:	8b 40 0c             	mov    0xc(%eax),%eax
  801784:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801789:	ba 00 00 00 00       	mov    $0x0,%edx
  80178e:	b8 06 00 00 00       	mov    $0x6,%eax
  801793:	e8 6b ff ff ff       	call   801703 <fsipc>
}
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	83 ec 04             	sub    $0x4,%esp
  8017a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017af:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8017b9:	e8 45 ff ff ff       	call   801703 <fsipc>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 2c                	js     8017ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c2:	83 ec 08             	sub    $0x8,%esp
  8017c5:	68 00 50 80 00       	push   $0x805000
  8017ca:	53                   	push   %ebx
  8017cb:	e8 bc f0 ff ff       	call   80088c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017db:	a1 84 50 80 00       	mov    0x805084,%eax
  8017e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8017f9:	68 e8 28 80 00       	push   $0x8028e8
  8017fe:	68 90 00 00 00       	push   $0x90
  801803:	68 06 29 80 00       	push   $0x802906
  801808:	e8 21 ea ff ff       	call   80022e <_panic>

0080180d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
  801812:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
  801818:	8b 40 0c             	mov    0xc(%eax),%eax
  80181b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801820:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801826:	ba 00 00 00 00       	mov    $0x0,%edx
  80182b:	b8 03 00 00 00       	mov    $0x3,%eax
  801830:	e8 ce fe ff ff       	call   801703 <fsipc>
  801835:	89 c3                	mov    %eax,%ebx
  801837:	85 c0                	test   %eax,%eax
  801839:	78 4b                	js     801886 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80183b:	39 c6                	cmp    %eax,%esi
  80183d:	73 16                	jae    801855 <devfile_read+0x48>
  80183f:	68 11 29 80 00       	push   $0x802911
  801844:	68 18 29 80 00       	push   $0x802918
  801849:	6a 7c                	push   $0x7c
  80184b:	68 06 29 80 00       	push   $0x802906
  801850:	e8 d9 e9 ff ff       	call   80022e <_panic>
	assert(r <= PGSIZE);
  801855:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80185a:	7e 16                	jle    801872 <devfile_read+0x65>
  80185c:	68 2d 29 80 00       	push   $0x80292d
  801861:	68 18 29 80 00       	push   $0x802918
  801866:	6a 7d                	push   $0x7d
  801868:	68 06 29 80 00       	push   $0x802906
  80186d:	e8 bc e9 ff ff       	call   80022e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801872:	83 ec 04             	sub    $0x4,%esp
  801875:	50                   	push   %eax
  801876:	68 00 50 80 00       	push   $0x805000
  80187b:	ff 75 0c             	pushl  0xc(%ebp)
  80187e:	e8 9b f1 ff ff       	call   800a1e <memmove>
	return r;
  801883:	83 c4 10             	add    $0x10,%esp
}
  801886:	89 d8                	mov    %ebx,%eax
  801888:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5e                   	pop    %esi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	53                   	push   %ebx
  801893:	83 ec 20             	sub    $0x20,%esp
  801896:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801899:	53                   	push   %ebx
  80189a:	e8 b4 ef ff ff       	call   800853 <strlen>
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018a7:	7f 67                	jg     801910 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	e8 c6 f8 ff ff       	call   80117b <fd_alloc>
  8018b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8018b8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 57                	js     801915 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	53                   	push   %ebx
  8018c2:	68 00 50 80 00       	push   $0x805000
  8018c7:	e8 c0 ef ff ff       	call   80088c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018dc:	e8 22 fe ff ff       	call   801703 <fsipc>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	79 14                	jns    8018fe <open+0x6f>
		fd_close(fd, 0);
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	6a 00                	push   $0x0
  8018ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f2:	e8 7c f9 ff ff       	call   801273 <fd_close>
		return r;
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	89 da                	mov    %ebx,%edx
  8018fc:	eb 17                	jmp    801915 <open+0x86>
	}

	return fd2num(fd);
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	ff 75 f4             	pushl  -0xc(%ebp)
  801904:	e8 4b f8 ff ff       	call   801154 <fd2num>
  801909:	89 c2                	mov    %eax,%edx
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	eb 05                	jmp    801915 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801910:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801915:	89 d0                	mov    %edx,%eax
  801917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801922:	ba 00 00 00 00       	mov    $0x0,%edx
  801927:	b8 08 00 00 00       	mov    $0x8,%eax
  80192c:	e8 d2 fd ff ff       	call   801703 <fsipc>
}
  801931:	c9                   	leave  
  801932:	c3                   	ret    

00801933 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	56                   	push   %esi
  801937:	53                   	push   %ebx
  801938:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80193b:	83 ec 0c             	sub    $0xc,%esp
  80193e:	ff 75 08             	pushl  0x8(%ebp)
  801941:	e8 1e f8 ff ff       	call   801164 <fd2data>
  801946:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801948:	83 c4 08             	add    $0x8,%esp
  80194b:	68 39 29 80 00       	push   $0x802939
  801950:	53                   	push   %ebx
  801951:	e8 36 ef ff ff       	call   80088c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801956:	8b 46 04             	mov    0x4(%esi),%eax
  801959:	2b 06                	sub    (%esi),%eax
  80195b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801961:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801968:	00 00 00 
	stat->st_dev = &devpipe;
  80196b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801972:	30 80 00 
	return 0;
}
  801975:	b8 00 00 00 00       	mov    $0x0,%eax
  80197a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	53                   	push   %ebx
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80198b:	53                   	push   %ebx
  80198c:	6a 00                	push   $0x0
  80198e:	e8 81 f3 ff ff       	call   800d14 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801993:	89 1c 24             	mov    %ebx,(%esp)
  801996:	e8 c9 f7 ff ff       	call   801164 <fd2data>
  80199b:	83 c4 08             	add    $0x8,%esp
  80199e:	50                   	push   %eax
  80199f:	6a 00                	push   $0x0
  8019a1:	e8 6e f3 ff ff       	call   800d14 <sys_page_unmap>
}
  8019a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	57                   	push   %edi
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 1c             	sub    $0x1c,%esp
  8019b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019b7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8019be:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019c1:	83 ec 0c             	sub    $0xc,%esp
  8019c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8019c7:	e8 22 06 00 00       	call   801fee <pageref>
  8019cc:	89 c3                	mov    %eax,%ebx
  8019ce:	89 3c 24             	mov    %edi,(%esp)
  8019d1:	e8 18 06 00 00       	call   801fee <pageref>
  8019d6:	83 c4 10             	add    $0x10,%esp
  8019d9:	39 c3                	cmp    %eax,%ebx
  8019db:	0f 94 c1             	sete   %cl
  8019de:	0f b6 c9             	movzbl %cl,%ecx
  8019e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019e4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019ea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019ed:	39 ce                	cmp    %ecx,%esi
  8019ef:	74 1b                	je     801a0c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019f1:	39 c3                	cmp    %eax,%ebx
  8019f3:	75 c4                	jne    8019b9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019f5:	8b 42 58             	mov    0x58(%edx),%eax
  8019f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019fb:	50                   	push   %eax
  8019fc:	56                   	push   %esi
  8019fd:	68 40 29 80 00       	push   $0x802940
  801a02:	e8 00 e9 ff ff       	call   800307 <cprintf>
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	eb ad                	jmp    8019b9 <_pipeisclosed+0xe>
	}
}
  801a0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a12:	5b                   	pop    %ebx
  801a13:	5e                   	pop    %esi
  801a14:	5f                   	pop    %edi
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    

00801a17 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	57                   	push   %edi
  801a1b:	56                   	push   %esi
  801a1c:	53                   	push   %ebx
  801a1d:	83 ec 28             	sub    $0x28,%esp
  801a20:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a23:	56                   	push   %esi
  801a24:	e8 3b f7 ff ff       	call   801164 <fd2data>
  801a29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	bf 00 00 00 00       	mov    $0x0,%edi
  801a33:	eb 4b                	jmp    801a80 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a35:	89 da                	mov    %ebx,%edx
  801a37:	89 f0                	mov    %esi,%eax
  801a39:	e8 6d ff ff ff       	call   8019ab <_pipeisclosed>
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	75 48                	jne    801a8a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a42:	e8 29 f2 ff ff       	call   800c70 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a47:	8b 43 04             	mov    0x4(%ebx),%eax
  801a4a:	8b 0b                	mov    (%ebx),%ecx
  801a4c:	8d 51 20             	lea    0x20(%ecx),%edx
  801a4f:	39 d0                	cmp    %edx,%eax
  801a51:	73 e2                	jae    801a35 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a56:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a5a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a5d:	89 c2                	mov    %eax,%edx
  801a5f:	c1 fa 1f             	sar    $0x1f,%edx
  801a62:	89 d1                	mov    %edx,%ecx
  801a64:	c1 e9 1b             	shr    $0x1b,%ecx
  801a67:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a6a:	83 e2 1f             	and    $0x1f,%edx
  801a6d:	29 ca                	sub    %ecx,%edx
  801a6f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a73:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a77:	83 c0 01             	add    $0x1,%eax
  801a7a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7d:	83 c7 01             	add    $0x1,%edi
  801a80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a83:	75 c2                	jne    801a47 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a85:	8b 45 10             	mov    0x10(%ebp),%eax
  801a88:	eb 05                	jmp    801a8f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5f                   	pop    %edi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	57                   	push   %edi
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 18             	sub    $0x18,%esp
  801aa0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aa3:	57                   	push   %edi
  801aa4:	e8 bb f6 ff ff       	call   801164 <fd2data>
  801aa9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ab3:	eb 3d                	jmp    801af2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ab5:	85 db                	test   %ebx,%ebx
  801ab7:	74 04                	je     801abd <devpipe_read+0x26>
				return i;
  801ab9:	89 d8                	mov    %ebx,%eax
  801abb:	eb 44                	jmp    801b01 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801abd:	89 f2                	mov    %esi,%edx
  801abf:	89 f8                	mov    %edi,%eax
  801ac1:	e8 e5 fe ff ff       	call   8019ab <_pipeisclosed>
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	75 32                	jne    801afc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aca:	e8 a1 f1 ff ff       	call   800c70 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801acf:	8b 06                	mov    (%esi),%eax
  801ad1:	3b 46 04             	cmp    0x4(%esi),%eax
  801ad4:	74 df                	je     801ab5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ad6:	99                   	cltd   
  801ad7:	c1 ea 1b             	shr    $0x1b,%edx
  801ada:	01 d0                	add    %edx,%eax
  801adc:	83 e0 1f             	and    $0x1f,%eax
  801adf:	29 d0                	sub    %edx,%eax
  801ae1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801aec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aef:	83 c3 01             	add    $0x1,%ebx
  801af2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801af5:	75 d8                	jne    801acf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801af7:	8b 45 10             	mov    0x10(%ebp),%eax
  801afa:	eb 05                	jmp    801b01 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5e                   	pop    %esi
  801b06:	5f                   	pop    %edi
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    

00801b09 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b14:	50                   	push   %eax
  801b15:	e8 61 f6 ff ff       	call   80117b <fd_alloc>
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	89 c2                	mov    %eax,%edx
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	0f 88 2c 01 00 00    	js     801c53 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b27:	83 ec 04             	sub    $0x4,%esp
  801b2a:	68 07 04 00 00       	push   $0x407
  801b2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b32:	6a 00                	push   $0x0
  801b34:	e8 56 f1 ff ff       	call   800c8f <sys_page_alloc>
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	89 c2                	mov    %eax,%edx
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	0f 88 0d 01 00 00    	js     801c53 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b4c:	50                   	push   %eax
  801b4d:	e8 29 f6 ff ff       	call   80117b <fd_alloc>
  801b52:	89 c3                	mov    %eax,%ebx
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	0f 88 e2 00 00 00    	js     801c41 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5f:	83 ec 04             	sub    $0x4,%esp
  801b62:	68 07 04 00 00       	push   $0x407
  801b67:	ff 75 f0             	pushl  -0x10(%ebp)
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 1e f1 ff ff       	call   800c8f <sys_page_alloc>
  801b71:	89 c3                	mov    %eax,%ebx
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	85 c0                	test   %eax,%eax
  801b78:	0f 88 c3 00 00 00    	js     801c41 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	ff 75 f4             	pushl  -0xc(%ebp)
  801b84:	e8 db f5 ff ff       	call   801164 <fd2data>
  801b89:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8b:	83 c4 0c             	add    $0xc,%esp
  801b8e:	68 07 04 00 00       	push   $0x407
  801b93:	50                   	push   %eax
  801b94:	6a 00                	push   $0x0
  801b96:	e8 f4 f0 ff ff       	call   800c8f <sys_page_alloc>
  801b9b:	89 c3                	mov    %eax,%ebx
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	0f 88 89 00 00 00    	js     801c31 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba8:	83 ec 0c             	sub    $0xc,%esp
  801bab:	ff 75 f0             	pushl  -0x10(%ebp)
  801bae:	e8 b1 f5 ff ff       	call   801164 <fd2data>
  801bb3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bba:	50                   	push   %eax
  801bbb:	6a 00                	push   $0x0
  801bbd:	56                   	push   %esi
  801bbe:	6a 00                	push   $0x0
  801bc0:	e8 0d f1 ff ff       	call   800cd2 <sys_page_map>
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	83 c4 20             	add    $0x20,%esp
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	78 55                	js     801c23 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bce:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801be3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bf8:	83 ec 0c             	sub    $0xc,%esp
  801bfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfe:	e8 51 f5 ff ff       	call   801154 <fd2num>
  801c03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c06:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c08:	83 c4 04             	add    $0x4,%esp
  801c0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c0e:	e8 41 f5 ff ff       	call   801154 <fd2num>
  801c13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c16:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c21:	eb 30                	jmp    801c53 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c23:	83 ec 08             	sub    $0x8,%esp
  801c26:	56                   	push   %esi
  801c27:	6a 00                	push   $0x0
  801c29:	e8 e6 f0 ff ff       	call   800d14 <sys_page_unmap>
  801c2e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c31:	83 ec 08             	sub    $0x8,%esp
  801c34:	ff 75 f0             	pushl  -0x10(%ebp)
  801c37:	6a 00                	push   $0x0
  801c39:	e8 d6 f0 ff ff       	call   800d14 <sys_page_unmap>
  801c3e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c41:	83 ec 08             	sub    $0x8,%esp
  801c44:	ff 75 f4             	pushl  -0xc(%ebp)
  801c47:	6a 00                	push   $0x0
  801c49:	e8 c6 f0 ff ff       	call   800d14 <sys_page_unmap>
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c53:	89 d0                	mov    %edx,%eax
  801c55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c58:	5b                   	pop    %ebx
  801c59:	5e                   	pop    %esi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c65:	50                   	push   %eax
  801c66:	ff 75 08             	pushl  0x8(%ebp)
  801c69:	e8 5c f5 ff ff       	call   8011ca <fd_lookup>
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 18                	js     801c8d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c75:	83 ec 0c             	sub    $0xc,%esp
  801c78:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7b:	e8 e4 f4 ff ff       	call   801164 <fd2data>
	return _pipeisclosed(fd, p);
  801c80:	89 c2                	mov    %eax,%edx
  801c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c85:	e8 21 fd ff ff       	call   8019ab <_pipeisclosed>
  801c8a:	83 c4 10             	add    $0x10,%esp
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c92:	b8 00 00 00 00       	mov    $0x0,%eax
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    

00801c99 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c9f:	68 58 29 80 00       	push   $0x802958
  801ca4:	ff 75 0c             	pushl  0xc(%ebp)
  801ca7:	e8 e0 eb ff ff       	call   80088c <strcpy>
	return 0;
}
  801cac:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	57                   	push   %edi
  801cb7:	56                   	push   %esi
  801cb8:	53                   	push   %ebx
  801cb9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cbf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cc4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cca:	eb 2d                	jmp    801cf9 <devcons_write+0x46>
		m = n - tot;
  801ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ccf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cd1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cd4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cd9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cdc:	83 ec 04             	sub    $0x4,%esp
  801cdf:	53                   	push   %ebx
  801ce0:	03 45 0c             	add    0xc(%ebp),%eax
  801ce3:	50                   	push   %eax
  801ce4:	57                   	push   %edi
  801ce5:	e8 34 ed ff ff       	call   800a1e <memmove>
		sys_cputs(buf, m);
  801cea:	83 c4 08             	add    $0x8,%esp
  801ced:	53                   	push   %ebx
  801cee:	57                   	push   %edi
  801cef:	e8 df ee ff ff       	call   800bd3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf4:	01 de                	add    %ebx,%esi
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	89 f0                	mov    %esi,%eax
  801cfb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cfe:	72 cc                	jb     801ccc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	83 ec 08             	sub    $0x8,%esp
  801d0e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d17:	74 2a                	je     801d43 <devcons_read+0x3b>
  801d19:	eb 05                	jmp    801d20 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d1b:	e8 50 ef ff ff       	call   800c70 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d20:	e8 cc ee ff ff       	call   800bf1 <sys_cgetc>
  801d25:	85 c0                	test   %eax,%eax
  801d27:	74 f2                	je     801d1b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	78 16                	js     801d43 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d2d:	83 f8 04             	cmp    $0x4,%eax
  801d30:	74 0c                	je     801d3e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d35:	88 02                	mov    %al,(%edx)
	return 1;
  801d37:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3c:	eb 05                	jmp    801d43 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d3e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d51:	6a 01                	push   $0x1
  801d53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d56:	50                   	push   %eax
  801d57:	e8 77 ee ff ff       	call   800bd3 <sys_cputs>
}
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	c9                   	leave  
  801d60:	c3                   	ret    

00801d61 <getchar>:

int
getchar(void)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d67:	6a 01                	push   $0x1
  801d69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d6c:	50                   	push   %eax
  801d6d:	6a 00                	push   $0x0
  801d6f:	e8 bc f6 ff ff       	call   801430 <read>
	if (r < 0)
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	78 0f                	js     801d8a <getchar+0x29>
		return r;
	if (r < 1)
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	7e 06                	jle    801d85 <getchar+0x24>
		return -E_EOF;
	return c;
  801d7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d83:	eb 05                	jmp    801d8a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d95:	50                   	push   %eax
  801d96:	ff 75 08             	pushl  0x8(%ebp)
  801d99:	e8 2c f4 ff ff       	call   8011ca <fd_lookup>
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 11                	js     801db6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dae:	39 10                	cmp    %edx,(%eax)
  801db0:	0f 94 c0             	sete   %al
  801db3:	0f b6 c0             	movzbl %al,%eax
}
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <opencons>:

int
opencons(void)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc1:	50                   	push   %eax
  801dc2:	e8 b4 f3 ff ff       	call   80117b <fd_alloc>
  801dc7:	83 c4 10             	add    $0x10,%esp
		return r;
  801dca:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dcc:	85 c0                	test   %eax,%eax
  801dce:	78 3e                	js     801e0e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dd0:	83 ec 04             	sub    $0x4,%esp
  801dd3:	68 07 04 00 00       	push   $0x407
  801dd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddb:	6a 00                	push   $0x0
  801ddd:	e8 ad ee ff ff       	call   800c8f <sys_page_alloc>
  801de2:	83 c4 10             	add    $0x10,%esp
		return r;
  801de5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de7:	85 c0                	test   %eax,%eax
  801de9:	78 23                	js     801e0e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801deb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e00:	83 ec 0c             	sub    $0xc,%esp
  801e03:	50                   	push   %eax
  801e04:	e8 4b f3 ff ff       	call   801154 <fd2num>
  801e09:	89 c2                	mov    %eax,%edx
  801e0b:	83 c4 10             	add    $0x10,%esp
}
  801e0e:	89 d0                	mov    %edx,%eax
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e18:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e1f:	75 64                	jne    801e85 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801e21:	a1 04 40 80 00       	mov    0x804004,%eax
  801e26:	8b 40 48             	mov    0x48(%eax),%eax
  801e29:	83 ec 04             	sub    $0x4,%esp
  801e2c:	6a 07                	push   $0x7
  801e2e:	68 00 f0 bf ee       	push   $0xeebff000
  801e33:	50                   	push   %eax
  801e34:	e8 56 ee ff ff       	call   800c8f <sys_page_alloc>
		if ( r != 0)
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	74 14                	je     801e54 <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  801e40:	83 ec 04             	sub    $0x4,%esp
  801e43:	68 64 29 80 00       	push   $0x802964
  801e48:	6a 24                	push   $0x24
  801e4a:	68 b2 29 80 00       	push   $0x8029b2
  801e4f:	e8 da e3 ff ff       	call   80022e <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  801e54:	a1 04 40 80 00       	mov    0x804004,%eax
  801e59:	8b 40 48             	mov    0x48(%eax),%eax
  801e5c:	83 ec 08             	sub    $0x8,%esp
  801e5f:	68 8f 1e 80 00       	push   $0x801e8f
  801e64:	50                   	push   %eax
  801e65:	e8 70 ef ff ff       	call   800dda <sys_env_set_pgfault_upcall>
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	79 14                	jns    801e85 <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  801e71:	83 ec 04             	sub    $0x4,%esp
  801e74:	68 90 29 80 00       	push   $0x802990
  801e79:	6a 27                	push   $0x27
  801e7b:	68 b2 29 80 00       	push   $0x8029b2
  801e80:	e8 a9 e3 ff ff       	call   80022e <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e85:	8b 45 08             	mov    0x8(%ebp),%eax
  801e88:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e8f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e90:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e95:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e97:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  801e9a:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  801e9e:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  801ea0:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  801ea4:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  801ea5:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  801ea8:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  801eaa:	83 c4 08             	add    $0x8,%esp
popal
  801ead:	61                   	popa   
addl $0x4, %esp
  801eae:	83 c4 04             	add    $0x4,%esp
popfl
  801eb1:	9d                   	popf   
popl %esp
  801eb2:	5c                   	pop    %esp
ret
  801eb3:	c3                   	ret    

00801eb4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	56                   	push   %esi
  801eb8:	53                   	push   %ebx
  801eb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebf:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	74 0e                	je     801ed4 <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	50                   	push   %eax
  801eca:	e8 70 ef ff ff       	call   800e3f <sys_ipc_recv>
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	eb 10                	jmp    801ee4 <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  801ed4:	83 ec 0c             	sub    $0xc,%esp
  801ed7:	68 00 00 00 f0       	push   $0xf0000000
  801edc:	e8 5e ef ff ff       	call   800e3f <sys_ipc_recv>
  801ee1:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	74 16                	je     801efe <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  801ee8:	85 db                	test   %ebx,%ebx
  801eea:	74 36                	je     801f22 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  801eec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  801ef2:	85 f6                	test   %esi,%esi
  801ef4:	74 2c                	je     801f22 <ipc_recv+0x6e>
				*perm_store = 0;
  801ef6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801efc:	eb 24                	jmp    801f22 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  801efe:	85 db                	test   %ebx,%ebx
  801f00:	74 18                	je     801f1a <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  801f02:	a1 04 40 80 00       	mov    0x804004,%eax
  801f07:	8b 40 74             	mov    0x74(%eax),%eax
  801f0a:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  801f0c:	85 f6                	test   %esi,%esi
  801f0e:	74 0a                	je     801f1a <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  801f10:	a1 04 40 80 00       	mov    0x804004,%eax
  801f15:	8b 40 78             	mov    0x78(%eax),%eax
  801f18:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  801f1a:	a1 04 40 80 00       	mov    0x804004,%eax
  801f1f:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  801f22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	57                   	push   %edi
  801f2d:	56                   	push   %esi
  801f2e:	53                   	push   %ebx
  801f2f:	83 ec 0c             	sub    $0xc,%esp
  801f32:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f35:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  801f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f3c:	75 39                	jne    801f77 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  801f3e:	6a 00                	push   $0x0
  801f40:	68 00 00 00 f0       	push   $0xf0000000
  801f45:	56                   	push   %esi
  801f46:	57                   	push   %edi
  801f47:	e8 d0 ee ff ff       	call   800e1c <sys_ipc_try_send>
  801f4c:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f54:	74 16                	je     801f6c <ipc_send+0x43>
  801f56:	85 c0                	test   %eax,%eax
  801f58:	74 12                	je     801f6c <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801f5a:	50                   	push   %eax
  801f5b:	68 c0 29 80 00       	push   $0x8029c0
  801f60:	6a 4f                	push   $0x4f
  801f62:	68 f8 29 80 00       	push   $0x8029f8
  801f67:	e8 c2 e2 ff ff       	call   80022e <_panic>
			sys_yield();
  801f6c:	e8 ff ec ff ff       	call   800c70 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  801f71:	85 db                	test   %ebx,%ebx
  801f73:	75 c9                	jne    801f3e <ipc_send+0x15>
  801f75:	eb 36                	jmp    801fad <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  801f77:	ff 75 14             	pushl  0x14(%ebp)
  801f7a:	ff 75 10             	pushl  0x10(%ebp)
  801f7d:	56                   	push   %esi
  801f7e:	57                   	push   %edi
  801f7f:	e8 98 ee ff ff       	call   800e1c <sys_ipc_try_send>
  801f84:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f8c:	74 16                	je     801fa4 <ipc_send+0x7b>
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	74 12                	je     801fa4 <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801f92:	50                   	push   %eax
  801f93:	68 c0 29 80 00       	push   $0x8029c0
  801f98:	6a 5a                	push   $0x5a
  801f9a:	68 f8 29 80 00       	push   $0x8029f8
  801f9f:	e8 8a e2 ff ff       	call   80022e <_panic>
			sys_yield();
  801fa4:	e8 c7 ec ff ff       	call   800c70 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  801fa9:	85 db                	test   %ebx,%ebx
  801fab:	75 ca                	jne    801f77 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  801fad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb0:	5b                   	pop    %ebx
  801fb1:	5e                   	pop    %esi
  801fb2:	5f                   	pop    %edi
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    

00801fb5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fbb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fc0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fc3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fc9:	8b 52 50             	mov    0x50(%edx),%edx
  801fcc:	39 ca                	cmp    %ecx,%edx
  801fce:	75 0d                	jne    801fdd <ipc_find_env+0x28>
			return envs[i].env_id;
  801fd0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fd3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd8:	8b 40 48             	mov    0x48(%eax),%eax
  801fdb:	eb 0f                	jmp    801fec <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fdd:	83 c0 01             	add    $0x1,%eax
  801fe0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fe5:	75 d9                	jne    801fc0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fe7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fec:	5d                   	pop    %ebp
  801fed:	c3                   	ret    

00801fee <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff4:	89 d0                	mov    %edx,%eax
  801ff6:	c1 e8 16             	shr    $0x16,%eax
  801ff9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802000:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802005:	f6 c1 01             	test   $0x1,%cl
  802008:	74 1d                	je     802027 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80200a:	c1 ea 0c             	shr    $0xc,%edx
  80200d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802014:	f6 c2 01             	test   $0x1,%dl
  802017:	74 0e                	je     802027 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802019:	c1 ea 0c             	shr    $0xc,%edx
  80201c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802023:	ef 
  802024:	0f b7 c0             	movzwl %ax,%eax
}
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    
  802029:	66 90                	xchg   %ax,%ax
  80202b:	66 90                	xchg   %ax,%ax
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
