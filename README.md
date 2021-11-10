# Wishbone connected HyperRAM memory driver

This is a wrapped implementation of a HyperRAM memory driver connected via Wishbone bus to internal picorv32 core, to be implemented inside the Caravel SoC, built on Google's SKY130 Shuttle as part of the Zero To ASIC course (https://www.zerotoasiccourse.com/).

Details and sources can be found in submodule repository: https://github.com/embelon/wb_hyperram

TODO:
- move HyperRAM memory driver into user_clock2 domain with necessary clock crossing logic

# License

This project is [licensed under Apache 2](LICENSE)
