
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
  80003c:	68 c0 27 80 00       	push   $0x8027c0
  800041:	e8 c1 02 00 00       	call   800307 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 bf 1f 00 00       	call   802010 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 0e 28 80 00       	push   $0x80280e
  80005e:	6a 0d                	push   $0xd
  800060:	68 17 28 80 00       	push   $0x802817
  800065:	e8 c4 01 00 00       	call   80022e <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 20 0f 00 00       	call   800f8f <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 e1 2c 80 00       	push   $0x802ce1
  80007b:	6a 0f                	push   $0xf
  80007d:	68 17 28 80 00       	push   $0x802817
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
  800091:	e8 d2 12 00 00       	call   801368 <close>
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
  8000be:	68 2c 28 80 00       	push   $0x80282c
  8000c3:	e8 3f 02 00 00       	call   800307 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 e0 12 00 00       	call   8013b8 <dup>
			sys_yield();
  8000d8:	e8 93 0b 00 00       	call   800c70 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 7f 12 00 00       	call   801368 <close>
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
  80011d:	e8 41 20 00 00       	call   802163 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 30 28 80 00       	push   $0x802830
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
  80015c:	68 4c 28 80 00       	push   $0x80284c
  800161:	e8 a1 01 00 00       	call   800307 <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 f2 1f 00 00       	call   802163 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 e4 27 80 00       	push   $0x8027e4
  800180:	6a 40                	push   $0x40
  800182:	68 17 28 80 00       	push   $0x802817
  800187:	e8 a2 00 00 00       	call   80022e <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 a3 10 00 00       	call   80123e <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 62 28 80 00       	push   $0x802862
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 17 28 80 00       	push   $0x802817
  8001af:	e8 7a 00 00 00       	call   80022e <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 19 10 00 00       	call   8011d8 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 7a 28 80 00 	movl   $0x80287a,(%esp)
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
  8001f3:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80024c:	68 98 28 80 00       	push   $0x802898
  800251:	e8 b1 00 00 00       	call   800307 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	53                   	push   %ebx
  80025a:	ff 75 10             	pushl  0x10(%ebp)
  80025d:	e8 54 00 00 00       	call   8002b6 <vcprintf>
	cprintf("\n");
  800262:	c7 04 24 70 2e 80 00 	movl   $0x802e70,(%esp)
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
  80036a:	e8 c1 21 00 00       	call   802530 <__udivdi3>
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
  8003ad:	e8 ae 22 00 00       	call   802660 <__umoddi3>
  8003b2:	83 c4 14             	add    $0x14,%esp
  8003b5:	0f be 80 bb 28 80 00 	movsbl 0x8028bb(%eax),%eax
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
  8004b1:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
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
  800575:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  80057c:	85 d2                	test   %edx,%edx
  80057e:	75 18                	jne    800598 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800580:	50                   	push   %eax
  800581:	68 d3 28 80 00       	push   $0x8028d3
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
  800599:	68 05 2e 80 00       	push   $0x802e05
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
  8005bd:	b8 cc 28 80 00       	mov    $0x8028cc,%eax
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
  800c38:	68 bf 2b 80 00       	push   $0x802bbf
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 dc 2b 80 00       	push   $0x802bdc
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
  800cb9:	68 bf 2b 80 00       	push   $0x802bbf
  800cbe:	6a 23                	push   $0x23
  800cc0:	68 dc 2b 80 00       	push   $0x802bdc
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
  800cfb:	68 bf 2b 80 00       	push   $0x802bbf
  800d00:	6a 23                	push   $0x23
  800d02:	68 dc 2b 80 00       	push   $0x802bdc
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
  800d3d:	68 bf 2b 80 00       	push   $0x802bbf
  800d42:	6a 23                	push   $0x23
  800d44:	68 dc 2b 80 00       	push   $0x802bdc
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
  800d7f:	68 bf 2b 80 00       	push   $0x802bbf
  800d84:	6a 23                	push   $0x23
  800d86:	68 dc 2b 80 00       	push   $0x802bdc
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
  800dc1:	68 bf 2b 80 00       	push   $0x802bbf
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 dc 2b 80 00       	push   $0x802bdc
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
  800e03:	68 bf 2b 80 00       	push   $0x802bbf
  800e08:	6a 23                	push   $0x23
  800e0a:	68 dc 2b 80 00       	push   $0x802bdc
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
  800e67:	68 bf 2b 80 00       	push   $0x802bbf
  800e6c:	6a 23                	push   $0x23
  800e6e:	68 dc 2b 80 00       	push   $0x802bdc
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

00800e80 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e86:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e90:	89 d1                	mov    %edx,%ecx
  800e92:	89 d3                	mov    %edx,%ebx
  800e94:	89 d7                	mov    %edx,%edi
  800e96:	89 d6                	mov    %edx,%esi
  800e98:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 04             	sub    $0x4,%esp
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  800eab:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eaf:	75 14                	jne    800ec5 <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	68 ec 2b 80 00       	push   $0x802bec
  800eb9:	6a 22                	push   $0x22
  800ebb:	68 cf 2c 80 00       	push   $0x802ccf
  800ec0:	e8 69 f3 ff ff       	call   80022e <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  800ec5:	89 d8                	mov    %ebx,%eax
  800ec7:	c1 e8 0c             	shr    $0xc,%eax
  800eca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed1:	f6 c4 08             	test   $0x8,%ah
  800ed4:	75 14                	jne    800eea <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	68 28 2c 80 00       	push   $0x802c28
  800ede:	6a 27                	push   $0x27
  800ee0:	68 cf 2c 80 00       	push   $0x802ccf
  800ee5:	e8 44 f3 ff ff       	call   80022e <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	6a 07                	push   $0x7
  800eef:	68 00 f0 7f 00       	push   $0x7ff000
  800ef4:	6a 00                	push   $0x0
  800ef6:	e8 94 fd ff ff       	call   800c8f <sys_page_alloc>
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	79 14                	jns    800f16 <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	68 58 2c 80 00       	push   $0x802c58
  800f0a:	6a 2f                	push   $0x2f
  800f0c:	68 cf 2c 80 00       	push   $0x802ccf
  800f11:	e8 18 f3 ff ff       	call   80022e <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f16:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f1c:	83 ec 04             	sub    $0x4,%esp
  800f1f:	68 00 10 00 00       	push   $0x1000
  800f24:	53                   	push   %ebx
  800f25:	68 00 f0 7f 00       	push   $0x7ff000
  800f2a:	e8 ef fa ff ff       	call   800a1e <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f2f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f36:	53                   	push   %ebx
  800f37:	6a 00                	push   $0x0
  800f39:	68 00 f0 7f 00       	push   $0x7ff000
  800f3e:	6a 00                	push   $0x0
  800f40:	e8 8d fd ff ff       	call   800cd2 <sys_page_map>
  800f45:	83 c4 20             	add    $0x20,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	79 14                	jns    800f60 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  800f4c:	83 ec 04             	sub    $0x4,%esp
  800f4f:	68 84 2c 80 00       	push   $0x802c84
  800f54:	6a 34                	push   $0x34
  800f56:	68 cf 2c 80 00       	push   $0x802ccf
  800f5b:	e8 ce f2 ff ff       	call   80022e <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f60:	83 ec 08             	sub    $0x8,%esp
  800f63:	68 00 f0 7f 00       	push   $0x7ff000
  800f68:	6a 00                	push   $0x0
  800f6a:	e8 a5 fd ff ff       	call   800d14 <sys_page_unmap>
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	79 14                	jns    800f8a <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	68 ac 2c 80 00       	push   $0x802cac
  800f7e:	6a 37                	push   $0x37
  800f80:	68 cf 2c 80 00       	push   $0x802ccf
  800f85:	e8 a4 f2 ff ff       	call   80022e <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  800f8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	57                   	push   %edi
  800f93:	56                   	push   %esi
  800f94:	53                   	push   %ebx
  800f95:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800f98:	68 9f 0e 80 00       	push   $0x800e9f
  800f9d:	e8 77 13 00 00       	call   802319 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fa2:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa7:	cd 30                	int    $0x30
  800fa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	79 15                	jns    800fcb <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800fb6:	50                   	push   %eax
  800fb7:	68 da 2c 80 00       	push   $0x802cda
  800fbc:	68 8d 00 00 00       	push   $0x8d
  800fc1:	68 cf 2c 80 00       	push   $0x802ccf
  800fc6:	e8 63 f2 ff ff       	call   80022e <_panic>
  800fcb:	be 00 00 00 00       	mov    $0x0,%esi
  800fd0:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  800fd5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fd9:	75 21                	jne    800ffc <fork+0x6d>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  800fdb:	e8 71 fc ff ff       	call   800c51 <sys_getenvid>
  800fe0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fed:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ff2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff7:	e9 aa 01 00 00       	jmp    8011a6 <fork+0x217>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  800ffc:	89 f0                	mov    %esi,%eax
  800ffe:	c1 e8 16             	shr    $0x16,%eax
  801001:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801008:	a8 01                	test   $0x1,%al
  80100a:	0f 84 f9 00 00 00    	je     801109 <fork+0x17a>
  801010:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801017:	a8 05                	test   $0x5,%al
  801019:	0f 84 ea 00 00 00    	je     801109 <fork+0x17a>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
  80101f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801026:	a8 02                	test   $0x2,%al
  801028:	75 1c                	jne    801046 <fork+0xb7>
  80102a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801031:	f6 c4 08             	test   $0x8,%ah
  801034:	75 10                	jne    801046 <fork+0xb7>
  801036:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80103d:	f6 c4 04             	test   $0x4,%ah
  801040:	0f 84 99 00 00 00    	je     8010df <fork+0x150>
	{
		if(uvpt[pn] & PTE_SHARE)
  801046:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80104d:	f6 c4 04             	test   $0x4,%ah
  801050:	74 0f                	je     801061 <fork+0xd2>
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
  801052:	8b 3c 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edi
  801059:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  80105f:	eb 2d                	jmp    80108e <fork+0xff>
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  801061:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
			perm = PTE_P|PTE_U|PTE_COW;
  801068:	bf 05 08 00 00       	mov    $0x805,%edi
	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
	{
		if(uvpt[pn] & PTE_SHARE)
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  80106d:	a8 02                	test   $0x2,%al
  80106f:	75 1d                	jne    80108e <fork+0xff>
  801071:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801078:	25 00 08 00 00       	and    $0x800,%eax
			perm = PTE_P|PTE_U|PTE_COW;
  80107d:	83 f8 01             	cmp    $0x1,%eax
  801080:	19 ff                	sbb    %edi,%edi
  801082:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801088:	81 c7 05 08 00 00    	add    $0x805,%edi
		}

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm))) < 0)
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	57                   	push   %edi
  801092:	56                   	push   %esi
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	56                   	push   %esi
  801097:	6a 00                	push   $0x0
  801099:	e8 34 fc ff ff       	call   800cd2 <sys_page_map>
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 12                	jns    8010b7 <fork+0x128>
			panic("fork: sys_page_map: %e", r);
  8010a5:	50                   	push   %eax
  8010a6:	68 ea 2c 80 00       	push   $0x802cea
  8010ab:	6a 62                	push   $0x62
  8010ad:	68 cf 2c 80 00       	push   $0x802ccf
  8010b2:	e8 77 f1 ff ff       	call   80022e <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm))) < 0)
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	6a 00                	push   $0x0
  8010be:	56                   	push   %esi
  8010bf:	6a 00                	push   $0x0
  8010c1:	e8 0c fc ff ff       	call   800cd2 <sys_page_map>
  8010c6:	83 c4 20             	add    $0x20,%esp
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	79 3c                	jns    801109 <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  8010cd:	50                   	push   %eax
  8010ce:	68 ea 2c 80 00       	push   $0x802cea
  8010d3:	6a 65                	push   $0x65
  8010d5:	68 cf 2c 80 00       	push   $0x802ccf
  8010da:	e8 4f f1 ff ff       	call   80022e <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	6a 05                	push   $0x5
  8010e4:	56                   	push   %esi
  8010e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e8:	56                   	push   %esi
  8010e9:	6a 00                	push   $0x0
  8010eb:	e8 e2 fb ff ff       	call   800cd2 <sys_page_map>
  8010f0:	83 c4 20             	add    $0x20,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	79 12                	jns    801109 <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  8010f7:	50                   	push   %eax
  8010f8:	68 ea 2c 80 00       	push   $0x802cea
  8010fd:	6a 6a                	push   $0x6a
  8010ff:	68 cf 2c 80 00       	push   $0x802ccf
  801104:	e8 25 f1 ff ff       	call   80022e <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  801109:	83 c3 01             	add    $0x1,%ebx
  80110c:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801112:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801118:	0f 85 de fe ff ff    	jne    800ffc <fork+0x6d>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  80111e:	83 ec 04             	sub    $0x4,%esp
  801121:	6a 07                	push   $0x7
  801123:	68 00 f0 bf ee       	push   $0xeebff000
  801128:	ff 75 e0             	pushl  -0x20(%ebp)
  80112b:	e8 5f fb ff ff       	call   800c8f <sys_page_alloc>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	79 15                	jns    80114c <fork+0x1bd>
		panic("sys_page_alloc: %e", r);
  801137:	50                   	push   %eax
  801138:	68 01 2d 80 00       	push   $0x802d01
  80113d:	68 9e 00 00 00       	push   $0x9e
  801142:	68 cf 2c 80 00       	push   $0x802ccf
  801147:	e8 e2 f0 ff ff       	call   80022e <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	68 96 23 80 00       	push   $0x802396
  801154:	ff 75 e0             	pushl  -0x20(%ebp)
  801157:	e8 7e fc ff ff       	call   800dda <sys_env_set_pgfault_upcall>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	79 17                	jns    80117a <fork+0x1eb>
		panic("sys_pgfault_upcall error");
  801163:	83 ec 04             	sub    $0x4,%esp
  801166:	68 14 2d 80 00       	push   $0x802d14
  80116b:	68 a1 00 00 00       	push   $0xa1
  801170:	68 cf 2c 80 00       	push   $0x802ccf
  801175:	e8 b4 f0 ff ff       	call   80022e <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80117a:	83 ec 08             	sub    $0x8,%esp
  80117d:	6a 02                	push   $0x2
  80117f:	ff 75 e0             	pushl  -0x20(%ebp)
  801182:	e8 cf fb ff ff       	call   800d56 <sys_env_set_status>
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	85 c0                	test   %eax,%eax
  80118c:	79 15                	jns    8011a3 <fork+0x214>
		panic("sys_env_set_status: %e", r);
  80118e:	50                   	push   %eax
  80118f:	68 2d 2d 80 00       	push   $0x802d2d
  801194:	68 a7 00 00 00       	push   $0xa7
  801199:	68 cf 2c 80 00       	push   $0x802ccf
  80119e:	e8 8b f0 ff ff       	call   80022e <_panic>

	return envid;
  8011a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  8011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a9:	5b                   	pop    %ebx
  8011aa:	5e                   	pop    %esi
  8011ab:	5f                   	pop    %edi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <sfork>:

// Challenge!
int
sfork(void)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011b4:	68 44 2d 80 00       	push   $0x802d44
  8011b9:	68 b2 00 00 00       	push   $0xb2
  8011be:	68 cf 2c 80 00       	push   $0x802ccf
  8011c3:	e8 66 f0 ff ff       	call   80022e <_panic>

008011c8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d3:	c1 e8 0c             	shr    $0xc,%eax
}
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	c1 ea 16             	shr    $0x16,%edx
  8011ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 11                	je     80121c <fd_alloc+0x2d>
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	c1 ea 0c             	shr    $0xc,%edx
  801210:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801217:	f6 c2 01             	test   $0x1,%dl
  80121a:	75 09                	jne    801225 <fd_alloc+0x36>
			*fd_store = fd;
  80121c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
  801223:	eb 17                	jmp    80123c <fd_alloc+0x4d>
  801225:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80122a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122f:	75 c9                	jne    8011fa <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801231:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801237:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801244:	83 f8 1f             	cmp    $0x1f,%eax
  801247:	77 36                	ja     80127f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801249:	c1 e0 0c             	shl    $0xc,%eax
  80124c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801251:	89 c2                	mov    %eax,%edx
  801253:	c1 ea 16             	shr    $0x16,%edx
  801256:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125d:	f6 c2 01             	test   $0x1,%dl
  801260:	74 24                	je     801286 <fd_lookup+0x48>
  801262:	89 c2                	mov    %eax,%edx
  801264:	c1 ea 0c             	shr    $0xc,%edx
  801267:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126e:	f6 c2 01             	test   $0x1,%dl
  801271:	74 1a                	je     80128d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801273:	8b 55 0c             	mov    0xc(%ebp),%edx
  801276:	89 02                	mov    %eax,(%edx)
	return 0;
  801278:	b8 00 00 00 00       	mov    $0x0,%eax
  80127d:	eb 13                	jmp    801292 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801284:	eb 0c                	jmp    801292 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801286:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128b:	eb 05                	jmp    801292 <fd_lookup+0x54>
  80128d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129d:	ba d8 2d 80 00       	mov    $0x802dd8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012a2:	eb 13                	jmp    8012b7 <dev_lookup+0x23>
  8012a4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012a7:	39 08                	cmp    %ecx,(%eax)
  8012a9:	75 0c                	jne    8012b7 <dev_lookup+0x23>
			*dev = devtab[i];
  8012ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ae:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b5:	eb 2e                	jmp    8012e5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b7:	8b 02                	mov    (%edx),%eax
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	75 e7                	jne    8012a4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012bd:	a1 08 40 80 00       	mov    0x804008,%eax
  8012c2:	8b 40 48             	mov    0x48(%eax),%eax
  8012c5:	83 ec 04             	sub    $0x4,%esp
  8012c8:	51                   	push   %ecx
  8012c9:	50                   	push   %eax
  8012ca:	68 5c 2d 80 00       	push   $0x802d5c
  8012cf:	e8 33 f0 ff ff       	call   800307 <cprintf>
	*dev = 0;
  8012d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e5:	c9                   	leave  
  8012e6:	c3                   	ret    

008012e7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	56                   	push   %esi
  8012eb:	53                   	push   %ebx
  8012ec:	83 ec 10             	sub    $0x10,%esp
  8012ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ff:	c1 e8 0c             	shr    $0xc,%eax
  801302:	50                   	push   %eax
  801303:	e8 36 ff ff ff       	call   80123e <fd_lookup>
  801308:	83 c4 08             	add    $0x8,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 05                	js     801314 <fd_close+0x2d>
	    || fd != fd2)
  80130f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801312:	74 0c                	je     801320 <fd_close+0x39>
		return (must_exist ? r : 0);
  801314:	84 db                	test   %bl,%bl
  801316:	ba 00 00 00 00       	mov    $0x0,%edx
  80131b:	0f 44 c2             	cmove  %edx,%eax
  80131e:	eb 41                	jmp    801361 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	ff 36                	pushl  (%esi)
  801329:	e8 66 ff ff ff       	call   801294 <dev_lookup>
  80132e:	89 c3                	mov    %eax,%ebx
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 1a                	js     801351 <fd_close+0x6a>
		if (dev->dev_close)
  801337:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80133d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801342:	85 c0                	test   %eax,%eax
  801344:	74 0b                	je     801351 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801346:	83 ec 0c             	sub    $0xc,%esp
  801349:	56                   	push   %esi
  80134a:	ff d0                	call   *%eax
  80134c:	89 c3                	mov    %eax,%ebx
  80134e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	56                   	push   %esi
  801355:	6a 00                	push   $0x0
  801357:	e8 b8 f9 ff ff       	call   800d14 <sys_page_unmap>
	return r;
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	89 d8                	mov    %ebx,%eax
}
  801361:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801364:	5b                   	pop    %ebx
  801365:	5e                   	pop    %esi
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    

00801368 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80136e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	ff 75 08             	pushl  0x8(%ebp)
  801375:	e8 c4 fe ff ff       	call   80123e <fd_lookup>
  80137a:	83 c4 08             	add    $0x8,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 10                	js     801391 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	6a 01                	push   $0x1
  801386:	ff 75 f4             	pushl  -0xc(%ebp)
  801389:	e8 59 ff ff ff       	call   8012e7 <fd_close>
  80138e:	83 c4 10             	add    $0x10,%esp
}
  801391:	c9                   	leave  
  801392:	c3                   	ret    

00801393 <close_all>:

void
close_all(void)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	53                   	push   %ebx
  801397:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80139a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	53                   	push   %ebx
  8013a3:	e8 c0 ff ff ff       	call   801368 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a8:	83 c3 01             	add    $0x1,%ebx
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	83 fb 20             	cmp    $0x20,%ebx
  8013b1:	75 ec                	jne    80139f <close_all+0xc>
		close(i);
}
  8013b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b6:	c9                   	leave  
  8013b7:	c3                   	ret    

008013b8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	57                   	push   %edi
  8013bc:	56                   	push   %esi
  8013bd:	53                   	push   %ebx
  8013be:	83 ec 2c             	sub    $0x2c,%esp
  8013c1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c7:	50                   	push   %eax
  8013c8:	ff 75 08             	pushl  0x8(%ebp)
  8013cb:	e8 6e fe ff ff       	call   80123e <fd_lookup>
  8013d0:	83 c4 08             	add    $0x8,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	0f 88 c1 00 00 00    	js     80149c <dup+0xe4>
		return r;
	close(newfdnum);
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	56                   	push   %esi
  8013df:	e8 84 ff ff ff       	call   801368 <close>

	newfd = INDEX2FD(newfdnum);
  8013e4:	89 f3                	mov    %esi,%ebx
  8013e6:	c1 e3 0c             	shl    $0xc,%ebx
  8013e9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013ef:	83 c4 04             	add    $0x4,%esp
  8013f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013f5:	e8 de fd ff ff       	call   8011d8 <fd2data>
  8013fa:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013fc:	89 1c 24             	mov    %ebx,(%esp)
  8013ff:	e8 d4 fd ff ff       	call   8011d8 <fd2data>
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80140a:	89 f8                	mov    %edi,%eax
  80140c:	c1 e8 16             	shr    $0x16,%eax
  80140f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801416:	a8 01                	test   $0x1,%al
  801418:	74 37                	je     801451 <dup+0x99>
  80141a:	89 f8                	mov    %edi,%eax
  80141c:	c1 e8 0c             	shr    $0xc,%eax
  80141f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801426:	f6 c2 01             	test   $0x1,%dl
  801429:	74 26                	je     801451 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80142b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	25 07 0e 00 00       	and    $0xe07,%eax
  80143a:	50                   	push   %eax
  80143b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80143e:	6a 00                	push   $0x0
  801440:	57                   	push   %edi
  801441:	6a 00                	push   $0x0
  801443:	e8 8a f8 ff ff       	call   800cd2 <sys_page_map>
  801448:	89 c7                	mov    %eax,%edi
  80144a:	83 c4 20             	add    $0x20,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 2e                	js     80147f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801451:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801454:	89 d0                	mov    %edx,%eax
  801456:	c1 e8 0c             	shr    $0xc,%eax
  801459:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801460:	83 ec 0c             	sub    $0xc,%esp
  801463:	25 07 0e 00 00       	and    $0xe07,%eax
  801468:	50                   	push   %eax
  801469:	53                   	push   %ebx
  80146a:	6a 00                	push   $0x0
  80146c:	52                   	push   %edx
  80146d:	6a 00                	push   $0x0
  80146f:	e8 5e f8 ff ff       	call   800cd2 <sys_page_map>
  801474:	89 c7                	mov    %eax,%edi
  801476:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801479:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80147b:	85 ff                	test   %edi,%edi
  80147d:	79 1d                	jns    80149c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	53                   	push   %ebx
  801483:	6a 00                	push   $0x0
  801485:	e8 8a f8 ff ff       	call   800d14 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80148a:	83 c4 08             	add    $0x8,%esp
  80148d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801490:	6a 00                	push   $0x0
  801492:	e8 7d f8 ff ff       	call   800d14 <sys_page_unmap>
	return r;
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	89 f8                	mov    %edi,%eax
}
  80149c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5f                   	pop    %edi
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    

008014a4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	53                   	push   %ebx
  8014a8:	83 ec 14             	sub    $0x14,%esp
  8014ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	53                   	push   %ebx
  8014b3:	e8 86 fd ff ff       	call   80123e <fd_lookup>
  8014b8:	83 c4 08             	add    $0x8,%esp
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 6d                	js     80152e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cb:	ff 30                	pushl  (%eax)
  8014cd:	e8 c2 fd ff ff       	call   801294 <dev_lookup>
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 4c                	js     801525 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014dc:	8b 42 08             	mov    0x8(%edx),%eax
  8014df:	83 e0 03             	and    $0x3,%eax
  8014e2:	83 f8 01             	cmp    $0x1,%eax
  8014e5:	75 21                	jne    801508 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e7:	a1 08 40 80 00       	mov    0x804008,%eax
  8014ec:	8b 40 48             	mov    0x48(%eax),%eax
  8014ef:	83 ec 04             	sub    $0x4,%esp
  8014f2:	53                   	push   %ebx
  8014f3:	50                   	push   %eax
  8014f4:	68 9d 2d 80 00       	push   $0x802d9d
  8014f9:	e8 09 ee ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801506:	eb 26                	jmp    80152e <read+0x8a>
	}
	if (!dev->dev_read)
  801508:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150b:	8b 40 08             	mov    0x8(%eax),%eax
  80150e:	85 c0                	test   %eax,%eax
  801510:	74 17                	je     801529 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801512:	83 ec 04             	sub    $0x4,%esp
  801515:	ff 75 10             	pushl  0x10(%ebp)
  801518:	ff 75 0c             	pushl  0xc(%ebp)
  80151b:	52                   	push   %edx
  80151c:	ff d0                	call   *%eax
  80151e:	89 c2                	mov    %eax,%edx
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	eb 09                	jmp    80152e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801525:	89 c2                	mov    %eax,%edx
  801527:	eb 05                	jmp    80152e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801529:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80152e:	89 d0                	mov    %edx,%eax
  801530:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801533:	c9                   	leave  
  801534:	c3                   	ret    

00801535 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	57                   	push   %edi
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801541:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801544:	bb 00 00 00 00       	mov    $0x0,%ebx
  801549:	eb 21                	jmp    80156c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80154b:	83 ec 04             	sub    $0x4,%esp
  80154e:	89 f0                	mov    %esi,%eax
  801550:	29 d8                	sub    %ebx,%eax
  801552:	50                   	push   %eax
  801553:	89 d8                	mov    %ebx,%eax
  801555:	03 45 0c             	add    0xc(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	57                   	push   %edi
  80155a:	e8 45 ff ff ff       	call   8014a4 <read>
		if (m < 0)
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 10                	js     801576 <readn+0x41>
			return m;
		if (m == 0)
  801566:	85 c0                	test   %eax,%eax
  801568:	74 0a                	je     801574 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156a:	01 c3                	add    %eax,%ebx
  80156c:	39 f3                	cmp    %esi,%ebx
  80156e:	72 db                	jb     80154b <readn+0x16>
  801570:	89 d8                	mov    %ebx,%eax
  801572:	eb 02                	jmp    801576 <readn+0x41>
  801574:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801576:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801579:	5b                   	pop    %ebx
  80157a:	5e                   	pop    %esi
  80157b:	5f                   	pop    %edi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	53                   	push   %ebx
  801582:	83 ec 14             	sub    $0x14,%esp
  801585:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801588:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158b:	50                   	push   %eax
  80158c:	53                   	push   %ebx
  80158d:	e8 ac fc ff ff       	call   80123e <fd_lookup>
  801592:	83 c4 08             	add    $0x8,%esp
  801595:	89 c2                	mov    %eax,%edx
  801597:	85 c0                	test   %eax,%eax
  801599:	78 68                	js     801603 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a5:	ff 30                	pushl  (%eax)
  8015a7:	e8 e8 fc ff ff       	call   801294 <dev_lookup>
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 47                	js     8015fa <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ba:	75 21                	jne    8015dd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8015c1:	8b 40 48             	mov    0x48(%eax),%eax
  8015c4:	83 ec 04             	sub    $0x4,%esp
  8015c7:	53                   	push   %ebx
  8015c8:	50                   	push   %eax
  8015c9:	68 b9 2d 80 00       	push   $0x802db9
  8015ce:	e8 34 ed ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015db:	eb 26                	jmp    801603 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015e3:	85 d2                	test   %edx,%edx
  8015e5:	74 17                	je     8015fe <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e7:	83 ec 04             	sub    $0x4,%esp
  8015ea:	ff 75 10             	pushl  0x10(%ebp)
  8015ed:	ff 75 0c             	pushl  0xc(%ebp)
  8015f0:	50                   	push   %eax
  8015f1:	ff d2                	call   *%edx
  8015f3:	89 c2                	mov    %eax,%edx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	eb 09                	jmp    801603 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	eb 05                	jmp    801603 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801603:	89 d0                	mov    %edx,%eax
  801605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <seek>:

int
seek(int fdnum, off_t offset)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801610:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 22 fc ff ff       	call   80123e <fd_lookup>
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 0e                	js     801631 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801623:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801626:	8b 55 0c             	mov    0xc(%ebp),%edx
  801629:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80162c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	53                   	push   %ebx
  801637:	83 ec 14             	sub    $0x14,%esp
  80163a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801640:	50                   	push   %eax
  801641:	53                   	push   %ebx
  801642:	e8 f7 fb ff ff       	call   80123e <fd_lookup>
  801647:	83 c4 08             	add    $0x8,%esp
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 65                	js     8016b5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165a:	ff 30                	pushl  (%eax)
  80165c:	e8 33 fc ff ff       	call   801294 <dev_lookup>
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	85 c0                	test   %eax,%eax
  801666:	78 44                	js     8016ac <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801668:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80166f:	75 21                	jne    801692 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801671:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801676:	8b 40 48             	mov    0x48(%eax),%eax
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	53                   	push   %ebx
  80167d:	50                   	push   %eax
  80167e:	68 7c 2d 80 00       	push   $0x802d7c
  801683:	e8 7f ec ff ff       	call   800307 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801690:	eb 23                	jmp    8016b5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801692:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801695:	8b 52 18             	mov    0x18(%edx),%edx
  801698:	85 d2                	test   %edx,%edx
  80169a:	74 14                	je     8016b0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80169c:	83 ec 08             	sub    $0x8,%esp
  80169f:	ff 75 0c             	pushl  0xc(%ebp)
  8016a2:	50                   	push   %eax
  8016a3:	ff d2                	call   *%edx
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	eb 09                	jmp    8016b5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ac:	89 c2                	mov    %eax,%edx
  8016ae:	eb 05                	jmp    8016b5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016b5:	89 d0                	mov    %edx,%eax
  8016b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 14             	sub    $0x14,%esp
  8016c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c9:	50                   	push   %eax
  8016ca:	ff 75 08             	pushl  0x8(%ebp)
  8016cd:	e8 6c fb ff ff       	call   80123e <fd_lookup>
  8016d2:	83 c4 08             	add    $0x8,%esp
  8016d5:	89 c2                	mov    %eax,%edx
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 58                	js     801733 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e5:	ff 30                	pushl  (%eax)
  8016e7:	e8 a8 fb ff ff       	call   801294 <dev_lookup>
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 37                	js     80172a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016fa:	74 32                	je     80172e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016fc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ff:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801706:	00 00 00 
	stat->st_isdir = 0;
  801709:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801710:	00 00 00 
	stat->st_dev = dev;
  801713:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	53                   	push   %ebx
  80171d:	ff 75 f0             	pushl  -0x10(%ebp)
  801720:	ff 50 14             	call   *0x14(%eax)
  801723:	89 c2                	mov    %eax,%edx
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	eb 09                	jmp    801733 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172a:	89 c2                	mov    %eax,%edx
  80172c:	eb 05                	jmp    801733 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80172e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801733:	89 d0                	mov    %edx,%eax
  801735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	6a 00                	push   $0x0
  801744:	ff 75 08             	pushl  0x8(%ebp)
  801747:	e8 e3 01 00 00       	call   80192f <open>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 1b                	js     801770 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801755:	83 ec 08             	sub    $0x8,%esp
  801758:	ff 75 0c             	pushl  0xc(%ebp)
  80175b:	50                   	push   %eax
  80175c:	e8 5b ff ff ff       	call   8016bc <fstat>
  801761:	89 c6                	mov    %eax,%esi
	close(fd);
  801763:	89 1c 24             	mov    %ebx,(%esp)
  801766:	e8 fd fb ff ff       	call   801368 <close>
	return r;
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	89 f0                	mov    %esi,%eax
}
  801770:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	56                   	push   %esi
  80177b:	53                   	push   %ebx
  80177c:	89 c6                	mov    %eax,%esi
  80177e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801780:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801787:	75 12                	jne    80179b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801789:	83 ec 0c             	sub    $0xc,%esp
  80178c:	6a 01                	push   $0x1
  80178e:	e8 29 0d 00 00       	call   8024bc <ipc_find_env>
  801793:	a3 00 40 80 00       	mov    %eax,0x804000
  801798:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80179b:	6a 07                	push   $0x7
  80179d:	68 00 50 80 00       	push   $0x805000
  8017a2:	56                   	push   %esi
  8017a3:	ff 35 00 40 80 00    	pushl  0x804000
  8017a9:	e8 82 0c 00 00       	call   802430 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ae:	83 c4 0c             	add    $0xc,%esp
  8017b1:	6a 00                	push   $0x0
  8017b3:	53                   	push   %ebx
  8017b4:	6a 00                	push   $0x0
  8017b6:	e8 00 0c 00 00       	call   8023bb <ipc_recv>
}
  8017bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017db:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e5:	e8 8d ff ff ff       	call   801777 <fsipc>
}
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801802:	b8 06 00 00 00       	mov    $0x6,%eax
  801807:	e8 6b ff ff ff       	call   801777 <fsipc>
}
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <devfile_stat>:
                return ((ssize_t)r);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 04             	sub    $0x4,%esp
  801815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 40 0c             	mov    0xc(%eax),%eax
  80181e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 05 00 00 00       	mov    $0x5,%eax
  80182d:	e8 45 ff ff ff       	call   801777 <fsipc>
  801832:	85 c0                	test   %eax,%eax
  801834:	78 2c                	js     801862 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	68 00 50 80 00       	push   $0x805000
  80183e:	53                   	push   %ebx
  80183f:	e8 48 f0 ff ff       	call   80088c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801844:	a1 80 50 80 00       	mov    0x805080,%eax
  801849:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80184f:	a1 84 50 80 00       	mov    0x805084,%eax
  801854:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	83 ec 0c             	sub    $0xc,%esp
  80186d:	8b 45 10             	mov    0x10(%ebp),%eax
  801870:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801875:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80187a:	0f 47 c2             	cmova  %edx,%eax
	int r;
	if(n > (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t))))
	{
		n = (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t)));
	}
		fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187d:	8b 55 08             	mov    0x8(%ebp),%edx
  801880:	8b 52 0c             	mov    0xc(%edx),%edx
  801883:	89 15 00 50 80 00    	mov    %edx,0x805000
		fsipcbuf.write.req_n = n;
  801889:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove((void *)fsipcbuf.write.req_buf, buf, n);
  80188e:	50                   	push   %eax
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	68 08 50 80 00       	push   $0x805008
  801897:	e8 82 f1 ff ff       	call   800a1e <memmove>
		r = fsipc(FSREQ_WRITE, NULL);
  80189c:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a6:	e8 cc fe ff ff       	call   801777 <fsipc>
                return ((ssize_t)r);
}
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    

008018ad <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	56                   	push   %esi
  8018b1:	53                   	push   %ebx
  8018b2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018c0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cb:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d0:	e8 a2 fe ff ff       	call   801777 <fsipc>
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 4b                	js     801926 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018db:	39 c6                	cmp    %eax,%esi
  8018dd:	73 16                	jae    8018f5 <devfile_read+0x48>
  8018df:	68 ec 2d 80 00       	push   $0x802dec
  8018e4:	68 f3 2d 80 00       	push   $0x802df3
  8018e9:	6a 7c                	push   $0x7c
  8018eb:	68 08 2e 80 00       	push   $0x802e08
  8018f0:	e8 39 e9 ff ff       	call   80022e <_panic>
	assert(r <= PGSIZE);
  8018f5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018fa:	7e 16                	jle    801912 <devfile_read+0x65>
  8018fc:	68 13 2e 80 00       	push   $0x802e13
  801901:	68 f3 2d 80 00       	push   $0x802df3
  801906:	6a 7d                	push   $0x7d
  801908:	68 08 2e 80 00       	push   $0x802e08
  80190d:	e8 1c e9 ff ff       	call   80022e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801912:	83 ec 04             	sub    $0x4,%esp
  801915:	50                   	push   %eax
  801916:	68 00 50 80 00       	push   $0x805000
  80191b:	ff 75 0c             	pushl  0xc(%ebp)
  80191e:	e8 fb f0 ff ff       	call   800a1e <memmove>
	return r;
  801923:	83 c4 10             	add    $0x10,%esp
}
  801926:	89 d8                	mov    %ebx,%eax
  801928:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192b:	5b                   	pop    %ebx
  80192c:	5e                   	pop    %esi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	53                   	push   %ebx
  801933:	83 ec 20             	sub    $0x20,%esp
  801936:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801939:	53                   	push   %ebx
  80193a:	e8 14 ef ff ff       	call   800853 <strlen>
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801947:	7f 67                	jg     8019b0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801949:	83 ec 0c             	sub    $0xc,%esp
  80194c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194f:	50                   	push   %eax
  801950:	e8 9a f8 ff ff       	call   8011ef <fd_alloc>
  801955:	83 c4 10             	add    $0x10,%esp
		return r;
  801958:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 57                	js     8019b5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	53                   	push   %ebx
  801962:	68 00 50 80 00       	push   $0x805000
  801967:	e8 20 ef ff ff       	call   80088c <strcpy>
	fsipcbuf.open.req_omode = mode;
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801974:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801977:	b8 01 00 00 00       	mov    $0x1,%eax
  80197c:	e8 f6 fd ff ff       	call   801777 <fsipc>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	79 14                	jns    80199e <open+0x6f>
		fd_close(fd, 0);
  80198a:	83 ec 08             	sub    $0x8,%esp
  80198d:	6a 00                	push   $0x0
  80198f:	ff 75 f4             	pushl  -0xc(%ebp)
  801992:	e8 50 f9 ff ff       	call   8012e7 <fd_close>
		return r;
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	89 da                	mov    %ebx,%edx
  80199c:	eb 17                	jmp    8019b5 <open+0x86>
	}

	return fd2num(fd);
  80199e:	83 ec 0c             	sub    $0xc,%esp
  8019a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a4:	e8 1f f8 ff ff       	call   8011c8 <fd2num>
  8019a9:	89 c2                	mov    %eax,%edx
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	eb 05                	jmp    8019b5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019b0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019b5:	89 d0                	mov    %edx,%eax
  8019b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8019cc:	e8 a6 fd ff ff       	call   801777 <fsipc>
}
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019d9:	68 1f 2e 80 00       	push   $0x802e1f
  8019de:	ff 75 0c             	pushl  0xc(%ebp)
  8019e1:	e8 a6 ee ff ff       	call   80088c <strcpy>
	return 0;
}
  8019e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	53                   	push   %ebx
  8019f1:	83 ec 10             	sub    $0x10,%esp
  8019f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019f7:	53                   	push   %ebx
  8019f8:	e8 f8 0a 00 00       	call   8024f5 <pageref>
  8019fd:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a00:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a05:	83 f8 01             	cmp    $0x1,%eax
  801a08:	75 10                	jne    801a1a <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	ff 73 0c             	pushl  0xc(%ebx)
  801a10:	e8 c0 02 00 00       	call   801cd5 <nsipc_close>
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a1a:	89 d0                	mov    %edx,%eax
  801a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    

00801a21 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a27:	6a 00                	push   $0x0
  801a29:	ff 75 10             	pushl  0x10(%ebp)
  801a2c:	ff 75 0c             	pushl  0xc(%ebp)
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	ff 70 0c             	pushl  0xc(%eax)
  801a35:	e8 78 03 00 00       	call   801db2 <nsipc_send>
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a42:	6a 00                	push   $0x0
  801a44:	ff 75 10             	pushl  0x10(%ebp)
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4d:	ff 70 0c             	pushl  0xc(%eax)
  801a50:	e8 f1 02 00 00       	call   801d46 <nsipc_recv>
}
  801a55:	c9                   	leave  
  801a56:	c3                   	ret    

00801a57 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a5d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a60:	52                   	push   %edx
  801a61:	50                   	push   %eax
  801a62:	e8 d7 f7 ff ff       	call   80123e <fd_lookup>
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 17                	js     801a85 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a71:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a77:	39 08                	cmp    %ecx,(%eax)
  801a79:	75 05                	jne    801a80 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a7b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7e:	eb 05                	jmp    801a85 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a80:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 1c             	sub    $0x1c,%esp
  801a8f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a94:	50                   	push   %eax
  801a95:	e8 55 f7 ff ff       	call   8011ef <fd_alloc>
  801a9a:	89 c3                	mov    %eax,%ebx
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 1b                	js     801abe <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	68 07 04 00 00       	push   $0x407
  801aab:	ff 75 f4             	pushl  -0xc(%ebp)
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 da f1 ff ff       	call   800c8f <sys_page_alloc>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	79 10                	jns    801ace <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801abe:	83 ec 0c             	sub    $0xc,%esp
  801ac1:	56                   	push   %esi
  801ac2:	e8 0e 02 00 00       	call   801cd5 <nsipc_close>
		return r;
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	89 d8                	mov    %ebx,%eax
  801acc:	eb 24                	jmp    801af2 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ace:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad7:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ae3:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	50                   	push   %eax
  801aea:	e8 d9 f6 ff ff       	call   8011c8 <fd2num>
  801aef:	83 c4 10             	add    $0x10,%esp
}
  801af2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aff:	8b 45 08             	mov    0x8(%ebp),%eax
  801b02:	e8 50 ff ff ff       	call   801a57 <fd2sockid>
		return r;
  801b07:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	78 1f                	js     801b2c <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b0d:	83 ec 04             	sub    $0x4,%esp
  801b10:	ff 75 10             	pushl  0x10(%ebp)
  801b13:	ff 75 0c             	pushl  0xc(%ebp)
  801b16:	50                   	push   %eax
  801b17:	e8 12 01 00 00       	call   801c2e <nsipc_accept>
  801b1c:	83 c4 10             	add    $0x10,%esp
		return r;
  801b1f:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b21:	85 c0                	test   %eax,%eax
  801b23:	78 07                	js     801b2c <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b25:	e8 5d ff ff ff       	call   801a87 <alloc_sockfd>
  801b2a:	89 c1                	mov    %eax,%ecx
}
  801b2c:	89 c8                	mov    %ecx,%eax
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b36:	8b 45 08             	mov    0x8(%ebp),%eax
  801b39:	e8 19 ff ff ff       	call   801a57 <fd2sockid>
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 12                	js     801b54 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b42:	83 ec 04             	sub    $0x4,%esp
  801b45:	ff 75 10             	pushl  0x10(%ebp)
  801b48:	ff 75 0c             	pushl  0xc(%ebp)
  801b4b:	50                   	push   %eax
  801b4c:	e8 2d 01 00 00       	call   801c7e <nsipc_bind>
  801b51:	83 c4 10             	add    $0x10,%esp
}
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <shutdown>:

int
shutdown(int s, int how)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5f:	e8 f3 fe ff ff       	call   801a57 <fd2sockid>
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 0f                	js     801b77 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b68:	83 ec 08             	sub    $0x8,%esp
  801b6b:	ff 75 0c             	pushl  0xc(%ebp)
  801b6e:	50                   	push   %eax
  801b6f:	e8 3f 01 00 00       	call   801cb3 <nsipc_shutdown>
  801b74:	83 c4 10             	add    $0x10,%esp
}
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    

00801b79 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b82:	e8 d0 fe ff ff       	call   801a57 <fd2sockid>
  801b87:	85 c0                	test   %eax,%eax
  801b89:	78 12                	js     801b9d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b8b:	83 ec 04             	sub    $0x4,%esp
  801b8e:	ff 75 10             	pushl  0x10(%ebp)
  801b91:	ff 75 0c             	pushl  0xc(%ebp)
  801b94:	50                   	push   %eax
  801b95:	e8 55 01 00 00       	call   801cef <nsipc_connect>
  801b9a:	83 c4 10             	add    $0x10,%esp
}
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <listen>:

int
listen(int s, int backlog)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba8:	e8 aa fe ff ff       	call   801a57 <fd2sockid>
  801bad:	85 c0                	test   %eax,%eax
  801baf:	78 0f                	js     801bc0 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bb1:	83 ec 08             	sub    $0x8,%esp
  801bb4:	ff 75 0c             	pushl  0xc(%ebp)
  801bb7:	50                   	push   %eax
  801bb8:	e8 67 01 00 00       	call   801d24 <nsipc_listen>
  801bbd:	83 c4 10             	add    $0x10,%esp
}
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    

00801bc2 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bc8:	ff 75 10             	pushl  0x10(%ebp)
  801bcb:	ff 75 0c             	pushl  0xc(%ebp)
  801bce:	ff 75 08             	pushl  0x8(%ebp)
  801bd1:	e8 3a 02 00 00       	call   801e10 <nsipc_socket>
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	78 05                	js     801be2 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bdd:	e8 a5 fe ff ff       	call   801a87 <alloc_sockfd>
}
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	53                   	push   %ebx
  801be8:	83 ec 04             	sub    $0x4,%esp
  801beb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bed:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bf4:	75 12                	jne    801c08 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bf6:	83 ec 0c             	sub    $0xc,%esp
  801bf9:	6a 02                	push   $0x2
  801bfb:	e8 bc 08 00 00       	call   8024bc <ipc_find_env>
  801c00:	a3 04 40 80 00       	mov    %eax,0x804004
  801c05:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c08:	6a 07                	push   $0x7
  801c0a:	68 00 60 80 00       	push   $0x806000
  801c0f:	53                   	push   %ebx
  801c10:	ff 35 04 40 80 00    	pushl  0x804004
  801c16:	e8 15 08 00 00       	call   802430 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c1b:	83 c4 0c             	add    $0xc,%esp
  801c1e:	6a 00                	push   $0x0
  801c20:	6a 00                	push   $0x0
  801c22:	6a 00                	push   $0x0
  801c24:	e8 92 07 00 00       	call   8023bb <ipc_recv>
}
  801c29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	56                   	push   %esi
  801c32:	53                   	push   %ebx
  801c33:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c36:	8b 45 08             	mov    0x8(%ebp),%eax
  801c39:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c3e:	8b 06                	mov    (%esi),%eax
  801c40:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c45:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4a:	e8 95 ff ff ff       	call   801be4 <nsipc>
  801c4f:	89 c3                	mov    %eax,%ebx
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 20                	js     801c75 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c55:	83 ec 04             	sub    $0x4,%esp
  801c58:	ff 35 10 60 80 00    	pushl  0x806010
  801c5e:	68 00 60 80 00       	push   $0x806000
  801c63:	ff 75 0c             	pushl  0xc(%ebp)
  801c66:	e8 b3 ed ff ff       	call   800a1e <memmove>
		*addrlen = ret->ret_addrlen;
  801c6b:	a1 10 60 80 00       	mov    0x806010,%eax
  801c70:	89 06                	mov    %eax,(%esi)
  801c72:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c75:	89 d8                	mov    %ebx,%eax
  801c77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7a:	5b                   	pop    %ebx
  801c7b:	5e                   	pop    %esi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	53                   	push   %ebx
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c88:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c90:	53                   	push   %ebx
  801c91:	ff 75 0c             	pushl  0xc(%ebp)
  801c94:	68 04 60 80 00       	push   $0x806004
  801c99:	e8 80 ed ff ff       	call   800a1e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c9e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ca4:	b8 02 00 00 00       	mov    $0x2,%eax
  801ca9:	e8 36 ff ff ff       	call   801be4 <nsipc>
}
  801cae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cc9:	b8 03 00 00 00       	mov    $0x3,%eax
  801cce:	e8 11 ff ff ff       	call   801be4 <nsipc>
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <nsipc_close>:

int
nsipc_close(int s)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ce3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ce8:	e8 f7 fe ff ff       	call   801be4 <nsipc>
}
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    

00801cef <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	53                   	push   %ebx
  801cf3:	83 ec 08             	sub    $0x8,%esp
  801cf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d01:	53                   	push   %ebx
  801d02:	ff 75 0c             	pushl  0xc(%ebp)
  801d05:	68 04 60 80 00       	push   $0x806004
  801d0a:	e8 0f ed ff ff       	call   800a1e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d0f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d15:	b8 05 00 00 00       	mov    $0x5,%eax
  801d1a:	e8 c5 fe ff ff       	call   801be4 <nsipc>
}
  801d1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    

00801d24 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d35:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d3a:	b8 06 00 00 00       	mov    $0x6,%eax
  801d3f:	e8 a0 fe ff ff       	call   801be4 <nsipc>
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	56                   	push   %esi
  801d4a:	53                   	push   %ebx
  801d4b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d51:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d56:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d5c:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d64:	b8 07 00 00 00       	mov    $0x7,%eax
  801d69:	e8 76 fe ff ff       	call   801be4 <nsipc>
  801d6e:	89 c3                	mov    %eax,%ebx
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 35                	js     801da9 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d74:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d79:	7f 04                	jg     801d7f <nsipc_recv+0x39>
  801d7b:	39 c6                	cmp    %eax,%esi
  801d7d:	7d 16                	jge    801d95 <nsipc_recv+0x4f>
  801d7f:	68 2b 2e 80 00       	push   $0x802e2b
  801d84:	68 f3 2d 80 00       	push   $0x802df3
  801d89:	6a 62                	push   $0x62
  801d8b:	68 40 2e 80 00       	push   $0x802e40
  801d90:	e8 99 e4 ff ff       	call   80022e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d95:	83 ec 04             	sub    $0x4,%esp
  801d98:	50                   	push   %eax
  801d99:	68 00 60 80 00       	push   $0x806000
  801d9e:	ff 75 0c             	pushl  0xc(%ebp)
  801da1:	e8 78 ec ff ff       	call   800a1e <memmove>
  801da6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801da9:	89 d8                	mov    %ebx,%eax
  801dab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dae:	5b                   	pop    %ebx
  801daf:	5e                   	pop    %esi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	53                   	push   %ebx
  801db6:	83 ec 04             	sub    $0x4,%esp
  801db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dc4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dca:	7e 16                	jle    801de2 <nsipc_send+0x30>
  801dcc:	68 4c 2e 80 00       	push   $0x802e4c
  801dd1:	68 f3 2d 80 00       	push   $0x802df3
  801dd6:	6a 6d                	push   $0x6d
  801dd8:	68 40 2e 80 00       	push   $0x802e40
  801ddd:	e8 4c e4 ff ff       	call   80022e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801de2:	83 ec 04             	sub    $0x4,%esp
  801de5:	53                   	push   %ebx
  801de6:	ff 75 0c             	pushl  0xc(%ebp)
  801de9:	68 0c 60 80 00       	push   $0x80600c
  801dee:	e8 2b ec ff ff       	call   800a1e <memmove>
	nsipcbuf.send.req_size = size;
  801df3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801df9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e01:	b8 08 00 00 00       	mov    $0x8,%eax
  801e06:	e8 d9 fd ff ff       	call   801be4 <nsipc>
}
  801e0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e21:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e26:	8b 45 10             	mov    0x10(%ebp),%eax
  801e29:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e2e:	b8 09 00 00 00       	mov    $0x9,%eax
  801e33:	e8 ac fd ff ff       	call   801be4 <nsipc>
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	56                   	push   %esi
  801e3e:	53                   	push   %ebx
  801e3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e42:	83 ec 0c             	sub    $0xc,%esp
  801e45:	ff 75 08             	pushl  0x8(%ebp)
  801e48:	e8 8b f3 ff ff       	call   8011d8 <fd2data>
  801e4d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e4f:	83 c4 08             	add    $0x8,%esp
  801e52:	68 58 2e 80 00       	push   $0x802e58
  801e57:	53                   	push   %ebx
  801e58:	e8 2f ea ff ff       	call   80088c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e5d:	8b 46 04             	mov    0x4(%esi),%eax
  801e60:	2b 06                	sub    (%esi),%eax
  801e62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e68:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e6f:	00 00 00 
	stat->st_dev = &devpipe;
  801e72:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e79:	30 80 00 
	return 0;
}
  801e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	53                   	push   %ebx
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e92:	53                   	push   %ebx
  801e93:	6a 00                	push   $0x0
  801e95:	e8 7a ee ff ff       	call   800d14 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e9a:	89 1c 24             	mov    %ebx,(%esp)
  801e9d:	e8 36 f3 ff ff       	call   8011d8 <fd2data>
  801ea2:	83 c4 08             	add    $0x8,%esp
  801ea5:	50                   	push   %eax
  801ea6:	6a 00                	push   $0x0
  801ea8:	e8 67 ee ff ff       	call   800d14 <sys_page_unmap>
}
  801ead:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	57                   	push   %edi
  801eb6:	56                   	push   %esi
  801eb7:	53                   	push   %ebx
  801eb8:	83 ec 1c             	sub    $0x1c,%esp
  801ebb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ebe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ec0:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ec8:	83 ec 0c             	sub    $0xc,%esp
  801ecb:	ff 75 e0             	pushl  -0x20(%ebp)
  801ece:	e8 22 06 00 00       	call   8024f5 <pageref>
  801ed3:	89 c3                	mov    %eax,%ebx
  801ed5:	89 3c 24             	mov    %edi,(%esp)
  801ed8:	e8 18 06 00 00       	call   8024f5 <pageref>
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	39 c3                	cmp    %eax,%ebx
  801ee2:	0f 94 c1             	sete   %cl
  801ee5:	0f b6 c9             	movzbl %cl,%ecx
  801ee8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801eeb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ef1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ef4:	39 ce                	cmp    %ecx,%esi
  801ef6:	74 1b                	je     801f13 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ef8:	39 c3                	cmp    %eax,%ebx
  801efa:	75 c4                	jne    801ec0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801efc:	8b 42 58             	mov    0x58(%edx),%eax
  801eff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f02:	50                   	push   %eax
  801f03:	56                   	push   %esi
  801f04:	68 5f 2e 80 00       	push   $0x802e5f
  801f09:	e8 f9 e3 ff ff       	call   800307 <cprintf>
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	eb ad                	jmp    801ec0 <_pipeisclosed+0xe>
	}
}
  801f13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f19:	5b                   	pop    %ebx
  801f1a:	5e                   	pop    %esi
  801f1b:	5f                   	pop    %edi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 28             	sub    $0x28,%esp
  801f27:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f2a:	56                   	push   %esi
  801f2b:	e8 a8 f2 ff ff       	call   8011d8 <fd2data>
  801f30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	bf 00 00 00 00       	mov    $0x0,%edi
  801f3a:	eb 4b                	jmp    801f87 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f3c:	89 da                	mov    %ebx,%edx
  801f3e:	89 f0                	mov    %esi,%eax
  801f40:	e8 6d ff ff ff       	call   801eb2 <_pipeisclosed>
  801f45:	85 c0                	test   %eax,%eax
  801f47:	75 48                	jne    801f91 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f49:	e8 22 ed ff ff       	call   800c70 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f4e:	8b 43 04             	mov    0x4(%ebx),%eax
  801f51:	8b 0b                	mov    (%ebx),%ecx
  801f53:	8d 51 20             	lea    0x20(%ecx),%edx
  801f56:	39 d0                	cmp    %edx,%eax
  801f58:	73 e2                	jae    801f3c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f5d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f61:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f64:	89 c2                	mov    %eax,%edx
  801f66:	c1 fa 1f             	sar    $0x1f,%edx
  801f69:	89 d1                	mov    %edx,%ecx
  801f6b:	c1 e9 1b             	shr    $0x1b,%ecx
  801f6e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f71:	83 e2 1f             	and    $0x1f,%edx
  801f74:	29 ca                	sub    %ecx,%edx
  801f76:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f7a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f7e:	83 c0 01             	add    $0x1,%eax
  801f81:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f84:	83 c7 01             	add    $0x1,%edi
  801f87:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f8a:	75 c2                	jne    801f4e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8f:	eb 05                	jmp    801f96 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f91:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5f                   	pop    %edi
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 18             	sub    $0x18,%esp
  801fa7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801faa:	57                   	push   %edi
  801fab:	e8 28 f2 ff ff       	call   8011d8 <fd2data>
  801fb0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb2:	83 c4 10             	add    $0x10,%esp
  801fb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fba:	eb 3d                	jmp    801ff9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fbc:	85 db                	test   %ebx,%ebx
  801fbe:	74 04                	je     801fc4 <devpipe_read+0x26>
				return i;
  801fc0:	89 d8                	mov    %ebx,%eax
  801fc2:	eb 44                	jmp    802008 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fc4:	89 f2                	mov    %esi,%edx
  801fc6:	89 f8                	mov    %edi,%eax
  801fc8:	e8 e5 fe ff ff       	call   801eb2 <_pipeisclosed>
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	75 32                	jne    802003 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fd1:	e8 9a ec ff ff       	call   800c70 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fd6:	8b 06                	mov    (%esi),%eax
  801fd8:	3b 46 04             	cmp    0x4(%esi),%eax
  801fdb:	74 df                	je     801fbc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fdd:	99                   	cltd   
  801fde:	c1 ea 1b             	shr    $0x1b,%edx
  801fe1:	01 d0                	add    %edx,%eax
  801fe3:	83 e0 1f             	and    $0x1f,%eax
  801fe6:	29 d0                	sub    %edx,%eax
  801fe8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ff0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ff3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff6:	83 c3 01             	add    $0x1,%ebx
  801ff9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ffc:	75 d8                	jne    801fd6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ffe:	8b 45 10             	mov    0x10(%ebp),%eax
  802001:	eb 05                	jmp    802008 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5e                   	pop    %esi
  80200d:	5f                   	pop    %edi
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    

00802010 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	56                   	push   %esi
  802014:	53                   	push   %ebx
  802015:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802018:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201b:	50                   	push   %eax
  80201c:	e8 ce f1 ff ff       	call   8011ef <fd_alloc>
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	89 c2                	mov    %eax,%edx
  802026:	85 c0                	test   %eax,%eax
  802028:	0f 88 2c 01 00 00    	js     80215a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202e:	83 ec 04             	sub    $0x4,%esp
  802031:	68 07 04 00 00       	push   $0x407
  802036:	ff 75 f4             	pushl  -0xc(%ebp)
  802039:	6a 00                	push   $0x0
  80203b:	e8 4f ec ff ff       	call   800c8f <sys_page_alloc>
  802040:	83 c4 10             	add    $0x10,%esp
  802043:	89 c2                	mov    %eax,%edx
  802045:	85 c0                	test   %eax,%eax
  802047:	0f 88 0d 01 00 00    	js     80215a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80204d:	83 ec 0c             	sub    $0xc,%esp
  802050:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802053:	50                   	push   %eax
  802054:	e8 96 f1 ff ff       	call   8011ef <fd_alloc>
  802059:	89 c3                	mov    %eax,%ebx
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	0f 88 e2 00 00 00    	js     802148 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802066:	83 ec 04             	sub    $0x4,%esp
  802069:	68 07 04 00 00       	push   $0x407
  80206e:	ff 75 f0             	pushl  -0x10(%ebp)
  802071:	6a 00                	push   $0x0
  802073:	e8 17 ec ff ff       	call   800c8f <sys_page_alloc>
  802078:	89 c3                	mov    %eax,%ebx
  80207a:	83 c4 10             	add    $0x10,%esp
  80207d:	85 c0                	test   %eax,%eax
  80207f:	0f 88 c3 00 00 00    	js     802148 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802085:	83 ec 0c             	sub    $0xc,%esp
  802088:	ff 75 f4             	pushl  -0xc(%ebp)
  80208b:	e8 48 f1 ff ff       	call   8011d8 <fd2data>
  802090:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802092:	83 c4 0c             	add    $0xc,%esp
  802095:	68 07 04 00 00       	push   $0x407
  80209a:	50                   	push   %eax
  80209b:	6a 00                	push   $0x0
  80209d:	e8 ed eb ff ff       	call   800c8f <sys_page_alloc>
  8020a2:	89 c3                	mov    %eax,%ebx
  8020a4:	83 c4 10             	add    $0x10,%esp
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	0f 88 89 00 00 00    	js     802138 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020af:	83 ec 0c             	sub    $0xc,%esp
  8020b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b5:	e8 1e f1 ff ff       	call   8011d8 <fd2data>
  8020ba:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020c1:	50                   	push   %eax
  8020c2:	6a 00                	push   $0x0
  8020c4:	56                   	push   %esi
  8020c5:	6a 00                	push   $0x0
  8020c7:	e8 06 ec ff ff       	call   800cd2 <sys_page_map>
  8020cc:	89 c3                	mov    %eax,%ebx
  8020ce:	83 c4 20             	add    $0x20,%esp
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	78 55                	js     80212a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020d5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020de:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020ea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020ff:	83 ec 0c             	sub    $0xc,%esp
  802102:	ff 75 f4             	pushl  -0xc(%ebp)
  802105:	e8 be f0 ff ff       	call   8011c8 <fd2num>
  80210a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80210d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80210f:	83 c4 04             	add    $0x4,%esp
  802112:	ff 75 f0             	pushl  -0x10(%ebp)
  802115:	e8 ae f0 ff ff       	call   8011c8 <fd2num>
  80211a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80211d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	ba 00 00 00 00       	mov    $0x0,%edx
  802128:	eb 30                	jmp    80215a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80212a:	83 ec 08             	sub    $0x8,%esp
  80212d:	56                   	push   %esi
  80212e:	6a 00                	push   $0x0
  802130:	e8 df eb ff ff       	call   800d14 <sys_page_unmap>
  802135:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802138:	83 ec 08             	sub    $0x8,%esp
  80213b:	ff 75 f0             	pushl  -0x10(%ebp)
  80213e:	6a 00                	push   $0x0
  802140:	e8 cf eb ff ff       	call   800d14 <sys_page_unmap>
  802145:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802148:	83 ec 08             	sub    $0x8,%esp
  80214b:	ff 75 f4             	pushl  -0xc(%ebp)
  80214e:	6a 00                	push   $0x0
  802150:	e8 bf eb ff ff       	call   800d14 <sys_page_unmap>
  802155:	83 c4 10             	add    $0x10,%esp
  802158:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5d                   	pop    %ebp
  802162:	c3                   	ret    

00802163 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802169:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80216c:	50                   	push   %eax
  80216d:	ff 75 08             	pushl  0x8(%ebp)
  802170:	e8 c9 f0 ff ff       	call   80123e <fd_lookup>
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	85 c0                	test   %eax,%eax
  80217a:	78 18                	js     802194 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80217c:	83 ec 0c             	sub    $0xc,%esp
  80217f:	ff 75 f4             	pushl  -0xc(%ebp)
  802182:	e8 51 f0 ff ff       	call   8011d8 <fd2data>
	return _pipeisclosed(fd, p);
  802187:	89 c2                	mov    %eax,%edx
  802189:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218c:	e8 21 fd ff ff       	call   801eb2 <_pipeisclosed>
  802191:	83 c4 10             	add    $0x10,%esp
}
  802194:	c9                   	leave  
  802195:	c3                   	ret    

00802196 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802196:	55                   	push   %ebp
  802197:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    

008021a0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021a6:	68 77 2e 80 00       	push   $0x802e77
  8021ab:	ff 75 0c             	pushl  0xc(%ebp)
  8021ae:	e8 d9 e6 ff ff       	call   80088c <strcpy>
	return 0;
}
  8021b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    

008021ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
  8021bd:	57                   	push   %edi
  8021be:	56                   	push   %esi
  8021bf:	53                   	push   %ebx
  8021c0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021c6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d1:	eb 2d                	jmp    802200 <devcons_write+0x46>
		m = n - tot;
  8021d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021d6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021d8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021db:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021e0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021e3:	83 ec 04             	sub    $0x4,%esp
  8021e6:	53                   	push   %ebx
  8021e7:	03 45 0c             	add    0xc(%ebp),%eax
  8021ea:	50                   	push   %eax
  8021eb:	57                   	push   %edi
  8021ec:	e8 2d e8 ff ff       	call   800a1e <memmove>
		sys_cputs(buf, m);
  8021f1:	83 c4 08             	add    $0x8,%esp
  8021f4:	53                   	push   %ebx
  8021f5:	57                   	push   %edi
  8021f6:	e8 d8 e9 ff ff       	call   800bd3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021fb:	01 de                	add    %ebx,%esi
  8021fd:	83 c4 10             	add    $0x10,%esp
  802200:	89 f0                	mov    %esi,%eax
  802202:	3b 75 10             	cmp    0x10(%ebp),%esi
  802205:	72 cc                	jb     8021d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80220a:	5b                   	pop    %ebx
  80220b:	5e                   	pop    %esi
  80220c:	5f                   	pop    %edi
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    

0080220f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	83 ec 08             	sub    $0x8,%esp
  802215:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80221a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80221e:	74 2a                	je     80224a <devcons_read+0x3b>
  802220:	eb 05                	jmp    802227 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802222:	e8 49 ea ff ff       	call   800c70 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802227:	e8 c5 e9 ff ff       	call   800bf1 <sys_cgetc>
  80222c:	85 c0                	test   %eax,%eax
  80222e:	74 f2                	je     802222 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802230:	85 c0                	test   %eax,%eax
  802232:	78 16                	js     80224a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802234:	83 f8 04             	cmp    $0x4,%eax
  802237:	74 0c                	je     802245 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80223c:	88 02                	mov    %al,(%edx)
	return 1;
  80223e:	b8 01 00 00 00       	mov    $0x1,%eax
  802243:	eb 05                	jmp    80224a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802245:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802252:	8b 45 08             	mov    0x8(%ebp),%eax
  802255:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802258:	6a 01                	push   $0x1
  80225a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80225d:	50                   	push   %eax
  80225e:	e8 70 e9 ff ff       	call   800bd3 <sys_cputs>
}
  802263:	83 c4 10             	add    $0x10,%esp
  802266:	c9                   	leave  
  802267:	c3                   	ret    

00802268 <getchar>:

int
getchar(void)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80226e:	6a 01                	push   $0x1
  802270:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802273:	50                   	push   %eax
  802274:	6a 00                	push   $0x0
  802276:	e8 29 f2 ff ff       	call   8014a4 <read>
	if (r < 0)
  80227b:	83 c4 10             	add    $0x10,%esp
  80227e:	85 c0                	test   %eax,%eax
  802280:	78 0f                	js     802291 <getchar+0x29>
		return r;
	if (r < 1)
  802282:	85 c0                	test   %eax,%eax
  802284:	7e 06                	jle    80228c <getchar+0x24>
		return -E_EOF;
	return c;
  802286:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80228a:	eb 05                	jmp    802291 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80228c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802291:	c9                   	leave  
  802292:	c3                   	ret    

00802293 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802293:	55                   	push   %ebp
  802294:	89 e5                	mov    %esp,%ebp
  802296:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802299:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229c:	50                   	push   %eax
  80229d:	ff 75 08             	pushl  0x8(%ebp)
  8022a0:	e8 99 ef ff ff       	call   80123e <fd_lookup>
  8022a5:	83 c4 10             	add    $0x10,%esp
  8022a8:	85 c0                	test   %eax,%eax
  8022aa:	78 11                	js     8022bd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022af:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022b5:	39 10                	cmp    %edx,(%eax)
  8022b7:	0f 94 c0             	sete   %al
  8022ba:	0f b6 c0             	movzbl %al,%eax
}
  8022bd:	c9                   	leave  
  8022be:	c3                   	ret    

008022bf <opencons>:

int
opencons(void)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c8:	50                   	push   %eax
  8022c9:	e8 21 ef ff ff       	call   8011ef <fd_alloc>
  8022ce:	83 c4 10             	add    $0x10,%esp
		return r;
  8022d1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022d3:	85 c0                	test   %eax,%eax
  8022d5:	78 3e                	js     802315 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d7:	83 ec 04             	sub    $0x4,%esp
  8022da:	68 07 04 00 00       	push   $0x407
  8022df:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e2:	6a 00                	push   $0x0
  8022e4:	e8 a6 e9 ff ff       	call   800c8f <sys_page_alloc>
  8022e9:	83 c4 10             	add    $0x10,%esp
		return r;
  8022ec:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	78 23                	js     802315 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022f2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802300:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802307:	83 ec 0c             	sub    $0xc,%esp
  80230a:	50                   	push   %eax
  80230b:	e8 b8 ee ff ff       	call   8011c8 <fd2num>
  802310:	89 c2                	mov    %eax,%edx
  802312:	83 c4 10             	add    $0x10,%esp
}
  802315:	89 d0                	mov    %edx,%eax
  802317:	c9                   	leave  
  802318:	c3                   	ret    

00802319 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802319:	55                   	push   %ebp
  80231a:	89 e5                	mov    %esp,%ebp
  80231c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80231f:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802326:	75 64                	jne    80238c <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  802328:	a1 08 40 80 00       	mov    0x804008,%eax
  80232d:	8b 40 48             	mov    0x48(%eax),%eax
  802330:	83 ec 04             	sub    $0x4,%esp
  802333:	6a 07                	push   $0x7
  802335:	68 00 f0 bf ee       	push   $0xeebff000
  80233a:	50                   	push   %eax
  80233b:	e8 4f e9 ff ff       	call   800c8f <sys_page_alloc>
		if ( r != 0)
  802340:	83 c4 10             	add    $0x10,%esp
  802343:	85 c0                	test   %eax,%eax
  802345:	74 14                	je     80235b <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  802347:	83 ec 04             	sub    $0x4,%esp
  80234a:	68 84 2e 80 00       	push   $0x802e84
  80234f:	6a 24                	push   $0x24
  802351:	68 d2 2e 80 00       	push   $0x802ed2
  802356:	e8 d3 de ff ff       	call   80022e <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  80235b:	a1 08 40 80 00       	mov    0x804008,%eax
  802360:	8b 40 48             	mov    0x48(%eax),%eax
  802363:	83 ec 08             	sub    $0x8,%esp
  802366:	68 96 23 80 00       	push   $0x802396
  80236b:	50                   	push   %eax
  80236c:	e8 69 ea ff ff       	call   800dda <sys_env_set_pgfault_upcall>
  802371:	83 c4 10             	add    $0x10,%esp
  802374:	85 c0                	test   %eax,%eax
  802376:	79 14                	jns    80238c <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  802378:	83 ec 04             	sub    $0x4,%esp
  80237b:	68 b0 2e 80 00       	push   $0x802eb0
  802380:	6a 27                	push   $0x27
  802382:	68 d2 2e 80 00       	push   $0x802ed2
  802387:	e8 a2 de ff ff       	call   80022e <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80238c:	8b 45 08             	mov    0x8(%ebp),%eax
  80238f:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802394:	c9                   	leave  
  802395:	c3                   	ret    

00802396 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802396:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802397:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80239c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80239e:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  8023a1:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  8023a5:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  8023a7:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  8023ab:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  8023ac:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  8023af:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  8023b1:	83 c4 08             	add    $0x8,%esp
popal
  8023b4:	61                   	popa   
addl $0x4, %esp
  8023b5:	83 c4 04             	add    $0x4,%esp
popfl
  8023b8:	9d                   	popf   
popl %esp
  8023b9:	5c                   	pop    %esp
ret
  8023ba:	c3                   	ret    

008023bb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023bb:	55                   	push   %ebp
  8023bc:	89 e5                	mov    %esp,%ebp
  8023be:	56                   	push   %esi
  8023bf:	53                   	push   %ebx
  8023c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8023c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  8023c9:	85 c0                	test   %eax,%eax
  8023cb:	74 0e                	je     8023db <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  8023cd:	83 ec 0c             	sub    $0xc,%esp
  8023d0:	50                   	push   %eax
  8023d1:	e8 69 ea ff ff       	call   800e3f <sys_ipc_recv>
  8023d6:	83 c4 10             	add    $0x10,%esp
  8023d9:	eb 10                	jmp    8023eb <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  8023db:	83 ec 0c             	sub    $0xc,%esp
  8023de:	68 00 00 00 f0       	push   $0xf0000000
  8023e3:	e8 57 ea ff ff       	call   800e3f <sys_ipc_recv>
  8023e8:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	74 16                	je     802405 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  8023ef:	85 db                	test   %ebx,%ebx
  8023f1:	74 36                	je     802429 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  8023f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  8023f9:	85 f6                	test   %esi,%esi
  8023fb:	74 2c                	je     802429 <ipc_recv+0x6e>
				*perm_store = 0;
  8023fd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802403:	eb 24                	jmp    802429 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  802405:	85 db                	test   %ebx,%ebx
  802407:	74 18                	je     802421 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  802409:	a1 08 40 80 00       	mov    0x804008,%eax
  80240e:	8b 40 74             	mov    0x74(%eax),%eax
  802411:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  802413:	85 f6                	test   %esi,%esi
  802415:	74 0a                	je     802421 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  802417:	a1 08 40 80 00       	mov    0x804008,%eax
  80241c:	8b 40 78             	mov    0x78(%eax),%eax
  80241f:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  802421:	a1 08 40 80 00       	mov    0x804008,%eax
  802426:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  802429:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80242c:	5b                   	pop    %ebx
  80242d:	5e                   	pop    %esi
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    

00802430 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802430:	55                   	push   %ebp
  802431:	89 e5                	mov    %esp,%ebp
  802433:	57                   	push   %edi
  802434:	56                   	push   %esi
  802435:	53                   	push   %ebx
  802436:	83 ec 0c             	sub    $0xc,%esp
  802439:	8b 7d 08             	mov    0x8(%ebp),%edi
  80243c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  80243f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802443:	75 39                	jne    80247e <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  802445:	6a 00                	push   $0x0
  802447:	68 00 00 00 f0       	push   $0xf0000000
  80244c:	56                   	push   %esi
  80244d:	57                   	push   %edi
  80244e:	e8 c9 e9 ff ff       	call   800e1c <sys_ipc_try_send>
  802453:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  802455:	83 c4 10             	add    $0x10,%esp
  802458:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80245b:	74 16                	je     802473 <ipc_send+0x43>
  80245d:	85 c0                	test   %eax,%eax
  80245f:	74 12                	je     802473 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802461:	50                   	push   %eax
  802462:	68 e0 2e 80 00       	push   $0x802ee0
  802467:	6a 4f                	push   $0x4f
  802469:	68 18 2f 80 00       	push   $0x802f18
  80246e:	e8 bb dd ff ff       	call   80022e <_panic>
			sys_yield();
  802473:	e8 f8 e7 ff ff       	call   800c70 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  802478:	85 db                	test   %ebx,%ebx
  80247a:	75 c9                	jne    802445 <ipc_send+0x15>
  80247c:	eb 36                	jmp    8024b4 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  80247e:	ff 75 14             	pushl  0x14(%ebp)
  802481:	ff 75 10             	pushl  0x10(%ebp)
  802484:	56                   	push   %esi
  802485:	57                   	push   %edi
  802486:	e8 91 e9 ff ff       	call   800e1c <sys_ipc_try_send>
  80248b:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  80248d:	83 c4 10             	add    $0x10,%esp
  802490:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802493:	74 16                	je     8024ab <ipc_send+0x7b>
  802495:	85 c0                	test   %eax,%eax
  802497:	74 12                	je     8024ab <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  802499:	50                   	push   %eax
  80249a:	68 e0 2e 80 00       	push   $0x802ee0
  80249f:	6a 5a                	push   $0x5a
  8024a1:	68 18 2f 80 00       	push   $0x802f18
  8024a6:	e8 83 dd ff ff       	call   80022e <_panic>
			sys_yield();
  8024ab:	e8 c0 e7 ff ff       	call   800c70 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  8024b0:	85 db                	test   %ebx,%ebx
  8024b2:	75 ca                	jne    80247e <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  8024b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024b7:	5b                   	pop    %ebx
  8024b8:	5e                   	pop    %esi
  8024b9:	5f                   	pop    %edi
  8024ba:	5d                   	pop    %ebp
  8024bb:	c3                   	ret    

008024bc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024bc:	55                   	push   %ebp
  8024bd:	89 e5                	mov    %esp,%ebp
  8024bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024c7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024d0:	8b 52 50             	mov    0x50(%edx),%edx
  8024d3:	39 ca                	cmp    %ecx,%edx
  8024d5:	75 0d                	jne    8024e4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8024d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024df:	8b 40 48             	mov    0x48(%eax),%eax
  8024e2:	eb 0f                	jmp    8024f3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024e4:	83 c0 01             	add    $0x1,%eax
  8024e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024ec:	75 d9                	jne    8024c7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    

008024f5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024f5:	55                   	push   %ebp
  8024f6:	89 e5                	mov    %esp,%ebp
  8024f8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024fb:	89 d0                	mov    %edx,%eax
  8024fd:	c1 e8 16             	shr    $0x16,%eax
  802500:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802507:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80250c:	f6 c1 01             	test   $0x1,%cl
  80250f:	74 1d                	je     80252e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802511:	c1 ea 0c             	shr    $0xc,%edx
  802514:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80251b:	f6 c2 01             	test   $0x1,%dl
  80251e:	74 0e                	je     80252e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802520:	c1 ea 0c             	shr    $0xc,%edx
  802523:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80252a:	ef 
  80252b:	0f b7 c0             	movzwl %ax,%eax
}
  80252e:	5d                   	pop    %ebp
  80252f:	c3                   	ret    

00802530 <__udivdi3>:
  802530:	55                   	push   %ebp
  802531:	57                   	push   %edi
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	83 ec 1c             	sub    $0x1c,%esp
  802537:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80253b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80253f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802543:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802547:	85 f6                	test   %esi,%esi
  802549:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80254d:	89 ca                	mov    %ecx,%edx
  80254f:	89 f8                	mov    %edi,%eax
  802551:	75 3d                	jne    802590 <__udivdi3+0x60>
  802553:	39 cf                	cmp    %ecx,%edi
  802555:	0f 87 c5 00 00 00    	ja     802620 <__udivdi3+0xf0>
  80255b:	85 ff                	test   %edi,%edi
  80255d:	89 fd                	mov    %edi,%ebp
  80255f:	75 0b                	jne    80256c <__udivdi3+0x3c>
  802561:	b8 01 00 00 00       	mov    $0x1,%eax
  802566:	31 d2                	xor    %edx,%edx
  802568:	f7 f7                	div    %edi
  80256a:	89 c5                	mov    %eax,%ebp
  80256c:	89 c8                	mov    %ecx,%eax
  80256e:	31 d2                	xor    %edx,%edx
  802570:	f7 f5                	div    %ebp
  802572:	89 c1                	mov    %eax,%ecx
  802574:	89 d8                	mov    %ebx,%eax
  802576:	89 cf                	mov    %ecx,%edi
  802578:	f7 f5                	div    %ebp
  80257a:	89 c3                	mov    %eax,%ebx
  80257c:	89 d8                	mov    %ebx,%eax
  80257e:	89 fa                	mov    %edi,%edx
  802580:	83 c4 1c             	add    $0x1c,%esp
  802583:	5b                   	pop    %ebx
  802584:	5e                   	pop    %esi
  802585:	5f                   	pop    %edi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    
  802588:	90                   	nop
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	39 ce                	cmp    %ecx,%esi
  802592:	77 74                	ja     802608 <__udivdi3+0xd8>
  802594:	0f bd fe             	bsr    %esi,%edi
  802597:	83 f7 1f             	xor    $0x1f,%edi
  80259a:	0f 84 98 00 00 00    	je     802638 <__udivdi3+0x108>
  8025a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025a5:	89 f9                	mov    %edi,%ecx
  8025a7:	89 c5                	mov    %eax,%ebp
  8025a9:	29 fb                	sub    %edi,%ebx
  8025ab:	d3 e6                	shl    %cl,%esi
  8025ad:	89 d9                	mov    %ebx,%ecx
  8025af:	d3 ed                	shr    %cl,%ebp
  8025b1:	89 f9                	mov    %edi,%ecx
  8025b3:	d3 e0                	shl    %cl,%eax
  8025b5:	09 ee                	or     %ebp,%esi
  8025b7:	89 d9                	mov    %ebx,%ecx
  8025b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025bd:	89 d5                	mov    %edx,%ebp
  8025bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025c3:	d3 ed                	shr    %cl,%ebp
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	d3 e2                	shl    %cl,%edx
  8025c9:	89 d9                	mov    %ebx,%ecx
  8025cb:	d3 e8                	shr    %cl,%eax
  8025cd:	09 c2                	or     %eax,%edx
  8025cf:	89 d0                	mov    %edx,%eax
  8025d1:	89 ea                	mov    %ebp,%edx
  8025d3:	f7 f6                	div    %esi
  8025d5:	89 d5                	mov    %edx,%ebp
  8025d7:	89 c3                	mov    %eax,%ebx
  8025d9:	f7 64 24 0c          	mull   0xc(%esp)
  8025dd:	39 d5                	cmp    %edx,%ebp
  8025df:	72 10                	jb     8025f1 <__udivdi3+0xc1>
  8025e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	d3 e6                	shl    %cl,%esi
  8025e9:	39 c6                	cmp    %eax,%esi
  8025eb:	73 07                	jae    8025f4 <__udivdi3+0xc4>
  8025ed:	39 d5                	cmp    %edx,%ebp
  8025ef:	75 03                	jne    8025f4 <__udivdi3+0xc4>
  8025f1:	83 eb 01             	sub    $0x1,%ebx
  8025f4:	31 ff                	xor    %edi,%edi
  8025f6:	89 d8                	mov    %ebx,%eax
  8025f8:	89 fa                	mov    %edi,%edx
  8025fa:	83 c4 1c             	add    $0x1c,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
  802602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802608:	31 ff                	xor    %edi,%edi
  80260a:	31 db                	xor    %ebx,%ebx
  80260c:	89 d8                	mov    %ebx,%eax
  80260e:	89 fa                	mov    %edi,%edx
  802610:	83 c4 1c             	add    $0x1c,%esp
  802613:	5b                   	pop    %ebx
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    
  802618:	90                   	nop
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	89 d8                	mov    %ebx,%eax
  802622:	f7 f7                	div    %edi
  802624:	31 ff                	xor    %edi,%edi
  802626:	89 c3                	mov    %eax,%ebx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 fa                	mov    %edi,%edx
  80262c:	83 c4 1c             	add    $0x1c,%esp
  80262f:	5b                   	pop    %ebx
  802630:	5e                   	pop    %esi
  802631:	5f                   	pop    %edi
  802632:	5d                   	pop    %ebp
  802633:	c3                   	ret    
  802634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802638:	39 ce                	cmp    %ecx,%esi
  80263a:	72 0c                	jb     802648 <__udivdi3+0x118>
  80263c:	31 db                	xor    %ebx,%ebx
  80263e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802642:	0f 87 34 ff ff ff    	ja     80257c <__udivdi3+0x4c>
  802648:	bb 01 00 00 00       	mov    $0x1,%ebx
  80264d:	e9 2a ff ff ff       	jmp    80257c <__udivdi3+0x4c>
  802652:	66 90                	xchg   %ax,%ax
  802654:	66 90                	xchg   %ax,%ax
  802656:	66 90                	xchg   %ax,%ax
  802658:	66 90                	xchg   %ax,%ax
  80265a:	66 90                	xchg   %ax,%ax
  80265c:	66 90                	xchg   %ax,%ax
  80265e:	66 90                	xchg   %ax,%ax

00802660 <__umoddi3>:
  802660:	55                   	push   %ebp
  802661:	57                   	push   %edi
  802662:	56                   	push   %esi
  802663:	53                   	push   %ebx
  802664:	83 ec 1c             	sub    $0x1c,%esp
  802667:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80266b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80266f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802673:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802677:	85 d2                	test   %edx,%edx
  802679:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80267d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802681:	89 f3                	mov    %esi,%ebx
  802683:	89 3c 24             	mov    %edi,(%esp)
  802686:	89 74 24 04          	mov    %esi,0x4(%esp)
  80268a:	75 1c                	jne    8026a8 <__umoddi3+0x48>
  80268c:	39 f7                	cmp    %esi,%edi
  80268e:	76 50                	jbe    8026e0 <__umoddi3+0x80>
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 f2                	mov    %esi,%edx
  802694:	f7 f7                	div    %edi
  802696:	89 d0                	mov    %edx,%eax
  802698:	31 d2                	xor    %edx,%edx
  80269a:	83 c4 1c             	add    $0x1c,%esp
  80269d:	5b                   	pop    %ebx
  80269e:	5e                   	pop    %esi
  80269f:	5f                   	pop    %edi
  8026a0:	5d                   	pop    %ebp
  8026a1:	c3                   	ret    
  8026a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026a8:	39 f2                	cmp    %esi,%edx
  8026aa:	89 d0                	mov    %edx,%eax
  8026ac:	77 52                	ja     802700 <__umoddi3+0xa0>
  8026ae:	0f bd ea             	bsr    %edx,%ebp
  8026b1:	83 f5 1f             	xor    $0x1f,%ebp
  8026b4:	75 5a                	jne    802710 <__umoddi3+0xb0>
  8026b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026ba:	0f 82 e0 00 00 00    	jb     8027a0 <__umoddi3+0x140>
  8026c0:	39 0c 24             	cmp    %ecx,(%esp)
  8026c3:	0f 86 d7 00 00 00    	jbe    8027a0 <__umoddi3+0x140>
  8026c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026d1:	83 c4 1c             	add    $0x1c,%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5e                   	pop    %esi
  8026d6:	5f                   	pop    %edi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    
  8026d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	85 ff                	test   %edi,%edi
  8026e2:	89 fd                	mov    %edi,%ebp
  8026e4:	75 0b                	jne    8026f1 <__umoddi3+0x91>
  8026e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026eb:	31 d2                	xor    %edx,%edx
  8026ed:	f7 f7                	div    %edi
  8026ef:	89 c5                	mov    %eax,%ebp
  8026f1:	89 f0                	mov    %esi,%eax
  8026f3:	31 d2                	xor    %edx,%edx
  8026f5:	f7 f5                	div    %ebp
  8026f7:	89 c8                	mov    %ecx,%eax
  8026f9:	f7 f5                	div    %ebp
  8026fb:	89 d0                	mov    %edx,%eax
  8026fd:	eb 99                	jmp    802698 <__umoddi3+0x38>
  8026ff:	90                   	nop
  802700:	89 c8                	mov    %ecx,%eax
  802702:	89 f2                	mov    %esi,%edx
  802704:	83 c4 1c             	add    $0x1c,%esp
  802707:	5b                   	pop    %ebx
  802708:	5e                   	pop    %esi
  802709:	5f                   	pop    %edi
  80270a:	5d                   	pop    %ebp
  80270b:	c3                   	ret    
  80270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802710:	8b 34 24             	mov    (%esp),%esi
  802713:	bf 20 00 00 00       	mov    $0x20,%edi
  802718:	89 e9                	mov    %ebp,%ecx
  80271a:	29 ef                	sub    %ebp,%edi
  80271c:	d3 e0                	shl    %cl,%eax
  80271e:	89 f9                	mov    %edi,%ecx
  802720:	89 f2                	mov    %esi,%edx
  802722:	d3 ea                	shr    %cl,%edx
  802724:	89 e9                	mov    %ebp,%ecx
  802726:	09 c2                	or     %eax,%edx
  802728:	89 d8                	mov    %ebx,%eax
  80272a:	89 14 24             	mov    %edx,(%esp)
  80272d:	89 f2                	mov    %esi,%edx
  80272f:	d3 e2                	shl    %cl,%edx
  802731:	89 f9                	mov    %edi,%ecx
  802733:	89 54 24 04          	mov    %edx,0x4(%esp)
  802737:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80273b:	d3 e8                	shr    %cl,%eax
  80273d:	89 e9                	mov    %ebp,%ecx
  80273f:	89 c6                	mov    %eax,%esi
  802741:	d3 e3                	shl    %cl,%ebx
  802743:	89 f9                	mov    %edi,%ecx
  802745:	89 d0                	mov    %edx,%eax
  802747:	d3 e8                	shr    %cl,%eax
  802749:	89 e9                	mov    %ebp,%ecx
  80274b:	09 d8                	or     %ebx,%eax
  80274d:	89 d3                	mov    %edx,%ebx
  80274f:	89 f2                	mov    %esi,%edx
  802751:	f7 34 24             	divl   (%esp)
  802754:	89 d6                	mov    %edx,%esi
  802756:	d3 e3                	shl    %cl,%ebx
  802758:	f7 64 24 04          	mull   0x4(%esp)
  80275c:	39 d6                	cmp    %edx,%esi
  80275e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802762:	89 d1                	mov    %edx,%ecx
  802764:	89 c3                	mov    %eax,%ebx
  802766:	72 08                	jb     802770 <__umoddi3+0x110>
  802768:	75 11                	jne    80277b <__umoddi3+0x11b>
  80276a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80276e:	73 0b                	jae    80277b <__umoddi3+0x11b>
  802770:	2b 44 24 04          	sub    0x4(%esp),%eax
  802774:	1b 14 24             	sbb    (%esp),%edx
  802777:	89 d1                	mov    %edx,%ecx
  802779:	89 c3                	mov    %eax,%ebx
  80277b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80277f:	29 da                	sub    %ebx,%edx
  802781:	19 ce                	sbb    %ecx,%esi
  802783:	89 f9                	mov    %edi,%ecx
  802785:	89 f0                	mov    %esi,%eax
  802787:	d3 e0                	shl    %cl,%eax
  802789:	89 e9                	mov    %ebp,%ecx
  80278b:	d3 ea                	shr    %cl,%edx
  80278d:	89 e9                	mov    %ebp,%ecx
  80278f:	d3 ee                	shr    %cl,%esi
  802791:	09 d0                	or     %edx,%eax
  802793:	89 f2                	mov    %esi,%edx
  802795:	83 c4 1c             	add    $0x1c,%esp
  802798:	5b                   	pop    %ebx
  802799:	5e                   	pop    %esi
  80279a:	5f                   	pop    %edi
  80279b:	5d                   	pop    %ebp
  80279c:	c3                   	ret    
  80279d:	8d 76 00             	lea    0x0(%esi),%esi
  8027a0:	29 f9                	sub    %edi,%ecx
  8027a2:	19 d6                	sbb    %edx,%esi
  8027a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ac:	e9 18 ff ff ff       	jmp    8026c9 <__umoddi3+0x69>
