.intel_syntax noprefix
.global _start
_start:

mov rbp, rsp

#Socket Syscall, Code - 41, 1st arg - 2 (AF_INET IP$)
# 2nd arg - 1 (Socket stream for TCP), 3d arg is 0 (To choose itself)
xor edx, edx
mov rax, 41
mov rdi, 2
mov rsi, 1
syscall

#Bind takes 3 arg (fd, add port type, size)
mov rdi, rax   #rax from socket returns a fd, -> 1st arg
push 0	       # last 8 byte of 2nd arg is zero
mov rax, 0x0000000050000002 # first 8 byte of 2nd arg is ip, port, type
push rax	
mov rsi, rsp	#assaining the second arg
mov rdx, 16	# 3rd arg is size of the 2nd arg, 16 bytes
mov rax, 49	# syscall for bind which write config to socket
syscall

#Listen takes 2 args ( fd, backlog)
xor esi, esi	# 2nd arg to 0 
mov rax, 50	# syscall for Listen
syscall

mov r10, rdi

parent:
mov rsp, rbp
#accept takes 3 arg (fd, addr, addrlen)
xor edx, edx	#0ing 3rd arg
mov rdi, r10
xor esi, esi
mov rax, 43	#syscall for accept
syscall

mov r12, rax
mov rax, 57  # fork the fid's 
syscall

cmp rax, 0
je child


mov rdi, r12
mov rax, 3
syscall
jmp parent


child:

#closing the binded fd not the clint connection keep in mind
mov rax, 3
mov rdi, r10
syscall


#Read into memory from the network buffer
mov rdi, r12	#accept get fd in recipt of connection
mov rsi, rsp	#location to write in ram
mov rdx, 512	#max size it able to write
xor eax, eax	# 0 is syscall for read
syscall

mov rax, 1
mov rdi, 1
syscall
mov rdi, r12

cmp dword ptr[rsp], 0x20544547
jne postcheck
add rsp, 4
mov r10, 0 # seting r10 for future comparision
mov rsi, 0 #read only while open the file
jmp openfile

postcheck:
cmp dword ptr[rsp], 0x54534f50
je postreq

postreq:
add rsp, 5
mov r10, 1
mov rsi, 65 #write only =1 + create = 64 total 65 while open the file
mov rdx, 0777 #file permission while creating 

openfile:
mov r9, rdi # Save fd for future
mov rax, 2 # Open syscall
mov r8, 0 #set the couunter
loop:
cmp byte ptr [rsp + r8], 0x20
je end
inc r8
jmp loop
end:
mov byte ptr [rsp + r8], 0x00 #inserting null poiter after file name
mov rdi, rsp
syscall # which returns fd in rax

cmp r10, 0
jne postwrite


#Read the open file to memory
sub rsp, 512 # having space to read in memory
mov rdi, rax  # seting fd
mov rsi, rsp # place to write
mov rdx, 512 # max read space
xor eax, eax # read syscall
syscall
mov r8, rax # reading file return no. of byte in rax
jmp close_file

postwrite:
#writing to the file in the post request which is already open
mov rdi, rax
add rsp, r8
add rsp, 155
mov r8, 0
mov rdx, 0
loop2:
cmp dword ptr [rsp+r8], 0x0a0d0a0d
je end2
movzx rax, byte ptr[rsp+r8]
sub rax, 0x30
imul rdx, 10
add rdx, rax
inc r8
jmp loop2
end2:
add rsp, r8
add rsp, 4
mov rsi, rsp
mov rax, 1
syscall

close_file:
#close th file
mov rax, 3
syscall # closing the fd of last open file

# Write to memory buf to send throut em wave
mov rax, 0x00000000000a0d0a # http header responce
push rax
mov rax, 0x0d4b4f2030303220
push rax
mov rax, 0x302e312f50545448
push rax
mov rsi, rsp
mov rdx, 19
mov rdi, r9
mov rax, 1
syscall

cmp r10, 0
jne fd_close

# Write the next add in memory 
add rsp, 24
mov rsi, rsp
mov rdx, r8
mov rax, 1
mov rdi, r9
syscall

fd_close:
# Syscall to close a connection take one arg (fd)
mov rax, 3 
mov rdi, r9# Here rdi points to fd clinet memory buffer 
syscall
mov rsp, rbp


mov rdi, 0x00 #exit the programm 1 arg (exit code)
mov rax, 60  #syscall to exit
syscall

