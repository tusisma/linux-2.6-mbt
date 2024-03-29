/*
 * Copyright (C) 2010-2011 Freescale Semiconductor, Inc. All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <linux/linkage.h>
#include <mach/hardware.h>
#include <asm/memory.h>
#include <asm/hardware/cache-l2x0.h>
#include "src-reg.h"

#define ARM_CTRL_DCACHE		(1 << 2)
#define ARM_CTRL_ICACHE		(1 << 12)
#define ARM_AUXCR_L2EN		(1 << 1)
#define TTRBIT_MASK 		0xffffc000
#define TABLE_INDEX_MASK 	0xfff00000
#define TABLE_ENTRY 		0x00000c02
#define CACHE_DISABLE_MASK 	0xffffe7fb
#define MMDC_MAPSR_OFFSET 	0x404
#define MMDC_MAPSR_PSS 		(1 << 4)
#define MMDC_MAPSR_PSD 		(1 << 0)
#define IRAM_SUSPEND_SIZE 	(1 << 12)

/*************************************************************
mx6q_suspend:

Suspend the processor (eg, wait for interrupt).
Set the DDR into Self Refresh
IRQs are already disabled.

The following code contain both standby and
dormant mode for MX6, decided by the parameter
passed in r0:
see define in include/linux/suspend.h
1 -> cpu enter stop mode;
3 -> cpu enter dormant mode.
r1: iram_paddr
r2: suspend_iram_base
*************************************************************/
	.macro	ddr_io_save

	ldr	r4, [r1, #0x5ac] /* DRAM_DQM0 */
	ldr	r5, [r1, #0x5b4] /* DRAM_DQM1 */
	ldr	r6, [r1, #0x528] /* DRAM_DQM2 */
	ldr	r7, [r1, #0x520] /* DRAM_DQM3 */
	stmfd	r0!, {r4-r7}

	ldr	r4, [r1, #0x514] /* DRAM_DQM4 */
	ldr	r5, [r1, #0x510] /* DRAM_DQM5 */
	ldr	r6, [r1, #0x5bc] /* DRAM_DQM6 */
	ldr	r7, [r1, #0x5c4] /* DRAM_DQM7 */
	stmfd	r0!, {r4-r7}

	ldr	r4, [r1, #0x56c] /* DRAM_CAS */
	ldr	r5, [r1, #0x578] /* DRAM_RAS */
	ldr	r6, [r1, #0x588] /* DRAM_SDCLK_0 */
	ldr	r7, [r1, #0x594] /* DRAM_SDCLK_1 */
	stmfd	r0!, {r4-r7}

	ldr	r5, [r1, #0x750] /* DDRMODE_CTL */
	ldr	r6, [r1, #0x774] /* DDRMODE */
	stmfd	r0!, {r5-r6}

	ldr	r4, [r1, #0x5a8] /* DRAM_SDQS0 */
	ldr	r5, [r1, #0x5b0] /* DRAM_SDQS1 */
	ldr	r6, [r1, #0x524] /* DRAM_SDQS2 */
	ldr	r7, [r1, #0x51c] /* DRAM_SDQS3 */
	stmfd	r0!, {r4-r7}

	ldr	r4, [r1, #0x518] /* DRAM_SDQS4 */
	ldr	r5, [r1, #0x50c] /* DRAM_SDQS5 */
	ldr	r6, [r1, #0x5b8] /* DRAM_SDQS6 */
	ldr	r7, [r1, #0x5c0] /* DRAM_SDQS7 */
	stmfd	r0!, {r4-r7}

	ldr	r4, [r1, #0x784] /* GPR_B0DS */
	ldr	r5, [r1, #0x788] /* GPR_B1DS */
	ldr	r6, [r1, #0x794] /* GPR_B2DS */
	ldr	r7, [r1, #0x79c] /* GPR_B3DS */
	stmfd	r0!, {r4-r7}

	ldr	r4, [r1, #0x7a0] /* GPR_B4DS */
	ldr	r5, [r1, #0x7a4] /* GPR_B5DS */
	ldr	r6, [r1, #0x7a8] /* GPR_B6DS */
	ldr	r7, [r1, #0x748] /* GPR_B7DS */
	stmfd	r0!, {r4-r7}

	ldr	r5, [r1, #0x74c] /* GPR_ADDS*/
	ldr	r6, [r1, #0x59c] /* DRAM_SODT0*/
	ldr	r7, [r1, #0x5a0] /* DRAM_SODT1*/
	stmfd	r0!, {r5-r7}

	.endm

	.macro	ddr_io_restore

	ldmea	r0!, {r4-r7}
	str	r4, [r1, #0x5ac] /* DRAM_DQM0 */
	str	r5, [r1, #0x5b4] /* DRAM_DQM1 */
	str	r6, [r1, #0x528] /* DRAM_DQM2 */
	str	r7, [r1, #0x520] /* DRAM_DQM3 */

	ldmea	r0!, {r4-r7}
	str	r4, [r1, #0x514] /* DRAM_DQM4 */
	str	r5, [r1, #0x510] /* DRAM_DQM5 */
	str	r6, [r1, #0x5bc] /* DRAM_DQM6 */
	str	r7, [r1, #0x5c4] /* DRAM_DQM7 */

	ldmea	r0!, {r4-r7}
	str	r4, [r1, #0x56c] /* DRAM_CAS */
	str	r5, [r1, #0x578] /* DRAM_RAS */
	str	r6, [r1, #0x588] /* DRAM_SDCLK_0 */
	str	r7, [r1, #0x594] /* DRAM_SDCLK_1 */

	ldmea	r0!, {r5-r6}
	str	r5, [r1, #0x750] /* DDRMODE_CTL */
	str	r6, [r1, #0x774] /* DDRMODE */

	ldmea	r0!, {r4-r7}
	str	r4, [r1, #0x5a8] /* DRAM_SDQS0 */
	str	r5, [r1, #0x5b0] /* DRAM_SDQS1 */
	str	r6, [r1, #0x524] /* DRAM_SDQS2 */
	str	r7, [r1, #0x51c] /* DRAM_SDQS3 */

	ldmea	r0!, {r4-r7}
	str	r4, [r1, #0x518] /* DRAM_SDQS4 */
	str	r5, [r1, #0x50c] /* DRAM_SDQS5 */
	str	r6, [r1, #0x5b8] /* DRAM_SDQS6 */
	str	r7, [r1, #0x5c0] /* DRAM_SDQS7 */

	ldmea	r0!, {r4-r7}
	str	r4, [r1, #0x784] /* GPR_B0DS */
	str	r5, [r1, #0x788] /* GPR_B1DS */
	str	r6, [r1, #0x794] /* GPR_B2DS */
	str	r7, [r1, #0x79c] /* GPR_B3DS */

	ldmea	r0!, {r4-r7}
	str	r4, [r1, #0x7a0] /* GPR_B4DS */
	str	r5, [r1, #0x7a4] /* GPR_B5DS */
	str	r6, [r1, #0x7a8] /* GPR_B6DS */
	str	r7, [r1, #0x748] /* GPR_B7DS */

	ldmea	r0!, {r5-r7}
	str	r5, [r1, #0x74c] /* GPR_ADDS*/
	str	r6, [r1, #0x59c] /* DRAM_SODT0*/
	str	r7, [r1, #0x5a0] /* DRAM_SODT1*/

	.endm

	.macro	ddr_io_set_lpm

	mov	r0, #0
	str	r0, [r1, #0x5ac] /* DRAM_DQM0 */
	str	r0, [r1, #0x5b4] /* DRAM_DQM1 */
	str	r0, [r1, #0x528] /* DRAM_DQM2 */
	str	r0, [r1, #0x520] /* DRAM_DQM3 */

	str	r0, [r1, #0x514] /* DRAM_DQM4 */
	str	r0, [r1, #0x510] /* DRAM_DQM5 */
	str	r0, [r1, #0x5bc] /* DRAM_DQM6 */
	str	r0, [r1, #0x5c4] /* DRAM_DQM7 */

	str	r0, [r1, #0x56c] /* DRAM_CAS */
	str	r0, [r1, #0x578] /* DRAM_RAS */
	str	r0, [r1, #0x588] /* DRAM_SDCLK_0 */
	str	r0, [r1, #0x594] /* DRAM_SDCLK_1 */

	str	r0, [r1, #0x750] /* DDRMODE_CTL */
	str	r0, [r1, #0x774] /* DDRMODE */

	str	r0, [r1, #0x5a8] /* DRAM_SDQS0 */
	str	r0, [r1, #0x5b0] /* DRAM_SDQS1 */
	str	r0, [r1, #0x524] /* DRAM_SDQS2 */
	str	r0, [r1, #0x51c] /* DRAM_SDQS3 */

	str	r0, [r1, #0x518] /* DRAM_SDQS4 */
	str	r0, [r1, #0x50c] /* DRAM_SDQS5 */
	str	r0, [r1, #0x5b8] /* DRAM_SDQS6 */
	str	r0, [r1, #0x5c0] /* DRAM_SDQS7 */

	str	r0, [r1, #0x784] /* GPR_B0DS */
	str	r0, [r1, #0x788] /* GPR_B1DS */
	str	r0, [r1, #0x794] /* GPR_B2DS */
	str	r0, [r1, #0x79c] /* GPR_B3DS */

	str	r0, [r1, #0x7a0] /* GPR_B4DS */
	str	r0, [r1, #0x7a4] /* GPR_B5DS */
	str	r0, [r1, #0x7a8] /* GPR_B6DS */
	str	r0, [r1, #0x748] /* GPR_B7DS */

	str	r0, [r1, #0x74c] /* GPR_ADDS*/
	str	r0, [r1, #0x59c] /* DRAM_SODT0*/
	str	r0, [r1, #0x5a0] /* DRAM_SODT1*/

	.endm

ENTRY(mx6q_suspend)
	stmfd	sp!, {r0-r12}     @ Save registers
/*************************************************************
suspend mode entry
*************************************************************/

	cmp	r0, #0x1
	bne	dormant		/* dormant mode */

	dsb
	wfi

	nop
	nop
	nop
	nop
	/* Due to the L2 cache errata(TKT065875)
	, need to wait at least 170ns, each IO read
	takes about 76ns, but the actual wait time
	to make system more stable is about 380ns */
	ldr	r0, =SRC_BASE_ADDR
	add 	r0, r0, #PERIPBASE_VIRT
	ldr	r1, [r0]
	ldr	r1, [r0, #0x4]
	ldr	r1, [r0, #0x8]
	ldr	r1, [r0, #0xc]
	ldr	r1, [r0, #0x10]
/***********************************************************
never run to here
************************************************************/
	b 	out	/* exit standby */

/************************************************************
dormant entry, data save in stack, save sp in the src_gpr2
************************************************************/
dormant:
	mov 	r3, r1
	mov 	r0, r1
	add 	r0, r0, #IRAM_SUSPEND_SIZE /* 4K */
	ldr 	r4, =SRC_BASE_ADDR
	add 	r4, r4, #PERIPBASE_VIRT
	str 	r0, [r4, #SRC_GPR2_OFFSET] /* set src_gpr2 */
/************************************************************
saved register and context as below:
	ddr_iomux set
	sp
	spsr
	lr
	CPACR
	TTBR0
	TTBR1
	TTBCR
	DACR
	PRRR
	NMRR
	ACTLR
	Context ID
	User r/w thread ID
	Secure or NS VBAR
	CPSR
	SCTLR
************************************************************/
ddr_iomux_save:
	/* save mmdc iomux setting, stack is from the tail of
	iram_suspend base */

	mov	r0, r2 		/* get suspend_iram_base */
	add	r0, r0, #IRAM_SUSPEND_SIZE	/* 4K */
	ldr	r1, =MX6Q_IOMUXC_BASE_ADDR
	add	r1, r1, #PERIPBASE_VIRT

	ddr_io_save

	mov	r4, sp			@ Store sp
	mrs	r5, spsr		@ Store spsr
	mov	r6, lr			@ Store lr
	stmfd	r0!, {r4-r6}

	/* c1 and c2 registers */
	mrc	p15, 0, r4, c1, c0, 2	@ CPACR
	mrc	p15, 0, r5, c2, c0, 0	@ TTBR0
	mrc	p15, 0, r6, c2, c0, 1	@ TTBR1
	mrc	p15, 0, r7, c2, c0, 2	@ TTBCR
	stmfd	r0!, {r4-r7}

	/* c3 and c10 registers */
	mrc	p15, 0, r4, c3, c0, 0	@ DACR
	mrc	p15, 0, r5, c10, c2, 0	@ PRRR
	mrc	p15, 0, r6, c10, c2, 1	@ NMRR
	mrc	p15, 0, r7, c1, c0, 1	@ ACTLR
	stmfd	r0!,{r4-r7}

	/* c12, c13 and CPSR registers */
	mrc	p15, 0, r4, c13, c0, 1	@ Context ID
	mrc	p15, 0, r5, c13, c0, 2	@ User r/w thread ID
	mrc	p15, 0, r6, c12, c0, 0	@ Secure or NS VBAR
	mrs	r7, cpsr		@ Store CPSR
	stmfd	r0!, {r4-r7}

	/* c1 control register */
	mrc	p15, 0, r4, c1, c0, 0	@ SCTLR
	stmfd	r0!, {r4}

#ifdef CONFIG_CACHE_L2X0
	ldr r2, =L2_BASE_ADDR
	add r2, r2, #PERIPBASE_VIRT

	ldr	r4, [r2, #L2X0_CTRL]
	ldr	r5, [r2, #L2X0_AUX_CTRL]
	ldr	r6, [r2, #L2X0_TAG_LATENCY_CTRL]
	ldr	r7, [r2, #L2X0_DATA_LATENCY_CTRL]
	stmfd	r0!, {r4-r7}

	ldr	r4, [r2, #L2X0_PREFETCH_CTRL]
	ldr	r5, [r2, #L2X0_POWER_CTRL]
	stmfd	r0!, {r4-r5}
#endif
	/*
	 * Flush all data from the L1 data cache before disabling
	 * SCTLR.C bit.
	 */
	push	{r0-r12, lr}
	ldr	r0, =v7_flush_dcache_all
	mov	lr, pc
	mov	pc, r0
	pop	{r0-r12, lr}

	/*
	 * Clear the SCTLR.C bit to prevent further data cache
	 * allocation. Clearing SCTLR.C would make all the data accesses
	 * strongly ordered and would not hit the cache.
	 */
	mrc	p15, 0, r0, c1, c0, 0
	bic	r0, r0, #(1 << 2)	@ Disable the C bit
	mcr	p15, 0, r0, c1, c0, 0
	isb

	/*
	 * Invalidate L1 data cache. Even though only invalidate is
	 * necessary exported flush API is used here. Doing clean
	 * on already clean cache would be almost NOP.
	 */
	push	{r0-r12, lr}
	ldr	r0, =v7_flush_dcache_all
	mov	lr, pc
	mov	pc, r0
	pop	{r0-r12, lr}

	/*
	 * Execute an ISB instruction to ensure that all of the
	 * CP15 register changes have been committed.
	 */
	isb

	/*
	 * Execute a barrier instruction to ensure that all cache,
	 * TLB and branch predictor maintenance operations issued
	 * by any CPU in the cluster have completed.
	 */
	dsb
	dmb

	/* Clean L2 cache to write the dirty data into DRAM to make
	sure the data alignment between DRAM and L2 cache.
	*/
#ifdef CONFIG_CACHE_L2X0
	/* Clean L2 cache here */
	ldr	r1, =L2_BASE_ADDR
	add	r1, r1, #PERIPBASE_VIRT
	/* Make way to 0xFFFF 16 ways */
	mov	r0, #0x10000
	sub	r0, r0, #0x1
	/* 0x7BC is L2X0_CLEAN_WAY */
	mov	r4, #0x700
	orr	r4, #0xBC
	str	r0, [r1, r4]
wait:
	ldr	r2, [r1, r4]
	ands	r2, r2, r0
	bne	wait
l2x0_sync:
	mov	r2, #0x0
	/* 0x730 is L2X0_CACHE_SYNC */
	mov	r4, #0x700
	orr	r4, #0x30
	str	r2, [r1, r4]
sync:
	ldr	r2, [r1, r4]
	ands	r2, r2, #0x1
	bne	sync
#endif
/****************************************************************
set ddr iomux to low power mode
****************************************************************/
	ldr	r1, =MMDC_P0_BASE_ADDR
	add	r1, r1, #PERIPBASE_VIRT
	ldr	r0, [r1, #MMDC_MAPSR_OFFSET]
	bic	r0, #MMDC_MAPSR_PSD 		/* enable lpm */
	str	r0, [r1, #MMDC_MAPSR_OFFSET]
refresh:
	ldr	r0, [r1, #MMDC_MAPSR_OFFSET] 	/* MMDC_MAPSR */
	and	r0, r0, #MMDC_MAPSR_PSS 	/* PSS bit */
	cmp	r0, #0
	beq	refresh

	/* set mmdc iomux to low power mode */
	ldr	r1, =MX6Q_IOMUXC_BASE_ADDR
	add	r1, r1, #PERIPBASE_VIRT

	ddr_io_set_lpm
/****************************************************************
save resume pointer into SRC_GPR1
****************************************************************/
	ldr	r0, =mx6q_suspend
	ldr	r1, =resume
	sub	r1, r1, r0
	add	r3, r3, r1
	ldr	r1, =SRC_BASE_ADDR
	add	r1, r1, #PERIPBASE_VIRT
	str	r3, [r1, #SRC_GPR1_OFFSET]
/****************************************************************
execute a wfi instruction to let SOC go into stop mode.
****************************************************************/
	wfi

	nop
	nop
	nop
	nop

/****************************************************************
if go here, means there is a wakeup irq pending, we should resume
system immediately.
****************************************************************/
	mov	r0, r2 		/* get suspend_iram_base */
	add	r0, r0, #IRAM_SUSPEND_SIZE	/* 4K */

	ldr	r1, =MX6Q_IOMUXC_BASE_ADDR
	add	r1, r1, #PERIPBASE_VIRT

	ddr_io_restore

	mrc	p15, 0, r1, c1, c0, 0
	orr	r1, r1, #(1 << 2)	@ Enable the C bit
	mcr	p15, 0, r1, c1, c0, 0

	b 	out	/* exit standby */

/****************************************************************
when SOC exit stop mode, arm core restart from here, currently
are running with MMU off.
****************************************************************/
resume:
	ldr	r0, =SRC_BASE_ADDR
	/* Due to the L2 cache errata(TKT065875)
	, need to wait at least 170ns, each IO read
	takes about 76ns, but the actual wait time
	to make system more stable is about 380ns */
	ldr	r1, [r0]
	ldr	r1, [r0, #0x4]
	ldr	r1, [r0, #0x8]
	ldr	r1, [r0, #0xc]
	ldr	r1, [r0, #0x10]
	mov	r1, #0x0
	str	r1, [r0, #SRC_GPR1_OFFSET] /* clear SRC_GPR1 */
	ldr	r0, [r0, #SRC_GPR2_OFFSET]

	ldr	r1, =MX6Q_IOMUXC_BASE_ADDR
	ddr_io_restore

	/* Restore cp15 registers */
	ldmea	r0!, {r4-r6}
	mov	sp, r4
	msr	spsr_cxsf, r5		@ Restore spsr
	mov	lr, r6			@ Restore lr

	/* c1 and c2 registers */
	ldmea	r0!, {r4-r7}
	mcr	p15, 0, r4, c1, c0, 2	@ CPACR
	mcr	p15, 0, r5, c2, c0, 0	@ TTBR0
	mcr	p15, 0, r6, c2, c0, 1	@ TTBR1
	mcr	p15, 0, r7, c2, c0, 2	@ TTBCR

	/* c3 and c10 registers */
	ldmea	r0!,{r4-r7}
	mcr	p15, 0, r4, c3, c0, 0	@ DACR
	mcr	p15, 0, r5, c10, c2, 0	@ PRRR
	mcr	p15, 0, r6, c10, c2, 1	@ NMRR
	mcr	p15, 0, r7, c1, c0, 1	@ ACTLR

	/* c12, c13 and CPSR registers */
	ldmea	r0!,{r4-r7}
	mcr	p15, 0, r4, c13, c0, 1	@ Context ID
	mcr	p15, 0, r5, c13, c0, 2	@ User r/w thread ID
	mrc	p15, 0, r6, c12, c0, 0	@ Secure or NS VBAR
	msr	cpsr, r7		@ store cpsr

	/*
	 * Enabling MMU here. Page entry needs to be altered
	 * to create temporary 1:1 map and then resore the entry
	 * ones MMU is enabled
	 */
	mrc	p15, 0, r7, c2, c0, 2	@ Read TTBRControl
	and	r7, #0x7		@ Extract N (0:2) to decide
	cmp	r7, #0x0		@ TTBR0/TTBR1
	beq	use_ttbr0
ttbr_error:
	b	ttbr_error		@ Only N = 0 supported
use_ttbr0:
	mrc	p15, 0, r2, c2, c0, 0	@ Read TTBR0
	ldr	r5, =TTRBIT_MASK
	and	r2, r5
	mov	r4, pc
	ldr	r5, =TABLE_INDEX_MASK
	and	r4, r5			@ r4 = 31 to 20 bits of pc
	ldr	r1, =TABLE_ENTRY
	add	r1, r1, r4		@ r1 has value of table entry
	lsr	r4, #18			@ Address of table entry
	add	r2, r4			@ r2 - location to be modified

	/* Storing previous entry of location being modified */
	ldr	r4, [r2]
	mov	r9, r4
	str	r1, [r2]

	/*
	 * Storing address of entry being modified
	 * It will be restored after enabling MMU
	 */
	mov 	r10, r2

	mov	r1, #0
	mcr	p15, 0, r1, c7, c5, 4	@ Flush prefetch buffer
	mcr	p15, 0, r1, c7, c5, 6	@ Invalidate BTB
	mcr	p15, 0, r1, c8, c5, 0	@ Invalidate ITLB
	mcr	p15, 0, r1, c8, c6, 0	@ Invalidate DTLB

	/*
	 * Restore control register  but don't enable Data caches here.
	 * Caches will be enabled after restoring MMU table entry.
	 */
	ldmea	r0!, {r4}
	mov r11, r4
	ldr	r2, =CACHE_DISABLE_MASK
	and	r4, r4, r2
	mcr	p15, 0, r4, c1, c0, 0
	isb
	dsb
	ldr	r1, =mmu_on_label
	bx	r1
mmu_on_label:
	mov 	r8, lr
	/* Set up the per-CPU stacks */
	bl	cpu_init

#ifdef CONFIG_CACHE_L2X0
	ldr r2, =L2_BASE_ADDR
	add r2, r2, #PERIPBASE_VIRT

	ldmea	r0!, {r4-r7}
	/* L2 will be enabled after L1 is enabled */
	mov r4, #0x0
	str	r4, [r2, #L2X0_CTRL]
	str	r5, [r2, #L2X0_AUX_CTRL]
	str	r6, [r2, #L2X0_TAG_LATENCY_CTRL]
	str	r7, [r2, #L2X0_DATA_LATENCY_CTRL]

	ldmea	r0!, {r4-r5}
	str	r4, [r2, #L2X0_PREFETCH_CTRL]
	str	r5, [r2, #L2X0_POWER_CTRL]
#endif
	/*
	 * Restore the MMU table entry that was modified for
	 * enabling MMU.
	 */
	ldr	r4, =PAGE_OFFSET
	ldr	r5, =MX6_PHYS_OFFSET
	sub	r4, r4, r5
	add	r4, r4, r10
	str	r9, [r4]

	mov	r0, #0
	mcr	p15, 0, r0, c7, c1, 6	@ flush TLB and issue barriers
	mcr	p15, 0, r0, c7, c5, 4	@ Flush prefetch buffer
	mcr	p15, 0, r0, c7, c5, 6	@ Invalidate BTB
	mcr	p15, 0, r0, c8, c5, 0	@ Invalidate ITLB
	mcr	p15, 0, r0, c8, c6, 0	@ Invalidate DTLB
	dsb
	isb

/******************************************************************
invalidate l1 dcache, r0-r4, r6, r7 used
******************************************************************/
	mov     r0, #0
	mcr     p15, 2, r0, c0, c0, 0
	mrc     p15, 1, r0, c0, c0, 0

	ldr     r1, =0x7fff
	and     r2, r1, r0, lsr #13

	ldr     r1, =0x3ff

	and     r3, r1, r0, lsr #3	@ NumWays - 1
	add     r2, r2, #1		@ NumSets

	and     r0, r0, #0x7
	add     r0, r0, #4		@ SetShift

	clz     r1, r3			@ WayShift
	add     r4, r3, #1		@ NumWays
1:
	sub     r2, r2, #1		@ NumSets--
	mov     r3, r4			@ Temp = NumWays
2:
	subs    r3, r3, #1		@ Temp--
	mov     r7, r3, lsl r1
	mov     r6, r2, lsl r0
	orr     r7, r7, r6
	mcr     p15, 0, r7, c7, c6, 2
	bgt     2b
	cmp     r2, #0
	bgt     1b
	dsb
	isb

/************************************************************
restore control register to enable cache
************************************************************/
	mov	r0, r11
	mcr	p15, 0, r0, c1, c0, 0	@ with caches enabled.
	dsb
	isb

#ifdef CONFIG_CACHE_L2X0
	/* Enable L2 cache here */
	ldr r2, =L2_BASE_ADDR
	add r2, r2, #PERIPBASE_VIRT
	mov r4, #0x1
	str	r4, [r2, #L2X0_CTRL]
#endif
/***********************************************************
return back to mx6_suspend_enter for dormant
***********************************************************/
	mov	lr, r8
	ldmfd	sp!, {r0-r12}
	mov	pc, lr
/************************************************
return back to mx6_suspend_enter for suspend
*************************************************/
out:
	ldmfd	sp!, {r0-r12}
	mov	pc, lr

	.equ	va2pa_offset, (PAGE_OFFSET - MX6_PHYS_OFFSET)
	.type	mx6q_do_suspend, #object
ENTRY(mx6q_do_suspend)
	.word	mx6q_suspend
	.size	mx6q_suspend, . - mx6q_suspend
