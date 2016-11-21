
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 fb 06 00 00       	call   80072c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	envid_t ns_envid = sys_getenvid();
  80003c:	e8 66 11 00 00       	call   8011a7 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 30 80 00 a0 	movl   $0x801ba0,0x803000
  80004a:	1b 80 00 

	output_envid = fork();
  80004d:	e8 93 14 00 00       	call   8014e5 <fork>
  800052:	a3 08 30 80 00       	mov    %eax,0x803008
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	79 14                	jns    80006f <umain+0x3c>
		panic("error forking");
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	68 aa 1b 80 00       	push   $0x801baa
  800063:	6a 4d                	push   $0x4d
  800065:	68 b8 1b 80 00       	push   $0x801bb8
  80006a:	e8 15 07 00 00       	call   800784 <_panic>
	else if (output_envid == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 11                	jne    800084 <umain+0x51>
		output(ns_envid);
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	53                   	push   %ebx
  800077:	e8 bd 03 00 00       	call   800439 <output>
		return;
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	e9 0b 03 00 00       	jmp    80038f <umain+0x35c>
	}

	input_envid = fork();
  800084:	e8 5c 14 00 00       	call   8014e5 <fork>
  800089:	a3 04 30 80 00       	mov    %eax,0x803004
	if (input_envid < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 14                	jns    8000a6 <umain+0x73>
		panic("error forking");
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	68 aa 1b 80 00       	push   $0x801baa
  80009a:	6a 55                	push   $0x55
  80009c:	68 b8 1b 80 00       	push   $0x801bb8
  8000a1:	e8 de 06 00 00       	call   800784 <_panic>
	else if (input_envid == 0) {
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 11                	jne    8000bb <umain+0x88>
		input(ns_envid);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	53                   	push   %ebx
  8000ae:	e8 77 03 00 00       	call   80042a <input>
		return;
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	e9 d4 02 00 00       	jmp    80038f <umain+0x35c>
	}

	cprintf("Sending ARP announcement...\n");
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 c8 1b 80 00       	push   $0x801bc8
  8000c3:	e8 95 07 00 00       	call   80085d <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000c8:	c6 45 98 52          	movb   $0x52,-0x68(%ebp)
  8000cc:	c6 45 99 54          	movb   $0x54,-0x67(%ebp)
  8000d0:	c6 45 9a 00          	movb   $0x0,-0x66(%ebp)
  8000d4:	c6 45 9b 12          	movb   $0x12,-0x65(%ebp)
  8000d8:	c6 45 9c 34          	movb   $0x34,-0x64(%ebp)
  8000dc:	c6 45 9d 56          	movb   $0x56,-0x63(%ebp)
	uint32_t myip = inet_addr(IP);
  8000e0:	c7 04 24 e5 1b 80 00 	movl   $0x801be5,(%esp)
  8000e7:	e8 0e 06 00 00       	call   8006fa <inet_addr>
  8000ec:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000ef:	c7 04 24 ef 1b 80 00 	movl   $0x801bef,(%esp)
  8000f6:	e8 ff 05 00 00       	call   8006fa <inet_addr>
  8000fb:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000fe:	83 c4 0c             	add    $0xc,%esp
  800101:	6a 07                	push   $0x7
  800103:	68 00 b0 fe 0f       	push   $0xffeb000
  800108:	6a 00                	push   $0x0
  80010a:	e8 d6 10 00 00       	call   8011e5 <sys_page_alloc>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	79 12                	jns    800128 <umain+0xf5>
		panic("sys_page_map: %e", r);
  800116:	50                   	push   %eax
  800117:	68 50 21 80 00       	push   $0x802150
  80011c:	6a 19                	push   $0x19
  80011e:	68 b8 1b 80 00       	push   $0x801bb8
  800123:	e8 5c 06 00 00       	call   800784 <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800128:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80012f:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800132:	83 ec 04             	sub    $0x4,%esp
  800135:	6a 06                	push   $0x6
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	68 04 b0 fe 0f       	push   $0xffeb004
  800141:	e8 e1 0d 00 00       	call   800f27 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	6a 06                	push   $0x6
  80014b:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  80014e:	53                   	push   %ebx
  80014f:	68 0a b0 fe 0f       	push   $0xffeb00a
  800154:	e8 83 0e 00 00       	call   800fdc <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800159:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800160:	e8 7c 03 00 00       	call   8004e1 <htons>
  800165:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80016b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800172:	e8 6a 03 00 00       	call   8004e1 <htons>
  800177:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80017d:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800184:	e8 58 03 00 00       	call   8004e1 <htons>
  800189:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80018f:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800196:	e8 46 03 00 00       	call   8004e1 <htons>
  80019b:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a8:	e8 34 03 00 00       	call   8004e1 <htons>
  8001ad:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001b3:	83 c4 0c             	add    $0xc,%esp
  8001b6:	6a 06                	push   $0x6
  8001b8:	53                   	push   %ebx
  8001b9:	68 1a b0 fe 0f       	push   $0xffeb01a
  8001be:	e8 19 0e 00 00       	call   800fdc <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001c3:	83 c4 0c             	add    $0xc,%esp
  8001c6:	6a 04                	push   $0x4
  8001c8:	8d 45 90             	lea    -0x70(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 20 b0 fe 0f       	push   $0xffeb020
  8001d1:	e8 06 0e 00 00       	call   800fdc <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  8001d6:	83 c4 0c             	add    $0xc,%esp
  8001d9:	6a 06                	push   $0x6
  8001db:	6a 00                	push   $0x0
  8001dd:	68 24 b0 fe 0f       	push   $0xffeb024
  8001e2:	e8 40 0d 00 00       	call   800f27 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  8001e7:	83 c4 0c             	add    $0xc,%esp
  8001ea:	6a 04                	push   $0x4
  8001ec:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001f5:	e8 e2 0d 00 00       	call   800fdc <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001fa:	6a 07                	push   $0x7
  8001fc:	68 00 b0 fe 0f       	push   $0xffeb000
  800201:	6a 0b                	push   $0xb
  800203:	ff 35 08 30 80 00    	pushl  0x803008
  800209:	e8 85 15 00 00       	call   801793 <ipc_send>
	sys_page_unmap(0, pkt);
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	68 00 b0 fe 0f       	push   $0xffeb000
  800216:	6a 00                	push   $0x0
  800218:	e8 4d 10 00 00       	call   80126a <sys_page_unmap>
  80021d:	83 c4 10             	add    $0x10,%esp

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800220:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  800227:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800230:	50                   	push   %eax
  800231:	68 00 b0 fe 0f       	push   $0xffeb000
  800236:	8d 45 90             	lea    -0x70(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	e8 df 14 00 00       	call   80171e <ipc_recv>
		if (req < 0)
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	85 c0                	test   %eax,%eax
  800244:	79 12                	jns    800258 <umain+0x225>
			panic("ipc_recv: %e", req);
  800246:	50                   	push   %eax
  800247:	68 f8 1b 80 00       	push   $0x801bf8
  80024c:	6a 64                	push   $0x64
  80024e:	68 b8 1b 80 00       	push   $0x801bb8
  800253:	e8 2c 05 00 00       	call   800784 <_panic>
		if (whom != input_envid)
  800258:	8b 55 90             	mov    -0x70(%ebp),%edx
  80025b:	3b 15 04 30 80 00    	cmp    0x803004,%edx
  800261:	74 12                	je     800275 <umain+0x242>
			panic("IPC from unexpected environment %08x", whom);
  800263:	52                   	push   %edx
  800264:	68 4c 1c 80 00       	push   $0x801c4c
  800269:	6a 66                	push   $0x66
  80026b:	68 b8 1b 80 00       	push   $0x801bb8
  800270:	e8 0f 05 00 00       	call   800784 <_panic>
		if (req != NSREQ_INPUT)
  800275:	83 f8 0a             	cmp    $0xa,%eax
  800278:	74 12                	je     80028c <umain+0x259>
			panic("Unexpected IPC %d", req);
  80027a:	50                   	push   %eax
  80027b:	68 05 1c 80 00       	push   $0x801c05
  800280:	6a 68                	push   $0x68
  800282:	68 b8 1b 80 00       	push   $0x801bb8
  800287:	e8 f8 04 00 00       	call   800784 <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80028c:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800291:	89 45 84             	mov    %eax,-0x7c(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800294:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  80029e:	83 e8 01             	sub    $0x1,%eax
  8002a1:	89 45 80             	mov    %eax,-0x80(%ebp)
  8002a4:	e9 a5 00 00 00       	jmp    80034e <umain+0x31b>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  8002a9:	89 df                	mov    %ebx,%edi
  8002ab:	f6 c3 0f             	test   $0xf,%bl
  8002ae:	75 22                	jne    8002d2 <umain+0x29f>
			out = buf + snprintf(buf, end - buf,
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	53                   	push   %ebx
  8002b4:	68 17 1c 80 00       	push   $0x801c17
  8002b9:	68 1f 1c 80 00       	push   $0x801c1f
  8002be:	6a 50                	push   $0x50
  8002c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 c6 0a 00 00       	call   800d8f <snprintf>
  8002c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8002cc:	8d 34 01             	lea    (%ecx,%eax,1),%esi
  8002cf:	83 c4 20             	add    $0x20,%esp
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d2:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  8002d7:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
  8002db:	50                   	push   %eax
  8002dc:	68 29 1c 80 00       	push   $0x801c29
  8002e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e4:	29 f0                	sub    %esi,%eax
  8002e6:	50                   	push   %eax
  8002e7:	56                   	push   %esi
  8002e8:	e8 a2 0a 00 00       	call   800d8f <snprintf>
  8002ed:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8002ef:	89 d8                	mov    %ebx,%eax
  8002f1:	c1 f8 1f             	sar    $0x1f,%eax
  8002f4:	c1 e8 1c             	shr    $0x1c,%eax
  8002f7:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8002fa:	83 e7 0f             	and    $0xf,%edi
  8002fd:	29 c7                	sub    %eax,%edi
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	83 ff 0f             	cmp    $0xf,%edi
  800305:	74 05                	je     80030c <umain+0x2d9>
  800307:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  80030a:	75 1c                	jne    800328 <umain+0x2f5>
			cprintf("%.*s\n", out - buf, buf);
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	8d 45 98             	lea    -0x68(%ebp),%eax
  800312:	50                   	push   %eax
  800313:	89 f0                	mov    %esi,%eax
  800315:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  800318:	29 c8                	sub    %ecx,%eax
  80031a:	50                   	push   %eax
  80031b:	68 2e 1c 80 00       	push   $0x801c2e
  800320:	e8 38 05 00 00       	call   80085d <cprintf>
  800325:	83 c4 10             	add    $0x10,%esp
		if (i % 2 == 1)
  800328:	89 da                	mov    %ebx,%edx
  80032a:	c1 ea 1f             	shr    $0x1f,%edx
  80032d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800330:	83 e0 01             	and    $0x1,%eax
  800333:	29 d0                	sub    %edx,%eax
  800335:	83 f8 01             	cmp    $0x1,%eax
  800338:	75 06                	jne    800340 <umain+0x30d>
			*(out++) = ' ';
  80033a:	c6 06 20             	movb   $0x20,(%esi)
  80033d:	8d 76 01             	lea    0x1(%esi),%esi
		if (i % 16 == 7)
  800340:	83 ff 07             	cmp    $0x7,%edi
  800343:	75 06                	jne    80034b <umain+0x318>
			*(out++) = ' ';
  800345:	c6 06 20             	movb   $0x20,(%esi)
  800348:	8d 76 01             	lea    0x1(%esi),%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  80034b:	83 c3 01             	add    $0x1,%ebx
  80034e:	3b 5d 84             	cmp    -0x7c(%ebp),%ebx
  800351:	0f 8c 52 ff ff ff    	jl     8002a9 <umain+0x276>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	68 4a 1c 80 00       	push   $0x801c4a
  80035f:	e8 f9 04 00 00       	call   80085d <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  80036e:	74 10                	je     800380 <umain+0x34d>
			cprintf("Waiting for packets...\n");
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	68 34 1c 80 00       	push   $0x801c34
  800378:	e8 e0 04 00 00       	call   80085d <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp
		first = 0;
  800380:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  800387:	00 00 00 
	}
  80038a:	e9 9b fe ff ff       	jmp    80022a <umain+0x1f7>
}
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 1c             	sub    $0x1c,%esp
  8003a0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  8003a3:	e8 2e 10 00 00       	call   8013d6 <sys_time_msec>
  8003a8:	03 45 0c             	add    0xc(%ebp),%eax
  8003ab:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ad:	c7 05 00 30 80 00 71 	movl   $0x801c71,0x803000
  8003b4:	1c 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003b7:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8003ba:	eb 05                	jmp    8003c1 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  8003bc:	e8 05 0e 00 00       	call   8011c6 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003c1:	e8 10 10 00 00       	call   8013d6 <sys_time_msec>
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	78 04                	js     8003d0 <timer+0x39>
  8003cc:	39 c3                	cmp    %eax,%ebx
  8003ce:	77 ec                	ja     8003bc <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	79 12                	jns    8003e6 <timer+0x4f>
			panic("sys_time_msec: %e", r);
  8003d4:	52                   	push   %edx
  8003d5:	68 7a 1c 80 00       	push   $0x801c7a
  8003da:	6a 0f                	push   $0xf
  8003dc:	68 8c 1c 80 00       	push   $0x801c8c
  8003e1:	e8 9e 03 00 00       	call   800784 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003e6:	6a 00                	push   $0x0
  8003e8:	6a 00                	push   $0x0
  8003ea:	6a 0c                	push   $0xc
  8003ec:	56                   	push   %esi
  8003ed:	e8 a1 13 00 00       	call   801793 <ipc_send>
  8003f2:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 00                	push   $0x0
  8003fa:	6a 00                	push   $0x0
  8003fc:	57                   	push   %edi
  8003fd:	e8 1c 13 00 00       	call   80171e <ipc_recv>
  800402:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	39 f0                	cmp    %esi,%eax
  80040c:	74 13                	je     800421 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 98 1c 80 00       	push   $0x801c98
  800417:	e8 41 04 00 00       	call   80085d <cprintf>
				continue;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	eb d4                	jmp    8003f5 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  800421:	e8 b0 0f 00 00       	call   8013d6 <sys_time_msec>
  800426:	01 c3                	add    %eax,%ebx
  800428:	eb 97                	jmp    8003c1 <timer+0x2a>

0080042a <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  80042d:	c7 05 00 30 80 00 d3 	movl   $0x801cd3,0x803000
  800434:	1c 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    

00800439 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  80043c:	c7 05 00 30 80 00 dc 	movl   $0x801cdc,0x803000
  800443:	1c 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800457:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80045a:	c7 45 e0 0c 30 80 00 	movl   $0x80300c,-0x20(%ebp)
  800461:	0f b6 0f             	movzbl (%edi),%ecx
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800469:	0f b6 d9             	movzbl %cl,%ebx
  80046c:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80046f:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800472:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800475:	66 c1 e8 0b          	shr    $0xb,%ax
  800479:	89 c3                	mov    %eax,%ebx
  80047b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047e:	01 c0                	add    %eax,%eax
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800484:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800486:	8d 72 01             	lea    0x1(%edx),%esi
  800489:	0f b6 d2             	movzbl %dl,%edx
  80048c:	83 c0 30             	add    $0x30,%eax
  80048f:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800493:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800495:	84 db                	test   %bl,%bl
  800497:	75 d0                	jne    800469 <inet_ntoa+0x21>
  800499:	c6 07 00             	movb   $0x0,(%edi)
  80049c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049f:	eb 0d                	jmp    8004ae <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  8004a1:	0f b6 c2             	movzbl %dl,%eax
  8004a4:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8004a9:	88 01                	mov    %al,(%ecx)
  8004ab:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8004ae:	83 ea 01             	sub    $0x1,%edx
  8004b1:	80 fa ff             	cmp    $0xff,%dl
  8004b4:	75 eb                	jne    8004a1 <inet_ntoa+0x59>
  8004b6:	89 f0                	mov    %esi,%eax
  8004b8:	0f b6 f0             	movzbl %al,%esi
  8004bb:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  8004be:	8d 46 01             	lea    0x1(%esi),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  8004c7:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8004ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004cd:	39 c7                	cmp    %eax,%edi
  8004cf:	75 90                	jne    800461 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  8004d1:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  8004d4:	b8 0c 30 80 00       	mov    $0x80300c,%eax
  8004d9:	83 c4 14             	add    $0x14,%esp
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5f                   	pop    %edi
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8004e4:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004e8:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  return htons(n);
  8004f1:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004f5:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800501:	89 d1                	mov    %edx,%ecx
  800503:	c1 e1 18             	shl    $0x18,%ecx
  800506:	89 d0                	mov    %edx,%eax
  800508:	c1 e8 18             	shr    $0x18,%eax
  80050b:	09 c8                	or     %ecx,%eax
  80050d:	89 d1                	mov    %edx,%ecx
  80050f:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800515:	c1 e1 08             	shl    $0x8,%ecx
  800518:	09 c8                	or     %ecx,%eax
  80051a:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800520:	c1 ea 08             	shr    $0x8,%edx
  800523:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800525:	5d                   	pop    %ebp
  800526:	c3                   	ret    

00800527 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 20             	sub    $0x20,%esp
  800530:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800533:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800536:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800539:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80053c:	0f b6 ca             	movzbl %dl,%ecx
  80053f:	83 e9 30             	sub    $0x30,%ecx
  800542:	83 f9 09             	cmp    $0x9,%ecx
  800545:	0f 87 94 01 00 00    	ja     8006df <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  80054b:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  800552:	83 fa 30             	cmp    $0x30,%edx
  800555:	75 2b                	jne    800582 <inet_aton+0x5b>
      c = *++cp;
  800557:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80055b:	89 d1                	mov    %edx,%ecx
  80055d:	83 e1 df             	and    $0xffffffdf,%ecx
  800560:	80 f9 58             	cmp    $0x58,%cl
  800563:	74 0f                	je     800574 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800565:	83 c0 01             	add    $0x1,%eax
  800568:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  80056b:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800572:	eb 0e                	jmp    800582 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800574:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800578:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  80057b:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800582:	83 c0 01             	add    $0x1,%eax
  800585:	be 00 00 00 00       	mov    $0x0,%esi
  80058a:	eb 03                	jmp    80058f <inet_aton+0x68>
  80058c:	83 c0 01             	add    $0x1,%eax
  80058f:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800592:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800595:	0f b6 fa             	movzbl %dl,%edi
  800598:	8d 4f d0             	lea    -0x30(%edi),%ecx
  80059b:	83 f9 09             	cmp    $0x9,%ecx
  80059e:	77 0d                	ja     8005ad <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  8005a0:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8005a4:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8005a8:	0f be 10             	movsbl (%eax),%edx
  8005ab:	eb df                	jmp    80058c <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  8005ad:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8005b1:	75 32                	jne    8005e5 <inet_aton+0xbe>
  8005b3:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  8005b6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bc:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  8005c2:	83 e9 41             	sub    $0x41,%ecx
  8005c5:	83 f9 05             	cmp    $0x5,%ecx
  8005c8:	77 1b                	ja     8005e5 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8005ca:	c1 e6 04             	shl    $0x4,%esi
  8005cd:	83 c2 0a             	add    $0xa,%edx
  8005d0:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  8005d4:	19 c9                	sbb    %ecx,%ecx
  8005d6:	83 e1 20             	and    $0x20,%ecx
  8005d9:	83 c1 41             	add    $0x41,%ecx
  8005dc:	29 ca                	sub    %ecx,%edx
  8005de:	09 d6                	or     %edx,%esi
        c = *++cp;
  8005e0:	0f be 10             	movsbl (%eax),%edx
  8005e3:	eb a7                	jmp    80058c <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  8005e5:	83 fa 2e             	cmp    $0x2e,%edx
  8005e8:	75 23                	jne    80060d <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8005ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  8005f0:	39 f8                	cmp    %edi,%eax
  8005f2:	0f 84 ee 00 00 00    	je     8006e6 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  8005f8:	83 c0 04             	add    $0x4,%eax
  8005fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005fe:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800601:	8d 43 01             	lea    0x1(%ebx),%eax
  800604:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800608:	e9 2f ff ff ff       	jmp    80053c <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80060d:	85 d2                	test   %edx,%edx
  80060f:	74 25                	je     800636 <inet_aton+0x10f>
  800611:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800614:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800619:	83 f9 5f             	cmp    $0x5f,%ecx
  80061c:	0f 87 d0 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  800622:	83 fa 20             	cmp    $0x20,%edx
  800625:	74 0f                	je     800636 <inet_aton+0x10f>
  800627:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80062a:	83 ea 09             	sub    $0x9,%edx
  80062d:	83 fa 04             	cmp    $0x4,%edx
  800630:	0f 87 bc 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800636:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800639:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80063c:	29 c2                	sub    %eax,%edx
  80063e:	c1 fa 02             	sar    $0x2,%edx
  800641:	83 c2 01             	add    $0x1,%edx
  800644:	83 fa 02             	cmp    $0x2,%edx
  800647:	74 20                	je     800669 <inet_aton+0x142>
  800649:	83 fa 02             	cmp    $0x2,%edx
  80064c:	7f 0f                	jg     80065d <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  80064e:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800653:	85 d2                	test   %edx,%edx
  800655:	0f 84 97 00 00 00    	je     8006f2 <inet_aton+0x1cb>
  80065b:	eb 67                	jmp    8006c4 <inet_aton+0x19d>
  80065d:	83 fa 03             	cmp    $0x3,%edx
  800660:	74 1e                	je     800680 <inet_aton+0x159>
  800662:	83 fa 04             	cmp    $0x4,%edx
  800665:	74 38                	je     80069f <inet_aton+0x178>
  800667:	eb 5b                	jmp    8006c4 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800669:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80066e:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  800674:	77 7c                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  800676:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800679:	c1 e0 18             	shl    $0x18,%eax
  80067c:	09 c6                	or     %eax,%esi
    break;
  80067e:	eb 44                	jmp    8006c4 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800680:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800685:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  80068b:	77 65                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80068d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800690:	c1 e2 18             	shl    $0x18,%edx
  800693:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800696:	c1 e0 10             	shl    $0x10,%eax
  800699:	09 d0                	or     %edx,%eax
  80069b:	09 c6                	or     %eax,%esi
    break;
  80069d:	eb 25                	jmp    8006c4 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80069f:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8006a4:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  8006aa:	77 46                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8006ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006af:	c1 e2 18             	shl    $0x18,%edx
  8006b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006b5:	c1 e0 10             	shl    $0x10,%eax
  8006b8:	09 c2                	or     %eax,%edx
  8006ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bd:	c1 e0 08             	shl    $0x8,%eax
  8006c0:	09 d0                	or     %edx,%eax
  8006c2:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  8006c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006c8:	74 23                	je     8006ed <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  8006ca:	56                   	push   %esi
  8006cb:	e8 2b fe ff ff       	call   8004fb <htonl>
  8006d0:	83 c4 04             	add    $0x4,%esp
  8006d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d6:	89 03                	mov    %eax,(%ebx)
  return (1);
  8006d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8006dd:	eb 13                	jmp    8006f2 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 0c                	jmp    8006f2 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 05                	jmp    8006f2 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8006ed:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8006f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800700:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	ff 75 08             	pushl  0x8(%ebp)
  800707:	e8 1b fe ff ff       	call   800527 <inet_aton>
  80070c:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80070f:	85 c0                	test   %eax,%eax
  800711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800716:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80071f:	ff 75 08             	pushl  0x8(%ebp)
  800722:	e8 d4 fd ff ff       	call   8004fb <htonl>
  800727:	83 c4 04             	add    $0x4,%esp
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800734:	8b 75 0c             	mov    0xc(%ebp),%esi
	//thisenv = 0;
	/*uint32_t id = sys_getenvid();
	int index = id & (1023); 
	thisenv = &envs[index];*/
	
	thisenv = envs + ENVX(sys_getenvid());
  800737:	e8 6b 0a 00 00       	call   8011a7 <sys_getenvid>
  80073c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800741:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800744:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800749:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80074e:	85 db                	test   %ebx,%ebx
  800750:	7e 07                	jle    800759 <libmain+0x2d>
		binaryname = argv[0];
  800752:	8b 06                	mov    (%esi),%eax
  800754:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	e8 d0 f8 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800763:	e8 0a 00 00 00       	call   800772 <exit>
}
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 14             	sub    $0x14,%esp
	//close_all();
	sys_env_destroy(0);
  800778:	6a 00                	push   $0x0
  80077a:	e8 e7 09 00 00       	call   801166 <sys_env_destroy>
}
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	56                   	push   %esi
  800788:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800789:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80078c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800792:	e8 10 0a 00 00       	call   8011a7 <sys_getenvid>
  800797:	83 ec 0c             	sub    $0xc,%esp
  80079a:	ff 75 0c             	pushl  0xc(%ebp)
  80079d:	ff 75 08             	pushl  0x8(%ebp)
  8007a0:	56                   	push   %esi
  8007a1:	50                   	push   %eax
  8007a2:	68 f0 1c 80 00       	push   $0x801cf0
  8007a7:	e8 b1 00 00 00       	call   80085d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8007ac:	83 c4 18             	add    $0x18,%esp
  8007af:	53                   	push   %ebx
  8007b0:	ff 75 10             	pushl  0x10(%ebp)
  8007b3:	e8 54 00 00 00       	call   80080c <vcprintf>
	cprintf("\n");
  8007b8:	c7 04 24 4a 1c 80 00 	movl   $0x801c4a,(%esp)
  8007bf:	e8 99 00 00 00       	call   80085d <cprintf>
  8007c4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8007c7:	cc                   	int3   
  8007c8:	eb fd                	jmp    8007c7 <_panic+0x43>

008007ca <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	83 ec 04             	sub    $0x4,%esp
  8007d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8007d4:	8b 13                	mov    (%ebx),%edx
  8007d6:	8d 42 01             	lea    0x1(%edx),%eax
  8007d9:	89 03                	mov    %eax,(%ebx)
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8007e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007e7:	75 1a                	jne    800803 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	68 ff 00 00 00       	push   $0xff
  8007f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8007f4:	50                   	push   %eax
  8007f5:	e8 2f 09 00 00       	call   801129 <sys_cputs>
		b->idx = 0;
  8007fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800800:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800803:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800815:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80081c:	00 00 00 
	b.cnt = 0;
  80081f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800826:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800829:	ff 75 0c             	pushl  0xc(%ebp)
  80082c:	ff 75 08             	pushl  0x8(%ebp)
  80082f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	68 ca 07 80 00       	push   $0x8007ca
  80083b:	e8 54 01 00 00       	call   800994 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800840:	83 c4 08             	add    $0x8,%esp
  800843:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800849:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	e8 d4 08 00 00       	call   801129 <sys_cputs>

	return b.cnt;
}
  800855:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800863:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800866:	50                   	push   %eax
  800867:	ff 75 08             	pushl  0x8(%ebp)
  80086a:	e8 9d ff ff ff       	call   80080c <vcprintf>
	va_end(ap);

	return cnt;
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	57                   	push   %edi
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	83 ec 1c             	sub    $0x1c,%esp
  80087a:	89 c7                	mov    %eax,%edi
  80087c:	89 d6                	mov    %edx,%esi
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
  800884:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800887:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800892:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800895:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800898:	39 d3                	cmp    %edx,%ebx
  80089a:	72 05                	jb     8008a1 <printnum+0x30>
  80089c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80089f:	77 45                	ja     8008e6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8008a1:	83 ec 0c             	sub    $0xc,%esp
  8008a4:	ff 75 18             	pushl  0x18(%ebp)
  8008a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008aa:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8008ad:	53                   	push   %ebx
  8008ae:	ff 75 10             	pushl  0x10(%ebp)
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8008bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8008c0:	e8 3b 10 00 00       	call   801900 <__udivdi3>
  8008c5:	83 c4 18             	add    $0x18,%esp
  8008c8:	52                   	push   %edx
  8008c9:	50                   	push   %eax
  8008ca:	89 f2                	mov    %esi,%edx
  8008cc:	89 f8                	mov    %edi,%eax
  8008ce:	e8 9e ff ff ff       	call   800871 <printnum>
  8008d3:	83 c4 20             	add    $0x20,%esp
  8008d6:	eb 18                	jmp    8008f0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	56                   	push   %esi
  8008dc:	ff 75 18             	pushl  0x18(%ebp)
  8008df:	ff d7                	call   *%edi
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	eb 03                	jmp    8008e9 <printnum+0x78>
  8008e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008e9:	83 eb 01             	sub    $0x1,%ebx
  8008ec:	85 db                	test   %ebx,%ebx
  8008ee:	7f e8                	jg     8008d8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	56                   	push   %esi
  8008f4:	83 ec 04             	sub    $0x4,%esp
  8008f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8008fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800900:	ff 75 d8             	pushl  -0x28(%ebp)
  800903:	e8 28 11 00 00       	call   801a30 <__umoddi3>
  800908:	83 c4 14             	add    $0x14,%esp
  80090b:	0f be 80 13 1d 80 00 	movsbl 0x801d13(%eax),%eax
  800912:	50                   	push   %eax
  800913:	ff d7                	call   *%edi
}
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800923:	83 fa 01             	cmp    $0x1,%edx
  800926:	7e 0e                	jle    800936 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800928:	8b 10                	mov    (%eax),%edx
  80092a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80092d:	89 08                	mov    %ecx,(%eax)
  80092f:	8b 02                	mov    (%edx),%eax
  800931:	8b 52 04             	mov    0x4(%edx),%edx
  800934:	eb 22                	jmp    800958 <getuint+0x38>
	else if (lflag)
  800936:	85 d2                	test   %edx,%edx
  800938:	74 10                	je     80094a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80093a:	8b 10                	mov    (%eax),%edx
  80093c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80093f:	89 08                	mov    %ecx,(%eax)
  800941:	8b 02                	mov    (%edx),%eax
  800943:	ba 00 00 00 00       	mov    $0x0,%edx
  800948:	eb 0e                	jmp    800958 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80094a:	8b 10                	mov    (%eax),%edx
  80094c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80094f:	89 08                	mov    %ecx,(%eax)
  800951:	8b 02                	mov    (%edx),%eax
  800953:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800960:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800964:	8b 10                	mov    (%eax),%edx
  800966:	3b 50 04             	cmp    0x4(%eax),%edx
  800969:	73 0a                	jae    800975 <sprintputch+0x1b>
		*b->buf++ = ch;
  80096b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80096e:	89 08                	mov    %ecx,(%eax)
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	88 02                	mov    %al,(%edx)
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80097d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800980:	50                   	push   %eax
  800981:	ff 75 10             	pushl  0x10(%ebp)
  800984:	ff 75 0c             	pushl  0xc(%ebp)
  800987:	ff 75 08             	pushl  0x8(%ebp)
  80098a:	e8 05 00 00 00       	call   800994 <vprintfmt>
	va_end(ap);
}
  80098f:	83 c4 10             	add    $0x10,%esp
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	83 ec 2c             	sub    $0x2c,%esp
  80099d:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009a6:	eb 12                	jmp    8009ba <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009a8:	85 c0                	test   %eax,%eax
  8009aa:	0f 84 89 03 00 00    	je     800d39 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8009b0:	83 ec 08             	sub    $0x8,%esp
  8009b3:	53                   	push   %ebx
  8009b4:	50                   	push   %eax
  8009b5:	ff d6                	call   *%esi
  8009b7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009ba:	83 c7 01             	add    $0x1,%edi
  8009bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009c1:	83 f8 25             	cmp    $0x25,%eax
  8009c4:	75 e2                	jne    8009a8 <vprintfmt+0x14>
  8009c6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009ca:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8009df:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e4:	eb 07                	jmp    8009ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009e9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ed:	8d 47 01             	lea    0x1(%edi),%eax
  8009f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009f3:	0f b6 07             	movzbl (%edi),%eax
  8009f6:	0f b6 c8             	movzbl %al,%ecx
  8009f9:	83 e8 23             	sub    $0x23,%eax
  8009fc:	3c 55                	cmp    $0x55,%al
  8009fe:	0f 87 1a 03 00 00    	ja     800d1e <vprintfmt+0x38a>
  800a04:	0f b6 c0             	movzbl %al,%eax
  800a07:	ff 24 85 60 1e 80 00 	jmp    *0x801e60(,%eax,4)
  800a0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a11:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a15:	eb d6                	jmp    8009ed <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a22:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a25:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800a29:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800a2c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800a2f:	83 fa 09             	cmp    $0x9,%edx
  800a32:	77 39                	ja     800a6d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a34:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a37:	eb e9                	jmp    800a22 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a39:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3c:	8d 48 04             	lea    0x4(%eax),%ecx
  800a3f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a42:	8b 00                	mov    (%eax),%eax
  800a44:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a4a:	eb 27                	jmp    800a73 <vprintfmt+0xdf>
  800a4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a56:	0f 49 c8             	cmovns %eax,%ecx
  800a59:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a5f:	eb 8c                	jmp    8009ed <vprintfmt+0x59>
  800a61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a64:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a6b:	eb 80                	jmp    8009ed <vprintfmt+0x59>
  800a6d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a70:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a73:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a77:	0f 89 70 ff ff ff    	jns    8009ed <vprintfmt+0x59>
				width = precision, precision = -1;
  800a7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a80:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a83:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a8a:	e9 5e ff ff ff       	jmp    8009ed <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a8f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a95:	e9 53 ff ff ff       	jmp    8009ed <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9d:	8d 50 04             	lea    0x4(%eax),%edx
  800aa0:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa3:	83 ec 08             	sub    $0x8,%esp
  800aa6:	53                   	push   %ebx
  800aa7:	ff 30                	pushl  (%eax)
  800aa9:	ff d6                	call   *%esi
			break;
  800aab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800ab1:	e9 04 ff ff ff       	jmp    8009ba <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800ab6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab9:	8d 50 04             	lea    0x4(%eax),%edx
  800abc:	89 55 14             	mov    %edx,0x14(%ebp)
  800abf:	8b 00                	mov    (%eax),%eax
  800ac1:	99                   	cltd   
  800ac2:	31 d0                	xor    %edx,%eax
  800ac4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ac6:	83 f8 0f             	cmp    $0xf,%eax
  800ac9:	7f 0b                	jg     800ad6 <vprintfmt+0x142>
  800acb:	8b 14 85 c0 1f 80 00 	mov    0x801fc0(,%eax,4),%edx
  800ad2:	85 d2                	test   %edx,%edx
  800ad4:	75 18                	jne    800aee <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800ad6:	50                   	push   %eax
  800ad7:	68 2b 1d 80 00       	push   $0x801d2b
  800adc:	53                   	push   %ebx
  800add:	56                   	push   %esi
  800ade:	e8 94 fe ff ff       	call   800977 <printfmt>
  800ae3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ae6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800ae9:	e9 cc fe ff ff       	jmp    8009ba <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800aee:	52                   	push   %edx
  800aef:	68 34 1d 80 00       	push   $0x801d34
  800af4:	53                   	push   %ebx
  800af5:	56                   	push   %esi
  800af6:	e8 7c fe ff ff       	call   800977 <printfmt>
  800afb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b01:	e9 b4 fe ff ff       	jmp    8009ba <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b06:	8b 45 14             	mov    0x14(%ebp),%eax
  800b09:	8d 50 04             	lea    0x4(%eax),%edx
  800b0c:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800b11:	85 ff                	test   %edi,%edi
  800b13:	b8 24 1d 80 00       	mov    $0x801d24,%eax
  800b18:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800b1b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b1f:	0f 8e 94 00 00 00    	jle    800bb9 <vprintfmt+0x225>
  800b25:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b29:	0f 84 98 00 00 00    	je     800bc7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b2f:	83 ec 08             	sub    $0x8,%esp
  800b32:	ff 75 d0             	pushl  -0x30(%ebp)
  800b35:	57                   	push   %edi
  800b36:	e8 86 02 00 00       	call   800dc1 <strnlen>
  800b3b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b3e:	29 c1                	sub    %eax,%ecx
  800b40:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800b43:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800b46:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b4d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b50:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b52:	eb 0f                	jmp    800b63 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800b54:	83 ec 08             	sub    $0x8,%esp
  800b57:	53                   	push   %ebx
  800b58:	ff 75 e0             	pushl  -0x20(%ebp)
  800b5b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b5d:	83 ef 01             	sub    $0x1,%edi
  800b60:	83 c4 10             	add    $0x10,%esp
  800b63:	85 ff                	test   %edi,%edi
  800b65:	7f ed                	jg     800b54 <vprintfmt+0x1c0>
  800b67:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800b6a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800b6d:	85 c9                	test   %ecx,%ecx
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b74:	0f 49 c1             	cmovns %ecx,%eax
  800b77:	29 c1                	sub    %eax,%ecx
  800b79:	89 75 08             	mov    %esi,0x8(%ebp)
  800b7c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b7f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b82:	89 cb                	mov    %ecx,%ebx
  800b84:	eb 4d                	jmp    800bd3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b86:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b8a:	74 1b                	je     800ba7 <vprintfmt+0x213>
  800b8c:	0f be c0             	movsbl %al,%eax
  800b8f:	83 e8 20             	sub    $0x20,%eax
  800b92:	83 f8 5e             	cmp    $0x5e,%eax
  800b95:	76 10                	jbe    800ba7 <vprintfmt+0x213>
					putch('?', putdat);
  800b97:	83 ec 08             	sub    $0x8,%esp
  800b9a:	ff 75 0c             	pushl  0xc(%ebp)
  800b9d:	6a 3f                	push   $0x3f
  800b9f:	ff 55 08             	call   *0x8(%ebp)
  800ba2:	83 c4 10             	add    $0x10,%esp
  800ba5:	eb 0d                	jmp    800bb4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800ba7:	83 ec 08             	sub    $0x8,%esp
  800baa:	ff 75 0c             	pushl  0xc(%ebp)
  800bad:	52                   	push   %edx
  800bae:	ff 55 08             	call   *0x8(%ebp)
  800bb1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bb4:	83 eb 01             	sub    $0x1,%ebx
  800bb7:	eb 1a                	jmp    800bd3 <vprintfmt+0x23f>
  800bb9:	89 75 08             	mov    %esi,0x8(%ebp)
  800bbc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bbf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bc2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bc5:	eb 0c                	jmp    800bd3 <vprintfmt+0x23f>
  800bc7:	89 75 08             	mov    %esi,0x8(%ebp)
  800bca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bcd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bd0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bd3:	83 c7 01             	add    $0x1,%edi
  800bd6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800bda:	0f be d0             	movsbl %al,%edx
  800bdd:	85 d2                	test   %edx,%edx
  800bdf:	74 23                	je     800c04 <vprintfmt+0x270>
  800be1:	85 f6                	test   %esi,%esi
  800be3:	78 a1                	js     800b86 <vprintfmt+0x1f2>
  800be5:	83 ee 01             	sub    $0x1,%esi
  800be8:	79 9c                	jns    800b86 <vprintfmt+0x1f2>
  800bea:	89 df                	mov    %ebx,%edi
  800bec:	8b 75 08             	mov    0x8(%ebp),%esi
  800bef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf2:	eb 18                	jmp    800c0c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bf4:	83 ec 08             	sub    $0x8,%esp
  800bf7:	53                   	push   %ebx
  800bf8:	6a 20                	push   $0x20
  800bfa:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bfc:	83 ef 01             	sub    $0x1,%edi
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	eb 08                	jmp    800c0c <vprintfmt+0x278>
  800c04:	89 df                	mov    %ebx,%edi
  800c06:	8b 75 08             	mov    0x8(%ebp),%esi
  800c09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c0c:	85 ff                	test   %edi,%edi
  800c0e:	7f e4                	jg     800bf4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c13:	e9 a2 fd ff ff       	jmp    8009ba <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c18:	83 fa 01             	cmp    $0x1,%edx
  800c1b:	7e 16                	jle    800c33 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800c1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c20:	8d 50 08             	lea    0x8(%eax),%edx
  800c23:	89 55 14             	mov    %edx,0x14(%ebp)
  800c26:	8b 50 04             	mov    0x4(%eax),%edx
  800c29:	8b 00                	mov    (%eax),%eax
  800c2b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c2e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c31:	eb 32                	jmp    800c65 <vprintfmt+0x2d1>
	else if (lflag)
  800c33:	85 d2                	test   %edx,%edx
  800c35:	74 18                	je     800c4f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800c37:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3a:	8d 50 04             	lea    0x4(%eax),%edx
  800c3d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c40:	8b 00                	mov    (%eax),%eax
  800c42:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c45:	89 c1                	mov    %eax,%ecx
  800c47:	c1 f9 1f             	sar    $0x1f,%ecx
  800c4a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800c4d:	eb 16                	jmp    800c65 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800c4f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c52:	8d 50 04             	lea    0x4(%eax),%edx
  800c55:	89 55 14             	mov    %edx,0x14(%ebp)
  800c58:	8b 00                	mov    (%eax),%eax
  800c5a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c5d:	89 c1                	mov    %eax,%ecx
  800c5f:	c1 f9 1f             	sar    $0x1f,%ecx
  800c62:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c65:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c68:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c6b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c70:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c74:	79 74                	jns    800cea <vprintfmt+0x356>
				putch('-', putdat);
  800c76:	83 ec 08             	sub    $0x8,%esp
  800c79:	53                   	push   %ebx
  800c7a:	6a 2d                	push   $0x2d
  800c7c:	ff d6                	call   *%esi
				num = -(long long) num;
  800c7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c81:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c84:	f7 d8                	neg    %eax
  800c86:	83 d2 00             	adc    $0x0,%edx
  800c89:	f7 da                	neg    %edx
  800c8b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800c8e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c93:	eb 55                	jmp    800cea <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c95:	8d 45 14             	lea    0x14(%ebp),%eax
  800c98:	e8 83 fc ff ff       	call   800920 <getuint>
			base = 10;
  800c9d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ca2:	eb 46                	jmp    800cea <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800ca4:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca7:	e8 74 fc ff ff       	call   800920 <getuint>
			base = 8;
  800cac:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800cb1:	eb 37                	jmp    800cea <vprintfmt+0x356>
		
		// pointer
		case 'p':
			putch('0', putdat);
  800cb3:	83 ec 08             	sub    $0x8,%esp
  800cb6:	53                   	push   %ebx
  800cb7:	6a 30                	push   $0x30
  800cb9:	ff d6                	call   *%esi
			putch('x', putdat);
  800cbb:	83 c4 08             	add    $0x8,%esp
  800cbe:	53                   	push   %ebx
  800cbf:	6a 78                	push   $0x78
  800cc1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800cc3:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc6:	8d 50 04             	lea    0x4(%eax),%edx
  800cc9:	89 55 14             	mov    %edx,0x14(%ebp)
		
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ccc:	8b 00                	mov    (%eax),%eax
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800cd3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cd6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800cdb:	eb 0d                	jmp    800cea <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800cdd:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce0:	e8 3b fc ff ff       	call   800920 <getuint>
			base = 16;
  800ce5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800cf1:	57                   	push   %edi
  800cf2:	ff 75 e0             	pushl  -0x20(%ebp)
  800cf5:	51                   	push   %ecx
  800cf6:	52                   	push   %edx
  800cf7:	50                   	push   %eax
  800cf8:	89 da                	mov    %ebx,%edx
  800cfa:	89 f0                	mov    %esi,%eax
  800cfc:	e8 70 fb ff ff       	call   800871 <printnum>
			break;
  800d01:	83 c4 20             	add    $0x20,%esp
  800d04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d07:	e9 ae fc ff ff       	jmp    8009ba <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d0c:	83 ec 08             	sub    $0x8,%esp
  800d0f:	53                   	push   %ebx
  800d10:	51                   	push   %ecx
  800d11:	ff d6                	call   *%esi
			break;
  800d13:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d19:	e9 9c fc ff ff       	jmp    8009ba <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d1e:	83 ec 08             	sub    $0x8,%esp
  800d21:	53                   	push   %ebx
  800d22:	6a 25                	push   $0x25
  800d24:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d26:	83 c4 10             	add    $0x10,%esp
  800d29:	eb 03                	jmp    800d2e <vprintfmt+0x39a>
  800d2b:	83 ef 01             	sub    $0x1,%edi
  800d2e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800d32:	75 f7                	jne    800d2b <vprintfmt+0x397>
  800d34:	e9 81 fc ff ff       	jmp    8009ba <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 18             	sub    $0x18,%esp
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d50:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d54:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	74 26                	je     800d88 <vsnprintf+0x47>
  800d62:	85 d2                	test   %edx,%edx
  800d64:	7e 22                	jle    800d88 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d66:	ff 75 14             	pushl  0x14(%ebp)
  800d69:	ff 75 10             	pushl  0x10(%ebp)
  800d6c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d6f:	50                   	push   %eax
  800d70:	68 5a 09 80 00       	push   $0x80095a
  800d75:	e8 1a fc ff ff       	call   800994 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d7d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	eb 05                	jmp    800d8d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d95:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d98:	50                   	push   %eax
  800d99:	ff 75 10             	pushl  0x10(%ebp)
  800d9c:	ff 75 0c             	pushl  0xc(%ebp)
  800d9f:	ff 75 08             	pushl  0x8(%ebp)
  800da2:	e8 9a ff ff ff       	call   800d41 <vsnprintf>
	va_end(ap);

	return rc;
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
  800db4:	eb 03                	jmp    800db9 <strlen+0x10>
		n++;
  800db6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800db9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dbd:	75 f7                	jne    800db6 <strlen+0xd>
		n++;
	return n;
}
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dca:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcf:	eb 03                	jmp    800dd4 <strnlen+0x13>
		n++;
  800dd1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dd4:	39 c2                	cmp    %eax,%edx
  800dd6:	74 08                	je     800de0 <strnlen+0x1f>
  800dd8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ddc:	75 f3                	jne    800dd1 <strnlen+0x10>
  800dde:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	53                   	push   %ebx
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
  800de9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800dec:	89 c2                	mov    %eax,%edx
  800dee:	83 c2 01             	add    $0x1,%edx
  800df1:	83 c1 01             	add    $0x1,%ecx
  800df4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800df8:	88 5a ff             	mov    %bl,-0x1(%edx)
  800dfb:	84 db                	test   %bl,%bl
  800dfd:	75 ef                	jne    800dee <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800dff:	5b                   	pop    %ebx
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	53                   	push   %ebx
  800e06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e09:	53                   	push   %ebx
  800e0a:	e8 9a ff ff ff       	call   800da9 <strlen>
  800e0f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800e12:	ff 75 0c             	pushl  0xc(%ebp)
  800e15:	01 d8                	add    %ebx,%eax
  800e17:	50                   	push   %eax
  800e18:	e8 c5 ff ff ff       	call   800de2 <strcpy>
	return dst;
}
  800e1d:	89 d8                	mov    %ebx,%eax
  800e1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    

00800e24 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	8b 75 08             	mov    0x8(%ebp),%esi
  800e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2f:	89 f3                	mov    %esi,%ebx
  800e31:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e34:	89 f2                	mov    %esi,%edx
  800e36:	eb 0f                	jmp    800e47 <strncpy+0x23>
		*dst++ = *src;
  800e38:	83 c2 01             	add    $0x1,%edx
  800e3b:	0f b6 01             	movzbl (%ecx),%eax
  800e3e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e41:	80 39 01             	cmpb   $0x1,(%ecx)
  800e44:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e47:	39 da                	cmp    %ebx,%edx
  800e49:	75 ed                	jne    800e38 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e4b:	89 f0                	mov    %esi,%eax
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	8b 75 08             	mov    0x8(%ebp),%esi
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	8b 55 10             	mov    0x10(%ebp),%edx
  800e5f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e61:	85 d2                	test   %edx,%edx
  800e63:	74 21                	je     800e86 <strlcpy+0x35>
  800e65:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e69:	89 f2                	mov    %esi,%edx
  800e6b:	eb 09                	jmp    800e76 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e6d:	83 c2 01             	add    $0x1,%edx
  800e70:	83 c1 01             	add    $0x1,%ecx
  800e73:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e76:	39 c2                	cmp    %eax,%edx
  800e78:	74 09                	je     800e83 <strlcpy+0x32>
  800e7a:	0f b6 19             	movzbl (%ecx),%ebx
  800e7d:	84 db                	test   %bl,%bl
  800e7f:	75 ec                	jne    800e6d <strlcpy+0x1c>
  800e81:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e83:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e86:	29 f0                	sub    %esi,%eax
}
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e92:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e95:	eb 06                	jmp    800e9d <strcmp+0x11>
		p++, q++;
  800e97:	83 c1 01             	add    $0x1,%ecx
  800e9a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e9d:	0f b6 01             	movzbl (%ecx),%eax
  800ea0:	84 c0                	test   %al,%al
  800ea2:	74 04                	je     800ea8 <strcmp+0x1c>
  800ea4:	3a 02                	cmp    (%edx),%al
  800ea6:	74 ef                	je     800e97 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ea8:	0f b6 c0             	movzbl %al,%eax
  800eab:	0f b6 12             	movzbl (%edx),%edx
  800eae:	29 d0                	sub    %edx,%eax
}
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	53                   	push   %ebx
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebc:	89 c3                	mov    %eax,%ebx
  800ebe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ec1:	eb 06                	jmp    800ec9 <strncmp+0x17>
		n--, p++, q++;
  800ec3:	83 c0 01             	add    $0x1,%eax
  800ec6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ec9:	39 d8                	cmp    %ebx,%eax
  800ecb:	74 15                	je     800ee2 <strncmp+0x30>
  800ecd:	0f b6 08             	movzbl (%eax),%ecx
  800ed0:	84 c9                	test   %cl,%cl
  800ed2:	74 04                	je     800ed8 <strncmp+0x26>
  800ed4:	3a 0a                	cmp    (%edx),%cl
  800ed6:	74 eb                	je     800ec3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ed8:	0f b6 00             	movzbl (%eax),%eax
  800edb:	0f b6 12             	movzbl (%edx),%edx
  800ede:	29 d0                	sub    %edx,%eax
  800ee0:	eb 05                	jmp    800ee7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ee7:	5b                   	pop    %ebx
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ef4:	eb 07                	jmp    800efd <strchr+0x13>
		if (*s == c)
  800ef6:	38 ca                	cmp    %cl,%dl
  800ef8:	74 0f                	je     800f09 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800efa:	83 c0 01             	add    $0x1,%eax
  800efd:	0f b6 10             	movzbl (%eax),%edx
  800f00:	84 d2                	test   %dl,%dl
  800f02:	75 f2                	jne    800ef6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800f04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f15:	eb 03                	jmp    800f1a <strfind+0xf>
  800f17:	83 c0 01             	add    $0x1,%eax
  800f1a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f1d:	38 ca                	cmp    %cl,%dl
  800f1f:	74 04                	je     800f25 <strfind+0x1a>
  800f21:	84 d2                	test   %dl,%dl
  800f23:	75 f2                	jne    800f17 <strfind+0xc>
			break;
	return (char *) s;
}
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f33:	85 c9                	test   %ecx,%ecx
  800f35:	74 36                	je     800f6d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f37:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f3d:	75 28                	jne    800f67 <memset+0x40>
  800f3f:	f6 c1 03             	test   $0x3,%cl
  800f42:	75 23                	jne    800f67 <memset+0x40>
		c &= 0xFF;
  800f44:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f48:	89 d3                	mov    %edx,%ebx
  800f4a:	c1 e3 08             	shl    $0x8,%ebx
  800f4d:	89 d6                	mov    %edx,%esi
  800f4f:	c1 e6 18             	shl    $0x18,%esi
  800f52:	89 d0                	mov    %edx,%eax
  800f54:	c1 e0 10             	shl    $0x10,%eax
  800f57:	09 f0                	or     %esi,%eax
  800f59:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f5b:	89 d8                	mov    %ebx,%eax
  800f5d:	09 d0                	or     %edx,%eax
  800f5f:	c1 e9 02             	shr    $0x2,%ecx
  800f62:	fc                   	cld    
  800f63:	f3 ab                	rep stos %eax,%es:(%edi)
  800f65:	eb 06                	jmp    800f6d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6a:	fc                   	cld    
  800f6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f6d:	89 f8                	mov    %edi,%eax
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f82:	39 c6                	cmp    %eax,%esi
  800f84:	73 35                	jae    800fbb <memmove+0x47>
  800f86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f89:	39 d0                	cmp    %edx,%eax
  800f8b:	73 2e                	jae    800fbb <memmove+0x47>
		s += n;
		d += n;
  800f8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f90:	89 d6                	mov    %edx,%esi
  800f92:	09 fe                	or     %edi,%esi
  800f94:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f9a:	75 13                	jne    800faf <memmove+0x3b>
  800f9c:	f6 c1 03             	test   $0x3,%cl
  800f9f:	75 0e                	jne    800faf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800fa1:	83 ef 04             	sub    $0x4,%edi
  800fa4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fa7:	c1 e9 02             	shr    $0x2,%ecx
  800faa:	fd                   	std    
  800fab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fad:	eb 09                	jmp    800fb8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800faf:	83 ef 01             	sub    $0x1,%edi
  800fb2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fb5:	fd                   	std    
  800fb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fb8:	fc                   	cld    
  800fb9:	eb 1d                	jmp    800fd8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fbb:	89 f2                	mov    %esi,%edx
  800fbd:	09 c2                	or     %eax,%edx
  800fbf:	f6 c2 03             	test   $0x3,%dl
  800fc2:	75 0f                	jne    800fd3 <memmove+0x5f>
  800fc4:	f6 c1 03             	test   $0x3,%cl
  800fc7:	75 0a                	jne    800fd3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fc9:	c1 e9 02             	shr    $0x2,%ecx
  800fcc:	89 c7                	mov    %eax,%edi
  800fce:	fc                   	cld    
  800fcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd1:	eb 05                	jmp    800fd8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fd3:	89 c7                	mov    %eax,%edi
  800fd5:	fc                   	cld    
  800fd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fd8:	5e                   	pop    %esi
  800fd9:	5f                   	pop    %edi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fdf:	ff 75 10             	pushl  0x10(%ebp)
  800fe2:	ff 75 0c             	pushl  0xc(%ebp)
  800fe5:	ff 75 08             	pushl  0x8(%ebp)
  800fe8:	e8 87 ff ff ff       	call   800f74 <memmove>
}
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    

00800fef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ffa:	89 c6                	mov    %eax,%esi
  800ffc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fff:	eb 1a                	jmp    80101b <memcmp+0x2c>
		if (*s1 != *s2)
  801001:	0f b6 08             	movzbl (%eax),%ecx
  801004:	0f b6 1a             	movzbl (%edx),%ebx
  801007:	38 d9                	cmp    %bl,%cl
  801009:	74 0a                	je     801015 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80100b:	0f b6 c1             	movzbl %cl,%eax
  80100e:	0f b6 db             	movzbl %bl,%ebx
  801011:	29 d8                	sub    %ebx,%eax
  801013:	eb 0f                	jmp    801024 <memcmp+0x35>
		s1++, s2++;
  801015:	83 c0 01             	add    $0x1,%eax
  801018:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80101b:	39 f0                	cmp    %esi,%eax
  80101d:	75 e2                	jne    801001 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	53                   	push   %ebx
  80102c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80102f:	89 c1                	mov    %eax,%ecx
  801031:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801034:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801038:	eb 0a                	jmp    801044 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80103a:	0f b6 10             	movzbl (%eax),%edx
  80103d:	39 da                	cmp    %ebx,%edx
  80103f:	74 07                	je     801048 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801041:	83 c0 01             	add    $0x1,%eax
  801044:	39 c8                	cmp    %ecx,%eax
  801046:	72 f2                	jb     80103a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801048:	5b                   	pop    %ebx
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801054:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801057:	eb 03                	jmp    80105c <strtol+0x11>
		s++;
  801059:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80105c:	0f b6 01             	movzbl (%ecx),%eax
  80105f:	3c 20                	cmp    $0x20,%al
  801061:	74 f6                	je     801059 <strtol+0xe>
  801063:	3c 09                	cmp    $0x9,%al
  801065:	74 f2                	je     801059 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801067:	3c 2b                	cmp    $0x2b,%al
  801069:	75 0a                	jne    801075 <strtol+0x2a>
		s++;
  80106b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80106e:	bf 00 00 00 00       	mov    $0x0,%edi
  801073:	eb 11                	jmp    801086 <strtol+0x3b>
  801075:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80107a:	3c 2d                	cmp    $0x2d,%al
  80107c:	75 08                	jne    801086 <strtol+0x3b>
		s++, neg = 1;
  80107e:	83 c1 01             	add    $0x1,%ecx
  801081:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801086:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80108c:	75 15                	jne    8010a3 <strtol+0x58>
  80108e:	80 39 30             	cmpb   $0x30,(%ecx)
  801091:	75 10                	jne    8010a3 <strtol+0x58>
  801093:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801097:	75 7c                	jne    801115 <strtol+0xca>
		s += 2, base = 16;
  801099:	83 c1 02             	add    $0x2,%ecx
  80109c:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010a1:	eb 16                	jmp    8010b9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8010a3:	85 db                	test   %ebx,%ebx
  8010a5:	75 12                	jne    8010b9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010ac:	80 39 30             	cmpb   $0x30,(%ecx)
  8010af:	75 08                	jne    8010b9 <strtol+0x6e>
		s++, base = 8;
  8010b1:	83 c1 01             	add    $0x1,%ecx
  8010b4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010be:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010c1:	0f b6 11             	movzbl (%ecx),%edx
  8010c4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010c7:	89 f3                	mov    %esi,%ebx
  8010c9:	80 fb 09             	cmp    $0x9,%bl
  8010cc:	77 08                	ja     8010d6 <strtol+0x8b>
			dig = *s - '0';
  8010ce:	0f be d2             	movsbl %dl,%edx
  8010d1:	83 ea 30             	sub    $0x30,%edx
  8010d4:	eb 22                	jmp    8010f8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8010d6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010d9:	89 f3                	mov    %esi,%ebx
  8010db:	80 fb 19             	cmp    $0x19,%bl
  8010de:	77 08                	ja     8010e8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8010e0:	0f be d2             	movsbl %dl,%edx
  8010e3:	83 ea 57             	sub    $0x57,%edx
  8010e6:	eb 10                	jmp    8010f8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8010e8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010eb:	89 f3                	mov    %esi,%ebx
  8010ed:	80 fb 19             	cmp    $0x19,%bl
  8010f0:	77 16                	ja     801108 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8010f2:	0f be d2             	movsbl %dl,%edx
  8010f5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8010f8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8010fb:	7d 0b                	jge    801108 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8010fd:	83 c1 01             	add    $0x1,%ecx
  801100:	0f af 45 10          	imul   0x10(%ebp),%eax
  801104:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801106:	eb b9                	jmp    8010c1 <strtol+0x76>

	if (endptr)
  801108:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80110c:	74 0d                	je     80111b <strtol+0xd0>
		*endptr = (char *) s;
  80110e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801111:	89 0e                	mov    %ecx,(%esi)
  801113:	eb 06                	jmp    80111b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801115:	85 db                	test   %ebx,%ebx
  801117:	74 98                	je     8010b1 <strtol+0x66>
  801119:	eb 9e                	jmp    8010b9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	f7 da                	neg    %edx
  80111f:	85 ff                	test   %edi,%edi
  801121:	0f 45 c2             	cmovne %edx,%eax
}
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	57                   	push   %edi
  80112d:	56                   	push   %esi
  80112e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
  801134:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801137:	8b 55 08             	mov    0x8(%ebp),%edx
  80113a:	89 c3                	mov    %eax,%ebx
  80113c:	89 c7                	mov    %eax,%edi
  80113e:	89 c6                	mov    %eax,%esi
  801140:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801142:	5b                   	pop    %ebx
  801143:	5e                   	pop    %esi
  801144:	5f                   	pop    %edi
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <sys_cgetc>:

int
sys_cgetc(void)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	57                   	push   %edi
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114d:	ba 00 00 00 00       	mov    $0x0,%edx
  801152:	b8 01 00 00 00       	mov    $0x1,%eax
  801157:	89 d1                	mov    %edx,%ecx
  801159:	89 d3                	mov    %edx,%ebx
  80115b:	89 d7                	mov    %edx,%edi
  80115d:	89 d6                	mov    %edx,%esi
  80115f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801161:	5b                   	pop    %ebx
  801162:	5e                   	pop    %esi
  801163:	5f                   	pop    %edi
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	53                   	push   %ebx
  80116c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801174:	b8 03 00 00 00       	mov    $0x3,%eax
  801179:	8b 55 08             	mov    0x8(%ebp),%edx
  80117c:	89 cb                	mov    %ecx,%ebx
  80117e:	89 cf                	mov    %ecx,%edi
  801180:	89 ce                	mov    %ecx,%esi
  801182:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801184:	85 c0                	test   %eax,%eax
  801186:	7e 17                	jle    80119f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801188:	83 ec 0c             	sub    $0xc,%esp
  80118b:	50                   	push   %eax
  80118c:	6a 03                	push   $0x3
  80118e:	68 1f 20 80 00       	push   $0x80201f
  801193:	6a 23                	push   $0x23
  801195:	68 3c 20 80 00       	push   $0x80203c
  80119a:	e8 e5 f5 ff ff       	call   800784 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80119f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a2:	5b                   	pop    %ebx
  8011a3:	5e                   	pop    %esi
  8011a4:	5f                   	pop    %edi
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	57                   	push   %edi
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8011b7:	89 d1                	mov    %edx,%ecx
  8011b9:	89 d3                	mov    %edx,%ebx
  8011bb:	89 d7                	mov    %edx,%edi
  8011bd:	89 d6                	mov    %edx,%esi
  8011bf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <sys_yield>:

void
sys_yield(void)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	57                   	push   %edi
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011d6:	89 d1                	mov    %edx,%ecx
  8011d8:	89 d3                	mov    %edx,%ebx
  8011da:	89 d7                	mov    %edx,%edi
  8011dc:	89 d6                	mov    %edx,%esi
  8011de:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ee:	be 00 00 00 00       	mov    $0x0,%esi
  8011f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8011f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801201:	89 f7                	mov    %esi,%edi
  801203:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801205:	85 c0                	test   %eax,%eax
  801207:	7e 17                	jle    801220 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	50                   	push   %eax
  80120d:	6a 04                	push   $0x4
  80120f:	68 1f 20 80 00       	push   $0x80201f
  801214:	6a 23                	push   $0x23
  801216:	68 3c 20 80 00       	push   $0x80203c
  80121b:	e8 64 f5 ff ff       	call   800784 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	57                   	push   %edi
  80122c:	56                   	push   %esi
  80122d:	53                   	push   %ebx
  80122e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801231:	b8 05 00 00 00       	mov    $0x5,%eax
  801236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801239:	8b 55 08             	mov    0x8(%ebp),%edx
  80123c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80123f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801242:	8b 75 18             	mov    0x18(%ebp),%esi
  801245:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801247:	85 c0                	test   %eax,%eax
  801249:	7e 17                	jle    801262 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80124b:	83 ec 0c             	sub    $0xc,%esp
  80124e:	50                   	push   %eax
  80124f:	6a 05                	push   $0x5
  801251:	68 1f 20 80 00       	push   $0x80201f
  801256:	6a 23                	push   $0x23
  801258:	68 3c 20 80 00       	push   $0x80203c
  80125d:	e8 22 f5 ff ff       	call   800784 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801265:	5b                   	pop    %ebx
  801266:	5e                   	pop    %esi
  801267:	5f                   	pop    %edi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	57                   	push   %edi
  80126e:	56                   	push   %esi
  80126f:	53                   	push   %ebx
  801270:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801273:	bb 00 00 00 00       	mov    $0x0,%ebx
  801278:	b8 06 00 00 00       	mov    $0x6,%eax
  80127d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801280:	8b 55 08             	mov    0x8(%ebp),%edx
  801283:	89 df                	mov    %ebx,%edi
  801285:	89 de                	mov    %ebx,%esi
  801287:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801289:	85 c0                	test   %eax,%eax
  80128b:	7e 17                	jle    8012a4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	50                   	push   %eax
  801291:	6a 06                	push   $0x6
  801293:	68 1f 20 80 00       	push   $0x80201f
  801298:	6a 23                	push   $0x23
  80129a:	68 3c 20 80 00       	push   $0x80203c
  80129f:	e8 e0 f4 ff ff       	call   800784 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5f                   	pop    %edi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8012bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c5:	89 df                	mov    %ebx,%edi
  8012c7:	89 de                	mov    %ebx,%esi
  8012c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	7e 17                	jle    8012e6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	50                   	push   %eax
  8012d3:	6a 08                	push   $0x8
  8012d5:	68 1f 20 80 00       	push   $0x80201f
  8012da:	6a 23                	push   $0x23
  8012dc:	68 3c 20 80 00       	push   $0x80203c
  8012e1:	e8 9e f4 ff ff       	call   800784 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e9:	5b                   	pop    %ebx
  8012ea:	5e                   	pop    %esi
  8012eb:	5f                   	pop    %edi
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012fc:	b8 09 00 00 00       	mov    $0x9,%eax
  801301:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801304:	8b 55 08             	mov    0x8(%ebp),%edx
  801307:	89 df                	mov    %ebx,%edi
  801309:	89 de                	mov    %ebx,%esi
  80130b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80130d:	85 c0                	test   %eax,%eax
  80130f:	7e 17                	jle    801328 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	50                   	push   %eax
  801315:	6a 09                	push   $0x9
  801317:	68 1f 20 80 00       	push   $0x80201f
  80131c:	6a 23                	push   $0x23
  80131e:	68 3c 20 80 00       	push   $0x80203c
  801323:	e8 5c f4 ff ff       	call   800784 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5f                   	pop    %edi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	57                   	push   %edi
  801334:	56                   	push   %esi
  801335:	53                   	push   %ebx
  801336:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801339:	bb 00 00 00 00       	mov    $0x0,%ebx
  80133e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801343:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801346:	8b 55 08             	mov    0x8(%ebp),%edx
  801349:	89 df                	mov    %ebx,%edi
  80134b:	89 de                	mov    %ebx,%esi
  80134d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80134f:	85 c0                	test   %eax,%eax
  801351:	7e 17                	jle    80136a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	50                   	push   %eax
  801357:	6a 0a                	push   $0xa
  801359:	68 1f 20 80 00       	push   $0x80201f
  80135e:	6a 23                	push   $0x23
  801360:	68 3c 20 80 00       	push   $0x80203c
  801365:	e8 1a f4 ff ff       	call   800784 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80136a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5f                   	pop    %edi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	57                   	push   %edi
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801378:	be 00 00 00 00       	mov    $0x0,%esi
  80137d:	b8 0c 00 00 00       	mov    $0xc,%eax
  801382:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801385:	8b 55 08             	mov    0x8(%ebp),%edx
  801388:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80138e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	57                   	push   %edi
  801399:	56                   	push   %esi
  80139a:	53                   	push   %ebx
  80139b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80139e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013a3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8013a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ab:	89 cb                	mov    %ecx,%ebx
  8013ad:	89 cf                	mov    %ecx,%edi
  8013af:	89 ce                	mov    %ecx,%esi
  8013b1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	7e 17                	jle    8013ce <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	50                   	push   %eax
  8013bb:	6a 0d                	push   $0xd
  8013bd:	68 1f 20 80 00       	push   $0x80201f
  8013c2:	6a 23                	push   $0x23
  8013c4:	68 3c 20 80 00       	push   $0x80203c
  8013c9:	e8 b6 f3 ff ff       	call   800784 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	57                   	push   %edi
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e1:	b8 0e 00 00 00       	mov    $0xe,%eax
  8013e6:	89 d1                	mov    %edx,%ecx
  8013e8:	89 d3                	mov    %edx,%ebx
  8013ea:	89 d7                	mov    %edx,%edi
  8013ec:	89 d6                	mov    %edx,%esi
  8013ee:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8013f0:	5b                   	pop    %ebx
  8013f1:	5e                   	pop    %esi
  8013f2:	5f                   	pop    %edi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	53                   	push   %ebx
  8013f9:	83 ec 04             	sub    $0x4,%esp
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8013ff:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  801401:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801405:	75 14                	jne    80141b <pgfault+0x26>
		panic("\nPage fault error : Faulting access was not a write access\n");
  801407:	83 ec 04             	sub    $0x4,%esp
  80140a:	68 4c 20 80 00       	push   $0x80204c
  80140f:	6a 22                	push   $0x22
  801411:	68 2f 21 80 00       	push   $0x80212f
  801416:	e8 69 f3 ff ff       	call   800784 <_panic>
	
	//*pte = uvpt[temp];

	if(!(uvpt[PGNUM(addr)] & PTE_COW))
  80141b:	89 d8                	mov    %ebx,%eax
  80141d:	c1 e8 0c             	shr    $0xc,%eax
  801420:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801427:	f6 c4 08             	test   $0x8,%ah
  80142a:	75 14                	jne    801440 <pgfault+0x4b>
		panic("\nPage fault error : Not a Copy on write page\n");
  80142c:	83 ec 04             	sub    $0x4,%esp
  80142f:	68 88 20 80 00       	push   $0x802088
  801434:	6a 27                	push   $0x27
  801436:	68 2f 21 80 00       	push   $0x80212f
  80143b:	e8 44 f3 ff ff       	call   800784 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	if((r = sys_page_alloc(0, PFTEMP, (PTE_P | PTE_U | PTE_W))) < 0)
  801440:	83 ec 04             	sub    $0x4,%esp
  801443:	6a 07                	push   $0x7
  801445:	68 00 f0 7f 00       	push   $0x7ff000
  80144a:	6a 00                	push   $0x0
  80144c:	e8 94 fd ff ff       	call   8011e5 <sys_page_alloc>
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	85 c0                	test   %eax,%eax
  801456:	79 14                	jns    80146c <pgfault+0x77>
		panic("\nPage fault error: Sys_page_alloc failed\n");
  801458:	83 ec 04             	sub    $0x4,%esp
  80145b:	68 b8 20 80 00       	push   $0x8020b8
  801460:	6a 2f                	push   $0x2f
  801462:	68 2f 21 80 00       	push   $0x80212f
  801467:	e8 18 f3 ff ff       	call   800784 <_panic>

	memmove((void *)PFTEMP, (void *)ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80146c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  801472:	83 ec 04             	sub    $0x4,%esp
  801475:	68 00 10 00 00       	push   $0x1000
  80147a:	53                   	push   %ebx
  80147b:	68 00 f0 7f 00       	push   $0x7ff000
  801480:	e8 ef fa ff ff       	call   800f74 <memmove>

	if((r = sys_page_map(0, PFTEMP, 0, (void *)ROUNDDOWN(addr, PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  801485:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80148c:	53                   	push   %ebx
  80148d:	6a 00                	push   $0x0
  80148f:	68 00 f0 7f 00       	push   $0x7ff000
  801494:	6a 00                	push   $0x0
  801496:	e8 8d fd ff ff       	call   801228 <sys_page_map>
  80149b:	83 c4 20             	add    $0x20,%esp
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	79 14                	jns    8014b6 <pgfault+0xc1>
		panic("\nPage fault error: Sys_page_map failed\n");
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	68 e4 20 80 00       	push   $0x8020e4
  8014aa:	6a 34                	push   $0x34
  8014ac:	68 2f 21 80 00       	push   $0x80212f
  8014b1:	e8 ce f2 ff ff       	call   800784 <_panic>

	if((r = sys_page_unmap(0, PFTEMP)) < 0)
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	68 00 f0 7f 00       	push   $0x7ff000
  8014be:	6a 00                	push   $0x0
  8014c0:	e8 a5 fd ff ff       	call   80126a <sys_page_unmap>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	79 14                	jns    8014e0 <pgfault+0xeb>
		panic("\nPage fault error: Sys_page_unmap\n");
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	68 0c 21 80 00       	push   $0x80210c
  8014d4:	6a 37                	push   $0x37
  8014d6:	68 2f 21 80 00       	push   $0x80212f
  8014db:	e8 a4 f2 ff ff       	call   800784 <_panic>
		panic("\nPage fault error: Sys_page_unmap failed\n");
	*/
	// LAB 4: Your code here.

	//panic("pgfault not implemented");
}
  8014e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	57                   	push   %edi
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  8014ee:	68 f5 13 80 00       	push   $0x8013f5
  8014f3:	e8 60 03 00 00       	call   801858 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014f8:	b8 07 00 00 00       	mov    $0x7,%eax
  8014fd:	cd 30                	int    $0x30
  8014ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t pn = 0;
	int r;

	envid = sys_exofork();

	if (envid < 0)
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	85 c0                	test   %eax,%eax
  80150a:	79 15                	jns    801521 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  80150c:	50                   	push   %eax
  80150d:	68 3a 21 80 00       	push   $0x80213a
  801512:	68 8d 00 00 00       	push   $0x8d
  801517:	68 2f 21 80 00       	push   $0x80212f
  80151c:	e8 63 f2 ff ff       	call   800784 <_panic>
  801521:	be 00 00 00 00       	mov    $0x0,%esi
  801526:	bb 00 00 00 00       	mov    $0x0,%ebx

	if (envid == 0) {
  80152b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80152f:	75 21                	jne    801552 <fork+0x6d>
		// We're the child.
		thisenv = &envs[ENVX(sys_getenvid())];
  801531:	e8 71 fc ff ff       	call   8011a7 <sys_getenvid>
  801536:	25 ff 03 00 00       	and    $0x3ff,%eax
  80153b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80153e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801543:	a3 1c 30 80 00       	mov    %eax,0x80301c
		return 0;
  801548:	b8 00 00 00 00       	mov    $0x0,%eax
  80154d:	e9 aa 01 00 00       	jmp    8016fc <fork+0x217>
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
		if((uvpd[PDX(pn*PGSIZE)] & PTE_P) && (uvpt[pn] & (PTE_P|PTE_U)))
  801552:	89 f0                	mov    %esi,%eax
  801554:	c1 e8 16             	shr    $0x16,%eax
  801557:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80155e:	a8 01                	test   $0x1,%al
  801560:	0f 84 f9 00 00 00    	je     80165f <fork+0x17a>
  801566:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80156d:	a8 05                	test   $0x5,%al
  80156f:	0f 84 ea 00 00 00    	je     80165f <fork+0x17a>
	int r;

	int perm = (PTE_P|PTE_U);   //PTE_AVAIL ???


	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
  801575:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80157c:	a8 02                	test   $0x2,%al
  80157e:	75 1c                	jne    80159c <fork+0xb7>
  801580:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801587:	f6 c4 08             	test   $0x8,%ah
  80158a:	75 10                	jne    80159c <fork+0xb7>
  80158c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801593:	f6 c4 04             	test   $0x4,%ah
  801596:	0f 84 99 00 00 00    	je     801635 <fork+0x150>
	{
		if(uvpt[pn] & PTE_SHARE)
  80159c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8015a3:	f6 c4 04             	test   $0x4,%ah
  8015a6:	74 0f                	je     8015b7 <fork+0xd2>
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
  8015a8:	8b 3c 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edi
  8015af:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8015b5:	eb 2d                	jmp    8015e4 <fork+0xff>
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  8015b7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
			perm = PTE_P|PTE_U|PTE_COW;
  8015be:	bf 05 08 00 00       	mov    $0x805,%edi
	if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW)) || (uvpt[pn] & PTE_SHARE))
	{
		if(uvpt[pn] & PTE_SHARE)
		{
			perm = (uvpt[pn] & PTE_SYSCALL); 
		} else if((uvpt[pn] & (PTE_W)) || (uvpt[pn] & (PTE_COW))) {
  8015c3:	a8 02                	test   $0x2,%al
  8015c5:	75 1d                	jne    8015e4 <fork+0xff>
  8015c7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8015ce:	25 00 08 00 00       	and    $0x800,%eax
			perm = PTE_P|PTE_U|PTE_COW;
  8015d3:	83 f8 01             	cmp    $0x1,%eax
  8015d6:	19 ff                	sbb    %edi,%edi
  8015d8:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  8015de:	81 c7 05 08 00 00    	add    $0x805,%edi
		}

		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), (perm))) < 0)
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	57                   	push   %edi
  8015e8:	56                   	push   %esi
  8015e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ec:	56                   	push   %esi
  8015ed:	6a 00                	push   $0x0
  8015ef:	e8 34 fc ff ff       	call   801228 <sys_page_map>
  8015f4:	83 c4 20             	add    $0x20,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	79 12                	jns    80160d <fork+0x128>
			panic("fork: sys_page_map: %e", r);
  8015fb:	50                   	push   %eax
  8015fc:	68 4a 21 80 00       	push   $0x80214a
  801601:	6a 62                	push   $0x62
  801603:	68 2f 21 80 00       	push   $0x80212f
  801608:	e8 77 f1 ff ff       	call   800784 <_panic>
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), (perm))) < 0)
  80160d:	83 ec 0c             	sub    $0xc,%esp
  801610:	57                   	push   %edi
  801611:	56                   	push   %esi
  801612:	6a 00                	push   $0x0
  801614:	56                   	push   %esi
  801615:	6a 00                	push   $0x0
  801617:	e8 0c fc ff ff       	call   801228 <sys_page_map>
  80161c:	83 c4 20             	add    $0x20,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	79 3c                	jns    80165f <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  801623:	50                   	push   %eax
  801624:	68 4a 21 80 00       	push   $0x80214a
  801629:	6a 65                	push   $0x65
  80162b:	68 2f 21 80 00       	push   $0x80212f
  801630:	e8 4f f1 ff ff       	call   800784 <_panic>
	}
	else{
		
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0)
  801635:	83 ec 0c             	sub    $0xc,%esp
  801638:	6a 05                	push   $0x5
  80163a:	56                   	push   %esi
  80163b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80163e:	56                   	push   %esi
  80163f:	6a 00                	push   $0x0
  801641:	e8 e2 fb ff ff       	call   801228 <sys_page_map>
  801646:	83 c4 20             	add    $0x20,%esp
  801649:	85 c0                	test   %eax,%eax
  80164b:	79 12                	jns    80165f <fork+0x17a>
			panic("fork: sys_page_map: %e", r);
  80164d:	50                   	push   %eax
  80164e:	68 4a 21 80 00       	push   $0x80214a
  801653:	6a 6a                	push   $0x6a
  801655:	68 2f 21 80 00       	push   $0x80212f
  80165a:	e8 25 f1 ff ff       	call   800784 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}


	for (pn = 0; pn < (PGNUM(UXSTACKTOP)-2); pn++){
  80165f:	83 c3 01             	add    $0x1,%ebx
  801662:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801668:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80166e:	0f 85 de fe ff ff    	jne    801552 <fork+0x6d>
			duppage(envid, pn);
	}

	//Copying stack
	
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	6a 07                	push   $0x7
  801679:	68 00 f0 bf ee       	push   $0xeebff000
  80167e:	ff 75 e0             	pushl  -0x20(%ebp)
  801681:	e8 5f fb ff ff       	call   8011e5 <sys_page_alloc>
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	79 15                	jns    8016a2 <fork+0x1bd>
		panic("sys_page_alloc: %e", r);
  80168d:	50                   	push   %eax
  80168e:	68 61 21 80 00       	push   $0x802161
  801693:	68 9e 00 00 00       	push   $0x9e
  801698:	68 2f 21 80 00       	push   $0x80212f
  80169d:	e8 e2 f0 ff ff       	call   800784 <_panic>

	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	68 d5 18 80 00       	push   $0x8018d5
  8016aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ad:	e8 7e fc ff ff       	call   801330 <sys_env_set_pgfault_upcall>
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	79 17                	jns    8016d0 <fork+0x1eb>
		panic("sys_pgfault_upcall error");
  8016b9:	83 ec 04             	sub    $0x4,%esp
  8016bc:	68 74 21 80 00       	push   $0x802174
  8016c1:	68 a1 00 00 00       	push   $0xa1
  8016c6:	68 2f 21 80 00       	push   $0x80212f
  8016cb:	e8 b4 f0 ff ff       	call   800784 <_panic>
	
	

	//setting child runnable			
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8016d0:	83 ec 08             	sub    $0x8,%esp
  8016d3:	6a 02                	push   $0x2
  8016d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8016d8:	e8 cf fb ff ff       	call   8012ac <sys_env_set_status>
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	79 15                	jns    8016f9 <fork+0x214>
		panic("sys_env_set_status: %e", r);
  8016e4:	50                   	push   %eax
  8016e5:	68 8d 21 80 00       	push   $0x80218d
  8016ea:	68 a7 00 00 00       	push   $0xa7
  8016ef:	68 2f 21 80 00       	push   $0x80212f
  8016f4:	e8 8b f0 ff ff       	call   800784 <_panic>

	return envid;
  8016f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
	// LAB 4: Your code here.
	//panic("fork not implemented");
}
  8016fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5f                   	pop    %edi
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <sfork>:

// Challenge!
int
sfork(void)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80170a:	68 a4 21 80 00       	push   $0x8021a4
  80170f:	68 b2 00 00 00       	push   $0xb2
  801714:	68 2f 21 80 00       	push   $0x80212f
  801719:	e8 66 f0 ff ff       	call   800784 <_panic>

0080171e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801726:	8b 45 0c             	mov    0xc(%ebp),%eax
  801729:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
//	panic("ipc_recv not implemented");
//	return 0;
	int r;
	if(pg != NULL)
  80172c:	85 c0                	test   %eax,%eax
  80172e:	74 0e                	je     80173e <ipc_recv+0x20>
	{
		r = sys_ipc_recv(pg);
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	50                   	push   %eax
  801734:	e8 5c fc ff ff       	call   801395 <sys_ipc_recv>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	eb 10                	jmp    80174e <ipc_recv+0x30>
	}
	else
	{
		r = sys_ipc_recv((void * )0xF0000000);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	68 00 00 00 f0       	push   $0xf0000000
  801746:	e8 4a fc ff ff       	call   801395 <sys_ipc_recv>
  80174b:	83 c4 10             	add    $0x10,%esp
	}
	if(r != 0 )
  80174e:	85 c0                	test   %eax,%eax
  801750:	74 16                	je     801768 <ipc_recv+0x4a>
	{
		if(from_env_store != NULL)
  801752:	85 db                	test   %ebx,%ebx
  801754:	74 36                	je     80178c <ipc_recv+0x6e>
		{
			*from_env_store = 0;
  801756:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
			if(perm_store != NULL)
  80175c:	85 f6                	test   %esi,%esi
  80175e:	74 2c                	je     80178c <ipc_recv+0x6e>
				*perm_store = 0;
  801760:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801766:	eb 24                	jmp    80178c <ipc_recv+0x6e>
		}
		return r;
	}
	if(from_env_store != NULL)
  801768:	85 db                	test   %ebx,%ebx
  80176a:	74 18                	je     801784 <ipc_recv+0x66>
	{
		*from_env_store = thisenv->env_ipc_from;
  80176c:	a1 1c 30 80 00       	mov    0x80301c,%eax
  801771:	8b 40 74             	mov    0x74(%eax),%eax
  801774:	89 03                	mov    %eax,(%ebx)
		if(perm_store != NULL)
  801776:	85 f6                	test   %esi,%esi
  801778:	74 0a                	je     801784 <ipc_recv+0x66>
			*perm_store = thisenv->env_ipc_perm;
  80177a:	a1 1c 30 80 00       	mov    0x80301c,%eax
  80177f:	8b 40 78             	mov    0x78(%eax),%eax
  801782:	89 06                	mov    %eax,(%esi)
		
	}
	int value = thisenv->env_ipc_value;
  801784:	a1 1c 30 80 00       	mov    0x80301c,%eax
  801789:	8b 40 70             	mov    0x70(%eax),%eax
	
	return value;
}
  80178c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	57                   	push   %edi
  801797:	56                   	push   %esi
  801798:	53                   	push   %ebx
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80179f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
  8017a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017a6:	75 39                	jne    8017e1 <ipc_send+0x4e>
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, (void *)0xF0000000, 0);	
  8017a8:	6a 00                	push   $0x0
  8017aa:	68 00 00 00 f0       	push   $0xf0000000
  8017af:	56                   	push   %esi
  8017b0:	57                   	push   %edi
  8017b1:	e8 bc fb ff ff       	call   801372 <sys_ipc_try_send>
  8017b6:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8017be:	74 16                	je     8017d6 <ipc_send+0x43>
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	74 12                	je     8017d6 <ipc_send+0x43>
				panic("The destination environment is not receiving. Error:%e\n",r);
  8017c4:	50                   	push   %eax
  8017c5:	68 bc 21 80 00       	push   $0x8021bc
  8017ca:	6a 4f                	push   $0x4f
  8017cc:	68 f4 21 80 00       	push   $0x8021f4
  8017d1:	e8 ae ef ff ff       	call   800784 <_panic>
			sys_yield();
  8017d6:	e8 eb f9 ff ff       	call   8011c6 <sys_yield>
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r = 100;
	if(pg == NULL)
	{
		while(r != 0)
  8017db:	85 db                	test   %ebx,%ebx
  8017dd:	75 c9                	jne    8017a8 <ipc_send+0x15>
  8017df:	eb 36                	jmp    801817 <ipc_send+0x84>
	}
	else
	{
		while(r != 0)
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);	
  8017e1:	ff 75 14             	pushl  0x14(%ebp)
  8017e4:	ff 75 10             	pushl  0x10(%ebp)
  8017e7:	56                   	push   %esi
  8017e8:	57                   	push   %edi
  8017e9:	e8 84 fb ff ff       	call   801372 <sys_ipc_try_send>
  8017ee:	89 c3                	mov    %eax,%ebx
			if(r != -E_IPC_NOT_RECV && r !=0)
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8017f6:	74 16                	je     80180e <ipc_send+0x7b>
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	74 12                	je     80180e <ipc_send+0x7b>
				panic("The destination environment is not receiving. Error:%e\n",r);
  8017fc:	50                   	push   %eax
  8017fd:	68 bc 21 80 00       	push   $0x8021bc
  801802:	6a 5a                	push   $0x5a
  801804:	68 f4 21 80 00       	push   $0x8021f4
  801809:	e8 76 ef ff ff       	call   800784 <_panic>
			sys_yield();
  80180e:	e8 b3 f9 ff ff       	call   8011c6 <sys_yield>
		}
		
	}
	else
	{
		while(r != 0)
  801813:	85 db                	test   %ebx,%ebx
  801815:	75 ca                	jne    8017e1 <ipc_send+0x4e>
			if(r != -E_IPC_NOT_RECV && r !=0)
				panic("The destination environment is not receiving. Error:%e\n",r);
			sys_yield();
		}
	}
}
  801817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5f                   	pop    %edi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80182a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80182d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801833:	8b 52 50             	mov    0x50(%edx),%edx
  801836:	39 ca                	cmp    %ecx,%edx
  801838:	75 0d                	jne    801847 <ipc_find_env+0x28>
			return envs[i].env_id;
  80183a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80183d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801842:	8b 40 48             	mov    0x48(%eax),%eax
  801845:	eb 0f                	jmp    801856 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801847:	83 c0 01             	add    $0x1,%eax
  80184a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80184f:	75 d9                	jne    80182a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801851:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80185e:	83 3d 20 30 80 00 00 	cmpl   $0x0,0x803020
  801865:	75 64                	jne    8018cb <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		int r;
		r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801867:	a1 1c 30 80 00       	mov    0x80301c,%eax
  80186c:	8b 40 48             	mov    0x48(%eax),%eax
  80186f:	83 ec 04             	sub    $0x4,%esp
  801872:	6a 07                	push   $0x7
  801874:	68 00 f0 bf ee       	push   $0xeebff000
  801879:	50                   	push   %eax
  80187a:	e8 66 f9 ff ff       	call   8011e5 <sys_page_alloc>
		if ( r != 0)
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	85 c0                	test   %eax,%eax
  801884:	74 14                	je     80189a <set_pgfault_handler+0x42>
			panic("set_pgfault_handler: sys_page_alloc failed.");
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	68 00 22 80 00       	push   $0x802200
  80188e:	6a 24                	push   $0x24
  801890:	68 50 22 80 00       	push   $0x802250
  801895:	e8 ea ee ff ff       	call   800784 <_panic>
			
		if (sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall) < 0)
  80189a:	a1 1c 30 80 00       	mov    0x80301c,%eax
  80189f:	8b 40 48             	mov    0x48(%eax),%eax
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	68 d5 18 80 00       	push   $0x8018d5
  8018aa:	50                   	push   %eax
  8018ab:	e8 80 fa ff ff       	call   801330 <sys_env_set_pgfault_upcall>
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	79 14                	jns    8018cb <set_pgfault_handler+0x73>
		 	panic("sys_env_set_pgfault_upcall failed");
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	68 2c 22 80 00       	push   $0x80222c
  8018bf:	6a 27                	push   $0x27
  8018c1:	68 50 22 80 00       	push   $0x802250
  8018c6:	e8 b9 ee ff ff       	call   800784 <_panic>
			
	}

	
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	a3 20 30 80 00       	mov    %eax,0x803020
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8018d5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8018d6:	a1 20 30 80 00       	mov    0x803020,%eax
	call *%eax
  8018db:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8018dd:	83 c4 04             	add    $0x4,%esp
	addl $0x4,%esp
	popfl
	popl %esp
	ret
*/
movl 0x28(%esp), %eax
  8018e0:	8b 44 24 28          	mov    0x28(%esp),%eax
movl %esp, %ebx
  8018e4:	89 e3                	mov    %esp,%ebx
movl 0x30(%esp), %esp
  8018e6:	8b 64 24 30          	mov    0x30(%esp),%esp
pushl %eax
  8018ea:	50                   	push   %eax
movl %esp, 0x30(%ebx)
  8018eb:	89 63 30             	mov    %esp,0x30(%ebx)
movl %ebx, %esp
  8018ee:	89 dc                	mov    %ebx,%esp
addl $0x8, %esp
  8018f0:	83 c4 08             	add    $0x8,%esp
popal
  8018f3:	61                   	popa   
addl $0x4, %esp
  8018f4:	83 c4 04             	add    $0x4,%esp
popfl
  8018f7:	9d                   	popf   
popl %esp
  8018f8:	5c                   	pop    %esp
ret
  8018f9:	c3                   	ret    
  8018fa:	66 90                	xchg   %ax,%ax
  8018fc:	66 90                	xchg   %ax,%ax
  8018fe:	66 90                	xchg   %ax,%ax

00801900 <__udivdi3>:
  801900:	55                   	push   %ebp
  801901:	57                   	push   %edi
  801902:	56                   	push   %esi
  801903:	53                   	push   %ebx
  801904:	83 ec 1c             	sub    $0x1c,%esp
  801907:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80190b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80190f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801913:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801917:	85 f6                	test   %esi,%esi
  801919:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191d:	89 ca                	mov    %ecx,%edx
  80191f:	89 f8                	mov    %edi,%eax
  801921:	75 3d                	jne    801960 <__udivdi3+0x60>
  801923:	39 cf                	cmp    %ecx,%edi
  801925:	0f 87 c5 00 00 00    	ja     8019f0 <__udivdi3+0xf0>
  80192b:	85 ff                	test   %edi,%edi
  80192d:	89 fd                	mov    %edi,%ebp
  80192f:	75 0b                	jne    80193c <__udivdi3+0x3c>
  801931:	b8 01 00 00 00       	mov    $0x1,%eax
  801936:	31 d2                	xor    %edx,%edx
  801938:	f7 f7                	div    %edi
  80193a:	89 c5                	mov    %eax,%ebp
  80193c:	89 c8                	mov    %ecx,%eax
  80193e:	31 d2                	xor    %edx,%edx
  801940:	f7 f5                	div    %ebp
  801942:	89 c1                	mov    %eax,%ecx
  801944:	89 d8                	mov    %ebx,%eax
  801946:	89 cf                	mov    %ecx,%edi
  801948:	f7 f5                	div    %ebp
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	89 d8                	mov    %ebx,%eax
  80194e:	89 fa                	mov    %edi,%edx
  801950:	83 c4 1c             	add    $0x1c,%esp
  801953:	5b                   	pop    %ebx
  801954:	5e                   	pop    %esi
  801955:	5f                   	pop    %edi
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    
  801958:	90                   	nop
  801959:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801960:	39 ce                	cmp    %ecx,%esi
  801962:	77 74                	ja     8019d8 <__udivdi3+0xd8>
  801964:	0f bd fe             	bsr    %esi,%edi
  801967:	83 f7 1f             	xor    $0x1f,%edi
  80196a:	0f 84 98 00 00 00    	je     801a08 <__udivdi3+0x108>
  801970:	bb 20 00 00 00       	mov    $0x20,%ebx
  801975:	89 f9                	mov    %edi,%ecx
  801977:	89 c5                	mov    %eax,%ebp
  801979:	29 fb                	sub    %edi,%ebx
  80197b:	d3 e6                	shl    %cl,%esi
  80197d:	89 d9                	mov    %ebx,%ecx
  80197f:	d3 ed                	shr    %cl,%ebp
  801981:	89 f9                	mov    %edi,%ecx
  801983:	d3 e0                	shl    %cl,%eax
  801985:	09 ee                	or     %ebp,%esi
  801987:	89 d9                	mov    %ebx,%ecx
  801989:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80198d:	89 d5                	mov    %edx,%ebp
  80198f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801993:	d3 ed                	shr    %cl,%ebp
  801995:	89 f9                	mov    %edi,%ecx
  801997:	d3 e2                	shl    %cl,%edx
  801999:	89 d9                	mov    %ebx,%ecx
  80199b:	d3 e8                	shr    %cl,%eax
  80199d:	09 c2                	or     %eax,%edx
  80199f:	89 d0                	mov    %edx,%eax
  8019a1:	89 ea                	mov    %ebp,%edx
  8019a3:	f7 f6                	div    %esi
  8019a5:	89 d5                	mov    %edx,%ebp
  8019a7:	89 c3                	mov    %eax,%ebx
  8019a9:	f7 64 24 0c          	mull   0xc(%esp)
  8019ad:	39 d5                	cmp    %edx,%ebp
  8019af:	72 10                	jb     8019c1 <__udivdi3+0xc1>
  8019b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8019b5:	89 f9                	mov    %edi,%ecx
  8019b7:	d3 e6                	shl    %cl,%esi
  8019b9:	39 c6                	cmp    %eax,%esi
  8019bb:	73 07                	jae    8019c4 <__udivdi3+0xc4>
  8019bd:	39 d5                	cmp    %edx,%ebp
  8019bf:	75 03                	jne    8019c4 <__udivdi3+0xc4>
  8019c1:	83 eb 01             	sub    $0x1,%ebx
  8019c4:	31 ff                	xor    %edi,%edi
  8019c6:	89 d8                	mov    %ebx,%eax
  8019c8:	89 fa                	mov    %edi,%edx
  8019ca:	83 c4 1c             	add    $0x1c,%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5e                   	pop    %esi
  8019cf:	5f                   	pop    %edi
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    
  8019d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8019d8:	31 ff                	xor    %edi,%edi
  8019da:	31 db                	xor    %ebx,%ebx
  8019dc:	89 d8                	mov    %ebx,%eax
  8019de:	89 fa                	mov    %edi,%edx
  8019e0:	83 c4 1c             	add    $0x1c,%esp
  8019e3:	5b                   	pop    %ebx
  8019e4:	5e                   	pop    %esi
  8019e5:	5f                   	pop    %edi
  8019e6:	5d                   	pop    %ebp
  8019e7:	c3                   	ret    
  8019e8:	90                   	nop
  8019e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8019f0:	89 d8                	mov    %ebx,%eax
  8019f2:	f7 f7                	div    %edi
  8019f4:	31 ff                	xor    %edi,%edi
  8019f6:	89 c3                	mov    %eax,%ebx
  8019f8:	89 d8                	mov    %ebx,%eax
  8019fa:	89 fa                	mov    %edi,%edx
  8019fc:	83 c4 1c             	add    $0x1c,%esp
  8019ff:	5b                   	pop    %ebx
  801a00:	5e                   	pop    %esi
  801a01:	5f                   	pop    %edi
  801a02:	5d                   	pop    %ebp
  801a03:	c3                   	ret    
  801a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a08:	39 ce                	cmp    %ecx,%esi
  801a0a:	72 0c                	jb     801a18 <__udivdi3+0x118>
  801a0c:	31 db                	xor    %ebx,%ebx
  801a0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801a12:	0f 87 34 ff ff ff    	ja     80194c <__udivdi3+0x4c>
  801a18:	bb 01 00 00 00       	mov    $0x1,%ebx
  801a1d:	e9 2a ff ff ff       	jmp    80194c <__udivdi3+0x4c>
  801a22:	66 90                	xchg   %ax,%ax
  801a24:	66 90                	xchg   %ax,%ax
  801a26:	66 90                	xchg   %ax,%ax
  801a28:	66 90                	xchg   %ax,%ax
  801a2a:	66 90                	xchg   %ax,%ax
  801a2c:	66 90                	xchg   %ax,%ax
  801a2e:	66 90                	xchg   %ax,%ax

00801a30 <__umoddi3>:
  801a30:	55                   	push   %ebp
  801a31:	57                   	push   %edi
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	83 ec 1c             	sub    $0x1c,%esp
  801a37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801a3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801a3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801a43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801a47:	85 d2                	test   %edx,%edx
  801a49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801a4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a51:	89 f3                	mov    %esi,%ebx
  801a53:	89 3c 24             	mov    %edi,(%esp)
  801a56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a5a:	75 1c                	jne    801a78 <__umoddi3+0x48>
  801a5c:	39 f7                	cmp    %esi,%edi
  801a5e:	76 50                	jbe    801ab0 <__umoddi3+0x80>
  801a60:	89 c8                	mov    %ecx,%eax
  801a62:	89 f2                	mov    %esi,%edx
  801a64:	f7 f7                	div    %edi
  801a66:	89 d0                	mov    %edx,%eax
  801a68:	31 d2                	xor    %edx,%edx
  801a6a:	83 c4 1c             	add    $0x1c,%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	5f                   	pop    %edi
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    
  801a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a78:	39 f2                	cmp    %esi,%edx
  801a7a:	89 d0                	mov    %edx,%eax
  801a7c:	77 52                	ja     801ad0 <__umoddi3+0xa0>
  801a7e:	0f bd ea             	bsr    %edx,%ebp
  801a81:	83 f5 1f             	xor    $0x1f,%ebp
  801a84:	75 5a                	jne    801ae0 <__umoddi3+0xb0>
  801a86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801a8a:	0f 82 e0 00 00 00    	jb     801b70 <__umoddi3+0x140>
  801a90:	39 0c 24             	cmp    %ecx,(%esp)
  801a93:	0f 86 d7 00 00 00    	jbe    801b70 <__umoddi3+0x140>
  801a99:	8b 44 24 08          	mov    0x8(%esp),%eax
  801a9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801aa1:	83 c4 1c             	add    $0x1c,%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5e                   	pop    %esi
  801aa6:	5f                   	pop    %edi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    
  801aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ab0:	85 ff                	test   %edi,%edi
  801ab2:	89 fd                	mov    %edi,%ebp
  801ab4:	75 0b                	jne    801ac1 <__umoddi3+0x91>
  801ab6:	b8 01 00 00 00       	mov    $0x1,%eax
  801abb:	31 d2                	xor    %edx,%edx
  801abd:	f7 f7                	div    %edi
  801abf:	89 c5                	mov    %eax,%ebp
  801ac1:	89 f0                	mov    %esi,%eax
  801ac3:	31 d2                	xor    %edx,%edx
  801ac5:	f7 f5                	div    %ebp
  801ac7:	89 c8                	mov    %ecx,%eax
  801ac9:	f7 f5                	div    %ebp
  801acb:	89 d0                	mov    %edx,%eax
  801acd:	eb 99                	jmp    801a68 <__umoddi3+0x38>
  801acf:	90                   	nop
  801ad0:	89 c8                	mov    %ecx,%eax
  801ad2:	89 f2                	mov    %esi,%edx
  801ad4:	83 c4 1c             	add    $0x1c,%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5f                   	pop    %edi
  801ada:	5d                   	pop    %ebp
  801adb:	c3                   	ret    
  801adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ae0:	8b 34 24             	mov    (%esp),%esi
  801ae3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ae8:	89 e9                	mov    %ebp,%ecx
  801aea:	29 ef                	sub    %ebp,%edi
  801aec:	d3 e0                	shl    %cl,%eax
  801aee:	89 f9                	mov    %edi,%ecx
  801af0:	89 f2                	mov    %esi,%edx
  801af2:	d3 ea                	shr    %cl,%edx
  801af4:	89 e9                	mov    %ebp,%ecx
  801af6:	09 c2                	or     %eax,%edx
  801af8:	89 d8                	mov    %ebx,%eax
  801afa:	89 14 24             	mov    %edx,(%esp)
  801afd:	89 f2                	mov    %esi,%edx
  801aff:	d3 e2                	shl    %cl,%edx
  801b01:	89 f9                	mov    %edi,%ecx
  801b03:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b0b:	d3 e8                	shr    %cl,%eax
  801b0d:	89 e9                	mov    %ebp,%ecx
  801b0f:	89 c6                	mov    %eax,%esi
  801b11:	d3 e3                	shl    %cl,%ebx
  801b13:	89 f9                	mov    %edi,%ecx
  801b15:	89 d0                	mov    %edx,%eax
  801b17:	d3 e8                	shr    %cl,%eax
  801b19:	89 e9                	mov    %ebp,%ecx
  801b1b:	09 d8                	or     %ebx,%eax
  801b1d:	89 d3                	mov    %edx,%ebx
  801b1f:	89 f2                	mov    %esi,%edx
  801b21:	f7 34 24             	divl   (%esp)
  801b24:	89 d6                	mov    %edx,%esi
  801b26:	d3 e3                	shl    %cl,%ebx
  801b28:	f7 64 24 04          	mull   0x4(%esp)
  801b2c:	39 d6                	cmp    %edx,%esi
  801b2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b32:	89 d1                	mov    %edx,%ecx
  801b34:	89 c3                	mov    %eax,%ebx
  801b36:	72 08                	jb     801b40 <__umoddi3+0x110>
  801b38:	75 11                	jne    801b4b <__umoddi3+0x11b>
  801b3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801b3e:	73 0b                	jae    801b4b <__umoddi3+0x11b>
  801b40:	2b 44 24 04          	sub    0x4(%esp),%eax
  801b44:	1b 14 24             	sbb    (%esp),%edx
  801b47:	89 d1                	mov    %edx,%ecx
  801b49:	89 c3                	mov    %eax,%ebx
  801b4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801b4f:	29 da                	sub    %ebx,%edx
  801b51:	19 ce                	sbb    %ecx,%esi
  801b53:	89 f9                	mov    %edi,%ecx
  801b55:	89 f0                	mov    %esi,%eax
  801b57:	d3 e0                	shl    %cl,%eax
  801b59:	89 e9                	mov    %ebp,%ecx
  801b5b:	d3 ea                	shr    %cl,%edx
  801b5d:	89 e9                	mov    %ebp,%ecx
  801b5f:	d3 ee                	shr    %cl,%esi
  801b61:	09 d0                	or     %edx,%eax
  801b63:	89 f2                	mov    %esi,%edx
  801b65:	83 c4 1c             	add    $0x1c,%esp
  801b68:	5b                   	pop    %ebx
  801b69:	5e                   	pop    %esi
  801b6a:	5f                   	pop    %edi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    
  801b6d:	8d 76 00             	lea    0x0(%esi),%esi
  801b70:	29 f9                	sub    %edi,%ecx
  801b72:	19 d6                	sbb    %edx,%esi
  801b74:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b7c:	e9 18 ff ff ff       	jmp    801a99 <__umoddi3+0x69>
