# CPEN_311_RC4

This lab consists of six parts: ksa.vhd, lab4_core, fsm_write_memory, fsm_shuffle, fsm_decode and Capitalletter. Also, there are three memory sections including two RAMs and one ROM.

ksa.vhd is responsible for the overall control over the lab entity, including the core, LEDs and HEX

lab4_core includes all the interconnected finite state machines that calculate the decrypted information.

fsm_write_memory is responsible for filling the RAM s_memory with addresses in ascending order to prepare for decryption.

fsm_shuffle plays the role of shuffling the content in s_memory through a swapping algorithm.

The encrypted secret message is stored in the ROM.

fsm_decode performs an algorithm that decrypts the secret message with a secret key given. The decrypted message is then written into d_memory.

Finally, Capitalletter performs a brute force algorithm that cracks the secret key by testing all possible combinations and finally decrypts the secret message by driving the three finite state machines recursively.

The decryption process is assembled and coordinated through lab4_core.
