
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 59 03 80 00       	push   $0x800359
  80003e:	6a 00                	push   $0x0
  800040:	e8 6e 02 00 00       	call   8002b3 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 4a 10 80 00       	push   $0x80104a
  800116:	6a 23                	push   $0x23
  800118:	68 67 10 80 00       	push   $0x801067
  80011d:	e8 5c 02 00 00       	call   80037e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0b 00 00 00       	mov    $0xb,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 4a 10 80 00       	push   $0x80104a
  800197:	6a 23                	push   $0x23
  800199:	68 67 10 80 00       	push   $0x801067
  80019e:	e8 db 01 00 00       	call   80037e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 4a 10 80 00       	push   $0x80104a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 67 10 80 00       	push   $0x801067
  8001e0:	e8 99 01 00 00       	call   80037e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 4a 10 80 00       	push   $0x80104a
  80021b:	6a 23                	push   $0x23
  80021d:	68 67 10 80 00       	push   $0x801067
  800222:	e8 57 01 00 00       	call   80037e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 4a 10 80 00       	push   $0x80104a
  80025d:	6a 23                	push   $0x23
  80025f:	68 67 10 80 00       	push   $0x801067
  800264:	e8 15 01 00 00       	call   80037e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 4a 10 80 00       	push   $0x80104a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 67 10 80 00       	push   $0x801067
  8002a6:	e8 d3 00 00 00       	call   80037e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cc:	89 df                	mov    %ebx,%edi
  8002ce:	89 de                	mov    %ebx,%esi
  8002d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d2:	85 c0                	test   %eax,%eax
  8002d4:	7e 17                	jle    8002ed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d6:	83 ec 0c             	sub    $0xc,%esp
  8002d9:	50                   	push   %eax
  8002da:	6a 0a                	push   $0xa
  8002dc:	68 4a 10 80 00       	push   $0x80104a
  8002e1:	6a 23                	push   $0x23
  8002e3:	68 67 10 80 00       	push   $0x801067
  8002e8:	e8 91 00 00 00       	call   80037e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fb:	be 00 00 00 00       	mov    $0x0,%esi
  800300:	b8 0c 00 00 00       	mov    $0xc,%eax
  800305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800308:	8b 55 08             	mov    0x8(%ebp),%edx
  80030b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800311:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800321:	b9 00 00 00 00       	mov    $0x0,%ecx
  800326:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
  80032e:	89 cb                	mov    %ecx,%ebx
  800330:	89 cf                	mov    %ecx,%edi
  800332:	89 ce                	mov    %ecx,%esi
  800334:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800336:	85 c0                	test   %eax,%eax
  800338:	7e 17                	jle    800351 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033a:	83 ec 0c             	sub    $0xc,%esp
  80033d:	50                   	push   %eax
  80033e:	6a 0d                	push   $0xd
  800340:	68 4a 10 80 00       	push   $0x80104a
  800345:	6a 23                	push   $0x23
  800347:	68 67 10 80 00       	push   $0x801067
  80034c:	e8 2d 00 00 00       	call   80037e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800354:	5b                   	pop    %ebx
  800355:	5e                   	pop    %esi
  800356:	5f                   	pop    %edi
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800359:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80035a:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80035f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800361:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  800364:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  800368:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  80036a:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  80036e:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  80036f:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  800372:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  800374:	83 c4 08             	add    $0x8,%esp
popal
  800377:	61                   	popa   
addl $0x4, %esp
  800378:	83 c4 04             	add    $0x4,%esp
popfl
  80037b:	9d                   	popf   
popl %esp
  80037c:	5c                   	pop    %esp
ret
  80037d:	c3                   	ret    

0080037e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800383:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800386:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80038c:	e8 99 fd ff ff       	call   80012a <sys_getenvid>
  800391:	83 ec 0c             	sub    $0xc,%esp
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	56                   	push   %esi
  80039b:	50                   	push   %eax
  80039c:	68 78 10 80 00       	push   $0x801078
  8003a1:	e8 b1 00 00 00       	call   800457 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003a6:	83 c4 18             	add    $0x18,%esp
  8003a9:	53                   	push   %ebx
  8003aa:	ff 75 10             	pushl  0x10(%ebp)
  8003ad:	e8 54 00 00 00       	call   800406 <vcprintf>
	cprintf("\n");
  8003b2:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  8003b9:	e8 99 00 00 00       	call   800457 <cprintf>
  8003be:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c1:	cc                   	int3   
  8003c2:	eb fd                	jmp    8003c1 <_panic+0x43>

008003c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	53                   	push   %ebx
  8003c8:	83 ec 04             	sub    $0x4,%esp
  8003cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ce:	8b 13                	mov    (%ebx),%edx
  8003d0:	8d 42 01             	lea    0x1(%edx),%eax
  8003d3:	89 03                	mov    %eax,(%ebx)
  8003d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e1:	75 1a                	jne    8003fd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	68 ff 00 00 00       	push   $0xff
  8003eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ee:	50                   	push   %eax
  8003ef:	e8 b8 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003fa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003fd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800401:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800404:	c9                   	leave  
  800405:	c3                   	ret    

00800406 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80040f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800416:	00 00 00 
	b.cnt = 0;
  800419:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800420:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800423:	ff 75 0c             	pushl  0xc(%ebp)
  800426:	ff 75 08             	pushl  0x8(%ebp)
  800429:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80042f:	50                   	push   %eax
  800430:	68 c4 03 80 00       	push   $0x8003c4
  800435:	e8 54 01 00 00       	call   80058e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80043a:	83 c4 08             	add    $0x8,%esp
  80043d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800443:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800449:	50                   	push   %eax
  80044a:	e8 5d fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80044f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800455:	c9                   	leave  
  800456:	c3                   	ret    

00800457 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80045d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800460:	50                   	push   %eax
  800461:	ff 75 08             	pushl  0x8(%ebp)
  800464:	e8 9d ff ff ff       	call   800406 <vcprintf>
	va_end(ap);

	return cnt;
}
  800469:	c9                   	leave  
  80046a:	c3                   	ret    

0080046b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	57                   	push   %edi
  80046f:	56                   	push   %esi
  800470:	53                   	push   %ebx
  800471:	83 ec 1c             	sub    $0x1c,%esp
  800474:	89 c7                	mov    %eax,%edi
  800476:	89 d6                	mov    %edx,%esi
  800478:	8b 45 08             	mov    0x8(%ebp),%eax
  80047b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800481:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800484:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800487:	bb 00 00 00 00       	mov    $0x0,%ebx
  80048c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80048f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800492:	39 d3                	cmp    %edx,%ebx
  800494:	72 05                	jb     80049b <printnum+0x30>
  800496:	39 45 10             	cmp    %eax,0x10(%ebp)
  800499:	77 45                	ja     8004e0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80049b:	83 ec 0c             	sub    $0xc,%esp
  80049e:	ff 75 18             	pushl  0x18(%ebp)
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8004a7:	53                   	push   %ebx
  8004a8:	ff 75 10             	pushl  0x10(%ebp)
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ba:	e8 e1 08 00 00       	call   800da0 <__udivdi3>
  8004bf:	83 c4 18             	add    $0x18,%esp
  8004c2:	52                   	push   %edx
  8004c3:	50                   	push   %eax
  8004c4:	89 f2                	mov    %esi,%edx
  8004c6:	89 f8                	mov    %edi,%eax
  8004c8:	e8 9e ff ff ff       	call   80046b <printnum>
  8004cd:	83 c4 20             	add    $0x20,%esp
  8004d0:	eb 18                	jmp    8004ea <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff 75 18             	pushl  0x18(%ebp)
  8004d9:	ff d7                	call   *%edi
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	eb 03                	jmp    8004e3 <printnum+0x78>
  8004e0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004e3:	83 eb 01             	sub    $0x1,%ebx
  8004e6:	85 db                	test   %ebx,%ebx
  8004e8:	7f e8                	jg     8004d2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	56                   	push   %esi
  8004ee:	83 ec 04             	sub    $0x4,%esp
  8004f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f7:	ff 75 dc             	pushl  -0x24(%ebp)
  8004fa:	ff 75 d8             	pushl  -0x28(%ebp)
  8004fd:	e8 ce 09 00 00       	call   800ed0 <__umoddi3>
  800502:	83 c4 14             	add    $0x14,%esp
  800505:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  80050c:	50                   	push   %eax
  80050d:	ff d7                	call   *%edi
}
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800515:	5b                   	pop    %ebx
  800516:	5e                   	pop    %esi
  800517:	5f                   	pop    %edi
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80051d:	83 fa 01             	cmp    $0x1,%edx
  800520:	7e 0e                	jle    800530 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800522:	8b 10                	mov    (%eax),%edx
  800524:	8d 4a 08             	lea    0x8(%edx),%ecx
  800527:	89 08                	mov    %ecx,(%eax)
  800529:	8b 02                	mov    (%edx),%eax
  80052b:	8b 52 04             	mov    0x4(%edx),%edx
  80052e:	eb 22                	jmp    800552 <getuint+0x38>
	else if (lflag)
  800530:	85 d2                	test   %edx,%edx
  800532:	74 10                	je     800544 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800534:	8b 10                	mov    (%eax),%edx
  800536:	8d 4a 04             	lea    0x4(%edx),%ecx
  800539:	89 08                	mov    %ecx,(%eax)
  80053b:	8b 02                	mov    (%edx),%eax
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
  800542:	eb 0e                	jmp    800552 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800544:	8b 10                	mov    (%eax),%edx
  800546:	8d 4a 04             	lea    0x4(%edx),%ecx
  800549:	89 08                	mov    %ecx,(%eax)
  80054b:	8b 02                	mov    (%edx),%eax
  80054d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800552:	5d                   	pop    %ebp
  800553:	c3                   	ret    

00800554 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80055a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80055e:	8b 10                	mov    (%eax),%edx
  800560:	3b 50 04             	cmp    0x4(%eax),%edx
  800563:	73 0a                	jae    80056f <sprintputch+0x1b>
		*b->buf++ = ch;
  800565:	8d 4a 01             	lea    0x1(%edx),%ecx
  800568:	89 08                	mov    %ecx,(%eax)
  80056a:	8b 45 08             	mov    0x8(%ebp),%eax
  80056d:	88 02                	mov    %al,(%edx)
}
  80056f:	5d                   	pop    %ebp
  800570:	c3                   	ret    

00800571 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800571:	55                   	push   %ebp
  800572:	89 e5                	mov    %esp,%ebp
  800574:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800577:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80057a:	50                   	push   %eax
  80057b:	ff 75 10             	pushl  0x10(%ebp)
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	ff 75 08             	pushl  0x8(%ebp)
  800584:	e8 05 00 00 00       	call   80058e <vprintfmt>
	va_end(ap);
}
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	c9                   	leave  
  80058d:	c3                   	ret    

0080058e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80058e:	55                   	push   %ebp
  80058f:	89 e5                	mov    %esp,%ebp
  800591:	57                   	push   %edi
  800592:	56                   	push   %esi
  800593:	53                   	push   %ebx
  800594:	83 ec 2c             	sub    $0x2c,%esp
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005a0:	eb 12                	jmp    8005b4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	0f 84 89 03 00 00    	je     800933 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	53                   	push   %ebx
  8005ae:	50                   	push   %eax
  8005af:	ff d6                	call   *%esi
  8005b1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b4:	83 c7 01             	add    $0x1,%edi
  8005b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005bb:	83 f8 25             	cmp    $0x25,%eax
  8005be:	75 e2                	jne    8005a2 <vprintfmt+0x14>
  8005c0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005c4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005de:	eb 07                	jmp    8005e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005e3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8d 47 01             	lea    0x1(%edi),%eax
  8005ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ed:	0f b6 07             	movzbl (%edi),%eax
  8005f0:	0f b6 c8             	movzbl %al,%ecx
  8005f3:	83 e8 23             	sub    $0x23,%eax
  8005f6:	3c 55                	cmp    $0x55,%al
  8005f8:	0f 87 1a 03 00 00    	ja     800918 <vprintfmt+0x38a>
  8005fe:	0f b6 c0             	movzbl %al,%eax
  800601:	ff 24 85 e0 11 80 00 	jmp    *0x8011e0(,%eax,4)
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80060b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80060f:	eb d6                	jmp    8005e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800614:	b8 00 00 00 00       	mov    $0x0,%eax
  800619:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80061c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80061f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800623:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800626:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800629:	83 fa 09             	cmp    $0x9,%edx
  80062c:	77 39                	ja     800667 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80062e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800631:	eb e9                	jmp    80061c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 48 04             	lea    0x4(%eax),%ecx
  800639:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800644:	eb 27                	jmp    80066d <vprintfmt+0xdf>
  800646:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800649:	85 c0                	test   %eax,%eax
  80064b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800650:	0f 49 c8             	cmovns %eax,%ecx
  800653:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800659:	eb 8c                	jmp    8005e7 <vprintfmt+0x59>
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80065e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800665:	eb 80                	jmp    8005e7 <vprintfmt+0x59>
  800667:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80066d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800671:	0f 89 70 ff ff ff    	jns    8005e7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800677:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80067a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80067d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800684:	e9 5e ff ff ff       	jmp    8005e7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800689:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80068f:	e9 53 ff ff ff       	jmp    8005e7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	ff 30                	pushl  (%eax)
  8006a3:	ff d6                	call   *%esi
			break;
  8006a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006ab:	e9 04 ff ff ff       	jmp    8005b4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 04             	lea    0x4(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	99                   	cltd   
  8006bc:	31 d0                	xor    %edx,%eax
  8006be:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006c0:	83 f8 0f             	cmp    $0xf,%eax
  8006c3:	7f 0b                	jg     8006d0 <vprintfmt+0x142>
  8006c5:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  8006cc:	85 d2                	test   %edx,%edx
  8006ce:	75 18                	jne    8006e8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006d0:	50                   	push   %eax
  8006d1:	68 b5 10 80 00       	push   $0x8010b5
  8006d6:	53                   	push   %ebx
  8006d7:	56                   	push   %esi
  8006d8:	e8 94 fe ff ff       	call   800571 <printfmt>
  8006dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006e3:	e9 cc fe ff ff       	jmp    8005b4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006e8:	52                   	push   %edx
  8006e9:	68 be 10 80 00       	push   $0x8010be
  8006ee:	53                   	push   %ebx
  8006ef:	56                   	push   %esi
  8006f0:	e8 7c fe ff ff       	call   800571 <printfmt>
  8006f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fb:	e9 b4 fe ff ff       	jmp    8005b4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8d 50 04             	lea    0x4(%eax),%edx
  800706:	89 55 14             	mov    %edx,0x14(%ebp)
  800709:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80070b:	85 ff                	test   %edi,%edi
  80070d:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  800712:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800715:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800719:	0f 8e 94 00 00 00    	jle    8007b3 <vprintfmt+0x225>
  80071f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800723:	0f 84 98 00 00 00    	je     8007c1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	ff 75 d0             	pushl  -0x30(%ebp)
  80072f:	57                   	push   %edi
  800730:	e8 86 02 00 00       	call   8009bb <strnlen>
  800735:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800738:	29 c1                	sub    %eax,%ecx
  80073a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80073d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800740:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800744:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800747:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80074a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074c:	eb 0f                	jmp    80075d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	ff 75 e0             	pushl  -0x20(%ebp)
  800755:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800757:	83 ef 01             	sub    $0x1,%edi
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	85 ff                	test   %edi,%edi
  80075f:	7f ed                	jg     80074e <vprintfmt+0x1c0>
  800761:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800764:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800767:	85 c9                	test   %ecx,%ecx
  800769:	b8 00 00 00 00       	mov    $0x0,%eax
  80076e:	0f 49 c1             	cmovns %ecx,%eax
  800771:	29 c1                	sub    %eax,%ecx
  800773:	89 75 08             	mov    %esi,0x8(%ebp)
  800776:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800779:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077c:	89 cb                	mov    %ecx,%ebx
  80077e:	eb 4d                	jmp    8007cd <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800780:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800784:	74 1b                	je     8007a1 <vprintfmt+0x213>
  800786:	0f be c0             	movsbl %al,%eax
  800789:	83 e8 20             	sub    $0x20,%eax
  80078c:	83 f8 5e             	cmp    $0x5e,%eax
  80078f:	76 10                	jbe    8007a1 <vprintfmt+0x213>
					putch('?', putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	ff 75 0c             	pushl  0xc(%ebp)
  800797:	6a 3f                	push   $0x3f
  800799:	ff 55 08             	call   *0x8(%ebp)
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	eb 0d                	jmp    8007ae <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	ff 75 0c             	pushl  0xc(%ebp)
  8007a7:	52                   	push   %edx
  8007a8:	ff 55 08             	call   *0x8(%ebp)
  8007ab:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ae:	83 eb 01             	sub    $0x1,%ebx
  8007b1:	eb 1a                	jmp    8007cd <vprintfmt+0x23f>
  8007b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8007b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007bf:	eb 0c                	jmp    8007cd <vprintfmt+0x23f>
  8007c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8007c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007cd:	83 c7 01             	add    $0x1,%edi
  8007d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007d4:	0f be d0             	movsbl %al,%edx
  8007d7:	85 d2                	test   %edx,%edx
  8007d9:	74 23                	je     8007fe <vprintfmt+0x270>
  8007db:	85 f6                	test   %esi,%esi
  8007dd:	78 a1                	js     800780 <vprintfmt+0x1f2>
  8007df:	83 ee 01             	sub    $0x1,%esi
  8007e2:	79 9c                	jns    800780 <vprintfmt+0x1f2>
  8007e4:	89 df                	mov    %ebx,%edi
  8007e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ec:	eb 18                	jmp    800806 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	6a 20                	push   $0x20
  8007f4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007f6:	83 ef 01             	sub    $0x1,%edi
  8007f9:	83 c4 10             	add    $0x10,%esp
  8007fc:	eb 08                	jmp    800806 <vprintfmt+0x278>
  8007fe:	89 df                	mov    %ebx,%edi
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800806:	85 ff                	test   %edi,%edi
  800808:	7f e4                	jg     8007ee <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080d:	e9 a2 fd ff ff       	jmp    8005b4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800812:	83 fa 01             	cmp    $0x1,%edx
  800815:	7e 16                	jle    80082d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 08             	lea    0x8(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)
  800820:	8b 50 04             	mov    0x4(%eax),%edx
  800823:	8b 00                	mov    (%eax),%eax
  800825:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800828:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80082b:	eb 32                	jmp    80085f <vprintfmt+0x2d1>
	else if (lflag)
  80082d:	85 d2                	test   %edx,%edx
  80082f:	74 18                	je     800849 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8d 50 04             	lea    0x4(%eax),%edx
  800837:	89 55 14             	mov    %edx,0x14(%ebp)
  80083a:	8b 00                	mov    (%eax),%eax
  80083c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083f:	89 c1                	mov    %eax,%ecx
  800841:	c1 f9 1f             	sar    $0x1f,%ecx
  800844:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800847:	eb 16                	jmp    80085f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8d 50 04             	lea    0x4(%eax),%edx
  80084f:	89 55 14             	mov    %edx,0x14(%ebp)
  800852:	8b 00                	mov    (%eax),%eax
  800854:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800857:	89 c1                	mov    %eax,%ecx
  800859:	c1 f9 1f             	sar    $0x1f,%ecx
  80085c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80085f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800862:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800865:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80086a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80086e:	79 74                	jns    8008e4 <vprintfmt+0x356>
				putch('-', putdat);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 2d                	push   $0x2d
  800876:	ff d6                	call   *%esi
				num = -(long long) num;
  800878:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80087b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80087e:	f7 d8                	neg    %eax
  800880:	83 d2 00             	adc    $0x0,%edx
  800883:	f7 da                	neg    %edx
  800885:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800888:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80088d:	eb 55                	jmp    8008e4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80088f:	8d 45 14             	lea    0x14(%ebp),%eax
  800892:	e8 83 fc ff ff       	call   80051a <getuint>
			base = 10;
  800897:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80089c:	eb 46                	jmp    8008e4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80089e:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a1:	e8 74 fc ff ff       	call   80051a <getuint>
			base = 8;
  8008a6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8008ab:	eb 37                	jmp    8008e4 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	53                   	push   %ebx
  8008b1:	6a 30                	push   $0x30
  8008b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b5:	83 c4 08             	add    $0x8,%esp
  8008b8:	53                   	push   %ebx
  8008b9:	6a 78                	push   $0x78
  8008bb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8d 50 04             	lea    0x4(%eax),%edx
  8008c3:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008c6:	8b 00                	mov    (%eax),%eax
  8008c8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008d0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008d5:	eb 0d                	jmp    8008e4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008da:	e8 3b fc ff ff       	call   80051a <getuint>
			base = 16;
  8008df:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e4:	83 ec 0c             	sub    $0xc,%esp
  8008e7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008eb:	57                   	push   %edi
  8008ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ef:	51                   	push   %ecx
  8008f0:	52                   	push   %edx
  8008f1:	50                   	push   %eax
  8008f2:	89 da                	mov    %ebx,%edx
  8008f4:	89 f0                	mov    %esi,%eax
  8008f6:	e8 70 fb ff ff       	call   80046b <printnum>
			break;
  8008fb:	83 c4 20             	add    $0x20,%esp
  8008fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800901:	e9 ae fc ff ff       	jmp    8005b4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	51                   	push   %ecx
  80090b:	ff d6                	call   *%esi
			break;
  80090d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800910:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800913:	e9 9c fc ff ff       	jmp    8005b4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800918:	83 ec 08             	sub    $0x8,%esp
  80091b:	53                   	push   %ebx
  80091c:	6a 25                	push   $0x25
  80091e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800920:	83 c4 10             	add    $0x10,%esp
  800923:	eb 03                	jmp    800928 <vprintfmt+0x39a>
  800925:	83 ef 01             	sub    $0x1,%edi
  800928:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80092c:	75 f7                	jne    800925 <vprintfmt+0x397>
  80092e:	e9 81 fc ff ff       	jmp    8005b4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800933:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5f                   	pop    %edi
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	83 ec 18             	sub    $0x18,%esp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800947:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80094a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80094e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800958:	85 c0                	test   %eax,%eax
  80095a:	74 26                	je     800982 <vsnprintf+0x47>
  80095c:	85 d2                	test   %edx,%edx
  80095e:	7e 22                	jle    800982 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800960:	ff 75 14             	pushl  0x14(%ebp)
  800963:	ff 75 10             	pushl  0x10(%ebp)
  800966:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800969:	50                   	push   %eax
  80096a:	68 54 05 80 00       	push   $0x800554
  80096f:	e8 1a fc ff ff       	call   80058e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800974:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800977:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80097a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097d:	83 c4 10             	add    $0x10,%esp
  800980:	eb 05                	jmp    800987 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800982:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80098f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800992:	50                   	push   %eax
  800993:	ff 75 10             	pushl  0x10(%ebp)
  800996:	ff 75 0c             	pushl  0xc(%ebp)
  800999:	ff 75 08             	pushl  0x8(%ebp)
  80099c:	e8 9a ff ff ff       	call   80093b <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ae:	eb 03                	jmp    8009b3 <strlen+0x10>
		n++;
  8009b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b7:	75 f7                	jne    8009b0 <strlen+0xd>
		n++;
	return n;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c9:	eb 03                	jmp    8009ce <strnlen+0x13>
		n++;
  8009cb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ce:	39 c2                	cmp    %eax,%edx
  8009d0:	74 08                	je     8009da <strnlen+0x1f>
  8009d2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009d6:	75 f3                	jne    8009cb <strnlen+0x10>
  8009d8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	53                   	push   %ebx
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e6:	89 c2                	mov    %eax,%edx
  8009e8:	83 c2 01             	add    $0x1,%edx
  8009eb:	83 c1 01             	add    $0x1,%ecx
  8009ee:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009f2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f5:	84 db                	test   %bl,%bl
  8009f7:	75 ef                	jne    8009e8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	53                   	push   %ebx
  800a00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a03:	53                   	push   %ebx
  800a04:	e8 9a ff ff ff       	call   8009a3 <strlen>
  800a09:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a0c:	ff 75 0c             	pushl  0xc(%ebp)
  800a0f:	01 d8                	add    %ebx,%eax
  800a11:	50                   	push   %eax
  800a12:	e8 c5 ff ff ff       	call   8009dc <strcpy>
	return dst;
}
  800a17:	89 d8                	mov    %ebx,%eax
  800a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 75 08             	mov    0x8(%ebp),%esi
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a29:	89 f3                	mov    %esi,%ebx
  800a2b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2e:	89 f2                	mov    %esi,%edx
  800a30:	eb 0f                	jmp    800a41 <strncpy+0x23>
		*dst++ = *src;
  800a32:	83 c2 01             	add    $0x1,%edx
  800a35:	0f b6 01             	movzbl (%ecx),%eax
  800a38:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3b:	80 39 01             	cmpb   $0x1,(%ecx)
  800a3e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a41:	39 da                	cmp    %ebx,%edx
  800a43:	75 ed                	jne    800a32 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a45:	89 f0                	mov    %esi,%eax
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 75 08             	mov    0x8(%ebp),%esi
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a56:	8b 55 10             	mov    0x10(%ebp),%edx
  800a59:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5b:	85 d2                	test   %edx,%edx
  800a5d:	74 21                	je     800a80 <strlcpy+0x35>
  800a5f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a63:	89 f2                	mov    %esi,%edx
  800a65:	eb 09                	jmp    800a70 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a67:	83 c2 01             	add    $0x1,%edx
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a70:	39 c2                	cmp    %eax,%edx
  800a72:	74 09                	je     800a7d <strlcpy+0x32>
  800a74:	0f b6 19             	movzbl (%ecx),%ebx
  800a77:	84 db                	test   %bl,%bl
  800a79:	75 ec                	jne    800a67 <strlcpy+0x1c>
  800a7b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a7d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a80:	29 f0                	sub    %esi,%eax
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a8f:	eb 06                	jmp    800a97 <strcmp+0x11>
		p++, q++;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a97:	0f b6 01             	movzbl (%ecx),%eax
  800a9a:	84 c0                	test   %al,%al
  800a9c:	74 04                	je     800aa2 <strcmp+0x1c>
  800a9e:	3a 02                	cmp    (%edx),%al
  800aa0:	74 ef                	je     800a91 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa2:	0f b6 c0             	movzbl %al,%eax
  800aa5:	0f b6 12             	movzbl (%edx),%edx
  800aa8:	29 d0                	sub    %edx,%eax
}
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	53                   	push   %ebx
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab6:	89 c3                	mov    %eax,%ebx
  800ab8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800abb:	eb 06                	jmp    800ac3 <strncmp+0x17>
		n--, p++, q++;
  800abd:	83 c0 01             	add    $0x1,%eax
  800ac0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac3:	39 d8                	cmp    %ebx,%eax
  800ac5:	74 15                	je     800adc <strncmp+0x30>
  800ac7:	0f b6 08             	movzbl (%eax),%ecx
  800aca:	84 c9                	test   %cl,%cl
  800acc:	74 04                	je     800ad2 <strncmp+0x26>
  800ace:	3a 0a                	cmp    (%edx),%cl
  800ad0:	74 eb                	je     800abd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad2:	0f b6 00             	movzbl (%eax),%eax
  800ad5:	0f b6 12             	movzbl (%edx),%edx
  800ad8:	29 d0                	sub    %edx,%eax
  800ada:	eb 05                	jmp    800ae1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aee:	eb 07                	jmp    800af7 <strchr+0x13>
		if (*s == c)
  800af0:	38 ca                	cmp    %cl,%dl
  800af2:	74 0f                	je     800b03 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af4:	83 c0 01             	add    $0x1,%eax
  800af7:	0f b6 10             	movzbl (%eax),%edx
  800afa:	84 d2                	test   %dl,%dl
  800afc:	75 f2                	jne    800af0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b0f:	eb 03                	jmp    800b14 <strfind+0xf>
  800b11:	83 c0 01             	add    $0x1,%eax
  800b14:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b17:	38 ca                	cmp    %cl,%dl
  800b19:	74 04                	je     800b1f <strfind+0x1a>
  800b1b:	84 d2                	test   %dl,%dl
  800b1d:	75 f2                	jne    800b11 <strfind+0xc>
			break;
	return (char *) s;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b2d:	85 c9                	test   %ecx,%ecx
  800b2f:	74 36                	je     800b67 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b37:	75 28                	jne    800b61 <memset+0x40>
  800b39:	f6 c1 03             	test   $0x3,%cl
  800b3c:	75 23                	jne    800b61 <memset+0x40>
		c &= 0xFF;
  800b3e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	c1 e3 08             	shl    $0x8,%ebx
  800b47:	89 d6                	mov    %edx,%esi
  800b49:	c1 e6 18             	shl    $0x18,%esi
  800b4c:	89 d0                	mov    %edx,%eax
  800b4e:	c1 e0 10             	shl    $0x10,%eax
  800b51:	09 f0                	or     %esi,%eax
  800b53:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b55:	89 d8                	mov    %ebx,%eax
  800b57:	09 d0                	or     %edx,%eax
  800b59:	c1 e9 02             	shr    $0x2,%ecx
  800b5c:	fc                   	cld    
  800b5d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b5f:	eb 06                	jmp    800b67 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b64:	fc                   	cld    
  800b65:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b67:	89 f8                	mov    %edi,%eax
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b7c:	39 c6                	cmp    %eax,%esi
  800b7e:	73 35                	jae    800bb5 <memmove+0x47>
  800b80:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b83:	39 d0                	cmp    %edx,%eax
  800b85:	73 2e                	jae    800bb5 <memmove+0x47>
		s += n;
		d += n;
  800b87:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	09 fe                	or     %edi,%esi
  800b8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b94:	75 13                	jne    800ba9 <memmove+0x3b>
  800b96:	f6 c1 03             	test   $0x3,%cl
  800b99:	75 0e                	jne    800ba9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b9b:	83 ef 04             	sub    $0x4,%edi
  800b9e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba1:	c1 e9 02             	shr    $0x2,%ecx
  800ba4:	fd                   	std    
  800ba5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba7:	eb 09                	jmp    800bb2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ba9:	83 ef 01             	sub    $0x1,%edi
  800bac:	8d 72 ff             	lea    -0x1(%edx),%esi
  800baf:	fd                   	std    
  800bb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb2:	fc                   	cld    
  800bb3:	eb 1d                	jmp    800bd2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb5:	89 f2                	mov    %esi,%edx
  800bb7:	09 c2                	or     %eax,%edx
  800bb9:	f6 c2 03             	test   $0x3,%dl
  800bbc:	75 0f                	jne    800bcd <memmove+0x5f>
  800bbe:	f6 c1 03             	test   $0x3,%cl
  800bc1:	75 0a                	jne    800bcd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bc3:	c1 e9 02             	shr    $0x2,%ecx
  800bc6:	89 c7                	mov    %eax,%edi
  800bc8:	fc                   	cld    
  800bc9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcb:	eb 05                	jmp    800bd2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bcd:	89 c7                	mov    %eax,%edi
  800bcf:	fc                   	cld    
  800bd0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bd9:	ff 75 10             	pushl  0x10(%ebp)
  800bdc:	ff 75 0c             	pushl  0xc(%ebp)
  800bdf:	ff 75 08             	pushl  0x8(%ebp)
  800be2:	e8 87 ff ff ff       	call   800b6e <memmove>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf4:	89 c6                	mov    %eax,%esi
  800bf6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf9:	eb 1a                	jmp    800c15 <memcmp+0x2c>
		if (*s1 != *s2)
  800bfb:	0f b6 08             	movzbl (%eax),%ecx
  800bfe:	0f b6 1a             	movzbl (%edx),%ebx
  800c01:	38 d9                	cmp    %bl,%cl
  800c03:	74 0a                	je     800c0f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c05:	0f b6 c1             	movzbl %cl,%eax
  800c08:	0f b6 db             	movzbl %bl,%ebx
  800c0b:	29 d8                	sub    %ebx,%eax
  800c0d:	eb 0f                	jmp    800c1e <memcmp+0x35>
		s1++, s2++;
  800c0f:	83 c0 01             	add    $0x1,%eax
  800c12:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c15:	39 f0                	cmp    %esi,%eax
  800c17:	75 e2                	jne    800bfb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	53                   	push   %ebx
  800c26:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c29:	89 c1                	mov    %eax,%ecx
  800c2b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c32:	eb 0a                	jmp    800c3e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c34:	0f b6 10             	movzbl (%eax),%edx
  800c37:	39 da                	cmp    %ebx,%edx
  800c39:	74 07                	je     800c42 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c3b:	83 c0 01             	add    $0x1,%eax
  800c3e:	39 c8                	cmp    %ecx,%eax
  800c40:	72 f2                	jb     800c34 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c42:	5b                   	pop    %ebx
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c51:	eb 03                	jmp    800c56 <strtol+0x11>
		s++;
  800c53:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c56:	0f b6 01             	movzbl (%ecx),%eax
  800c59:	3c 20                	cmp    $0x20,%al
  800c5b:	74 f6                	je     800c53 <strtol+0xe>
  800c5d:	3c 09                	cmp    $0x9,%al
  800c5f:	74 f2                	je     800c53 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c61:	3c 2b                	cmp    $0x2b,%al
  800c63:	75 0a                	jne    800c6f <strtol+0x2a>
		s++;
  800c65:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c68:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6d:	eb 11                	jmp    800c80 <strtol+0x3b>
  800c6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c74:	3c 2d                	cmp    $0x2d,%al
  800c76:	75 08                	jne    800c80 <strtol+0x3b>
		s++, neg = 1;
  800c78:	83 c1 01             	add    $0x1,%ecx
  800c7b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c80:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c86:	75 15                	jne    800c9d <strtol+0x58>
  800c88:	80 39 30             	cmpb   $0x30,(%ecx)
  800c8b:	75 10                	jne    800c9d <strtol+0x58>
  800c8d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c91:	75 7c                	jne    800d0f <strtol+0xca>
		s += 2, base = 16;
  800c93:	83 c1 02             	add    $0x2,%ecx
  800c96:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c9b:	eb 16                	jmp    800cb3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c9d:	85 db                	test   %ebx,%ebx
  800c9f:	75 12                	jne    800cb3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca9:	75 08                	jne    800cb3 <strtol+0x6e>
		s++, base = 8;
  800cab:	83 c1 01             	add    $0x1,%ecx
  800cae:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cbb:	0f b6 11             	movzbl (%ecx),%edx
  800cbe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cc1:	89 f3                	mov    %esi,%ebx
  800cc3:	80 fb 09             	cmp    $0x9,%bl
  800cc6:	77 08                	ja     800cd0 <strtol+0x8b>
			dig = *s - '0';
  800cc8:	0f be d2             	movsbl %dl,%edx
  800ccb:	83 ea 30             	sub    $0x30,%edx
  800cce:	eb 22                	jmp    800cf2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cd0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cd3:	89 f3                	mov    %esi,%ebx
  800cd5:	80 fb 19             	cmp    $0x19,%bl
  800cd8:	77 08                	ja     800ce2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cda:	0f be d2             	movsbl %dl,%edx
  800cdd:	83 ea 57             	sub    $0x57,%edx
  800ce0:	eb 10                	jmp    800cf2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ce2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ce5:	89 f3                	mov    %esi,%ebx
  800ce7:	80 fb 19             	cmp    $0x19,%bl
  800cea:	77 16                	ja     800d02 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cec:	0f be d2             	movsbl %dl,%edx
  800cef:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cf2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf5:	7d 0b                	jge    800d02 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cf7:	83 c1 01             	add    $0x1,%ecx
  800cfa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cfe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d00:	eb b9                	jmp    800cbb <strtol+0x76>

	if (endptr)
  800d02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d06:	74 0d                	je     800d15 <strtol+0xd0>
		*endptr = (char *) s;
  800d08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d0b:	89 0e                	mov    %ecx,(%esi)
  800d0d:	eb 06                	jmp    800d15 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d0f:	85 db                	test   %ebx,%ebx
  800d11:	74 98                	je     800cab <strtol+0x66>
  800d13:	eb 9e                	jmp    800cb3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d15:	89 c2                	mov    %eax,%edx
  800d17:	f7 da                	neg    %edx
  800d19:	85 ff                	test   %edi,%edi
  800d1b:	0f 45 c2             	cmovne %edx,%eax
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d29:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d30:	75 64                	jne    800d96 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800d32:	a1 04 20 80 00       	mov    0x802004,%eax
  800d37:	8b 40 48             	mov    0x48(%eax),%eax
  800d3a:	83 ec 04             	sub    $0x4,%esp
  800d3d:	6a 07                	push   $0x7
  800d3f:	68 00 f0 bf ee       	push   $0xeebff000
  800d44:	50                   	push   %eax
  800d45:	e8 1e f4 ff ff       	call   800168 <sys_page_alloc>
		if ( r != 0)
  800d4a:	83 c4 10             	add    $0x10,%esp
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	74 14                	je     800d65 <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	68 a0 13 80 00       	push   $0x8013a0
  800d59:	6a 24                	push   $0x24
  800d5b:	68 f0 13 80 00       	push   $0x8013f0
  800d60:	e8 19 f6 ff ff       	call   80037e <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  800d65:	a1 04 20 80 00       	mov    0x802004,%eax
  800d6a:	8b 40 48             	mov    0x48(%eax),%eax
  800d6d:	83 ec 08             	sub    $0x8,%esp
  800d70:	68 59 03 80 00       	push   $0x800359
  800d75:	50                   	push   %eax
  800d76:	e8 38 f5 ff ff       	call   8002b3 <sys_env_set_pgfault_upcall>
  800d7b:	83 c4 10             	add    $0x10,%esp
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	79 14                	jns    800d96 <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	68 cc 13 80 00       	push   $0x8013cc
  800d8a:	6a 27                	push   $0x27
  800d8c:	68 f0 13 80 00       	push   $0x8013f0
  800d91:	e8 e8 f5 ff ff       	call   80037e <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d9e:	c9                   	leave  
  800d9f:	c3                   	ret    

00800da0 <__udivdi3>:
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 1c             	sub    $0x1c,%esp
  800da7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800daf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800db7:	85 f6                	test   %esi,%esi
  800db9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dbd:	89 ca                	mov    %ecx,%edx
  800dbf:	89 f8                	mov    %edi,%eax
  800dc1:	75 3d                	jne    800e00 <__udivdi3+0x60>
  800dc3:	39 cf                	cmp    %ecx,%edi
  800dc5:	0f 87 c5 00 00 00    	ja     800e90 <__udivdi3+0xf0>
  800dcb:	85 ff                	test   %edi,%edi
  800dcd:	89 fd                	mov    %edi,%ebp
  800dcf:	75 0b                	jne    800ddc <__udivdi3+0x3c>
  800dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd6:	31 d2                	xor    %edx,%edx
  800dd8:	f7 f7                	div    %edi
  800dda:	89 c5                	mov    %eax,%ebp
  800ddc:	89 c8                	mov    %ecx,%eax
  800dde:	31 d2                	xor    %edx,%edx
  800de0:	f7 f5                	div    %ebp
  800de2:	89 c1                	mov    %eax,%ecx
  800de4:	89 d8                	mov    %ebx,%eax
  800de6:	89 cf                	mov    %ecx,%edi
  800de8:	f7 f5                	div    %ebp
  800dea:	89 c3                	mov    %eax,%ebx
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
  800e00:	39 ce                	cmp    %ecx,%esi
  800e02:	77 74                	ja     800e78 <__udivdi3+0xd8>
  800e04:	0f bd fe             	bsr    %esi,%edi
  800e07:	83 f7 1f             	xor    $0x1f,%edi
  800e0a:	0f 84 98 00 00 00    	je     800ea8 <__udivdi3+0x108>
  800e10:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	89 c5                	mov    %eax,%ebp
  800e19:	29 fb                	sub    %edi,%ebx
  800e1b:	d3 e6                	shl    %cl,%esi
  800e1d:	89 d9                	mov    %ebx,%ecx
  800e1f:	d3 ed                	shr    %cl,%ebp
  800e21:	89 f9                	mov    %edi,%ecx
  800e23:	d3 e0                	shl    %cl,%eax
  800e25:	09 ee                	or     %ebp,%esi
  800e27:	89 d9                	mov    %ebx,%ecx
  800e29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2d:	89 d5                	mov    %edx,%ebp
  800e2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e33:	d3 ed                	shr    %cl,%ebp
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	d3 e2                	shl    %cl,%edx
  800e39:	89 d9                	mov    %ebx,%ecx
  800e3b:	d3 e8                	shr    %cl,%eax
  800e3d:	09 c2                	or     %eax,%edx
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	89 ea                	mov    %ebp,%edx
  800e43:	f7 f6                	div    %esi
  800e45:	89 d5                	mov    %edx,%ebp
  800e47:	89 c3                	mov    %eax,%ebx
  800e49:	f7 64 24 0c          	mull   0xc(%esp)
  800e4d:	39 d5                	cmp    %edx,%ebp
  800e4f:	72 10                	jb     800e61 <__udivdi3+0xc1>
  800e51:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e6                	shl    %cl,%esi
  800e59:	39 c6                	cmp    %eax,%esi
  800e5b:	73 07                	jae    800e64 <__udivdi3+0xc4>
  800e5d:	39 d5                	cmp    %edx,%ebp
  800e5f:	75 03                	jne    800e64 <__udivdi3+0xc4>
  800e61:	83 eb 01             	sub    $0x1,%ebx
  800e64:	31 ff                	xor    %edi,%edi
  800e66:	89 d8                	mov    %ebx,%eax
  800e68:	89 fa                	mov    %edi,%edx
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e78:	31 ff                	xor    %edi,%edi
  800e7a:	31 db                	xor    %ebx,%ebx
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	89 fa                	mov    %edi,%edx
  800e80:	83 c4 1c             	add    $0x1c,%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 d8                	mov    %ebx,%eax
  800e92:	f7 f7                	div    %edi
  800e94:	31 ff                	xor    %edi,%edi
  800e96:	89 c3                	mov    %eax,%ebx
  800e98:	89 d8                	mov    %ebx,%eax
  800e9a:	89 fa                	mov    %edi,%edx
  800e9c:	83 c4 1c             	add    $0x1c,%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	39 ce                	cmp    %ecx,%esi
  800eaa:	72 0c                	jb     800eb8 <__udivdi3+0x118>
  800eac:	31 db                	xor    %ebx,%ebx
  800eae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800eb2:	0f 87 34 ff ff ff    	ja     800dec <__udivdi3+0x4c>
  800eb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ebd:	e9 2a ff ff ff       	jmp    800dec <__udivdi3+0x4c>
  800ec2:	66 90                	xchg   %ax,%ax
  800ec4:	66 90                	xchg   %ax,%ax
  800ec6:	66 90                	xchg   %ax,%ax
  800ec8:	66 90                	xchg   %ax,%ax
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__umoddi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 1c             	sub    $0x1c,%esp
  800ed7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800edb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800edf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ee7:	85 d2                	test   %edx,%edx
  800ee9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ef1:	89 f3                	mov    %esi,%ebx
  800ef3:	89 3c 24             	mov    %edi,(%esp)
  800ef6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efa:	75 1c                	jne    800f18 <__umoddi3+0x48>
  800efc:	39 f7                	cmp    %esi,%edi
  800efe:	76 50                	jbe    800f50 <__umoddi3+0x80>
  800f00:	89 c8                	mov    %ecx,%eax
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	f7 f7                	div    %edi
  800f06:	89 d0                	mov    %edx,%eax
  800f08:	31 d2                	xor    %edx,%edx
  800f0a:	83 c4 1c             	add    $0x1c,%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    
  800f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	89 d0                	mov    %edx,%eax
  800f1c:	77 52                	ja     800f70 <__umoddi3+0xa0>
  800f1e:	0f bd ea             	bsr    %edx,%ebp
  800f21:	83 f5 1f             	xor    $0x1f,%ebp
  800f24:	75 5a                	jne    800f80 <__umoddi3+0xb0>
  800f26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f2a:	0f 82 e0 00 00 00    	jb     801010 <__umoddi3+0x140>
  800f30:	39 0c 24             	cmp    %ecx,(%esp)
  800f33:	0f 86 d7 00 00 00    	jbe    801010 <__umoddi3+0x140>
  800f39:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f41:	83 c4 1c             	add    $0x1c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	85 ff                	test   %edi,%edi
  800f52:	89 fd                	mov    %edi,%ebp
  800f54:	75 0b                	jne    800f61 <__umoddi3+0x91>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f7                	div    %edi
  800f5f:	89 c5                	mov    %eax,%ebp
  800f61:	89 f0                	mov    %esi,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	f7 f5                	div    %ebp
  800f67:	89 c8                	mov    %ecx,%eax
  800f69:	f7 f5                	div    %ebp
  800f6b:	89 d0                	mov    %edx,%eax
  800f6d:	eb 99                	jmp    800f08 <__umoddi3+0x38>
  800f6f:	90                   	nop
  800f70:	89 c8                	mov    %ecx,%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	83 c4 1c             	add    $0x1c,%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    
  800f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f80:	8b 34 24             	mov    (%esp),%esi
  800f83:	bf 20 00 00 00       	mov    $0x20,%edi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	29 ef                	sub    %ebp,%edi
  800f8c:	d3 e0                	shl    %cl,%eax
  800f8e:	89 f9                	mov    %edi,%ecx
  800f90:	89 f2                	mov    %esi,%edx
  800f92:	d3 ea                	shr    %cl,%edx
  800f94:	89 e9                	mov    %ebp,%ecx
  800f96:	09 c2                	or     %eax,%edx
  800f98:	89 d8                	mov    %ebx,%eax
  800f9a:	89 14 24             	mov    %edx,(%esp)
  800f9d:	89 f2                	mov    %esi,%edx
  800f9f:	d3 e2                	shl    %cl,%edx
  800fa1:	89 f9                	mov    %edi,%ecx
  800fa3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fab:	d3 e8                	shr    %cl,%eax
  800fad:	89 e9                	mov    %ebp,%ecx
  800faf:	89 c6                	mov    %eax,%esi
  800fb1:	d3 e3                	shl    %cl,%ebx
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	89 d0                	mov    %edx,%eax
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	09 d8                	or     %ebx,%eax
  800fbd:	89 d3                	mov    %edx,%ebx
  800fbf:	89 f2                	mov    %esi,%edx
  800fc1:	f7 34 24             	divl   (%esp)
  800fc4:	89 d6                	mov    %edx,%esi
  800fc6:	d3 e3                	shl    %cl,%ebx
  800fc8:	f7 64 24 04          	mull   0x4(%esp)
  800fcc:	39 d6                	cmp    %edx,%esi
  800fce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fd2:	89 d1                	mov    %edx,%ecx
  800fd4:	89 c3                	mov    %eax,%ebx
  800fd6:	72 08                	jb     800fe0 <__umoddi3+0x110>
  800fd8:	75 11                	jne    800feb <__umoddi3+0x11b>
  800fda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fde:	73 0b                	jae    800feb <__umoddi3+0x11b>
  800fe0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fe4:	1b 14 24             	sbb    (%esp),%edx
  800fe7:	89 d1                	mov    %edx,%ecx
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fef:	29 da                	sub    %ebx,%edx
  800ff1:	19 ce                	sbb    %ecx,%esi
  800ff3:	89 f9                	mov    %edi,%ecx
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	d3 e0                	shl    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	d3 ea                	shr    %cl,%edx
  800ffd:	89 e9                	mov    %ebp,%ecx
  800fff:	d3 ee                	shr    %cl,%esi
  801001:	09 d0                	or     %edx,%eax
  801003:	89 f2                	mov    %esi,%edx
  801005:	83 c4 1c             	add    $0x1c,%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	29 f9                	sub    %edi,%ecx
  801012:	19 d6                	sbb    %edx,%esi
  801014:	89 74 24 04          	mov    %esi,0x4(%esp)
  801018:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80101c:	e9 18 ff ff ff       	jmp    800f39 <__umoddi3+0x69>
