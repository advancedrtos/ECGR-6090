
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 32 01 00 00       	call   800179 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 6e 02 00 00       	call   8002c4 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  800070:	e8 c6 00 00 00       	call   80013b <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 42 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	b8 03 00 00 00       	mov    $0x3,%eax
  80010d:	8b 55 08             	mov    0x8(%ebp),%edx
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7e 17                	jle    800133 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	50                   	push   %eax
  800120:	6a 03                	push   $0x3
  800122:	68 aa 0f 80 00       	push   $0x800faa
  800127:	6a 23                	push   $0x23
  800129:	68 c7 0f 80 00       	push   $0x800fc7
  80012e:	e8 37 02 00 00       	call   80036a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 17                	jle    8001b4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	6a 04                	push   $0x4
  8001a3:	68 aa 0f 80 00       	push   $0x800faa
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 c7 0f 80 00       	push   $0x800fc7
  8001af:	e8 b6 01 00 00       	call   80036a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7e 17                	jle    8001f6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	50                   	push   %eax
  8001e3:	6a 05                	push   $0x5
  8001e5:	68 aa 0f 80 00       	push   $0x800faa
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 c7 0f 80 00       	push   $0x800fc7
  8001f1:	e8 74 01 00 00       	call   80036a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	b8 06 00 00 00       	mov    $0x6,%eax
  800211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7e 17                	jle    800238 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	50                   	push   %eax
  800225:	6a 06                	push   $0x6
  800227:	68 aa 0f 80 00       	push   $0x800faa
  80022c:	6a 23                	push   $0x23
  80022e:	68 c7 0f 80 00       	push   $0x800fc7
  800233:	e8 32 01 00 00       	call   80036a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 17                	jle    80027a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	50                   	push   %eax
  800267:	6a 08                	push   $0x8
  800269:	68 aa 0f 80 00       	push   $0x800faa
  80026e:	6a 23                	push   $0x23
  800270:	68 c7 0f 80 00       	push   $0x800fc7
  800275:	e8 f0 00 00 00       	call   80036a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	b8 09 00 00 00       	mov    $0x9,%eax
  800295:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7e 17                	jle    8002bc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	50                   	push   %eax
  8002a9:	6a 09                	push   $0x9
  8002ab:	68 aa 0f 80 00       	push   $0x800faa
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 c7 0f 80 00       	push   $0x800fc7
  8002b7:	e8 ae 00 00 00       	call   80036a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	89 df                	mov    %ebx,%edi
  8002df:	89 de                	mov    %ebx,%esi
  8002e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	7e 17                	jle    8002fe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e7:	83 ec 0c             	sub    $0xc,%esp
  8002ea:	50                   	push   %eax
  8002eb:	6a 0a                	push   $0xa
  8002ed:	68 aa 0f 80 00       	push   $0x800faa
  8002f2:	6a 23                	push   $0x23
  8002f4:	68 c7 0f 80 00       	push   $0x800fc7
  8002f9:	e8 6c 00 00 00       	call   80036a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030c:	be 00 00 00 00       	mov    $0x0,%esi
  800311:	b8 0c 00 00 00       	mov    $0xc,%eax
  800316:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800322:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
  800337:	b8 0d 00 00 00       	mov    $0xd,%eax
  80033c:	8b 55 08             	mov    0x8(%ebp),%edx
  80033f:	89 cb                	mov    %ecx,%ebx
  800341:	89 cf                	mov    %ecx,%edi
  800343:	89 ce                	mov    %ecx,%esi
  800345:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800347:	85 c0                	test   %eax,%eax
  800349:	7e 17                	jle    800362 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034b:	83 ec 0c             	sub    $0xc,%esp
  80034e:	50                   	push   %eax
  80034f:	6a 0d                	push   $0xd
  800351:	68 aa 0f 80 00       	push   $0x800faa
  800356:	6a 23                	push   $0x23
  800358:	68 c7 0f 80 00       	push   $0x800fc7
  80035d:	e8 08 00 00 00       	call   80036a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800362:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80036f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800372:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800378:	e8 be fd ff ff       	call   80013b <sys_getenvid>
  80037d:	83 ec 0c             	sub    $0xc,%esp
  800380:	ff 75 0c             	pushl  0xc(%ebp)
  800383:	ff 75 08             	pushl  0x8(%ebp)
  800386:	56                   	push   %esi
  800387:	50                   	push   %eax
  800388:	68 d8 0f 80 00       	push   $0x800fd8
  80038d:	e8 b1 00 00 00       	call   800443 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800392:	83 c4 18             	add    $0x18,%esp
  800395:	53                   	push   %ebx
  800396:	ff 75 10             	pushl  0x10(%ebp)
  800399:	e8 54 00 00 00       	call   8003f2 <vcprintf>
	cprintf("\n");
  80039e:	c7 04 24 fb 0f 80 00 	movl   $0x800ffb,(%esp)
  8003a5:	e8 99 00 00 00       	call   800443 <cprintf>
  8003aa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ad:	cc                   	int3   
  8003ae:	eb fd                	jmp    8003ad <_panic+0x43>

008003b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ba:	8b 13                	mov    (%ebx),%edx
  8003bc:	8d 42 01             	lea    0x1(%edx),%eax
  8003bf:	89 03                	mov    %eax,(%ebx)
  8003c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003cd:	75 1a                	jne    8003e9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003cf:	83 ec 08             	sub    $0x8,%esp
  8003d2:	68 ff 00 00 00       	push   $0xff
  8003d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8003da:	50                   	push   %eax
  8003db:	e8 dd fc ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  8003e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003e6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003e9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800402:	00 00 00 
	b.cnt = 0;
  800405:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80040c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80040f:	ff 75 0c             	pushl  0xc(%ebp)
  800412:	ff 75 08             	pushl  0x8(%ebp)
  800415:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80041b:	50                   	push   %eax
  80041c:	68 b0 03 80 00       	push   $0x8003b0
  800421:	e8 54 01 00 00       	call   80057a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800426:	83 c4 08             	add    $0x8,%esp
  800429:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80042f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800435:	50                   	push   %eax
  800436:	e8 82 fc ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  80043b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800441:	c9                   	leave  
  800442:	c3                   	ret    

00800443 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
  800446:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800449:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80044c:	50                   	push   %eax
  80044d:	ff 75 08             	pushl  0x8(%ebp)
  800450:	e8 9d ff ff ff       	call   8003f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800455:	c9                   	leave  
  800456:	c3                   	ret    

00800457 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	57                   	push   %edi
  80045b:	56                   	push   %esi
  80045c:	53                   	push   %ebx
  80045d:	83 ec 1c             	sub    $0x1c,%esp
  800460:	89 c7                	mov    %eax,%edi
  800462:	89 d6                	mov    %edx,%esi
  800464:	8b 45 08             	mov    0x8(%ebp),%eax
  800467:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800470:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800473:	bb 00 00 00 00       	mov    $0x0,%ebx
  800478:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80047b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80047e:	39 d3                	cmp    %edx,%ebx
  800480:	72 05                	jb     800487 <printnum+0x30>
  800482:	39 45 10             	cmp    %eax,0x10(%ebp)
  800485:	77 45                	ja     8004cc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800487:	83 ec 0c             	sub    $0xc,%esp
  80048a:	ff 75 18             	pushl  0x18(%ebp)
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800493:	53                   	push   %ebx
  800494:	ff 75 10             	pushl  0x10(%ebp)
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049d:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a6:	e8 65 08 00 00       	call   800d10 <__udivdi3>
  8004ab:	83 c4 18             	add    $0x18,%esp
  8004ae:	52                   	push   %edx
  8004af:	50                   	push   %eax
  8004b0:	89 f2                	mov    %esi,%edx
  8004b2:	89 f8                	mov    %edi,%eax
  8004b4:	e8 9e ff ff ff       	call   800457 <printnum>
  8004b9:	83 c4 20             	add    $0x20,%esp
  8004bc:	eb 18                	jmp    8004d6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	56                   	push   %esi
  8004c2:	ff 75 18             	pushl  0x18(%ebp)
  8004c5:	ff d7                	call   *%edi
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	eb 03                	jmp    8004cf <printnum+0x78>
  8004cc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004cf:	83 eb 01             	sub    $0x1,%ebx
  8004d2:	85 db                	test   %ebx,%ebx
  8004d4:	7f e8                	jg     8004be <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	56                   	push   %esi
  8004da:	83 ec 04             	sub    $0x4,%esp
  8004dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e9:	e8 52 09 00 00       	call   800e40 <__umoddi3>
  8004ee:	83 c4 14             	add    $0x14,%esp
  8004f1:	0f be 80 fd 0f 80 00 	movsbl 0x800ffd(%eax),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff d7                	call   *%edi
}
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800501:	5b                   	pop    %ebx
  800502:	5e                   	pop    %esi
  800503:	5f                   	pop    %edi
  800504:	5d                   	pop    %ebp
  800505:	c3                   	ret    

00800506 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800509:	83 fa 01             	cmp    $0x1,%edx
  80050c:	7e 0e                	jle    80051c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80050e:	8b 10                	mov    (%eax),%edx
  800510:	8d 4a 08             	lea    0x8(%edx),%ecx
  800513:	89 08                	mov    %ecx,(%eax)
  800515:	8b 02                	mov    (%edx),%eax
  800517:	8b 52 04             	mov    0x4(%edx),%edx
  80051a:	eb 22                	jmp    80053e <getuint+0x38>
	else if (lflag)
  80051c:	85 d2                	test   %edx,%edx
  80051e:	74 10                	je     800530 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800520:	8b 10                	mov    (%eax),%edx
  800522:	8d 4a 04             	lea    0x4(%edx),%ecx
  800525:	89 08                	mov    %ecx,(%eax)
  800527:	8b 02                	mov    (%edx),%eax
  800529:	ba 00 00 00 00       	mov    $0x0,%edx
  80052e:	eb 0e                	jmp    80053e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800530:	8b 10                	mov    (%eax),%edx
  800532:	8d 4a 04             	lea    0x4(%edx),%ecx
  800535:	89 08                	mov    %ecx,(%eax)
  800537:	8b 02                	mov    (%edx),%eax
  800539:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80053e:	5d                   	pop    %ebp
  80053f:	c3                   	ret    

00800540 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800546:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80054a:	8b 10                	mov    (%eax),%edx
  80054c:	3b 50 04             	cmp    0x4(%eax),%edx
  80054f:	73 0a                	jae    80055b <sprintputch+0x1b>
		*b->buf++ = ch;
  800551:	8d 4a 01             	lea    0x1(%edx),%ecx
  800554:	89 08                	mov    %ecx,(%eax)
  800556:	8b 45 08             	mov    0x8(%ebp),%eax
  800559:	88 02                	mov    %al,(%edx)
}
  80055b:	5d                   	pop    %ebp
  80055c:	c3                   	ret    

0080055d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800563:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800566:	50                   	push   %eax
  800567:	ff 75 10             	pushl  0x10(%ebp)
  80056a:	ff 75 0c             	pushl  0xc(%ebp)
  80056d:	ff 75 08             	pushl  0x8(%ebp)
  800570:	e8 05 00 00 00       	call   80057a <vprintfmt>
	va_end(ap);
}
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	c9                   	leave  
  800579:	c3                   	ret    

0080057a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	57                   	push   %edi
  80057e:	56                   	push   %esi
  80057f:	53                   	push   %ebx
  800580:	83 ec 2c             	sub    $0x2c,%esp
  800583:	8b 75 08             	mov    0x8(%ebp),%esi
  800586:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800589:	8b 7d 10             	mov    0x10(%ebp),%edi
  80058c:	eb 12                	jmp    8005a0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80058e:	85 c0                	test   %eax,%eax
  800590:	0f 84 89 03 00 00    	je     80091f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	53                   	push   %ebx
  80059a:	50                   	push   %eax
  80059b:	ff d6                	call   *%esi
  80059d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a0:	83 c7 01             	add    $0x1,%edi
  8005a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a7:	83 f8 25             	cmp    $0x25,%eax
  8005aa:	75 e2                	jne    80058e <vprintfmt+0x14>
  8005ac:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005be:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ca:	eb 07                	jmp    8005d3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005cf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8d 47 01             	lea    0x1(%edi),%eax
  8005d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d9:	0f b6 07             	movzbl (%edi),%eax
  8005dc:	0f b6 c8             	movzbl %al,%ecx
  8005df:	83 e8 23             	sub    $0x23,%eax
  8005e2:	3c 55                	cmp    $0x55,%al
  8005e4:	0f 87 1a 03 00 00    	ja     800904 <vprintfmt+0x38a>
  8005ea:	0f b6 c0             	movzbl %al,%eax
  8005ed:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005f7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005fb:	eb d6                	jmp    8005d3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800600:	b8 00 00 00 00       	mov    $0x0,%eax
  800605:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800608:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80060b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80060f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800612:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800615:	83 fa 09             	cmp    $0x9,%edx
  800618:	77 39                	ja     800653 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80061a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80061d:	eb e9                	jmp    800608 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 48 04             	lea    0x4(%eax),%ecx
  800625:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800630:	eb 27                	jmp    800659 <vprintfmt+0xdf>
  800632:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800635:	85 c0                	test   %eax,%eax
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	0f 49 c8             	cmovns %eax,%ecx
  80063f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800645:	eb 8c                	jmp    8005d3 <vprintfmt+0x59>
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80064a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800651:	eb 80                	jmp    8005d3 <vprintfmt+0x59>
  800653:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800656:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800659:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065d:	0f 89 70 ff ff ff    	jns    8005d3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800663:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800666:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800669:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800670:	e9 5e ff ff ff       	jmp    8005d3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800675:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800678:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80067b:	e9 53 ff ff ff       	jmp    8005d3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	ff 30                	pushl  (%eax)
  80068f:	ff d6                	call   *%esi
			break;
  800691:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800697:	e9 04 ff ff ff       	jmp    8005a0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a5:	8b 00                	mov    (%eax),%eax
  8006a7:	99                   	cltd   
  8006a8:	31 d0                	xor    %edx,%eax
  8006aa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ac:	83 f8 0f             	cmp    $0xf,%eax
  8006af:	7f 0b                	jg     8006bc <vprintfmt+0x142>
  8006b1:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	75 18                	jne    8006d4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006bc:	50                   	push   %eax
  8006bd:	68 15 10 80 00       	push   $0x801015
  8006c2:	53                   	push   %ebx
  8006c3:	56                   	push   %esi
  8006c4:	e8 94 fe ff ff       	call   80055d <printfmt>
  8006c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006cf:	e9 cc fe ff ff       	jmp    8005a0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006d4:	52                   	push   %edx
  8006d5:	68 1e 10 80 00       	push   $0x80101e
  8006da:	53                   	push   %ebx
  8006db:	56                   	push   %esi
  8006dc:	e8 7c fe ff ff       	call   80055d <printfmt>
  8006e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e7:	e9 b4 fe ff ff       	jmp    8005a0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8d 50 04             	lea    0x4(%eax),%edx
  8006f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006f7:	85 ff                	test   %edi,%edi
  8006f9:	b8 0e 10 80 00       	mov    $0x80100e,%eax
  8006fe:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800701:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800705:	0f 8e 94 00 00 00    	jle    80079f <vprintfmt+0x225>
  80070b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80070f:	0f 84 98 00 00 00    	je     8007ad <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	ff 75 d0             	pushl  -0x30(%ebp)
  80071b:	57                   	push   %edi
  80071c:	e8 86 02 00 00       	call   8009a7 <strnlen>
  800721:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800724:	29 c1                	sub    %eax,%ecx
  800726:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800729:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80072c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800730:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800733:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800736:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800738:	eb 0f                	jmp    800749 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	ff 75 e0             	pushl  -0x20(%ebp)
  800741:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800743:	83 ef 01             	sub    $0x1,%edi
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	85 ff                	test   %edi,%edi
  80074b:	7f ed                	jg     80073a <vprintfmt+0x1c0>
  80074d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800750:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800753:	85 c9                	test   %ecx,%ecx
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
  80075a:	0f 49 c1             	cmovns %ecx,%eax
  80075d:	29 c1                	sub    %eax,%ecx
  80075f:	89 75 08             	mov    %esi,0x8(%ebp)
  800762:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800765:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800768:	89 cb                	mov    %ecx,%ebx
  80076a:	eb 4d                	jmp    8007b9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80076c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800770:	74 1b                	je     80078d <vprintfmt+0x213>
  800772:	0f be c0             	movsbl %al,%eax
  800775:	83 e8 20             	sub    $0x20,%eax
  800778:	83 f8 5e             	cmp    $0x5e,%eax
  80077b:	76 10                	jbe    80078d <vprintfmt+0x213>
					putch('?', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	6a 3f                	push   $0x3f
  800785:	ff 55 08             	call   *0x8(%ebp)
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 0d                	jmp    80079a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80078d:	83 ec 08             	sub    $0x8,%esp
  800790:	ff 75 0c             	pushl  0xc(%ebp)
  800793:	52                   	push   %edx
  800794:	ff 55 08             	call   *0x8(%ebp)
  800797:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80079a:	83 eb 01             	sub    $0x1,%ebx
  80079d:	eb 1a                	jmp    8007b9 <vprintfmt+0x23f>
  80079f:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007ab:	eb 0c                	jmp    8007b9 <vprintfmt+0x23f>
  8007ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007b9:	83 c7 01             	add    $0x1,%edi
  8007bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007c0:	0f be d0             	movsbl %al,%edx
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 23                	je     8007ea <vprintfmt+0x270>
  8007c7:	85 f6                	test   %esi,%esi
  8007c9:	78 a1                	js     80076c <vprintfmt+0x1f2>
  8007cb:	83 ee 01             	sub    $0x1,%esi
  8007ce:	79 9c                	jns    80076c <vprintfmt+0x1f2>
  8007d0:	89 df                	mov    %ebx,%edi
  8007d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d8:	eb 18                	jmp    8007f2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	53                   	push   %ebx
  8007de:	6a 20                	push   $0x20
  8007e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007e2:	83 ef 01             	sub    $0x1,%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 08                	jmp    8007f2 <vprintfmt+0x278>
  8007ea:	89 df                	mov    %ebx,%edi
  8007ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f2:	85 ff                	test   %edi,%edi
  8007f4:	7f e4                	jg     8007da <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f9:	e9 a2 fd ff ff       	jmp    8005a0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007fe:	83 fa 01             	cmp    $0x1,%edx
  800801:	7e 16                	jle    800819 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	8d 50 08             	lea    0x8(%eax),%edx
  800809:	89 55 14             	mov    %edx,0x14(%ebp)
  80080c:	8b 50 04             	mov    0x4(%eax),%edx
  80080f:	8b 00                	mov    (%eax),%eax
  800811:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800814:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800817:	eb 32                	jmp    80084b <vprintfmt+0x2d1>
	else if (lflag)
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 18                	je     800835 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8d 50 04             	lea    0x4(%eax),%edx
  800823:	89 55 14             	mov    %edx,0x14(%ebp)
  800826:	8b 00                	mov    (%eax),%eax
  800828:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082b:	89 c1                	mov    %eax,%ecx
  80082d:	c1 f9 1f             	sar    $0x1f,%ecx
  800830:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800833:	eb 16                	jmp    80084b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8d 50 04             	lea    0x4(%eax),%edx
  80083b:	89 55 14             	mov    %edx,0x14(%ebp)
  80083e:	8b 00                	mov    (%eax),%eax
  800840:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800843:	89 c1                	mov    %eax,%ecx
  800845:	c1 f9 1f             	sar    $0x1f,%ecx
  800848:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80084b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80084e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800851:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800856:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80085a:	79 74                	jns    8008d0 <vprintfmt+0x356>
				putch('-', putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	53                   	push   %ebx
  800860:	6a 2d                	push   $0x2d
  800862:	ff d6                	call   *%esi
				num = -(long long) num;
  800864:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800867:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80086a:	f7 d8                	neg    %eax
  80086c:	83 d2 00             	adc    $0x0,%edx
  80086f:	f7 da                	neg    %edx
  800871:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800874:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800879:	eb 55                	jmp    8008d0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
  80087e:	e8 83 fc ff ff       	call   800506 <getuint>
			base = 10;
  800883:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800888:	eb 46                	jmp    8008d0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80088a:	8d 45 14             	lea    0x14(%ebp),%eax
  80088d:	e8 74 fc ff ff       	call   800506 <getuint>
			base = 8;
  800892:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800897:	eb 37                	jmp    8008d0 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  800899:	83 ec 08             	sub    $0x8,%esp
  80089c:	53                   	push   %ebx
  80089d:	6a 30                	push   $0x30
  80089f:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a1:	83 c4 08             	add    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	6a 78                	push   $0x78
  8008a7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ac:	8d 50 04             	lea    0x4(%eax),%edx
  8008af:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008b2:	8b 00                	mov    (%eax),%eax
  8008b4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008bc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008c1:	eb 0d                	jmp    8008d0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c6:	e8 3b fc ff ff       	call   800506 <getuint>
			base = 16;
  8008cb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d0:	83 ec 0c             	sub    $0xc,%esp
  8008d3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d7:	57                   	push   %edi
  8008d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008db:	51                   	push   %ecx
  8008dc:	52                   	push   %edx
  8008dd:	50                   	push   %eax
  8008de:	89 da                	mov    %ebx,%edx
  8008e0:	89 f0                	mov    %esi,%eax
  8008e2:	e8 70 fb ff ff       	call   800457 <printnum>
			break;
  8008e7:	83 c4 20             	add    $0x20,%esp
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ed:	e9 ae fc ff ff       	jmp    8005a0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	53                   	push   %ebx
  8008f6:	51                   	push   %ecx
  8008f7:	ff d6                	call   *%esi
			break;
  8008f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ff:	e9 9c fc ff ff       	jmp    8005a0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800904:	83 ec 08             	sub    $0x8,%esp
  800907:	53                   	push   %ebx
  800908:	6a 25                	push   $0x25
  80090a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	eb 03                	jmp    800914 <vprintfmt+0x39a>
  800911:	83 ef 01             	sub    $0x1,%edi
  800914:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800918:	75 f7                	jne    800911 <vprintfmt+0x397>
  80091a:	e9 81 fc ff ff       	jmp    8005a0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80091f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5f                   	pop    %edi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	83 ec 18             	sub    $0x18,%esp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800933:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800936:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80093d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800944:	85 c0                	test   %eax,%eax
  800946:	74 26                	je     80096e <vsnprintf+0x47>
  800948:	85 d2                	test   %edx,%edx
  80094a:	7e 22                	jle    80096e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80094c:	ff 75 14             	pushl  0x14(%ebp)
  80094f:	ff 75 10             	pushl  0x10(%ebp)
  800952:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800955:	50                   	push   %eax
  800956:	68 40 05 80 00       	push   $0x800540
  80095b:	e8 1a fc ff ff       	call   80057a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800960:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800963:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800969:	83 c4 10             	add    $0x10,%esp
  80096c:	eb 05                	jmp    800973 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80096e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097e:	50                   	push   %eax
  80097f:	ff 75 10             	pushl  0x10(%ebp)
  800982:	ff 75 0c             	pushl  0xc(%ebp)
  800985:	ff 75 08             	pushl  0x8(%ebp)
  800988:	e8 9a ff ff ff       	call   800927 <vsnprintf>
	va_end(ap);

	return rc;
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
  80099a:	eb 03                	jmp    80099f <strlen+0x10>
		n++;
  80099c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80099f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a3:	75 f7                	jne    80099c <strlen+0xd>
		n++;
	return n;
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b5:	eb 03                	jmp    8009ba <strnlen+0x13>
		n++;
  8009b7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ba:	39 c2                	cmp    %eax,%edx
  8009bc:	74 08                	je     8009c6 <strnlen+0x1f>
  8009be:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c2:	75 f3                	jne    8009b7 <strnlen+0x10>
  8009c4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	53                   	push   %ebx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d2:	89 c2                	mov    %eax,%edx
  8009d4:	83 c2 01             	add    $0x1,%edx
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009de:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e1:	84 db                	test   %bl,%bl
  8009e3:	75 ef                	jne    8009d4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	53                   	push   %ebx
  8009ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009ef:	53                   	push   %ebx
  8009f0:	e8 9a ff ff ff       	call   80098f <strlen>
  8009f5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009f8:	ff 75 0c             	pushl  0xc(%ebp)
  8009fb:	01 d8                	add    %ebx,%eax
  8009fd:	50                   	push   %eax
  8009fe:	e8 c5 ff ff ff       	call   8009c8 <strcpy>
	return dst;
}
  800a03:	89 d8                	mov    %ebx,%eax
  800a05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a15:	89 f3                	mov    %esi,%ebx
  800a17:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1a:	89 f2                	mov    %esi,%edx
  800a1c:	eb 0f                	jmp    800a2d <strncpy+0x23>
		*dst++ = *src;
  800a1e:	83 c2 01             	add    $0x1,%edx
  800a21:	0f b6 01             	movzbl (%ecx),%eax
  800a24:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a27:	80 39 01             	cmpb   $0x1,(%ecx)
  800a2a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2d:	39 da                	cmp    %ebx,%edx
  800a2f:	75 ed                	jne    800a1e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a31:	89 f0                	mov    %esi,%eax
  800a33:	5b                   	pop    %ebx
  800a34:	5e                   	pop    %esi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a42:	8b 55 10             	mov    0x10(%ebp),%edx
  800a45:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a47:	85 d2                	test   %edx,%edx
  800a49:	74 21                	je     800a6c <strlcpy+0x35>
  800a4b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a4f:	89 f2                	mov    %esi,%edx
  800a51:	eb 09                	jmp    800a5c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a53:	83 c2 01             	add    $0x1,%edx
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a5c:	39 c2                	cmp    %eax,%edx
  800a5e:	74 09                	je     800a69 <strlcpy+0x32>
  800a60:	0f b6 19             	movzbl (%ecx),%ebx
  800a63:	84 db                	test   %bl,%bl
  800a65:	75 ec                	jne    800a53 <strlcpy+0x1c>
  800a67:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a69:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a6c:	29 f0                	sub    %esi,%eax
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a78:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7b:	eb 06                	jmp    800a83 <strcmp+0x11>
		p++, q++;
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a83:	0f b6 01             	movzbl (%ecx),%eax
  800a86:	84 c0                	test   %al,%al
  800a88:	74 04                	je     800a8e <strcmp+0x1c>
  800a8a:	3a 02                	cmp    (%edx),%al
  800a8c:	74 ef                	je     800a7d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8e:	0f b6 c0             	movzbl %al,%eax
  800a91:	0f b6 12             	movzbl (%edx),%edx
  800a94:	29 d0                	sub    %edx,%eax
}
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	53                   	push   %ebx
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa2:	89 c3                	mov    %eax,%ebx
  800aa4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa7:	eb 06                	jmp    800aaf <strncmp+0x17>
		n--, p++, q++;
  800aa9:	83 c0 01             	add    $0x1,%eax
  800aac:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aaf:	39 d8                	cmp    %ebx,%eax
  800ab1:	74 15                	je     800ac8 <strncmp+0x30>
  800ab3:	0f b6 08             	movzbl (%eax),%ecx
  800ab6:	84 c9                	test   %cl,%cl
  800ab8:	74 04                	je     800abe <strncmp+0x26>
  800aba:	3a 0a                	cmp    (%edx),%cl
  800abc:	74 eb                	je     800aa9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800abe:	0f b6 00             	movzbl (%eax),%eax
  800ac1:	0f b6 12             	movzbl (%edx),%edx
  800ac4:	29 d0                	sub    %edx,%eax
  800ac6:	eb 05                	jmp    800acd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800acd:	5b                   	pop    %ebx
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ada:	eb 07                	jmp    800ae3 <strchr+0x13>
		if (*s == c)
  800adc:	38 ca                	cmp    %cl,%dl
  800ade:	74 0f                	je     800aef <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae0:	83 c0 01             	add    $0x1,%eax
  800ae3:	0f b6 10             	movzbl (%eax),%edx
  800ae6:	84 d2                	test   %dl,%dl
  800ae8:	75 f2                	jne    800adc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800afb:	eb 03                	jmp    800b00 <strfind+0xf>
  800afd:	83 c0 01             	add    $0x1,%eax
  800b00:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b03:	38 ca                	cmp    %cl,%dl
  800b05:	74 04                	je     800b0b <strfind+0x1a>
  800b07:	84 d2                	test   %dl,%dl
  800b09:	75 f2                	jne    800afd <strfind+0xc>
			break;
	return (char *) s;
}
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b19:	85 c9                	test   %ecx,%ecx
  800b1b:	74 36                	je     800b53 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b23:	75 28                	jne    800b4d <memset+0x40>
  800b25:	f6 c1 03             	test   $0x3,%cl
  800b28:	75 23                	jne    800b4d <memset+0x40>
		c &= 0xFF;
  800b2a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b2e:	89 d3                	mov    %edx,%ebx
  800b30:	c1 e3 08             	shl    $0x8,%ebx
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	c1 e6 18             	shl    $0x18,%esi
  800b38:	89 d0                	mov    %edx,%eax
  800b3a:	c1 e0 10             	shl    $0x10,%eax
  800b3d:	09 f0                	or     %esi,%eax
  800b3f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b41:	89 d8                	mov    %ebx,%eax
  800b43:	09 d0                	or     %edx,%eax
  800b45:	c1 e9 02             	shr    $0x2,%ecx
  800b48:	fc                   	cld    
  800b49:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4b:	eb 06                	jmp    800b53 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	fc                   	cld    
  800b51:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b53:	89 f8                	mov    %edi,%eax
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b68:	39 c6                	cmp    %eax,%esi
  800b6a:	73 35                	jae    800ba1 <memmove+0x47>
  800b6c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b6f:	39 d0                	cmp    %edx,%eax
  800b71:	73 2e                	jae    800ba1 <memmove+0x47>
		s += n;
		d += n;
  800b73:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	89 d6                	mov    %edx,%esi
  800b78:	09 fe                	or     %edi,%esi
  800b7a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b80:	75 13                	jne    800b95 <memmove+0x3b>
  800b82:	f6 c1 03             	test   $0x3,%cl
  800b85:	75 0e                	jne    800b95 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b87:	83 ef 04             	sub    $0x4,%edi
  800b8a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b8d:	c1 e9 02             	shr    $0x2,%ecx
  800b90:	fd                   	std    
  800b91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b93:	eb 09                	jmp    800b9e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b95:	83 ef 01             	sub    $0x1,%edi
  800b98:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9b:	fd                   	std    
  800b9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9e:	fc                   	cld    
  800b9f:	eb 1d                	jmp    800bbe <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba1:	89 f2                	mov    %esi,%edx
  800ba3:	09 c2                	or     %eax,%edx
  800ba5:	f6 c2 03             	test   $0x3,%dl
  800ba8:	75 0f                	jne    800bb9 <memmove+0x5f>
  800baa:	f6 c1 03             	test   $0x3,%cl
  800bad:	75 0a                	jne    800bb9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800baf:	c1 e9 02             	shr    $0x2,%ecx
  800bb2:	89 c7                	mov    %eax,%edi
  800bb4:	fc                   	cld    
  800bb5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb7:	eb 05                	jmp    800bbe <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	fc                   	cld    
  800bbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc5:	ff 75 10             	pushl  0x10(%ebp)
  800bc8:	ff 75 0c             	pushl  0xc(%ebp)
  800bcb:	ff 75 08             	pushl  0x8(%ebp)
  800bce:	e8 87 ff ff ff       	call   800b5a <memmove>
}
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be0:	89 c6                	mov    %eax,%esi
  800be2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be5:	eb 1a                	jmp    800c01 <memcmp+0x2c>
		if (*s1 != *s2)
  800be7:	0f b6 08             	movzbl (%eax),%ecx
  800bea:	0f b6 1a             	movzbl (%edx),%ebx
  800bed:	38 d9                	cmp    %bl,%cl
  800bef:	74 0a                	je     800bfb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf1:	0f b6 c1             	movzbl %cl,%eax
  800bf4:	0f b6 db             	movzbl %bl,%ebx
  800bf7:	29 d8                	sub    %ebx,%eax
  800bf9:	eb 0f                	jmp    800c0a <memcmp+0x35>
		s1++, s2++;
  800bfb:	83 c0 01             	add    $0x1,%eax
  800bfe:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c01:	39 f0                	cmp    %esi,%eax
  800c03:	75 e2                	jne    800be7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	53                   	push   %ebx
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c15:	89 c1                	mov    %eax,%ecx
  800c17:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1e:	eb 0a                	jmp    800c2a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c20:	0f b6 10             	movzbl (%eax),%edx
  800c23:	39 da                	cmp    %ebx,%edx
  800c25:	74 07                	je     800c2e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c27:	83 c0 01             	add    $0x1,%eax
  800c2a:	39 c8                	cmp    %ecx,%eax
  800c2c:	72 f2                	jb     800c20 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3d:	eb 03                	jmp    800c42 <strtol+0x11>
		s++;
  800c3f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c42:	0f b6 01             	movzbl (%ecx),%eax
  800c45:	3c 20                	cmp    $0x20,%al
  800c47:	74 f6                	je     800c3f <strtol+0xe>
  800c49:	3c 09                	cmp    $0x9,%al
  800c4b:	74 f2                	je     800c3f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4d:	3c 2b                	cmp    $0x2b,%al
  800c4f:	75 0a                	jne    800c5b <strtol+0x2a>
		s++;
  800c51:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c54:	bf 00 00 00 00       	mov    $0x0,%edi
  800c59:	eb 11                	jmp    800c6c <strtol+0x3b>
  800c5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c60:	3c 2d                	cmp    $0x2d,%al
  800c62:	75 08                	jne    800c6c <strtol+0x3b>
		s++, neg = 1;
  800c64:	83 c1 01             	add    $0x1,%ecx
  800c67:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c72:	75 15                	jne    800c89 <strtol+0x58>
  800c74:	80 39 30             	cmpb   $0x30,(%ecx)
  800c77:	75 10                	jne    800c89 <strtol+0x58>
  800c79:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c7d:	75 7c                	jne    800cfb <strtol+0xca>
		s += 2, base = 16;
  800c7f:	83 c1 02             	add    $0x2,%ecx
  800c82:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c87:	eb 16                	jmp    800c9f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c89:	85 db                	test   %ebx,%ebx
  800c8b:	75 12                	jne    800c9f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c92:	80 39 30             	cmpb   $0x30,(%ecx)
  800c95:	75 08                	jne    800c9f <strtol+0x6e>
		s++, base = 8;
  800c97:	83 c1 01             	add    $0x1,%ecx
  800c9a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca7:	0f b6 11             	movzbl (%ecx),%edx
  800caa:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cad:	89 f3                	mov    %esi,%ebx
  800caf:	80 fb 09             	cmp    $0x9,%bl
  800cb2:	77 08                	ja     800cbc <strtol+0x8b>
			dig = *s - '0';
  800cb4:	0f be d2             	movsbl %dl,%edx
  800cb7:	83 ea 30             	sub    $0x30,%edx
  800cba:	eb 22                	jmp    800cde <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cbc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cbf:	89 f3                	mov    %esi,%ebx
  800cc1:	80 fb 19             	cmp    $0x19,%bl
  800cc4:	77 08                	ja     800cce <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cc6:	0f be d2             	movsbl %dl,%edx
  800cc9:	83 ea 57             	sub    $0x57,%edx
  800ccc:	eb 10                	jmp    800cde <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cce:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd1:	89 f3                	mov    %esi,%ebx
  800cd3:	80 fb 19             	cmp    $0x19,%bl
  800cd6:	77 16                	ja     800cee <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cd8:	0f be d2             	movsbl %dl,%edx
  800cdb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cde:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce1:	7d 0b                	jge    800cee <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce3:	83 c1 01             	add    $0x1,%ecx
  800ce6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cea:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cec:	eb b9                	jmp    800ca7 <strtol+0x76>

	if (endptr)
  800cee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf2:	74 0d                	je     800d01 <strtol+0xd0>
		*endptr = (char *) s;
  800cf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf7:	89 0e                	mov    %ecx,(%esi)
  800cf9:	eb 06                	jmp    800d01 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfb:	85 db                	test   %ebx,%ebx
  800cfd:	74 98                	je     800c97 <strtol+0x66>
  800cff:	eb 9e                	jmp    800c9f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d01:	89 c2                	mov    %eax,%edx
  800d03:	f7 da                	neg    %edx
  800d05:	85 ff                	test   %edi,%edi
  800d07:	0f 45 c2             	cmovne %edx,%eax
}
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    
  800d0f:	90                   	nop

00800d10 <__udivdi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 f6                	test   %esi,%esi
  800d29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d2d:	89 ca                	mov    %ecx,%edx
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	75 3d                	jne    800d70 <__udivdi3+0x60>
  800d33:	39 cf                	cmp    %ecx,%edi
  800d35:	0f 87 c5 00 00 00    	ja     800e00 <__udivdi3+0xf0>
  800d3b:	85 ff                	test   %edi,%edi
  800d3d:	89 fd                	mov    %edi,%ebp
  800d3f:	75 0b                	jne    800d4c <__udivdi3+0x3c>
  800d41:	b8 01 00 00 00       	mov    $0x1,%eax
  800d46:	31 d2                	xor    %edx,%edx
  800d48:	f7 f7                	div    %edi
  800d4a:	89 c5                	mov    %eax,%ebp
  800d4c:	89 c8                	mov    %ecx,%eax
  800d4e:	31 d2                	xor    %edx,%edx
  800d50:	f7 f5                	div    %ebp
  800d52:	89 c1                	mov    %eax,%ecx
  800d54:	89 d8                	mov    %ebx,%eax
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	f7 f5                	div    %ebp
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	89 d8                	mov    %ebx,%eax
  800d5e:	89 fa                	mov    %edi,%edx
  800d60:	83 c4 1c             	add    $0x1c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
  800d68:	90                   	nop
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	39 ce                	cmp    %ecx,%esi
  800d72:	77 74                	ja     800de8 <__udivdi3+0xd8>
  800d74:	0f bd fe             	bsr    %esi,%edi
  800d77:	83 f7 1f             	xor    $0x1f,%edi
  800d7a:	0f 84 98 00 00 00    	je     800e18 <__udivdi3+0x108>
  800d80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	89 c5                	mov    %eax,%ebp
  800d89:	29 fb                	sub    %edi,%ebx
  800d8b:	d3 e6                	shl    %cl,%esi
  800d8d:	89 d9                	mov    %ebx,%ecx
  800d8f:	d3 ed                	shr    %cl,%ebp
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e0                	shl    %cl,%eax
  800d95:	09 ee                	or     %ebp,%esi
  800d97:	89 d9                	mov    %ebx,%ecx
  800d99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9d:	89 d5                	mov    %edx,%ebp
  800d9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800da3:	d3 ed                	shr    %cl,%ebp
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e2                	shl    %cl,%edx
  800da9:	89 d9                	mov    %ebx,%ecx
  800dab:	d3 e8                	shr    %cl,%eax
  800dad:	09 c2                	or     %eax,%edx
  800daf:	89 d0                	mov    %edx,%eax
  800db1:	89 ea                	mov    %ebp,%edx
  800db3:	f7 f6                	div    %esi
  800db5:	89 d5                	mov    %edx,%ebp
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	f7 64 24 0c          	mull   0xc(%esp)
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	72 10                	jb     800dd1 <__udivdi3+0xc1>
  800dc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e6                	shl    %cl,%esi
  800dc9:	39 c6                	cmp    %eax,%esi
  800dcb:	73 07                	jae    800dd4 <__udivdi3+0xc4>
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	75 03                	jne    800dd4 <__udivdi3+0xc4>
  800dd1:	83 eb 01             	sub    $0x1,%ebx
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	89 d8                	mov    %ebx,%eax
  800dd8:	89 fa                	mov    %edi,%edx
  800dda:	83 c4 1c             	add    $0x1c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
  800de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800de8:	31 ff                	xor    %edi,%edi
  800dea:	31 db                	xor    %ebx,%ebx
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	89 fa                	mov    %edi,%edx
  800df0:	83 c4 1c             	add    $0x1c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	90                   	nop
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	f7 f7                	div    %edi
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 1c             	add    $0x1c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	39 ce                	cmp    %ecx,%esi
  800e1a:	72 0c                	jb     800e28 <__udivdi3+0x118>
  800e1c:	31 db                	xor    %ebx,%ebx
  800e1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e22:	0f 87 34 ff ff ff    	ja     800d5c <__udivdi3+0x4c>
  800e28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e2d:	e9 2a ff ff ff       	jmp    800d5c <__udivdi3+0x4c>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 1c             	sub    $0x1c,%esp
  800e47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e57:	85 d2                	test   %edx,%edx
  800e59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f3                	mov    %esi,%ebx
  800e63:	89 3c 24             	mov    %edi,(%esp)
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	75 1c                	jne    800e88 <__umoddi3+0x48>
  800e6c:	39 f7                	cmp    %esi,%edi
  800e6e:	76 50                	jbe    800ec0 <__umoddi3+0x80>
  800e70:	89 c8                	mov    %ecx,%eax
  800e72:	89 f2                	mov    %esi,%edx
  800e74:	f7 f7                	div    %edi
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	89 d0                	mov    %edx,%eax
  800e8c:	77 52                	ja     800ee0 <__umoddi3+0xa0>
  800e8e:	0f bd ea             	bsr    %edx,%ebp
  800e91:	83 f5 1f             	xor    $0x1f,%ebp
  800e94:	75 5a                	jne    800ef0 <__umoddi3+0xb0>
  800e96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e9a:	0f 82 e0 00 00 00    	jb     800f80 <__umoddi3+0x140>
  800ea0:	39 0c 24             	cmp    %ecx,(%esp)
  800ea3:	0f 86 d7 00 00 00    	jbe    800f80 <__umoddi3+0x140>
  800ea9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ead:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	85 ff                	test   %edi,%edi
  800ec2:	89 fd                	mov    %edi,%ebp
  800ec4:	75 0b                	jne    800ed1 <__umoddi3+0x91>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f7                	div    %edi
  800ecf:	89 c5                	mov    %eax,%ebp
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f5                	div    %ebp
  800ed7:	89 c8                	mov    %ecx,%eax
  800ed9:	f7 f5                	div    %ebp
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	eb 99                	jmp    800e78 <__umoddi3+0x38>
  800edf:	90                   	nop
  800ee0:	89 c8                	mov    %ecx,%eax
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	8b 34 24             	mov    (%esp),%esi
  800ef3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef8:	89 e9                	mov    %ebp,%ecx
  800efa:	29 ef                	sub    %ebp,%edi
  800efc:	d3 e0                	shl    %cl,%eax
  800efe:	89 f9                	mov    %edi,%ecx
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	d3 ea                	shr    %cl,%edx
  800f04:	89 e9                	mov    %ebp,%ecx
  800f06:	09 c2                	or     %eax,%edx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 14 24             	mov    %edx,(%esp)
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	d3 e2                	shl    %cl,%edx
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	d3 e3                	shl    %cl,%ebx
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 d0                	mov    %edx,%eax
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	09 d8                	or     %ebx,%eax
  800f2d:	89 d3                	mov    %edx,%ebx
  800f2f:	89 f2                	mov    %esi,%edx
  800f31:	f7 34 24             	divl   (%esp)
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	d3 e3                	shl    %cl,%ebx
  800f38:	f7 64 24 04          	mull   0x4(%esp)
  800f3c:	39 d6                	cmp    %edx,%esi
  800f3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f42:	89 d1                	mov    %edx,%ecx
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	72 08                	jb     800f50 <__umoddi3+0x110>
  800f48:	75 11                	jne    800f5b <__umoddi3+0x11b>
  800f4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f4e:	73 0b                	jae    800f5b <__umoddi3+0x11b>
  800f50:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f54:	1b 14 24             	sbb    (%esp),%edx
  800f57:	89 d1                	mov    %edx,%ecx
  800f59:	89 c3                	mov    %eax,%ebx
  800f5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f5f:	29 da                	sub    %ebx,%edx
  800f61:	19 ce                	sbb    %ecx,%esi
  800f63:	89 f9                	mov    %edi,%ecx
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	d3 e0                	shl    %cl,%eax
  800f69:	89 e9                	mov    %ebp,%ecx
  800f6b:	d3 ea                	shr    %cl,%edx
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	d3 ee                	shr    %cl,%esi
  800f71:	09 d0                	or     %edx,%eax
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	83 c4 1c             	add    $0x1c,%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	29 f9                	sub    %edi,%ecx
  800f82:	19 d6                	sbb    %edx,%esi
  800f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f8c:	e9 18 ff ff ff       	jmp    800ea9 <__umoddi3+0x69>
