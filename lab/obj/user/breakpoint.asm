
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  800044:	e8 c6 00 00 00       	call   80010f <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800085:	6a 00                	push   $0x0
  800087:	e8 42 00 00 00       	call   8000ce <sys_env_destroy>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	57                   	push   %edi
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	89 c6                	mov    %eax,%esi
  8000a8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5f                   	pop    %edi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <sys_cgetc>:

int
sys_cgetc(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	89 d1                	mov    %edx,%ecx
  8000c1:	89 d3                	mov    %edx,%ebx
  8000c3:	89 d7                	mov    %edx,%edi
  8000c5:	89 d6                	mov    %edx,%esi
  8000c7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	89 cb                	mov    %ecx,%ebx
  8000e6:	89 cf                	mov    %ecx,%edi
  8000e8:	89 ce                	mov    %ecx,%esi
  8000ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	7e 17                	jle    800107 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	50                   	push   %eax
  8000f4:	6a 03                	push   $0x3
  8000f6:	68 aa 0f 80 00       	push   $0x800faa
  8000fb:	6a 23                	push   $0x23
  8000fd:	68 c7 0f 80 00       	push   $0x800fc7
  800102:	e8 56 02 00 00       	call   80035d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800115:	ba 00 00 00 00       	mov    $0x0,%edx
  80011a:	b8 02 00 00 00       	mov    $0x2,%eax
  80011f:	89 d1                	mov    %edx,%ecx
  800121:	89 d3                	mov    %edx,%ebx
  800123:	89 d7                	mov    %edx,%edi
  800125:	89 d6                	mov    %edx,%esi
  800127:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_yield>:

void
sys_yield(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 0b 00 00 00       	mov    $0xb,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	be 00 00 00 00       	mov    $0x0,%esi
  80015b:	b8 04 00 00 00       	mov    $0x4,%eax
  800160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800169:	89 f7                	mov    %esi,%edi
  80016b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016d:	85 c0                	test   %eax,%eax
  80016f:	7e 17                	jle    800188 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	50                   	push   %eax
  800175:	6a 04                	push   $0x4
  800177:	68 aa 0f 80 00       	push   $0x800faa
  80017c:	6a 23                	push   $0x23
  80017e:	68 c7 0f 80 00       	push   $0x800fc7
  800183:	e8 d5 01 00 00       	call   80035d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5f                   	pop    %edi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800199:	b8 05 00 00 00       	mov    $0x5,%eax
  80019e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001aa:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	7e 17                	jle    8001ca <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	50                   	push   %eax
  8001b7:	6a 05                	push   $0x5
  8001b9:	68 aa 0f 80 00       	push   $0x800faa
  8001be:	6a 23                	push   $0x23
  8001c0:	68 c7 0f 80 00       	push   $0x800fc7
  8001c5:	e8 93 01 00 00       	call   80035d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	89 df                	mov    %ebx,%edi
  8001ed:	89 de                	mov    %ebx,%esi
  8001ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 17                	jle    80020c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	50                   	push   %eax
  8001f9:	6a 06                	push   $0x6
  8001fb:	68 aa 0f 80 00       	push   $0x800faa
  800200:	6a 23                	push   $0x23
  800202:	68 c7 0f 80 00       	push   $0x800fc7
  800207:	e8 51 01 00 00       	call   80035d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	b8 08 00 00 00       	mov    $0x8,%eax
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 17                	jle    80024e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 08                	push   $0x8
  80023d:	68 aa 0f 80 00       	push   $0x800faa
  800242:	6a 23                	push   $0x23
  800244:	68 c7 0f 80 00       	push   $0x800fc7
  800249:	e8 0f 01 00 00       	call   80035d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	57                   	push   %edi
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
  80025c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800264:	b8 09 00 00 00       	mov    $0x9,%eax
  800269:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	89 df                	mov    %ebx,%edi
  800271:	89 de                	mov    %ebx,%esi
  800273:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800275:	85 c0                	test   %eax,%eax
  800277:	7e 17                	jle    800290 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800279:	83 ec 0c             	sub    $0xc,%esp
  80027c:	50                   	push   %eax
  80027d:	6a 09                	push   $0x9
  80027f:	68 aa 0f 80 00       	push   $0x800faa
  800284:	6a 23                	push   $0x23
  800286:	68 c7 0f 80 00       	push   $0x800fc7
  80028b:	e8 cd 00 00 00       	call   80035d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b1:	89 df                	mov    %ebx,%edi
  8002b3:	89 de                	mov    %ebx,%esi
  8002b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b7:	85 c0                	test   %eax,%eax
  8002b9:	7e 17                	jle    8002d2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	50                   	push   %eax
  8002bf:	6a 0a                	push   $0xa
  8002c1:	68 aa 0f 80 00       	push   $0x800faa
  8002c6:	6a 23                	push   $0x23
  8002c8:	68 c7 0f 80 00       	push   $0x800fc7
  8002cd:	e8 8b 00 00 00       	call   80035d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e0:	be 00 00 00 00       	mov    $0x0,%esi
  8002e5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002f6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	89 cb                	mov    %ecx,%ebx
  800315:	89 cf                	mov    %ecx,%edi
  800317:	89 ce                	mov    %ecx,%esi
  800319:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80031b:	85 c0                	test   %eax,%eax
  80031d:	7e 17                	jle    800336 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80031f:	83 ec 0c             	sub    $0xc,%esp
  800322:	50                   	push   %eax
  800323:	6a 0d                	push   $0xd
  800325:	68 aa 0f 80 00       	push   $0x800faa
  80032a:	6a 23                	push   $0x23
  80032c:	68 c7 0f 80 00       	push   $0x800fc7
  800331:	e8 27 00 00 00       	call   80035d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800336:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	57                   	push   %edi
  800342:	56                   	push   %esi
  800343:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800344:	ba 00 00 00 00       	mov    $0x0,%edx
  800349:	b8 0e 00 00 00       	mov    $0xe,%eax
  80034e:	89 d1                	mov    %edx,%ecx
  800350:	89 d3                	mov    %edx,%ebx
  800352:	89 d7                	mov    %edx,%edi
  800354:	89 d6                	mov    %edx,%esi
  800356:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800358:	5b                   	pop    %ebx
  800359:	5e                   	pop    %esi
  80035a:	5f                   	pop    %edi
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	56                   	push   %esi
  800361:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800362:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800365:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80036b:	e8 9f fd ff ff       	call   80010f <sys_getenvid>
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	ff 75 0c             	pushl  0xc(%ebp)
  800376:	ff 75 08             	pushl  0x8(%ebp)
  800379:	56                   	push   %esi
  80037a:	50                   	push   %eax
  80037b:	68 d8 0f 80 00       	push   $0x800fd8
  800380:	e8 b1 00 00 00       	call   800436 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	53                   	push   %ebx
  800389:	ff 75 10             	pushl  0x10(%ebp)
  80038c:	e8 54 00 00 00       	call   8003e5 <vcprintf>
	cprintf("\n");
  800391:	c7 04 24 fb 0f 80 00 	movl   $0x800ffb,(%esp)
  800398:	e8 99 00 00 00       	call   800436 <cprintf>
  80039d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003a0:	cc                   	int3   
  8003a1:	eb fd                	jmp    8003a0 <_panic+0x43>

008003a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	53                   	push   %ebx
  8003a7:	83 ec 04             	sub    $0x4,%esp
  8003aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ad:	8b 13                	mov    (%ebx),%edx
  8003af:	8d 42 01             	lea    0x1(%edx),%eax
  8003b2:	89 03                	mov    %eax,(%ebx)
  8003b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003c0:	75 1a                	jne    8003dc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003c2:	83 ec 08             	sub    $0x8,%esp
  8003c5:	68 ff 00 00 00       	push   $0xff
  8003ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8003cd:	50                   	push   %eax
  8003ce:	e8 be fc ff ff       	call   800091 <sys_cputs>
		b->idx = 0;
  8003d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003dc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003f5:	00 00 00 
	b.cnt = 0;
  8003f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800402:	ff 75 0c             	pushl  0xc(%ebp)
  800405:	ff 75 08             	pushl  0x8(%ebp)
  800408:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80040e:	50                   	push   %eax
  80040f:	68 a3 03 80 00       	push   $0x8003a3
  800414:	e8 54 01 00 00       	call   80056d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800419:	83 c4 08             	add    $0x8,%esp
  80041c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800422:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800428:	50                   	push   %eax
  800429:	e8 63 fc ff ff       	call   800091 <sys_cputs>

	return b.cnt;
}
  80042e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800434:	c9                   	leave  
  800435:	c3                   	ret    

00800436 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80043f:	50                   	push   %eax
  800440:	ff 75 08             	pushl  0x8(%ebp)
  800443:	e8 9d ff ff ff       	call   8003e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800448:	c9                   	leave  
  800449:	c3                   	ret    

0080044a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	57                   	push   %edi
  80044e:	56                   	push   %esi
  80044f:	53                   	push   %ebx
  800450:	83 ec 1c             	sub    $0x1c,%esp
  800453:	89 c7                	mov    %eax,%edi
  800455:	89 d6                	mov    %edx,%esi
  800457:	8b 45 08             	mov    0x8(%ebp),%eax
  80045a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800460:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800463:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800466:	bb 00 00 00 00       	mov    $0x0,%ebx
  80046b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80046e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800471:	39 d3                	cmp    %edx,%ebx
  800473:	72 05                	jb     80047a <printnum+0x30>
  800475:	39 45 10             	cmp    %eax,0x10(%ebp)
  800478:	77 45                	ja     8004bf <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80047a:	83 ec 0c             	sub    $0xc,%esp
  80047d:	ff 75 18             	pushl  0x18(%ebp)
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800486:	53                   	push   %ebx
  800487:	ff 75 10             	pushl  0x10(%ebp)
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800490:	ff 75 e0             	pushl  -0x20(%ebp)
  800493:	ff 75 dc             	pushl  -0x24(%ebp)
  800496:	ff 75 d8             	pushl  -0x28(%ebp)
  800499:	e8 72 08 00 00       	call   800d10 <__udivdi3>
  80049e:	83 c4 18             	add    $0x18,%esp
  8004a1:	52                   	push   %edx
  8004a2:	50                   	push   %eax
  8004a3:	89 f2                	mov    %esi,%edx
  8004a5:	89 f8                	mov    %edi,%eax
  8004a7:	e8 9e ff ff ff       	call   80044a <printnum>
  8004ac:	83 c4 20             	add    $0x20,%esp
  8004af:	eb 18                	jmp    8004c9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	ff 75 18             	pushl  0x18(%ebp)
  8004b8:	ff d7                	call   *%edi
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	eb 03                	jmp    8004c2 <printnum+0x78>
  8004bf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c2:	83 eb 01             	sub    $0x1,%ebx
  8004c5:	85 db                	test   %ebx,%ebx
  8004c7:	7f e8                	jg     8004b1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	56                   	push   %esi
  8004cd:	83 ec 04             	sub    $0x4,%esp
  8004d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004dc:	e8 5f 09 00 00       	call   800e40 <__umoddi3>
  8004e1:	83 c4 14             	add    $0x14,%esp
  8004e4:	0f be 80 fd 0f 80 00 	movsbl 0x800ffd(%eax),%eax
  8004eb:	50                   	push   %eax
  8004ec:	ff d7                	call   *%edi
}
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004f4:	5b                   	pop    %ebx
  8004f5:	5e                   	pop    %esi
  8004f6:	5f                   	pop    %edi
  8004f7:	5d                   	pop    %ebp
  8004f8:	c3                   	ret    

008004f9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004fc:	83 fa 01             	cmp    $0x1,%edx
  8004ff:	7e 0e                	jle    80050f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800501:	8b 10                	mov    (%eax),%edx
  800503:	8d 4a 08             	lea    0x8(%edx),%ecx
  800506:	89 08                	mov    %ecx,(%eax)
  800508:	8b 02                	mov    (%edx),%eax
  80050a:	8b 52 04             	mov    0x4(%edx),%edx
  80050d:	eb 22                	jmp    800531 <getuint+0x38>
	else if (lflag)
  80050f:	85 d2                	test   %edx,%edx
  800511:	74 10                	je     800523 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800513:	8b 10                	mov    (%eax),%edx
  800515:	8d 4a 04             	lea    0x4(%edx),%ecx
  800518:	89 08                	mov    %ecx,(%eax)
  80051a:	8b 02                	mov    (%edx),%eax
  80051c:	ba 00 00 00 00       	mov    $0x0,%edx
  800521:	eb 0e                	jmp    800531 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800523:	8b 10                	mov    (%eax),%edx
  800525:	8d 4a 04             	lea    0x4(%edx),%ecx
  800528:	89 08                	mov    %ecx,(%eax)
  80052a:	8b 02                	mov    (%edx),%eax
  80052c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800531:	5d                   	pop    %ebp
  800532:	c3                   	ret    

00800533 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800539:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80053d:	8b 10                	mov    (%eax),%edx
  80053f:	3b 50 04             	cmp    0x4(%eax),%edx
  800542:	73 0a                	jae    80054e <sprintputch+0x1b>
		*b->buf++ = ch;
  800544:	8d 4a 01             	lea    0x1(%edx),%ecx
  800547:	89 08                	mov    %ecx,(%eax)
  800549:	8b 45 08             	mov    0x8(%ebp),%eax
  80054c:	88 02                	mov    %al,(%edx)
}
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800556:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800559:	50                   	push   %eax
  80055a:	ff 75 10             	pushl  0x10(%ebp)
  80055d:	ff 75 0c             	pushl  0xc(%ebp)
  800560:	ff 75 08             	pushl  0x8(%ebp)
  800563:	e8 05 00 00 00       	call   80056d <vprintfmt>
	va_end(ap);
}
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	c9                   	leave  
  80056c:	c3                   	ret    

0080056d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	57                   	push   %edi
  800571:	56                   	push   %esi
  800572:	53                   	push   %ebx
  800573:	83 ec 2c             	sub    $0x2c,%esp
  800576:	8b 75 08             	mov    0x8(%ebp),%esi
  800579:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80057f:	eb 12                	jmp    800593 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800581:	85 c0                	test   %eax,%eax
  800583:	0f 84 89 03 00 00    	je     800912 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	53                   	push   %ebx
  80058d:	50                   	push   %eax
  80058e:	ff d6                	call   *%esi
  800590:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800593:	83 c7 01             	add    $0x1,%edi
  800596:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059a:	83 f8 25             	cmp    $0x25,%eax
  80059d:	75 e2                	jne    800581 <vprintfmt+0x14>
  80059f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005a3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005aa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005b1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bd:	eb 07                	jmp    8005c6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005c2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8d 47 01             	lea    0x1(%edi),%eax
  8005c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005cc:	0f b6 07             	movzbl (%edi),%eax
  8005cf:	0f b6 c8             	movzbl %al,%ecx
  8005d2:	83 e8 23             	sub    $0x23,%eax
  8005d5:	3c 55                	cmp    $0x55,%al
  8005d7:	0f 87 1a 03 00 00    	ja     8008f7 <vprintfmt+0x38a>
  8005dd:	0f b6 c0             	movzbl %al,%eax
  8005e0:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ea:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005ee:	eb d6                	jmp    8005c6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005fe:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800602:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800605:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800608:	83 fa 09             	cmp    $0x9,%edx
  80060b:	77 39                	ja     800646 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80060d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800610:	eb e9                	jmp    8005fb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 48 04             	lea    0x4(%eax),%ecx
  800618:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800623:	eb 27                	jmp    80064c <vprintfmt+0xdf>
  800625:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800628:	85 c0                	test   %eax,%eax
  80062a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062f:	0f 49 c8             	cmovns %eax,%ecx
  800632:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800638:	eb 8c                	jmp    8005c6 <vprintfmt+0x59>
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80063d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800644:	eb 80                	jmp    8005c6 <vprintfmt+0x59>
  800646:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800649:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80064c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800650:	0f 89 70 ff ff ff    	jns    8005c6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800656:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800659:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80065c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800663:	e9 5e ff ff ff       	jmp    8005c6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800668:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80066e:	e9 53 ff ff ff       	jmp    8005c6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 50 04             	lea    0x4(%eax),%edx
  800679:	89 55 14             	mov    %edx,0x14(%ebp)
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	ff 30                	pushl  (%eax)
  800682:	ff d6                	call   *%esi
			break;
  800684:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80068a:	e9 04 ff ff ff       	jmp    800593 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	99                   	cltd   
  80069b:	31 d0                	xor    %edx,%eax
  80069d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80069f:	83 f8 0f             	cmp    $0xf,%eax
  8006a2:	7f 0b                	jg     8006af <vprintfmt+0x142>
  8006a4:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	75 18                	jne    8006c7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006af:	50                   	push   %eax
  8006b0:	68 15 10 80 00       	push   $0x801015
  8006b5:	53                   	push   %ebx
  8006b6:	56                   	push   %esi
  8006b7:	e8 94 fe ff ff       	call   800550 <printfmt>
  8006bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006c2:	e9 cc fe ff ff       	jmp    800593 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006c7:	52                   	push   %edx
  8006c8:	68 1e 10 80 00       	push   $0x80101e
  8006cd:	53                   	push   %ebx
  8006ce:	56                   	push   %esi
  8006cf:	e8 7c fe ff ff       	call   800550 <printfmt>
  8006d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	e9 b4 fe ff ff       	jmp    800593 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006ea:	85 ff                	test   %edi,%edi
  8006ec:	b8 0e 10 80 00       	mov    $0x80100e,%eax
  8006f1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006f8:	0f 8e 94 00 00 00    	jle    800792 <vprintfmt+0x225>
  8006fe:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800702:	0f 84 98 00 00 00    	je     8007a0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	ff 75 d0             	pushl  -0x30(%ebp)
  80070e:	57                   	push   %edi
  80070f:	e8 86 02 00 00       	call   80099a <strnlen>
  800714:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800717:	29 c1                	sub    %eax,%ecx
  800719:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80071c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80071f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800723:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800726:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800729:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072b:	eb 0f                	jmp    80073c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	ff 75 e0             	pushl  -0x20(%ebp)
  800734:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800736:	83 ef 01             	sub    $0x1,%edi
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	85 ff                	test   %edi,%edi
  80073e:	7f ed                	jg     80072d <vprintfmt+0x1c0>
  800740:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800743:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800746:	85 c9                	test   %ecx,%ecx
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	0f 49 c1             	cmovns %ecx,%eax
  800750:	29 c1                	sub    %eax,%ecx
  800752:	89 75 08             	mov    %esi,0x8(%ebp)
  800755:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800758:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075b:	89 cb                	mov    %ecx,%ebx
  80075d:	eb 4d                	jmp    8007ac <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80075f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800763:	74 1b                	je     800780 <vprintfmt+0x213>
  800765:	0f be c0             	movsbl %al,%eax
  800768:	83 e8 20             	sub    $0x20,%eax
  80076b:	83 f8 5e             	cmp    $0x5e,%eax
  80076e:	76 10                	jbe    800780 <vprintfmt+0x213>
					putch('?', putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	6a 3f                	push   $0x3f
  800778:	ff 55 08             	call   *0x8(%ebp)
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	eb 0d                	jmp    80078d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	ff 75 0c             	pushl  0xc(%ebp)
  800786:	52                   	push   %edx
  800787:	ff 55 08             	call   *0x8(%ebp)
  80078a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80078d:	83 eb 01             	sub    $0x1,%ebx
  800790:	eb 1a                	jmp    8007ac <vprintfmt+0x23f>
  800792:	89 75 08             	mov    %esi,0x8(%ebp)
  800795:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800798:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80079b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80079e:	eb 0c                	jmp    8007ac <vprintfmt+0x23f>
  8007a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007a9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007ac:	83 c7 01             	add    $0x1,%edi
  8007af:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007b3:	0f be d0             	movsbl %al,%edx
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	74 23                	je     8007dd <vprintfmt+0x270>
  8007ba:	85 f6                	test   %esi,%esi
  8007bc:	78 a1                	js     80075f <vprintfmt+0x1f2>
  8007be:	83 ee 01             	sub    $0x1,%esi
  8007c1:	79 9c                	jns    80075f <vprintfmt+0x1f2>
  8007c3:	89 df                	mov    %ebx,%edi
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007cb:	eb 18                	jmp    8007e5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	53                   	push   %ebx
  8007d1:	6a 20                	push   $0x20
  8007d3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007d5:	83 ef 01             	sub    $0x1,%edi
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 08                	jmp    8007e5 <vprintfmt+0x278>
  8007dd:	89 df                	mov    %ebx,%edi
  8007df:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e5:	85 ff                	test   %edi,%edi
  8007e7:	7f e4                	jg     8007cd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ec:	e9 a2 fd ff ff       	jmp    800593 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007f1:	83 fa 01             	cmp    $0x1,%edx
  8007f4:	7e 16                	jle    80080c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 50 08             	lea    0x8(%eax),%edx
  8007fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ff:	8b 50 04             	mov    0x4(%eax),%edx
  800802:	8b 00                	mov    (%eax),%eax
  800804:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800807:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80080a:	eb 32                	jmp    80083e <vprintfmt+0x2d1>
	else if (lflag)
  80080c:	85 d2                	test   %edx,%edx
  80080e:	74 18                	je     800828 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8d 50 04             	lea    0x4(%eax),%edx
  800816:	89 55 14             	mov    %edx,0x14(%ebp)
  800819:	8b 00                	mov    (%eax),%eax
  80081b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081e:	89 c1                	mov    %eax,%ecx
  800820:	c1 f9 1f             	sar    $0x1f,%ecx
  800823:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800826:	eb 16                	jmp    80083e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8d 50 04             	lea    0x4(%eax),%edx
  80082e:	89 55 14             	mov    %edx,0x14(%ebp)
  800831:	8b 00                	mov    (%eax),%eax
  800833:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800836:	89 c1                	mov    %eax,%ecx
  800838:	c1 f9 1f             	sar    $0x1f,%ecx
  80083b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80083e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800841:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800844:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800849:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80084d:	79 74                	jns    8008c3 <vprintfmt+0x356>
				putch('-', putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 2d                	push   $0x2d
  800855:	ff d6                	call   *%esi
				num = -(long long) num;
  800857:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80085a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80085d:	f7 d8                	neg    %eax
  80085f:	83 d2 00             	adc    $0x0,%edx
  800862:	f7 da                	neg    %edx
  800864:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800867:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80086c:	eb 55                	jmp    8008c3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80086e:	8d 45 14             	lea    0x14(%ebp),%eax
  800871:	e8 83 fc ff ff       	call   8004f9 <getuint>
			base = 10;
  800876:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80087b:	eb 46                	jmp    8008c3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80087d:	8d 45 14             	lea    0x14(%ebp),%eax
  800880:	e8 74 fc ff ff       	call   8004f9 <getuint>
			base = 8;
  800885:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80088a:	eb 37                	jmp    8008c3 <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	6a 30                	push   $0x30
  800892:	ff d6                	call   *%esi
			putch('x', putdat);
  800894:	83 c4 08             	add    $0x8,%esp
  800897:	53                   	push   %ebx
  800898:	6a 78                	push   $0x78
  80089a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8d 50 04             	lea    0x4(%eax),%edx
  8008a2:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008a5:	8b 00                	mov    (%eax),%eax
  8008a7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008ac:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008af:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008b4:	eb 0d                	jmp    8008c3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b9:	e8 3b fc ff ff       	call   8004f9 <getuint>
			base = 16;
  8008be:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008c3:	83 ec 0c             	sub    $0xc,%esp
  8008c6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008ca:	57                   	push   %edi
  8008cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ce:	51                   	push   %ecx
  8008cf:	52                   	push   %edx
  8008d0:	50                   	push   %eax
  8008d1:	89 da                	mov    %ebx,%edx
  8008d3:	89 f0                	mov    %esi,%eax
  8008d5:	e8 70 fb ff ff       	call   80044a <printnum>
			break;
  8008da:	83 c4 20             	add    $0x20,%esp
  8008dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008e0:	e9 ae fc ff ff       	jmp    800593 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	53                   	push   %ebx
  8008e9:	51                   	push   %ecx
  8008ea:	ff d6                	call   *%esi
			break;
  8008ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008f2:	e9 9c fc ff ff       	jmp    800593 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	53                   	push   %ebx
  8008fb:	6a 25                	push   $0x25
  8008fd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	eb 03                	jmp    800907 <vprintfmt+0x39a>
  800904:	83 ef 01             	sub    $0x1,%edi
  800907:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80090b:	75 f7                	jne    800904 <vprintfmt+0x397>
  80090d:	e9 81 fc ff ff       	jmp    800593 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800912:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 18             	sub    $0x18,%esp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800926:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800929:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80092d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800930:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800937:	85 c0                	test   %eax,%eax
  800939:	74 26                	je     800961 <vsnprintf+0x47>
  80093b:	85 d2                	test   %edx,%edx
  80093d:	7e 22                	jle    800961 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093f:	ff 75 14             	pushl  0x14(%ebp)
  800942:	ff 75 10             	pushl  0x10(%ebp)
  800945:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800948:	50                   	push   %eax
  800949:	68 33 05 80 00       	push   $0x800533
  80094e:	e8 1a fc ff ff       	call   80056d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800953:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800956:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800959:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095c:	83 c4 10             	add    $0x10,%esp
  80095f:	eb 05                	jmp    800966 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800961:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800966:	c9                   	leave  
  800967:	c3                   	ret    

00800968 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800971:	50                   	push   %eax
  800972:	ff 75 10             	pushl  0x10(%ebp)
  800975:	ff 75 0c             	pushl  0xc(%ebp)
  800978:	ff 75 08             	pushl  0x8(%ebp)
  80097b:	e8 9a ff ff ff       	call   80091a <vsnprintf>
	va_end(ap);

	return rc;
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
  80098d:	eb 03                	jmp    800992 <strlen+0x10>
		n++;
  80098f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800992:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800996:	75 f7                	jne    80098f <strlen+0xd>
		n++;
	return n;
}
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a8:	eb 03                	jmp    8009ad <strnlen+0x13>
		n++;
  8009aa:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ad:	39 c2                	cmp    %eax,%edx
  8009af:	74 08                	je     8009b9 <strnlen+0x1f>
  8009b1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009b5:	75 f3                	jne    8009aa <strnlen+0x10>
  8009b7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c5:	89 c2                	mov    %eax,%edx
  8009c7:	83 c2 01             	add    $0x1,%edx
  8009ca:	83 c1 01             	add    $0x1,%ecx
  8009cd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009d1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d4:	84 db                	test   %bl,%bl
  8009d6:	75 ef                	jne    8009c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e2:	53                   	push   %ebx
  8009e3:	e8 9a ff ff ff       	call   800982 <strlen>
  8009e8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009eb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ee:	01 d8                	add    %ebx,%eax
  8009f0:	50                   	push   %eax
  8009f1:	e8 c5 ff ff ff       	call   8009bb <strcpy>
	return dst;
}
  8009f6:	89 d8                	mov    %ebx,%eax
  8009f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 75 08             	mov    0x8(%ebp),%esi
  800a05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a08:	89 f3                	mov    %esi,%ebx
  800a0a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0d:	89 f2                	mov    %esi,%edx
  800a0f:	eb 0f                	jmp    800a20 <strncpy+0x23>
		*dst++ = *src;
  800a11:	83 c2 01             	add    $0x1,%edx
  800a14:	0f b6 01             	movzbl (%ecx),%eax
  800a17:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a1a:	80 39 01             	cmpb   $0x1,(%ecx)
  800a1d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a20:	39 da                	cmp    %ebx,%edx
  800a22:	75 ed                	jne    800a11 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a24:	89 f0                	mov    %esi,%eax
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a35:	8b 55 10             	mov    0x10(%ebp),%edx
  800a38:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a3a:	85 d2                	test   %edx,%edx
  800a3c:	74 21                	je     800a5f <strlcpy+0x35>
  800a3e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a42:	89 f2                	mov    %esi,%edx
  800a44:	eb 09                	jmp    800a4f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a4f:	39 c2                	cmp    %eax,%edx
  800a51:	74 09                	je     800a5c <strlcpy+0x32>
  800a53:	0f b6 19             	movzbl (%ecx),%ebx
  800a56:	84 db                	test   %bl,%bl
  800a58:	75 ec                	jne    800a46 <strlcpy+0x1c>
  800a5a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a5c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5f:	29 f0                	sub    %esi,%eax
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a6e:	eb 06                	jmp    800a76 <strcmp+0x11>
		p++, q++;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a76:	0f b6 01             	movzbl (%ecx),%eax
  800a79:	84 c0                	test   %al,%al
  800a7b:	74 04                	je     800a81 <strcmp+0x1c>
  800a7d:	3a 02                	cmp    (%edx),%al
  800a7f:	74 ef                	je     800a70 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 c0             	movzbl %al,%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a95:	89 c3                	mov    %eax,%ebx
  800a97:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a9a:	eb 06                	jmp    800aa2 <strncmp+0x17>
		n--, p++, q++;
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa2:	39 d8                	cmp    %ebx,%eax
  800aa4:	74 15                	je     800abb <strncmp+0x30>
  800aa6:	0f b6 08             	movzbl (%eax),%ecx
  800aa9:	84 c9                	test   %cl,%cl
  800aab:	74 04                	je     800ab1 <strncmp+0x26>
  800aad:	3a 0a                	cmp    (%edx),%cl
  800aaf:	74 eb                	je     800a9c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab1:	0f b6 00             	movzbl (%eax),%eax
  800ab4:	0f b6 12             	movzbl (%edx),%edx
  800ab7:	29 d0                	sub    %edx,%eax
  800ab9:	eb 05                	jmp    800ac0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800acd:	eb 07                	jmp    800ad6 <strchr+0x13>
		if (*s == c)
  800acf:	38 ca                	cmp    %cl,%dl
  800ad1:	74 0f                	je     800ae2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	0f b6 10             	movzbl (%eax),%edx
  800ad9:	84 d2                	test   %dl,%dl
  800adb:	75 f2                	jne    800acf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aee:	eb 03                	jmp    800af3 <strfind+0xf>
  800af0:	83 c0 01             	add    $0x1,%eax
  800af3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af6:	38 ca                	cmp    %cl,%dl
  800af8:	74 04                	je     800afe <strfind+0x1a>
  800afa:	84 d2                	test   %dl,%dl
  800afc:	75 f2                	jne    800af0 <strfind+0xc>
			break;
	return (char *) s;
}
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b09:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b0c:	85 c9                	test   %ecx,%ecx
  800b0e:	74 36                	je     800b46 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b10:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b16:	75 28                	jne    800b40 <memset+0x40>
  800b18:	f6 c1 03             	test   $0x3,%cl
  800b1b:	75 23                	jne    800b40 <memset+0x40>
		c &= 0xFF;
  800b1d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b21:	89 d3                	mov    %edx,%ebx
  800b23:	c1 e3 08             	shl    $0x8,%ebx
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	c1 e6 18             	shl    $0x18,%esi
  800b2b:	89 d0                	mov    %edx,%eax
  800b2d:	c1 e0 10             	shl    $0x10,%eax
  800b30:	09 f0                	or     %esi,%eax
  800b32:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b34:	89 d8                	mov    %ebx,%eax
  800b36:	09 d0                	or     %edx,%eax
  800b38:	c1 e9 02             	shr    $0x2,%ecx
  800b3b:	fc                   	cld    
  800b3c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3e:	eb 06                	jmp    800b46 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	fc                   	cld    
  800b44:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b46:	89 f8                	mov    %edi,%eax
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5b:	39 c6                	cmp    %eax,%esi
  800b5d:	73 35                	jae    800b94 <memmove+0x47>
  800b5f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b62:	39 d0                	cmp    %edx,%eax
  800b64:	73 2e                	jae    800b94 <memmove+0x47>
		s += n;
		d += n;
  800b66:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	09 fe                	or     %edi,%esi
  800b6d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b73:	75 13                	jne    800b88 <memmove+0x3b>
  800b75:	f6 c1 03             	test   $0x3,%cl
  800b78:	75 0e                	jne    800b88 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b7a:	83 ef 04             	sub    $0x4,%edi
  800b7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b80:	c1 e9 02             	shr    $0x2,%ecx
  800b83:	fd                   	std    
  800b84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b86:	eb 09                	jmp    800b91 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b88:	83 ef 01             	sub    $0x1,%edi
  800b8b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b8e:	fd                   	std    
  800b8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b91:	fc                   	cld    
  800b92:	eb 1d                	jmp    800bb1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	09 c2                	or     %eax,%edx
  800b98:	f6 c2 03             	test   $0x3,%dl
  800b9b:	75 0f                	jne    800bac <memmove+0x5f>
  800b9d:	f6 c1 03             	test   $0x3,%cl
  800ba0:	75 0a                	jne    800bac <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ba2:	c1 e9 02             	shr    $0x2,%ecx
  800ba5:	89 c7                	mov    %eax,%edi
  800ba7:	fc                   	cld    
  800ba8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800baa:	eb 05                	jmp    800bb1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bac:	89 c7                	mov    %eax,%edi
  800bae:	fc                   	cld    
  800baf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bb8:	ff 75 10             	pushl  0x10(%ebp)
  800bbb:	ff 75 0c             	pushl  0xc(%ebp)
  800bbe:	ff 75 08             	pushl  0x8(%ebp)
  800bc1:	e8 87 ff ff ff       	call   800b4d <memmove>
}
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd3:	89 c6                	mov    %eax,%esi
  800bd5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd8:	eb 1a                	jmp    800bf4 <memcmp+0x2c>
		if (*s1 != *s2)
  800bda:	0f b6 08             	movzbl (%eax),%ecx
  800bdd:	0f b6 1a             	movzbl (%edx),%ebx
  800be0:	38 d9                	cmp    %bl,%cl
  800be2:	74 0a                	je     800bee <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800be4:	0f b6 c1             	movzbl %cl,%eax
  800be7:	0f b6 db             	movzbl %bl,%ebx
  800bea:	29 d8                	sub    %ebx,%eax
  800bec:	eb 0f                	jmp    800bfd <memcmp+0x35>
		s1++, s2++;
  800bee:	83 c0 01             	add    $0x1,%eax
  800bf1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf4:	39 f0                	cmp    %esi,%eax
  800bf6:	75 e2                	jne    800bda <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	53                   	push   %ebx
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c08:	89 c1                	mov    %eax,%ecx
  800c0a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c11:	eb 0a                	jmp    800c1d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c13:	0f b6 10             	movzbl (%eax),%edx
  800c16:	39 da                	cmp    %ebx,%edx
  800c18:	74 07                	je     800c21 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	39 c8                	cmp    %ecx,%eax
  800c1f:	72 f2                	jb     800c13 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c21:	5b                   	pop    %ebx
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c30:	eb 03                	jmp    800c35 <strtol+0x11>
		s++;
  800c32:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c35:	0f b6 01             	movzbl (%ecx),%eax
  800c38:	3c 20                	cmp    $0x20,%al
  800c3a:	74 f6                	je     800c32 <strtol+0xe>
  800c3c:	3c 09                	cmp    $0x9,%al
  800c3e:	74 f2                	je     800c32 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c40:	3c 2b                	cmp    $0x2b,%al
  800c42:	75 0a                	jne    800c4e <strtol+0x2a>
		s++;
  800c44:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c47:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4c:	eb 11                	jmp    800c5f <strtol+0x3b>
  800c4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c53:	3c 2d                	cmp    $0x2d,%al
  800c55:	75 08                	jne    800c5f <strtol+0x3b>
		s++, neg = 1;
  800c57:	83 c1 01             	add    $0x1,%ecx
  800c5a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c65:	75 15                	jne    800c7c <strtol+0x58>
  800c67:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6a:	75 10                	jne    800c7c <strtol+0x58>
  800c6c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c70:	75 7c                	jne    800cee <strtol+0xca>
		s += 2, base = 16;
  800c72:	83 c1 02             	add    $0x2,%ecx
  800c75:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c7a:	eb 16                	jmp    800c92 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c7c:	85 db                	test   %ebx,%ebx
  800c7e:	75 12                	jne    800c92 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c80:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c85:	80 39 30             	cmpb   $0x30,(%ecx)
  800c88:	75 08                	jne    800c92 <strtol+0x6e>
		s++, base = 8;
  800c8a:	83 c1 01             	add    $0x1,%ecx
  800c8d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
  800c97:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c9a:	0f b6 11             	movzbl (%ecx),%edx
  800c9d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ca0:	89 f3                	mov    %esi,%ebx
  800ca2:	80 fb 09             	cmp    $0x9,%bl
  800ca5:	77 08                	ja     800caf <strtol+0x8b>
			dig = *s - '0';
  800ca7:	0f be d2             	movsbl %dl,%edx
  800caa:	83 ea 30             	sub    $0x30,%edx
  800cad:	eb 22                	jmp    800cd1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800caf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb2:	89 f3                	mov    %esi,%ebx
  800cb4:	80 fb 19             	cmp    $0x19,%bl
  800cb7:	77 08                	ja     800cc1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cb9:	0f be d2             	movsbl %dl,%edx
  800cbc:	83 ea 57             	sub    $0x57,%edx
  800cbf:	eb 10                	jmp    800cd1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cc1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cc4:	89 f3                	mov    %esi,%ebx
  800cc6:	80 fb 19             	cmp    $0x19,%bl
  800cc9:	77 16                	ja     800ce1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ccb:	0f be d2             	movsbl %dl,%edx
  800cce:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cd1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cd4:	7d 0b                	jge    800ce1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cd6:	83 c1 01             	add    $0x1,%ecx
  800cd9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cdd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cdf:	eb b9                	jmp    800c9a <strtol+0x76>

	if (endptr)
  800ce1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce5:	74 0d                	je     800cf4 <strtol+0xd0>
		*endptr = (char *) s;
  800ce7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cea:	89 0e                	mov    %ecx,(%esi)
  800cec:	eb 06                	jmp    800cf4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cee:	85 db                	test   %ebx,%ebx
  800cf0:	74 98                	je     800c8a <strtol+0x66>
  800cf2:	eb 9e                	jmp    800c92 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cf4:	89 c2                	mov    %eax,%edx
  800cf6:	f7 da                	neg    %edx
  800cf8:	85 ff                	test   %edi,%edi
  800cfa:	0f 45 c2             	cmovne %edx,%eax
}
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
  800d02:	66 90                	xchg   %ax,%ax
  800d04:	66 90                	xchg   %ax,%ax
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

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
