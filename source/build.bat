@echo off
del /Q dump*.bin 
python scripts\generate.py >generated\rpl.inc
python scripts\assembler.py >generated\assembler.inc
python scripts\makeprogram.py
64tass -q -c main.asm -o rpl.prg -L rpl.lst
..\..\x16-emulator\x16emu -prg rpl.prg -run -scale 2 -debug -keymap en-gb 

