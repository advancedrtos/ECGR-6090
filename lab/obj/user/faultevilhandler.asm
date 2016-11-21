
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
  800122:	68 ca 0f 80 00       	push   $0x800fca
  800127:	6a 23                	push   $0x23
  800129:	68 e7 0f 80 00       	push   $0x800fe7
  80012e:	e8 56 02 00 00       	call   800389 <_panic>

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
  8001a3:	68 ca 0f 80 00       	push   $0x800fca
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 e7 0f 80 00       	push   $0x800fe7
  8001af:	e8 d5 01 00 00       	call   800389 <_panic>

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
  8001e5:	68 ca 0f 80 00       	push   $0x800fca
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 e7 0f 80 00       	push   $0x800fe7
  8001f1:	e8 93 01 00 00       	call   800389 <_panic>

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
  800227:	68 ca 0f 80 00       	push   $0x800fca
  80022c:	6a 23                	push   $0x23
  80022e:	68 e7 0f 80 00       	push   $0x800fe7
  800233:	e8 51 01 00 00       	call   800389 <_panic>

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
  800269:	68 ca 0f 80 00       	push   $0x800fca
  80026e:	6a 23                	push   $0x23
  800270:	68 e7 0f 80 00       	push   $0x800fe7
  800275:	e8 0f 01 00 00       	call   800389 <_panic>

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
  8002ab:	68 ca 0f 80 00       	push   $0x800fca
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 e7 0f 80 00       	push   $0x800fe7
  8002b7:	e8 cd 00 00 00       	call   800389 <_panic>

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
  8002ed:	68 ca 0f 80 00       	push   $0x800fca
  8002f2:	6a 23                	push   $0x23
  8002f4:	68 e7 0f 80 00       	push   $0x800fe7
  8002f9:	e8 8b 00 00 00       	call   800389 <_panic>

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
  800351:	68 ca 0f 80 00       	push   $0x800fca
  800356:	6a 23                	push   $0x23
  800358:	68 e7 0f 80 00       	push   $0x800fe7
  80035d:	e8 27 00 00 00       	call   800389 <_panic>

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

0080036a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	b8 0e 00 00 00       	mov    $0xe,%eax
  80037a:	89 d1                	mov    %edx,%ecx
  80037c:	89 d3                	mov    %edx,%ebx
  80037e:	89 d7                	mov    %edx,%edi
  800380:	89 d6                	mov    %edx,%esi
  800382:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800384:	5b                   	pop    %ebx
  800385:	5e                   	pop    %esi
  800386:	5f                   	pop    %edi
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	56                   	push   %esi
  80038d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80038e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800391:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800397:	e8 9f fd ff ff       	call   80013b <sys_getenvid>
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 75 0c             	pushl  0xc(%ebp)
  8003a2:	ff 75 08             	pushl  0x8(%ebp)
  8003a5:	56                   	push   %esi
  8003a6:	50                   	push   %eax
  8003a7:	68 f8 0f 80 00       	push   $0x800ff8
  8003ac:	e8 b1 00 00 00       	call   800462 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b1:	83 c4 18             	add    $0x18,%esp
  8003b4:	53                   	push   %ebx
  8003b5:	ff 75 10             	pushl  0x10(%ebp)
  8003b8:	e8 54 00 00 00       	call   800411 <vcprintf>
	cprintf("\n");
  8003bd:	c7 04 24 1b 10 80 00 	movl   $0x80101b,(%esp)
  8003c4:	e8 99 00 00 00       	call   800462 <cprintf>
  8003c9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003cc:	cc                   	int3   
  8003cd:	eb fd                	jmp    8003cc <_panic+0x43>

008003cf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	53                   	push   %ebx
  8003d3:	83 ec 04             	sub    $0x4,%esp
  8003d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d9:	8b 13                	mov    (%ebx),%edx
  8003db:	8d 42 01             	lea    0x1(%edx),%eax
  8003de:	89 03                	mov    %eax,(%ebx)
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003e7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ec:	75 1a                	jne    800408 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	68 ff 00 00 00       	push   $0xff
  8003f6:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f9:	50                   	push   %eax
  8003fa:	e8 be fc ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  8003ff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800405:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800408:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80040c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80041a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800421:	00 00 00 
	b.cnt = 0;
  800424:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80042b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042e:	ff 75 0c             	pushl  0xc(%ebp)
  800431:	ff 75 08             	pushl  0x8(%ebp)
  800434:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80043a:	50                   	push   %eax
  80043b:	68 cf 03 80 00       	push   $0x8003cf
  800440:	e8 54 01 00 00       	call   800599 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800445:	83 c4 08             	add    $0x8,%esp
  800448:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80044e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800454:	50                   	push   %eax
  800455:	e8 63 fc ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  80045a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800460:	c9                   	leave  
  800461:	c3                   	ret    

00800462 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800468:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80046b:	50                   	push   %eax
  80046c:	ff 75 08             	pushl  0x8(%ebp)
  80046f:	e8 9d ff ff ff       	call   800411 <vcprintf>
	va_end(ap);

	return cnt;
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	57                   	push   %edi
  80047a:	56                   	push   %esi
  80047b:	53                   	push   %ebx
  80047c:	83 ec 1c             	sub    $0x1c,%esp
  80047f:	89 c7                	mov    %eax,%edi
  800481:	89 d6                	mov    %edx,%esi
  800483:	8b 45 08             	mov    0x8(%ebp),%eax
  800486:	8b 55 0c             	mov    0xc(%ebp),%edx
  800489:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80048c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80048f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800492:	bb 00 00 00 00       	mov    $0x0,%ebx
  800497:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80049a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80049d:	39 d3                	cmp    %edx,%ebx
  80049f:	72 05                	jb     8004a6 <printnum+0x30>
  8004a1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004a4:	77 45                	ja     8004eb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004a6:	83 ec 0c             	sub    $0xc,%esp
  8004a9:	ff 75 18             	pushl  0x18(%ebp)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8004b2:	53                   	push   %ebx
  8004b3:	ff 75 10             	pushl  0x10(%ebp)
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c5:	e8 66 08 00 00       	call   800d30 <__udivdi3>
  8004ca:	83 c4 18             	add    $0x18,%esp
  8004cd:	52                   	push   %edx
  8004ce:	50                   	push   %eax
  8004cf:	89 f2                	mov    %esi,%edx
  8004d1:	89 f8                	mov    %edi,%eax
  8004d3:	e8 9e ff ff ff       	call   800476 <printnum>
  8004d8:	83 c4 20             	add    $0x20,%esp
  8004db:	eb 18                	jmp    8004f5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	ff 75 18             	pushl  0x18(%ebp)
  8004e4:	ff d7                	call   *%edi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	eb 03                	jmp    8004ee <printnum+0x78>
  8004eb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004ee:	83 eb 01             	sub    $0x1,%ebx
  8004f1:	85 db                	test   %ebx,%ebx
  8004f3:	7f e8                	jg     8004dd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	56                   	push   %esi
  8004f9:	83 ec 04             	sub    $0x4,%esp
  8004fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800502:	ff 75 dc             	pushl  -0x24(%ebp)
  800505:	ff 75 d8             	pushl  -0x28(%ebp)
  800508:	e8 53 09 00 00       	call   800e60 <__umoddi3>
  80050d:	83 c4 14             	add    $0x14,%esp
  800510:	0f be 80 1d 10 80 00 	movsbl 0x80101d(%eax),%eax
  800517:	50                   	push   %eax
  800518:	ff d7                	call   *%edi
}
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800520:	5b                   	pop    %ebx
  800521:	5e                   	pop    %esi
  800522:	5f                   	pop    %edi
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800528:	83 fa 01             	cmp    $0x1,%edx
  80052b:	7e 0e                	jle    80053b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80052d:	8b 10                	mov    (%eax),%edx
  80052f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800532:	89 08                	mov    %ecx,(%eax)
  800534:	8b 02                	mov    (%edx),%eax
  800536:	8b 52 04             	mov    0x4(%edx),%edx
  800539:	eb 22                	jmp    80055d <getuint+0x38>
	else if (lflag)
  80053b:	85 d2                	test   %edx,%edx
  80053d:	74 10                	je     80054f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80053f:	8b 10                	mov    (%eax),%edx
  800541:	8d 4a 04             	lea    0x4(%edx),%ecx
  800544:	89 08                	mov    %ecx,(%eax)
  800546:	8b 02                	mov    (%edx),%eax
  800548:	ba 00 00 00 00       	mov    $0x0,%edx
  80054d:	eb 0e                	jmp    80055d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80054f:	8b 10                	mov    (%eax),%edx
  800551:	8d 4a 04             	lea    0x4(%edx),%ecx
  800554:	89 08                	mov    %ecx,(%eax)
  800556:	8b 02                	mov    (%edx),%eax
  800558:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80055d:	5d                   	pop    %ebp
  80055e:	c3                   	ret    

0080055f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800565:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800569:	8b 10                	mov    (%eax),%edx
  80056b:	3b 50 04             	cmp    0x4(%eax),%edx
  80056e:	73 0a                	jae    80057a <sprintputch+0x1b>
		*b->buf++ = ch;
  800570:	8d 4a 01             	lea    0x1(%edx),%ecx
  800573:	89 08                	mov    %ecx,(%eax)
  800575:	8b 45 08             	mov    0x8(%ebp),%eax
  800578:	88 02                	mov    %al,(%edx)
}
  80057a:	5d                   	pop    %ebp
  80057b:	c3                   	ret    

0080057c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800582:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800585:	50                   	push   %eax
  800586:	ff 75 10             	pushl  0x10(%ebp)
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	e8 05 00 00 00       	call   800599 <vprintfmt>
	va_end(ap);
}
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	c9                   	leave  
  800598:	c3                   	ret    

00800599 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800599:	55                   	push   %ebp
  80059a:	89 e5                	mov    %esp,%ebp
  80059c:	57                   	push   %edi
  80059d:	56                   	push   %esi
  80059e:	53                   	push   %ebx
  80059f:	83 ec 2c             	sub    $0x2c,%esp
  8005a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005ab:	eb 12                	jmp    8005bf <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	0f 84 89 03 00 00    	je     80093e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	50                   	push   %eax
  8005ba:	ff d6                	call   *%esi
  8005bc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005bf:	83 c7 01             	add    $0x1,%edi
  8005c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c6:	83 f8 25             	cmp    $0x25,%eax
  8005c9:	75 e2                	jne    8005ad <vprintfmt+0x14>
  8005cb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005cf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005dd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e9:	eb 07                	jmp    8005f2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005ee:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8d 47 01             	lea    0x1(%edi),%eax
  8005f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f8:	0f b6 07             	movzbl (%edi),%eax
  8005fb:	0f b6 c8             	movzbl %al,%ecx
  8005fe:	83 e8 23             	sub    $0x23,%eax
  800601:	3c 55                	cmp    $0x55,%al
  800603:	0f 87 1a 03 00 00    	ja     800923 <vprintfmt+0x38a>
  800609:	0f b6 c0             	movzbl %al,%eax
  80060c:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800616:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80061a:	eb d6                	jmp    8005f2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061f:	b8 00 00 00 00       	mov    $0x0,%eax
  800624:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800627:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80062a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80062e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800631:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800634:	83 fa 09             	cmp    $0x9,%edx
  800637:	77 39                	ja     800672 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800639:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80063c:	eb e9                	jmp    800627 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 48 04             	lea    0x4(%eax),%ecx
  800644:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80064f:	eb 27                	jmp    800678 <vprintfmt+0xdf>
  800651:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800654:	85 c0                	test   %eax,%eax
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	0f 49 c8             	cmovns %eax,%ecx
  80065e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800664:	eb 8c                	jmp    8005f2 <vprintfmt+0x59>
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800669:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800670:	eb 80                	jmp    8005f2 <vprintfmt+0x59>
  800672:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800675:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800678:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067c:	0f 89 70 ff ff ff    	jns    8005f2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800682:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800685:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800688:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80068f:	e9 5e ff ff ff       	jmp    8005f2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800694:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80069a:	e9 53 ff ff ff       	jmp    8005f2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 50 04             	lea    0x4(%eax),%edx
  8006a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	ff 30                	pushl  (%eax)
  8006ae:	ff d6                	call   *%esi
			break;
  8006b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006b6:	e9 04 ff ff ff       	jmp    8005bf <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	99                   	cltd   
  8006c7:	31 d0                	xor    %edx,%eax
  8006c9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006cb:	83 f8 0f             	cmp    $0xf,%eax
  8006ce:	7f 0b                	jg     8006db <vprintfmt+0x142>
  8006d0:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	75 18                	jne    8006f3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006db:	50                   	push   %eax
  8006dc:	68 35 10 80 00       	push   $0x801035
  8006e1:	53                   	push   %ebx
  8006e2:	56                   	push   %esi
  8006e3:	e8 94 fe ff ff       	call   80057c <printfmt>
  8006e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006ee:	e9 cc fe ff ff       	jmp    8005bf <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006f3:	52                   	push   %edx
  8006f4:	68 3e 10 80 00       	push   $0x80103e
  8006f9:	53                   	push   %ebx
  8006fa:	56                   	push   %esi
  8006fb:	e8 7c fe ff ff       	call   80057c <printfmt>
  800700:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800703:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800706:	e9 b4 fe ff ff       	jmp    8005bf <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	8d 50 04             	lea    0x4(%eax),%edx
  800711:	89 55 14             	mov    %edx,0x14(%ebp)
  800714:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800716:	85 ff                	test   %edi,%edi
  800718:	b8 2e 10 80 00       	mov    $0x80102e,%eax
  80071d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800720:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800724:	0f 8e 94 00 00 00    	jle    8007be <vprintfmt+0x225>
  80072a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80072e:	0f 84 98 00 00 00    	je     8007cc <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	ff 75 d0             	pushl  -0x30(%ebp)
  80073a:	57                   	push   %edi
  80073b:	e8 86 02 00 00       	call   8009c6 <strnlen>
  800740:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800743:	29 c1                	sub    %eax,%ecx
  800745:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800748:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80074b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80074f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800752:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800755:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800757:	eb 0f                	jmp    800768 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	ff 75 e0             	pushl  -0x20(%ebp)
  800760:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800762:	83 ef 01             	sub    $0x1,%edi
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	85 ff                	test   %edi,%edi
  80076a:	7f ed                	jg     800759 <vprintfmt+0x1c0>
  80076c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80076f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800772:	85 c9                	test   %ecx,%ecx
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	0f 49 c1             	cmovns %ecx,%eax
  80077c:	29 c1                	sub    %eax,%ecx
  80077e:	89 75 08             	mov    %esi,0x8(%ebp)
  800781:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800784:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800787:	89 cb                	mov    %ecx,%ebx
  800789:	eb 4d                	jmp    8007d8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80078b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80078f:	74 1b                	je     8007ac <vprintfmt+0x213>
  800791:	0f be c0             	movsbl %al,%eax
  800794:	83 e8 20             	sub    $0x20,%eax
  800797:	83 f8 5e             	cmp    $0x5e,%eax
  80079a:	76 10                	jbe    8007ac <vprintfmt+0x213>
					putch('?', putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	6a 3f                	push   $0x3f
  8007a4:	ff 55 08             	call   *0x8(%ebp)
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb 0d                	jmp    8007b9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	52                   	push   %edx
  8007b3:	ff 55 08             	call   *0x8(%ebp)
  8007b6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007b9:	83 eb 01             	sub    $0x1,%ebx
  8007bc:	eb 1a                	jmp    8007d8 <vprintfmt+0x23f>
  8007be:	89 75 08             	mov    %esi,0x8(%ebp)
  8007c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007c7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007ca:	eb 0c                	jmp    8007d8 <vprintfmt+0x23f>
  8007cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8007cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007d5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007d8:	83 c7 01             	add    $0x1,%edi
  8007db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007df:	0f be d0             	movsbl %al,%edx
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	74 23                	je     800809 <vprintfmt+0x270>
  8007e6:	85 f6                	test   %esi,%esi
  8007e8:	78 a1                	js     80078b <vprintfmt+0x1f2>
  8007ea:	83 ee 01             	sub    $0x1,%esi
  8007ed:	79 9c                	jns    80078b <vprintfmt+0x1f2>
  8007ef:	89 df                	mov    %ebx,%edi
  8007f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f7:	eb 18                	jmp    800811 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	53                   	push   %ebx
  8007fd:	6a 20                	push   $0x20
  8007ff:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800801:	83 ef 01             	sub    $0x1,%edi
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	eb 08                	jmp    800811 <vprintfmt+0x278>
  800809:	89 df                	mov    %ebx,%edi
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800811:	85 ff                	test   %edi,%edi
  800813:	7f e4                	jg     8007f9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800815:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800818:	e9 a2 fd ff ff       	jmp    8005bf <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081d:	83 fa 01             	cmp    $0x1,%edx
  800820:	7e 16                	jle    800838 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8d 50 08             	lea    0x8(%eax),%edx
  800828:	89 55 14             	mov    %edx,0x14(%ebp)
  80082b:	8b 50 04             	mov    0x4(%eax),%edx
  80082e:	8b 00                	mov    (%eax),%eax
  800830:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800833:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800836:	eb 32                	jmp    80086a <vprintfmt+0x2d1>
	else if (lflag)
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 18                	je     800854 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 04             	lea    0x4(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 00                	mov    (%eax),%eax
  800847:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084a:	89 c1                	mov    %eax,%ecx
  80084c:	c1 f9 1f             	sar    $0x1f,%ecx
  80084f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800852:	eb 16                	jmp    80086a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	8b 00                	mov    (%eax),%eax
  80085f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800862:	89 c1                	mov    %eax,%ecx
  800864:	c1 f9 1f             	sar    $0x1f,%ecx
  800867:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80086a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80086d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800870:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800875:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800879:	79 74                	jns    8008ef <vprintfmt+0x356>
				putch('-', putdat);
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	53                   	push   %ebx
  80087f:	6a 2d                	push   $0x2d
  800881:	ff d6                	call   *%esi
				num = -(long long) num;
  800883:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800886:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800889:	f7 d8                	neg    %eax
  80088b:	83 d2 00             	adc    $0x0,%edx
  80088e:	f7 da                	neg    %edx
  800890:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800893:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800898:	eb 55                	jmp    8008ef <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80089a:	8d 45 14             	lea    0x14(%ebp),%eax
  80089d:	e8 83 fc ff ff       	call   800525 <getuint>
			base = 10;
  8008a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8008a7:	eb 46                	jmp    8008ef <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ac:	e8 74 fc ff ff       	call   800525 <getuint>
			base = 8;
  8008b1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8008b6:	eb 37                	jmp    8008ef <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	53                   	push   %ebx
  8008bc:	6a 30                	push   $0x30
  8008be:	ff d6                	call   *%esi
			putch('x', putdat);
  8008c0:	83 c4 08             	add    $0x8,%esp
  8008c3:	53                   	push   %ebx
  8008c4:	6a 78                	push   $0x78
  8008c6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ce:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008d1:	8b 00                	mov    (%eax),%eax
  8008d3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008d8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008db:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008e0:	eb 0d                	jmp    8008ef <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e5:	e8 3b fc ff ff       	call   800525 <getuint>
			base = 16;
  8008ea:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ef:	83 ec 0c             	sub    $0xc,%esp
  8008f2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008f6:	57                   	push   %edi
  8008f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8008fa:	51                   	push   %ecx
  8008fb:	52                   	push   %edx
  8008fc:	50                   	push   %eax
  8008fd:	89 da                	mov    %ebx,%edx
  8008ff:	89 f0                	mov    %esi,%eax
  800901:	e8 70 fb ff ff       	call   800476 <printnum>
			break;
  800906:	83 c4 20             	add    $0x20,%esp
  800909:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80090c:	e9 ae fc ff ff       	jmp    8005bf <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	53                   	push   %ebx
  800915:	51                   	push   %ecx
  800916:	ff d6                	call   *%esi
			break;
  800918:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80091e:	e9 9c fc ff ff       	jmp    8005bf <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800923:	83 ec 08             	sub    $0x8,%esp
  800926:	53                   	push   %ebx
  800927:	6a 25                	push   $0x25
  800929:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	eb 03                	jmp    800933 <vprintfmt+0x39a>
  800930:	83 ef 01             	sub    $0x1,%edi
  800933:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800937:	75 f7                	jne    800930 <vprintfmt+0x397>
  800939:	e9 81 fc ff ff       	jmp    8005bf <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80093e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5f                   	pop    %edi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 18             	sub    $0x18,%esp
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800952:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800955:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800959:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80095c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800963:	85 c0                	test   %eax,%eax
  800965:	74 26                	je     80098d <vsnprintf+0x47>
  800967:	85 d2                	test   %edx,%edx
  800969:	7e 22                	jle    80098d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80096b:	ff 75 14             	pushl  0x14(%ebp)
  80096e:	ff 75 10             	pushl  0x10(%ebp)
  800971:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800974:	50                   	push   %eax
  800975:	68 5f 05 80 00       	push   $0x80055f
  80097a:	e8 1a fc ff ff       	call   800599 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80097f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800982:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800985:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800988:	83 c4 10             	add    $0x10,%esp
  80098b:	eb 05                	jmp    800992 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80098d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80099a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80099d:	50                   	push   %eax
  80099e:	ff 75 10             	pushl  0x10(%ebp)
  8009a1:	ff 75 0c             	pushl  0xc(%ebp)
  8009a4:	ff 75 08             	pushl  0x8(%ebp)
  8009a7:	e8 9a ff ff ff       	call   800946 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b9:	eb 03                	jmp    8009be <strlen+0x10>
		n++;
  8009bb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c2:	75 f7                	jne    8009bb <strlen+0xd>
		n++;
	return n;
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d4:	eb 03                	jmp    8009d9 <strnlen+0x13>
		n++;
  8009d6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d9:	39 c2                	cmp    %eax,%edx
  8009db:	74 08                	je     8009e5 <strnlen+0x1f>
  8009dd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009e1:	75 f3                	jne    8009d6 <strnlen+0x10>
  8009e3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	53                   	push   %ebx
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f1:	89 c2                	mov    %eax,%edx
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	83 c1 01             	add    $0x1,%ecx
  8009f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a00:	84 db                	test   %bl,%bl
  800a02:	75 ef                	jne    8009f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a04:	5b                   	pop    %ebx
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	53                   	push   %ebx
  800a0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a0e:	53                   	push   %ebx
  800a0f:	e8 9a ff ff ff       	call   8009ae <strlen>
  800a14:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	01 d8                	add    %ebx,%eax
  800a1c:	50                   	push   %eax
  800a1d:	e8 c5 ff ff ff       	call   8009e7 <strcpy>
	return dst;
}
  800a22:	89 d8                	mov    %ebx,%eax
  800a24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a27:	c9                   	leave  
  800a28:	c3                   	ret    

00800a29 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a34:	89 f3                	mov    %esi,%ebx
  800a36:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a39:	89 f2                	mov    %esi,%edx
  800a3b:	eb 0f                	jmp    800a4c <strncpy+0x23>
		*dst++ = *src;
  800a3d:	83 c2 01             	add    $0x1,%edx
  800a40:	0f b6 01             	movzbl (%ecx),%eax
  800a43:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a46:	80 39 01             	cmpb   $0x1,(%ecx)
  800a49:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a4c:	39 da                	cmp    %ebx,%edx
  800a4e:	75 ed                	jne    800a3d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a50:	89 f0                	mov    %esi,%eax
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a61:	8b 55 10             	mov    0x10(%ebp),%edx
  800a64:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a66:	85 d2                	test   %edx,%edx
  800a68:	74 21                	je     800a8b <strlcpy+0x35>
  800a6a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a6e:	89 f2                	mov    %esi,%edx
  800a70:	eb 09                	jmp    800a7b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a72:	83 c2 01             	add    $0x1,%edx
  800a75:	83 c1 01             	add    $0x1,%ecx
  800a78:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a7b:	39 c2                	cmp    %eax,%edx
  800a7d:	74 09                	je     800a88 <strlcpy+0x32>
  800a7f:	0f b6 19             	movzbl (%ecx),%ebx
  800a82:	84 db                	test   %bl,%bl
  800a84:	75 ec                	jne    800a72 <strlcpy+0x1c>
  800a86:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a88:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a8b:	29 f0                	sub    %esi,%eax
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a97:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a9a:	eb 06                	jmp    800aa2 <strcmp+0x11>
		p++, q++;
  800a9c:	83 c1 01             	add    $0x1,%ecx
  800a9f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aa2:	0f b6 01             	movzbl (%ecx),%eax
  800aa5:	84 c0                	test   %al,%al
  800aa7:	74 04                	je     800aad <strcmp+0x1c>
  800aa9:	3a 02                	cmp    (%edx),%al
  800aab:	74 ef                	je     800a9c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aad:	0f b6 c0             	movzbl %al,%eax
  800ab0:	0f b6 12             	movzbl (%edx),%edx
  800ab3:	29 d0                	sub    %edx,%eax
}
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac1:	89 c3                	mov    %eax,%ebx
  800ac3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac6:	eb 06                	jmp    800ace <strncmp+0x17>
		n--, p++, q++;
  800ac8:	83 c0 01             	add    $0x1,%eax
  800acb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ace:	39 d8                	cmp    %ebx,%eax
  800ad0:	74 15                	je     800ae7 <strncmp+0x30>
  800ad2:	0f b6 08             	movzbl (%eax),%ecx
  800ad5:	84 c9                	test   %cl,%cl
  800ad7:	74 04                	je     800add <strncmp+0x26>
  800ad9:	3a 0a                	cmp    (%edx),%cl
  800adb:	74 eb                	je     800ac8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800add:	0f b6 00             	movzbl (%eax),%eax
  800ae0:	0f b6 12             	movzbl (%edx),%edx
  800ae3:	29 d0                	sub    %edx,%eax
  800ae5:	eb 05                	jmp    800aec <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aec:	5b                   	pop    %ebx
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af9:	eb 07                	jmp    800b02 <strchr+0x13>
		if (*s == c)
  800afb:	38 ca                	cmp    %cl,%dl
  800afd:	74 0f                	je     800b0e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	0f b6 10             	movzbl (%eax),%edx
  800b05:	84 d2                	test   %dl,%dl
  800b07:	75 f2                	jne    800afb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b1a:	eb 03                	jmp    800b1f <strfind+0xf>
  800b1c:	83 c0 01             	add    $0x1,%eax
  800b1f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b22:	38 ca                	cmp    %cl,%dl
  800b24:	74 04                	je     800b2a <strfind+0x1a>
  800b26:	84 d2                	test   %dl,%dl
  800b28:	75 f2                	jne    800b1c <strfind+0xc>
			break;
	return (char *) s;
}
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b38:	85 c9                	test   %ecx,%ecx
  800b3a:	74 36                	je     800b72 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b42:	75 28                	jne    800b6c <memset+0x40>
  800b44:	f6 c1 03             	test   $0x3,%cl
  800b47:	75 23                	jne    800b6c <memset+0x40>
		c &= 0xFF;
  800b49:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	c1 e3 08             	shl    $0x8,%ebx
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	c1 e6 18             	shl    $0x18,%esi
  800b57:	89 d0                	mov    %edx,%eax
  800b59:	c1 e0 10             	shl    $0x10,%eax
  800b5c:	09 f0                	or     %esi,%eax
  800b5e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b60:	89 d8                	mov    %ebx,%eax
  800b62:	09 d0                	or     %edx,%eax
  800b64:	c1 e9 02             	shr    $0x2,%ecx
  800b67:	fc                   	cld    
  800b68:	f3 ab                	rep stos %eax,%es:(%edi)
  800b6a:	eb 06                	jmp    800b72 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6f:	fc                   	cld    
  800b70:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b72:	89 f8                	mov    %edi,%eax
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b84:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b87:	39 c6                	cmp    %eax,%esi
  800b89:	73 35                	jae    800bc0 <memmove+0x47>
  800b8b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b8e:	39 d0                	cmp    %edx,%eax
  800b90:	73 2e                	jae    800bc0 <memmove+0x47>
		s += n;
		d += n;
  800b92:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	09 fe                	or     %edi,%esi
  800b99:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9f:	75 13                	jne    800bb4 <memmove+0x3b>
  800ba1:	f6 c1 03             	test   $0x3,%cl
  800ba4:	75 0e                	jne    800bb4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ba6:	83 ef 04             	sub    $0x4,%edi
  800ba9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bac:	c1 e9 02             	shr    $0x2,%ecx
  800baf:	fd                   	std    
  800bb0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb2:	eb 09                	jmp    800bbd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb4:	83 ef 01             	sub    $0x1,%edi
  800bb7:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bba:	fd                   	std    
  800bbb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bbd:	fc                   	cld    
  800bbe:	eb 1d                	jmp    800bdd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc0:	89 f2                	mov    %esi,%edx
  800bc2:	09 c2                	or     %eax,%edx
  800bc4:	f6 c2 03             	test   $0x3,%dl
  800bc7:	75 0f                	jne    800bd8 <memmove+0x5f>
  800bc9:	f6 c1 03             	test   $0x3,%cl
  800bcc:	75 0a                	jne    800bd8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bce:	c1 e9 02             	shr    $0x2,%ecx
  800bd1:	89 c7                	mov    %eax,%edi
  800bd3:	fc                   	cld    
  800bd4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd6:	eb 05                	jmp    800bdd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd8:	89 c7                	mov    %eax,%edi
  800bda:	fc                   	cld    
  800bdb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800be4:	ff 75 10             	pushl  0x10(%ebp)
  800be7:	ff 75 0c             	pushl  0xc(%ebp)
  800bea:	ff 75 08             	pushl  0x8(%ebp)
  800bed:	e8 87 ff ff ff       	call   800b79 <memmove>
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bff:	89 c6                	mov    %eax,%esi
  800c01:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c04:	eb 1a                	jmp    800c20 <memcmp+0x2c>
		if (*s1 != *s2)
  800c06:	0f b6 08             	movzbl (%eax),%ecx
  800c09:	0f b6 1a             	movzbl (%edx),%ebx
  800c0c:	38 d9                	cmp    %bl,%cl
  800c0e:	74 0a                	je     800c1a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c10:	0f b6 c1             	movzbl %cl,%eax
  800c13:	0f b6 db             	movzbl %bl,%ebx
  800c16:	29 d8                	sub    %ebx,%eax
  800c18:	eb 0f                	jmp    800c29 <memcmp+0x35>
		s1++, s2++;
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c20:	39 f0                	cmp    %esi,%eax
  800c22:	75 e2                	jne    800c06 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	53                   	push   %ebx
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c34:	89 c1                	mov    %eax,%ecx
  800c36:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c39:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c3d:	eb 0a                	jmp    800c49 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3f:	0f b6 10             	movzbl (%eax),%edx
  800c42:	39 da                	cmp    %ebx,%edx
  800c44:	74 07                	je     800c4d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c46:	83 c0 01             	add    $0x1,%eax
  800c49:	39 c8                	cmp    %ecx,%eax
  800c4b:	72 f2                	jb     800c3f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c4d:	5b                   	pop    %ebx
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5c:	eb 03                	jmp    800c61 <strtol+0x11>
		s++;
  800c5e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c61:	0f b6 01             	movzbl (%ecx),%eax
  800c64:	3c 20                	cmp    $0x20,%al
  800c66:	74 f6                	je     800c5e <strtol+0xe>
  800c68:	3c 09                	cmp    $0x9,%al
  800c6a:	74 f2                	je     800c5e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c6c:	3c 2b                	cmp    $0x2b,%al
  800c6e:	75 0a                	jne    800c7a <strtol+0x2a>
		s++;
  800c70:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c73:	bf 00 00 00 00       	mov    $0x0,%edi
  800c78:	eb 11                	jmp    800c8b <strtol+0x3b>
  800c7a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c7f:	3c 2d                	cmp    $0x2d,%al
  800c81:	75 08                	jne    800c8b <strtol+0x3b>
		s++, neg = 1;
  800c83:	83 c1 01             	add    $0x1,%ecx
  800c86:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c91:	75 15                	jne    800ca8 <strtol+0x58>
  800c93:	80 39 30             	cmpb   $0x30,(%ecx)
  800c96:	75 10                	jne    800ca8 <strtol+0x58>
  800c98:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c9c:	75 7c                	jne    800d1a <strtol+0xca>
		s += 2, base = 16;
  800c9e:	83 c1 02             	add    $0x2,%ecx
  800ca1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca6:	eb 16                	jmp    800cbe <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	75 12                	jne    800cbe <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cac:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb1:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb4:	75 08                	jne    800cbe <strtol+0x6e>
		s++, base = 8;
  800cb6:	83 c1 01             	add    $0x1,%ecx
  800cb9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc6:	0f b6 11             	movzbl (%ecx),%edx
  800cc9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ccc:	89 f3                	mov    %esi,%ebx
  800cce:	80 fb 09             	cmp    $0x9,%bl
  800cd1:	77 08                	ja     800cdb <strtol+0x8b>
			dig = *s - '0';
  800cd3:	0f be d2             	movsbl %dl,%edx
  800cd6:	83 ea 30             	sub    $0x30,%edx
  800cd9:	eb 22                	jmp    800cfd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cdb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cde:	89 f3                	mov    %esi,%ebx
  800ce0:	80 fb 19             	cmp    $0x19,%bl
  800ce3:	77 08                	ja     800ced <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ce5:	0f be d2             	movsbl %dl,%edx
  800ce8:	83 ea 57             	sub    $0x57,%edx
  800ceb:	eb 10                	jmp    800cfd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ced:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cf0:	89 f3                	mov    %esi,%ebx
  800cf2:	80 fb 19             	cmp    $0x19,%bl
  800cf5:	77 16                	ja     800d0d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cf7:	0f be d2             	movsbl %dl,%edx
  800cfa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cfd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d00:	7d 0b                	jge    800d0d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d02:	83 c1 01             	add    $0x1,%ecx
  800d05:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d09:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d0b:	eb b9                	jmp    800cc6 <strtol+0x76>

	if (endptr)
  800d0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d11:	74 0d                	je     800d20 <strtol+0xd0>
		*endptr = (char *) s;
  800d13:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d16:	89 0e                	mov    %ecx,(%esi)
  800d18:	eb 06                	jmp    800d20 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d1a:	85 db                	test   %ebx,%ebx
  800d1c:	74 98                	je     800cb6 <strtol+0x66>
  800d1e:	eb 9e                	jmp    800cbe <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d20:	89 c2                	mov    %eax,%edx
  800d22:	f7 da                	neg    %edx
  800d24:	85 ff                	test   %edi,%edi
  800d26:	0f 45 c2             	cmovne %edx,%eax
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__udivdi3>:
  800d30:	55                   	push   %ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 1c             	sub    $0x1c,%esp
  800d37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d47:	85 f6                	test   %esi,%esi
  800d49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d4d:	89 ca                	mov    %ecx,%edx
  800d4f:	89 f8                	mov    %edi,%eax
  800d51:	75 3d                	jne    800d90 <__udivdi3+0x60>
  800d53:	39 cf                	cmp    %ecx,%edi
  800d55:	0f 87 c5 00 00 00    	ja     800e20 <__udivdi3+0xf0>
  800d5b:	85 ff                	test   %edi,%edi
  800d5d:	89 fd                	mov    %edi,%ebp
  800d5f:	75 0b                	jne    800d6c <__udivdi3+0x3c>
  800d61:	b8 01 00 00 00       	mov    $0x1,%eax
  800d66:	31 d2                	xor    %edx,%edx
  800d68:	f7 f7                	div    %edi
  800d6a:	89 c5                	mov    %eax,%ebp
  800d6c:	89 c8                	mov    %ecx,%eax
  800d6e:	31 d2                	xor    %edx,%edx
  800d70:	f7 f5                	div    %ebp
  800d72:	89 c1                	mov    %eax,%ecx
  800d74:	89 d8                	mov    %ebx,%eax
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	f7 f5                	div    %ebp
  800d7a:	89 c3                	mov    %eax,%ebx
  800d7c:	89 d8                	mov    %ebx,%eax
  800d7e:	89 fa                	mov    %edi,%edx
  800d80:	83 c4 1c             	add    $0x1c,%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
  800d88:	90                   	nop
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	39 ce                	cmp    %ecx,%esi
  800d92:	77 74                	ja     800e08 <__udivdi3+0xd8>
  800d94:	0f bd fe             	bsr    %esi,%edi
  800d97:	83 f7 1f             	xor    $0x1f,%edi
  800d9a:	0f 84 98 00 00 00    	je     800e38 <__udivdi3+0x108>
  800da0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	89 c5                	mov    %eax,%ebp
  800da9:	29 fb                	sub    %edi,%ebx
  800dab:	d3 e6                	shl    %cl,%esi
  800dad:	89 d9                	mov    %ebx,%ecx
  800daf:	d3 ed                	shr    %cl,%ebp
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	d3 e0                	shl    %cl,%eax
  800db5:	09 ee                	or     %ebp,%esi
  800db7:	89 d9                	mov    %ebx,%ecx
  800db9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbd:	89 d5                	mov    %edx,%ebp
  800dbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dc3:	d3 ed                	shr    %cl,%ebp
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e2                	shl    %cl,%edx
  800dc9:	89 d9                	mov    %ebx,%ecx
  800dcb:	d3 e8                	shr    %cl,%eax
  800dcd:	09 c2                	or     %eax,%edx
  800dcf:	89 d0                	mov    %edx,%eax
  800dd1:	89 ea                	mov    %ebp,%edx
  800dd3:	f7 f6                	div    %esi
  800dd5:	89 d5                	mov    %edx,%ebp
  800dd7:	89 c3                	mov    %eax,%ebx
  800dd9:	f7 64 24 0c          	mull   0xc(%esp)
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	72 10                	jb     800df1 <__udivdi3+0xc1>
  800de1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800de5:	89 f9                	mov    %edi,%ecx
  800de7:	d3 e6                	shl    %cl,%esi
  800de9:	39 c6                	cmp    %eax,%esi
  800deb:	73 07                	jae    800df4 <__udivdi3+0xc4>
  800ded:	39 d5                	cmp    %edx,%ebp
  800def:	75 03                	jne    800df4 <__udivdi3+0xc4>
  800df1:	83 eb 01             	sub    $0x1,%ebx
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 d8                	mov    %ebx,%eax
  800df8:	89 fa                	mov    %edi,%edx
  800dfa:	83 c4 1c             	add    $0x1c,%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    
  800e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e08:	31 ff                	xor    %edi,%edi
  800e0a:	31 db                	xor    %ebx,%ebx
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
  800e18:	90                   	nop
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	89 d8                	mov    %ebx,%eax
  800e22:	f7 f7                	div    %edi
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	89 c3                	mov    %eax,%ebx
  800e28:	89 d8                	mov    %ebx,%eax
  800e2a:	89 fa                	mov    %edi,%edx
  800e2c:	83 c4 1c             	add    $0x1c,%esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5f                   	pop    %edi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	39 ce                	cmp    %ecx,%esi
  800e3a:	72 0c                	jb     800e48 <__udivdi3+0x118>
  800e3c:	31 db                	xor    %ebx,%ebx
  800e3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e42:	0f 87 34 ff ff ff    	ja     800d7c <__udivdi3+0x4c>
  800e48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e4d:	e9 2a ff ff ff       	jmp    800d7c <__udivdi3+0x4c>
  800e52:	66 90                	xchg   %ax,%ax
  800e54:	66 90                	xchg   %ax,%ax
  800e56:	66 90                	xchg   %ax,%ax
  800e58:	66 90                	xchg   %ax,%ax
  800e5a:	66 90                	xchg   %ax,%ax
  800e5c:	66 90                	xchg   %ax,%ax
  800e5e:	66 90                	xchg   %ax,%ax

00800e60 <__umoddi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 1c             	sub    $0x1c,%esp
  800e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e77:	85 d2                	test   %edx,%edx
  800e79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e81:	89 f3                	mov    %esi,%ebx
  800e83:	89 3c 24             	mov    %edi,(%esp)
  800e86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8a:	75 1c                	jne    800ea8 <__umoddi3+0x48>
  800e8c:	39 f7                	cmp    %esi,%edi
  800e8e:	76 50                	jbe    800ee0 <__umoddi3+0x80>
  800e90:	89 c8                	mov    %ecx,%eax
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	f7 f7                	div    %edi
  800e96:	89 d0                	mov    %edx,%eax
  800e98:	31 d2                	xor    %edx,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea8:	39 f2                	cmp    %esi,%edx
  800eaa:	89 d0                	mov    %edx,%eax
  800eac:	77 52                	ja     800f00 <__umoddi3+0xa0>
  800eae:	0f bd ea             	bsr    %edx,%ebp
  800eb1:	83 f5 1f             	xor    $0x1f,%ebp
  800eb4:	75 5a                	jne    800f10 <__umoddi3+0xb0>
  800eb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eba:	0f 82 e0 00 00 00    	jb     800fa0 <__umoddi3+0x140>
  800ec0:	39 0c 24             	cmp    %ecx,(%esp)
  800ec3:	0f 86 d7 00 00 00    	jbe    800fa0 <__umoddi3+0x140>
  800ec9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ecd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ed1:	83 c4 1c             	add    $0x1c,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	85 ff                	test   %edi,%edi
  800ee2:	89 fd                	mov    %edi,%ebp
  800ee4:	75 0b                	jne    800ef1 <__umoddi3+0x91>
  800ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	f7 f7                	div    %edi
  800eef:	89 c5                	mov    %eax,%ebp
  800ef1:	89 f0                	mov    %esi,%eax
  800ef3:	31 d2                	xor    %edx,%edx
  800ef5:	f7 f5                	div    %ebp
  800ef7:	89 c8                	mov    %ecx,%eax
  800ef9:	f7 f5                	div    %ebp
  800efb:	89 d0                	mov    %edx,%eax
  800efd:	eb 99                	jmp    800e98 <__umoddi3+0x38>
  800eff:	90                   	nop
  800f00:	89 c8                	mov    %ecx,%eax
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	83 c4 1c             	add    $0x1c,%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    
  800f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f10:	8b 34 24             	mov    (%esp),%esi
  800f13:	bf 20 00 00 00       	mov    $0x20,%edi
  800f18:	89 e9                	mov    %ebp,%ecx
  800f1a:	29 ef                	sub    %ebp,%edi
  800f1c:	d3 e0                	shl    %cl,%eax
  800f1e:	89 f9                	mov    %edi,%ecx
  800f20:	89 f2                	mov    %esi,%edx
  800f22:	d3 ea                	shr    %cl,%edx
  800f24:	89 e9                	mov    %ebp,%ecx
  800f26:	09 c2                	or     %eax,%edx
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	89 14 24             	mov    %edx,(%esp)
  800f2d:	89 f2                	mov    %esi,%edx
  800f2f:	d3 e2                	shl    %cl,%edx
  800f31:	89 f9                	mov    %edi,%ecx
  800f33:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f3b:	d3 e8                	shr    %cl,%eax
  800f3d:	89 e9                	mov    %ebp,%ecx
  800f3f:	89 c6                	mov    %eax,%esi
  800f41:	d3 e3                	shl    %cl,%ebx
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	89 d0                	mov    %edx,%eax
  800f47:	d3 e8                	shr    %cl,%eax
  800f49:	89 e9                	mov    %ebp,%ecx
  800f4b:	09 d8                	or     %ebx,%eax
  800f4d:	89 d3                	mov    %edx,%ebx
  800f4f:	89 f2                	mov    %esi,%edx
  800f51:	f7 34 24             	divl   (%esp)
  800f54:	89 d6                	mov    %edx,%esi
  800f56:	d3 e3                	shl    %cl,%ebx
  800f58:	f7 64 24 04          	mull   0x4(%esp)
  800f5c:	39 d6                	cmp    %edx,%esi
  800f5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f62:	89 d1                	mov    %edx,%ecx
  800f64:	89 c3                	mov    %eax,%ebx
  800f66:	72 08                	jb     800f70 <__umoddi3+0x110>
  800f68:	75 11                	jne    800f7b <__umoddi3+0x11b>
  800f6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f6e:	73 0b                	jae    800f7b <__umoddi3+0x11b>
  800f70:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f74:	1b 14 24             	sbb    (%esp),%edx
  800f77:	89 d1                	mov    %edx,%ecx
  800f79:	89 c3                	mov    %eax,%ebx
  800f7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f7f:	29 da                	sub    %ebx,%edx
  800f81:	19 ce                	sbb    %ecx,%esi
  800f83:	89 f9                	mov    %edi,%ecx
  800f85:	89 f0                	mov    %esi,%eax
  800f87:	d3 e0                	shl    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	d3 ea                	shr    %cl,%edx
  800f8d:	89 e9                	mov    %ebp,%ecx
  800f8f:	d3 ee                	shr    %cl,%esi
  800f91:	09 d0                	or     %edx,%eax
  800f93:	89 f2                	mov    %esi,%edx
  800f95:	83 c4 1c             	add    $0x1c,%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    
  800f9d:	8d 76 00             	lea    0x0(%esi),%esi
  800fa0:	29 f9                	sub    %edi,%ecx
  800fa2:	19 d6                	sbb    %edx,%esi
  800fa4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fac:	e9 18 ff ff ff       	jmp    800ec9 <__umoddi3+0x69>
