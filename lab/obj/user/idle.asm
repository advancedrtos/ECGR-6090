
obj/user/idle.debug:     file format elf32-i386


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
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 20 80 00 c0 	movl   $0x800fc0,0x802000
  800040:	0f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 f7 00 00 00       	call   80013f <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

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
  800107:	68 cf 0f 80 00       	push   $0x800fcf
  80010c:	6a 23                	push   $0x23
  80010e:	68 ec 0f 80 00       	push   $0x800fec
  800113:	e8 56 02 00 00       	call   80036e <_panic>

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
  800188:	68 cf 0f 80 00       	push   $0x800fcf
  80018d:	6a 23                	push   $0x23
  80018f:	68 ec 0f 80 00       	push   $0x800fec
  800194:	e8 d5 01 00 00       	call   80036e <_panic>

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
  8001ca:	68 cf 0f 80 00       	push   $0x800fcf
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 ec 0f 80 00       	push   $0x800fec
  8001d6:	e8 93 01 00 00       	call   80036e <_panic>

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
  80020c:	68 cf 0f 80 00       	push   $0x800fcf
  800211:	6a 23                	push   $0x23
  800213:	68 ec 0f 80 00       	push   $0x800fec
  800218:	e8 51 01 00 00       	call   80036e <_panic>

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
  80024e:	68 cf 0f 80 00       	push   $0x800fcf
  800253:	6a 23                	push   $0x23
  800255:	68 ec 0f 80 00       	push   $0x800fec
  80025a:	e8 0f 01 00 00       	call   80036e <_panic>

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
  800290:	68 cf 0f 80 00       	push   $0x800fcf
  800295:	6a 23                	push   $0x23
  800297:	68 ec 0f 80 00       	push   $0x800fec
  80029c:	e8 cd 00 00 00       	call   80036e <_panic>

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
  8002d2:	68 cf 0f 80 00       	push   $0x800fcf
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 ec 0f 80 00       	push   $0x800fec
  8002de:	e8 8b 00 00 00       	call   80036e <_panic>

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
  800336:	68 cf 0f 80 00       	push   $0x800fcf
  80033b:	6a 23                	push   $0x23
  80033d:	68 ec 0f 80 00       	push   $0x800fec
  800342:	e8 27 00 00 00       	call   80036e <_panic>

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

0080034f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035f:	89 d1                	mov    %edx,%ecx
  800361:	89 d3                	mov    %edx,%ebx
  800363:	89 d7                	mov    %edx,%edi
  800365:	89 d6                	mov    %edx,%esi
  800367:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800373:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800376:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80037c:	e8 9f fd ff ff       	call   800120 <sys_getenvid>
  800381:	83 ec 0c             	sub    $0xc,%esp
  800384:	ff 75 0c             	pushl  0xc(%ebp)
  800387:	ff 75 08             	pushl  0x8(%ebp)
  80038a:	56                   	push   %esi
  80038b:	50                   	push   %eax
  80038c:	68 fc 0f 80 00       	push   $0x800ffc
  800391:	e8 b1 00 00 00       	call   800447 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800396:	83 c4 18             	add    $0x18,%esp
  800399:	53                   	push   %ebx
  80039a:	ff 75 10             	pushl  0x10(%ebp)
  80039d:	e8 54 00 00 00       	call   8003f6 <vcprintf>
	cprintf("\n");
  8003a2:	c7 04 24 1f 10 80 00 	movl   $0x80101f,(%esp)
  8003a9:	e8 99 00 00 00       	call   800447 <cprintf>
  8003ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003b1:	cc                   	int3   
  8003b2:	eb fd                	jmp    8003b1 <_panic+0x43>

008003b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 04             	sub    $0x4,%esp
  8003bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003be:	8b 13                	mov    (%ebx),%edx
  8003c0:	8d 42 01             	lea    0x1(%edx),%eax
  8003c3:	89 03                	mov    %eax,(%ebx)
  8003c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003d1:	75 1a                	jne    8003ed <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	68 ff 00 00 00       	push   $0xff
  8003db:	8d 43 08             	lea    0x8(%ebx),%eax
  8003de:	50                   	push   %eax
  8003df:	e8 be fc ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8003e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ea:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ed:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003f4:	c9                   	leave  
  8003f5:	c3                   	ret    

008003f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ff:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800406:	00 00 00 
	b.cnt = 0;
  800409:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800410:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800413:	ff 75 0c             	pushl  0xc(%ebp)
  800416:	ff 75 08             	pushl  0x8(%ebp)
  800419:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80041f:	50                   	push   %eax
  800420:	68 b4 03 80 00       	push   $0x8003b4
  800425:	e8 54 01 00 00       	call   80057e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80042a:	83 c4 08             	add    $0x8,%esp
  80042d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800433:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800439:	50                   	push   %eax
  80043a:	e8 63 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80043f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800445:	c9                   	leave  
  800446:	c3                   	ret    

00800447 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800447:	55                   	push   %ebp
  800448:	89 e5                	mov    %esp,%ebp
  80044a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80044d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800450:	50                   	push   %eax
  800451:	ff 75 08             	pushl  0x8(%ebp)
  800454:	e8 9d ff ff ff       	call   8003f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800459:	c9                   	leave  
  80045a:	c3                   	ret    

0080045b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80045b:	55                   	push   %ebp
  80045c:	89 e5                	mov    %esp,%ebp
  80045e:	57                   	push   %edi
  80045f:	56                   	push   %esi
  800460:	53                   	push   %ebx
  800461:	83 ec 1c             	sub    $0x1c,%esp
  800464:	89 c7                	mov    %eax,%edi
  800466:	89 d6                	mov    %edx,%esi
  800468:	8b 45 08             	mov    0x8(%ebp),%eax
  80046b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800471:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800474:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800477:	bb 00 00 00 00       	mov    $0x0,%ebx
  80047c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80047f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800482:	39 d3                	cmp    %edx,%ebx
  800484:	72 05                	jb     80048b <printnum+0x30>
  800486:	39 45 10             	cmp    %eax,0x10(%ebp)
  800489:	77 45                	ja     8004d0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80048b:	83 ec 0c             	sub    $0xc,%esp
  80048e:	ff 75 18             	pushl  0x18(%ebp)
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800497:	53                   	push   %ebx
  800498:	ff 75 10             	pushl  0x10(%ebp)
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a4:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004aa:	e8 71 08 00 00       	call   800d20 <__udivdi3>
  8004af:	83 c4 18             	add    $0x18,%esp
  8004b2:	52                   	push   %edx
  8004b3:	50                   	push   %eax
  8004b4:	89 f2                	mov    %esi,%edx
  8004b6:	89 f8                	mov    %edi,%eax
  8004b8:	e8 9e ff ff ff       	call   80045b <printnum>
  8004bd:	83 c4 20             	add    $0x20,%esp
  8004c0:	eb 18                	jmp    8004da <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	56                   	push   %esi
  8004c6:	ff 75 18             	pushl  0x18(%ebp)
  8004c9:	ff d7                	call   *%edi
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	eb 03                	jmp    8004d3 <printnum+0x78>
  8004d0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004d3:	83 eb 01             	sub    $0x1,%ebx
  8004d6:	85 db                	test   %ebx,%ebx
  8004d8:	7f e8                	jg     8004c2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	56                   	push   %esi
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ed:	e8 5e 09 00 00       	call   800e50 <__umoddi3>
  8004f2:	83 c4 14             	add    $0x14,%esp
  8004f5:	0f be 80 21 10 80 00 	movsbl 0x801021(%eax),%eax
  8004fc:	50                   	push   %eax
  8004fd:	ff d7                	call   *%edi
}
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800505:	5b                   	pop    %ebx
  800506:	5e                   	pop    %esi
  800507:	5f                   	pop    %edi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80050d:	83 fa 01             	cmp    $0x1,%edx
  800510:	7e 0e                	jle    800520 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800512:	8b 10                	mov    (%eax),%edx
  800514:	8d 4a 08             	lea    0x8(%edx),%ecx
  800517:	89 08                	mov    %ecx,(%eax)
  800519:	8b 02                	mov    (%edx),%eax
  80051b:	8b 52 04             	mov    0x4(%edx),%edx
  80051e:	eb 22                	jmp    800542 <getuint+0x38>
	else if (lflag)
  800520:	85 d2                	test   %edx,%edx
  800522:	74 10                	je     800534 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800524:	8b 10                	mov    (%eax),%edx
  800526:	8d 4a 04             	lea    0x4(%edx),%ecx
  800529:	89 08                	mov    %ecx,(%eax)
  80052b:	8b 02                	mov    (%edx),%eax
  80052d:	ba 00 00 00 00       	mov    $0x0,%edx
  800532:	eb 0e                	jmp    800542 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800534:	8b 10                	mov    (%eax),%edx
  800536:	8d 4a 04             	lea    0x4(%edx),%ecx
  800539:	89 08                	mov    %ecx,(%eax)
  80053b:	8b 02                	mov    (%edx),%eax
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800542:	5d                   	pop    %ebp
  800543:	c3                   	ret    

00800544 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80054e:	8b 10                	mov    (%eax),%edx
  800550:	3b 50 04             	cmp    0x4(%eax),%edx
  800553:	73 0a                	jae    80055f <sprintputch+0x1b>
		*b->buf++ = ch;
  800555:	8d 4a 01             	lea    0x1(%edx),%ecx
  800558:	89 08                	mov    %ecx,(%eax)
  80055a:	8b 45 08             	mov    0x8(%ebp),%eax
  80055d:	88 02                	mov    %al,(%edx)
}
  80055f:	5d                   	pop    %ebp
  800560:	c3                   	ret    

00800561 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800561:	55                   	push   %ebp
  800562:	89 e5                	mov    %esp,%ebp
  800564:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800567:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056a:	50                   	push   %eax
  80056b:	ff 75 10             	pushl  0x10(%ebp)
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	ff 75 08             	pushl  0x8(%ebp)
  800574:	e8 05 00 00 00       	call   80057e <vprintfmt>
	va_end(ap);
}
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	c9                   	leave  
  80057d:	c3                   	ret    

0080057e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	57                   	push   %edi
  800582:	56                   	push   %esi
  800583:	53                   	push   %ebx
  800584:	83 ec 2c             	sub    $0x2c,%esp
  800587:	8b 75 08             	mov    0x8(%ebp),%esi
  80058a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800590:	eb 12                	jmp    8005a4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800592:	85 c0                	test   %eax,%eax
  800594:	0f 84 89 03 00 00    	je     800923 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	50                   	push   %eax
  80059f:	ff d6                	call   *%esi
  8005a1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a4:	83 c7 01             	add    $0x1,%edi
  8005a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ab:	83 f8 25             	cmp    $0x25,%eax
  8005ae:	75 e2                	jne    800592 <vprintfmt+0x14>
  8005b0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005b4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ce:	eb 07                	jmp    8005d7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8d 47 01             	lea    0x1(%edi),%eax
  8005da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005dd:	0f b6 07             	movzbl (%edi),%eax
  8005e0:	0f b6 c8             	movzbl %al,%ecx
  8005e3:	83 e8 23             	sub    $0x23,%eax
  8005e6:	3c 55                	cmp    $0x55,%al
  8005e8:	0f 87 1a 03 00 00    	ja     800908 <vprintfmt+0x38a>
  8005ee:	0f b6 c0             	movzbl %al,%eax
  8005f1:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005fb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005ff:	eb d6                	jmp    8005d7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800604:	b8 00 00 00 00       	mov    $0x0,%eax
  800609:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80060c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80060f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800613:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800616:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800619:	83 fa 09             	cmp    $0x9,%edx
  80061c:	77 39                	ja     800657 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80061e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800621:	eb e9                	jmp    80060c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 48 04             	lea    0x4(%eax),%ecx
  800629:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800634:	eb 27                	jmp    80065d <vprintfmt+0xdf>
  800636:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800639:	85 c0                	test   %eax,%eax
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800640:	0f 49 c8             	cmovns %eax,%ecx
  800643:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800649:	eb 8c                	jmp    8005d7 <vprintfmt+0x59>
  80064b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80064e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800655:	eb 80                	jmp    8005d7 <vprintfmt+0x59>
  800657:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80065d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800661:	0f 89 70 ff ff ff    	jns    8005d7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800667:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80066a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80066d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800674:	e9 5e ff ff ff       	jmp    8005d7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800679:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80067f:	e9 53 ff ff ff       	jmp    8005d7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	ff 30                	pushl  (%eax)
  800693:	ff d6                	call   *%esi
			break;
  800695:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80069b:	e9 04 ff ff ff       	jmp    8005a4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	99                   	cltd   
  8006ac:	31 d0                	xor    %edx,%eax
  8006ae:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b0:	83 f8 0f             	cmp    $0xf,%eax
  8006b3:	7f 0b                	jg     8006c0 <vprintfmt+0x142>
  8006b5:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	75 18                	jne    8006d8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006c0:	50                   	push   %eax
  8006c1:	68 39 10 80 00       	push   $0x801039
  8006c6:	53                   	push   %ebx
  8006c7:	56                   	push   %esi
  8006c8:	e8 94 fe ff ff       	call   800561 <printfmt>
  8006cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d3:	e9 cc fe ff ff       	jmp    8005a4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006d8:	52                   	push   %edx
  8006d9:	68 42 10 80 00       	push   $0x801042
  8006de:	53                   	push   %ebx
  8006df:	56                   	push   %esi
  8006e0:	e8 7c fe ff ff       	call   800561 <printfmt>
  8006e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006eb:	e9 b4 fe ff ff       	jmp    8005a4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 50 04             	lea    0x4(%eax),%edx
  8006f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006fb:	85 ff                	test   %edi,%edi
  8006fd:	b8 32 10 80 00       	mov    $0x801032,%eax
  800702:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800705:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800709:	0f 8e 94 00 00 00    	jle    8007a3 <vprintfmt+0x225>
  80070f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800713:	0f 84 98 00 00 00    	je     8007b1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	ff 75 d0             	pushl  -0x30(%ebp)
  80071f:	57                   	push   %edi
  800720:	e8 86 02 00 00       	call   8009ab <strnlen>
  800725:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800728:	29 c1                	sub    %eax,%ecx
  80072a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80072d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800730:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800734:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800737:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80073a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80073c:	eb 0f                	jmp    80074d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	53                   	push   %ebx
  800742:	ff 75 e0             	pushl  -0x20(%ebp)
  800745:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800747:	83 ef 01             	sub    $0x1,%edi
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	85 ff                	test   %edi,%edi
  80074f:	7f ed                	jg     80073e <vprintfmt+0x1c0>
  800751:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800754:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800757:	85 c9                	test   %ecx,%ecx
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	0f 49 c1             	cmovns %ecx,%eax
  800761:	29 c1                	sub    %eax,%ecx
  800763:	89 75 08             	mov    %esi,0x8(%ebp)
  800766:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800769:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076c:	89 cb                	mov    %ecx,%ebx
  80076e:	eb 4d                	jmp    8007bd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800770:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800774:	74 1b                	je     800791 <vprintfmt+0x213>
  800776:	0f be c0             	movsbl %al,%eax
  800779:	83 e8 20             	sub    $0x20,%eax
  80077c:	83 f8 5e             	cmp    $0x5e,%eax
  80077f:	76 10                	jbe    800791 <vprintfmt+0x213>
					putch('?', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	ff 75 0c             	pushl  0xc(%ebp)
  800787:	6a 3f                	push   $0x3f
  800789:	ff 55 08             	call   *0x8(%ebp)
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	eb 0d                	jmp    80079e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	ff 75 0c             	pushl  0xc(%ebp)
  800797:	52                   	push   %edx
  800798:	ff 55 08             	call   *0x8(%ebp)
  80079b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80079e:	83 eb 01             	sub    $0x1,%ebx
  8007a1:	eb 1a                	jmp    8007bd <vprintfmt+0x23f>
  8007a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007af:	eb 0c                	jmp    8007bd <vprintfmt+0x23f>
  8007b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007ba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007bd:	83 c7 01             	add    $0x1,%edi
  8007c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007c4:	0f be d0             	movsbl %al,%edx
  8007c7:	85 d2                	test   %edx,%edx
  8007c9:	74 23                	je     8007ee <vprintfmt+0x270>
  8007cb:	85 f6                	test   %esi,%esi
  8007cd:	78 a1                	js     800770 <vprintfmt+0x1f2>
  8007cf:	83 ee 01             	sub    $0x1,%esi
  8007d2:	79 9c                	jns    800770 <vprintfmt+0x1f2>
  8007d4:	89 df                	mov    %ebx,%edi
  8007d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007dc:	eb 18                	jmp    8007f6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	53                   	push   %ebx
  8007e2:	6a 20                	push   $0x20
  8007e4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007e6:	83 ef 01             	sub    $0x1,%edi
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	eb 08                	jmp    8007f6 <vprintfmt+0x278>
  8007ee:	89 df                	mov    %ebx,%edi
  8007f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f6:	85 ff                	test   %edi,%edi
  8007f8:	7f e4                	jg     8007de <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007fd:	e9 a2 fd ff ff       	jmp    8005a4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800802:	83 fa 01             	cmp    $0x1,%edx
  800805:	7e 16                	jle    80081d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8d 50 08             	lea    0x8(%eax),%edx
  80080d:	89 55 14             	mov    %edx,0x14(%ebp)
  800810:	8b 50 04             	mov    0x4(%eax),%edx
  800813:	8b 00                	mov    (%eax),%eax
  800815:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800818:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80081b:	eb 32                	jmp    80084f <vprintfmt+0x2d1>
	else if (lflag)
  80081d:	85 d2                	test   %edx,%edx
  80081f:	74 18                	je     800839 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8d 50 04             	lea    0x4(%eax),%edx
  800827:	89 55 14             	mov    %edx,0x14(%ebp)
  80082a:	8b 00                	mov    (%eax),%eax
  80082c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082f:	89 c1                	mov    %eax,%ecx
  800831:	c1 f9 1f             	sar    $0x1f,%ecx
  800834:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800837:	eb 16                	jmp    80084f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800839:	8b 45 14             	mov    0x14(%ebp),%eax
  80083c:	8d 50 04             	lea    0x4(%eax),%edx
  80083f:	89 55 14             	mov    %edx,0x14(%ebp)
  800842:	8b 00                	mov    (%eax),%eax
  800844:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800847:	89 c1                	mov    %eax,%ecx
  800849:	c1 f9 1f             	sar    $0x1f,%ecx
  80084c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80084f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800852:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800855:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80085a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80085e:	79 74                	jns    8008d4 <vprintfmt+0x356>
				putch('-', putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 2d                	push   $0x2d
  800866:	ff d6                	call   *%esi
				num = -(long long) num;
  800868:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80086b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80086e:	f7 d8                	neg    %eax
  800870:	83 d2 00             	adc    $0x0,%edx
  800873:	f7 da                	neg    %edx
  800875:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800878:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80087d:	eb 55                	jmp    8008d4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80087f:	8d 45 14             	lea    0x14(%ebp),%eax
  800882:	e8 83 fc ff ff       	call   80050a <getuint>
			base = 10;
  800887:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80088c:	eb 46                	jmp    8008d4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80088e:	8d 45 14             	lea    0x14(%ebp),%eax
  800891:	e8 74 fc ff ff       	call   80050a <getuint>
			base = 8;
  800896:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80089b:	eb 37                	jmp    8008d4 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	6a 30                	push   $0x30
  8008a3:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a5:	83 c4 08             	add    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	6a 78                	push   $0x78
  8008ab:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8d 50 04             	lea    0x4(%eax),%edx
  8008b3:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008b6:	8b 00                	mov    (%eax),%eax
  8008b8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008bd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008c0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008c5:	eb 0d                	jmp    8008d4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ca:	e8 3b fc ff ff       	call   80050a <getuint>
			base = 16;
  8008cf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d4:	83 ec 0c             	sub    $0xc,%esp
  8008d7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008db:	57                   	push   %edi
  8008dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8008df:	51                   	push   %ecx
  8008e0:	52                   	push   %edx
  8008e1:	50                   	push   %eax
  8008e2:	89 da                	mov    %ebx,%edx
  8008e4:	89 f0                	mov    %esi,%eax
  8008e6:	e8 70 fb ff ff       	call   80045b <printnum>
			break;
  8008eb:	83 c4 20             	add    $0x20,%esp
  8008ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f1:	e9 ae fc ff ff       	jmp    8005a4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	53                   	push   %ebx
  8008fa:	51                   	push   %ecx
  8008fb:	ff d6                	call   *%esi
			break;
  8008fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800900:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800903:	e9 9c fc ff ff       	jmp    8005a4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	53                   	push   %ebx
  80090c:	6a 25                	push   $0x25
  80090e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	eb 03                	jmp    800918 <vprintfmt+0x39a>
  800915:	83 ef 01             	sub    $0x1,%edi
  800918:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80091c:	75 f7                	jne    800915 <vprintfmt+0x397>
  80091e:	e9 81 fc ff ff       	jmp    8005a4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800923:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	83 ec 18             	sub    $0x18,%esp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800937:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800948:	85 c0                	test   %eax,%eax
  80094a:	74 26                	je     800972 <vsnprintf+0x47>
  80094c:	85 d2                	test   %edx,%edx
  80094e:	7e 22                	jle    800972 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800950:	ff 75 14             	pushl  0x14(%ebp)
  800953:	ff 75 10             	pushl  0x10(%ebp)
  800956:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800959:	50                   	push   %eax
  80095a:	68 44 05 80 00       	push   $0x800544
  80095f:	e8 1a fc ff ff       	call   80057e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800964:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800967:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096d:	83 c4 10             	add    $0x10,%esp
  800970:	eb 05                	jmp    800977 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800972:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800982:	50                   	push   %eax
  800983:	ff 75 10             	pushl  0x10(%ebp)
  800986:	ff 75 0c             	pushl  0xc(%ebp)
  800989:	ff 75 08             	pushl  0x8(%ebp)
  80098c:	e8 9a ff ff ff       	call   80092b <vsnprintf>
	va_end(ap);

	return rc;
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
  80099e:	eb 03                	jmp    8009a3 <strlen+0x10>
		n++;
  8009a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a7:	75 f7                	jne    8009a0 <strlen+0xd>
		n++;
	return n;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b9:	eb 03                	jmp    8009be <strnlen+0x13>
		n++;
  8009bb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009be:	39 c2                	cmp    %eax,%edx
  8009c0:	74 08                	je     8009ca <strnlen+0x1f>
  8009c2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c6:	75 f3                	jne    8009bb <strnlen+0x10>
  8009c8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d6:	89 c2                	mov    %eax,%edx
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	83 c1 01             	add    $0x1,%ecx
  8009de:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e5:	84 db                	test   %bl,%bl
  8009e7:	75 ef                	jne    8009d8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	53                   	push   %ebx
  8009f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f3:	53                   	push   %ebx
  8009f4:	e8 9a ff ff ff       	call   800993 <strlen>
  8009f9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009fc:	ff 75 0c             	pushl  0xc(%ebp)
  8009ff:	01 d8                	add    %ebx,%eax
  800a01:	50                   	push   %eax
  800a02:	e8 c5 ff ff ff       	call   8009cc <strcpy>
	return dst;
}
  800a07:	89 d8                	mov    %ebx,%eax
  800a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 75 08             	mov    0x8(%ebp),%esi
  800a16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a19:	89 f3                	mov    %esi,%ebx
  800a1b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1e:	89 f2                	mov    %esi,%edx
  800a20:	eb 0f                	jmp    800a31 <strncpy+0x23>
		*dst++ = *src;
  800a22:	83 c2 01             	add    $0x1,%edx
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2b:	80 39 01             	cmpb   $0x1,(%ecx)
  800a2e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a31:	39 da                	cmp    %ebx,%edx
  800a33:	75 ed                	jne    800a22 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a35:	89 f0                	mov    %esi,%eax
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 75 08             	mov    0x8(%ebp),%esi
  800a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a46:	8b 55 10             	mov    0x10(%ebp),%edx
  800a49:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4b:	85 d2                	test   %edx,%edx
  800a4d:	74 21                	je     800a70 <strlcpy+0x35>
  800a4f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a53:	89 f2                	mov    %esi,%edx
  800a55:	eb 09                	jmp    800a60 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a60:	39 c2                	cmp    %eax,%edx
  800a62:	74 09                	je     800a6d <strlcpy+0x32>
  800a64:	0f b6 19             	movzbl (%ecx),%ebx
  800a67:	84 db                	test   %bl,%bl
  800a69:	75 ec                	jne    800a57 <strlcpy+0x1c>
  800a6b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a70:	29 f0                	sub    %esi,%eax
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7f:	eb 06                	jmp    800a87 <strcmp+0x11>
		p++, q++;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a87:	0f b6 01             	movzbl (%ecx),%eax
  800a8a:	84 c0                	test   %al,%al
  800a8c:	74 04                	je     800a92 <strcmp+0x1c>
  800a8e:	3a 02                	cmp    (%edx),%al
  800a90:	74 ef                	je     800a81 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a92:	0f b6 c0             	movzbl %al,%eax
  800a95:	0f b6 12             	movzbl (%edx),%edx
  800a98:	29 d0                	sub    %edx,%eax
}
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	53                   	push   %ebx
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa6:	89 c3                	mov    %eax,%ebx
  800aa8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aab:	eb 06                	jmp    800ab3 <strncmp+0x17>
		n--, p++, q++;
  800aad:	83 c0 01             	add    $0x1,%eax
  800ab0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab3:	39 d8                	cmp    %ebx,%eax
  800ab5:	74 15                	je     800acc <strncmp+0x30>
  800ab7:	0f b6 08             	movzbl (%eax),%ecx
  800aba:	84 c9                	test   %cl,%cl
  800abc:	74 04                	je     800ac2 <strncmp+0x26>
  800abe:	3a 0a                	cmp    (%edx),%cl
  800ac0:	74 eb                	je     800aad <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac2:	0f b6 00             	movzbl (%eax),%eax
  800ac5:	0f b6 12             	movzbl (%edx),%edx
  800ac8:	29 d0                	sub    %edx,%eax
  800aca:	eb 05                	jmp    800ad1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ade:	eb 07                	jmp    800ae7 <strchr+0x13>
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	74 0f                	je     800af3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae4:	83 c0 01             	add    $0x1,%eax
  800ae7:	0f b6 10             	movzbl (%eax),%edx
  800aea:	84 d2                	test   %dl,%dl
  800aec:	75 f2                	jne    800ae0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aff:	eb 03                	jmp    800b04 <strfind+0xf>
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b07:	38 ca                	cmp    %cl,%dl
  800b09:	74 04                	je     800b0f <strfind+0x1a>
  800b0b:	84 d2                	test   %dl,%dl
  800b0d:	75 f2                	jne    800b01 <strfind+0xc>
			break;
	return (char *) s;
}
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1d:	85 c9                	test   %ecx,%ecx
  800b1f:	74 36                	je     800b57 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b27:	75 28                	jne    800b51 <memset+0x40>
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	75 23                	jne    800b51 <memset+0x40>
		c &= 0xFF;
  800b2e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	c1 e3 08             	shl    $0x8,%ebx
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	c1 e6 18             	shl    $0x18,%esi
  800b3c:	89 d0                	mov    %edx,%eax
  800b3e:	c1 e0 10             	shl    $0x10,%eax
  800b41:	09 f0                	or     %esi,%eax
  800b43:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b45:	89 d8                	mov    %ebx,%eax
  800b47:	09 d0                	or     %edx,%eax
  800b49:	c1 e9 02             	shr    $0x2,%ecx
  800b4c:	fc                   	cld    
  800b4d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4f:	eb 06                	jmp    800b57 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b54:	fc                   	cld    
  800b55:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b57:	89 f8                	mov    %edi,%eax
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6c:	39 c6                	cmp    %eax,%esi
  800b6e:	73 35                	jae    800ba5 <memmove+0x47>
  800b70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b73:	39 d0                	cmp    %edx,%eax
  800b75:	73 2e                	jae    800ba5 <memmove+0x47>
		s += n;
		d += n;
  800b77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	09 fe                	or     %edi,%esi
  800b7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b84:	75 13                	jne    800b99 <memmove+0x3b>
  800b86:	f6 c1 03             	test   $0x3,%cl
  800b89:	75 0e                	jne    800b99 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b8b:	83 ef 04             	sub    $0x4,%edi
  800b8e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b91:	c1 e9 02             	shr    $0x2,%ecx
  800b94:	fd                   	std    
  800b95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b97:	eb 09                	jmp    800ba2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b99:	83 ef 01             	sub    $0x1,%edi
  800b9c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9f:	fd                   	std    
  800ba0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba2:	fc                   	cld    
  800ba3:	eb 1d                	jmp    800bc2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba5:	89 f2                	mov    %esi,%edx
  800ba7:	09 c2                	or     %eax,%edx
  800ba9:	f6 c2 03             	test   $0x3,%dl
  800bac:	75 0f                	jne    800bbd <memmove+0x5f>
  800bae:	f6 c1 03             	test   $0x3,%cl
  800bb1:	75 0a                	jne    800bbd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb3:	c1 e9 02             	shr    $0x2,%ecx
  800bb6:	89 c7                	mov    %eax,%edi
  800bb8:	fc                   	cld    
  800bb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbb:	eb 05                	jmp    800bc2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbd:	89 c7                	mov    %eax,%edi
  800bbf:	fc                   	cld    
  800bc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc9:	ff 75 10             	pushl  0x10(%ebp)
  800bcc:	ff 75 0c             	pushl  0xc(%ebp)
  800bcf:	ff 75 08             	pushl  0x8(%ebp)
  800bd2:	e8 87 ff ff ff       	call   800b5e <memmove>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be4:	89 c6                	mov    %eax,%esi
  800be6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be9:	eb 1a                	jmp    800c05 <memcmp+0x2c>
		if (*s1 != *s2)
  800beb:	0f b6 08             	movzbl (%eax),%ecx
  800bee:	0f b6 1a             	movzbl (%edx),%ebx
  800bf1:	38 d9                	cmp    %bl,%cl
  800bf3:	74 0a                	je     800bff <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf5:	0f b6 c1             	movzbl %cl,%eax
  800bf8:	0f b6 db             	movzbl %bl,%ebx
  800bfb:	29 d8                	sub    %ebx,%eax
  800bfd:	eb 0f                	jmp    800c0e <memcmp+0x35>
		s1++, s2++;
  800bff:	83 c0 01             	add    $0x1,%eax
  800c02:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c05:	39 f0                	cmp    %esi,%eax
  800c07:	75 e2                	jne    800beb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c19:	89 c1                	mov    %eax,%ecx
  800c1b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c22:	eb 0a                	jmp    800c2e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c24:	0f b6 10             	movzbl (%eax),%edx
  800c27:	39 da                	cmp    %ebx,%edx
  800c29:	74 07                	je     800c32 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2b:	83 c0 01             	add    $0x1,%eax
  800c2e:	39 c8                	cmp    %ecx,%eax
  800c30:	72 f2                	jb     800c24 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c32:	5b                   	pop    %ebx
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c41:	eb 03                	jmp    800c46 <strtol+0x11>
		s++;
  800c43:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c46:	0f b6 01             	movzbl (%ecx),%eax
  800c49:	3c 20                	cmp    $0x20,%al
  800c4b:	74 f6                	je     800c43 <strtol+0xe>
  800c4d:	3c 09                	cmp    $0x9,%al
  800c4f:	74 f2                	je     800c43 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c51:	3c 2b                	cmp    $0x2b,%al
  800c53:	75 0a                	jne    800c5f <strtol+0x2a>
		s++;
  800c55:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c58:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5d:	eb 11                	jmp    800c70 <strtol+0x3b>
  800c5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c64:	3c 2d                	cmp    $0x2d,%al
  800c66:	75 08                	jne    800c70 <strtol+0x3b>
		s++, neg = 1;
  800c68:	83 c1 01             	add    $0x1,%ecx
  800c6b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c70:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c76:	75 15                	jne    800c8d <strtol+0x58>
  800c78:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7b:	75 10                	jne    800c8d <strtol+0x58>
  800c7d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c81:	75 7c                	jne    800cff <strtol+0xca>
		s += 2, base = 16;
  800c83:	83 c1 02             	add    $0x2,%ecx
  800c86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8b:	eb 16                	jmp    800ca3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c8d:	85 db                	test   %ebx,%ebx
  800c8f:	75 12                	jne    800ca3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c91:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c96:	80 39 30             	cmpb   $0x30,(%ecx)
  800c99:	75 08                	jne    800ca3 <strtol+0x6e>
		s++, base = 8;
  800c9b:	83 c1 01             	add    $0x1,%ecx
  800c9e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cab:	0f b6 11             	movzbl (%ecx),%edx
  800cae:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb1:	89 f3                	mov    %esi,%ebx
  800cb3:	80 fb 09             	cmp    $0x9,%bl
  800cb6:	77 08                	ja     800cc0 <strtol+0x8b>
			dig = *s - '0';
  800cb8:	0f be d2             	movsbl %dl,%edx
  800cbb:	83 ea 30             	sub    $0x30,%edx
  800cbe:	eb 22                	jmp    800ce2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	80 fb 19             	cmp    $0x19,%bl
  800cc8:	77 08                	ja     800cd2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cca:	0f be d2             	movsbl %dl,%edx
  800ccd:	83 ea 57             	sub    $0x57,%edx
  800cd0:	eb 10                	jmp    800ce2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd5:	89 f3                	mov    %esi,%ebx
  800cd7:	80 fb 19             	cmp    $0x19,%bl
  800cda:	77 16                	ja     800cf2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cdc:	0f be d2             	movsbl %dl,%edx
  800cdf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce5:	7d 0b                	jge    800cf2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce7:	83 c1 01             	add    $0x1,%ecx
  800cea:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cee:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf0:	eb b9                	jmp    800cab <strtol+0x76>

	if (endptr)
  800cf2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf6:	74 0d                	je     800d05 <strtol+0xd0>
		*endptr = (char *) s;
  800cf8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cfb:	89 0e                	mov    %ecx,(%esi)
  800cfd:	eb 06                	jmp    800d05 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	74 98                	je     800c9b <strtol+0x66>
  800d03:	eb 9e                	jmp    800ca3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d05:	89 c2                	mov    %eax,%edx
  800d07:	f7 da                	neg    %edx
  800d09:	85 ff                	test   %edi,%edi
  800d0b:	0f 45 c2             	cmovne %edx,%eax
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    
  800d13:	66 90                	xchg   %ax,%ax
  800d15:	66 90                	xchg   %ax,%ax
  800d17:	66 90                	xchg   %ax,%ax
  800d19:	66 90                	xchg   %ax,%ax
  800d1b:	66 90                	xchg   %ax,%ax
  800d1d:	66 90                	xchg   %ax,%ax
  800d1f:	90                   	nop

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
