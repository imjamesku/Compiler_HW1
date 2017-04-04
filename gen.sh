#!bin/bash
#generate an executable from HW1.l
flex HW1.l
gcc lex.yy.c -o HW1 -lfl 



