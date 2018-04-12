# Data block transfer
### Instructions to execute non-overlapping block transfer
nasm -felf64 nonoverlap.asm
<br>
ld -o nonoverlap nonoverlap.o
<br>
./nonoverlap
