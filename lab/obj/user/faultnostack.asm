
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
  800039:	68 78 03 80 00       	push   $0x800378
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
  800111:	68 6a 10 80 00       	push   $0x80106a
  800116:	6a 23                	push   $0x23
  800118:	68 87 10 80 00       	push   $0x801087
  80011d:	e8 7b 02 00 00       	call   80039d <_panic>

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
  800192:	68 6a 10 80 00       	push   $0x80106a
  800197:	6a 23                	push   $0x23
  800199:	68 87 10 80 00       	push   $0x801087
  80019e:	e8 fa 01 00 00       	call   80039d <_panic>

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
  8001d4:	68 6a 10 80 00       	push   $0x80106a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 87 10 80 00       	push   $0x801087
  8001e0:	e8 b8 01 00 00       	call   80039d <_panic>

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
  800216:	68 6a 10 80 00       	push   $0x80106a
  80021b:	6a 23                	push   $0x23
  80021d:	68 87 10 80 00       	push   $0x801087
  800222:	e8 76 01 00 00       	call   80039d <_panic>

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
  800258:	68 6a 10 80 00       	push   $0x80106a
  80025d:	6a 23                	push   $0x23
  80025f:	68 87 10 80 00       	push   $0x801087
  800264:	e8 34 01 00 00       	call   80039d <_panic>

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
  80029a:	68 6a 10 80 00       	push   $0x80106a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 87 10 80 00       	push   $0x801087
  8002a6:	e8 f2 00 00 00       	call   80039d <_panic>

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
  8002dc:	68 6a 10 80 00       	push   $0x80106a
  8002e1:	6a 23                	push   $0x23
  8002e3:	68 87 10 80 00       	push   $0x801087
  8002e8:	e8 b0 00 00 00       	call   80039d <_panic>

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
  800340:	68 6a 10 80 00       	push   $0x80106a
  800345:	6a 23                	push   $0x23
  800347:	68 87 10 80 00       	push   $0x801087
  80034c:	e8 4c 00 00 00       	call   80039d <_panic>

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

00800359 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	57                   	push   %edi
  80035d:	56                   	push   %esi
  80035e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035f:	ba 00 00 00 00       	mov    $0x0,%edx
  800364:	b8 0e 00 00 00       	mov    $0xe,%eax
  800369:	89 d1                	mov    %edx,%ecx
  80036b:	89 d3                	mov    %edx,%ebx
  80036d:	89 d7                	mov    %edx,%edi
  80036f:	89 d6                	mov    %edx,%esi
  800371:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800378:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800379:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80037e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800380:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  800383:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  800387:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  800389:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  80038d:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  80038e:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  800391:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  800393:	83 c4 08             	add    $0x8,%esp
popal
  800396:	61                   	popa   
addl $0x4, %esp
  800397:	83 c4 04             	add    $0x4,%esp
popfl
  80039a:	9d                   	popf   
popl %esp
  80039b:	5c                   	pop    %esp
ret
  80039c:	c3                   	ret    

0080039d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	56                   	push   %esi
  8003a1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8003a2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003ab:	e8 7a fd ff ff       	call   80012a <sys_getenvid>
  8003b0:	83 ec 0c             	sub    $0xc,%esp
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	56                   	push   %esi
  8003ba:	50                   	push   %eax
  8003bb:	68 98 10 80 00       	push   $0x801098
  8003c0:	e8 b1 00 00 00       	call   800476 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c5:	83 c4 18             	add    $0x18,%esp
  8003c8:	53                   	push   %ebx
  8003c9:	ff 75 10             	pushl  0x10(%ebp)
  8003cc:	e8 54 00 00 00       	call   800425 <vcprintf>
	cprintf("\n");
  8003d1:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  8003d8:	e8 99 00 00 00       	call   800476 <cprintf>
  8003dd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e0:	cc                   	int3   
  8003e1:	eb fd                	jmp    8003e0 <_panic+0x43>

008003e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	53                   	push   %ebx
  8003e7:	83 ec 04             	sub    $0x4,%esp
  8003ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ed:	8b 13                	mov    (%ebx),%edx
  8003ef:	8d 42 01             	lea    0x1(%edx),%eax
  8003f2:	89 03                	mov    %eax,(%ebx)
  8003f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003fb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800400:	75 1a                	jne    80041c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	68 ff 00 00 00       	push   $0xff
  80040a:	8d 43 08             	lea    0x8(%ebx),%eax
  80040d:	50                   	push   %eax
  80040e:	e8 99 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  800413:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800419:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80041c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800423:	c9                   	leave  
  800424:	c3                   	ret    

00800425 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80042e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800435:	00 00 00 
	b.cnt = 0;
  800438:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80043f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800442:	ff 75 0c             	pushl  0xc(%ebp)
  800445:	ff 75 08             	pushl  0x8(%ebp)
  800448:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80044e:	50                   	push   %eax
  80044f:	68 e3 03 80 00       	push   $0x8003e3
  800454:	e8 54 01 00 00       	call   8005ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800459:	83 c4 08             	add    $0x8,%esp
  80045c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800462:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800468:	50                   	push   %eax
  800469:	e8 3e fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80046e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80047c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80047f:	50                   	push   %eax
  800480:	ff 75 08             	pushl  0x8(%ebp)
  800483:	e8 9d ff ff ff       	call   800425 <vcprintf>
	va_end(ap);

	return cnt;
}
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	57                   	push   %edi
  80048e:	56                   	push   %esi
  80048f:	53                   	push   %ebx
  800490:	83 ec 1c             	sub    $0x1c,%esp
  800493:	89 c7                	mov    %eax,%edi
  800495:	89 d6                	mov    %edx,%esi
  800497:	8b 45 08             	mov    0x8(%ebp),%eax
  80049a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8004a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004ae:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004b1:	39 d3                	cmp    %edx,%ebx
  8004b3:	72 05                	jb     8004ba <printnum+0x30>
  8004b5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004b8:	77 45                	ja     8004ff <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004ba:	83 ec 0c             	sub    $0xc,%esp
  8004bd:	ff 75 18             	pushl  0x18(%ebp)
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8004c6:	53                   	push   %ebx
  8004c7:	ff 75 10             	pushl  0x10(%ebp)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d9:	e8 e2 08 00 00       	call   800dc0 <__udivdi3>
  8004de:	83 c4 18             	add    $0x18,%esp
  8004e1:	52                   	push   %edx
  8004e2:	50                   	push   %eax
  8004e3:	89 f2                	mov    %esi,%edx
  8004e5:	89 f8                	mov    %edi,%eax
  8004e7:	e8 9e ff ff ff       	call   80048a <printnum>
  8004ec:	83 c4 20             	add    $0x20,%esp
  8004ef:	eb 18                	jmp    800509 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	56                   	push   %esi
  8004f5:	ff 75 18             	pushl  0x18(%ebp)
  8004f8:	ff d7                	call   *%edi
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	eb 03                	jmp    800502 <printnum+0x78>
  8004ff:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800502:	83 eb 01             	sub    $0x1,%ebx
  800505:	85 db                	test   %ebx,%ebx
  800507:	7f e8                	jg     8004f1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	56                   	push   %esi
  80050d:	83 ec 04             	sub    $0x4,%esp
  800510:	ff 75 e4             	pushl  -0x1c(%ebp)
  800513:	ff 75 e0             	pushl  -0x20(%ebp)
  800516:	ff 75 dc             	pushl  -0x24(%ebp)
  800519:	ff 75 d8             	pushl  -0x28(%ebp)
  80051c:	e8 cf 09 00 00       	call   800ef0 <__umoddi3>
  800521:	83 c4 14             	add    $0x14,%esp
  800524:	0f be 80 bd 10 80 00 	movsbl 0x8010bd(%eax),%eax
  80052b:	50                   	push   %eax
  80052c:	ff d7                	call   *%edi
}
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800534:	5b                   	pop    %ebx
  800535:	5e                   	pop    %esi
  800536:	5f                   	pop    %edi
  800537:	5d                   	pop    %ebp
  800538:	c3                   	ret    

00800539 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80053c:	83 fa 01             	cmp    $0x1,%edx
  80053f:	7e 0e                	jle    80054f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800541:	8b 10                	mov    (%eax),%edx
  800543:	8d 4a 08             	lea    0x8(%edx),%ecx
  800546:	89 08                	mov    %ecx,(%eax)
  800548:	8b 02                	mov    (%edx),%eax
  80054a:	8b 52 04             	mov    0x4(%edx),%edx
  80054d:	eb 22                	jmp    800571 <getuint+0x38>
	else if (lflag)
  80054f:	85 d2                	test   %edx,%edx
  800551:	74 10                	je     800563 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800553:	8b 10                	mov    (%eax),%edx
  800555:	8d 4a 04             	lea    0x4(%edx),%ecx
  800558:	89 08                	mov    %ecx,(%eax)
  80055a:	8b 02                	mov    (%edx),%eax
  80055c:	ba 00 00 00 00       	mov    $0x0,%edx
  800561:	eb 0e                	jmp    800571 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800563:	8b 10                	mov    (%eax),%edx
  800565:	8d 4a 04             	lea    0x4(%edx),%ecx
  800568:	89 08                	mov    %ecx,(%eax)
  80056a:	8b 02                	mov    (%edx),%eax
  80056c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800571:	5d                   	pop    %ebp
  800572:	c3                   	ret    

00800573 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800573:	55                   	push   %ebp
  800574:	89 e5                	mov    %esp,%ebp
  800576:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800579:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80057d:	8b 10                	mov    (%eax),%edx
  80057f:	3b 50 04             	cmp    0x4(%eax),%edx
  800582:	73 0a                	jae    80058e <sprintputch+0x1b>
		*b->buf++ = ch;
  800584:	8d 4a 01             	lea    0x1(%edx),%ecx
  800587:	89 08                	mov    %ecx,(%eax)
  800589:	8b 45 08             	mov    0x8(%ebp),%eax
  80058c:	88 02                	mov    %al,(%edx)
}
  80058e:	5d                   	pop    %ebp
  80058f:	c3                   	ret    

00800590 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800599:	50                   	push   %eax
  80059a:	ff 75 10             	pushl  0x10(%ebp)
  80059d:	ff 75 0c             	pushl  0xc(%ebp)
  8005a0:	ff 75 08             	pushl  0x8(%ebp)
  8005a3:	e8 05 00 00 00       	call   8005ad <vprintfmt>
	va_end(ap);
}
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	c9                   	leave  
  8005ac:	c3                   	ret    

008005ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ad:	55                   	push   %ebp
  8005ae:	89 e5                	mov    %esp,%ebp
  8005b0:	57                   	push   %edi
  8005b1:	56                   	push   %esi
  8005b2:	53                   	push   %ebx
  8005b3:	83 ec 2c             	sub    $0x2c,%esp
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005bf:	eb 12                	jmp    8005d3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005c1:	85 c0                	test   %eax,%eax
  8005c3:	0f 84 89 03 00 00    	je     800952 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	50                   	push   %eax
  8005ce:	ff d6                	call   *%esi
  8005d0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d3:	83 c7 01             	add    $0x1,%edi
  8005d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005da:	83 f8 25             	cmp    $0x25,%eax
  8005dd:	75 e2                	jne    8005c1 <vprintfmt+0x14>
  8005df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fd:	eb 07                	jmp    800606 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800602:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8d 47 01             	lea    0x1(%edi),%eax
  800609:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80060c:	0f b6 07             	movzbl (%edi),%eax
  80060f:	0f b6 c8             	movzbl %al,%ecx
  800612:	83 e8 23             	sub    $0x23,%eax
  800615:	3c 55                	cmp    $0x55,%al
  800617:	0f 87 1a 03 00 00    	ja     800937 <vprintfmt+0x38a>
  80061d:	0f b6 c0             	movzbl %al,%eax
  800620:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80062a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80062e:	eb d6                	jmp    800606 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800633:	b8 00 00 00 00       	mov    $0x0,%eax
  800638:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80063b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80063e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800642:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800645:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800648:	83 fa 09             	cmp    $0x9,%edx
  80064b:	77 39                	ja     800686 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80064d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800650:	eb e9                	jmp    80063b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 48 04             	lea    0x4(%eax),%ecx
  800658:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80065b:	8b 00                	mov    (%eax),%eax
  80065d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800660:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800663:	eb 27                	jmp    80068c <vprintfmt+0xdf>
  800665:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800668:	85 c0                	test   %eax,%eax
  80066a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066f:	0f 49 c8             	cmovns %eax,%ecx
  800672:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800678:	eb 8c                	jmp    800606 <vprintfmt+0x59>
  80067a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80067d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800684:	eb 80                	jmp    800606 <vprintfmt+0x59>
  800686:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800689:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80068c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800690:	0f 89 70 ff ff ff    	jns    800606 <vprintfmt+0x59>
				width = precision, precision = -1;
  800696:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800699:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80069c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006a3:	e9 5e ff ff ff       	jmp    800606 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006a8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006ae:	e9 53 ff ff ff       	jmp    800606 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 50 04             	lea    0x4(%eax),%edx
  8006b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	ff 30                	pushl  (%eax)
  8006c2:	ff d6                	call   *%esi
			break;
  8006c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006ca:	e9 04 ff ff ff       	jmp    8005d3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 04             	lea    0x4(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 00                	mov    (%eax),%eax
  8006da:	99                   	cltd   
  8006db:	31 d0                	xor    %edx,%eax
  8006dd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006df:	83 f8 0f             	cmp    $0xf,%eax
  8006e2:	7f 0b                	jg     8006ef <vprintfmt+0x142>
  8006e4:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	75 18                	jne    800707 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006ef:	50                   	push   %eax
  8006f0:	68 d5 10 80 00       	push   $0x8010d5
  8006f5:	53                   	push   %ebx
  8006f6:	56                   	push   %esi
  8006f7:	e8 94 fe ff ff       	call   800590 <printfmt>
  8006fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800702:	e9 cc fe ff ff       	jmp    8005d3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800707:	52                   	push   %edx
  800708:	68 de 10 80 00       	push   $0x8010de
  80070d:	53                   	push   %ebx
  80070e:	56                   	push   %esi
  80070f:	e8 7c fe ff ff       	call   800590 <printfmt>
  800714:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071a:	e9 b4 fe ff ff       	jmp    8005d3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8d 50 04             	lea    0x4(%eax),%edx
  800725:	89 55 14             	mov    %edx,0x14(%ebp)
  800728:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80072a:	85 ff                	test   %edi,%edi
  80072c:	b8 ce 10 80 00       	mov    $0x8010ce,%eax
  800731:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800734:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800738:	0f 8e 94 00 00 00    	jle    8007d2 <vprintfmt+0x225>
  80073e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800742:	0f 84 98 00 00 00    	je     8007e0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	ff 75 d0             	pushl  -0x30(%ebp)
  80074e:	57                   	push   %edi
  80074f:	e8 86 02 00 00       	call   8009da <strnlen>
  800754:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800757:	29 c1                	sub    %eax,%ecx
  800759:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80075c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80075f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800763:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800766:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800769:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80076b:	eb 0f                	jmp    80077c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	ff 75 e0             	pushl  -0x20(%ebp)
  800774:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800776:	83 ef 01             	sub    $0x1,%edi
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	85 ff                	test   %edi,%edi
  80077e:	7f ed                	jg     80076d <vprintfmt+0x1c0>
  800780:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800783:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800786:	85 c9                	test   %ecx,%ecx
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
  80078d:	0f 49 c1             	cmovns %ecx,%eax
  800790:	29 c1                	sub    %eax,%ecx
  800792:	89 75 08             	mov    %esi,0x8(%ebp)
  800795:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800798:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80079b:	89 cb                	mov    %ecx,%ebx
  80079d:	eb 4d                	jmp    8007ec <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80079f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007a3:	74 1b                	je     8007c0 <vprintfmt+0x213>
  8007a5:	0f be c0             	movsbl %al,%eax
  8007a8:	83 e8 20             	sub    $0x20,%eax
  8007ab:	83 f8 5e             	cmp    $0x5e,%eax
  8007ae:	76 10                	jbe    8007c0 <vprintfmt+0x213>
					putch('?', putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	6a 3f                	push   $0x3f
  8007b8:	ff 55 08             	call   *0x8(%ebp)
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb 0d                	jmp    8007cd <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	ff 75 0c             	pushl  0xc(%ebp)
  8007c6:	52                   	push   %edx
  8007c7:	ff 55 08             	call   *0x8(%ebp)
  8007ca:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cd:	83 eb 01             	sub    $0x1,%ebx
  8007d0:	eb 1a                	jmp    8007ec <vprintfmt+0x23f>
  8007d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8007d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007de:	eb 0c                	jmp    8007ec <vprintfmt+0x23f>
  8007e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8007e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007ec:	83 c7 01             	add    $0x1,%edi
  8007ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007f3:	0f be d0             	movsbl %al,%edx
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 23                	je     80081d <vprintfmt+0x270>
  8007fa:	85 f6                	test   %esi,%esi
  8007fc:	78 a1                	js     80079f <vprintfmt+0x1f2>
  8007fe:	83 ee 01             	sub    $0x1,%esi
  800801:	79 9c                	jns    80079f <vprintfmt+0x1f2>
  800803:	89 df                	mov    %ebx,%edi
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080b:	eb 18                	jmp    800825 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	53                   	push   %ebx
  800811:	6a 20                	push   $0x20
  800813:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800815:	83 ef 01             	sub    $0x1,%edi
  800818:	83 c4 10             	add    $0x10,%esp
  80081b:	eb 08                	jmp    800825 <vprintfmt+0x278>
  80081d:	89 df                	mov    %ebx,%edi
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800825:	85 ff                	test   %edi,%edi
  800827:	7f e4                	jg     80080d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800829:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80082c:	e9 a2 fd ff ff       	jmp    8005d3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800831:	83 fa 01             	cmp    $0x1,%edx
  800834:	7e 16                	jle    80084c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	8d 50 08             	lea    0x8(%eax),%edx
  80083c:	89 55 14             	mov    %edx,0x14(%ebp)
  80083f:	8b 50 04             	mov    0x4(%eax),%edx
  800842:	8b 00                	mov    (%eax),%eax
  800844:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800847:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80084a:	eb 32                	jmp    80087e <vprintfmt+0x2d1>
	else if (lflag)
  80084c:	85 d2                	test   %edx,%edx
  80084e:	74 18                	je     800868 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 00                	mov    (%eax),%eax
  80085b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80085e:	89 c1                	mov    %eax,%ecx
  800860:	c1 f9 1f             	sar    $0x1f,%ecx
  800863:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800866:	eb 16                	jmp    80087e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 04             	lea    0x4(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)
  800871:	8b 00                	mov    (%eax),%eax
  800873:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800876:	89 c1                	mov    %eax,%ecx
  800878:	c1 f9 1f             	sar    $0x1f,%ecx
  80087b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80087e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800881:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800884:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800889:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80088d:	79 74                	jns    800903 <vprintfmt+0x356>
				putch('-', putdat);
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	53                   	push   %ebx
  800893:	6a 2d                	push   $0x2d
  800895:	ff d6                	call   *%esi
				num = -(long long) num;
  800897:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80089a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80089d:	f7 d8                	neg    %eax
  80089f:	83 d2 00             	adc    $0x0,%edx
  8008a2:	f7 da                	neg    %edx
  8008a4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8008a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008ac:	eb 55                	jmp    800903 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b1:	e8 83 fc ff ff       	call   800539 <getuint>
			base = 10;
  8008b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8008bb:	eb 46                	jmp    800903 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8008bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c0:	e8 74 fc ff ff       	call   800539 <getuint>
			base = 8;
  8008c5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8008ca:	eb 37                	jmp    800903 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	53                   	push   %ebx
  8008d0:	6a 30                	push   $0x30
  8008d2:	ff d6                	call   *%esi
			putch('x', putdat);
  8008d4:	83 c4 08             	add    $0x8,%esp
  8008d7:	53                   	push   %ebx
  8008d8:	6a 78                	push   $0x78
  8008da:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008df:	8d 50 04             	lea    0x4(%eax),%edx
  8008e2:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008e5:	8b 00                	mov    (%eax),%eax
  8008e7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008ef:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008f4:	eb 0d                	jmp    800903 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f9:	e8 3b fc ff ff       	call   800539 <getuint>
			base = 16;
  8008fe:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800903:	83 ec 0c             	sub    $0xc,%esp
  800906:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80090a:	57                   	push   %edi
  80090b:	ff 75 e0             	pushl  -0x20(%ebp)
  80090e:	51                   	push   %ecx
  80090f:	52                   	push   %edx
  800910:	50                   	push   %eax
  800911:	89 da                	mov    %ebx,%edx
  800913:	89 f0                	mov    %esi,%eax
  800915:	e8 70 fb ff ff       	call   80048a <printnum>
			break;
  80091a:	83 c4 20             	add    $0x20,%esp
  80091d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800920:	e9 ae fc ff ff       	jmp    8005d3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800925:	83 ec 08             	sub    $0x8,%esp
  800928:	53                   	push   %ebx
  800929:	51                   	push   %ecx
  80092a:	ff d6                	call   *%esi
			break;
  80092c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800932:	e9 9c fc ff ff       	jmp    8005d3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800937:	83 ec 08             	sub    $0x8,%esp
  80093a:	53                   	push   %ebx
  80093b:	6a 25                	push   $0x25
  80093d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80093f:	83 c4 10             	add    $0x10,%esp
  800942:	eb 03                	jmp    800947 <vprintfmt+0x39a>
  800944:	83 ef 01             	sub    $0x1,%edi
  800947:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80094b:	75 f7                	jne    800944 <vprintfmt+0x397>
  80094d:	e9 81 fc ff ff       	jmp    8005d3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800952:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 18             	sub    $0x18,%esp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800966:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800969:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80096d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800970:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800977:	85 c0                	test   %eax,%eax
  800979:	74 26                	je     8009a1 <vsnprintf+0x47>
  80097b:	85 d2                	test   %edx,%edx
  80097d:	7e 22                	jle    8009a1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80097f:	ff 75 14             	pushl  0x14(%ebp)
  800982:	ff 75 10             	pushl  0x10(%ebp)
  800985:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800988:	50                   	push   %eax
  800989:	68 73 05 80 00       	push   $0x800573
  80098e:	e8 1a fc ff ff       	call   8005ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800993:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800996:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	83 c4 10             	add    $0x10,%esp
  80099f:	eb 05                	jmp    8009a6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b1:	50                   	push   %eax
  8009b2:	ff 75 10             	pushl  0x10(%ebp)
  8009b5:	ff 75 0c             	pushl  0xc(%ebp)
  8009b8:	ff 75 08             	pushl  0x8(%ebp)
  8009bb:	e8 9a ff ff ff       	call   80095a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cd:	eb 03                	jmp    8009d2 <strlen+0x10>
		n++;
  8009cf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d6:	75 f7                	jne    8009cf <strlen+0xd>
		n++;
	return n;
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e8:	eb 03                	jmp    8009ed <strnlen+0x13>
		n++;
  8009ea:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ed:	39 c2                	cmp    %eax,%edx
  8009ef:	74 08                	je     8009f9 <strnlen+0x1f>
  8009f1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009f5:	75 f3                	jne    8009ea <strnlen+0x10>
  8009f7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a05:	89 c2                	mov    %eax,%edx
  800a07:	83 c2 01             	add    $0x1,%edx
  800a0a:	83 c1 01             	add    $0x1,%ecx
  800a0d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a11:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a14:	84 db                	test   %bl,%bl
  800a16:	75 ef                	jne    800a07 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a18:	5b                   	pop    %ebx
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a22:	53                   	push   %ebx
  800a23:	e8 9a ff ff ff       	call   8009c2 <strlen>
  800a28:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	01 d8                	add    %ebx,%eax
  800a30:	50                   	push   %eax
  800a31:	e8 c5 ff ff ff       	call   8009fb <strcpy>
	return dst;
}
  800a36:	89 d8                	mov    %ebx,%eax
  800a38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 75 08             	mov    0x8(%ebp),%esi
  800a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a4d:	89 f2                	mov    %esi,%edx
  800a4f:	eb 0f                	jmp    800a60 <strncpy+0x23>
		*dst++ = *src;
  800a51:	83 c2 01             	add    $0x1,%edx
  800a54:	0f b6 01             	movzbl (%ecx),%eax
  800a57:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a5a:	80 39 01             	cmpb   $0x1,(%ecx)
  800a5d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a60:	39 da                	cmp    %ebx,%edx
  800a62:	75 ed                	jne    800a51 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a64:	89 f0                	mov    %esi,%eax
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a75:	8b 55 10             	mov    0x10(%ebp),%edx
  800a78:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a7a:	85 d2                	test   %edx,%edx
  800a7c:	74 21                	je     800a9f <strlcpy+0x35>
  800a7e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a82:	89 f2                	mov    %esi,%edx
  800a84:	eb 09                	jmp    800a8f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a86:	83 c2 01             	add    $0x1,%edx
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a8f:	39 c2                	cmp    %eax,%edx
  800a91:	74 09                	je     800a9c <strlcpy+0x32>
  800a93:	0f b6 19             	movzbl (%ecx),%ebx
  800a96:	84 db                	test   %bl,%bl
  800a98:	75 ec                	jne    800a86 <strlcpy+0x1c>
  800a9a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a9c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a9f:	29 f0                	sub    %esi,%eax
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aae:	eb 06                	jmp    800ab6 <strcmp+0x11>
		p++, q++;
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	84 c0                	test   %al,%al
  800abb:	74 04                	je     800ac1 <strcmp+0x1c>
  800abd:	3a 02                	cmp    (%edx),%al
  800abf:	74 ef                	je     800ab0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac1:	0f b6 c0             	movzbl %al,%eax
  800ac4:	0f b6 12             	movzbl (%edx),%edx
  800ac7:	29 d0                	sub    %edx,%eax
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ada:	eb 06                	jmp    800ae2 <strncmp+0x17>
		n--, p++, q++;
  800adc:	83 c0 01             	add    $0x1,%eax
  800adf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ae2:	39 d8                	cmp    %ebx,%eax
  800ae4:	74 15                	je     800afb <strncmp+0x30>
  800ae6:	0f b6 08             	movzbl (%eax),%ecx
  800ae9:	84 c9                	test   %cl,%cl
  800aeb:	74 04                	je     800af1 <strncmp+0x26>
  800aed:	3a 0a                	cmp    (%edx),%cl
  800aef:	74 eb                	je     800adc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af1:	0f b6 00             	movzbl (%eax),%eax
  800af4:	0f b6 12             	movzbl (%edx),%edx
  800af7:	29 d0                	sub    %edx,%eax
  800af9:	eb 05                	jmp    800b00 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b0d:	eb 07                	jmp    800b16 <strchr+0x13>
		if (*s == c)
  800b0f:	38 ca                	cmp    %cl,%dl
  800b11:	74 0f                	je     800b22 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b13:	83 c0 01             	add    $0x1,%eax
  800b16:	0f b6 10             	movzbl (%eax),%edx
  800b19:	84 d2                	test   %dl,%dl
  800b1b:	75 f2                	jne    800b0f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b2e:	eb 03                	jmp    800b33 <strfind+0xf>
  800b30:	83 c0 01             	add    $0x1,%eax
  800b33:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b36:	38 ca                	cmp    %cl,%dl
  800b38:	74 04                	je     800b3e <strfind+0x1a>
  800b3a:	84 d2                	test   %dl,%dl
  800b3c:	75 f2                	jne    800b30 <strfind+0xc>
			break;
	return (char *) s;
}
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b49:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b4c:	85 c9                	test   %ecx,%ecx
  800b4e:	74 36                	je     800b86 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b50:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b56:	75 28                	jne    800b80 <memset+0x40>
  800b58:	f6 c1 03             	test   $0x3,%cl
  800b5b:	75 23                	jne    800b80 <memset+0x40>
		c &= 0xFF;
  800b5d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	c1 e3 08             	shl    $0x8,%ebx
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	c1 e6 18             	shl    $0x18,%esi
  800b6b:	89 d0                	mov    %edx,%eax
  800b6d:	c1 e0 10             	shl    $0x10,%eax
  800b70:	09 f0                	or     %esi,%eax
  800b72:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b74:	89 d8                	mov    %ebx,%eax
  800b76:	09 d0                	or     %edx,%eax
  800b78:	c1 e9 02             	shr    $0x2,%ecx
  800b7b:	fc                   	cld    
  800b7c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b7e:	eb 06                	jmp    800b86 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	fc                   	cld    
  800b84:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b86:	89 f8                	mov    %edi,%eax
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b98:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b9b:	39 c6                	cmp    %eax,%esi
  800b9d:	73 35                	jae    800bd4 <memmove+0x47>
  800b9f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba2:	39 d0                	cmp    %edx,%eax
  800ba4:	73 2e                	jae    800bd4 <memmove+0x47>
		s += n;
		d += n;
  800ba6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	09 fe                	or     %edi,%esi
  800bad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb3:	75 13                	jne    800bc8 <memmove+0x3b>
  800bb5:	f6 c1 03             	test   $0x3,%cl
  800bb8:	75 0e                	jne    800bc8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bba:	83 ef 04             	sub    $0x4,%edi
  800bbd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc0:	c1 e9 02             	shr    $0x2,%ecx
  800bc3:	fd                   	std    
  800bc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc6:	eb 09                	jmp    800bd1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bc8:	83 ef 01             	sub    $0x1,%edi
  800bcb:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bce:	fd                   	std    
  800bcf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd1:	fc                   	cld    
  800bd2:	eb 1d                	jmp    800bf1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd4:	89 f2                	mov    %esi,%edx
  800bd6:	09 c2                	or     %eax,%edx
  800bd8:	f6 c2 03             	test   $0x3,%dl
  800bdb:	75 0f                	jne    800bec <memmove+0x5f>
  800bdd:	f6 c1 03             	test   $0x3,%cl
  800be0:	75 0a                	jne    800bec <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800be2:	c1 e9 02             	shr    $0x2,%ecx
  800be5:	89 c7                	mov    %eax,%edi
  800be7:	fc                   	cld    
  800be8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bea:	eb 05                	jmp    800bf1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bec:	89 c7                	mov    %eax,%edi
  800bee:	fc                   	cld    
  800bef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bf8:	ff 75 10             	pushl  0x10(%ebp)
  800bfb:	ff 75 0c             	pushl  0xc(%ebp)
  800bfe:	ff 75 08             	pushl  0x8(%ebp)
  800c01:	e8 87 ff ff ff       	call   800b8d <memmove>
}
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c13:	89 c6                	mov    %eax,%esi
  800c15:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c18:	eb 1a                	jmp    800c34 <memcmp+0x2c>
		if (*s1 != *s2)
  800c1a:	0f b6 08             	movzbl (%eax),%ecx
  800c1d:	0f b6 1a             	movzbl (%edx),%ebx
  800c20:	38 d9                	cmp    %bl,%cl
  800c22:	74 0a                	je     800c2e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c24:	0f b6 c1             	movzbl %cl,%eax
  800c27:	0f b6 db             	movzbl %bl,%ebx
  800c2a:	29 d8                	sub    %ebx,%eax
  800c2c:	eb 0f                	jmp    800c3d <memcmp+0x35>
		s1++, s2++;
  800c2e:	83 c0 01             	add    $0x1,%eax
  800c31:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c34:	39 f0                	cmp    %esi,%eax
  800c36:	75 e2                	jne    800c1a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	53                   	push   %ebx
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c48:	89 c1                	mov    %eax,%ecx
  800c4a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c51:	eb 0a                	jmp    800c5d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c53:	0f b6 10             	movzbl (%eax),%edx
  800c56:	39 da                	cmp    %ebx,%edx
  800c58:	74 07                	je     800c61 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	39 c8                	cmp    %ecx,%eax
  800c5f:	72 f2                	jb     800c53 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c61:	5b                   	pop    %ebx
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c70:	eb 03                	jmp    800c75 <strtol+0x11>
		s++;
  800c72:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c75:	0f b6 01             	movzbl (%ecx),%eax
  800c78:	3c 20                	cmp    $0x20,%al
  800c7a:	74 f6                	je     800c72 <strtol+0xe>
  800c7c:	3c 09                	cmp    $0x9,%al
  800c7e:	74 f2                	je     800c72 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c80:	3c 2b                	cmp    $0x2b,%al
  800c82:	75 0a                	jne    800c8e <strtol+0x2a>
		s++;
  800c84:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c87:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8c:	eb 11                	jmp    800c9f <strtol+0x3b>
  800c8e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c93:	3c 2d                	cmp    $0x2d,%al
  800c95:	75 08                	jne    800c9f <strtol+0x3b>
		s++, neg = 1;
  800c97:	83 c1 01             	add    $0x1,%ecx
  800c9a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c9f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ca5:	75 15                	jne    800cbc <strtol+0x58>
  800ca7:	80 39 30             	cmpb   $0x30,(%ecx)
  800caa:	75 10                	jne    800cbc <strtol+0x58>
  800cac:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cb0:	75 7c                	jne    800d2e <strtol+0xca>
		s += 2, base = 16;
  800cb2:	83 c1 02             	add    $0x2,%ecx
  800cb5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cba:	eb 16                	jmp    800cd2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cbc:	85 db                	test   %ebx,%ebx
  800cbe:	75 12                	jne    800cd2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc5:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc8:	75 08                	jne    800cd2 <strtol+0x6e>
		s++, base = 8;
  800cca:	83 c1 01             	add    $0x1,%ecx
  800ccd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cda:	0f b6 11             	movzbl (%ecx),%edx
  800cdd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ce0:	89 f3                	mov    %esi,%ebx
  800ce2:	80 fb 09             	cmp    $0x9,%bl
  800ce5:	77 08                	ja     800cef <strtol+0x8b>
			dig = *s - '0';
  800ce7:	0f be d2             	movsbl %dl,%edx
  800cea:	83 ea 30             	sub    $0x30,%edx
  800ced:	eb 22                	jmp    800d11 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cef:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cf2:	89 f3                	mov    %esi,%ebx
  800cf4:	80 fb 19             	cmp    $0x19,%bl
  800cf7:	77 08                	ja     800d01 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cf9:	0f be d2             	movsbl %dl,%edx
  800cfc:	83 ea 57             	sub    $0x57,%edx
  800cff:	eb 10                	jmp    800d11 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d01:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d04:	89 f3                	mov    %esi,%ebx
  800d06:	80 fb 19             	cmp    $0x19,%bl
  800d09:	77 16                	ja     800d21 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d0b:	0f be d2             	movsbl %dl,%edx
  800d0e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d11:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d14:	7d 0b                	jge    800d21 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d16:	83 c1 01             	add    $0x1,%ecx
  800d19:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d1d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d1f:	eb b9                	jmp    800cda <strtol+0x76>

	if (endptr)
  800d21:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d25:	74 0d                	je     800d34 <strtol+0xd0>
		*endptr = (char *) s;
  800d27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d2a:	89 0e                	mov    %ecx,(%esi)
  800d2c:	eb 06                	jmp    800d34 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d2e:	85 db                	test   %ebx,%ebx
  800d30:	74 98                	je     800cca <strtol+0x66>
  800d32:	eb 9e                	jmp    800cd2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d34:	89 c2                	mov    %eax,%edx
  800d36:	f7 da                	neg    %edx
  800d38:	85 ff                	test   %edi,%edi
  800d3a:	0f 45 c2             	cmovne %edx,%eax
}
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d48:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d4f:	75 64                	jne    800db5 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800d51:	a1 04 20 80 00       	mov    0x802004,%eax
  800d56:	8b 40 48             	mov    0x48(%eax),%eax
  800d59:	83 ec 04             	sub    $0x4,%esp
  800d5c:	6a 07                	push   $0x7
  800d5e:	68 00 f0 bf ee       	push   $0xeebff000
  800d63:	50                   	push   %eax
  800d64:	e8 ff f3 ff ff       	call   800168 <sys_page_alloc>
		if ( r != 0)
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	74 14                	je     800d84 <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  800d70:	83 ec 04             	sub    $0x4,%esp
  800d73:	68 c0 13 80 00       	push   $0x8013c0
  800d78:	6a 24                	push   $0x24
  800d7a:	68 10 14 80 00       	push   $0x801410
  800d7f:	e8 19 f6 ff ff       	call   80039d <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  800d84:	a1 04 20 80 00       	mov    0x802004,%eax
  800d89:	8b 40 48             	mov    0x48(%eax),%eax
  800d8c:	83 ec 08             	sub    $0x8,%esp
  800d8f:	68 78 03 80 00       	push   $0x800378
  800d94:	50                   	push   %eax
  800d95:	e8 19 f5 ff ff       	call   8002b3 <sys_env_set_pgfault_upcall>
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	79 14                	jns    800db5 <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  800da1:	83 ec 04             	sub    $0x4,%esp
  800da4:	68 ec 13 80 00       	push   $0x8013ec
  800da9:	6a 27                	push   $0x27
  800dab:	68 10 14 80 00       	push   $0x801410
  800db0:	e8 e8 f5 ff ff       	call   80039d <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    
  800dbf:	90                   	nop

00800dc0 <__udivdi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 f6                	test   %esi,%esi
  800dd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ddd:	89 ca                	mov    %ecx,%edx
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	75 3d                	jne    800e20 <__udivdi3+0x60>
  800de3:	39 cf                	cmp    %ecx,%edi
  800de5:	0f 87 c5 00 00 00    	ja     800eb0 <__udivdi3+0xf0>
  800deb:	85 ff                	test   %edi,%edi
  800ded:	89 fd                	mov    %edi,%ebp
  800def:	75 0b                	jne    800dfc <__udivdi3+0x3c>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	31 d2                	xor    %edx,%edx
  800df8:	f7 f7                	div    %edi
  800dfa:	89 c5                	mov    %eax,%ebp
  800dfc:	89 c8                	mov    %ecx,%eax
  800dfe:	31 d2                	xor    %edx,%edx
  800e00:	f7 f5                	div    %ebp
  800e02:	89 c1                	mov    %eax,%ecx
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	f7 f5                	div    %ebp
  800e0a:	89 c3                	mov    %eax,%ebx
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
  800e20:	39 ce                	cmp    %ecx,%esi
  800e22:	77 74                	ja     800e98 <__udivdi3+0xd8>
  800e24:	0f bd fe             	bsr    %esi,%edi
  800e27:	83 f7 1f             	xor    $0x1f,%edi
  800e2a:	0f 84 98 00 00 00    	je     800ec8 <__udivdi3+0x108>
  800e30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	89 c5                	mov    %eax,%ebp
  800e39:	29 fb                	sub    %edi,%ebx
  800e3b:	d3 e6                	shl    %cl,%esi
  800e3d:	89 d9                	mov    %ebx,%ecx
  800e3f:	d3 ed                	shr    %cl,%ebp
  800e41:	89 f9                	mov    %edi,%ecx
  800e43:	d3 e0                	shl    %cl,%eax
  800e45:	09 ee                	or     %ebp,%esi
  800e47:	89 d9                	mov    %ebx,%ecx
  800e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4d:	89 d5                	mov    %edx,%ebp
  800e4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e53:	d3 ed                	shr    %cl,%ebp
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e2                	shl    %cl,%edx
  800e59:	89 d9                	mov    %ebx,%ecx
  800e5b:	d3 e8                	shr    %cl,%eax
  800e5d:	09 c2                	or     %eax,%edx
  800e5f:	89 d0                	mov    %edx,%eax
  800e61:	89 ea                	mov    %ebp,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 d5                	mov    %edx,%ebp
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	f7 64 24 0c          	mull   0xc(%esp)
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	72 10                	jb     800e81 <__udivdi3+0xc1>
  800e71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e6                	shl    %cl,%esi
  800e79:	39 c6                	cmp    %eax,%esi
  800e7b:	73 07                	jae    800e84 <__udivdi3+0xc4>
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	75 03                	jne    800e84 <__udivdi3+0xc4>
  800e81:	83 eb 01             	sub    $0x1,%ebx
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	31 ff                	xor    %edi,%edi
  800e9a:	31 db                	xor    %ebx,%ebx
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	89 fa                	mov    %edi,%edx
  800ea0:	83 c4 1c             	add    $0x1c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
  800ea8:	90                   	nop
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	f7 f7                	div    %edi
  800eb4:	31 ff                	xor    %edi,%edi
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	89 fa                	mov    %edi,%edx
  800ebc:	83 c4 1c             	add    $0x1c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	39 ce                	cmp    %ecx,%esi
  800eca:	72 0c                	jb     800ed8 <__udivdi3+0x118>
  800ecc:	31 db                	xor    %ebx,%ebx
  800ece:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ed2:	0f 87 34 ff ff ff    	ja     800e0c <__udivdi3+0x4c>
  800ed8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800edd:	e9 2a ff ff ff       	jmp    800e0c <__udivdi3+0x4c>
  800ee2:	66 90                	xchg   %ax,%ax
  800ee4:	66 90                	xchg   %ax,%ax
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	66 90                	xchg   %ax,%ax
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800efb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 d2                	test   %edx,%edx
  800f09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f3                	mov    %esi,%ebx
  800f13:	89 3c 24             	mov    %edi,(%esp)
  800f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1a:	75 1c                	jne    800f38 <__umoddi3+0x48>
  800f1c:	39 f7                	cmp    %esi,%edi
  800f1e:	76 50                	jbe    800f70 <__umoddi3+0x80>
  800f20:	89 c8                	mov    %ecx,%eax
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	f7 f7                	div    %edi
  800f26:	89 d0                	mov    %edx,%eax
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	83 c4 1c             	add    $0x1c,%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    
  800f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	89 d0                	mov    %edx,%eax
  800f3c:	77 52                	ja     800f90 <__umoddi3+0xa0>
  800f3e:	0f bd ea             	bsr    %edx,%ebp
  800f41:	83 f5 1f             	xor    $0x1f,%ebp
  800f44:	75 5a                	jne    800fa0 <__umoddi3+0xb0>
  800f46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f4a:	0f 82 e0 00 00 00    	jb     801030 <__umoddi3+0x140>
  800f50:	39 0c 24             	cmp    %ecx,(%esp)
  800f53:	0f 86 d7 00 00 00    	jbe    801030 <__umoddi3+0x140>
  800f59:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f61:	83 c4 1c             	add    $0x1c,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	85 ff                	test   %edi,%edi
  800f72:	89 fd                	mov    %edi,%ebp
  800f74:	75 0b                	jne    800f81 <__umoddi3+0x91>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f7                	div    %edi
  800f7f:	89 c5                	mov    %eax,%ebp
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f5                	div    %ebp
  800f87:	89 c8                	mov    %ecx,%eax
  800f89:	f7 f5                	div    %ebp
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	eb 99                	jmp    800f28 <__umoddi3+0x38>
  800f8f:	90                   	nop
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	83 c4 1c             	add    $0x1c,%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	8b 34 24             	mov    (%esp),%esi
  800fa3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	29 ef                	sub    %ebp,%edi
  800fac:	d3 e0                	shl    %cl,%eax
  800fae:	89 f9                	mov    %edi,%ecx
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	d3 ea                	shr    %cl,%edx
  800fb4:	89 e9                	mov    %ebp,%ecx
  800fb6:	09 c2                	or     %eax,%edx
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	89 14 24             	mov    %edx,(%esp)
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	d3 e2                	shl    %cl,%edx
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	d3 e3                	shl    %cl,%ebx
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	89 d0                	mov    %edx,%eax
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	09 d8                	or     %ebx,%eax
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 f2                	mov    %esi,%edx
  800fe1:	f7 34 24             	divl   (%esp)
  800fe4:	89 d6                	mov    %edx,%esi
  800fe6:	d3 e3                	shl    %cl,%ebx
  800fe8:	f7 64 24 04          	mull   0x4(%esp)
  800fec:	39 d6                	cmp    %edx,%esi
  800fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ff2:	89 d1                	mov    %edx,%ecx
  800ff4:	89 c3                	mov    %eax,%ebx
  800ff6:	72 08                	jb     801000 <__umoddi3+0x110>
  800ff8:	75 11                	jne    80100b <__umoddi3+0x11b>
  800ffa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800ffe:	73 0b                	jae    80100b <__umoddi3+0x11b>
  801000:	2b 44 24 04          	sub    0x4(%esp),%eax
  801004:	1b 14 24             	sbb    (%esp),%edx
  801007:	89 d1                	mov    %edx,%ecx
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80100f:	29 da                	sub    %ebx,%edx
  801011:	19 ce                	sbb    %ecx,%esi
  801013:	89 f9                	mov    %edi,%ecx
  801015:	89 f0                	mov    %esi,%eax
  801017:	d3 e0                	shl    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	d3 ea                	shr    %cl,%edx
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	d3 ee                	shr    %cl,%esi
  801021:	09 d0                	or     %edx,%eax
  801023:	89 f2                	mov    %esi,%edx
  801025:	83 c4 1c             	add    $0x1c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	29 f9                	sub    %edi,%ecx
  801032:	19 d6                	sbb    %edx,%esi
  801034:	89 74 24 04          	mov    %esi,0x4(%esp)
  801038:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103c:	e9 18 ff ff ff       	jmp    800f59 <__umoddi3+0x69>
