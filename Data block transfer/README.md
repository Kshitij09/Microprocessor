# Data block transfer
### Instructions to execute non-overlapping block transfer
nasm -felf64 nonoverlap.asm
<br>
ld -o nonoverlap nonoverlap.o
<br>
./nonoverlap


### Instructions to execute overlapping block transfer
nasm -felf64 overlap.asm
<br>
ld -o overlap overlap.o
<br>
./overlap

![](screenshots/block_1.png)
![](screenshots/block_2.png)
