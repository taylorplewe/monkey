# pre-compile with dundalk
.\dundalk-nesasm-precompiler.exe src\main.s src\compiled\main-dlk.s

# compile from source to NES binary
.\NESASM3.exe src\compiled\main-dlk.s | tee-object -v buildOutput
move-item src\compiled\main-dlk.nes bin\monkey.nes -force
move-item src\compiled\main-dlk.fns bin\monkey.fns -force

# Uh-oh... we got a "problem"
if ($buildOutput.Count -ne 4) {
	return
}

# trim dat header for real NES hardware
# ..\trim-nes-header.exe bin\monkey.nes bin\monkey.nes.raw -b

# run game (default program is Mesen)
.\bin\monkey.nes