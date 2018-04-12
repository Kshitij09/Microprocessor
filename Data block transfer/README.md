# Data block transfer
### Instructions to execute non-overlapping
nasm -felf64 nonoverlap.asm
ld -o nonoverlap nonoverlap.o
./nonoverlap
