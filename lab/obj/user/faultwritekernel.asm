
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  80004d:	e8 c6 00 00 00       	call   800118 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 aa 0f 80 00       	push   $0x800faa
  800104:	6a 23                	push   $0x23
  800106:	68 c7 0f 80 00       	push   $0x800fc7
  80010b:	e8 56 02 00 00       	call   800366 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 aa 0f 80 00       	push   $0x800faa
  800185:	6a 23                	push   $0x23
  800187:	68 c7 0f 80 00       	push   $0x800fc7
  80018c:	e8 d5 01 00 00       	call   800366 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 aa 0f 80 00       	push   $0x800faa
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 c7 0f 80 00       	push   $0x800fc7
  8001ce:	e8 93 01 00 00       	call   800366 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 aa 0f 80 00       	push   $0x800faa
  800209:	6a 23                	push   $0x23
  80020b:	68 c7 0f 80 00       	push   $0x800fc7
  800210:	e8 51 01 00 00       	call   800366 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 aa 0f 80 00       	push   $0x800faa
  80024b:	6a 23                	push   $0x23
  80024d:	68 c7 0f 80 00       	push   $0x800fc7
  800252:	e8 0f 01 00 00       	call   800366 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 aa 0f 80 00       	push   $0x800faa
  80028d:	6a 23                	push   $0x23
  80028f:	68 c7 0f 80 00       	push   $0x800fc7
  800294:	e8 cd 00 00 00       	call   800366 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 aa 0f 80 00       	push   $0x800faa
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 c7 0f 80 00       	push   $0x800fc7
  8002d6:	e8 8b 00 00 00       	call   800366 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 aa 0f 80 00       	push   $0x800faa
  800333:	6a 23                	push   $0x23
  800335:	68 c7 0f 80 00       	push   $0x800fc7
  80033a:	e8 27 00 00 00       	call   800366 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	b8 0e 00 00 00       	mov    $0xe,%eax
  800357:	89 d1                	mov    %edx,%ecx
  800359:	89 d3                	mov    %edx,%ebx
  80035b:	89 d7                	mov    %edx,%edi
  80035d:	89 d6                	mov    %edx,%esi
  80035f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80036b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80036e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800374:	e8 9f fd ff ff       	call   800118 <sys_getenvid>
  800379:	83 ec 0c             	sub    $0xc,%esp
  80037c:	ff 75 0c             	pushl  0xc(%ebp)
  80037f:	ff 75 08             	pushl  0x8(%ebp)
  800382:	56                   	push   %esi
  800383:	50                   	push   %eax
  800384:	68 d8 0f 80 00       	push   $0x800fd8
  800389:	e8 b1 00 00 00       	call   80043f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80038e:	83 c4 18             	add    $0x18,%esp
  800391:	53                   	push   %ebx
  800392:	ff 75 10             	pushl  0x10(%ebp)
  800395:	e8 54 00 00 00       	call   8003ee <vcprintf>
	cprintf("\n");
  80039a:	c7 04 24 fb 0f 80 00 	movl   $0x800ffb,(%esp)
  8003a1:	e8 99 00 00 00       	call   80043f <cprintf>
  8003a6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003a9:	cc                   	int3   
  8003aa:	eb fd                	jmp    8003a9 <_panic+0x43>

008003ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	53                   	push   %ebx
  8003b0:	83 ec 04             	sub    $0x4,%esp
  8003b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003b6:	8b 13                	mov    (%ebx),%edx
  8003b8:	8d 42 01             	lea    0x1(%edx),%eax
  8003bb:	89 03                	mov    %eax,(%ebx)
  8003bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003c9:	75 1a                	jne    8003e5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	68 ff 00 00 00       	push   $0xff
  8003d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8003d6:	50                   	push   %eax
  8003d7:	e8 be fc ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8003dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003e2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003e5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003fe:	00 00 00 
	b.cnt = 0;
  800401:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800408:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80040b:	ff 75 0c             	pushl  0xc(%ebp)
  80040e:	ff 75 08             	pushl  0x8(%ebp)
  800411:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800417:	50                   	push   %eax
  800418:	68 ac 03 80 00       	push   $0x8003ac
  80041d:	e8 54 01 00 00       	call   800576 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800422:	83 c4 08             	add    $0x8,%esp
  800425:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80042b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800431:	50                   	push   %eax
  800432:	e8 63 fc ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  800437:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80043d:	c9                   	leave  
  80043e:	c3                   	ret    

0080043f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800445:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800448:	50                   	push   %eax
  800449:	ff 75 08             	pushl  0x8(%ebp)
  80044c:	e8 9d ff ff ff       	call   8003ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800451:	c9                   	leave  
  800452:	c3                   	ret    

00800453 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	57                   	push   %edi
  800457:	56                   	push   %esi
  800458:	53                   	push   %ebx
  800459:	83 ec 1c             	sub    $0x1c,%esp
  80045c:	89 c7                	mov    %eax,%edi
  80045e:	89 d6                	mov    %edx,%esi
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	8b 55 0c             	mov    0xc(%ebp),%edx
  800466:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800469:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80046c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80046f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800474:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800477:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80047a:	39 d3                	cmp    %edx,%ebx
  80047c:	72 05                	jb     800483 <printnum+0x30>
  80047e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800481:	77 45                	ja     8004c8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800483:	83 ec 0c             	sub    $0xc,%esp
  800486:	ff 75 18             	pushl  0x18(%ebp)
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80048f:	53                   	push   %ebx
  800490:	ff 75 10             	pushl  0x10(%ebp)
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	ff 75 e4             	pushl  -0x1c(%ebp)
  800499:	ff 75 e0             	pushl  -0x20(%ebp)
  80049c:	ff 75 dc             	pushl  -0x24(%ebp)
  80049f:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a2:	e8 69 08 00 00       	call   800d10 <__udivdi3>
  8004a7:	83 c4 18             	add    $0x18,%esp
  8004aa:	52                   	push   %edx
  8004ab:	50                   	push   %eax
  8004ac:	89 f2                	mov    %esi,%edx
  8004ae:	89 f8                	mov    %edi,%eax
  8004b0:	e8 9e ff ff ff       	call   800453 <printnum>
  8004b5:	83 c4 20             	add    $0x20,%esp
  8004b8:	eb 18                	jmp    8004d2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	56                   	push   %esi
  8004be:	ff 75 18             	pushl  0x18(%ebp)
  8004c1:	ff d7                	call   *%edi
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	eb 03                	jmp    8004cb <printnum+0x78>
  8004c8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004cb:	83 eb 01             	sub    $0x1,%ebx
  8004ce:	85 db                	test   %ebx,%ebx
  8004d0:	7f e8                	jg     8004ba <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	56                   	push   %esi
  8004d6:	83 ec 04             	sub    $0x4,%esp
  8004d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004df:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e5:	e8 56 09 00 00       	call   800e40 <__umoddi3>
  8004ea:	83 c4 14             	add    $0x14,%esp
  8004ed:	0f be 80 fd 0f 80 00 	movsbl 0x800ffd(%eax),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff d7                	call   *%edi
}
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004fd:	5b                   	pop    %ebx
  8004fe:	5e                   	pop    %esi
  8004ff:	5f                   	pop    %edi
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800505:	83 fa 01             	cmp    $0x1,%edx
  800508:	7e 0e                	jle    800518 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80050a:	8b 10                	mov    (%eax),%edx
  80050c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80050f:	89 08                	mov    %ecx,(%eax)
  800511:	8b 02                	mov    (%edx),%eax
  800513:	8b 52 04             	mov    0x4(%edx),%edx
  800516:	eb 22                	jmp    80053a <getuint+0x38>
	else if (lflag)
  800518:	85 d2                	test   %edx,%edx
  80051a:	74 10                	je     80052c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80051c:	8b 10                	mov    (%eax),%edx
  80051e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800521:	89 08                	mov    %ecx,(%eax)
  800523:	8b 02                	mov    (%edx),%eax
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
  80052a:	eb 0e                	jmp    80053a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80052c:	8b 10                	mov    (%eax),%edx
  80052e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800531:	89 08                	mov    %ecx,(%eax)
  800533:	8b 02                	mov    (%edx),%eax
  800535:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800542:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800546:	8b 10                	mov    (%eax),%edx
  800548:	3b 50 04             	cmp    0x4(%eax),%edx
  80054b:	73 0a                	jae    800557 <sprintputch+0x1b>
		*b->buf++ = ch;
  80054d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800550:	89 08                	mov    %ecx,(%eax)
  800552:	8b 45 08             	mov    0x8(%ebp),%eax
  800555:	88 02                	mov    %al,(%edx)
}
  800557:	5d                   	pop    %ebp
  800558:	c3                   	ret    

00800559 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800559:	55                   	push   %ebp
  80055a:	89 e5                	mov    %esp,%ebp
  80055c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80055f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800562:	50                   	push   %eax
  800563:	ff 75 10             	pushl  0x10(%ebp)
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	ff 75 08             	pushl  0x8(%ebp)
  80056c:	e8 05 00 00 00       	call   800576 <vprintfmt>
	va_end(ap);
}
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	c9                   	leave  
  800575:	c3                   	ret    

00800576 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
  800579:	57                   	push   %edi
  80057a:	56                   	push   %esi
  80057b:	53                   	push   %ebx
  80057c:	83 ec 2c             	sub    $0x2c,%esp
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	8b 7d 10             	mov    0x10(%ebp),%edi
  800588:	eb 12                	jmp    80059c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80058a:	85 c0                	test   %eax,%eax
  80058c:	0f 84 89 03 00 00    	je     80091b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	50                   	push   %eax
  800597:	ff d6                	call   *%esi
  800599:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	83 f8 25             	cmp    $0x25,%eax
  8005a6:	75 e2                	jne    80058a <vprintfmt+0x14>
  8005a8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c6:	eb 07                	jmp    8005cf <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005cb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8d 47 01             	lea    0x1(%edi),%eax
  8005d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d5:	0f b6 07             	movzbl (%edi),%eax
  8005d8:	0f b6 c8             	movzbl %al,%ecx
  8005db:	83 e8 23             	sub    $0x23,%eax
  8005de:	3c 55                	cmp    $0x55,%al
  8005e0:	0f 87 1a 03 00 00    	ja     800900 <vprintfmt+0x38a>
  8005e6:	0f b6 c0             	movzbl %al,%eax
  8005e9:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005f3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005f7:	eb d6                	jmp    8005cf <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800601:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800604:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800607:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80060b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80060e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800611:	83 fa 09             	cmp    $0x9,%edx
  800614:	77 39                	ja     80064f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800616:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800619:	eb e9                	jmp    800604 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 48 04             	lea    0x4(%eax),%ecx
  800621:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80062c:	eb 27                	jmp    800655 <vprintfmt+0xdf>
  80062e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800631:	85 c0                	test   %eax,%eax
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
  800638:	0f 49 c8             	cmovns %eax,%ecx
  80063b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	eb 8c                	jmp    8005cf <vprintfmt+0x59>
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800646:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80064d:	eb 80                	jmp    8005cf <vprintfmt+0x59>
  80064f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800652:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800655:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800659:	0f 89 70 ff ff ff    	jns    8005cf <vprintfmt+0x59>
				width = precision, precision = -1;
  80065f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800662:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800665:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80066c:	e9 5e ff ff ff       	jmp    8005cf <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800671:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800677:	e9 53 ff ff ff       	jmp    8005cf <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	ff 30                	pushl  (%eax)
  80068b:	ff d6                	call   *%esi
			break;
  80068d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800693:	e9 04 ff ff ff       	jmp    80059c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	99                   	cltd   
  8006a4:	31 d0                	xor    %edx,%eax
  8006a6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a8:	83 f8 0f             	cmp    $0xf,%eax
  8006ab:	7f 0b                	jg     8006b8 <vprintfmt+0x142>
  8006ad:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  8006b4:	85 d2                	test   %edx,%edx
  8006b6:	75 18                	jne    8006d0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8006b8:	50                   	push   %eax
  8006b9:	68 15 10 80 00       	push   $0x801015
  8006be:	53                   	push   %ebx
  8006bf:	56                   	push   %esi
  8006c0:	e8 94 fe ff ff       	call   800559 <printfmt>
  8006c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006cb:	e9 cc fe ff ff       	jmp    80059c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006d0:	52                   	push   %edx
  8006d1:	68 1e 10 80 00       	push   $0x80101e
  8006d6:	53                   	push   %ebx
  8006d7:	56                   	push   %esi
  8006d8:	e8 7c fe ff ff       	call   800559 <printfmt>
  8006dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e3:	e9 b4 fe ff ff       	jmp    80059c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006f3:	85 ff                	test   %edi,%edi
  8006f5:	b8 0e 10 80 00       	mov    $0x80100e,%eax
  8006fa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800701:	0f 8e 94 00 00 00    	jle    80079b <vprintfmt+0x225>
  800707:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80070b:	0f 84 98 00 00 00    	je     8007a9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	ff 75 d0             	pushl  -0x30(%ebp)
  800717:	57                   	push   %edi
  800718:	e8 86 02 00 00       	call   8009a3 <strnlen>
  80071d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800720:	29 c1                	sub    %eax,%ecx
  800722:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800725:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800728:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80072c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80072f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800732:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800734:	eb 0f                	jmp    800745 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	ff 75 e0             	pushl  -0x20(%ebp)
  80073d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80073f:	83 ef 01             	sub    $0x1,%edi
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	85 ff                	test   %edi,%edi
  800747:	7f ed                	jg     800736 <vprintfmt+0x1c0>
  800749:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80074c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80074f:	85 c9                	test   %ecx,%ecx
  800751:	b8 00 00 00 00       	mov    $0x0,%eax
  800756:	0f 49 c1             	cmovns %ecx,%eax
  800759:	29 c1                	sub    %eax,%ecx
  80075b:	89 75 08             	mov    %esi,0x8(%ebp)
  80075e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800761:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800764:	89 cb                	mov    %ecx,%ebx
  800766:	eb 4d                	jmp    8007b5 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800768:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80076c:	74 1b                	je     800789 <vprintfmt+0x213>
  80076e:	0f be c0             	movsbl %al,%eax
  800771:	83 e8 20             	sub    $0x20,%eax
  800774:	83 f8 5e             	cmp    $0x5e,%eax
  800777:	76 10                	jbe    800789 <vprintfmt+0x213>
					putch('?', putdat);
  800779:	83 ec 08             	sub    $0x8,%esp
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	6a 3f                	push   $0x3f
  800781:	ff 55 08             	call   *0x8(%ebp)
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 0d                	jmp    800796 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	52                   	push   %edx
  800790:	ff 55 08             	call   *0x8(%ebp)
  800793:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800796:	83 eb 01             	sub    $0x1,%ebx
  800799:	eb 1a                	jmp    8007b5 <vprintfmt+0x23f>
  80079b:	89 75 08             	mov    %esi,0x8(%ebp)
  80079e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007a7:	eb 0c                	jmp    8007b5 <vprintfmt+0x23f>
  8007a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8007ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007b5:	83 c7 01             	add    $0x1,%edi
  8007b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007bc:	0f be d0             	movsbl %al,%edx
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	74 23                	je     8007e6 <vprintfmt+0x270>
  8007c3:	85 f6                	test   %esi,%esi
  8007c5:	78 a1                	js     800768 <vprintfmt+0x1f2>
  8007c7:	83 ee 01             	sub    $0x1,%esi
  8007ca:	79 9c                	jns    800768 <vprintfmt+0x1f2>
  8007cc:	89 df                	mov    %ebx,%edi
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d4:	eb 18                	jmp    8007ee <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	53                   	push   %ebx
  8007da:	6a 20                	push   $0x20
  8007dc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007de:	83 ef 01             	sub    $0x1,%edi
  8007e1:	83 c4 10             	add    $0x10,%esp
  8007e4:	eb 08                	jmp    8007ee <vprintfmt+0x278>
  8007e6:	89 df                	mov    %ebx,%edi
  8007e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ee:	85 ff                	test   %edi,%edi
  8007f0:	7f e4                	jg     8007d6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f5:	e9 a2 fd ff ff       	jmp    80059c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007fa:	83 fa 01             	cmp    $0x1,%edx
  8007fd:	7e 16                	jle    800815 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8d 50 08             	lea    0x8(%eax),%edx
  800805:	89 55 14             	mov    %edx,0x14(%ebp)
  800808:	8b 50 04             	mov    0x4(%eax),%edx
  80080b:	8b 00                	mov    (%eax),%eax
  80080d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800810:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800813:	eb 32                	jmp    800847 <vprintfmt+0x2d1>
	else if (lflag)
  800815:	85 d2                	test   %edx,%edx
  800817:	74 18                	je     800831 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8d 50 04             	lea    0x4(%eax),%edx
  80081f:	89 55 14             	mov    %edx,0x14(%ebp)
  800822:	8b 00                	mov    (%eax),%eax
  800824:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800827:	89 c1                	mov    %eax,%ecx
  800829:	c1 f9 1f             	sar    $0x1f,%ecx
  80082c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80082f:	eb 16                	jmp    800847 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8d 50 04             	lea    0x4(%eax),%edx
  800837:	89 55 14             	mov    %edx,0x14(%ebp)
  80083a:	8b 00                	mov    (%eax),%eax
  80083c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083f:	89 c1                	mov    %eax,%ecx
  800841:	c1 f9 1f             	sar    $0x1f,%ecx
  800844:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800847:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80084a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80084d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800852:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800856:	79 74                	jns    8008cc <vprintfmt+0x356>
				putch('-', putdat);
  800858:	83 ec 08             	sub    $0x8,%esp
  80085b:	53                   	push   %ebx
  80085c:	6a 2d                	push   $0x2d
  80085e:	ff d6                	call   *%esi
				num = -(long long) num;
  800860:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800863:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800866:	f7 d8                	neg    %eax
  800868:	83 d2 00             	adc    $0x0,%edx
  80086b:	f7 da                	neg    %edx
  80086d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800870:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800875:	eb 55                	jmp    8008cc <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800877:	8d 45 14             	lea    0x14(%ebp),%eax
  80087a:	e8 83 fc ff ff       	call   800502 <getuint>
			base = 10;
  80087f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800884:	eb 46                	jmp    8008cc <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800886:	8d 45 14             	lea    0x14(%ebp),%eax
  800889:	e8 74 fc ff ff       	call   800502 <getuint>
			base = 8;
  80088e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800893:	eb 37                	jmp    8008cc <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	6a 30                	push   $0x30
  80089b:	ff d6                	call   *%esi
			putch('x', putdat);
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	6a 78                	push   $0x78
  8008a3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	8d 50 04             	lea    0x4(%eax),%edx
  8008ab:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ae:	8b 00                	mov    (%eax),%eax
  8008b0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008bd:	eb 0d                	jmp    8008cc <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c2:	e8 3b fc ff ff       	call   800502 <getuint>
			base = 16;
  8008c7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008cc:	83 ec 0c             	sub    $0xc,%esp
  8008cf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d3:	57                   	push   %edi
  8008d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d7:	51                   	push   %ecx
  8008d8:	52                   	push   %edx
  8008d9:	50                   	push   %eax
  8008da:	89 da                	mov    %ebx,%edx
  8008dc:	89 f0                	mov    %esi,%eax
  8008de:	e8 70 fb ff ff       	call   800453 <printnum>
			break;
  8008e3:	83 c4 20             	add    $0x20,%esp
  8008e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008e9:	e9 ae fc ff ff       	jmp    80059c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ee:	83 ec 08             	sub    $0x8,%esp
  8008f1:	53                   	push   %ebx
  8008f2:	51                   	push   %ecx
  8008f3:	ff d6                	call   *%esi
			break;
  8008f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008fb:	e9 9c fc ff ff       	jmp    80059c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	53                   	push   %ebx
  800904:	6a 25                	push   $0x25
  800906:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	eb 03                	jmp    800910 <vprintfmt+0x39a>
  80090d:	83 ef 01             	sub    $0x1,%edi
  800910:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800914:	75 f7                	jne    80090d <vprintfmt+0x397>
  800916:	e9 81 fc ff ff       	jmp    80059c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80091b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5f                   	pop    %edi
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	83 ec 18             	sub    $0x18,%esp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800932:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800936:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800939:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800940:	85 c0                	test   %eax,%eax
  800942:	74 26                	je     80096a <vsnprintf+0x47>
  800944:	85 d2                	test   %edx,%edx
  800946:	7e 22                	jle    80096a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800948:	ff 75 14             	pushl  0x14(%ebp)
  80094b:	ff 75 10             	pushl  0x10(%ebp)
  80094e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800951:	50                   	push   %eax
  800952:	68 3c 05 80 00       	push   $0x80053c
  800957:	e8 1a fc ff ff       	call   800576 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80095c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800965:	83 c4 10             	add    $0x10,%esp
  800968:	eb 05                	jmp    80096f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80096a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800977:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097a:	50                   	push   %eax
  80097b:	ff 75 10             	pushl  0x10(%ebp)
  80097e:	ff 75 0c             	pushl  0xc(%ebp)
  800981:	ff 75 08             	pushl  0x8(%ebp)
  800984:	e8 9a ff ff ff       	call   800923 <vsnprintf>
	va_end(ap);

	return rc;
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
  800996:	eb 03                	jmp    80099b <strlen+0x10>
		n++;
  800998:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80099b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80099f:	75 f7                	jne    800998 <strlen+0xd>
		n++;
	return n;
}
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b1:	eb 03                	jmp    8009b6 <strnlen+0x13>
		n++;
  8009b3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b6:	39 c2                	cmp    %eax,%edx
  8009b8:	74 08                	je     8009c2 <strnlen+0x1f>
  8009ba:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009be:	75 f3                	jne    8009b3 <strnlen+0x10>
  8009c0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009ce:	89 c2                	mov    %eax,%edx
  8009d0:	83 c2 01             	add    $0x1,%edx
  8009d3:	83 c1 01             	add    $0x1,%ecx
  8009d6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009da:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009dd:	84 db                	test   %bl,%bl
  8009df:	75 ef                	jne    8009d0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009eb:	53                   	push   %ebx
  8009ec:	e8 9a ff ff ff       	call   80098b <strlen>
  8009f1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009f4:	ff 75 0c             	pushl  0xc(%ebp)
  8009f7:	01 d8                	add    %ebx,%eax
  8009f9:	50                   	push   %eax
  8009fa:	e8 c5 ff ff ff       	call   8009c4 <strcpy>
	return dst;
}
  8009ff:	89 d8                	mov    %ebx,%eax
  800a01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a11:	89 f3                	mov    %esi,%ebx
  800a13:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a16:	89 f2                	mov    %esi,%edx
  800a18:	eb 0f                	jmp    800a29 <strncpy+0x23>
		*dst++ = *src;
  800a1a:	83 c2 01             	add    $0x1,%edx
  800a1d:	0f b6 01             	movzbl (%ecx),%eax
  800a20:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a23:	80 39 01             	cmpb   $0x1,(%ecx)
  800a26:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a29:	39 da                	cmp    %ebx,%edx
  800a2b:	75 ed                	jne    800a1a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a2d:	89 f0                	mov    %esi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3e:	8b 55 10             	mov    0x10(%ebp),%edx
  800a41:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a43:	85 d2                	test   %edx,%edx
  800a45:	74 21                	je     800a68 <strlcpy+0x35>
  800a47:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a4b:	89 f2                	mov    %esi,%edx
  800a4d:	eb 09                	jmp    800a58 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a4f:	83 c2 01             	add    $0x1,%edx
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a58:	39 c2                	cmp    %eax,%edx
  800a5a:	74 09                	je     800a65 <strlcpy+0x32>
  800a5c:	0f b6 19             	movzbl (%ecx),%ebx
  800a5f:	84 db                	test   %bl,%bl
  800a61:	75 ec                	jne    800a4f <strlcpy+0x1c>
  800a63:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a65:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a68:	29 f0                	sub    %esi,%eax
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a74:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a77:	eb 06                	jmp    800a7f <strcmp+0x11>
		p++, q++;
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a7f:	0f b6 01             	movzbl (%ecx),%eax
  800a82:	84 c0                	test   %al,%al
  800a84:	74 04                	je     800a8a <strcmp+0x1c>
  800a86:	3a 02                	cmp    (%edx),%al
  800a88:	74 ef                	je     800a79 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8a:	0f b6 c0             	movzbl %al,%eax
  800a8d:	0f b6 12             	movzbl (%edx),%edx
  800a90:	29 d0                	sub    %edx,%eax
}
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	53                   	push   %ebx
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9e:	89 c3                	mov    %eax,%ebx
  800aa0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa3:	eb 06                	jmp    800aab <strncmp+0x17>
		n--, p++, q++;
  800aa5:	83 c0 01             	add    $0x1,%eax
  800aa8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aab:	39 d8                	cmp    %ebx,%eax
  800aad:	74 15                	je     800ac4 <strncmp+0x30>
  800aaf:	0f b6 08             	movzbl (%eax),%ecx
  800ab2:	84 c9                	test   %cl,%cl
  800ab4:	74 04                	je     800aba <strncmp+0x26>
  800ab6:	3a 0a                	cmp    (%edx),%cl
  800ab8:	74 eb                	je     800aa5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aba:	0f b6 00             	movzbl (%eax),%eax
  800abd:	0f b6 12             	movzbl (%edx),%edx
  800ac0:	29 d0                	sub    %edx,%eax
  800ac2:	eb 05                	jmp    800ac9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad6:	eb 07                	jmp    800adf <strchr+0x13>
		if (*s == c)
  800ad8:	38 ca                	cmp    %cl,%dl
  800ada:	74 0f                	je     800aeb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800adc:	83 c0 01             	add    $0x1,%eax
  800adf:	0f b6 10             	movzbl (%eax),%edx
  800ae2:	84 d2                	test   %dl,%dl
  800ae4:	75 f2                	jne    800ad8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ae6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af7:	eb 03                	jmp    800afc <strfind+0xf>
  800af9:	83 c0 01             	add    $0x1,%eax
  800afc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aff:	38 ca                	cmp    %cl,%dl
  800b01:	74 04                	je     800b07 <strfind+0x1a>
  800b03:	84 d2                	test   %dl,%dl
  800b05:	75 f2                	jne    800af9 <strfind+0xc>
			break;
	return (char *) s;
}
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
  800b0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b15:	85 c9                	test   %ecx,%ecx
  800b17:	74 36                	je     800b4f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1f:	75 28                	jne    800b49 <memset+0x40>
  800b21:	f6 c1 03             	test   $0x3,%cl
  800b24:	75 23                	jne    800b49 <memset+0x40>
		c &= 0xFF;
  800b26:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b2a:	89 d3                	mov    %edx,%ebx
  800b2c:	c1 e3 08             	shl    $0x8,%ebx
  800b2f:	89 d6                	mov    %edx,%esi
  800b31:	c1 e6 18             	shl    $0x18,%esi
  800b34:	89 d0                	mov    %edx,%eax
  800b36:	c1 e0 10             	shl    $0x10,%eax
  800b39:	09 f0                	or     %esi,%eax
  800b3b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b3d:	89 d8                	mov    %ebx,%eax
  800b3f:	09 d0                	or     %edx,%eax
  800b41:	c1 e9 02             	shr    $0x2,%ecx
  800b44:	fc                   	cld    
  800b45:	f3 ab                	rep stos %eax,%es:(%edi)
  800b47:	eb 06                	jmp    800b4f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4c:	fc                   	cld    
  800b4d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b4f:	89 f8                	mov    %edi,%eax
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b61:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b64:	39 c6                	cmp    %eax,%esi
  800b66:	73 35                	jae    800b9d <memmove+0x47>
  800b68:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b6b:	39 d0                	cmp    %edx,%eax
  800b6d:	73 2e                	jae    800b9d <memmove+0x47>
		s += n;
		d += n;
  800b6f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	09 fe                	or     %edi,%esi
  800b76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b7c:	75 13                	jne    800b91 <memmove+0x3b>
  800b7e:	f6 c1 03             	test   $0x3,%cl
  800b81:	75 0e                	jne    800b91 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b83:	83 ef 04             	sub    $0x4,%edi
  800b86:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b89:	c1 e9 02             	shr    $0x2,%ecx
  800b8c:	fd                   	std    
  800b8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8f:	eb 09                	jmp    800b9a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b91:	83 ef 01             	sub    $0x1,%edi
  800b94:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b97:	fd                   	std    
  800b98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9a:	fc                   	cld    
  800b9b:	eb 1d                	jmp    800bba <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9d:	89 f2                	mov    %esi,%edx
  800b9f:	09 c2                	or     %eax,%edx
  800ba1:	f6 c2 03             	test   $0x3,%dl
  800ba4:	75 0f                	jne    800bb5 <memmove+0x5f>
  800ba6:	f6 c1 03             	test   $0x3,%cl
  800ba9:	75 0a                	jne    800bb5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bab:	c1 e9 02             	shr    $0x2,%ecx
  800bae:	89 c7                	mov    %eax,%edi
  800bb0:	fc                   	cld    
  800bb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb3:	eb 05                	jmp    800bba <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb5:	89 c7                	mov    %eax,%edi
  800bb7:	fc                   	cld    
  800bb8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc1:	ff 75 10             	pushl  0x10(%ebp)
  800bc4:	ff 75 0c             	pushl  0xc(%ebp)
  800bc7:	ff 75 08             	pushl  0x8(%ebp)
  800bca:	e8 87 ff ff ff       	call   800b56 <memmove>
}
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdc:	89 c6                	mov    %eax,%esi
  800bde:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be1:	eb 1a                	jmp    800bfd <memcmp+0x2c>
		if (*s1 != *s2)
  800be3:	0f b6 08             	movzbl (%eax),%ecx
  800be6:	0f b6 1a             	movzbl (%edx),%ebx
  800be9:	38 d9                	cmp    %bl,%cl
  800beb:	74 0a                	je     800bf7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bed:	0f b6 c1             	movzbl %cl,%eax
  800bf0:	0f b6 db             	movzbl %bl,%ebx
  800bf3:	29 d8                	sub    %ebx,%eax
  800bf5:	eb 0f                	jmp    800c06 <memcmp+0x35>
		s1++, s2++;
  800bf7:	83 c0 01             	add    $0x1,%eax
  800bfa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfd:	39 f0                	cmp    %esi,%eax
  800bff:	75 e2                	jne    800be3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c11:	89 c1                	mov    %eax,%ecx
  800c13:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c16:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1a:	eb 0a                	jmp    800c26 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1c:	0f b6 10             	movzbl (%eax),%edx
  800c1f:	39 da                	cmp    %ebx,%edx
  800c21:	74 07                	je     800c2a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	39 c8                	cmp    %ecx,%eax
  800c28:	72 f2                	jb     800c1c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c2a:	5b                   	pop    %ebx
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c39:	eb 03                	jmp    800c3e <strtol+0x11>
		s++;
  800c3b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3e:	0f b6 01             	movzbl (%ecx),%eax
  800c41:	3c 20                	cmp    $0x20,%al
  800c43:	74 f6                	je     800c3b <strtol+0xe>
  800c45:	3c 09                	cmp    $0x9,%al
  800c47:	74 f2                	je     800c3b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c49:	3c 2b                	cmp    $0x2b,%al
  800c4b:	75 0a                	jne    800c57 <strtol+0x2a>
		s++;
  800c4d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c50:	bf 00 00 00 00       	mov    $0x0,%edi
  800c55:	eb 11                	jmp    800c68 <strtol+0x3b>
  800c57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c5c:	3c 2d                	cmp    $0x2d,%al
  800c5e:	75 08                	jne    800c68 <strtol+0x3b>
		s++, neg = 1;
  800c60:	83 c1 01             	add    $0x1,%ecx
  800c63:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c68:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c6e:	75 15                	jne    800c85 <strtol+0x58>
  800c70:	80 39 30             	cmpb   $0x30,(%ecx)
  800c73:	75 10                	jne    800c85 <strtol+0x58>
  800c75:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c79:	75 7c                	jne    800cf7 <strtol+0xca>
		s += 2, base = 16;
  800c7b:	83 c1 02             	add    $0x2,%ecx
  800c7e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c83:	eb 16                	jmp    800c9b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c85:	85 db                	test   %ebx,%ebx
  800c87:	75 12                	jne    800c9b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c89:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c91:	75 08                	jne    800c9b <strtol+0x6e>
		s++, base = 8;
  800c93:	83 c1 01             	add    $0x1,%ecx
  800c96:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca3:	0f b6 11             	movzbl (%ecx),%edx
  800ca6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ca9:	89 f3                	mov    %esi,%ebx
  800cab:	80 fb 09             	cmp    $0x9,%bl
  800cae:	77 08                	ja     800cb8 <strtol+0x8b>
			dig = *s - '0';
  800cb0:	0f be d2             	movsbl %dl,%edx
  800cb3:	83 ea 30             	sub    $0x30,%edx
  800cb6:	eb 22                	jmp    800cda <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cb8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cbb:	89 f3                	mov    %esi,%ebx
  800cbd:	80 fb 19             	cmp    $0x19,%bl
  800cc0:	77 08                	ja     800cca <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cc2:	0f be d2             	movsbl %dl,%edx
  800cc5:	83 ea 57             	sub    $0x57,%edx
  800cc8:	eb 10                	jmp    800cda <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cca:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ccd:	89 f3                	mov    %esi,%ebx
  800ccf:	80 fb 19             	cmp    $0x19,%bl
  800cd2:	77 16                	ja     800cea <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cd4:	0f be d2             	movsbl %dl,%edx
  800cd7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cda:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cdd:	7d 0b                	jge    800cea <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cdf:	83 c1 01             	add    $0x1,%ecx
  800ce2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ce6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ce8:	eb b9                	jmp    800ca3 <strtol+0x76>

	if (endptr)
  800cea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cee:	74 0d                	je     800cfd <strtol+0xd0>
		*endptr = (char *) s;
  800cf0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf3:	89 0e                	mov    %ecx,(%esi)
  800cf5:	eb 06                	jmp    800cfd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	74 98                	je     800c93 <strtol+0x66>
  800cfb:	eb 9e                	jmp    800c9b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cfd:	89 c2                	mov    %eax,%edx
  800cff:	f7 da                	neg    %edx
  800d01:	85 ff                	test   %edi,%edi
  800d03:	0f 45 c2             	cmovne %edx,%eax
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    
  800d0b:	66 90                	xchg   %ax,%ax
  800d0d:	66 90                	xchg   %ax,%ax
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
