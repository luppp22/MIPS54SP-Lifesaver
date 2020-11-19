.data
A:.space 240
B:.space 240
C:.space 240
D:.space 240
E:.space 240
.text
j main
exc:
nop
j exc

main:
addi $2,$0,0    #a[i]
addi $3,$0,1    #b[i]
addi $4,$0,0    #c[i]
addi $13,$0,0   #d[i]
addi $5,$0,4    #counter
addi $6,$0,0    #a[i-1]
addi $7,$0,1    #b[i-1]
addi $10,$0,0   #flag for i<20 || i<40
addi $11,$0,240 #sum counts
addi $14,$0,3
addi $30,$0,0

# 把 0 1 0 0 ($2,...,$13) 分别存入 A B C D
lui $27,0x0000
addu $27,$27,$0
sw $2,A($27)
lui $27,0x0000
addu $27,$27,$0
sw $3,B($27)
lui $27,0x0000
addu $27,$27,$0
sw $2,C($27)
lui $27,0x0000
addu $27,$27,$0
sw $3,D($27)

# 循环
loop:
## $5(4) 除以 4 (=i) 存入 $12
srl $12,$5,2
# $6 加 i. 自此, $6 就是 a[i] 而不是 a[i-1] 了
add $6,$6,$12
# 把 a[i] 的内容存入 A[i] 中
lui $27,0x0000
addu $27,$27,$5
sw $6,A($27)
# $14 (3) 乘以 $5/4 (i) ( = 3i )
mul $15,$14,$12
# 把 $7 (b[i-1]) 的内容加上 3i, 存入 B[i]. 自此, $7 就是 b[i] 而不是 b[i-1]
add $7,$7,$15
lui $27,0x0000
addu $27,$27,$5
sw $7,B($27)
# $5 是否小于 80 (i 是否小于 20)? 记入 $10
slti $10,$5,80
# 若不是, 跳转
bne $10,1,c1

# (0<=i<=19)
# 把 $6 的内容存入 C[i] 中 (c[i] = a[i])
lui $27,0x0000
addu $27,$27,$5
sw $6,C($27)
# 把 $7 的内容存入 D[i] 中 (d[i] = b[i])
lui $27,0x0000
addu $27,$27,$5
sw $7,D($27)
addi $15,$6,0 # $15 $16 分别赋值为 c[i] d[i]
addi $16,$7,0
j endc
c1: # (20<=i<=39)
# i 是否小于 40 ？ 若不是，跳转到 c2
slti $10,$5,160
addi $27,$0,1
bne $10,$27,c2
# C[i] = a[i] + b[i]
add $15,$6,$7
lui $27,0x0000
addu $27,$27,$5
sw $15,C($27)
# D[i] = a[i] * b[i]
mul $16, $15,$6
lui $27,0x0000
addu $27,$27,$5
sw $16,D($27)
j endc
c2: # (i>=40)
# C[i] = a[i] * b[i]
mul $15,$6,$7
lui $27,0x0000
addu $27,$27,$5
sw $15,C($27)
# D[i] = c[i] * b[i]
mul $16,$15,$7
lui $27,0x0000
addu $27,$27,$5
sw $16,D($27)

endc:
add $28,$15,$16 #$28 = c[i] + d[i]
lui $27,0x0000
addu $27,$27,$5
sw $28,E($27) # 将 c[i] + d[i] 存入 E[i]
addi $5,$5,4 # i = i + 1
bne $5,$11,loop # i = 60 不跳转
break
# 最后 E[i] = c[i] + d[i], 可通过验证 E[59] 的正确性来验证 c[i] 和 d[i] 正确性