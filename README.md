# monkey
NES port of the [Wall Kickers mobile game](http://wallkickers.com/)

---

Syntax of the code is in 6502 assembly for use with the NESASM3 compiler, but with some minor additions I've added via a pre-compiler I wrote called dundalk:

- `class <name>` ; all `var`s, `const`s and labels will be unique to this class and can be invoked elsewhere in the codebase with dot notation:
```
class monkey

var [1] x
Spin:
  ...
  rts
```
```
class obj

var [1] x
```
```
lda obj.x
sta monkey.x
jsr monkey.Spin
```
- `var [#] <name>` ; # = number of bytes to allocate to this label, `<name>` = name of label.  dundalk will allocate a spot in zeropage RAM for this label with # bytes.
- `const <name> <value>` ; dundalk will replace all occurences of `<name>` across codebase with `<value>`.
- `idset <name> { }` ; dundalk will replace each occurence of every label inside the `idset` across the codebase with its index inside the `idset`. e.g. with the following idset:
```
idset STATE {
	IDLE
	JUMP
	BFLIP
}
```
and then invoking `STATE.BFLIP` would make dundalk replace it with `2`.
- using `var`s and `const`s underneath a global label e.g. `TurnAround:` will cause those vars and consts to be local to this label, and can be invoked by dot notation:
```
class monkey

DoSomething:
  ...
  lda #$ea
  sta TurnAround.newX
  jsr TurnAround
  ...
  rts

TurnAround:
  var [1] newX
  ...
  rts
```
in another file:
```
lda #$ea
sta monkey.TurnAround.newX
jsr monkey.TurnAround
```
- `>` ; dundalk will create a unique local label for this and the next occurence of `>`; useful for branching over a only few instructions frequently

---

Acquiring a binary for NESASM3 is not simple so I've just included one in the repo.  To build you should just be able to run `build-and-run-game.ps1` in PowerShell.  It assumes you have an emulator set as the default program for .nes files.
