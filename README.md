# Wishbone connected HyperRAM memory driver

This is an implementation of a HyperRAM memory driver connected via Wishbone bus to internal picorv32 core, to be implemented inside the Caravel SoC, built on Google's SKY130 Shuttle as part of the Zero To ASIC course (https://www.zerotoasiccourse.com/).

Currently implemented:
- working with wb_clk_i clock (external HyperRAM clock is two times smaller due to DDR)
- read and write to both memory and register space (inside HyperRAM chip)
- single 32 bit access to memory space (no burst)
- single 16 bit access to register space (inside HyperRAM chip)
- adjusting timings (tacc, tcsh, tpre, tpost and read timeout) via registers also accessible via Wishbone
- fixed latency (1x/2x) or variable latency (according to RWDS signal state during CA phase) - configurable in register
- read timeout in case of external HyperRAM connection failure

TODO:
- add burst transfers
- move HyperRAM memory driver into user_clock2 domain with necessary clock crossing logic

# License

This project is [licensed under Apache 2](LICENSE)
