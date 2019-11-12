rm dump*.bin 2>/dev/null	
python scripts/generate.py >generated/rpl.inc
python scripts/makeprogram.py
64tass -q -c main.asm -o rpl.prg -L rpl.lst
if [ $? -eq 0 ]; then
	time ../../x16-emulator/x16emu -prg rpl.prg -run -scale 2 -debug -keymap en-gb 
fi

