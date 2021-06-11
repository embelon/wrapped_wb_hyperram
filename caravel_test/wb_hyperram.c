/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include "verilog/dv/caravel/defs.h"
#include "verilog/dv/caravel/stub.c"

// Caravel allows user project to use 0x30xx_xxxx address space on Wishbone bus
// HyperRAM has 8MB -> mask is 0x007fffff
// 0x3000_0000 till 307f_ffff -> RAM / MEM inisde chip
#define hyperram_mem_base_address	0x30000000
#define hyperram_mem_mask			0x007fffff
#define hyperram_mem(offset)		(*(volatile uint32_t*)(hyperram_mem_base_address + (offset & hyperram_mem_mask)))
// 0x3080_00xx -> register space inside chip
#define hyperram_reg_base_address	0x30800000
#define hyperram_reg_mask			0x003fffff
#define hyperram_reg(num)			(*(volatile uint32_t*)(hyperram_reg_base_address + ((2 * num) & hyperram_reg_mask)))
// 0x30c0_00xx -> CSR space for driver / peripheral configuration
#define hyperram_csr_base_address	0x30c00000
#define hyperram_csr_mask			0x003fffff
#define hyperram_csr_latency		(*(volatile uint32_t*)(hyperram_csr_base_address + 0x00))
#define hyperram_csr_tpre_tpost		(*(volatile uint32_t*)(hyperram_csr_base_address + 0x04))
#define hyperram_csr_tcsh			(*(volatile uint32_t*)(hyperram_csr_base_address + 0x08))
#define hyperram_csr_trmax			(*(volatile uint32_t*)(hyperram_csr_base_address + 0x0c))
#define hyperram_csr_status			(*(volatile uint32_t*)(hyperram_csr_base_address + 0x10))

void main()
{
	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |

	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |

	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

	// Configure lower 8-IOs as user output
	// Observe counter value in the testbench
	reg_mprj_io_7 =  GPIO_MODE_USER_STD_INPUT_NOPULL;

	reg_mprj_io_8 =  GPIO_MODE_USER_STD_OUTPUT;			// rstn
	reg_mprj_io_9 =  GPIO_MODE_USER_STD_OUTPUT;			// csn
	reg_mprj_io_10 =  GPIO_MODE_USER_STD_OUTPUT;		// clk
	reg_mprj_io_11 =  GPIO_MODE_USER_STD_OUTPUT;		// clkn
	reg_mprj_io_12 =  GPIO_MODE_USER_STD_OUTPUT;		// rwds
	reg_mprj_io_13 =  GPIO_MODE_USER_STD_OUTPUT;		// dq0
	reg_mprj_io_14 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_15 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_16 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_17 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_18 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_19 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_20 =  GPIO_MODE_USER_STD_OUTPUT;		// dq7

	/* Apply configuration */
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);

	// activate the project #11
	reg_la1_iena = 0; // input enable off
	reg_la1_oenb = 0; // output enable on
	reg_la1_data = 1 << 11;
    
	// reset IP
	reg_la0_oenb = 0;
	reg_la0_iena = 0;
	reg_la0_data = 1;
	reg_la0_data = 0;

	// write register space inside hyperram
	hyperram_reg(0x2) = 0xa573;

	// write memory, low addresses, default tacc (latency) is 6 cycles (default)
	hyperram_mem(0x320) = 0xfecdba89;
	hyperram_mem(0x1234) = 0x13579246;

	// write latency csr
	// fixed & double latency
	// tacc = 4 cycles
	hyperram_csr_latency = 0x34;
	// read latency csr
	volatile uint32_t read = hyperram_csr_latency;
	// if write unsucessful, loop until timeout
	while (read != 0x34);

	// write memory, high addresses, tacc should be now 4 cycles
	hyperram_mem(0x123450) = 0x12874562;
	hyperram_mem(0x7ffff4) = 0x77f77f77;

	// try to read memory and trigger timeout - there's no chip connected
	read = hyperram_mem(0x135);

	// wait for timeout on read from hyperram
	while (hyperram_csr_status != 1);
}

