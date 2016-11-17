
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 5d 00 00 00       	call   8000a2 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  800055:	e8 c6 00 00 00       	call   800120 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 aa 0f 80 00       	push   $0x800faa
  80010c:	6a 23                	push   $0x23
  80010e:	68 c7 0f 80 00       	push   $0x800fc7
  800113:	e8 37 02 00 00       	call   80034f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 aa 0f 80 00       	push   $0x800faa
  80018d:	6a 23                	push   $0x23
  80018f:	68 c7 0f 80 00       	push   $0x800fc7
  800194:	e8 b6 01 00 00       	call   80034f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 aa 0f 80 00       	push   $0x800faa
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 c7 0f 80 00       	push   $0x800fc7
  8001d6:	e8 74 01 00 00       	call   80034f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 aa 0f 80 00       	push   $0x800faa
  800211:	6a 23                	push   $0x23
  800213:	68 c7 0f 80 00       	push   $0x800fc7
  800218:	e8 32 01 00 00       	call   80034f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 aa 0f 80 00       	push   $0x800faa
  800253:	6a 23                	push   $0x23
  800255:	68 c7 0f 80 00       	push   $0x800fc7
  80025a:	e8 f0 00 00 00       	call   80034f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 aa 0f 80 00       	push   $0x800faa
  800295:	6a 23                	push   $0x23
  800297:	68 c7 0f 80 00       	push   $0x800fc7
  80029c:	e8 ae 00 00 00       	call   80034f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 aa 0f 80 00       	push   $0x800faa
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 c7 0f 80 00       	push   $0x800fc7
  8002de:	e8 6c 00 00 00       	call   80034f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 aa 0f 80 00       	push   $0x800faa
  80033b:	6a 23                	push   $0x23
  80033d:	68 c7 0f 80 00       	push   $0x800fc7
  800342:	e8 08 00 00 00       	call   80034f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800354:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800357:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80035d:	e8 be fd ff ff       	call   800120 <sys_getenvid>
  800362:	83 ec 0c             	sub    $0xc,%esp
  800365:	ff 75 0c             	pushl  0xc(%ebp)
  800368:	ff 75 08             	pushl  0x8(%ebp)
  80036b:	56                   	push   %esi
  80036c:	50                   	push   %eax
  80036d:	68 d8 0f 80 00       	push   $0x800fd8
  800372:	e8 b1 00 00 00       	call   800428 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	53                   	push   %ebx
  80037b:	ff 75 10             	pushl  0x10(%ebp)
  80037e:	e8 54 00 00 00       	call   8003d7 <vcprintf>
	cprintf("\n");
  800383:	c7 04 24 fb 0f 80 00 	movl   $0x800ffb,(%esp)
  80038a:	e8 99 00 00 00       	call   800428 <cprintf>
  80038f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800392:	cc                   	int3   
  800393:	eb fd                	jmp    800392 <_panic+0x43>

00800395 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	53                   	push   %ebx
  800399:	83 ec 04             	sub    $0x4,%esp
  80039c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039f:	8b 13                	mov    (%ebx),%edx
  8003a1:	8d 42 01             	lea    0x1(%edx),%eax
  8003a4:	89 03                	mov    %eax,(%ebx)
  8003a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b2:	75 1a                	jne    8003ce <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003b4:	83 ec 08             	sub    $0x8,%esp
  8003b7:	68 ff 00 00 00       	push   $0xff
  8003bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8003bf:	50                   	push   %eax
  8003c0:	e8 dd fc ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8003c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003cb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ce:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003d5:	c9                   	leave  
  8003d6:	c3                   	ret    

008003d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e7:	00 00 00 
	b.cnt = 0;
  8003ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f4:	ff 75 0c             	pushl  0xc(%ebp)
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800400:	50                   	push   %eax
  800401:	68 95 03 80 00       	push   $0x800395
  800406:	e8 54 01 00 00       	call   80055f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040b:	83 c4 08             	add    $0x8,%esp
  80040e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800414:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80041a:	50                   	push   %eax
  80041b:	e8 82 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  800420:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800431:	50                   	push   %eax
  800432:	ff 75 08             	pushl  0x8(%ebp)
  800435:	e8 9d ff ff ff       	call   8003d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043a:	c9                   	leave  
  80043b:	c3                   	ret    

0080043c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
  800442:	83 ec 1c             	sub    $0x1c,%esp
  800445:	89 c7                	mov    %eax,%edi
  800447:	89 d6                	mov    %edx,%esi
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800452:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800455:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800458:	bb 00 00 00 00       	mov    $0x0,%ebx
  80045d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800460:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800463:	39 d3                	cmp    %edx,%ebx
  800465:	72 05                	jb     80046c <printnum+0x30>
  800467:	39 45 10             	cmp    %eax,0x10(%ebp)
  80046a:	77 45                	ja     8004b1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046c:	83 ec 0c             	sub    $0xc,%esp
  80046f:	ff 75 18             	pushl  0x18(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800478:	53                   	push   %ebx
  800479:	ff 75 10             	pushl  0x10(%ebp)
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800482:	ff 75 e0             	pushl  -0x20(%ebp)
  800485:	ff 75 dc             	pushl  -0x24(%ebp)
  800488:	ff 75 d8             	pushl  -0x28(%ebp)
  80048b:	e8 70 08 00 00       	call   800d00 <__udivdi3>
  800490:	83 c4 18             	add    $0x18,%esp
  800493:	52                   	push   %edx
  800494:	50                   	push   %eax
  800495:	89 f2                	mov    %esi,%edx
  800497:	89 f8                	mov    %edi,%eax
  800499:	e8 9e ff ff ff       	call   80043c <printnum>
  80049e:	83 c4 20             	add    $0x20,%esp
  8004a1:	eb 18                	jmp    8004bb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	56                   	push   %esi
  8004a7:	ff 75 18             	pushl  0x18(%ebp)
  8004aa:	ff d7                	call   *%edi
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	eb 03                	jmp    8004b4 <printnum+0x78>
  8004b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004b4:	83 eb 01             	sub    $0x1,%ebx
  8004b7:	85 db                	test   %ebx,%ebx
  8004b9:	7f e8                	jg     8004a3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	56                   	push   %esi
  8004bf:	83 ec 04             	sub    $0x4,%esp
  8004c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8004cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ce:	e8 5d 09 00 00       	call   800e30 <__umoddi3>
  8004d3:	83 c4 14             	add    $0x14,%esp
  8004d6:	0f be 80 fd 0f 80 00 	movsbl 0x800ffd(%eax),%eax
  8004dd:	50                   	push   %eax
  8004de:	ff d7                	call   *%edi
}
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e6:	5b                   	pop    %ebx
  8004e7:	5e                   	pop    %esi
  8004e8:	5f                   	pop    %edi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ee:	83 fa 01             	cmp    $0x1,%edx
  8004f1:	7e 0e                	jle    800501 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004f8:	89 08                	mov    %ecx,(%eax)
  8004fa:	8b 02                	mov    (%edx),%eax
  8004fc:	8b 52 04             	mov    0x4(%edx),%edx
  8004ff:	eb 22                	jmp    800523 <getuint+0x38>
	else if (lflag)
  800501:	85 d2                	test   %edx,%edx
  800503:	74 10                	je     800515 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800505:	8b 10                	mov    (%eax),%edx
  800507:	8d 4a 04             	lea    0x4(%edx),%ecx
  80050a:	89 08                	mov    %ecx,(%eax)
  80050c:	8b 02                	mov    (%edx),%eax
  80050e:	ba 00 00 00 00       	mov    $0x0,%edx
  800513:	eb 0e                	jmp    800523 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800515:	8b 10                	mov    (%eax),%edx
  800517:	8d 4a 04             	lea    0x4(%edx),%ecx
  80051a:	89 08                	mov    %ecx,(%eax)
  80051c:	8b 02                	mov    (%edx),%eax
  80051e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80052b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80052f:	8b 10                	mov    (%eax),%edx
  800531:	3b 50 04             	cmp    0x4(%eax),%edx
  800534:	73 0a                	jae    800540 <sprintputch+0x1b>
		*b->buf++ = ch;
  800536:	8d 4a 01             	lea    0x1(%edx),%ecx
  800539:	89 08                	mov    %ecx,(%eax)
  80053b:	8b 45 08             	mov    0x8(%ebp),%eax
  80053e:	88 02                	mov    %al,(%edx)
}
  800540:	5d                   	pop    %ebp
  800541:	c3                   	ret    

00800542 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800548:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80054b:	50                   	push   %eax
  80054c:	ff 75 10             	pushl  0x10(%ebp)
  80054f:	ff 75 0c             	pushl  0xc(%ebp)
  800552:	ff 75 08             	pushl  0x8(%ebp)
  800555:	e8 05 00 00 00       	call   80055f <vprintfmt>
	va_end(ap);
}
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	c9                   	leave  
  80055e:	c3                   	ret    

0080055f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	57                   	push   %edi
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
  800565:	83 ec 2c             	sub    $0x2c,%esp
  800568:	8b 75 08             	mov    0x8(%ebp),%esi
  80056b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800571:	eb 12                	jmp    800585 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800573:	85 c0                	test   %eax,%eax
  800575:	0f 84 89 03 00 00    	je     800904 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	53                   	push   %ebx
  80057f:	50                   	push   %eax
  800580:	ff d6                	call   *%esi
  800582:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800585:	83 c7 01             	add    $0x1,%edi
  800588:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058c:	83 f8 25             	cmp    $0x25,%eax
  80058f:	75 e2                	jne    800573 <vprintfmt+0x14>
  800591:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800595:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80059c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005a3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8005af:	eb 07                	jmp    8005b8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005b4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8d 47 01             	lea    0x1(%edi),%eax
  8005bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005be:	0f b6 07             	movzbl (%edi),%eax
  8005c1:	0f b6 c8             	movzbl %al,%ecx
  8005c4:	83 e8 23             	sub    $0x23,%eax
  8005c7:	3c 55                	cmp    $0x55,%al
  8005c9:	0f 87 1a 03 00 00    	ja     8008e9 <vprintfmt+0x38a>
  8005cf:	0f b6 c0             	movzbl %al,%eax
  8005d2:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005dc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005e0:	eb d6                	jmp    8005b8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ed:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005f0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005f4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005f7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005fa:	83 fa 09             	cmp    $0x9,%edx
  8005fd:	77 39                	ja     800638 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ff:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800602:	eb e9                	jmp    8005ed <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 48 04             	lea    0x4(%eax),%ecx
  80060a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800615:	eb 27                	jmp    80063e <vprintfmt+0xdf>
  800617:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061a:	85 c0                	test   %eax,%eax
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	0f 49 c8             	cmovns %eax,%ecx
  800624:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062a:	eb 8c                	jmp    8005b8 <vprintfmt+0x59>
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80062f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800636:	eb 80                	jmp    8005b8 <vprintfmt+0x59>
  800638:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80063b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80063e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800642:	0f 89 70 ff ff ff    	jns    8005b8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800648:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80064b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800655:	e9 5e ff ff ff       	jmp    8005b8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80065a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800660:	e9 53 ff ff ff       	jmp    8005b8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 50 04             	lea    0x4(%eax),%edx
  80066b:	89 55 14             	mov    %edx,0x14(%ebp)
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	ff 30                	pushl  (%eax)
  800674:	ff d6                	call   *%esi
			break;
  800676:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80067c:	e9 04 ff ff ff       	jmp    800585 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8d 50 04             	lea    0x4(%eax),%edx
  800687:	89 55 14             	mov    %edx,0x14(%ebp)
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	99                   	cltd   
  80068d:	31 d0                	xor    %edx,%eax
  80068f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800691:	83 f8 0f             	cmp    $0xf,%eax
  800694:	7f 0b                	jg     8006a1 <vprintfmt+0x142>
  800696:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	75 18                	jne    8006b9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006a1:	50                   	push   %eax
  8006a2:	68 15 10 80 00       	push   $0x801015
  8006a7:	53                   	push   %ebx
  8006a8:	56                   	push   %esi
  8006a9:	e8 94 fe ff ff       	call   800542 <printfmt>
  8006ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006b4:	e9 cc fe ff ff       	jmp    800585 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006b9:	52                   	push   %edx
  8006ba:	68 1e 10 80 00       	push   $0x80101e
  8006bf:	53                   	push   %ebx
  8006c0:	56                   	push   %esi
  8006c1:	e8 7c fe ff ff       	call   800542 <printfmt>
  8006c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cc:	e9 b4 fe ff ff       	jmp    800585 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 04             	lea    0x4(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006da:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006dc:	85 ff                	test   %edi,%edi
  8006de:	b8 0e 10 80 00       	mov    $0x80100e,%eax
  8006e3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ea:	0f 8e 94 00 00 00    	jle    800784 <vprintfmt+0x225>
  8006f0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006f4:	0f 84 98 00 00 00    	je     800792 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	ff 75 d0             	pushl  -0x30(%ebp)
  800700:	57                   	push   %edi
  800701:	e8 86 02 00 00       	call   80098c <strnlen>
  800706:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800709:	29 c1                	sub    %eax,%ecx
  80070b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80070e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800711:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800715:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800718:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80071b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80071d:	eb 0f                	jmp    80072e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	ff 75 e0             	pushl  -0x20(%ebp)
  800726:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800728:	83 ef 01             	sub    $0x1,%edi
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 ff                	test   %edi,%edi
  800730:	7f ed                	jg     80071f <vprintfmt+0x1c0>
  800732:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800735:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800738:	85 c9                	test   %ecx,%ecx
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	0f 49 c1             	cmovns %ecx,%eax
  800742:	29 c1                	sub    %eax,%ecx
  800744:	89 75 08             	mov    %esi,0x8(%ebp)
  800747:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074d:	89 cb                	mov    %ecx,%ebx
  80074f:	eb 4d                	jmp    80079e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800751:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800755:	74 1b                	je     800772 <vprintfmt+0x213>
  800757:	0f be c0             	movsbl %al,%eax
  80075a:	83 e8 20             	sub    $0x20,%eax
  80075d:	83 f8 5e             	cmp    $0x5e,%eax
  800760:	76 10                	jbe    800772 <vprintfmt+0x213>
					putch('?', putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	6a 3f                	push   $0x3f
  80076a:	ff 55 08             	call   *0x8(%ebp)
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	eb 0d                	jmp    80077f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	52                   	push   %edx
  800779:	ff 55 08             	call   *0x8(%ebp)
  80077c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80077f:	83 eb 01             	sub    $0x1,%ebx
  800782:	eb 1a                	jmp    80079e <vprintfmt+0x23f>
  800784:	89 75 08             	mov    %esi,0x8(%ebp)
  800787:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80078a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80078d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800790:	eb 0c                	jmp    80079e <vprintfmt+0x23f>
  800792:	89 75 08             	mov    %esi,0x8(%ebp)
  800795:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800798:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80079b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80079e:	83 c7 01             	add    $0x1,%edi
  8007a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007a5:	0f be d0             	movsbl %al,%edx
  8007a8:	85 d2                	test   %edx,%edx
  8007aa:	74 23                	je     8007cf <vprintfmt+0x270>
  8007ac:	85 f6                	test   %esi,%esi
  8007ae:	78 a1                	js     800751 <vprintfmt+0x1f2>
  8007b0:	83 ee 01             	sub    $0x1,%esi
  8007b3:	79 9c                	jns    800751 <vprintfmt+0x1f2>
  8007b5:	89 df                	mov    %ebx,%edi
  8007b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007bd:	eb 18                	jmp    8007d7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	6a 20                	push   $0x20
  8007c5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007c7:	83 ef 01             	sub    $0x1,%edi
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	eb 08                	jmp    8007d7 <vprintfmt+0x278>
  8007cf:	89 df                	mov    %ebx,%edi
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d7:	85 ff                	test   %edi,%edi
  8007d9:	7f e4                	jg     8007bf <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007de:	e9 a2 fd ff ff       	jmp    800585 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007e3:	83 fa 01             	cmp    $0x1,%edx
  8007e6:	7e 16                	jle    8007fe <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 50 08             	lea    0x8(%eax),%edx
  8007ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f1:	8b 50 04             	mov    0x4(%eax),%edx
  8007f4:	8b 00                	mov    (%eax),%eax
  8007f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007fc:	eb 32                	jmp    800830 <vprintfmt+0x2d1>
	else if (lflag)
  8007fe:	85 d2                	test   %edx,%edx
  800800:	74 18                	je     80081a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	8d 50 04             	lea    0x4(%eax),%edx
  800808:	89 55 14             	mov    %edx,0x14(%ebp)
  80080b:	8b 00                	mov    (%eax),%eax
  80080d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800810:	89 c1                	mov    %eax,%ecx
  800812:	c1 f9 1f             	sar    $0x1f,%ecx
  800815:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800818:	eb 16                	jmp    800830 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	8d 50 04             	lea    0x4(%eax),%edx
  800820:	89 55 14             	mov    %edx,0x14(%ebp)
  800823:	8b 00                	mov    (%eax),%eax
  800825:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800828:	89 c1                	mov    %eax,%ecx
  80082a:	c1 f9 1f             	sar    $0x1f,%ecx
  80082d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800830:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800833:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800836:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80083b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80083f:	79 74                	jns    8008b5 <vprintfmt+0x356>
				putch('-', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	53                   	push   %ebx
  800845:	6a 2d                	push   $0x2d
  800847:	ff d6                	call   *%esi
				num = -(long long) num;
  800849:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80084c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80084f:	f7 d8                	neg    %eax
  800851:	83 d2 00             	adc    $0x0,%edx
  800854:	f7 da                	neg    %edx
  800856:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800859:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80085e:	eb 55                	jmp    8008b5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
  800863:	e8 83 fc ff ff       	call   8004eb <getuint>
			base = 10;
  800868:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80086d:	eb 46                	jmp    8008b5 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80086f:	8d 45 14             	lea    0x14(%ebp),%eax
  800872:	e8 74 fc ff ff       	call   8004eb <getuint>
			base = 8;
  800877:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80087c:	eb 37                	jmp    8008b5 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  80087e:	83 ec 08             	sub    $0x8,%esp
  800881:	53                   	push   %ebx
  800882:	6a 30                	push   $0x30
  800884:	ff d6                	call   *%esi
			putch('x', putdat);
  800886:	83 c4 08             	add    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	6a 78                	push   $0x78
  80088c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088e:	8b 45 14             	mov    0x14(%ebp),%eax
  800891:	8d 50 04             	lea    0x4(%eax),%edx
  800894:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800897:	8b 00                	mov    (%eax),%eax
  800899:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80089e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008a6:	eb 0d                	jmp    8008b5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ab:	e8 3b fc ff ff       	call   8004eb <getuint>
			base = 16;
  8008b0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b5:	83 ec 0c             	sub    $0xc,%esp
  8008b8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008bc:	57                   	push   %edi
  8008bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c0:	51                   	push   %ecx
  8008c1:	52                   	push   %edx
  8008c2:	50                   	push   %eax
  8008c3:	89 da                	mov    %ebx,%edx
  8008c5:	89 f0                	mov    %esi,%eax
  8008c7:	e8 70 fb ff ff       	call   80043c <printnum>
			break;
  8008cc:	83 c4 20             	add    $0x20,%esp
  8008cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d2:	e9 ae fc ff ff       	jmp    800585 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	53                   	push   %ebx
  8008db:	51                   	push   %ecx
  8008dc:	ff d6                	call   *%esi
			break;
  8008de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e4:	e9 9c fc ff ff       	jmp    800585 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	53                   	push   %ebx
  8008ed:	6a 25                	push   $0x25
  8008ef:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f1:	83 c4 10             	add    $0x10,%esp
  8008f4:	eb 03                	jmp    8008f9 <vprintfmt+0x39a>
  8008f6:	83 ef 01             	sub    $0x1,%edi
  8008f9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008fd:	75 f7                	jne    8008f6 <vprintfmt+0x397>
  8008ff:	e9 81 fc ff ff       	jmp    800585 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800904:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	83 ec 18             	sub    $0x18,%esp
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800918:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800922:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800929:	85 c0                	test   %eax,%eax
  80092b:	74 26                	je     800953 <vsnprintf+0x47>
  80092d:	85 d2                	test   %edx,%edx
  80092f:	7e 22                	jle    800953 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800931:	ff 75 14             	pushl  0x14(%ebp)
  800934:	ff 75 10             	pushl  0x10(%ebp)
  800937:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093a:	50                   	push   %eax
  80093b:	68 25 05 80 00       	push   $0x800525
  800940:	e8 1a fc ff ff       	call   80055f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800945:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800948:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	eb 05                	jmp    800958 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800953:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800960:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800963:	50                   	push   %eax
  800964:	ff 75 10             	pushl  0x10(%ebp)
  800967:	ff 75 0c             	pushl  0xc(%ebp)
  80096a:	ff 75 08             	pushl  0x8(%ebp)
  80096d:	e8 9a ff ff ff       	call   80090c <vsnprintf>
	va_end(ap);

	return rc;
}
  800972:	c9                   	leave  
  800973:	c3                   	ret    

00800974 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
  80097f:	eb 03                	jmp    800984 <strlen+0x10>
		n++;
  800981:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800984:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800988:	75 f7                	jne    800981 <strlen+0xd>
		n++;
	return n;
}
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800995:	ba 00 00 00 00       	mov    $0x0,%edx
  80099a:	eb 03                	jmp    80099f <strnlen+0x13>
		n++;
  80099c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099f:	39 c2                	cmp    %eax,%edx
  8009a1:	74 08                	je     8009ab <strnlen+0x1f>
  8009a3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009a7:	75 f3                	jne    80099c <strnlen+0x10>
  8009a9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	53                   	push   %ebx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b7:	89 c2                	mov    %eax,%edx
  8009b9:	83 c2 01             	add    $0x1,%edx
  8009bc:	83 c1 01             	add    $0x1,%ecx
  8009bf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009c3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c6:	84 db                	test   %bl,%bl
  8009c8:	75 ef                	jne    8009b9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	53                   	push   %ebx
  8009d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d4:	53                   	push   %ebx
  8009d5:	e8 9a ff ff ff       	call   800974 <strlen>
  8009da:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009dd:	ff 75 0c             	pushl  0xc(%ebp)
  8009e0:	01 d8                	add    %ebx,%eax
  8009e2:	50                   	push   %eax
  8009e3:	e8 c5 ff ff ff       	call   8009ad <strcpy>
	return dst;
}
  8009e8:	89 d8                	mov    %ebx,%eax
  8009ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fa:	89 f3                	mov    %esi,%ebx
  8009fc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ff:	89 f2                	mov    %esi,%edx
  800a01:	eb 0f                	jmp    800a12 <strncpy+0x23>
		*dst++ = *src;
  800a03:	83 c2 01             	add    $0x1,%edx
  800a06:	0f b6 01             	movzbl (%ecx),%eax
  800a09:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a0c:	80 39 01             	cmpb   $0x1,(%ecx)
  800a0f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a12:	39 da                	cmp    %ebx,%edx
  800a14:	75 ed                	jne    800a03 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a16:	89 f0                	mov    %esi,%eax
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 75 08             	mov    0x8(%ebp),%esi
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a27:	8b 55 10             	mov    0x10(%ebp),%edx
  800a2a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a2c:	85 d2                	test   %edx,%edx
  800a2e:	74 21                	je     800a51 <strlcpy+0x35>
  800a30:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a34:	89 f2                	mov    %esi,%edx
  800a36:	eb 09                	jmp    800a41 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a38:	83 c2 01             	add    $0x1,%edx
  800a3b:	83 c1 01             	add    $0x1,%ecx
  800a3e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a41:	39 c2                	cmp    %eax,%edx
  800a43:	74 09                	je     800a4e <strlcpy+0x32>
  800a45:	0f b6 19             	movzbl (%ecx),%ebx
  800a48:	84 db                	test   %bl,%bl
  800a4a:	75 ec                	jne    800a38 <strlcpy+0x1c>
  800a4c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a4e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a51:	29 f0                	sub    %esi,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a60:	eb 06                	jmp    800a68 <strcmp+0x11>
		p++, q++;
  800a62:	83 c1 01             	add    $0x1,%ecx
  800a65:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a68:	0f b6 01             	movzbl (%ecx),%eax
  800a6b:	84 c0                	test   %al,%al
  800a6d:	74 04                	je     800a73 <strcmp+0x1c>
  800a6f:	3a 02                	cmp    (%edx),%al
  800a71:	74 ef                	je     800a62 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a73:	0f b6 c0             	movzbl %al,%eax
  800a76:	0f b6 12             	movzbl (%edx),%edx
  800a79:	29 d0                	sub    %edx,%eax
}
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a87:	89 c3                	mov    %eax,%ebx
  800a89:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a8c:	eb 06                	jmp    800a94 <strncmp+0x17>
		n--, p++, q++;
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a94:	39 d8                	cmp    %ebx,%eax
  800a96:	74 15                	je     800aad <strncmp+0x30>
  800a98:	0f b6 08             	movzbl (%eax),%ecx
  800a9b:	84 c9                	test   %cl,%cl
  800a9d:	74 04                	je     800aa3 <strncmp+0x26>
  800a9f:	3a 0a                	cmp    (%edx),%cl
  800aa1:	74 eb                	je     800a8e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa3:	0f b6 00             	movzbl (%eax),%eax
  800aa6:	0f b6 12             	movzbl (%edx),%edx
  800aa9:	29 d0                	sub    %edx,%eax
  800aab:	eb 05                	jmp    800ab2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab2:	5b                   	pop    %ebx
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abf:	eb 07                	jmp    800ac8 <strchr+0x13>
		if (*s == c)
  800ac1:	38 ca                	cmp    %cl,%dl
  800ac3:	74 0f                	je     800ad4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac5:	83 c0 01             	add    $0x1,%eax
  800ac8:	0f b6 10             	movzbl (%eax),%edx
  800acb:	84 d2                	test   %dl,%dl
  800acd:	75 f2                	jne    800ac1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae0:	eb 03                	jmp    800ae5 <strfind+0xf>
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae8:	38 ca                	cmp    %cl,%dl
  800aea:	74 04                	je     800af0 <strfind+0x1a>
  800aec:	84 d2                	test   %dl,%dl
  800aee:	75 f2                	jne    800ae2 <strfind+0xc>
			break;
	return (char *) s;
}
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800afe:	85 c9                	test   %ecx,%ecx
  800b00:	74 36                	je     800b38 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b02:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b08:	75 28                	jne    800b32 <memset+0x40>
  800b0a:	f6 c1 03             	test   $0x3,%cl
  800b0d:	75 23                	jne    800b32 <memset+0x40>
		c &= 0xFF;
  800b0f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b13:	89 d3                	mov    %edx,%ebx
  800b15:	c1 e3 08             	shl    $0x8,%ebx
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	c1 e6 18             	shl    $0x18,%esi
  800b1d:	89 d0                	mov    %edx,%eax
  800b1f:	c1 e0 10             	shl    $0x10,%eax
  800b22:	09 f0                	or     %esi,%eax
  800b24:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b26:	89 d8                	mov    %ebx,%eax
  800b28:	09 d0                	or     %edx,%eax
  800b2a:	c1 e9 02             	shr    $0x2,%ecx
  800b2d:	fc                   	cld    
  800b2e:	f3 ab                	rep stos %eax,%es:(%edi)
  800b30:	eb 06                	jmp    800b38 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	fc                   	cld    
  800b36:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b38:	89 f8                	mov    %edi,%eax
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b4d:	39 c6                	cmp    %eax,%esi
  800b4f:	73 35                	jae    800b86 <memmove+0x47>
  800b51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b54:	39 d0                	cmp    %edx,%eax
  800b56:	73 2e                	jae    800b86 <memmove+0x47>
		s += n;
		d += n;
  800b58:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	09 fe                	or     %edi,%esi
  800b5f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b65:	75 13                	jne    800b7a <memmove+0x3b>
  800b67:	f6 c1 03             	test   $0x3,%cl
  800b6a:	75 0e                	jne    800b7a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b6c:	83 ef 04             	sub    $0x4,%edi
  800b6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b72:	c1 e9 02             	shr    $0x2,%ecx
  800b75:	fd                   	std    
  800b76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b78:	eb 09                	jmp    800b83 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b7a:	83 ef 01             	sub    $0x1,%edi
  800b7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b80:	fd                   	std    
  800b81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b83:	fc                   	cld    
  800b84:	eb 1d                	jmp    800ba3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b86:	89 f2                	mov    %esi,%edx
  800b88:	09 c2                	or     %eax,%edx
  800b8a:	f6 c2 03             	test   $0x3,%dl
  800b8d:	75 0f                	jne    800b9e <memmove+0x5f>
  800b8f:	f6 c1 03             	test   $0x3,%cl
  800b92:	75 0a                	jne    800b9e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b94:	c1 e9 02             	shr    $0x2,%ecx
  800b97:	89 c7                	mov    %eax,%edi
  800b99:	fc                   	cld    
  800b9a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9c:	eb 05                	jmp    800ba3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b9e:	89 c7                	mov    %eax,%edi
  800ba0:	fc                   	cld    
  800ba1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800baa:	ff 75 10             	pushl  0x10(%ebp)
  800bad:	ff 75 0c             	pushl  0xc(%ebp)
  800bb0:	ff 75 08             	pushl  0x8(%ebp)
  800bb3:	e8 87 ff ff ff       	call   800b3f <memmove>
}
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc5:	89 c6                	mov    %eax,%esi
  800bc7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bca:	eb 1a                	jmp    800be6 <memcmp+0x2c>
		if (*s1 != *s2)
  800bcc:	0f b6 08             	movzbl (%eax),%ecx
  800bcf:	0f b6 1a             	movzbl (%edx),%ebx
  800bd2:	38 d9                	cmp    %bl,%cl
  800bd4:	74 0a                	je     800be0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bd6:	0f b6 c1             	movzbl %cl,%eax
  800bd9:	0f b6 db             	movzbl %bl,%ebx
  800bdc:	29 d8                	sub    %ebx,%eax
  800bde:	eb 0f                	jmp    800bef <memcmp+0x35>
		s1++, s2++;
  800be0:	83 c0 01             	add    $0x1,%eax
  800be3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be6:	39 f0                	cmp    %esi,%eax
  800be8:	75 e2                	jne    800bcc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	53                   	push   %ebx
  800bf7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bfa:	89 c1                	mov    %eax,%ecx
  800bfc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bff:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c03:	eb 0a                	jmp    800c0f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c05:	0f b6 10             	movzbl (%eax),%edx
  800c08:	39 da                	cmp    %ebx,%edx
  800c0a:	74 07                	je     800c13 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0c:	83 c0 01             	add    $0x1,%eax
  800c0f:	39 c8                	cmp    %ecx,%eax
  800c11:	72 f2                	jb     800c05 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c13:	5b                   	pop    %ebx
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c22:	eb 03                	jmp    800c27 <strtol+0x11>
		s++;
  800c24:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c27:	0f b6 01             	movzbl (%ecx),%eax
  800c2a:	3c 20                	cmp    $0x20,%al
  800c2c:	74 f6                	je     800c24 <strtol+0xe>
  800c2e:	3c 09                	cmp    $0x9,%al
  800c30:	74 f2                	je     800c24 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c32:	3c 2b                	cmp    $0x2b,%al
  800c34:	75 0a                	jne    800c40 <strtol+0x2a>
		s++;
  800c36:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c39:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3e:	eb 11                	jmp    800c51 <strtol+0x3b>
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c45:	3c 2d                	cmp    $0x2d,%al
  800c47:	75 08                	jne    800c51 <strtol+0x3b>
		s++, neg = 1;
  800c49:	83 c1 01             	add    $0x1,%ecx
  800c4c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c51:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c57:	75 15                	jne    800c6e <strtol+0x58>
  800c59:	80 39 30             	cmpb   $0x30,(%ecx)
  800c5c:	75 10                	jne    800c6e <strtol+0x58>
  800c5e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c62:	75 7c                	jne    800ce0 <strtol+0xca>
		s += 2, base = 16;
  800c64:	83 c1 02             	add    $0x2,%ecx
  800c67:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c6c:	eb 16                	jmp    800c84 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c6e:	85 db                	test   %ebx,%ebx
  800c70:	75 12                	jne    800c84 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c72:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c77:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7a:	75 08                	jne    800c84 <strtol+0x6e>
		s++, base = 8;
  800c7c:	83 c1 01             	add    $0x1,%ecx
  800c7f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
  800c89:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c8c:	0f b6 11             	movzbl (%ecx),%edx
  800c8f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c92:	89 f3                	mov    %esi,%ebx
  800c94:	80 fb 09             	cmp    $0x9,%bl
  800c97:	77 08                	ja     800ca1 <strtol+0x8b>
			dig = *s - '0';
  800c99:	0f be d2             	movsbl %dl,%edx
  800c9c:	83 ea 30             	sub    $0x30,%edx
  800c9f:	eb 22                	jmp    800cc3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ca1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca4:	89 f3                	mov    %esi,%ebx
  800ca6:	80 fb 19             	cmp    $0x19,%bl
  800ca9:	77 08                	ja     800cb3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cab:	0f be d2             	movsbl %dl,%edx
  800cae:	83 ea 57             	sub    $0x57,%edx
  800cb1:	eb 10                	jmp    800cc3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cb3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cb6:	89 f3                	mov    %esi,%ebx
  800cb8:	80 fb 19             	cmp    $0x19,%bl
  800cbb:	77 16                	ja     800cd3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cbd:	0f be d2             	movsbl %dl,%edx
  800cc0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cc3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cc6:	7d 0b                	jge    800cd3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cc8:	83 c1 01             	add    $0x1,%ecx
  800ccb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ccf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cd1:	eb b9                	jmp    800c8c <strtol+0x76>

	if (endptr)
  800cd3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd7:	74 0d                	je     800ce6 <strtol+0xd0>
		*endptr = (char *) s;
  800cd9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdc:	89 0e                	mov    %ecx,(%esi)
  800cde:	eb 06                	jmp    800ce6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce0:	85 db                	test   %ebx,%ebx
  800ce2:	74 98                	je     800c7c <strtol+0x66>
  800ce4:	eb 9e                	jmp    800c84 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ce6:	89 c2                	mov    %eax,%edx
  800ce8:	f7 da                	neg    %edx
  800cea:	85 ff                	test   %edi,%edi
  800cec:	0f 45 c2             	cmovne %edx,%eax
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    
  800cf4:	66 90                	xchg   %ax,%ax
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

00800d00 <__udivdi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d17:	85 f6                	test   %esi,%esi
  800d19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d1d:	89 ca                	mov    %ecx,%edx
  800d1f:	89 f8                	mov    %edi,%eax
  800d21:	75 3d                	jne    800d60 <__udivdi3+0x60>
  800d23:	39 cf                	cmp    %ecx,%edi
  800d25:	0f 87 c5 00 00 00    	ja     800df0 <__udivdi3+0xf0>
  800d2b:	85 ff                	test   %edi,%edi
  800d2d:	89 fd                	mov    %edi,%ebp
  800d2f:	75 0b                	jne    800d3c <__udivdi3+0x3c>
  800d31:	b8 01 00 00 00       	mov    $0x1,%eax
  800d36:	31 d2                	xor    %edx,%edx
  800d38:	f7 f7                	div    %edi
  800d3a:	89 c5                	mov    %eax,%ebp
  800d3c:	89 c8                	mov    %ecx,%eax
  800d3e:	31 d2                	xor    %edx,%edx
  800d40:	f7 f5                	div    %ebp
  800d42:	89 c1                	mov    %eax,%ecx
  800d44:	89 d8                	mov    %ebx,%eax
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	f7 f5                	div    %ebp
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	89 d8                	mov    %ebx,%eax
  800d4e:	89 fa                	mov    %edi,%edx
  800d50:	83 c4 1c             	add    $0x1c,%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
  800d58:	90                   	nop
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	39 ce                	cmp    %ecx,%esi
  800d62:	77 74                	ja     800dd8 <__udivdi3+0xd8>
  800d64:	0f bd fe             	bsr    %esi,%edi
  800d67:	83 f7 1f             	xor    $0x1f,%edi
  800d6a:	0f 84 98 00 00 00    	je     800e08 <__udivdi3+0x108>
  800d70:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d75:	89 f9                	mov    %edi,%ecx
  800d77:	89 c5                	mov    %eax,%ebp
  800d79:	29 fb                	sub    %edi,%ebx
  800d7b:	d3 e6                	shl    %cl,%esi
  800d7d:	89 d9                	mov    %ebx,%ecx
  800d7f:	d3 ed                	shr    %cl,%ebp
  800d81:	89 f9                	mov    %edi,%ecx
  800d83:	d3 e0                	shl    %cl,%eax
  800d85:	09 ee                	or     %ebp,%esi
  800d87:	89 d9                	mov    %ebx,%ecx
  800d89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d8d:	89 d5                	mov    %edx,%ebp
  800d8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d93:	d3 ed                	shr    %cl,%ebp
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	d3 e2                	shl    %cl,%edx
  800d99:	89 d9                	mov    %ebx,%ecx
  800d9b:	d3 e8                	shr    %cl,%eax
  800d9d:	09 c2                	or     %eax,%edx
  800d9f:	89 d0                	mov    %edx,%eax
  800da1:	89 ea                	mov    %ebp,%edx
  800da3:	f7 f6                	div    %esi
  800da5:	89 d5                	mov    %edx,%ebp
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	f7 64 24 0c          	mull   0xc(%esp)
  800dad:	39 d5                	cmp    %edx,%ebp
  800daf:	72 10                	jb     800dc1 <__udivdi3+0xc1>
  800db1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e6                	shl    %cl,%esi
  800db9:	39 c6                	cmp    %eax,%esi
  800dbb:	73 07                	jae    800dc4 <__udivdi3+0xc4>
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	75 03                	jne    800dc4 <__udivdi3+0xc4>
  800dc1:	83 eb 01             	sub    $0x1,%ebx
  800dc4:	31 ff                	xor    %edi,%edi
  800dc6:	89 d8                	mov    %ebx,%eax
  800dc8:	89 fa                	mov    %edi,%edx
  800dca:	83 c4 1c             	add    $0x1c,%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    
  800dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dd8:	31 ff                	xor    %edi,%edi
  800dda:	31 db                	xor    %ebx,%ebx
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	89 fa                	mov    %edi,%edx
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	90                   	nop
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df0:	89 d8                	mov    %ebx,%eax
  800df2:	f7 f7                	div    %edi
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 c3                	mov    %eax,%ebx
  800df8:	89 d8                	mov    %ebx,%eax
  800dfa:	89 fa                	mov    %edi,%edx
  800dfc:	83 c4 1c             	add    $0x1c,%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	39 ce                	cmp    %ecx,%esi
  800e0a:	72 0c                	jb     800e18 <__udivdi3+0x118>
  800e0c:	31 db                	xor    %ebx,%ebx
  800e0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e12:	0f 87 34 ff ff ff    	ja     800d4c <__udivdi3+0x4c>
  800e18:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e1d:	e9 2a ff ff ff       	jmp    800d4c <__udivdi3+0x4c>
  800e22:	66 90                	xchg   %ax,%ax
  800e24:	66 90                	xchg   %ax,%ax
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__umoddi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 d2                	test   %edx,%edx
  800e49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e51:	89 f3                	mov    %esi,%ebx
  800e53:	89 3c 24             	mov    %edi,(%esp)
  800e56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5a:	75 1c                	jne    800e78 <__umoddi3+0x48>
  800e5c:	39 f7                	cmp    %esi,%edi
  800e5e:	76 50                	jbe    800eb0 <__umoddi3+0x80>
  800e60:	89 c8                	mov    %ecx,%eax
  800e62:	89 f2                	mov    %esi,%edx
  800e64:	f7 f7                	div    %edi
  800e66:	89 d0                	mov    %edx,%eax
  800e68:	31 d2                	xor    %edx,%edx
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e78:	39 f2                	cmp    %esi,%edx
  800e7a:	89 d0                	mov    %edx,%eax
  800e7c:	77 52                	ja     800ed0 <__umoddi3+0xa0>
  800e7e:	0f bd ea             	bsr    %edx,%ebp
  800e81:	83 f5 1f             	xor    $0x1f,%ebp
  800e84:	75 5a                	jne    800ee0 <__umoddi3+0xb0>
  800e86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e8a:	0f 82 e0 00 00 00    	jb     800f70 <__umoddi3+0x140>
  800e90:	39 0c 24             	cmp    %ecx,(%esp)
  800e93:	0f 86 d7 00 00 00    	jbe    800f70 <__umoddi3+0x140>
  800e99:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ea1:	83 c4 1c             	add    $0x1c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	85 ff                	test   %edi,%edi
  800eb2:	89 fd                	mov    %edi,%ebp
  800eb4:	75 0b                	jne    800ec1 <__umoddi3+0x91>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f7                	div    %edi
  800ebf:	89 c5                	mov    %eax,%ebp
  800ec1:	89 f0                	mov    %esi,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	f7 f5                	div    %ebp
  800ec7:	89 c8                	mov    %ecx,%eax
  800ec9:	f7 f5                	div    %ebp
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	eb 99                	jmp    800e68 <__umoddi3+0x38>
  800ecf:	90                   	nop
  800ed0:	89 c8                	mov    %ecx,%eax
  800ed2:	89 f2                	mov    %esi,%edx
  800ed4:	83 c4 1c             	add    $0x1c,%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    
  800edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	8b 34 24             	mov    (%esp),%esi
  800ee3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ee8:	89 e9                	mov    %ebp,%ecx
  800eea:	29 ef                	sub    %ebp,%edi
  800eec:	d3 e0                	shl    %cl,%eax
  800eee:	89 f9                	mov    %edi,%ecx
  800ef0:	89 f2                	mov    %esi,%edx
  800ef2:	d3 ea                	shr    %cl,%edx
  800ef4:	89 e9                	mov    %ebp,%ecx
  800ef6:	09 c2                	or     %eax,%edx
  800ef8:	89 d8                	mov    %ebx,%eax
  800efa:	89 14 24             	mov    %edx,(%esp)
  800efd:	89 f2                	mov    %esi,%edx
  800eff:	d3 e2                	shl    %cl,%edx
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	89 e9                	mov    %ebp,%ecx
  800f0f:	89 c6                	mov    %eax,%esi
  800f11:	d3 e3                	shl    %cl,%ebx
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	89 d0                	mov    %edx,%eax
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	89 e9                	mov    %ebp,%ecx
  800f1b:	09 d8                	or     %ebx,%eax
  800f1d:	89 d3                	mov    %edx,%ebx
  800f1f:	89 f2                	mov    %esi,%edx
  800f21:	f7 34 24             	divl   (%esp)
  800f24:	89 d6                	mov    %edx,%esi
  800f26:	d3 e3                	shl    %cl,%ebx
  800f28:	f7 64 24 04          	mull   0x4(%esp)
  800f2c:	39 d6                	cmp    %edx,%esi
  800f2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f32:	89 d1                	mov    %edx,%ecx
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	72 08                	jb     800f40 <__umoddi3+0x110>
  800f38:	75 11                	jne    800f4b <__umoddi3+0x11b>
  800f3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f3e:	73 0b                	jae    800f4b <__umoddi3+0x11b>
  800f40:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f44:	1b 14 24             	sbb    (%esp),%edx
  800f47:	89 d1                	mov    %edx,%ecx
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f4f:	29 da                	sub    %ebx,%edx
  800f51:	19 ce                	sbb    %ecx,%esi
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	89 f0                	mov    %esi,%eax
  800f57:	d3 e0                	shl    %cl,%eax
  800f59:	89 e9                	mov    %ebp,%ecx
  800f5b:	d3 ea                	shr    %cl,%edx
  800f5d:	89 e9                	mov    %ebp,%ecx
  800f5f:	d3 ee                	shr    %cl,%esi
  800f61:	09 d0                	or     %edx,%eax
  800f63:	89 f2                	mov    %esi,%edx
  800f65:	83 c4 1c             	add    $0x1c,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	29 f9                	sub    %edi,%ecx
  800f72:	19 d6                	sbb    %edx,%esi
  800f74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7c:	e9 18 ff ff ff       	jmp    800e99 <__umoddi3+0x69>
