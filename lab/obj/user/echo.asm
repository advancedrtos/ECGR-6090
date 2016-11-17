
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
  800051:	68 60 1e 80 00       	push   $0x801e60
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
  80008a:	68 63 1e 80 00       	push   $0x801e63
  80008f:	6a 01                	push   $0x1
  800091:	e8 83 0a 00 00       	call   800b19 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 92 00 00 00       	call   800136 <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 67 0a 00 00       	call   800b19 <write>
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
  8000c7:	68 91 1f 80 00       	push   $0x801f91
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 46 0a 00 00       	call   800b19 <write>
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
  8000fb:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80051b:	68 6f 1e 80 00       	push   $0x801e6f
  800520:	6a 23                	push   $0x23
  800522:	68 8c 1e 80 00       	push   $0x801e8c
  800527:	e8 f5 0e 00 00       	call   801421 <_panic>

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
  80059c:	68 6f 1e 80 00       	push   $0x801e6f
  8005a1:	6a 23                	push   $0x23
  8005a3:	68 8c 1e 80 00       	push   $0x801e8c
  8005a8:	e8 74 0e 00 00       	call   801421 <_panic>

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
  8005de:	68 6f 1e 80 00       	push   $0x801e6f
  8005e3:	6a 23                	push   $0x23
  8005e5:	68 8c 1e 80 00       	push   $0x801e8c
  8005ea:	e8 32 0e 00 00       	call   801421 <_panic>

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
  800620:	68 6f 1e 80 00       	push   $0x801e6f
  800625:	6a 23                	push   $0x23
  800627:	68 8c 1e 80 00       	push   $0x801e8c
  80062c:	e8 f0 0d 00 00       	call   801421 <_panic>

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
  800662:	68 6f 1e 80 00       	push   $0x801e6f
  800667:	6a 23                	push   $0x23
  800669:	68 8c 1e 80 00       	push   $0x801e8c
  80066e:	e8 ae 0d 00 00       	call   801421 <_panic>

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
  8006a4:	68 6f 1e 80 00       	push   $0x801e6f
  8006a9:	6a 23                	push   $0x23
  8006ab:	68 8c 1e 80 00       	push   $0x801e8c
  8006b0:	e8 6c 0d 00 00       	call   801421 <_panic>

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
  8006e6:	68 6f 1e 80 00       	push   $0x801e6f
  8006eb:	6a 23                	push   $0x23
  8006ed:	68 8c 1e 80 00       	push   $0x801e8c
  8006f2:	e8 2a 0d 00 00       	call   801421 <_panic>

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
  80074a:	68 6f 1e 80 00       	push   $0x801e6f
  80074f:	6a 23                	push   $0x23
  800751:	68 8c 1e 80 00       	push   $0x801e8c
  800756:	e8 c6 0c 00 00       	call   801421 <_panic>

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

00800763 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	05 00 00 00 30       	add    $0x30000000,%eax
  80076e:	c1 e8 0c             	shr    $0xc,%eax
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	05 00 00 00 30       	add    $0x30000000,%eax
  80077e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800783:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800795:	89 c2                	mov    %eax,%edx
  800797:	c1 ea 16             	shr    $0x16,%edx
  80079a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007a1:	f6 c2 01             	test   $0x1,%dl
  8007a4:	74 11                	je     8007b7 <fd_alloc+0x2d>
  8007a6:	89 c2                	mov    %eax,%edx
  8007a8:	c1 ea 0c             	shr    $0xc,%edx
  8007ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007b2:	f6 c2 01             	test   $0x1,%dl
  8007b5:	75 09                	jne    8007c0 <fd_alloc+0x36>
			*fd_store = fd;
  8007b7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007be:	eb 17                	jmp    8007d7 <fd_alloc+0x4d>
  8007c0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007c5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007ca:	75 c9                	jne    800795 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007cc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8007d2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007df:	83 f8 1f             	cmp    $0x1f,%eax
  8007e2:	77 36                	ja     80081a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007e4:	c1 e0 0c             	shl    $0xc,%eax
  8007e7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007ec:	89 c2                	mov    %eax,%edx
  8007ee:	c1 ea 16             	shr    $0x16,%edx
  8007f1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007f8:	f6 c2 01             	test   $0x1,%dl
  8007fb:	74 24                	je     800821 <fd_lookup+0x48>
  8007fd:	89 c2                	mov    %eax,%edx
  8007ff:	c1 ea 0c             	shr    $0xc,%edx
  800802:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800809:	f6 c2 01             	test   $0x1,%dl
  80080c:	74 1a                	je     800828 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	89 02                	mov    %eax,(%edx)
	return 0;
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
  800818:	eb 13                	jmp    80082d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80081a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081f:	eb 0c                	jmp    80082d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800821:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800826:	eb 05                	jmp    80082d <fd_lookup+0x54>
  800828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	83 ec 08             	sub    $0x8,%esp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	ba 18 1f 80 00       	mov    $0x801f18,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80083d:	eb 13                	jmp    800852 <dev_lookup+0x23>
  80083f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800842:	39 08                	cmp    %ecx,(%eax)
  800844:	75 0c                	jne    800852 <dev_lookup+0x23>
			*dev = devtab[i];
  800846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800849:	89 01                	mov    %eax,(%ecx)
			return 0;
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
  800850:	eb 2e                	jmp    800880 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800852:	8b 02                	mov    (%edx),%eax
  800854:	85 c0                	test   %eax,%eax
  800856:	75 e7                	jne    80083f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800858:	a1 04 40 80 00       	mov    0x804004,%eax
  80085d:	8b 40 48             	mov    0x48(%eax),%eax
  800860:	83 ec 04             	sub    $0x4,%esp
  800863:	51                   	push   %ecx
  800864:	50                   	push   %eax
  800865:	68 9c 1e 80 00       	push   $0x801e9c
  80086a:	e8 8b 0c 00 00       	call   8014fa <cprintf>
	*dev = 0;
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	83 ec 10             	sub    $0x10,%esp
  80088a:	8b 75 08             	mov    0x8(%ebp),%esi
  80088d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800893:	50                   	push   %eax
  800894:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80089a:	c1 e8 0c             	shr    $0xc,%eax
  80089d:	50                   	push   %eax
  80089e:	e8 36 ff ff ff       	call   8007d9 <fd_lookup>
  8008a3:	83 c4 08             	add    $0x8,%esp
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	78 05                	js     8008af <fd_close+0x2d>
	    || fd != fd2)
  8008aa:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008ad:	74 0c                	je     8008bb <fd_close+0x39>
		return (must_exist ? r : 0);
  8008af:	84 db                	test   %bl,%bl
  8008b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b6:	0f 44 c2             	cmove  %edx,%eax
  8008b9:	eb 41                	jmp    8008fc <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c1:	50                   	push   %eax
  8008c2:	ff 36                	pushl  (%esi)
  8008c4:	e8 66 ff ff ff       	call   80082f <dev_lookup>
  8008c9:	89 c3                	mov    %eax,%ebx
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	85 c0                	test   %eax,%eax
  8008d0:	78 1a                	js     8008ec <fd_close+0x6a>
		if (dev->dev_close)
  8008d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8008d8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	74 0b                	je     8008ec <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8008e1:	83 ec 0c             	sub    $0xc,%esp
  8008e4:	56                   	push   %esi
  8008e5:	ff d0                	call   *%eax
  8008e7:	89 c3                	mov    %eax,%ebx
  8008e9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	56                   	push   %esi
  8008f0:	6a 00                	push   $0x0
  8008f2:	e8 00 fd ff ff       	call   8005f7 <sys_page_unmap>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 d8                	mov    %ebx,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800909:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80090c:	50                   	push   %eax
  80090d:	ff 75 08             	pushl  0x8(%ebp)
  800910:	e8 c4 fe ff ff       	call   8007d9 <fd_lookup>
  800915:	83 c4 08             	add    $0x8,%esp
  800918:	85 c0                	test   %eax,%eax
  80091a:	78 10                	js     80092c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80091c:	83 ec 08             	sub    $0x8,%esp
  80091f:	6a 01                	push   $0x1
  800921:	ff 75 f4             	pushl  -0xc(%ebp)
  800924:	e8 59 ff ff ff       	call   800882 <fd_close>
  800929:	83 c4 10             	add    $0x10,%esp
}
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <close_all>:

void
close_all(void)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	53                   	push   %ebx
  800932:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800935:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80093a:	83 ec 0c             	sub    $0xc,%esp
  80093d:	53                   	push   %ebx
  80093e:	e8 c0 ff ff ff       	call   800903 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800943:	83 c3 01             	add    $0x1,%ebx
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	83 fb 20             	cmp    $0x20,%ebx
  80094c:	75 ec                	jne    80093a <close_all+0xc>
		close(i);
}
  80094e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	57                   	push   %edi
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	83 ec 2c             	sub    $0x2c,%esp
  80095c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80095f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800962:	50                   	push   %eax
  800963:	ff 75 08             	pushl  0x8(%ebp)
  800966:	e8 6e fe ff ff       	call   8007d9 <fd_lookup>
  80096b:	83 c4 08             	add    $0x8,%esp
  80096e:	85 c0                	test   %eax,%eax
  800970:	0f 88 c1 00 00 00    	js     800a37 <dup+0xe4>
		return r;
	close(newfdnum);
  800976:	83 ec 0c             	sub    $0xc,%esp
  800979:	56                   	push   %esi
  80097a:	e8 84 ff ff ff       	call   800903 <close>

	newfd = INDEX2FD(newfdnum);
  80097f:	89 f3                	mov    %esi,%ebx
  800981:	c1 e3 0c             	shl    $0xc,%ebx
  800984:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80098a:	83 c4 04             	add    $0x4,%esp
  80098d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800990:	e8 de fd ff ff       	call   800773 <fd2data>
  800995:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800997:	89 1c 24             	mov    %ebx,(%esp)
  80099a:	e8 d4 fd ff ff       	call   800773 <fd2data>
  80099f:	83 c4 10             	add    $0x10,%esp
  8009a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009a5:	89 f8                	mov    %edi,%eax
  8009a7:	c1 e8 16             	shr    $0x16,%eax
  8009aa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009b1:	a8 01                	test   $0x1,%al
  8009b3:	74 37                	je     8009ec <dup+0x99>
  8009b5:	89 f8                	mov    %edi,%eax
  8009b7:	c1 e8 0c             	shr    $0xc,%eax
  8009ba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009c1:	f6 c2 01             	test   $0x1,%dl
  8009c4:	74 26                	je     8009ec <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009cd:	83 ec 0c             	sub    $0xc,%esp
  8009d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8009d5:	50                   	push   %eax
  8009d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009d9:	6a 00                	push   $0x0
  8009db:	57                   	push   %edi
  8009dc:	6a 00                	push   $0x0
  8009de:	e8 d2 fb ff ff       	call   8005b5 <sys_page_map>
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	83 c4 20             	add    $0x20,%esp
  8009e8:	85 c0                	test   %eax,%eax
  8009ea:	78 2e                	js     800a1a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009ef:	89 d0                	mov    %edx,%eax
  8009f1:	c1 e8 0c             	shr    $0xc,%eax
  8009f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009fb:	83 ec 0c             	sub    $0xc,%esp
  8009fe:	25 07 0e 00 00       	and    $0xe07,%eax
  800a03:	50                   	push   %eax
  800a04:	53                   	push   %ebx
  800a05:	6a 00                	push   $0x0
  800a07:	52                   	push   %edx
  800a08:	6a 00                	push   $0x0
  800a0a:	e8 a6 fb ff ff       	call   8005b5 <sys_page_map>
  800a0f:	89 c7                	mov    %eax,%edi
  800a11:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a14:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a16:	85 ff                	test   %edi,%edi
  800a18:	79 1d                	jns    800a37 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a1a:	83 ec 08             	sub    $0x8,%esp
  800a1d:	53                   	push   %ebx
  800a1e:	6a 00                	push   $0x0
  800a20:	e8 d2 fb ff ff       	call   8005f7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a25:	83 c4 08             	add    $0x8,%esp
  800a28:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a2b:	6a 00                	push   $0x0
  800a2d:	e8 c5 fb ff ff       	call   8005f7 <sys_page_unmap>
	return r;
  800a32:	83 c4 10             	add    $0x10,%esp
  800a35:	89 f8                	mov    %edi,%eax
}
  800a37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	83 ec 14             	sub    $0x14,%esp
  800a46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a4c:	50                   	push   %eax
  800a4d:	53                   	push   %ebx
  800a4e:	e8 86 fd ff ff       	call   8007d9 <fd_lookup>
  800a53:	83 c4 08             	add    $0x8,%esp
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	85 c0                	test   %eax,%eax
  800a5a:	78 6d                	js     800ac9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a62:	50                   	push   %eax
  800a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a66:	ff 30                	pushl  (%eax)
  800a68:	e8 c2 fd ff ff       	call   80082f <dev_lookup>
  800a6d:	83 c4 10             	add    $0x10,%esp
  800a70:	85 c0                	test   %eax,%eax
  800a72:	78 4c                	js     800ac0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a74:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a77:	8b 42 08             	mov    0x8(%edx),%eax
  800a7a:	83 e0 03             	and    $0x3,%eax
  800a7d:	83 f8 01             	cmp    $0x1,%eax
  800a80:	75 21                	jne    800aa3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a82:	a1 04 40 80 00       	mov    0x804004,%eax
  800a87:	8b 40 48             	mov    0x48(%eax),%eax
  800a8a:	83 ec 04             	sub    $0x4,%esp
  800a8d:	53                   	push   %ebx
  800a8e:	50                   	push   %eax
  800a8f:	68 dd 1e 80 00       	push   $0x801edd
  800a94:	e8 61 0a 00 00       	call   8014fa <cprintf>
		return -E_INVAL;
  800a99:	83 c4 10             	add    $0x10,%esp
  800a9c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800aa1:	eb 26                	jmp    800ac9 <read+0x8a>
	}
	if (!dev->dev_read)
  800aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aa6:	8b 40 08             	mov    0x8(%eax),%eax
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	74 17                	je     800ac4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800aad:	83 ec 04             	sub    $0x4,%esp
  800ab0:	ff 75 10             	pushl  0x10(%ebp)
  800ab3:	ff 75 0c             	pushl  0xc(%ebp)
  800ab6:	52                   	push   %edx
  800ab7:	ff d0                	call   *%eax
  800ab9:	89 c2                	mov    %eax,%edx
  800abb:	83 c4 10             	add    $0x10,%esp
  800abe:	eb 09                	jmp    800ac9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac0:	89 c2                	mov    %eax,%edx
  800ac2:	eb 05                	jmp    800ac9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800ac4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800ac9:	89 d0                	mov    %edx,%eax
  800acb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ace:	c9                   	leave  
  800acf:	c3                   	ret    

00800ad0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	83 ec 0c             	sub    $0xc,%esp
  800ad9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800adc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800adf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ae4:	eb 21                	jmp    800b07 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800ae6:	83 ec 04             	sub    $0x4,%esp
  800ae9:	89 f0                	mov    %esi,%eax
  800aeb:	29 d8                	sub    %ebx,%eax
  800aed:	50                   	push   %eax
  800aee:	89 d8                	mov    %ebx,%eax
  800af0:	03 45 0c             	add    0xc(%ebp),%eax
  800af3:	50                   	push   %eax
  800af4:	57                   	push   %edi
  800af5:	e8 45 ff ff ff       	call   800a3f <read>
		if (m < 0)
  800afa:	83 c4 10             	add    $0x10,%esp
  800afd:	85 c0                	test   %eax,%eax
  800aff:	78 10                	js     800b11 <readn+0x41>
			return m;
		if (m == 0)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	74 0a                	je     800b0f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b05:	01 c3                	add    %eax,%ebx
  800b07:	39 f3                	cmp    %esi,%ebx
  800b09:	72 db                	jb     800ae6 <readn+0x16>
  800b0b:	89 d8                	mov    %ebx,%eax
  800b0d:	eb 02                	jmp    800b11 <readn+0x41>
  800b0f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	53                   	push   %ebx
  800b1d:	83 ec 14             	sub    $0x14,%esp
  800b20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b23:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b26:	50                   	push   %eax
  800b27:	53                   	push   %ebx
  800b28:	e8 ac fc ff ff       	call   8007d9 <fd_lookup>
  800b2d:	83 c4 08             	add    $0x8,%esp
  800b30:	89 c2                	mov    %eax,%edx
  800b32:	85 c0                	test   %eax,%eax
  800b34:	78 68                	js     800b9e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3c:	50                   	push   %eax
  800b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b40:	ff 30                	pushl  (%eax)
  800b42:	e8 e8 fc ff ff       	call   80082f <dev_lookup>
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	78 47                	js     800b95 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b51:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b55:	75 21                	jne    800b78 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b57:	a1 04 40 80 00       	mov    0x804004,%eax
  800b5c:	8b 40 48             	mov    0x48(%eax),%eax
  800b5f:	83 ec 04             	sub    $0x4,%esp
  800b62:	53                   	push   %ebx
  800b63:	50                   	push   %eax
  800b64:	68 f9 1e 80 00       	push   $0x801ef9
  800b69:	e8 8c 09 00 00       	call   8014fa <cprintf>
		return -E_INVAL;
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b76:	eb 26                	jmp    800b9e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7b:	8b 52 0c             	mov    0xc(%edx),%edx
  800b7e:	85 d2                	test   %edx,%edx
  800b80:	74 17                	je     800b99 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b82:	83 ec 04             	sub    $0x4,%esp
  800b85:	ff 75 10             	pushl  0x10(%ebp)
  800b88:	ff 75 0c             	pushl  0xc(%ebp)
  800b8b:	50                   	push   %eax
  800b8c:	ff d2                	call   *%edx
  800b8e:	89 c2                	mov    %eax,%edx
  800b90:	83 c4 10             	add    $0x10,%esp
  800b93:	eb 09                	jmp    800b9e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	eb 05                	jmp    800b9e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b99:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b9e:	89 d0                	mov    %edx,%eax
  800ba0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <seek>:

int
seek(int fdnum, off_t offset)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800bae:	50                   	push   %eax
  800baf:	ff 75 08             	pushl  0x8(%ebp)
  800bb2:	e8 22 fc ff ff       	call   8007d9 <fd_lookup>
  800bb7:	83 c4 08             	add    $0x8,%esp
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	78 0e                	js     800bcc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 14             	sub    $0x14,%esp
  800bd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bdb:	50                   	push   %eax
  800bdc:	53                   	push   %ebx
  800bdd:	e8 f7 fb ff ff       	call   8007d9 <fd_lookup>
  800be2:	83 c4 08             	add    $0x8,%esp
  800be5:	89 c2                	mov    %eax,%edx
  800be7:	85 c0                	test   %eax,%eax
  800be9:	78 65                	js     800c50 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800beb:	83 ec 08             	sub    $0x8,%esp
  800bee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf1:	50                   	push   %eax
  800bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf5:	ff 30                	pushl  (%eax)
  800bf7:	e8 33 fc ff ff       	call   80082f <dev_lookup>
  800bfc:	83 c4 10             	add    $0x10,%esp
  800bff:	85 c0                	test   %eax,%eax
  800c01:	78 44                	js     800c47 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c06:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c0a:	75 21                	jne    800c2d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c0c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c11:	8b 40 48             	mov    0x48(%eax),%eax
  800c14:	83 ec 04             	sub    $0x4,%esp
  800c17:	53                   	push   %ebx
  800c18:	50                   	push   %eax
  800c19:	68 bc 1e 80 00       	push   $0x801ebc
  800c1e:	e8 d7 08 00 00       	call   8014fa <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c2b:	eb 23                	jmp    800c50 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c30:	8b 52 18             	mov    0x18(%edx),%edx
  800c33:	85 d2                	test   %edx,%edx
  800c35:	74 14                	je     800c4b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c37:	83 ec 08             	sub    $0x8,%esp
  800c3a:	ff 75 0c             	pushl  0xc(%ebp)
  800c3d:	50                   	push   %eax
  800c3e:	ff d2                	call   *%edx
  800c40:	89 c2                	mov    %eax,%edx
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	eb 09                	jmp    800c50 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c47:	89 c2                	mov    %eax,%edx
  800c49:	eb 05                	jmp    800c50 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c4b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c50:	89 d0                	mov    %edx,%eax
  800c52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c55:	c9                   	leave  
  800c56:	c3                   	ret    

00800c57 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 14             	sub    $0x14,%esp
  800c5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c64:	50                   	push   %eax
  800c65:	ff 75 08             	pushl  0x8(%ebp)
  800c68:	e8 6c fb ff ff       	call   8007d9 <fd_lookup>
  800c6d:	83 c4 08             	add    $0x8,%esp
  800c70:	89 c2                	mov    %eax,%edx
  800c72:	85 c0                	test   %eax,%eax
  800c74:	78 58                	js     800cce <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c76:	83 ec 08             	sub    $0x8,%esp
  800c79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c7c:	50                   	push   %eax
  800c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c80:	ff 30                	pushl  (%eax)
  800c82:	e8 a8 fb ff ff       	call   80082f <dev_lookup>
  800c87:	83 c4 10             	add    $0x10,%esp
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	78 37                	js     800cc5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c91:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c95:	74 32                	je     800cc9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c97:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c9a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ca1:	00 00 00 
	stat->st_isdir = 0;
  800ca4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cab:	00 00 00 
	stat->st_dev = dev;
  800cae:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800cb4:	83 ec 08             	sub    $0x8,%esp
  800cb7:	53                   	push   %ebx
  800cb8:	ff 75 f0             	pushl  -0x10(%ebp)
  800cbb:	ff 50 14             	call   *0x14(%eax)
  800cbe:	89 c2                	mov    %eax,%edx
  800cc0:	83 c4 10             	add    $0x10,%esp
  800cc3:	eb 09                	jmp    800cce <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cc5:	89 c2                	mov    %eax,%edx
  800cc7:	eb 05                	jmp    800cce <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800cc9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800cce:	89 d0                	mov    %edx,%eax
  800cd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cd3:	c9                   	leave  
  800cd4:	c3                   	ret    

00800cd5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800cda:	83 ec 08             	sub    $0x8,%esp
  800cdd:	6a 00                	push   $0x0
  800cdf:	ff 75 08             	pushl  0x8(%ebp)
  800ce2:	e8 b7 01 00 00       	call   800e9e <open>
  800ce7:	89 c3                	mov    %eax,%ebx
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	85 c0                	test   %eax,%eax
  800cee:	78 1b                	js     800d0b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800cf0:	83 ec 08             	sub    $0x8,%esp
  800cf3:	ff 75 0c             	pushl  0xc(%ebp)
  800cf6:	50                   	push   %eax
  800cf7:	e8 5b ff ff ff       	call   800c57 <fstat>
  800cfc:	89 c6                	mov    %eax,%esi
	close(fd);
  800cfe:	89 1c 24             	mov    %ebx,(%esp)
  800d01:	e8 fd fb ff ff       	call   800903 <close>
	return r;
  800d06:	83 c4 10             	add    $0x10,%esp
  800d09:	89 f0                	mov    %esi,%eax
}
  800d0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	89 c6                	mov    %eax,%esi
  800d19:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d1b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d22:	75 12                	jne    800d36 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	6a 01                	push   $0x1
  800d29:	e8 19 0e 00 00       	call   801b47 <ipc_find_env>
  800d2e:	a3 00 40 80 00       	mov    %eax,0x804000
  800d33:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d36:	6a 07                	push   $0x7
  800d38:	68 00 50 80 00       	push   $0x805000
  800d3d:	56                   	push   %esi
  800d3e:	ff 35 00 40 80 00    	pushl  0x804000
  800d44:	e8 72 0d 00 00       	call   801abb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d49:	83 c4 0c             	add    $0xc,%esp
  800d4c:	6a 00                	push   $0x0
  800d4e:	53                   	push   %ebx
  800d4f:	6a 00                	push   $0x0
  800d51:	e8 f0 0c 00 00       	call   801a46 <ipc_recv>
}
  800d56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	8b 40 0c             	mov    0xc(%eax),%eax
  800d69:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d71:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d76:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800d80:	e8 8d ff ff ff       	call   800d12 <fsipc>
}
  800d85:	c9                   	leave  
  800d86:	c3                   	ret    

00800d87 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	8b 40 0c             	mov    0xc(%eax),%eax
  800d93:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d98:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800da2:	e8 6b ff ff ff       	call   800d12 <fsipc>
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	53                   	push   %ebx
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	8b 40 0c             	mov    0xc(%eax),%eax
  800db9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800dbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc3:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc8:	e8 45 ff ff ff       	call   800d12 <fsipc>
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	78 2c                	js     800dfd <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800dd1:	83 ec 08             	sub    $0x8,%esp
  800dd4:	68 00 50 80 00       	push   $0x805000
  800dd9:	53                   	push   %ebx
  800dda:	e8 90 f3 ff ff       	call   80016f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ddf:	a1 80 50 80 00       	mov    0x805080,%eax
  800de4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dea:	a1 84 50 80 00       	mov    0x805084,%eax
  800def:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800e08:	68 28 1f 80 00       	push   $0x801f28
  800e0d:	68 90 00 00 00       	push   $0x90
  800e12:	68 46 1f 80 00       	push   $0x801f46
  800e17:	e8 05 06 00 00       	call   801421 <_panic>

00800e1c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	8b 40 0c             	mov    0xc(%eax),%eax
  800e2a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e2f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e35:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800e3f:	e8 ce fe ff ff       	call   800d12 <fsipc>
  800e44:	89 c3                	mov    %eax,%ebx
  800e46:	85 c0                	test   %eax,%eax
  800e48:	78 4b                	js     800e95 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e4a:	39 c6                	cmp    %eax,%esi
  800e4c:	73 16                	jae    800e64 <devfile_read+0x48>
  800e4e:	68 51 1f 80 00       	push   $0x801f51
  800e53:	68 58 1f 80 00       	push   $0x801f58
  800e58:	6a 7c                	push   $0x7c
  800e5a:	68 46 1f 80 00       	push   $0x801f46
  800e5f:	e8 bd 05 00 00       	call   801421 <_panic>
	assert(r <= PGSIZE);
  800e64:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e69:	7e 16                	jle    800e81 <devfile_read+0x65>
  800e6b:	68 6d 1f 80 00       	push   $0x801f6d
  800e70:	68 58 1f 80 00       	push   $0x801f58
  800e75:	6a 7d                	push   $0x7d
  800e77:	68 46 1f 80 00       	push   $0x801f46
  800e7c:	e8 a0 05 00 00       	call   801421 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e81:	83 ec 04             	sub    $0x4,%esp
  800e84:	50                   	push   %eax
  800e85:	68 00 50 80 00       	push   $0x805000
  800e8a:	ff 75 0c             	pushl  0xc(%ebp)
  800e8d:	e8 6f f4 ff ff       	call   800301 <memmove>
	return r;
  800e92:	83 c4 10             	add    $0x10,%esp
}
  800e95:	89 d8                	mov    %ebx,%eax
  800e97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9a:	5b                   	pop    %ebx
  800e9b:	5e                   	pop    %esi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	53                   	push   %ebx
  800ea2:	83 ec 20             	sub    $0x20,%esp
  800ea5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ea8:	53                   	push   %ebx
  800ea9:	e8 88 f2 ff ff       	call   800136 <strlen>
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800eb6:	7f 67                	jg     800f1f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebe:	50                   	push   %eax
  800ebf:	e8 c6 f8 ff ff       	call   80078a <fd_alloc>
  800ec4:	83 c4 10             	add    $0x10,%esp
		return r;
  800ec7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	78 57                	js     800f24 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ecd:	83 ec 08             	sub    $0x8,%esp
  800ed0:	53                   	push   %ebx
  800ed1:	68 00 50 80 00       	push   $0x805000
  800ed6:	e8 94 f2 ff ff       	call   80016f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ede:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ee3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eeb:	e8 22 fe ff ff       	call   800d12 <fsipc>
  800ef0:	89 c3                	mov    %eax,%ebx
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	79 14                	jns    800f0d <open+0x6f>
		fd_close(fd, 0);
  800ef9:	83 ec 08             	sub    $0x8,%esp
  800efc:	6a 00                	push   $0x0
  800efe:	ff 75 f4             	pushl  -0xc(%ebp)
  800f01:	e8 7c f9 ff ff       	call   800882 <fd_close>
		return r;
  800f06:	83 c4 10             	add    $0x10,%esp
  800f09:	89 da                	mov    %ebx,%edx
  800f0b:	eb 17                	jmp    800f24 <open+0x86>
	}

	return fd2num(fd);
  800f0d:	83 ec 0c             	sub    $0xc,%esp
  800f10:	ff 75 f4             	pushl  -0xc(%ebp)
  800f13:	e8 4b f8 ff ff       	call   800763 <fd2num>
  800f18:	89 c2                	mov    %eax,%edx
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	eb 05                	jmp    800f24 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f1f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f24:	89 d0                	mov    %edx,%eax
  800f26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f29:	c9                   	leave  
  800f2a:	c3                   	ret    

00800f2b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f31:	ba 00 00 00 00       	mov    $0x0,%edx
  800f36:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3b:	e8 d2 fd ff ff       	call   800d12 <fsipc>
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	ff 75 08             	pushl  0x8(%ebp)
  800f50:	e8 1e f8 ff ff       	call   800773 <fd2data>
  800f55:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f57:	83 c4 08             	add    $0x8,%esp
  800f5a:	68 79 1f 80 00       	push   $0x801f79
  800f5f:	53                   	push   %ebx
  800f60:	e8 0a f2 ff ff       	call   80016f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f65:	8b 46 04             	mov    0x4(%esi),%eax
  800f68:	2b 06                	sub    (%esi),%eax
  800f6a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f70:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f77:	00 00 00 
	stat->st_dev = &devpipe;
  800f7a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f81:	30 80 00 
	return 0;
}
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
  800f89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	53                   	push   %ebx
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f9a:	53                   	push   %ebx
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 55 f6 ff ff       	call   8005f7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800fa2:	89 1c 24             	mov    %ebx,(%esp)
  800fa5:	e8 c9 f7 ff ff       	call   800773 <fd2data>
  800faa:	83 c4 08             	add    $0x8,%esp
  800fad:	50                   	push   %eax
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 42 f6 ff ff       	call   8005f7 <sys_page_unmap>
}
  800fb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 1c             	sub    $0x1c,%esp
  800fc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fc6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800fc8:	a1 04 40 80 00       	mov    0x804004,%eax
  800fcd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800fd0:	83 ec 0c             	sub    $0xc,%esp
  800fd3:	ff 75 e0             	pushl  -0x20(%ebp)
  800fd6:	e8 a5 0b 00 00       	call   801b80 <pageref>
  800fdb:	89 c3                	mov    %eax,%ebx
  800fdd:	89 3c 24             	mov    %edi,(%esp)
  800fe0:	e8 9b 0b 00 00       	call   801b80 <pageref>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	39 c3                	cmp    %eax,%ebx
  800fea:	0f 94 c1             	sete   %cl
  800fed:	0f b6 c9             	movzbl %cl,%ecx
  800ff0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800ff3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ff9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800ffc:	39 ce                	cmp    %ecx,%esi
  800ffe:	74 1b                	je     80101b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801000:	39 c3                	cmp    %eax,%ebx
  801002:	75 c4                	jne    800fc8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801004:	8b 42 58             	mov    0x58(%edx),%eax
  801007:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100a:	50                   	push   %eax
  80100b:	56                   	push   %esi
  80100c:	68 80 1f 80 00       	push   $0x801f80
  801011:	e8 e4 04 00 00       	call   8014fa <cprintf>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	eb ad                	jmp    800fc8 <_pipeisclosed+0xe>
	}
}
  80101b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80101e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	57                   	push   %edi
  80102a:	56                   	push   %esi
  80102b:	53                   	push   %ebx
  80102c:	83 ec 28             	sub    $0x28,%esp
  80102f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801032:	56                   	push   %esi
  801033:	e8 3b f7 ff ff       	call   800773 <fd2data>
  801038:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	bf 00 00 00 00       	mov    $0x0,%edi
  801042:	eb 4b                	jmp    80108f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801044:	89 da                	mov    %ebx,%edx
  801046:	89 f0                	mov    %esi,%eax
  801048:	e8 6d ff ff ff       	call   800fba <_pipeisclosed>
  80104d:	85 c0                	test   %eax,%eax
  80104f:	75 48                	jne    801099 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801051:	e8 fd f4 ff ff       	call   800553 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801056:	8b 43 04             	mov    0x4(%ebx),%eax
  801059:	8b 0b                	mov    (%ebx),%ecx
  80105b:	8d 51 20             	lea    0x20(%ecx),%edx
  80105e:	39 d0                	cmp    %edx,%eax
  801060:	73 e2                	jae    801044 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801062:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801065:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801069:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80106c:	89 c2                	mov    %eax,%edx
  80106e:	c1 fa 1f             	sar    $0x1f,%edx
  801071:	89 d1                	mov    %edx,%ecx
  801073:	c1 e9 1b             	shr    $0x1b,%ecx
  801076:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801079:	83 e2 1f             	and    $0x1f,%edx
  80107c:	29 ca                	sub    %ecx,%edx
  80107e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801082:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801086:	83 c0 01             	add    $0x1,%eax
  801089:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80108c:	83 c7 01             	add    $0x1,%edi
  80108f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801092:	75 c2                	jne    801056 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801094:	8b 45 10             	mov    0x10(%ebp),%eax
  801097:	eb 05                	jmp    80109e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801099:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 18             	sub    $0x18,%esp
  8010af:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8010b2:	57                   	push   %edi
  8010b3:	e8 bb f6 ff ff       	call   800773 <fd2data>
  8010b8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c2:	eb 3d                	jmp    801101 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8010c4:	85 db                	test   %ebx,%ebx
  8010c6:	74 04                	je     8010cc <devpipe_read+0x26>
				return i;
  8010c8:	89 d8                	mov    %ebx,%eax
  8010ca:	eb 44                	jmp    801110 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8010cc:	89 f2                	mov    %esi,%edx
  8010ce:	89 f8                	mov    %edi,%eax
  8010d0:	e8 e5 fe ff ff       	call   800fba <_pipeisclosed>
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	75 32                	jne    80110b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8010d9:	e8 75 f4 ff ff       	call   800553 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010de:	8b 06                	mov    (%esi),%eax
  8010e0:	3b 46 04             	cmp    0x4(%esi),%eax
  8010e3:	74 df                	je     8010c4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010e5:	99                   	cltd   
  8010e6:	c1 ea 1b             	shr    $0x1b,%edx
  8010e9:	01 d0                	add    %edx,%eax
  8010eb:	83 e0 1f             	and    $0x1f,%eax
  8010ee:	29 d0                	sub    %edx,%eax
  8010f0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010fb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010fe:	83 c3 01             	add    $0x1,%ebx
  801101:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801104:	75 d8                	jne    8010de <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801106:	8b 45 10             	mov    0x10(%ebp),%eax
  801109:	eb 05                	jmp    801110 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80110b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	e8 61 f6 ff ff       	call   80078a <fd_alloc>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	85 c0                	test   %eax,%eax
  801130:	0f 88 2c 01 00 00    	js     801262 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801136:	83 ec 04             	sub    $0x4,%esp
  801139:	68 07 04 00 00       	push   $0x407
  80113e:	ff 75 f4             	pushl  -0xc(%ebp)
  801141:	6a 00                	push   $0x0
  801143:	e8 2a f4 ff ff       	call   800572 <sys_page_alloc>
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	89 c2                	mov    %eax,%edx
  80114d:	85 c0                	test   %eax,%eax
  80114f:	0f 88 0d 01 00 00    	js     801262 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80115b:	50                   	push   %eax
  80115c:	e8 29 f6 ff ff       	call   80078a <fd_alloc>
  801161:	89 c3                	mov    %eax,%ebx
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	0f 88 e2 00 00 00    	js     801250 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	68 07 04 00 00       	push   $0x407
  801176:	ff 75 f0             	pushl  -0x10(%ebp)
  801179:	6a 00                	push   $0x0
  80117b:	e8 f2 f3 ff ff       	call   800572 <sys_page_alloc>
  801180:	89 c3                	mov    %eax,%ebx
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	0f 88 c3 00 00 00    	js     801250 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80118d:	83 ec 0c             	sub    $0xc,%esp
  801190:	ff 75 f4             	pushl  -0xc(%ebp)
  801193:	e8 db f5 ff ff       	call   800773 <fd2data>
  801198:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80119a:	83 c4 0c             	add    $0xc,%esp
  80119d:	68 07 04 00 00       	push   $0x407
  8011a2:	50                   	push   %eax
  8011a3:	6a 00                	push   $0x0
  8011a5:	e8 c8 f3 ff ff       	call   800572 <sys_page_alloc>
  8011aa:	89 c3                	mov    %eax,%ebx
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	0f 88 89 00 00 00    	js     801240 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8011bd:	e8 b1 f5 ff ff       	call   800773 <fd2data>
  8011c2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8011c9:	50                   	push   %eax
  8011ca:	6a 00                	push   $0x0
  8011cc:	56                   	push   %esi
  8011cd:	6a 00                	push   $0x0
  8011cf:	e8 e1 f3 ff ff       	call   8005b5 <sys_page_map>
  8011d4:	89 c3                	mov    %eax,%ebx
  8011d6:	83 c4 20             	add    $0x20,%esp
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 55                	js     801232 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011dd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011eb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011f2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801200:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	ff 75 f4             	pushl  -0xc(%ebp)
  80120d:	e8 51 f5 ff ff       	call   800763 <fd2num>
  801212:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801215:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801217:	83 c4 04             	add    $0x4,%esp
  80121a:	ff 75 f0             	pushl  -0x10(%ebp)
  80121d:	e8 41 f5 ff ff       	call   800763 <fd2num>
  801222:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801225:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	ba 00 00 00 00       	mov    $0x0,%edx
  801230:	eb 30                	jmp    801262 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801232:	83 ec 08             	sub    $0x8,%esp
  801235:	56                   	push   %esi
  801236:	6a 00                	push   $0x0
  801238:	e8 ba f3 ff ff       	call   8005f7 <sys_page_unmap>
  80123d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	ff 75 f0             	pushl  -0x10(%ebp)
  801246:	6a 00                	push   $0x0
  801248:	e8 aa f3 ff ff       	call   8005f7 <sys_page_unmap>
  80124d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	ff 75 f4             	pushl  -0xc(%ebp)
  801256:	6a 00                	push   $0x0
  801258:	e8 9a f3 ff ff       	call   8005f7 <sys_page_unmap>
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801262:	89 d0                	mov    %edx,%eax
  801264:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    

0080126b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	ff 75 08             	pushl  0x8(%ebp)
  801278:	e8 5c f5 ff ff       	call   8007d9 <fd_lookup>
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	85 c0                	test   %eax,%eax
  801282:	78 18                	js     80129c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801284:	83 ec 0c             	sub    $0xc,%esp
  801287:	ff 75 f4             	pushl  -0xc(%ebp)
  80128a:	e8 e4 f4 ff ff       	call   800773 <fd2data>
	return _pipeisclosed(fd, p);
  80128f:	89 c2                	mov    %eax,%edx
  801291:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801294:	e8 21 fd ff ff       	call   800fba <_pipeisclosed>
  801299:	83 c4 10             	add    $0x10,%esp
}
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    

0080129e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8012ae:	68 98 1f 80 00       	push   $0x801f98
  8012b3:	ff 75 0c             	pushl  0xc(%ebp)
  8012b6:	e8 b4 ee ff ff       	call   80016f <strcpy>
	return 0;
}
  8012bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	57                   	push   %edi
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012ce:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012d3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012d9:	eb 2d                	jmp    801308 <devcons_write+0x46>
		m = n - tot;
  8012db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012de:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012e0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012e3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012e8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012eb:	83 ec 04             	sub    $0x4,%esp
  8012ee:	53                   	push   %ebx
  8012ef:	03 45 0c             	add    0xc(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	57                   	push   %edi
  8012f4:	e8 08 f0 ff ff       	call   800301 <memmove>
		sys_cputs(buf, m);
  8012f9:	83 c4 08             	add    $0x8,%esp
  8012fc:	53                   	push   %ebx
  8012fd:	57                   	push   %edi
  8012fe:	e8 b3 f1 ff ff       	call   8004b6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801303:	01 de                	add    %ebx,%esi
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	89 f0                	mov    %esi,%eax
  80130a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80130d:	72 cc                	jb     8012db <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80130f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801312:	5b                   	pop    %ebx
  801313:	5e                   	pop    %esi
  801314:	5f                   	pop    %edi
  801315:	5d                   	pop    %ebp
  801316:	c3                   	ret    

00801317 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801322:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801326:	74 2a                	je     801352 <devcons_read+0x3b>
  801328:	eb 05                	jmp    80132f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80132a:	e8 24 f2 ff ff       	call   800553 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80132f:	e8 a0 f1 ff ff       	call   8004d4 <sys_cgetc>
  801334:	85 c0                	test   %eax,%eax
  801336:	74 f2                	je     80132a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 16                	js     801352 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80133c:	83 f8 04             	cmp    $0x4,%eax
  80133f:	74 0c                	je     80134d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801341:	8b 55 0c             	mov    0xc(%ebp),%edx
  801344:	88 02                	mov    %al,(%edx)
	return 1;
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	eb 05                	jmp    801352 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80134d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80135a:	8b 45 08             	mov    0x8(%ebp),%eax
  80135d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801360:	6a 01                	push   $0x1
  801362:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	e8 4b f1 ff ff       	call   8004b6 <sys_cputs>
}
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <getchar>:

int
getchar(void)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801376:	6a 01                	push   $0x1
  801378:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	6a 00                	push   $0x0
  80137e:	e8 bc f6 ff ff       	call   800a3f <read>
	if (r < 0)
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 0f                	js     801399 <getchar+0x29>
		return r;
	if (r < 1)
  80138a:	85 c0                	test   %eax,%eax
  80138c:	7e 06                	jle    801394 <getchar+0x24>
		return -E_EOF;
	return c;
  80138e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801392:	eb 05                	jmp    801399 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801394:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a4:	50                   	push   %eax
  8013a5:	ff 75 08             	pushl  0x8(%ebp)
  8013a8:	e8 2c f4 ff ff       	call   8007d9 <fd_lookup>
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 11                	js     8013c5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8013b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013bd:	39 10                	cmp    %edx,(%eax)
  8013bf:	0f 94 c0             	sete   %al
  8013c2:	0f b6 c0             	movzbl %al,%eax
}
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <opencons>:

int
opencons(void)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	e8 b4 f3 ff ff       	call   80078a <fd_alloc>
  8013d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8013d9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 3e                	js     80141d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	68 07 04 00 00       	push   $0x407
  8013e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 81 f1 ff ff       	call   800572 <sys_page_alloc>
  8013f1:	83 c4 10             	add    $0x10,%esp
		return r;
  8013f4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 23                	js     80141d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013fa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801400:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801403:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801405:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801408:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80140f:	83 ec 0c             	sub    $0xc,%esp
  801412:	50                   	push   %eax
  801413:	e8 4b f3 ff ff       	call   800763 <fd2num>
  801418:	89 c2                	mov    %eax,%edx
  80141a:	83 c4 10             	add    $0x10,%esp
}
  80141d:	89 d0                	mov    %edx,%eax
  80141f:	c9                   	leave  
  801420:	c3                   	ret    

00801421 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	56                   	push   %esi
  801425:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801426:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801429:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80142f:	e8 00 f1 ff ff       	call   800534 <sys_getenvid>
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	ff 75 0c             	pushl  0xc(%ebp)
  80143a:	ff 75 08             	pushl  0x8(%ebp)
  80143d:	56                   	push   %esi
  80143e:	50                   	push   %eax
  80143f:	68 a4 1f 80 00       	push   $0x801fa4
  801444:	e8 b1 00 00 00       	call   8014fa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801449:	83 c4 18             	add    $0x18,%esp
  80144c:	53                   	push   %ebx
  80144d:	ff 75 10             	pushl  0x10(%ebp)
  801450:	e8 54 00 00 00       	call   8014a9 <vcprintf>
	cprintf("\n");
  801455:	c7 04 24 91 1f 80 00 	movl   $0x801f91,(%esp)
  80145c:	e8 99 00 00 00       	call   8014fa <cprintf>
  801461:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801464:	cc                   	int3   
  801465:	eb fd                	jmp    801464 <_panic+0x43>

00801467 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	53                   	push   %ebx
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801471:	8b 13                	mov    (%ebx),%edx
  801473:	8d 42 01             	lea    0x1(%edx),%eax
  801476:	89 03                	mov    %eax,(%ebx)
  801478:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80147f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801484:	75 1a                	jne    8014a0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	68 ff 00 00 00       	push   $0xff
  80148e:	8d 43 08             	lea    0x8(%ebx),%eax
  801491:	50                   	push   %eax
  801492:	e8 1f f0 ff ff       	call   8004b6 <sys_cputs>
		b->idx = 0;
  801497:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80149d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8014a0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8014b2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8014b9:	00 00 00 
	b.cnt = 0;
  8014bc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8014c3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8014c6:	ff 75 0c             	pushl  0xc(%ebp)
  8014c9:	ff 75 08             	pushl  0x8(%ebp)
  8014cc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	68 67 14 80 00       	push   $0x801467
  8014d8:	e8 54 01 00 00       	call   801631 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014dd:	83 c4 08             	add    $0x8,%esp
  8014e0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	e8 c4 ef ff ff       	call   8004b6 <sys_cputs>

	return b.cnt;
}
  8014f2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801500:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801503:	50                   	push   %eax
  801504:	ff 75 08             	pushl  0x8(%ebp)
  801507:	e8 9d ff ff ff       	call   8014a9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	83 ec 1c             	sub    $0x1c,%esp
  801517:	89 c7                	mov    %eax,%edi
  801519:	89 d6                	mov    %edx,%esi
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801524:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801527:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80152a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801532:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801535:	39 d3                	cmp    %edx,%ebx
  801537:	72 05                	jb     80153e <printnum+0x30>
  801539:	39 45 10             	cmp    %eax,0x10(%ebp)
  80153c:	77 45                	ja     801583 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	ff 75 18             	pushl  0x18(%ebp)
  801544:	8b 45 14             	mov    0x14(%ebp),%eax
  801547:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80154a:	53                   	push   %ebx
  80154b:	ff 75 10             	pushl  0x10(%ebp)
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	ff 75 e4             	pushl  -0x1c(%ebp)
  801554:	ff 75 e0             	pushl  -0x20(%ebp)
  801557:	ff 75 dc             	pushl  -0x24(%ebp)
  80155a:	ff 75 d8             	pushl  -0x28(%ebp)
  80155d:	e8 5e 06 00 00       	call   801bc0 <__udivdi3>
  801562:	83 c4 18             	add    $0x18,%esp
  801565:	52                   	push   %edx
  801566:	50                   	push   %eax
  801567:	89 f2                	mov    %esi,%edx
  801569:	89 f8                	mov    %edi,%eax
  80156b:	e8 9e ff ff ff       	call   80150e <printnum>
  801570:	83 c4 20             	add    $0x20,%esp
  801573:	eb 18                	jmp    80158d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	56                   	push   %esi
  801579:	ff 75 18             	pushl  0x18(%ebp)
  80157c:	ff d7                	call   *%edi
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb 03                	jmp    801586 <printnum+0x78>
  801583:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801586:	83 eb 01             	sub    $0x1,%ebx
  801589:	85 db                	test   %ebx,%ebx
  80158b:	7f e8                	jg     801575 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	56                   	push   %esi
  801591:	83 ec 04             	sub    $0x4,%esp
  801594:	ff 75 e4             	pushl  -0x1c(%ebp)
  801597:	ff 75 e0             	pushl  -0x20(%ebp)
  80159a:	ff 75 dc             	pushl  -0x24(%ebp)
  80159d:	ff 75 d8             	pushl  -0x28(%ebp)
  8015a0:	e8 4b 07 00 00       	call   801cf0 <__umoddi3>
  8015a5:	83 c4 14             	add    $0x14,%esp
  8015a8:	0f be 80 c7 1f 80 00 	movsbl 0x801fc7(%eax),%eax
  8015af:	50                   	push   %eax
  8015b0:	ff d7                	call   *%edi
}
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5f                   	pop    %edi
  8015bb:	5d                   	pop    %ebp
  8015bc:	c3                   	ret    

008015bd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8015c0:	83 fa 01             	cmp    $0x1,%edx
  8015c3:	7e 0e                	jle    8015d3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8015c5:	8b 10                	mov    (%eax),%edx
  8015c7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8015ca:	89 08                	mov    %ecx,(%eax)
  8015cc:	8b 02                	mov    (%edx),%eax
  8015ce:	8b 52 04             	mov    0x4(%edx),%edx
  8015d1:	eb 22                	jmp    8015f5 <getuint+0x38>
	else if (lflag)
  8015d3:	85 d2                	test   %edx,%edx
  8015d5:	74 10                	je     8015e7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015d7:	8b 10                	mov    (%eax),%edx
  8015d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015dc:	89 08                	mov    %ecx,(%eax)
  8015de:	8b 02                	mov    (%edx),%eax
  8015e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e5:	eb 0e                	jmp    8015f5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015e7:	8b 10                	mov    (%eax),%edx
  8015e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015ec:	89 08                	mov    %ecx,(%eax)
  8015ee:	8b 02                	mov    (%edx),%eax
  8015f0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    

008015f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015fd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801601:	8b 10                	mov    (%eax),%edx
  801603:	3b 50 04             	cmp    0x4(%eax),%edx
  801606:	73 0a                	jae    801612 <sprintputch+0x1b>
		*b->buf++ = ch;
  801608:	8d 4a 01             	lea    0x1(%edx),%ecx
  80160b:	89 08                	mov    %ecx,(%eax)
  80160d:	8b 45 08             	mov    0x8(%ebp),%eax
  801610:	88 02                	mov    %al,(%edx)
}
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80161a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80161d:	50                   	push   %eax
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	ff 75 08             	pushl  0x8(%ebp)
  801627:	e8 05 00 00 00       	call   801631 <vprintfmt>
	va_end(ap);
}
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	57                   	push   %edi
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	83 ec 2c             	sub    $0x2c,%esp
  80163a:	8b 75 08             	mov    0x8(%ebp),%esi
  80163d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801640:	8b 7d 10             	mov    0x10(%ebp),%edi
  801643:	eb 12                	jmp    801657 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801645:	85 c0                	test   %eax,%eax
  801647:	0f 84 89 03 00 00    	je     8019d6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	53                   	push   %ebx
  801651:	50                   	push   %eax
  801652:	ff d6                	call   *%esi
  801654:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801657:	83 c7 01             	add    $0x1,%edi
  80165a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80165e:	83 f8 25             	cmp    $0x25,%eax
  801661:	75 e2                	jne    801645 <vprintfmt+0x14>
  801663:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801667:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80166e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801675:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80167c:	ba 00 00 00 00       	mov    $0x0,%edx
  801681:	eb 07                	jmp    80168a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801683:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801686:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80168a:	8d 47 01             	lea    0x1(%edi),%eax
  80168d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801690:	0f b6 07             	movzbl (%edi),%eax
  801693:	0f b6 c8             	movzbl %al,%ecx
  801696:	83 e8 23             	sub    $0x23,%eax
  801699:	3c 55                	cmp    $0x55,%al
  80169b:	0f 87 1a 03 00 00    	ja     8019bb <vprintfmt+0x38a>
  8016a1:	0f b6 c0             	movzbl %al,%eax
  8016a4:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  8016ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8016ae:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8016b2:	eb d6                	jmp    80168a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8016bf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8016c2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8016c6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8016c9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8016cc:	83 fa 09             	cmp    $0x9,%edx
  8016cf:	77 39                	ja     80170a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8016d1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8016d4:	eb e9                	jmp    8016bf <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d9:	8d 48 04             	lea    0x4(%eax),%ecx
  8016dc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016df:	8b 00                	mov    (%eax),%eax
  8016e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016e7:	eb 27                	jmp    801710 <vprintfmt+0xdf>
  8016e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016f3:	0f 49 c8             	cmovns %eax,%ecx
  8016f6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016fc:	eb 8c                	jmp    80168a <vprintfmt+0x59>
  8016fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801701:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801708:	eb 80                	jmp    80168a <vprintfmt+0x59>
  80170a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80170d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801710:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801714:	0f 89 70 ff ff ff    	jns    80168a <vprintfmt+0x59>
				width = precision, precision = -1;
  80171a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80171d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801720:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801727:	e9 5e ff ff ff       	jmp    80168a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80172c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80172f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801732:	e9 53 ff ff ff       	jmp    80168a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801737:	8b 45 14             	mov    0x14(%ebp),%eax
  80173a:	8d 50 04             	lea    0x4(%eax),%edx
  80173d:	89 55 14             	mov    %edx,0x14(%ebp)
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	53                   	push   %ebx
  801744:	ff 30                	pushl  (%eax)
  801746:	ff d6                	call   *%esi
			break;
  801748:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80174e:	e9 04 ff ff ff       	jmp    801657 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801753:	8b 45 14             	mov    0x14(%ebp),%eax
  801756:	8d 50 04             	lea    0x4(%eax),%edx
  801759:	89 55 14             	mov    %edx,0x14(%ebp)
  80175c:	8b 00                	mov    (%eax),%eax
  80175e:	99                   	cltd   
  80175f:	31 d0                	xor    %edx,%eax
  801761:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801763:	83 f8 0f             	cmp    $0xf,%eax
  801766:	7f 0b                	jg     801773 <vprintfmt+0x142>
  801768:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  80176f:	85 d2                	test   %edx,%edx
  801771:	75 18                	jne    80178b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801773:	50                   	push   %eax
  801774:	68 df 1f 80 00       	push   $0x801fdf
  801779:	53                   	push   %ebx
  80177a:	56                   	push   %esi
  80177b:	e8 94 fe ff ff       	call   801614 <printfmt>
  801780:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801783:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801786:	e9 cc fe ff ff       	jmp    801657 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80178b:	52                   	push   %edx
  80178c:	68 6a 1f 80 00       	push   $0x801f6a
  801791:	53                   	push   %ebx
  801792:	56                   	push   %esi
  801793:	e8 7c fe ff ff       	call   801614 <printfmt>
  801798:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80179e:	e9 b4 fe ff ff       	jmp    801657 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8017a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a6:	8d 50 04             	lea    0x4(%eax),%edx
  8017a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ac:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8017ae:	85 ff                	test   %edi,%edi
  8017b0:	b8 d8 1f 80 00       	mov    $0x801fd8,%eax
  8017b5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8017b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017bc:	0f 8e 94 00 00 00    	jle    801856 <vprintfmt+0x225>
  8017c2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8017c6:	0f 84 98 00 00 00    	je     801864 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	ff 75 d0             	pushl  -0x30(%ebp)
  8017d2:	57                   	push   %edi
  8017d3:	e8 76 e9 ff ff       	call   80014e <strnlen>
  8017d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017db:	29 c1                	sub    %eax,%ecx
  8017dd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017e0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017e3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ea:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017ed:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017ef:	eb 0f                	jmp    801800 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	53                   	push   %ebx
  8017f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8017f8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017fa:	83 ef 01             	sub    $0x1,%edi
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	85 ff                	test   %edi,%edi
  801802:	7f ed                	jg     8017f1 <vprintfmt+0x1c0>
  801804:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801807:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80180a:	85 c9                	test   %ecx,%ecx
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
  801811:	0f 49 c1             	cmovns %ecx,%eax
  801814:	29 c1                	sub    %eax,%ecx
  801816:	89 75 08             	mov    %esi,0x8(%ebp)
  801819:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80181c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80181f:	89 cb                	mov    %ecx,%ebx
  801821:	eb 4d                	jmp    801870 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801823:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801827:	74 1b                	je     801844 <vprintfmt+0x213>
  801829:	0f be c0             	movsbl %al,%eax
  80182c:	83 e8 20             	sub    $0x20,%eax
  80182f:	83 f8 5e             	cmp    $0x5e,%eax
  801832:	76 10                	jbe    801844 <vprintfmt+0x213>
					putch('?', putdat);
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	6a 3f                	push   $0x3f
  80183c:	ff 55 08             	call   *0x8(%ebp)
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	eb 0d                	jmp    801851 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	ff 75 0c             	pushl  0xc(%ebp)
  80184a:	52                   	push   %edx
  80184b:	ff 55 08             	call   *0x8(%ebp)
  80184e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801851:	83 eb 01             	sub    $0x1,%ebx
  801854:	eb 1a                	jmp    801870 <vprintfmt+0x23f>
  801856:	89 75 08             	mov    %esi,0x8(%ebp)
  801859:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80185c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80185f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801862:	eb 0c                	jmp    801870 <vprintfmt+0x23f>
  801864:	89 75 08             	mov    %esi,0x8(%ebp)
  801867:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80186a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80186d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801870:	83 c7 01             	add    $0x1,%edi
  801873:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801877:	0f be d0             	movsbl %al,%edx
  80187a:	85 d2                	test   %edx,%edx
  80187c:	74 23                	je     8018a1 <vprintfmt+0x270>
  80187e:	85 f6                	test   %esi,%esi
  801880:	78 a1                	js     801823 <vprintfmt+0x1f2>
  801882:	83 ee 01             	sub    $0x1,%esi
  801885:	79 9c                	jns    801823 <vprintfmt+0x1f2>
  801887:	89 df                	mov    %ebx,%edi
  801889:	8b 75 08             	mov    0x8(%ebp),%esi
  80188c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80188f:	eb 18                	jmp    8018a9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	53                   	push   %ebx
  801895:	6a 20                	push   $0x20
  801897:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801899:	83 ef 01             	sub    $0x1,%edi
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	eb 08                	jmp    8018a9 <vprintfmt+0x278>
  8018a1:	89 df                	mov    %ebx,%edi
  8018a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8018a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018a9:	85 ff                	test   %edi,%edi
  8018ab:	7f e4                	jg     801891 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018b0:	e9 a2 fd ff ff       	jmp    801657 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8018b5:	83 fa 01             	cmp    $0x1,%edx
  8018b8:	7e 16                	jle    8018d0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8018ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8018bd:	8d 50 08             	lea    0x8(%eax),%edx
  8018c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c3:	8b 50 04             	mov    0x4(%eax),%edx
  8018c6:	8b 00                	mov    (%eax),%eax
  8018c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018ce:	eb 32                	jmp    801902 <vprintfmt+0x2d1>
	else if (lflag)
  8018d0:	85 d2                	test   %edx,%edx
  8018d2:	74 18                	je     8018ec <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8018d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d7:	8d 50 04             	lea    0x4(%eax),%edx
  8018da:	89 55 14             	mov    %edx,0x14(%ebp)
  8018dd:	8b 00                	mov    (%eax),%eax
  8018df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018e2:	89 c1                	mov    %eax,%ecx
  8018e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8018e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018ea:	eb 16                	jmp    801902 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ef:	8d 50 04             	lea    0x4(%eax),%edx
  8018f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f5:	8b 00                	mov    (%eax),%eax
  8018f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018fa:	89 c1                	mov    %eax,%ecx
  8018fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8018ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801902:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801905:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801908:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80190d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801911:	79 74                	jns    801987 <vprintfmt+0x356>
				putch('-', putdat);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	53                   	push   %ebx
  801917:	6a 2d                	push   $0x2d
  801919:	ff d6                	call   *%esi
				num = -(long long) num;
  80191b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80191e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801921:	f7 d8                	neg    %eax
  801923:	83 d2 00             	adc    $0x0,%edx
  801926:	f7 da                	neg    %edx
  801928:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80192b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801930:	eb 55                	jmp    801987 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801932:	8d 45 14             	lea    0x14(%ebp),%eax
  801935:	e8 83 fc ff ff       	call   8015bd <getuint>
			base = 10;
  80193a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80193f:	eb 46                	jmp    801987 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  801941:	8d 45 14             	lea    0x14(%ebp),%eax
  801944:	e8 74 fc ff ff       	call   8015bd <getuint>
			base = 8;
  801949:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80194e:	eb 37                	jmp    801987 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	53                   	push   %ebx
  801954:	6a 30                	push   $0x30
  801956:	ff d6                	call   *%esi
			putch('x', putdat);
  801958:	83 c4 08             	add    $0x8,%esp
  80195b:	53                   	push   %ebx
  80195c:	6a 78                	push   $0x78
  80195e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801960:	8b 45 14             	mov    0x14(%ebp),%eax
  801963:	8d 50 04             	lea    0x4(%eax),%edx
  801966:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801969:	8b 00                	mov    (%eax),%eax
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801970:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801973:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801978:	eb 0d                	jmp    801987 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80197a:	8d 45 14             	lea    0x14(%ebp),%eax
  80197d:	e8 3b fc ff ff       	call   8015bd <getuint>
			base = 16;
  801982:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80198e:	57                   	push   %edi
  80198f:	ff 75 e0             	pushl  -0x20(%ebp)
  801992:	51                   	push   %ecx
  801993:	52                   	push   %edx
  801994:	50                   	push   %eax
  801995:	89 da                	mov    %ebx,%edx
  801997:	89 f0                	mov    %esi,%eax
  801999:	e8 70 fb ff ff       	call   80150e <printnum>
			break;
  80199e:	83 c4 20             	add    $0x20,%esp
  8019a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019a4:	e9 ae fc ff ff       	jmp    801657 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	53                   	push   %ebx
  8019ad:	51                   	push   %ecx
  8019ae:	ff d6                	call   *%esi
			break;
  8019b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8019b6:	e9 9c fc ff ff       	jmp    801657 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	53                   	push   %ebx
  8019bf:	6a 25                	push   $0x25
  8019c1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb 03                	jmp    8019cb <vprintfmt+0x39a>
  8019c8:	83 ef 01             	sub    $0x1,%edi
  8019cb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8019cf:	75 f7                	jne    8019c8 <vprintfmt+0x397>
  8019d1:	e9 81 fc ff ff       	jmp    801657 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8019d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5e                   	pop    %esi
  8019db:	5f                   	pop    %edi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 18             	sub    $0x18,%esp
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	74 26                	je     801a25 <vsnprintf+0x47>
  8019ff:	85 d2                	test   %edx,%edx
  801a01:	7e 22                	jle    801a25 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a03:	ff 75 14             	pushl  0x14(%ebp)
  801a06:	ff 75 10             	pushl  0x10(%ebp)
  801a09:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a0c:	50                   	push   %eax
  801a0d:	68 f7 15 80 00       	push   $0x8015f7
  801a12:	e8 1a fc ff ff       	call   801631 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a1a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	eb 05                	jmp    801a2a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a32:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a35:	50                   	push   %eax
  801a36:	ff 75 10             	pushl  0x10(%ebp)
  801a39:	ff 75 0c             	pushl  0xc(%ebp)
  801a3c:	ff 75 08             	pushl  0x8(%ebp)
  801a3f:	e8 9a ff ff ff       	call   8019de <vsnprintf>
	va_end(ap);

	return rc;
}
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	56                   	push   %esi
  801a4a:	53                   	push   %ebx
  801a4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a51:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  801a54:	85 c0                	test   %eax,%eax
  801a56:	74 0e                	je     801a66 <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	50                   	push   %eax
  801a5c:	e8 c1 ec ff ff       	call   800722 <sys_ipc_recv>
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	eb 10                	jmp    801a76 <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	68 00 00 00 f0       	push   $0xf0000000
  801a6e:	e8 af ec ff ff       	call   800722 <sys_ipc_recv>
  801a73:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  801a76:	85 c0                	test   %eax,%eax
  801a78:	74 16                	je     801a90 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  801a7a:	85 db                	test   %ebx,%ebx
  801a7c:	74 36                	je     801ab4 <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  801a7e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  801a84:	85 f6                	test   %esi,%esi
  801a86:	74 2c                	je     801ab4 <ipc_recv+0x6e>
				*perm_store = 0;
  801a88:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801a8e:	eb 24                	jmp    801ab4 <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  801a90:	85 db                	test   %ebx,%ebx
  801a92:	74 18                	je     801aac <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  801a94:	a1 04 40 80 00       	mov    0x804004,%eax
  801a99:	8b 40 74             	mov    0x74(%eax),%eax
  801a9c:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  801a9e:	85 f6                	test   %esi,%esi
  801aa0:	74 0a                	je     801aac <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  801aa2:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa7:	8b 40 78             	mov    0x78(%eax),%eax
  801aaa:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  801aac:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab1:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  801ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  801aca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ace:	75 39                	jne    801b09 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  801ad0:	6a 00                	push   $0x0
  801ad2:	68 00 00 00 f0       	push   $0xf0000000
  801ad7:	56                   	push   %esi
  801ad8:	57                   	push   %edi
  801ad9:	e8 21 ec ff ff       	call   8006ff <sys_ipc_try_send>
  801ade:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae6:	74 16                	je     801afe <ipc_send+0x43>
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	74 12                	je     801afe <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801aec:	50                   	push   %eax
  801aed:	68 c0 22 80 00       	push   $0x8022c0
  801af2:	6a 4f                	push   $0x4f
  801af4:	68 f8 22 80 00       	push   $0x8022f8
  801af9:	e8 23 f9 ff ff       	call   801421 <_panic>
			sys_yield();
  801afe:	e8 50 ea ff ff       	call   800553 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  801b03:	85 db                	test   %ebx,%ebx
  801b05:	75 c9                	jne    801ad0 <ipc_send+0x15>
  801b07:	eb 36                	jmp    801b3f <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  801b09:	ff 75 14             	pushl  0x14(%ebp)
  801b0c:	ff 75 10             	pushl  0x10(%ebp)
  801b0f:	56                   	push   %esi
  801b10:	57                   	push   %edi
  801b11:	e8 e9 eb ff ff       	call   8006ff <sys_ipc_try_send>
  801b16:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b1e:	74 16                	je     801b36 <ipc_send+0x7b>
  801b20:	85 c0                	test   %eax,%eax
  801b22:	74 12                	je     801b36 <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  801b24:	50                   	push   %eax
  801b25:	68 c0 22 80 00       	push   $0x8022c0
  801b2a:	6a 5a                	push   $0x5a
  801b2c:	68 f8 22 80 00       	push   $0x8022f8
  801b31:	e8 eb f8 ff ff       	call   801421 <_panic>
			sys_yield();
  801b36:	e8 18 ea ff ff       	call   800553 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  801b3b:	85 db                	test   %ebx,%ebx
  801b3d:	75 ca                	jne    801b09 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  801b3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b42:	5b                   	pop    %ebx
  801b43:	5e                   	pop    %esi
  801b44:	5f                   	pop    %edi
  801b45:	5d                   	pop    %ebp
  801b46:	c3                   	ret    

00801b47 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b4d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b52:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b55:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b5b:	8b 52 50             	mov    0x50(%edx),%edx
  801b5e:	39 ca                	cmp    %ecx,%edx
  801b60:	75 0d                	jne    801b6f <ipc_find_env+0x28>
			return envs[i].env_id;
  801b62:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b65:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b6a:	8b 40 48             	mov    0x48(%eax),%eax
  801b6d:	eb 0f                	jmp    801b7e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6f:	83 c0 01             	add    $0x1,%eax
  801b72:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b77:	75 d9                	jne    801b52 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b86:	89 d0                	mov    %edx,%eax
  801b88:	c1 e8 16             	shr    $0x16,%eax
  801b8b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b92:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b97:	f6 c1 01             	test   $0x1,%cl
  801b9a:	74 1d                	je     801bb9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b9c:	c1 ea 0c             	shr    $0xc,%edx
  801b9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba6:	f6 c2 01             	test   $0x1,%dl
  801ba9:	74 0e                	je     801bb9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bab:	c1 ea 0c             	shr    $0xc,%edx
  801bae:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bb5:	ef 
  801bb6:	0f b7 c0             	movzwl %ax,%eax
}
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
