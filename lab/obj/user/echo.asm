
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
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
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 00 23 80 00       	push   $0x802300
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 bb 01 00 00       	call   800219 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 03 23 80 00       	push   $0x802303
  80008f:	6a 01                	push   $0x1
  800091:	e8 a2 0a 00 00       	call   800b38 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 92 00 00 00       	call   800136 <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 86 0a 00 00       	call   800b38 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 50 24 80 00       	push   $0x802450
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 65 0a 00 00       	call   800b38 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  8000e9:	e8 46 04 00 00       	call   800534 <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80012a:	6a 00                	push   $0x0
  80012c:	e8 c2 03 00 00       	call   8004f3 <sys_env_destroy>
}
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	c9                   	leave  
  800135:	c3                   	ret    

00800136 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80013c:	b8 00 00 00 00       	mov    $0x0,%eax
  800141:	eb 03                	jmp    800146 <strlen+0x10>
		n++;
  800143:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800146:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80014a:	75 f7                	jne    800143 <strlen+0xd>
		n++;
	return n;
}
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800154:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	eb 03                	jmp    800161 <strnlen+0x13>
		n++;
  80015e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800161:	39 c2                	cmp    %eax,%edx
  800163:	74 08                	je     80016d <strnlen+0x1f>
  800165:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800169:	75 f3                	jne    80015e <strnlen+0x10>
  80016b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	53                   	push   %ebx
  800173:	8b 45 08             	mov    0x8(%ebp),%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800179:	89 c2                	mov    %eax,%edx
  80017b:	83 c2 01             	add    $0x1,%edx
  80017e:	83 c1 01             	add    $0x1,%ecx
  800181:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800185:	88 5a ff             	mov    %bl,-0x1(%edx)
  800188:	84 db                	test   %bl,%bl
  80018a:	75 ef                	jne    80017b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80018c:	5b                   	pop    %ebx
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	53                   	push   %ebx
  800193:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800196:	53                   	push   %ebx
  800197:	e8 9a ff ff ff       	call   800136 <strlen>
  80019c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80019f:	ff 75 0c             	pushl  0xc(%ebp)
  8001a2:	01 d8                	add    %ebx,%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 c5 ff ff ff       	call   80016f <strcpy>
	return dst;
}
  8001aa:	89 d8                	mov    %ebx,%eax
  8001ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	89 f3                	mov    %esi,%ebx
  8001be:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c1:	89 f2                	mov    %esi,%edx
  8001c3:	eb 0f                	jmp    8001d4 <strncpy+0x23>
		*dst++ = *src;
  8001c5:	83 c2 01             	add    $0x1,%edx
  8001c8:	0f b6 01             	movzbl (%ecx),%eax
  8001cb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001ce:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001d4:	39 da                	cmp    %ebx,%edx
  8001d6:	75 ed                	jne    8001c5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001d8:	89 f0                	mov    %esi,%eax
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    

008001de <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8001e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e9:	8b 55 10             	mov    0x10(%ebp),%edx
  8001ec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001ee:	85 d2                	test   %edx,%edx
  8001f0:	74 21                	je     800213 <strlcpy+0x35>
  8001f2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001f6:	89 f2                	mov    %esi,%edx
  8001f8:	eb 09                	jmp    800203 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8001fa:	83 c2 01             	add    $0x1,%edx
  8001fd:	83 c1 01             	add    $0x1,%ecx
  800200:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800203:	39 c2                	cmp    %eax,%edx
  800205:	74 09                	je     800210 <strlcpy+0x32>
  800207:	0f b6 19             	movzbl (%ecx),%ebx
  80020a:	84 db                	test   %bl,%bl
  80020c:	75 ec                	jne    8001fa <strlcpy+0x1c>
  80020e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800210:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800213:	29 f0                	sub    %esi,%eax
}
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80021f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800222:	eb 06                	jmp    80022a <strcmp+0x11>
		p++, q++;
  800224:	83 c1 01             	add    $0x1,%ecx
  800227:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80022a:	0f b6 01             	movzbl (%ecx),%eax
  80022d:	84 c0                	test   %al,%al
  80022f:	74 04                	je     800235 <strcmp+0x1c>
  800231:	3a 02                	cmp    (%edx),%al
  800233:	74 ef                	je     800224 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800235:	0f b6 c0             	movzbl %al,%eax
  800238:	0f b6 12             	movzbl (%edx),%edx
  80023b:	29 d0                	sub    %edx,%eax
}
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    

0080023f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	53                   	push   %ebx
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 c3                	mov    %eax,%ebx
  80024b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80024e:	eb 06                	jmp    800256 <strncmp+0x17>
		n--, p++, q++;
  800250:	83 c0 01             	add    $0x1,%eax
  800253:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800256:	39 d8                	cmp    %ebx,%eax
  800258:	74 15                	je     80026f <strncmp+0x30>
  80025a:	0f b6 08             	movzbl (%eax),%ecx
  80025d:	84 c9                	test   %cl,%cl
  80025f:	74 04                	je     800265 <strncmp+0x26>
  800261:	3a 0a                	cmp    (%edx),%cl
  800263:	74 eb                	je     800250 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800265:	0f b6 00             	movzbl (%eax),%eax
  800268:	0f b6 12             	movzbl (%edx),%edx
  80026b:	29 d0                	sub    %edx,%eax
  80026d:	eb 05                	jmp    800274 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80026f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800274:	5b                   	pop    %ebx
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800281:	eb 07                	jmp    80028a <strchr+0x13>
		if (*s == c)
  800283:	38 ca                	cmp    %cl,%dl
  800285:	74 0f                	je     800296 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800287:	83 c0 01             	add    $0x1,%eax
  80028a:	0f b6 10             	movzbl (%eax),%edx
  80028d:	84 d2                	test   %dl,%dl
  80028f:	75 f2                	jne    800283 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800291:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	8b 45 08             	mov    0x8(%ebp),%eax
  80029e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002a2:	eb 03                	jmp    8002a7 <strfind+0xf>
  8002a4:	83 c0 01             	add    $0x1,%eax
  8002a7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002aa:	38 ca                	cmp    %cl,%dl
  8002ac:	74 04                	je     8002b2 <strfind+0x1a>
  8002ae:	84 d2                	test   %dl,%dl
  8002b0:	75 f2                	jne    8002a4 <strfind+0xc>
			break;
	return (char *) s;
}
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c0:	85 c9                	test   %ecx,%ecx
  8002c2:	74 36                	je     8002fa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002ca:	75 28                	jne    8002f4 <memset+0x40>
  8002cc:	f6 c1 03             	test   $0x3,%cl
  8002cf:	75 23                	jne    8002f4 <memset+0x40>
		c &= 0xFF;
  8002d1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002d5:	89 d3                	mov    %edx,%ebx
  8002d7:	c1 e3 08             	shl    $0x8,%ebx
  8002da:	89 d6                	mov    %edx,%esi
  8002dc:	c1 e6 18             	shl    $0x18,%esi
  8002df:	89 d0                	mov    %edx,%eax
  8002e1:	c1 e0 10             	shl    $0x10,%eax
  8002e4:	09 f0                	or     %esi,%eax
  8002e6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8002e8:	89 d8                	mov    %ebx,%eax
  8002ea:	09 d0                	or     %edx,%eax
  8002ec:	c1 e9 02             	shr    $0x2,%ecx
  8002ef:	fc                   	cld    
  8002f0:	f3 ab                	rep stos %eax,%es:(%edi)
  8002f2:	eb 06                	jmp    8002fa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	fc                   	cld    
  8002f8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8002fa:	89 f8                	mov    %edi,%eax
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	57                   	push   %edi
  800305:	56                   	push   %esi
  800306:	8b 45 08             	mov    0x8(%ebp),%eax
  800309:	8b 75 0c             	mov    0xc(%ebp),%esi
  80030c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80030f:	39 c6                	cmp    %eax,%esi
  800311:	73 35                	jae    800348 <memmove+0x47>
  800313:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800316:	39 d0                	cmp    %edx,%eax
  800318:	73 2e                	jae    800348 <memmove+0x47>
		s += n;
		d += n;
  80031a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80031d:	89 d6                	mov    %edx,%esi
  80031f:	09 fe                	or     %edi,%esi
  800321:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800327:	75 13                	jne    80033c <memmove+0x3b>
  800329:	f6 c1 03             	test   $0x3,%cl
  80032c:	75 0e                	jne    80033c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80032e:	83 ef 04             	sub    $0x4,%edi
  800331:	8d 72 fc             	lea    -0x4(%edx),%esi
  800334:	c1 e9 02             	shr    $0x2,%ecx
  800337:	fd                   	std    
  800338:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80033a:	eb 09                	jmp    800345 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80033c:	83 ef 01             	sub    $0x1,%edi
  80033f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800342:	fd                   	std    
  800343:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800345:	fc                   	cld    
  800346:	eb 1d                	jmp    800365 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800348:	89 f2                	mov    %esi,%edx
  80034a:	09 c2                	or     %eax,%edx
  80034c:	f6 c2 03             	test   $0x3,%dl
  80034f:	75 0f                	jne    800360 <memmove+0x5f>
  800351:	f6 c1 03             	test   $0x3,%cl
  800354:	75 0a                	jne    800360 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800356:	c1 e9 02             	shr    $0x2,%ecx
  800359:	89 c7                	mov    %eax,%edi
  80035b:	fc                   	cld    
  80035c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80035e:	eb 05                	jmp    800365 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800360:	89 c7                	mov    %eax,%edi
  800362:	fc                   	cld    
  800363:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800365:	5e                   	pop    %esi
  800366:	5f                   	pop    %edi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80036c:	ff 75 10             	pushl  0x10(%ebp)
  80036f:	ff 75 0c             	pushl  0xc(%ebp)
  800372:	ff 75 08             	pushl  0x8(%ebp)
  800375:	e8 87 ff ff ff       	call   800301 <memmove>
}
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	56                   	push   %esi
  800380:	53                   	push   %ebx
  800381:	8b 45 08             	mov    0x8(%ebp),%eax
  800384:	8b 55 0c             	mov    0xc(%ebp),%edx
  800387:	89 c6                	mov    %eax,%esi
  800389:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80038c:	eb 1a                	jmp    8003a8 <memcmp+0x2c>
		if (*s1 != *s2)
  80038e:	0f b6 08             	movzbl (%eax),%ecx
  800391:	0f b6 1a             	movzbl (%edx),%ebx
  800394:	38 d9                	cmp    %bl,%cl
  800396:	74 0a                	je     8003a2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800398:	0f b6 c1             	movzbl %cl,%eax
  80039b:	0f b6 db             	movzbl %bl,%ebx
  80039e:	29 d8                	sub    %ebx,%eax
  8003a0:	eb 0f                	jmp    8003b1 <memcmp+0x35>
		s1++, s2++;
  8003a2:	83 c0 01             	add    $0x1,%eax
  8003a5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003a8:	39 f0                	cmp    %esi,%eax
  8003aa:	75 e2                	jne    80038e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b1:	5b                   	pop    %ebx
  8003b2:	5e                   	pop    %esi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	53                   	push   %ebx
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003bc:	89 c1                	mov    %eax,%ecx
  8003be:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003c1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003c5:	eb 0a                	jmp    8003d1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003c7:	0f b6 10             	movzbl (%eax),%edx
  8003ca:	39 da                	cmp    %ebx,%edx
  8003cc:	74 07                	je     8003d5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003ce:	83 c0 01             	add    $0x1,%eax
  8003d1:	39 c8                	cmp    %ecx,%eax
  8003d3:	72 f2                	jb     8003c7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003d5:	5b                   	pop    %ebx
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	57                   	push   %edi
  8003dc:	56                   	push   %esi
  8003dd:	53                   	push   %ebx
  8003de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003e4:	eb 03                	jmp    8003e9 <strtol+0x11>
		s++;
  8003e6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003e9:	0f b6 01             	movzbl (%ecx),%eax
  8003ec:	3c 20                	cmp    $0x20,%al
  8003ee:	74 f6                	je     8003e6 <strtol+0xe>
  8003f0:	3c 09                	cmp    $0x9,%al
  8003f2:	74 f2                	je     8003e6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003f4:	3c 2b                	cmp    $0x2b,%al
  8003f6:	75 0a                	jne    800402 <strtol+0x2a>
		s++;
  8003f8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8003fb:	bf 00 00 00 00       	mov    $0x0,%edi
  800400:	eb 11                	jmp    800413 <strtol+0x3b>
  800402:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800407:	3c 2d                	cmp    $0x2d,%al
  800409:	75 08                	jne    800413 <strtol+0x3b>
		s++, neg = 1;
  80040b:	83 c1 01             	add    $0x1,%ecx
  80040e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800413:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800419:	75 15                	jne    800430 <strtol+0x58>
  80041b:	80 39 30             	cmpb   $0x30,(%ecx)
  80041e:	75 10                	jne    800430 <strtol+0x58>
  800420:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800424:	75 7c                	jne    8004a2 <strtol+0xca>
		s += 2, base = 16;
  800426:	83 c1 02             	add    $0x2,%ecx
  800429:	bb 10 00 00 00       	mov    $0x10,%ebx
  80042e:	eb 16                	jmp    800446 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800430:	85 db                	test   %ebx,%ebx
  800432:	75 12                	jne    800446 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800434:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800439:	80 39 30             	cmpb   $0x30,(%ecx)
  80043c:	75 08                	jne    800446 <strtol+0x6e>
		s++, base = 8;
  80043e:	83 c1 01             	add    $0x1,%ecx
  800441:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800446:	b8 00 00 00 00       	mov    $0x0,%eax
  80044b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80044e:	0f b6 11             	movzbl (%ecx),%edx
  800451:	8d 72 d0             	lea    -0x30(%edx),%esi
  800454:	89 f3                	mov    %esi,%ebx
  800456:	80 fb 09             	cmp    $0x9,%bl
  800459:	77 08                	ja     800463 <strtol+0x8b>
			dig = *s - '0';
  80045b:	0f be d2             	movsbl %dl,%edx
  80045e:	83 ea 30             	sub    $0x30,%edx
  800461:	eb 22                	jmp    800485 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800463:	8d 72 9f             	lea    -0x61(%edx),%esi
  800466:	89 f3                	mov    %esi,%ebx
  800468:	80 fb 19             	cmp    $0x19,%bl
  80046b:	77 08                	ja     800475 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80046d:	0f be d2             	movsbl %dl,%edx
  800470:	83 ea 57             	sub    $0x57,%edx
  800473:	eb 10                	jmp    800485 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800475:	8d 72 bf             	lea    -0x41(%edx),%esi
  800478:	89 f3                	mov    %esi,%ebx
  80047a:	80 fb 19             	cmp    $0x19,%bl
  80047d:	77 16                	ja     800495 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80047f:	0f be d2             	movsbl %dl,%edx
  800482:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800485:	3b 55 10             	cmp    0x10(%ebp),%edx
  800488:	7d 0b                	jge    800495 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80048a:	83 c1 01             	add    $0x1,%ecx
  80048d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800491:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800493:	eb b9                	jmp    80044e <strtol+0x76>

	if (endptr)
  800495:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800499:	74 0d                	je     8004a8 <strtol+0xd0>
		*endptr = (char *) s;
  80049b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80049e:	89 0e                	mov    %ecx,(%esi)
  8004a0:	eb 06                	jmp    8004a8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004a2:	85 db                	test   %ebx,%ebx
  8004a4:	74 98                	je     80043e <strtol+0x66>
  8004a6:	eb 9e                	jmp    800446 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004a8:	89 c2                	mov    %eax,%edx
  8004aa:	f7 da                	neg    %edx
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	0f 45 c2             	cmovne %edx,%eax
}
  8004b1:	5b                   	pop    %ebx
  8004b2:	5e                   	pop    %esi
  8004b3:	5f                   	pop    %edi
  8004b4:	5d                   	pop    %ebp
  8004b5:	c3                   	ret    

008004b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	57                   	push   %edi
  8004ba:	56                   	push   %esi
  8004bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c7:	89 c3                	mov    %eax,%ebx
  8004c9:	89 c7                	mov    %eax,%edi
  8004cb:	89 c6                	mov    %eax,%esi
  8004cd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004cf:	5b                   	pop    %ebx
  8004d0:	5e                   	pop    %esi
  8004d1:	5f                   	pop    %edi
  8004d2:	5d                   	pop    %ebp
  8004d3:	c3                   	ret    

008004d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	57                   	push   %edi
  8004d8:	56                   	push   %esi
  8004d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	b8 01 00 00 00       	mov    $0x1,%eax
  8004e4:	89 d1                	mov    %edx,%ecx
  8004e6:	89 d3                	mov    %edx,%ebx
  8004e8:	89 d7                	mov    %edx,%edi
  8004ea:	89 d6                	mov    %edx,%esi
  8004ec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004ee:	5b                   	pop    %ebx
  8004ef:	5e                   	pop    %esi
  8004f0:	5f                   	pop    %edi
  8004f1:	5d                   	pop    %ebp
  8004f2:	c3                   	ret    

008004f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	57                   	push   %edi
  8004f7:	56                   	push   %esi
  8004f8:	53                   	push   %ebx
  8004f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800501:	b8 03 00 00 00       	mov    $0x3,%eax
  800506:	8b 55 08             	mov    0x8(%ebp),%edx
  800509:	89 cb                	mov    %ecx,%ebx
  80050b:	89 cf                	mov    %ecx,%edi
  80050d:	89 ce                	mov    %ecx,%esi
  80050f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800511:	85 c0                	test   %eax,%eax
  800513:	7e 17                	jle    80052c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800515:	83 ec 0c             	sub    $0xc,%esp
  800518:	50                   	push   %eax
  800519:	6a 03                	push   $0x3
  80051b:	68 0f 23 80 00       	push   $0x80230f
  800520:	6a 23                	push   $0x23
  800522:	68 2c 23 80 00       	push   $0x80232c
  800527:	e8 a7 13 00 00       	call   8018d3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80052c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80052f:	5b                   	pop    %ebx
  800530:	5e                   	pop    %esi
  800531:	5f                   	pop    %edi
  800532:	5d                   	pop    %ebp
  800533:	c3                   	ret    

00800534 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80053a:	ba 00 00 00 00       	mov    $0x0,%edx
  80053f:	b8 02 00 00 00       	mov    $0x2,%eax
  800544:	89 d1                	mov    %edx,%ecx
  800546:	89 d3                	mov    %edx,%ebx
  800548:	89 d7                	mov    %edx,%edi
  80054a:	89 d6                	mov    %edx,%esi
  80054c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80054e:	5b                   	pop    %ebx
  80054f:	5e                   	pop    %esi
  800550:	5f                   	pop    %edi
  800551:	5d                   	pop    %ebp
  800552:	c3                   	ret    

00800553 <sys_yield>:

void
sys_yield(void)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	57                   	push   %edi
  800557:	56                   	push   %esi
  800558:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800559:	ba 00 00 00 00       	mov    $0x0,%edx
  80055e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800563:	89 d1                	mov    %edx,%ecx
  800565:	89 d3                	mov    %edx,%ebx
  800567:	89 d7                	mov    %edx,%edi
  800569:	89 d6                	mov    %edx,%esi
  80056b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80056d:	5b                   	pop    %ebx
  80056e:	5e                   	pop    %esi
  80056f:	5f                   	pop    %edi
  800570:	5d                   	pop    %ebp
  800571:	c3                   	ret    

00800572 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	57                   	push   %edi
  800576:	56                   	push   %esi
  800577:	53                   	push   %ebx
  800578:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80057b:	be 00 00 00 00       	mov    $0x0,%esi
  800580:	b8 04 00 00 00       	mov    $0x4,%eax
  800585:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800588:	8b 55 08             	mov    0x8(%ebp),%edx
  80058b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80058e:	89 f7                	mov    %esi,%edi
  800590:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800592:	85 c0                	test   %eax,%eax
  800594:	7e 17                	jle    8005ad <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800596:	83 ec 0c             	sub    $0xc,%esp
  800599:	50                   	push   %eax
  80059a:	6a 04                	push   $0x4
  80059c:	68 0f 23 80 00       	push   $0x80230f
  8005a1:	6a 23                	push   $0x23
  8005a3:	68 2c 23 80 00       	push   $0x80232c
  8005a8:	e8 26 13 00 00       	call   8018d3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b0:	5b                   	pop    %ebx
  8005b1:	5e                   	pop    %esi
  8005b2:	5f                   	pop    %edi
  8005b3:	5d                   	pop    %ebp
  8005b4:	c3                   	ret    

008005b5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	57                   	push   %edi
  8005b9:	56                   	push   %esi
  8005ba:	53                   	push   %ebx
  8005bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005be:	b8 05 00 00 00       	mov    $0x5,%eax
  8005c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8005d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	7e 17                	jle    8005ef <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	50                   	push   %eax
  8005dc:	6a 05                	push   $0x5
  8005de:	68 0f 23 80 00       	push   $0x80230f
  8005e3:	6a 23                	push   $0x23
  8005e5:	68 2c 23 80 00       	push   $0x80232c
  8005ea:	e8 e4 12 00 00       	call   8018d3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f2:	5b                   	pop    %ebx
  8005f3:	5e                   	pop    %esi
  8005f4:	5f                   	pop    %edi
  8005f5:	5d                   	pop    %ebp
  8005f6:	c3                   	ret    

008005f7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	57                   	push   %edi
  8005fb:	56                   	push   %esi
  8005fc:	53                   	push   %ebx
  8005fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800600:	bb 00 00 00 00       	mov    $0x0,%ebx
  800605:	b8 06 00 00 00       	mov    $0x6,%eax
  80060a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80060d:	8b 55 08             	mov    0x8(%ebp),%edx
  800610:	89 df                	mov    %ebx,%edi
  800612:	89 de                	mov    %ebx,%esi
  800614:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800616:	85 c0                	test   %eax,%eax
  800618:	7e 17                	jle    800631 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	50                   	push   %eax
  80061e:	6a 06                	push   $0x6
  800620:	68 0f 23 80 00       	push   $0x80230f
  800625:	6a 23                	push   $0x23
  800627:	68 2c 23 80 00       	push   $0x80232c
  80062c:	e8 a2 12 00 00       	call   8018d3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800631:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800634:	5b                   	pop    %ebx
  800635:	5e                   	pop    %esi
  800636:	5f                   	pop    %edi
  800637:	5d                   	pop    %ebp
  800638:	c3                   	ret    

00800639 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800639:	55                   	push   %ebp
  80063a:	89 e5                	mov    %esp,%ebp
  80063c:	57                   	push   %edi
  80063d:	56                   	push   %esi
  80063e:	53                   	push   %ebx
  80063f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800642:	bb 00 00 00 00       	mov    $0x0,%ebx
  800647:	b8 08 00 00 00       	mov    $0x8,%eax
  80064c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80064f:	8b 55 08             	mov    0x8(%ebp),%edx
  800652:	89 df                	mov    %ebx,%edi
  800654:	89 de                	mov    %ebx,%esi
  800656:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800658:	85 c0                	test   %eax,%eax
  80065a:	7e 17                	jle    800673 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80065c:	83 ec 0c             	sub    $0xc,%esp
  80065f:	50                   	push   %eax
  800660:	6a 08                	push   $0x8
  800662:	68 0f 23 80 00       	push   $0x80230f
  800667:	6a 23                	push   $0x23
  800669:	68 2c 23 80 00       	push   $0x80232c
  80066e:	e8 60 12 00 00       	call   8018d3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800676:	5b                   	pop    %ebx
  800677:	5e                   	pop    %esi
  800678:	5f                   	pop    %edi
  800679:	5d                   	pop    %ebp
  80067a:	c3                   	ret    

0080067b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	57                   	push   %edi
  80067f:	56                   	push   %esi
  800680:	53                   	push   %ebx
  800681:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800684:	bb 00 00 00 00       	mov    $0x0,%ebx
  800689:	b8 09 00 00 00       	mov    $0x9,%eax
  80068e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800691:	8b 55 08             	mov    0x8(%ebp),%edx
  800694:	89 df                	mov    %ebx,%edi
  800696:	89 de                	mov    %ebx,%esi
  800698:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80069a:	85 c0                	test   %eax,%eax
  80069c:	7e 17                	jle    8006b5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80069e:	83 ec 0c             	sub    $0xc,%esp
  8006a1:	50                   	push   %eax
  8006a2:	6a 09                	push   $0x9
  8006a4:	68 0f 23 80 00       	push   $0x80230f
  8006a9:	6a 23                	push   $0x23
  8006ab:	68 2c 23 80 00       	push   $0x80232c
  8006b0:	e8 1e 12 00 00       	call   8018d3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b8:	5b                   	pop    %ebx
  8006b9:	5e                   	pop    %esi
  8006ba:	5f                   	pop    %edi
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	57                   	push   %edi
  8006c1:	56                   	push   %esi
  8006c2:	53                   	push   %ebx
  8006c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d6:	89 df                	mov    %ebx,%edi
  8006d8:	89 de                	mov    %ebx,%esi
  8006da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	7e 17                	jle    8006f7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e0:	83 ec 0c             	sub    $0xc,%esp
  8006e3:	50                   	push   %eax
  8006e4:	6a 0a                	push   $0xa
  8006e6:	68 0f 23 80 00       	push   $0x80230f
  8006eb:	6a 23                	push   $0x23
  8006ed:	68 2c 23 80 00       	push   $0x80232c
  8006f2:	e8 dc 11 00 00       	call   8018d3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fa:	5b                   	pop    %ebx
  8006fb:	5e                   	pop    %esi
  8006fc:	5f                   	pop    %edi
  8006fd:	5d                   	pop    %ebp
  8006fe:	c3                   	ret    

008006ff <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	57                   	push   %edi
  800703:	56                   	push   %esi
  800704:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800705:	be 00 00 00 00       	mov    $0x0,%esi
  80070a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80070f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800712:	8b 55 08             	mov    0x8(%ebp),%edx
  800715:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800718:	8b 7d 14             	mov    0x14(%ebp),%edi
  80071b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	57                   	push   %edi
  800726:	56                   	push   %esi
  800727:	53                   	push   %ebx
  800728:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80072b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800730:	b8 0d 00 00 00       	mov    $0xd,%eax
  800735:	8b 55 08             	mov    0x8(%ebp),%edx
  800738:	89 cb                	mov    %ecx,%ebx
  80073a:	89 cf                	mov    %ecx,%edi
  80073c:	89 ce                	mov    %ecx,%esi
  80073e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800740:	85 c0                	test   %eax,%eax
  800742:	7e 17                	jle    80075b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800744:	83 ec 0c             	sub    $0xc,%esp
  800747:	50                   	push   %eax
  800748:	6a 0d                	push   $0xd
  80074a:	68 0f 23 80 00       	push   $0x80230f
  80074f:	6a 23                	push   $0x23
  800751:	68 2c 23 80 00       	push   $0x80232c
  800756:	e8 78 11 00 00       	call   8018d3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80075b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075e:	5b                   	pop    %ebx
  80075f:	5e                   	pop    %esi
  800760:	5f                   	pop    %edi
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	57                   	push   %edi
  800767:	56                   	push   %esi
  800768:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800769:	ba 00 00 00 00       	mov    $0x0,%edx
  80076e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800773:	89 d1                	mov    %edx,%ecx
  800775:	89 d3                	mov    %edx,%ebx
  800777:	89 d7                	mov    %edx,%edi
  800779:	89 d6                	mov    %edx,%esi
  80077b:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5f                   	pop    %edi
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800785:	8b 45 08             	mov    0x8(%ebp),%eax
  800788:	05 00 00 00 30       	add    $0x30000000,%eax
  80078d:	c1 e8 0c             	shr    $0xc,%eax
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	05 00 00 00 30       	add    $0x30000000,%eax
  80079d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8007a2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8007a7:	5d                   	pop    %ebp
  8007a8:	c3                   	ret    

008007a9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007af:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007b4:	89 c2                	mov    %eax,%edx
  8007b6:	c1 ea 16             	shr    $0x16,%edx
  8007b9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007c0:	f6 c2 01             	test   $0x1,%dl
  8007c3:	74 11                	je     8007d6 <fd_alloc+0x2d>
  8007c5:	89 c2                	mov    %eax,%edx
  8007c7:	c1 ea 0c             	shr    $0xc,%edx
  8007ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007d1:	f6 c2 01             	test   $0x1,%dl
  8007d4:	75 09                	jne    8007df <fd_alloc+0x36>
			*fd_store = fd;
  8007d6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dd:	eb 17                	jmp    8007f6 <fd_alloc+0x4d>
  8007df:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007e4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007e9:	75 c9                	jne    8007b4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007eb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8007f1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007fe:	83 f8 1f             	cmp    $0x1f,%eax
  800801:	77 36                	ja     800839 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800803:	c1 e0 0c             	shl    $0xc,%eax
  800806:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80080b:	89 c2                	mov    %eax,%edx
  80080d:	c1 ea 16             	shr    $0x16,%edx
  800810:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800817:	f6 c2 01             	test   $0x1,%dl
  80081a:	74 24                	je     800840 <fd_lookup+0x48>
  80081c:	89 c2                	mov    %eax,%edx
  80081e:	c1 ea 0c             	shr    $0xc,%edx
  800821:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800828:	f6 c2 01             	test   $0x1,%dl
  80082b:	74 1a                	je     800847 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800830:	89 02                	mov    %eax,(%edx)
	return 0;
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
  800837:	eb 13                	jmp    80084c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800839:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083e:	eb 0c                	jmp    80084c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800840:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800845:	eb 05                	jmp    80084c <fd_lookup+0x54>
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800857:	ba b8 23 80 00       	mov    $0x8023b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80085c:	eb 13                	jmp    800871 <dev_lookup+0x23>
  80085e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800861:	39 08                	cmp    %ecx,(%eax)
  800863:	75 0c                	jne    800871 <dev_lookup+0x23>
			*dev = devtab[i];
  800865:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800868:	89 01                	mov    %eax,(%ecx)
			return 0;
  80086a:	b8 00 00 00 00       	mov    $0x0,%eax
  80086f:	eb 2e                	jmp    80089f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800871:	8b 02                	mov    (%edx),%eax
  800873:	85 c0                	test   %eax,%eax
  800875:	75 e7                	jne    80085e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800877:	a1 08 40 80 00       	mov    0x804008,%eax
  80087c:	8b 40 48             	mov    0x48(%eax),%eax
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	51                   	push   %ecx
  800883:	50                   	push   %eax
  800884:	68 3c 23 80 00       	push   $0x80233c
  800889:	e8 1e 11 00 00       	call   8019ac <cprintf>
	*dev = 0;
  80088e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800891:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    

008008a1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	56                   	push   %esi
  8008a5:	53                   	push   %ebx
  8008a6:	83 ec 10             	sub    $0x10,%esp
  8008a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b2:	50                   	push   %eax
  8008b3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008b9:	c1 e8 0c             	shr    $0xc,%eax
  8008bc:	50                   	push   %eax
  8008bd:	e8 36 ff ff ff       	call   8007f8 <fd_lookup>
  8008c2:	83 c4 08             	add    $0x8,%esp
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	78 05                	js     8008ce <fd_close+0x2d>
	    || fd != fd2)
  8008c9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008cc:	74 0c                	je     8008da <fd_close+0x39>
		return (must_exist ? r : 0);
  8008ce:	84 db                	test   %bl,%bl
  8008d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d5:	0f 44 c2             	cmove  %edx,%eax
  8008d8:	eb 41                	jmp    80091b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008da:	83 ec 08             	sub    $0x8,%esp
  8008dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008e0:	50                   	push   %eax
  8008e1:	ff 36                	pushl  (%esi)
  8008e3:	e8 66 ff ff ff       	call   80084e <dev_lookup>
  8008e8:	89 c3                	mov    %eax,%ebx
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	85 c0                	test   %eax,%eax
  8008ef:	78 1a                	js     80090b <fd_close+0x6a>
		if (dev->dev_close)
  8008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8008f7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	74 0b                	je     80090b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800900:	83 ec 0c             	sub    $0xc,%esp
  800903:	56                   	push   %esi
  800904:	ff d0                	call   *%eax
  800906:	89 c3                	mov    %eax,%ebx
  800908:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	56                   	push   %esi
  80090f:	6a 00                	push   $0x0
  800911:	e8 e1 fc ff ff       	call   8005f7 <sys_page_unmap>
	return r;
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	89 d8                	mov    %ebx,%eax
}
  80091b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800928:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80092b:	50                   	push   %eax
  80092c:	ff 75 08             	pushl  0x8(%ebp)
  80092f:	e8 c4 fe ff ff       	call   8007f8 <fd_lookup>
  800934:	83 c4 08             	add    $0x8,%esp
  800937:	85 c0                	test   %eax,%eax
  800939:	78 10                	js     80094b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	6a 01                	push   $0x1
  800940:	ff 75 f4             	pushl  -0xc(%ebp)
  800943:	e8 59 ff ff ff       	call   8008a1 <fd_close>
  800948:	83 c4 10             	add    $0x10,%esp
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <close_all>:

void
close_all(void)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	53                   	push   %ebx
  800951:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800954:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800959:	83 ec 0c             	sub    $0xc,%esp
  80095c:	53                   	push   %ebx
  80095d:	e8 c0 ff ff ff       	call   800922 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800962:	83 c3 01             	add    $0x1,%ebx
  800965:	83 c4 10             	add    $0x10,%esp
  800968:	83 fb 20             	cmp    $0x20,%ebx
  80096b:	75 ec                	jne    800959 <close_all+0xc>
		close(i);
}
  80096d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	57                   	push   %edi
  800976:	56                   	push   %esi
  800977:	53                   	push   %ebx
  800978:	83 ec 2c             	sub    $0x2c,%esp
  80097b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80097e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800981:	50                   	push   %eax
  800982:	ff 75 08             	pushl  0x8(%ebp)
  800985:	e8 6e fe ff ff       	call   8007f8 <fd_lookup>
  80098a:	83 c4 08             	add    $0x8,%esp
  80098d:	85 c0                	test   %eax,%eax
  80098f:	0f 88 c1 00 00 00    	js     800a56 <dup+0xe4>
		return r;
	close(newfdnum);
  800995:	83 ec 0c             	sub    $0xc,%esp
  800998:	56                   	push   %esi
  800999:	e8 84 ff ff ff       	call   800922 <close>

	newfd = INDEX2FD(newfdnum);
  80099e:	89 f3                	mov    %esi,%ebx
  8009a0:	c1 e3 0c             	shl    $0xc,%ebx
  8009a3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8009a9:	83 c4 04             	add    $0x4,%esp
  8009ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009af:	e8 de fd ff ff       	call   800792 <fd2data>
  8009b4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8009b6:	89 1c 24             	mov    %ebx,(%esp)
  8009b9:	e8 d4 fd ff ff       	call   800792 <fd2data>
  8009be:	83 c4 10             	add    $0x10,%esp
  8009c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009c4:	89 f8                	mov    %edi,%eax
  8009c6:	c1 e8 16             	shr    $0x16,%eax
  8009c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009d0:	a8 01                	test   $0x1,%al
  8009d2:	74 37                	je     800a0b <dup+0x99>
  8009d4:	89 f8                	mov    %edi,%eax
  8009d6:	c1 e8 0c             	shr    $0xc,%eax
  8009d9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009e0:	f6 c2 01             	test   $0x1,%dl
  8009e3:	74 26                	je     800a0b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009ec:	83 ec 0c             	sub    $0xc,%esp
  8009ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8009f4:	50                   	push   %eax
  8009f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009f8:	6a 00                	push   $0x0
  8009fa:	57                   	push   %edi
  8009fb:	6a 00                	push   $0x0
  8009fd:	e8 b3 fb ff ff       	call   8005b5 <sys_page_map>
  800a02:	89 c7                	mov    %eax,%edi
  800a04:	83 c4 20             	add    $0x20,%esp
  800a07:	85 c0                	test   %eax,%eax
  800a09:	78 2e                	js     800a39 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a0b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a0e:	89 d0                	mov    %edx,%eax
  800a10:	c1 e8 0c             	shr    $0xc,%eax
  800a13:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a1a:	83 ec 0c             	sub    $0xc,%esp
  800a1d:	25 07 0e 00 00       	and    $0xe07,%eax
  800a22:	50                   	push   %eax
  800a23:	53                   	push   %ebx
  800a24:	6a 00                	push   $0x0
  800a26:	52                   	push   %edx
  800a27:	6a 00                	push   $0x0
  800a29:	e8 87 fb ff ff       	call   8005b5 <sys_page_map>
  800a2e:	89 c7                	mov    %eax,%edi
  800a30:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a33:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a35:	85 ff                	test   %edi,%edi
  800a37:	79 1d                	jns    800a56 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a39:	83 ec 08             	sub    $0x8,%esp
  800a3c:	53                   	push   %ebx
  800a3d:	6a 00                	push   $0x0
  800a3f:	e8 b3 fb ff ff       	call   8005f7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a44:	83 c4 08             	add    $0x8,%esp
  800a47:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a4a:	6a 00                	push   $0x0
  800a4c:	e8 a6 fb ff ff       	call   8005f7 <sys_page_unmap>
	return r;
  800a51:	83 c4 10             	add    $0x10,%esp
  800a54:	89 f8                	mov    %edi,%eax
}
  800a56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	53                   	push   %ebx
  800a62:	83 ec 14             	sub    $0x14,%esp
  800a65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a6b:	50                   	push   %eax
  800a6c:	53                   	push   %ebx
  800a6d:	e8 86 fd ff ff       	call   8007f8 <fd_lookup>
  800a72:	83 c4 08             	add    $0x8,%esp
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	85 c0                	test   %eax,%eax
  800a79:	78 6d                	js     800ae8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a7b:	83 ec 08             	sub    $0x8,%esp
  800a7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a81:	50                   	push   %eax
  800a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a85:	ff 30                	pushl  (%eax)
  800a87:	e8 c2 fd ff ff       	call   80084e <dev_lookup>
  800a8c:	83 c4 10             	add    $0x10,%esp
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	78 4c                	js     800adf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a93:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a96:	8b 42 08             	mov    0x8(%edx),%eax
  800a99:	83 e0 03             	and    $0x3,%eax
  800a9c:	83 f8 01             	cmp    $0x1,%eax
  800a9f:	75 21                	jne    800ac2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800aa1:	a1 08 40 80 00       	mov    0x804008,%eax
  800aa6:	8b 40 48             	mov    0x48(%eax),%eax
  800aa9:	83 ec 04             	sub    $0x4,%esp
  800aac:	53                   	push   %ebx
  800aad:	50                   	push   %eax
  800aae:	68 7d 23 80 00       	push   $0x80237d
  800ab3:	e8 f4 0e 00 00       	call   8019ac <cprintf>
		return -E_INVAL;
  800ab8:	83 c4 10             	add    $0x10,%esp
  800abb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ac0:	eb 26                	jmp    800ae8 <read+0x8a>
	}
	if (!dev->dev_read)
  800ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac5:	8b 40 08             	mov    0x8(%eax),%eax
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	74 17                	je     800ae3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800acc:	83 ec 04             	sub    $0x4,%esp
  800acf:	ff 75 10             	pushl  0x10(%ebp)
  800ad2:	ff 75 0c             	pushl  0xc(%ebp)
  800ad5:	52                   	push   %edx
  800ad6:	ff d0                	call   *%eax
  800ad8:	89 c2                	mov    %eax,%edx
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	eb 09                	jmp    800ae8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	eb 05                	jmp    800ae8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800ae3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800ae8:	89 d0                	mov    %edx,%eax
  800aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800afe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b03:	eb 21                	jmp    800b26 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b05:	83 ec 04             	sub    $0x4,%esp
  800b08:	89 f0                	mov    %esi,%eax
  800b0a:	29 d8                	sub    %ebx,%eax
  800b0c:	50                   	push   %eax
  800b0d:	89 d8                	mov    %ebx,%eax
  800b0f:	03 45 0c             	add    0xc(%ebp),%eax
  800b12:	50                   	push   %eax
  800b13:	57                   	push   %edi
  800b14:	e8 45 ff ff ff       	call   800a5e <read>
		if (m < 0)
  800b19:	83 c4 10             	add    $0x10,%esp
  800b1c:	85 c0                	test   %eax,%eax
  800b1e:	78 10                	js     800b30 <readn+0x41>
			return m;
		if (m == 0)
  800b20:	85 c0                	test   %eax,%eax
  800b22:	74 0a                	je     800b2e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b24:	01 c3                	add    %eax,%ebx
  800b26:	39 f3                	cmp    %esi,%ebx
  800b28:	72 db                	jb     800b05 <readn+0x16>
  800b2a:	89 d8                	mov    %ebx,%eax
  800b2c:	eb 02                	jmp    800b30 <readn+0x41>
  800b2e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	53                   	push   %ebx
  800b3c:	83 ec 14             	sub    $0x14,%esp
  800b3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b45:	50                   	push   %eax
  800b46:	53                   	push   %ebx
  800b47:	e8 ac fc ff ff       	call   8007f8 <fd_lookup>
  800b4c:	83 c4 08             	add    $0x8,%esp
  800b4f:	89 c2                	mov    %eax,%edx
  800b51:	85 c0                	test   %eax,%eax
  800b53:	78 68                	js     800bbd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b55:	83 ec 08             	sub    $0x8,%esp
  800b58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b5b:	50                   	push   %eax
  800b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b5f:	ff 30                	pushl  (%eax)
  800b61:	e8 e8 fc ff ff       	call   80084e <dev_lookup>
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	78 47                	js     800bb4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b70:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b74:	75 21                	jne    800b97 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b76:	a1 08 40 80 00       	mov    0x804008,%eax
  800b7b:	8b 40 48             	mov    0x48(%eax),%eax
  800b7e:	83 ec 04             	sub    $0x4,%esp
  800b81:	53                   	push   %ebx
  800b82:	50                   	push   %eax
  800b83:	68 99 23 80 00       	push   $0x802399
  800b88:	e8 1f 0e 00 00       	call   8019ac <cprintf>
		return -E_INVAL;
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b95:	eb 26                	jmp    800bbd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b9a:	8b 52 0c             	mov    0xc(%edx),%edx
  800b9d:	85 d2                	test   %edx,%edx
  800b9f:	74 17                	je     800bb8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ba1:	83 ec 04             	sub    $0x4,%esp
  800ba4:	ff 75 10             	pushl  0x10(%ebp)
  800ba7:	ff 75 0c             	pushl  0xc(%ebp)
  800baa:	50                   	push   %eax
  800bab:	ff d2                	call   *%edx
  800bad:	89 c2                	mov    %eax,%edx
  800baf:	83 c4 10             	add    $0x10,%esp
  800bb2:	eb 09                	jmp    800bbd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bb4:	89 c2                	mov    %eax,%edx
  800bb6:	eb 05                	jmp    800bbd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800bb8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800bbd:	89 d0                	mov    %edx,%eax
  800bbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <seek>:

int
seek(int fdnum, off_t offset)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bca:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800bcd:	50                   	push   %eax
  800bce:	ff 75 08             	pushl  0x8(%ebp)
  800bd1:	e8 22 fc ff ff       	call   8007f8 <fd_lookup>
  800bd6:	83 c4 08             	add    $0x8,%esp
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	78 0e                	js     800beb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800be0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 14             	sub    $0x14,%esp
  800bf4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bf7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bfa:	50                   	push   %eax
  800bfb:	53                   	push   %ebx
  800bfc:	e8 f7 fb ff ff       	call   8007f8 <fd_lookup>
  800c01:	83 c4 08             	add    $0x8,%esp
  800c04:	89 c2                	mov    %eax,%edx
  800c06:	85 c0                	test   %eax,%eax
  800c08:	78 65                	js     800c6f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c0a:	83 ec 08             	sub    $0x8,%esp
  800c0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c10:	50                   	push   %eax
  800c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c14:	ff 30                	pushl  (%eax)
  800c16:	e8 33 fc ff ff       	call   80084e <dev_lookup>
  800c1b:	83 c4 10             	add    $0x10,%esp
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	78 44                	js     800c66 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c25:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c29:	75 21                	jne    800c4c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c2b:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c30:	8b 40 48             	mov    0x48(%eax),%eax
  800c33:	83 ec 04             	sub    $0x4,%esp
  800c36:	53                   	push   %ebx
  800c37:	50                   	push   %eax
  800c38:	68 5c 23 80 00       	push   $0x80235c
  800c3d:	e8 6a 0d 00 00       	call   8019ac <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c4a:	eb 23                	jmp    800c6f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c4f:	8b 52 18             	mov    0x18(%edx),%edx
  800c52:	85 d2                	test   %edx,%edx
  800c54:	74 14                	je     800c6a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c56:	83 ec 08             	sub    $0x8,%esp
  800c59:	ff 75 0c             	pushl  0xc(%ebp)
  800c5c:	50                   	push   %eax
  800c5d:	ff d2                	call   *%edx
  800c5f:	89 c2                	mov    %eax,%edx
  800c61:	83 c4 10             	add    $0x10,%esp
  800c64:	eb 09                	jmp    800c6f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c66:	89 c2                	mov    %eax,%edx
  800c68:	eb 05                	jmp    800c6f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c6a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c6f:	89 d0                	mov    %edx,%eax
  800c71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c74:	c9                   	leave  
  800c75:	c3                   	ret    

00800c76 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 14             	sub    $0x14,%esp
  800c7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c80:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c83:	50                   	push   %eax
  800c84:	ff 75 08             	pushl  0x8(%ebp)
  800c87:	e8 6c fb ff ff       	call   8007f8 <fd_lookup>
  800c8c:	83 c4 08             	add    $0x8,%esp
  800c8f:	89 c2                	mov    %eax,%edx
  800c91:	85 c0                	test   %eax,%eax
  800c93:	78 58                	js     800ced <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c95:	83 ec 08             	sub    $0x8,%esp
  800c98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c9b:	50                   	push   %eax
  800c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c9f:	ff 30                	pushl  (%eax)
  800ca1:	e8 a8 fb ff ff       	call   80084e <dev_lookup>
  800ca6:	83 c4 10             	add    $0x10,%esp
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	78 37                	js     800ce4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800cb4:	74 32                	je     800ce8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800cb6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cb9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cc0:	00 00 00 
	stat->st_isdir = 0;
  800cc3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cca:	00 00 00 
	stat->st_dev = dev;
  800ccd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800cd3:	83 ec 08             	sub    $0x8,%esp
  800cd6:	53                   	push   %ebx
  800cd7:	ff 75 f0             	pushl  -0x10(%ebp)
  800cda:	ff 50 14             	call   *0x14(%eax)
  800cdd:	89 c2                	mov    %eax,%edx
  800cdf:	83 c4 10             	add    $0x10,%esp
  800ce2:	eb 09                	jmp    800ced <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ce4:	89 c2                	mov    %eax,%edx
  800ce6:	eb 05                	jmp    800ced <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ce8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ced:	89 d0                	mov    %edx,%eax
  800cef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800cf9:	83 ec 08             	sub    $0x8,%esp
  800cfc:	6a 00                	push   $0x0
  800cfe:	ff 75 08             	pushl  0x8(%ebp)
  800d01:	e8 e3 01 00 00       	call   800ee9 <open>
  800d06:	89 c3                	mov    %eax,%ebx
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	78 1b                	js     800d2a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d0f:	83 ec 08             	sub    $0x8,%esp
  800d12:	ff 75 0c             	pushl  0xc(%ebp)
  800d15:	50                   	push   %eax
  800d16:	e8 5b ff ff ff       	call   800c76 <fstat>
  800d1b:	89 c6                	mov    %eax,%esi
	close(fd);
  800d1d:	89 1c 24             	mov    %ebx,(%esp)
  800d20:	e8 fd fb ff ff       	call   800922 <close>
	return r;
  800d25:	83 c4 10             	add    $0x10,%esp
  800d28:	89 f0                	mov    %esi,%eax
}
  800d2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	89 c6                	mov    %eax,%esi
  800d38:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d3a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d41:	75 12                	jne    800d55 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	6a 01                	push   $0x1
  800d48:	e8 ac 12 00 00       	call   801ff9 <ipc_find_env>
  800d4d:	a3 00 40 80 00       	mov    %eax,0x804000
  800d52:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d55:	6a 07                	push   $0x7
  800d57:	68 00 50 80 00       	push   $0x805000
  800d5c:	56                   	push   %esi
  800d5d:	ff 35 00 40 80 00    	pushl  0x804000
  800d63:	e8 05 12 00 00       	call   801f6d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d68:	83 c4 0c             	add    $0xc,%esp
  800d6b:	6a 00                	push   $0x0
  800d6d:	53                   	push   %ebx
  800d6e:	6a 00                	push   $0x0
  800d70:	e8 83 11 00 00       	call   801ef8 <ipc_recv>
}
  800d75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	8b 40 0c             	mov    0xc(%eax),%eax
  800d88:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d90:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d95:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d9f:	e8 8d ff ff ff       	call   800d31 <fsipc>
}
  800da4:	c9                   	leave  
  800da5:	c3                   	ret    

00800da6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	8b 40 0c             	mov    0xc(%eax),%eax
  800db2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800db7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbc:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc1:	e8 6b ff ff ff       	call   800d31 <fsipc>
}
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <devfile_stat>:
                return ((ssize_t)r);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	8b 40 0c             	mov    0xc(%eax),%eax
  800dd8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ddd:	ba 00 00 00 00       	mov    $0x0,%edx
  800de2:	b8 05 00 00 00       	mov    $0x5,%eax
  800de7:	e8 45 ff ff ff       	call   800d31 <fsipc>
  800dec:	85 c0                	test   %eax,%eax
  800dee:	78 2c                	js     800e1c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800df0:	83 ec 08             	sub    $0x8,%esp
  800df3:	68 00 50 80 00       	push   $0x805000
  800df8:	53                   	push   %ebx
  800df9:	e8 71 f3 ff ff       	call   80016f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800dfe:	a1 80 50 80 00       	mov    0x805080,%eax
  800e03:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e09:	a1 84 50 80 00       	mov    0x805084,%eax
  800e0e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	8b 45 10             	mov    0x10(%ebp),%eax
  800e2a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e2f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800e34:	0f 47 c2             	cmova  %edx,%eax
	int r;
	if(n > (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t))))
	{
		n = (size_t)(PGSIZE - (sizeof(int) + sizeof(size_t)));
	}
		fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 52 0c             	mov    0xc(%edx),%edx
  800e3d:	89 15 00 50 80 00    	mov    %edx,0x805000
		fsipcbuf.write.req_n = n;
  800e43:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove((void *)fsipcbuf.write.req_buf, buf, n);
  800e48:	50                   	push   %eax
  800e49:	ff 75 0c             	pushl  0xc(%ebp)
  800e4c:	68 08 50 80 00       	push   $0x805008
  800e51:	e8 ab f4 ff ff       	call   800301 <memmove>
		r = fsipc(FSREQ_WRITE, NULL);
  800e56:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800e60:	e8 cc fe ff ff       	call   800d31 <fsipc>
                return ((ssize_t)r);
}
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	8b 40 0c             	mov    0xc(%eax),%eax
  800e75:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e7a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e80:	ba 00 00 00 00       	mov    $0x0,%edx
  800e85:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8a:	e8 a2 fe ff ff       	call   800d31 <fsipc>
  800e8f:	89 c3                	mov    %eax,%ebx
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 4b                	js     800ee0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e95:	39 c6                	cmp    %eax,%esi
  800e97:	73 16                	jae    800eaf <devfile_read+0x48>
  800e99:	68 cc 23 80 00       	push   $0x8023cc
  800e9e:	68 d3 23 80 00       	push   $0x8023d3
  800ea3:	6a 7c                	push   $0x7c
  800ea5:	68 e8 23 80 00       	push   $0x8023e8
  800eaa:	e8 24 0a 00 00       	call   8018d3 <_panic>
	assert(r <= PGSIZE);
  800eaf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800eb4:	7e 16                	jle    800ecc <devfile_read+0x65>
  800eb6:	68 f3 23 80 00       	push   $0x8023f3
  800ebb:	68 d3 23 80 00       	push   $0x8023d3
  800ec0:	6a 7d                	push   $0x7d
  800ec2:	68 e8 23 80 00       	push   $0x8023e8
  800ec7:	e8 07 0a 00 00       	call   8018d3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ecc:	83 ec 04             	sub    $0x4,%esp
  800ecf:	50                   	push   %eax
  800ed0:	68 00 50 80 00       	push   $0x805000
  800ed5:	ff 75 0c             	pushl  0xc(%ebp)
  800ed8:	e8 24 f4 ff ff       	call   800301 <memmove>
	return r;
  800edd:	83 c4 10             	add    $0x10,%esp
}
  800ee0:	89 d8                	mov    %ebx,%eax
  800ee2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	53                   	push   %ebx
  800eed:	83 ec 20             	sub    $0x20,%esp
  800ef0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ef3:	53                   	push   %ebx
  800ef4:	e8 3d f2 ff ff       	call   800136 <strlen>
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f01:	7f 67                	jg     800f6a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f09:	50                   	push   %eax
  800f0a:	e8 9a f8 ff ff       	call   8007a9 <fd_alloc>
  800f0f:	83 c4 10             	add    $0x10,%esp
		return r;
  800f12:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	78 57                	js     800f6f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f18:	83 ec 08             	sub    $0x8,%esp
  800f1b:	53                   	push   %ebx
  800f1c:	68 00 50 80 00       	push   $0x805000
  800f21:	e8 49 f2 ff ff       	call   80016f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f29:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f31:	b8 01 00 00 00       	mov    $0x1,%eax
  800f36:	e8 f6 fd ff ff       	call   800d31 <fsipc>
  800f3b:	89 c3                	mov    %eax,%ebx
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	79 14                	jns    800f58 <open+0x6f>
		fd_close(fd, 0);
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	6a 00                	push   $0x0
  800f49:	ff 75 f4             	pushl  -0xc(%ebp)
  800f4c:	e8 50 f9 ff ff       	call   8008a1 <fd_close>
		return r;
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	89 da                	mov    %ebx,%edx
  800f56:	eb 17                	jmp    800f6f <open+0x86>
	}

	return fd2num(fd);
  800f58:	83 ec 0c             	sub    $0xc,%esp
  800f5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f5e:	e8 1f f8 ff ff       	call   800782 <fd2num>
  800f63:	89 c2                	mov    %eax,%edx
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	eb 05                	jmp    800f6f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f6a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f6f:	89 d0                	mov    %edx,%eax
  800f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f81:	b8 08 00 00 00       	mov    $0x8,%eax
  800f86:	e8 a6 fd ff ff       	call   800d31 <fsipc>
}
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800f93:	68 ff 23 80 00       	push   $0x8023ff
  800f98:	ff 75 0c             	pushl  0xc(%ebp)
  800f9b:	e8 cf f1 ff ff       	call   80016f <strcpy>
	return 0;
}
  800fa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	53                   	push   %ebx
  800fab:	83 ec 10             	sub    $0x10,%esp
  800fae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800fb1:	53                   	push   %ebx
  800fb2:	e8 7b 10 00 00       	call   802032 <pageref>
  800fb7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800fba:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800fbf:	83 f8 01             	cmp    $0x1,%eax
  800fc2:	75 10                	jne    800fd4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	ff 73 0c             	pushl  0xc(%ebx)
  800fca:	e8 c0 02 00 00       	call   80128f <nsipc_close>
  800fcf:	89 c2                	mov    %eax,%edx
  800fd1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800fd4:	89 d0                	mov    %edx,%eax
  800fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800fe1:	6a 00                	push   $0x0
  800fe3:	ff 75 10             	pushl  0x10(%ebp)
  800fe6:	ff 75 0c             	pushl  0xc(%ebp)
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fec:	ff 70 0c             	pushl  0xc(%eax)
  800fef:	e8 78 03 00 00       	call   80136c <nsipc_send>
}
  800ff4:	c9                   	leave  
  800ff5:	c3                   	ret    

00800ff6 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800ffc:	6a 00                	push   $0x0
  800ffe:	ff 75 10             	pushl  0x10(%ebp)
  801001:	ff 75 0c             	pushl  0xc(%ebp)
  801004:	8b 45 08             	mov    0x8(%ebp),%eax
  801007:	ff 70 0c             	pushl  0xc(%eax)
  80100a:	e8 f1 02 00 00       	call   801300 <nsipc_recv>
}
  80100f:	c9                   	leave  
  801010:	c3                   	ret    

00801011 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801017:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80101a:	52                   	push   %edx
  80101b:	50                   	push   %eax
  80101c:	e8 d7 f7 ff ff       	call   8007f8 <fd_lookup>
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	78 17                	js     80103f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801031:	39 08                	cmp    %ecx,(%eax)
  801033:	75 05                	jne    80103a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801035:	8b 40 0c             	mov    0xc(%eax),%eax
  801038:	eb 05                	jmp    80103f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80103a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
  801046:	83 ec 1c             	sub    $0x1c,%esp
  801049:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80104b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104e:	50                   	push   %eax
  80104f:	e8 55 f7 ff ff       	call   8007a9 <fd_alloc>
  801054:	89 c3                	mov    %eax,%ebx
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 1b                	js     801078 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80105d:	83 ec 04             	sub    $0x4,%esp
  801060:	68 07 04 00 00       	push   $0x407
  801065:	ff 75 f4             	pushl  -0xc(%ebp)
  801068:	6a 00                	push   $0x0
  80106a:	e8 03 f5 ff ff       	call   800572 <sys_page_alloc>
  80106f:	89 c3                	mov    %eax,%ebx
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	79 10                	jns    801088 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	56                   	push   %esi
  80107c:	e8 0e 02 00 00       	call   80128f <nsipc_close>
		return r;
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	89 d8                	mov    %ebx,%eax
  801086:	eb 24                	jmp    8010ac <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801088:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80108e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801091:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801093:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801096:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80109d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	50                   	push   %eax
  8010a4:	e8 d9 f6 ff ff       	call   800782 <fd2num>
  8010a9:	83 c4 10             	add    $0x10,%esp
}
  8010ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bc:	e8 50 ff ff ff       	call   801011 <fd2sockid>
		return r;
  8010c1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 1f                	js     8010e6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	ff 75 10             	pushl  0x10(%ebp)
  8010cd:	ff 75 0c             	pushl  0xc(%ebp)
  8010d0:	50                   	push   %eax
  8010d1:	e8 12 01 00 00       	call   8011e8 <nsipc_accept>
  8010d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8010d9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 07                	js     8010e6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8010df:	e8 5d ff ff ff       	call   801041 <alloc_sockfd>
  8010e4:	89 c1                	mov    %eax,%ecx
}
  8010e6:	89 c8                	mov    %ecx,%eax
  8010e8:	c9                   	leave  
  8010e9:	c3                   	ret    

008010ea <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	e8 19 ff ff ff       	call   801011 <fd2sockid>
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 12                	js     80110e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8010fc:	83 ec 04             	sub    $0x4,%esp
  8010ff:	ff 75 10             	pushl  0x10(%ebp)
  801102:	ff 75 0c             	pushl  0xc(%ebp)
  801105:	50                   	push   %eax
  801106:	e8 2d 01 00 00       	call   801238 <nsipc_bind>
  80110b:	83 c4 10             	add    $0x10,%esp
}
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <shutdown>:

int
shutdown(int s, int how)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	e8 f3 fe ff ff       	call   801011 <fd2sockid>
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 0f                	js     801131 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801122:	83 ec 08             	sub    $0x8,%esp
  801125:	ff 75 0c             	pushl  0xc(%ebp)
  801128:	50                   	push   %eax
  801129:	e8 3f 01 00 00       	call   80126d <nsipc_shutdown>
  80112e:	83 c4 10             	add    $0x10,%esp
}
  801131:	c9                   	leave  
  801132:	c3                   	ret    

00801133 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	e8 d0 fe ff ff       	call   801011 <fd2sockid>
  801141:	85 c0                	test   %eax,%eax
  801143:	78 12                	js     801157 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	ff 75 10             	pushl  0x10(%ebp)
  80114b:	ff 75 0c             	pushl  0xc(%ebp)
  80114e:	50                   	push   %eax
  80114f:	e8 55 01 00 00       	call   8012a9 <nsipc_connect>
  801154:	83 c4 10             	add    $0x10,%esp
}
  801157:	c9                   	leave  
  801158:	c3                   	ret    

00801159 <listen>:

int
listen(int s, int backlog)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	e8 aa fe ff ff       	call   801011 <fd2sockid>
  801167:	85 c0                	test   %eax,%eax
  801169:	78 0f                	js     80117a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	ff 75 0c             	pushl  0xc(%ebp)
  801171:	50                   	push   %eax
  801172:	e8 67 01 00 00       	call   8012de <nsipc_listen>
  801177:	83 c4 10             	add    $0x10,%esp
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801182:	ff 75 10             	pushl  0x10(%ebp)
  801185:	ff 75 0c             	pushl  0xc(%ebp)
  801188:	ff 75 08             	pushl  0x8(%ebp)
  80118b:	e8 3a 02 00 00       	call   8013ca <nsipc_socket>
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	78 05                	js     80119c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801197:	e8 a5 fe ff ff       	call   801041 <alloc_sockfd>
}
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    

0080119e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 04             	sub    $0x4,%esp
  8011a5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8011a7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8011ae:	75 12                	jne    8011c2 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8011b0:	83 ec 0c             	sub    $0xc,%esp
  8011b3:	6a 02                	push   $0x2
  8011b5:	e8 3f 0e 00 00       	call   801ff9 <ipc_find_env>
  8011ba:	a3 04 40 80 00       	mov    %eax,0x804004
  8011bf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8011c2:	6a 07                	push   $0x7
  8011c4:	68 00 60 80 00       	push   $0x806000
  8011c9:	53                   	push   %ebx
  8011ca:	ff 35 04 40 80 00    	pushl  0x804004
  8011d0:	e8 98 0d 00 00       	call   801f6d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8011d5:	83 c4 0c             	add    $0xc,%esp
  8011d8:	6a 00                	push   $0x0
  8011da:	6a 00                	push   $0x0
  8011dc:	6a 00                	push   $0x0
  8011de:	e8 15 0d 00 00       	call   801ef8 <ipc_recv>
}
  8011e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	56                   	push   %esi
  8011ec:	53                   	push   %ebx
  8011ed:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8011f8:	8b 06                	mov    (%esi),%eax
  8011fa:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8011ff:	b8 01 00 00 00       	mov    $0x1,%eax
  801204:	e8 95 ff ff ff       	call   80119e <nsipc>
  801209:	89 c3                	mov    %eax,%ebx
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 20                	js     80122f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	ff 35 10 60 80 00    	pushl  0x806010
  801218:	68 00 60 80 00       	push   $0x806000
  80121d:	ff 75 0c             	pushl  0xc(%ebp)
  801220:	e8 dc f0 ff ff       	call   800301 <memmove>
		*addrlen = ret->ret_addrlen;
  801225:	a1 10 60 80 00       	mov    0x806010,%eax
  80122a:	89 06                	mov    %eax,(%esi)
  80122c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80122f:	89 d8                	mov    %ebx,%eax
  801231:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801234:	5b                   	pop    %ebx
  801235:	5e                   	pop    %esi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	53                   	push   %ebx
  80123c:	83 ec 08             	sub    $0x8,%esp
  80123f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
  801245:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80124a:	53                   	push   %ebx
  80124b:	ff 75 0c             	pushl  0xc(%ebp)
  80124e:	68 04 60 80 00       	push   $0x806004
  801253:	e8 a9 f0 ff ff       	call   800301 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801258:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80125e:	b8 02 00 00 00       	mov    $0x2,%eax
  801263:	e8 36 ff ff ff       	call   80119e <nsipc>
}
  801268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126b:	c9                   	leave  
  80126c:	c3                   	ret    

0080126d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80127b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801283:	b8 03 00 00 00       	mov    $0x3,%eax
  801288:	e8 11 ff ff ff       	call   80119e <nsipc>
}
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <nsipc_close>:

int
nsipc_close(int s)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
  801298:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80129d:	b8 04 00 00 00       	mov    $0x4,%eax
  8012a2:	e8 f7 fe ff ff       	call   80119e <nsipc>
}
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    

008012a9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8012b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8012bb:	53                   	push   %ebx
  8012bc:	ff 75 0c             	pushl  0xc(%ebp)
  8012bf:	68 04 60 80 00       	push   $0x806004
  8012c4:	e8 38 f0 ff ff       	call   800301 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8012c9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8012cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8012d4:	e8 c5 fe ff ff       	call   80119e <nsipc>
}
  8012d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8012e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8012ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ef:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8012f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8012f9:	e8 a0 fe ff ff       	call   80119e <nsipc>
}
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	56                   	push   %esi
  801304:	53                   	push   %ebx
  801305:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801308:	8b 45 08             	mov    0x8(%ebp),%eax
  80130b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801310:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801316:	8b 45 14             	mov    0x14(%ebp),%eax
  801319:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80131e:	b8 07 00 00 00       	mov    $0x7,%eax
  801323:	e8 76 fe ff ff       	call   80119e <nsipc>
  801328:	89 c3                	mov    %eax,%ebx
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 35                	js     801363 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80132e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801333:	7f 04                	jg     801339 <nsipc_recv+0x39>
  801335:	39 c6                	cmp    %eax,%esi
  801337:	7d 16                	jge    80134f <nsipc_recv+0x4f>
  801339:	68 0b 24 80 00       	push   $0x80240b
  80133e:	68 d3 23 80 00       	push   $0x8023d3
  801343:	6a 62                	push   $0x62
  801345:	68 20 24 80 00       	push   $0x802420
  80134a:	e8 84 05 00 00       	call   8018d3 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80134f:	83 ec 04             	sub    $0x4,%esp
  801352:	50                   	push   %eax
  801353:	68 00 60 80 00       	push   $0x806000
  801358:	ff 75 0c             	pushl  0xc(%ebp)
  80135b:	e8 a1 ef ff ff       	call   800301 <memmove>
  801360:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801363:	89 d8                	mov    %ebx,%eax
  801365:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801368:	5b                   	pop    %ebx
  801369:	5e                   	pop    %esi
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	53                   	push   %ebx
  801370:	83 ec 04             	sub    $0x4,%esp
  801373:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801376:	8b 45 08             	mov    0x8(%ebp),%eax
  801379:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80137e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801384:	7e 16                	jle    80139c <nsipc_send+0x30>
  801386:	68 2c 24 80 00       	push   $0x80242c
  80138b:	68 d3 23 80 00       	push   $0x8023d3
  801390:	6a 6d                	push   $0x6d
  801392:	68 20 24 80 00       	push   $0x802420
  801397:	e8 37 05 00 00       	call   8018d3 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	53                   	push   %ebx
  8013a0:	ff 75 0c             	pushl  0xc(%ebp)
  8013a3:	68 0c 60 80 00       	push   $0x80600c
  8013a8:	e8 54 ef ff ff       	call   800301 <memmove>
	nsipcbuf.send.req_size = size;
  8013ad:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8013b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8013bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8013c0:	e8 d9 fd ff ff       	call   80119e <nsipc>
}
  8013c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8013d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8013d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013db:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8013e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8013e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8013ed:	e8 ac fd ff ff       	call   80119e <nsipc>
}
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
  8013f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8013fc:	83 ec 0c             	sub    $0xc,%esp
  8013ff:	ff 75 08             	pushl  0x8(%ebp)
  801402:	e8 8b f3 ff ff       	call   800792 <fd2data>
  801407:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801409:	83 c4 08             	add    $0x8,%esp
  80140c:	68 38 24 80 00       	push   $0x802438
  801411:	53                   	push   %ebx
  801412:	e8 58 ed ff ff       	call   80016f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801417:	8b 46 04             	mov    0x4(%esi),%eax
  80141a:	2b 06                	sub    (%esi),%eax
  80141c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801422:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801429:	00 00 00 
	stat->st_dev = &devpipe;
  80142c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801433:	30 80 00 
	return 0;
}
  801436:	b8 00 00 00 00       	mov    $0x0,%eax
  80143b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143e:	5b                   	pop    %ebx
  80143f:	5e                   	pop    %esi
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	53                   	push   %ebx
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80144c:	53                   	push   %ebx
  80144d:	6a 00                	push   $0x0
  80144f:	e8 a3 f1 ff ff       	call   8005f7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801454:	89 1c 24             	mov    %ebx,(%esp)
  801457:	e8 36 f3 ff ff       	call   800792 <fd2data>
  80145c:	83 c4 08             	add    $0x8,%esp
  80145f:	50                   	push   %eax
  801460:	6a 00                	push   $0x0
  801462:	e8 90 f1 ff ff       	call   8005f7 <sys_page_unmap>
}
  801467:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	57                   	push   %edi
  801470:	56                   	push   %esi
  801471:	53                   	push   %ebx
  801472:	83 ec 1c             	sub    $0x1c,%esp
  801475:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801478:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80147a:	a1 08 40 80 00       	mov    0x804008,%eax
  80147f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	ff 75 e0             	pushl  -0x20(%ebp)
  801488:	e8 a5 0b 00 00       	call   802032 <pageref>
  80148d:	89 c3                	mov    %eax,%ebx
  80148f:	89 3c 24             	mov    %edi,(%esp)
  801492:	e8 9b 0b 00 00       	call   802032 <pageref>
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	39 c3                	cmp    %eax,%ebx
  80149c:	0f 94 c1             	sete   %cl
  80149f:	0f b6 c9             	movzbl %cl,%ecx
  8014a2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8014a5:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8014ab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8014ae:	39 ce                	cmp    %ecx,%esi
  8014b0:	74 1b                	je     8014cd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8014b2:	39 c3                	cmp    %eax,%ebx
  8014b4:	75 c4                	jne    80147a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8014b6:	8b 42 58             	mov    0x58(%edx),%eax
  8014b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014bc:	50                   	push   %eax
  8014bd:	56                   	push   %esi
  8014be:	68 3f 24 80 00       	push   $0x80243f
  8014c3:	e8 e4 04 00 00       	call   8019ac <cprintf>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	eb ad                	jmp    80147a <_pipeisclosed+0xe>
	}
}
  8014cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5e                   	pop    %esi
  8014d5:	5f                   	pop    %edi
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	57                   	push   %edi
  8014dc:	56                   	push   %esi
  8014dd:	53                   	push   %ebx
  8014de:	83 ec 28             	sub    $0x28,%esp
  8014e1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8014e4:	56                   	push   %esi
  8014e5:	e8 a8 f2 ff ff       	call   800792 <fd2data>
  8014ea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8014f4:	eb 4b                	jmp    801541 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8014f6:	89 da                	mov    %ebx,%edx
  8014f8:	89 f0                	mov    %esi,%eax
  8014fa:	e8 6d ff ff ff       	call   80146c <_pipeisclosed>
  8014ff:	85 c0                	test   %eax,%eax
  801501:	75 48                	jne    80154b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801503:	e8 4b f0 ff ff       	call   800553 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801508:	8b 43 04             	mov    0x4(%ebx),%eax
  80150b:	8b 0b                	mov    (%ebx),%ecx
  80150d:	8d 51 20             	lea    0x20(%ecx),%edx
  801510:	39 d0                	cmp    %edx,%eax
  801512:	73 e2                	jae    8014f6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801514:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801517:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80151b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80151e:	89 c2                	mov    %eax,%edx
  801520:	c1 fa 1f             	sar    $0x1f,%edx
  801523:	89 d1                	mov    %edx,%ecx
  801525:	c1 e9 1b             	shr    $0x1b,%ecx
  801528:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80152b:	83 e2 1f             	and    $0x1f,%edx
  80152e:	29 ca                	sub    %ecx,%edx
  801530:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801534:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801538:	83 c0 01             	add    $0x1,%eax
  80153b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80153e:	83 c7 01             	add    $0x1,%edi
  801541:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801544:	75 c2                	jne    801508 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801546:	8b 45 10             	mov    0x10(%ebp),%eax
  801549:	eb 05                	jmp    801550 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80154b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801550:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801553:	5b                   	pop    %ebx
  801554:	5e                   	pop    %esi
  801555:	5f                   	pop    %edi
  801556:	5d                   	pop    %ebp
  801557:	c3                   	ret    

00801558 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	57                   	push   %edi
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	83 ec 18             	sub    $0x18,%esp
  801561:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801564:	57                   	push   %edi
  801565:	e8 28 f2 ff ff       	call   800792 <fd2data>
  80156a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801574:	eb 3d                	jmp    8015b3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801576:	85 db                	test   %ebx,%ebx
  801578:	74 04                	je     80157e <devpipe_read+0x26>
				return i;
  80157a:	89 d8                	mov    %ebx,%eax
  80157c:	eb 44                	jmp    8015c2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80157e:	89 f2                	mov    %esi,%edx
  801580:	89 f8                	mov    %edi,%eax
  801582:	e8 e5 fe ff ff       	call   80146c <_pipeisclosed>
  801587:	85 c0                	test   %eax,%eax
  801589:	75 32                	jne    8015bd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80158b:	e8 c3 ef ff ff       	call   800553 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801590:	8b 06                	mov    (%esi),%eax
  801592:	3b 46 04             	cmp    0x4(%esi),%eax
  801595:	74 df                	je     801576 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801597:	99                   	cltd   
  801598:	c1 ea 1b             	shr    $0x1b,%edx
  80159b:	01 d0                	add    %edx,%eax
  80159d:	83 e0 1f             	and    $0x1f,%eax
  8015a0:	29 d0                	sub    %edx,%eax
  8015a2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8015a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015aa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8015ad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015b0:	83 c3 01             	add    $0x1,%ebx
  8015b3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015b6:	75 d8                	jne    801590 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8015b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8015bb:	eb 05                	jmp    8015c2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8015bd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8015c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5e                   	pop    %esi
  8015c7:	5f                   	pop    %edi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	56                   	push   %esi
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8015d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	e8 ce f1 ff ff       	call   8007a9 <fd_alloc>
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	0f 88 2c 01 00 00    	js     801714 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8015e8:	83 ec 04             	sub    $0x4,%esp
  8015eb:	68 07 04 00 00       	push   $0x407
  8015f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f3:	6a 00                	push   $0x0
  8015f5:	e8 78 ef ff ff       	call   800572 <sys_page_alloc>
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	85 c0                	test   %eax,%eax
  801601:	0f 88 0d 01 00 00    	js     801714 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	e8 96 f1 ff ff       	call   8007a9 <fd_alloc>
  801613:	89 c3                	mov    %eax,%ebx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	0f 88 e2 00 00 00    	js     801702 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801620:	83 ec 04             	sub    $0x4,%esp
  801623:	68 07 04 00 00       	push   $0x407
  801628:	ff 75 f0             	pushl  -0x10(%ebp)
  80162b:	6a 00                	push   $0x0
  80162d:	e8 40 ef ff ff       	call   800572 <sys_page_alloc>
  801632:	89 c3                	mov    %eax,%ebx
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	0f 88 c3 00 00 00    	js     801702 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80163f:	83 ec 0c             	sub    $0xc,%esp
  801642:	ff 75 f4             	pushl  -0xc(%ebp)
  801645:	e8 48 f1 ff ff       	call   800792 <fd2data>
  80164a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80164c:	83 c4 0c             	add    $0xc,%esp
  80164f:	68 07 04 00 00       	push   $0x407
  801654:	50                   	push   %eax
  801655:	6a 00                	push   $0x0
  801657:	e8 16 ef ff ff       	call   800572 <sys_page_alloc>
  80165c:	89 c3                	mov    %eax,%ebx
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	85 c0                	test   %eax,%eax
  801663:	0f 88 89 00 00 00    	js     8016f2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801669:	83 ec 0c             	sub    $0xc,%esp
  80166c:	ff 75 f0             	pushl  -0x10(%ebp)
  80166f:	e8 1e f1 ff ff       	call   800792 <fd2data>
  801674:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80167b:	50                   	push   %eax
  80167c:	6a 00                	push   $0x0
  80167e:	56                   	push   %esi
  80167f:	6a 00                	push   $0x0
  801681:	e8 2f ef ff ff       	call   8005b5 <sys_page_map>
  801686:	89 c3                	mov    %eax,%ebx
  801688:	83 c4 20             	add    $0x20,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 55                	js     8016e4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80168f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801698:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80169a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8016a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016bf:	e8 be f0 ff ff       	call   800782 <fd2num>
  8016c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8016c9:	83 c4 04             	add    $0x4,%esp
  8016cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8016cf:	e8 ae f0 ff ff       	call   800782 <fd2num>
  8016d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e2:	eb 30                	jmp    801714 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8016e4:	83 ec 08             	sub    $0x8,%esp
  8016e7:	56                   	push   %esi
  8016e8:	6a 00                	push   $0x0
  8016ea:	e8 08 ef ff ff       	call   8005f7 <sys_page_unmap>
  8016ef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016f8:	6a 00                	push   $0x0
  8016fa:	e8 f8 ee ff ff       	call   8005f7 <sys_page_unmap>
  8016ff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801702:	83 ec 08             	sub    $0x8,%esp
  801705:	ff 75 f4             	pushl  -0xc(%ebp)
  801708:	6a 00                	push   $0x0
  80170a:	e8 e8 ee ff ff       	call   8005f7 <sys_page_unmap>
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801714:	89 d0                	mov    %edx,%eax
  801716:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801719:	5b                   	pop    %ebx
  80171a:	5e                   	pop    %esi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801723:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	ff 75 08             	pushl  0x8(%ebp)
  80172a:	e8 c9 f0 ff ff       	call   8007f8 <fd_lookup>
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	85 c0                	test   %eax,%eax
  801734:	78 18                	js     80174e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801736:	83 ec 0c             	sub    $0xc,%esp
  801739:	ff 75 f4             	pushl  -0xc(%ebp)
  80173c:	e8 51 f0 ff ff       	call   800792 <fd2data>
	return _pipeisclosed(fd, p);
  801741:	89 c2                	mov    %eax,%edx
  801743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801746:	e8 21 fd ff ff       	call   80146c <_pipeisclosed>
  80174b:	83 c4 10             	add    $0x10,%esp
}
  80174e:	c9                   	leave  
  80174f:	c3                   	ret    

00801750 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801753:	b8 00 00 00 00       	mov    $0x0,%eax
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801760:	68 57 24 80 00       	push   $0x802457
  801765:	ff 75 0c             	pushl  0xc(%ebp)
  801768:	e8 02 ea ff ff       	call   80016f <strcpy>
	return 0;
}
  80176d:	b8 00 00 00 00       	mov    $0x0,%eax
  801772:	c9                   	leave  
  801773:	c3                   	ret    

00801774 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	57                   	push   %edi
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801780:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801785:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80178b:	eb 2d                	jmp    8017ba <devcons_write+0x46>
		m = n - tot;
  80178d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801790:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801792:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801795:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80179a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80179d:	83 ec 04             	sub    $0x4,%esp
  8017a0:	53                   	push   %ebx
  8017a1:	03 45 0c             	add    0xc(%ebp),%eax
  8017a4:	50                   	push   %eax
  8017a5:	57                   	push   %edi
  8017a6:	e8 56 eb ff ff       	call   800301 <memmove>
		sys_cputs(buf, m);
  8017ab:	83 c4 08             	add    $0x8,%esp
  8017ae:	53                   	push   %ebx
  8017af:	57                   	push   %edi
  8017b0:	e8 01 ed ff ff       	call   8004b6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8017b5:	01 de                	add    %ebx,%esi
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	89 f0                	mov    %esi,%eax
  8017bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017bf:	72 cc                	jb     80178d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8017c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5f                   	pop    %edi
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8017d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017d8:	74 2a                	je     801804 <devcons_read+0x3b>
  8017da:	eb 05                	jmp    8017e1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8017dc:	e8 72 ed ff ff       	call   800553 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8017e1:	e8 ee ec ff ff       	call   8004d4 <sys_cgetc>
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	74 f2                	je     8017dc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 16                	js     801804 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8017ee:	83 f8 04             	cmp    $0x4,%eax
  8017f1:	74 0c                	je     8017ff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8017f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f6:	88 02                	mov    %al,(%edx)
	return 1;
  8017f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8017fd:	eb 05                	jmp    801804 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8017ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80180c:	8b 45 08             	mov    0x8(%ebp),%eax
  80180f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801812:	6a 01                	push   $0x1
  801814:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	e8 99 ec ff ff       	call   8004b6 <sys_cputs>
}
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <getchar>:

int
getchar(void)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801828:	6a 01                	push   $0x1
  80182a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80182d:	50                   	push   %eax
  80182e:	6a 00                	push   $0x0
  801830:	e8 29 f2 ff ff       	call   800a5e <read>
	if (r < 0)
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	78 0f                	js     80184b <getchar+0x29>
		return r;
	if (r < 1)
  80183c:	85 c0                	test   %eax,%eax
  80183e:	7e 06                	jle    801846 <getchar+0x24>
		return -E_EOF;
	return c;
  801840:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801844:	eb 05                	jmp    80184b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801846:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801853:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801856:	50                   	push   %eax
  801857:	ff 75 08             	pushl  0x8(%ebp)
  80185a:	e8 99 ef ff ff       	call   8007f8 <fd_lookup>
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	78 11                	js     801877 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801869:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80186f:	39 10                	cmp    %edx,(%eax)
  801871:	0f 94 c0             	sete   %al
  801874:	0f b6 c0             	movzbl %al,%eax
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <opencons>:

int
opencons(void)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80187f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801882:	50                   	push   %eax
  801883:	e8 21 ef ff ff       	call   8007a9 <fd_alloc>
  801888:	83 c4 10             	add    $0x10,%esp
		return r;
  80188b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 3e                	js     8018cf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801891:	83 ec 04             	sub    $0x4,%esp
  801894:	68 07 04 00 00       	push   $0x407
  801899:	ff 75 f4             	pushl  -0xc(%ebp)
  80189c:	6a 00                	push   $0x0
  80189e:	e8 cf ec ff ff       	call   800572 <sys_page_alloc>
  8018a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 23                	js     8018cf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8018ac:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8018b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8018c1:	83 ec 0c             	sub    $0xc,%esp
  8018c4:	50                   	push   %eax
  8018c5:	e8 b8 ee ff ff       	call   800782 <fd2num>
  8018ca:	89 c2                	mov    %eax,%edx
  8018cc:	83 c4 10             	add    $0x10,%esp
}
  8018cf:	89 d0                	mov    %edx,%eax
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	56                   	push   %esi
  8018d7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8018d8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018db:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8018e1:	e8 4e ec ff ff       	call   800534 <sys_getenvid>
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	ff 75 0c             	pushl  0xc(%ebp)
  8018ec:	ff 75 08             	pushl  0x8(%ebp)
  8018ef:	56                   	push   %esi
  8018f0:	50                   	push   %eax
  8018f1:	68 64 24 80 00       	push   $0x802464
  8018f6:	e8 b1 00 00 00       	call   8019ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8018fb:	83 c4 18             	add    $0x18,%esp
  8018fe:	53                   	push   %ebx
  8018ff:	ff 75 10             	pushl  0x10(%ebp)
  801902:	e8 54 00 00 00       	call   80195b <vcprintf>
	cprintf("\n");
  801907:	c7 04 24 50 24 80 00 	movl   $0x802450,(%esp)
  80190e:	e8 99 00 00 00       	call   8019ac <cprintf>
  801913:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801916:	cc                   	int3   
  801917:	eb fd                	jmp    801916 <_panic+0x43>

00801919 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	53                   	push   %ebx
  80191d:	83 ec 04             	sub    $0x4,%esp
  801920:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801923:	8b 13                	mov    (%ebx),%edx
  801925:	8d 42 01             	lea    0x1(%edx),%eax
  801928:	89 03                	mov    %eax,(%ebx)
  80192a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801931:	3d ff 00 00 00       	cmp    $0xff,%eax
  801936:	75 1a                	jne    801952 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801938:	83 ec 08             	sub    $0x8,%esp
  80193b:	68 ff 00 00 00       	push   $0xff
  801940:	8d 43 08             	lea    0x8(%ebx),%eax
  801943:	50                   	push   %eax
  801944:	e8 6d eb ff ff       	call   8004b6 <sys_cputs>
		b->idx = 0;
  801949:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80194f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801952:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801964:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80196b:	00 00 00 
	b.cnt = 0;
  80196e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801975:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801978:	ff 75 0c             	pushl  0xc(%ebp)
  80197b:	ff 75 08             	pushl  0x8(%ebp)
  80197e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	68 19 19 80 00       	push   $0x801919
  80198a:	e8 54 01 00 00       	call   801ae3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80198f:	83 c4 08             	add    $0x8,%esp
  801992:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801998:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80199e:	50                   	push   %eax
  80199f:	e8 12 eb ff ff       	call   8004b6 <sys_cputs>

	return b.cnt;
}
  8019a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8019b5:	50                   	push   %eax
  8019b6:	ff 75 08             	pushl  0x8(%ebp)
  8019b9:	e8 9d ff ff ff       	call   80195b <vcprintf>
	va_end(ap);

	return cnt;
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	57                   	push   %edi
  8019c4:	56                   	push   %esi
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 1c             	sub    $0x1c,%esp
  8019c9:	89 c7                	mov    %eax,%edi
  8019cb:	89 d6                	mov    %edx,%esi
  8019cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8019d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8019e4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8019e7:	39 d3                	cmp    %edx,%ebx
  8019e9:	72 05                	jb     8019f0 <printnum+0x30>
  8019eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8019ee:	77 45                	ja     801a35 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 75 18             	pushl  0x18(%ebp)
  8019f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8019fc:	53                   	push   %ebx
  8019fd:	ff 75 10             	pushl  0x10(%ebp)
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a06:	ff 75 e0             	pushl  -0x20(%ebp)
  801a09:	ff 75 dc             	pushl  -0x24(%ebp)
  801a0c:	ff 75 d8             	pushl  -0x28(%ebp)
  801a0f:	e8 5c 06 00 00       	call   802070 <__udivdi3>
  801a14:	83 c4 18             	add    $0x18,%esp
  801a17:	52                   	push   %edx
  801a18:	50                   	push   %eax
  801a19:	89 f2                	mov    %esi,%edx
  801a1b:	89 f8                	mov    %edi,%eax
  801a1d:	e8 9e ff ff ff       	call   8019c0 <printnum>
  801a22:	83 c4 20             	add    $0x20,%esp
  801a25:	eb 18                	jmp    801a3f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	56                   	push   %esi
  801a2b:	ff 75 18             	pushl  0x18(%ebp)
  801a2e:	ff d7                	call   *%edi
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	eb 03                	jmp    801a38 <printnum+0x78>
  801a35:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801a38:	83 eb 01             	sub    $0x1,%ebx
  801a3b:	85 db                	test   %ebx,%ebx
  801a3d:	7f e8                	jg     801a27 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801a3f:	83 ec 08             	sub    $0x8,%esp
  801a42:	56                   	push   %esi
  801a43:	83 ec 04             	sub    $0x4,%esp
  801a46:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a49:	ff 75 e0             	pushl  -0x20(%ebp)
  801a4c:	ff 75 dc             	pushl  -0x24(%ebp)
  801a4f:	ff 75 d8             	pushl  -0x28(%ebp)
  801a52:	e8 49 07 00 00       	call   8021a0 <__umoddi3>
  801a57:	83 c4 14             	add    $0x14,%esp
  801a5a:	0f be 80 87 24 80 00 	movsbl 0x802487(%eax),%eax
  801a61:	50                   	push   %eax
  801a62:	ff d7                	call   *%edi
}
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5f                   	pop    %edi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801a72:	83 fa 01             	cmp    $0x1,%edx
  801a75:	7e 0e                	jle    801a85 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801a77:	8b 10                	mov    (%eax),%edx
  801a79:	8d 4a 08             	lea    0x8(%edx),%ecx
  801a7c:	89 08                	mov    %ecx,(%eax)
  801a7e:	8b 02                	mov    (%edx),%eax
  801a80:	8b 52 04             	mov    0x4(%edx),%edx
  801a83:	eb 22                	jmp    801aa7 <getuint+0x38>
	else if (lflag)
  801a85:	85 d2                	test   %edx,%edx
  801a87:	74 10                	je     801a99 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801a89:	8b 10                	mov    (%eax),%edx
  801a8b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801a8e:	89 08                	mov    %ecx,(%eax)
  801a90:	8b 02                	mov    (%edx),%eax
  801a92:	ba 00 00 00 00       	mov    $0x0,%edx
  801a97:	eb 0e                	jmp    801aa7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801a99:	8b 10                	mov    (%eax),%edx
  801a9b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801a9e:	89 08                	mov    %ecx,(%eax)
  801aa0:	8b 02                	mov    (%edx),%eax
  801aa2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801aaf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801ab3:	8b 10                	mov    (%eax),%edx
  801ab5:	3b 50 04             	cmp    0x4(%eax),%edx
  801ab8:	73 0a                	jae    801ac4 <sprintputch+0x1b>
		*b->buf++ = ch;
  801aba:	8d 4a 01             	lea    0x1(%edx),%ecx
  801abd:	89 08                	mov    %ecx,(%eax)
  801abf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac2:	88 02                	mov    %al,(%edx)
}
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801acc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801acf:	50                   	push   %eax
  801ad0:	ff 75 10             	pushl  0x10(%ebp)
  801ad3:	ff 75 0c             	pushl  0xc(%ebp)
  801ad6:	ff 75 08             	pushl  0x8(%ebp)
  801ad9:	e8 05 00 00 00       	call   801ae3 <vprintfmt>
	va_end(ap);
}
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	57                   	push   %edi
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 2c             	sub    $0x2c,%esp
  801aec:	8b 75 08             	mov    0x8(%ebp),%esi
  801aef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801af2:	8b 7d 10             	mov    0x10(%ebp),%edi
  801af5:	eb 12                	jmp    801b09 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801af7:	85 c0                	test   %eax,%eax
  801af9:	0f 84 89 03 00 00    	je     801e88 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801aff:	83 ec 08             	sub    $0x8,%esp
  801b02:	53                   	push   %ebx
  801b03:	50                   	push   %eax
  801b04:	ff d6                	call   *%esi
  801b06:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801b09:	83 c7 01             	add    $0x1,%edi
  801b0c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801b10:	83 f8 25             	cmp    $0x25,%eax
  801b13:	75 e2                	jne    801af7 <vprintfmt+0x14>
  801b15:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801b19:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801b20:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801b27:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b33:	eb 07                	jmp    801b3c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b35:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801b38:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b3c:	8d 47 01             	lea    0x1(%edi),%eax
  801b3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b42:	0f b6 07             	movzbl (%edi),%eax
  801b45:	0f b6 c8             	movzbl %al,%ecx
  801b48:	83 e8 23             	sub    $0x23,%eax
  801b4b:	3c 55                	cmp    $0x55,%al
  801b4d:	0f 87 1a 03 00 00    	ja     801e6d <vprintfmt+0x38a>
  801b53:	0f b6 c0             	movzbl %al,%eax
  801b56:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  801b5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801b60:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801b64:	eb d6                	jmp    801b3c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801b71:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801b74:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801b78:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801b7b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801b7e:	83 fa 09             	cmp    $0x9,%edx
  801b81:	77 39                	ja     801bbc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801b83:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801b86:	eb e9                	jmp    801b71 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801b88:	8b 45 14             	mov    0x14(%ebp),%eax
  801b8b:	8d 48 04             	lea    0x4(%eax),%ecx
  801b8e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801b91:	8b 00                	mov    (%eax),%eax
  801b93:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801b99:	eb 27                	jmp    801bc2 <vprintfmt+0xdf>
  801b9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ba5:	0f 49 c8             	cmovns %eax,%ecx
  801ba8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bae:	eb 8c                	jmp    801b3c <vprintfmt+0x59>
  801bb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801bb3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801bba:	eb 80                	jmp    801b3c <vprintfmt+0x59>
  801bbc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801bbf:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801bc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801bc6:	0f 89 70 ff ff ff    	jns    801b3c <vprintfmt+0x59>
				width = precision, precision = -1;
  801bcc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801bcf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bd2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801bd9:	e9 5e ff ff ff       	jmp    801b3c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801bde:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801be4:	e9 53 ff ff ff       	jmp    801b3c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801be9:	8b 45 14             	mov    0x14(%ebp),%eax
  801bec:	8d 50 04             	lea    0x4(%eax),%edx
  801bef:	89 55 14             	mov    %edx,0x14(%ebp)
  801bf2:	83 ec 08             	sub    $0x8,%esp
  801bf5:	53                   	push   %ebx
  801bf6:	ff 30                	pushl  (%eax)
  801bf8:	ff d6                	call   *%esi
			break;
  801bfa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bfd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801c00:	e9 04 ff ff ff       	jmp    801b09 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801c05:	8b 45 14             	mov    0x14(%ebp),%eax
  801c08:	8d 50 04             	lea    0x4(%eax),%edx
  801c0b:	89 55 14             	mov    %edx,0x14(%ebp)
  801c0e:	8b 00                	mov    (%eax),%eax
  801c10:	99                   	cltd   
  801c11:	31 d0                	xor    %edx,%eax
  801c13:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c15:	83 f8 0f             	cmp    $0xf,%eax
  801c18:	7f 0b                	jg     801c25 <vprintfmt+0x142>
  801c1a:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  801c21:	85 d2                	test   %edx,%edx
  801c23:	75 18                	jne    801c3d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801c25:	50                   	push   %eax
  801c26:	68 9f 24 80 00       	push   $0x80249f
  801c2b:	53                   	push   %ebx
  801c2c:	56                   	push   %esi
  801c2d:	e8 94 fe ff ff       	call   801ac6 <printfmt>
  801c32:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801c38:	e9 cc fe ff ff       	jmp    801b09 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801c3d:	52                   	push   %edx
  801c3e:	68 e5 23 80 00       	push   $0x8023e5
  801c43:	53                   	push   %ebx
  801c44:	56                   	push   %esi
  801c45:	e8 7c fe ff ff       	call   801ac6 <printfmt>
  801c4a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c50:	e9 b4 fe ff ff       	jmp    801b09 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801c55:	8b 45 14             	mov    0x14(%ebp),%eax
  801c58:	8d 50 04             	lea    0x4(%eax),%edx
  801c5b:	89 55 14             	mov    %edx,0x14(%ebp)
  801c5e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801c60:	85 ff                	test   %edi,%edi
  801c62:	b8 98 24 80 00       	mov    $0x802498,%eax
  801c67:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801c6a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c6e:	0f 8e 94 00 00 00    	jle    801d08 <vprintfmt+0x225>
  801c74:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801c78:	0f 84 98 00 00 00    	je     801d16 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801c7e:	83 ec 08             	sub    $0x8,%esp
  801c81:	ff 75 d0             	pushl  -0x30(%ebp)
  801c84:	57                   	push   %edi
  801c85:	e8 c4 e4 ff ff       	call   80014e <strnlen>
  801c8a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801c8d:	29 c1                	sub    %eax,%ecx
  801c8f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801c92:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801c95:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801c99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c9c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801c9f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ca1:	eb 0f                	jmp    801cb2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801ca3:	83 ec 08             	sub    $0x8,%esp
  801ca6:	53                   	push   %ebx
  801ca7:	ff 75 e0             	pushl  -0x20(%ebp)
  801caa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801cac:	83 ef 01             	sub    $0x1,%edi
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 ff                	test   %edi,%edi
  801cb4:	7f ed                	jg     801ca3 <vprintfmt+0x1c0>
  801cb6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801cb9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801cbc:	85 c9                	test   %ecx,%ecx
  801cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc3:	0f 49 c1             	cmovns %ecx,%eax
  801cc6:	29 c1                	sub    %eax,%ecx
  801cc8:	89 75 08             	mov    %esi,0x8(%ebp)
  801ccb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801cce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801cd1:	89 cb                	mov    %ecx,%ebx
  801cd3:	eb 4d                	jmp    801d22 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801cd5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801cd9:	74 1b                	je     801cf6 <vprintfmt+0x213>
  801cdb:	0f be c0             	movsbl %al,%eax
  801cde:	83 e8 20             	sub    $0x20,%eax
  801ce1:	83 f8 5e             	cmp    $0x5e,%eax
  801ce4:	76 10                	jbe    801cf6 <vprintfmt+0x213>
					putch('?', putdat);
  801ce6:	83 ec 08             	sub    $0x8,%esp
  801ce9:	ff 75 0c             	pushl  0xc(%ebp)
  801cec:	6a 3f                	push   $0x3f
  801cee:	ff 55 08             	call   *0x8(%ebp)
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	eb 0d                	jmp    801d03 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801cf6:	83 ec 08             	sub    $0x8,%esp
  801cf9:	ff 75 0c             	pushl  0xc(%ebp)
  801cfc:	52                   	push   %edx
  801cfd:	ff 55 08             	call   *0x8(%ebp)
  801d00:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d03:	83 eb 01             	sub    $0x1,%ebx
  801d06:	eb 1a                	jmp    801d22 <vprintfmt+0x23f>
  801d08:	89 75 08             	mov    %esi,0x8(%ebp)
  801d0b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d0e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d11:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d14:	eb 0c                	jmp    801d22 <vprintfmt+0x23f>
  801d16:	89 75 08             	mov    %esi,0x8(%ebp)
  801d19:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d1c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d1f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d22:	83 c7 01             	add    $0x1,%edi
  801d25:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d29:	0f be d0             	movsbl %al,%edx
  801d2c:	85 d2                	test   %edx,%edx
  801d2e:	74 23                	je     801d53 <vprintfmt+0x270>
  801d30:	85 f6                	test   %esi,%esi
  801d32:	78 a1                	js     801cd5 <vprintfmt+0x1f2>
  801d34:	83 ee 01             	sub    $0x1,%esi
  801d37:	79 9c                	jns    801cd5 <vprintfmt+0x1f2>
  801d39:	89 df                	mov    %ebx,%edi
  801d3b:	8b 75 08             	mov    0x8(%ebp),%esi
  801d3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d41:	eb 18                	jmp    801d5b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801d43:	83 ec 08             	sub    $0x8,%esp
  801d46:	53                   	push   %ebx
  801d47:	6a 20                	push   $0x20
  801d49:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801d4b:	83 ef 01             	sub    $0x1,%edi
  801d4e:	83 c4 10             	add    $0x10,%esp
  801d51:	eb 08                	jmp    801d5b <vprintfmt+0x278>
  801d53:	89 df                	mov    %ebx,%edi
  801d55:	8b 75 08             	mov    0x8(%ebp),%esi
  801d58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d5b:	85 ff                	test   %edi,%edi
  801d5d:	7f e4                	jg     801d43 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d62:	e9 a2 fd ff ff       	jmp    801b09 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801d67:	83 fa 01             	cmp    $0x1,%edx
  801d6a:	7e 16                	jle    801d82 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801d6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801d6f:	8d 50 08             	lea    0x8(%eax),%edx
  801d72:	89 55 14             	mov    %edx,0x14(%ebp)
  801d75:	8b 50 04             	mov    0x4(%eax),%edx
  801d78:	8b 00                	mov    (%eax),%eax
  801d7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d7d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801d80:	eb 32                	jmp    801db4 <vprintfmt+0x2d1>
	else if (lflag)
  801d82:	85 d2                	test   %edx,%edx
  801d84:	74 18                	je     801d9e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801d86:	8b 45 14             	mov    0x14(%ebp),%eax
  801d89:	8d 50 04             	lea    0x4(%eax),%edx
  801d8c:	89 55 14             	mov    %edx,0x14(%ebp)
  801d8f:	8b 00                	mov    (%eax),%eax
  801d91:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d94:	89 c1                	mov    %eax,%ecx
  801d96:	c1 f9 1f             	sar    $0x1f,%ecx
  801d99:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801d9c:	eb 16                	jmp    801db4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801d9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801da1:	8d 50 04             	lea    0x4(%eax),%edx
  801da4:	89 55 14             	mov    %edx,0x14(%ebp)
  801da7:	8b 00                	mov    (%eax),%eax
  801da9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dac:	89 c1                	mov    %eax,%ecx
  801dae:	c1 f9 1f             	sar    $0x1f,%ecx
  801db1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801db4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801db7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801dba:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801dbf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801dc3:	79 74                	jns    801e39 <vprintfmt+0x356>
				putch('-', putdat);
  801dc5:	83 ec 08             	sub    $0x8,%esp
  801dc8:	53                   	push   %ebx
  801dc9:	6a 2d                	push   $0x2d
  801dcb:	ff d6                	call   *%esi
				num = -(long long) num;
  801dcd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801dd0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801dd3:	f7 d8                	neg    %eax
  801dd5:	83 d2 00             	adc    $0x0,%edx
  801dd8:	f7 da                	neg    %edx
  801dda:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ddd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801de2:	eb 55                	jmp    801e39 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801de4:	8d 45 14             	lea    0x14(%ebp),%eax
  801de7:	e8 83 fc ff ff       	call   801a6f <getuint>
			base = 10;
  801dec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801df1:	eb 46                	jmp    801e39 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801df3:	8d 45 14             	lea    0x14(%ebp),%eax
  801df6:	e8 74 fc ff ff       	call   801a6f <getuint>
			base = 8;
  801dfb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801e00:	eb 37                	jmp    801e39 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  801e02:	83 ec 08             	sub    $0x8,%esp
  801e05:	53                   	push   %ebx
  801e06:	6a 30                	push   $0x30
  801e08:	ff d6                	call   *%esi
			putch('x', putdat);
  801e0a:	83 c4 08             	add    $0x8,%esp
  801e0d:	53                   	push   %ebx
  801e0e:	6a 78                	push   $0x78
  801e10:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801e12:	8b 45 14             	mov    0x14(%ebp),%eax
  801e15:	8d 50 04             	lea    0x4(%eax),%edx
  801e18:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801e1b:	8b 00                	mov    (%eax),%eax
  801e1d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801e22:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801e25:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801e2a:	eb 0d                	jmp    801e39 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801e2c:	8d 45 14             	lea    0x14(%ebp),%eax
  801e2f:	e8 3b fc ff ff       	call   801a6f <getuint>
			base = 16;
  801e34:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801e40:	57                   	push   %edi
  801e41:	ff 75 e0             	pushl  -0x20(%ebp)
  801e44:	51                   	push   %ecx
  801e45:	52                   	push   %edx
  801e46:	50                   	push   %eax
  801e47:	89 da                	mov    %ebx,%edx
  801e49:	89 f0                	mov    %esi,%eax
  801e4b:	e8 70 fb ff ff       	call   8019c0 <printnum>
			break;
  801e50:	83 c4 20             	add    $0x20,%esp
  801e53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e56:	e9 ae fc ff ff       	jmp    801b09 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	53                   	push   %ebx
  801e5f:	51                   	push   %ecx
  801e60:	ff d6                	call   *%esi
			break;
  801e62:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801e68:	e9 9c fc ff ff       	jmp    801b09 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801e6d:	83 ec 08             	sub    $0x8,%esp
  801e70:	53                   	push   %ebx
  801e71:	6a 25                	push   $0x25
  801e73:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	eb 03                	jmp    801e7d <vprintfmt+0x39a>
  801e7a:	83 ef 01             	sub    $0x1,%edi
  801e7d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801e81:	75 f7                	jne    801e7a <vprintfmt+0x397>
  801e83:	e9 81 fc ff ff       	jmp    801b09 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801e88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8b:	5b                   	pop    %ebx
  801e8c:	5e                   	pop    %esi
  801e8d:	5f                   	pop    %edi
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	83 ec 18             	sub    $0x18,%esp
  801e96:	8b 45 08             	mov    0x8(%ebp),%eax
  801e99:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801e9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e9f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ea3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ea6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	74 26                	je     801ed7 <vsnprintf+0x47>
  801eb1:	85 d2                	test   %edx,%edx
  801eb3:	7e 22                	jle    801ed7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801eb5:	ff 75 14             	pushl  0x14(%ebp)
  801eb8:	ff 75 10             	pushl  0x10(%ebp)
  801ebb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ebe:	50                   	push   %eax
  801ebf:	68 a9 1a 80 00       	push   $0x801aa9
  801ec4:	e8 1a fc ff ff       	call   801ae3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ecc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	eb 05                	jmp    801edc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ed7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ee4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ee7:	50                   	push   %eax
  801ee8:	ff 75 10             	pushl  0x10(%ebp)
  801eeb:	ff 75 0c             	pushl  0xc(%ebp)
  801eee:	ff 75 08             	pushl  0x8(%ebp)
  801ef1:	e8 9a ff ff ff       	call   801e90 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f03:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  801f06:	85 c0                	test   %eax,%eax
  801f08:	74 0e                	je     801f18 <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  801f0a:	83 ec 0c             	sub    $0xc,%esp
  801f0d:	50                   	push   %eax
  801f0e:	e8 0f e8 ff ff       	call   800722 <sys_ipc_recv>
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	eb 10                	jmp    801f28 <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	68 00 00 00 f0       	push   $0xf0000000
  801f20:	e8 fd e7 ff ff       	call   800722 <sys_ipc_recv>
  801f25:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	74 16                	je     801f42 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  801f2c:	85 db                	test   %ebx,%ebx
  801f2e:	74 36                	je     801f66 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  801f30:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  801f36:	85 f6                	test   %esi,%esi
  801f38:	74 2c                	je     801f66 <ipc_recv+0x6e>
				*perm_store = 0;
  801f3a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f40:	eb 24                	jmp    801f66 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  801f42:	85 db                	test   %ebx,%ebx
  801f44:	74 18                	je     801f5e <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  801f46:	a1 08 40 80 00       	mov    0x804008,%eax
  801f4b:	8b 40 74             	mov    0x74(%eax),%eax
  801f4e:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  801f50:	85 f6                	test   %esi,%esi
  801f52:	74 0a                	je     801f5e <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  801f54:	a1 08 40 80 00       	mov    0x804008,%eax
  801f59:	8b 40 78             	mov    0x78(%eax),%eax
  801f5c:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  801f5e:	a1 08 40 80 00       	mov    0x804008,%eax
  801f63:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  801f66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f69:	5b                   	pop    %ebx
  801f6a:	5e                   	pop    %esi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	57                   	push   %edi
  801f71:	56                   	push   %esi
  801f72:	53                   	push   %ebx
  801f73:	83 ec 0c             	sub    $0xc,%esp
  801f76:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f79:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  801f7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f80:	75 39                	jne    801fbb <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  801f82:	6a 00                	push   $0x0
  801f84:	68 00 00 00 f0       	push   $0xf0000000
  801f89:	56                   	push   %esi
  801f8a:	57                   	push   %edi
  801f8b:	e8 6f e7 ff ff       	call   8006ff <sys_ipc_try_send>
  801f90:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f98:	74 16                	je     801fb0 <ipc_send+0x43>
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	74 12                	je     801fb0 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801f9e:	50                   	push   %eax
  801f9f:	68 80 27 80 00       	push   $0x802780
  801fa4:	6a 4f                	push   $0x4f
  801fa6:	68 b8 27 80 00       	push   $0x8027b8
  801fab:	e8 23 f9 ff ff       	call   8018d3 <_panic>
			sys_yield();
  801fb0:	e8 9e e5 ff ff       	call   800553 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  801fb5:	85 db                	test   %ebx,%ebx
  801fb7:	75 c9                	jne    801f82 <ipc_send+0x15>
  801fb9:	eb 36                	jmp    801ff1 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  801fbb:	ff 75 14             	pushl  0x14(%ebp)
  801fbe:	ff 75 10             	pushl  0x10(%ebp)
  801fc1:	56                   	push   %esi
  801fc2:	57                   	push   %edi
  801fc3:	e8 37 e7 ff ff       	call   8006ff <sys_ipc_try_send>
  801fc8:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fd0:	74 16                	je     801fe8 <ipc_send+0x7b>
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	74 12                	je     801fe8 <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801fd6:	50                   	push   %eax
  801fd7:	68 80 27 80 00       	push   $0x802780
  801fdc:	6a 5a                	push   $0x5a
  801fde:	68 b8 27 80 00       	push   $0x8027b8
  801fe3:	e8 eb f8 ff ff       	call   8018d3 <_panic>
			sys_yield();
  801fe8:	e8 66 e5 ff ff       	call   800553 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  801fed:	85 db                	test   %ebx,%ebx
  801fef:	75 ca                	jne    801fbb <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  801ff1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fff:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802004:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802007:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80200d:	8b 52 50             	mov    0x50(%edx),%edx
  802010:	39 ca                	cmp    %ecx,%edx
  802012:	75 0d                	jne    802021 <ipc_find_env+0x28>
			return envs[i].env_id;
  802014:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802017:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80201c:	8b 40 48             	mov    0x48(%eax),%eax
  80201f:	eb 0f                	jmp    802030 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802021:	83 c0 01             	add    $0x1,%eax
  802024:	3d 00 04 00 00       	cmp    $0x400,%eax
  802029:	75 d9                	jne    802004 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80202b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802038:	89 d0                	mov    %edx,%eax
  80203a:	c1 e8 16             	shr    $0x16,%eax
  80203d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802044:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802049:	f6 c1 01             	test   $0x1,%cl
  80204c:	74 1d                	je     80206b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80204e:	c1 ea 0c             	shr    $0xc,%edx
  802051:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802058:	f6 c2 01             	test   $0x1,%dl
  80205b:	74 0e                	je     80206b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205d:	c1 ea 0c             	shr    $0xc,%edx
  802060:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802067:	ef 
  802068:	0f b7 c0             	movzwl %ax,%eax
}
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    
  80206d:	66 90                	xchg   %ax,%ax
  80206f:	90                   	nop

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
