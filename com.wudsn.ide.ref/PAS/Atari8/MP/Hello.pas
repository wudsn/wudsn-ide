Program Hello;

// Comment
var SDLSTL: word absolute $230;
var COLPF2: byte absolute $d018;
var COLBK: byte absolute $d01a;
var NMIEN: byte absolute $d40e;

Procedure MeinDLI; assembler; interrupt;
asm
{	pha

	lda #$38
	sta wsync
	sta COLPF2

	pla
};
end;


Procedure HiThere;
Begin
  Writeln('Hello World');
End;


var dl_ptr: ^byte;
Begin
  HiThere;
  SetIntVec(iDLI, @MeinDLI);
  
  dl_ptr:=Pointer(SDLSTL+10);
  
  dl_ptr^:=dl_ptr^ or $80;
  NMIEN:=$c0;
 
  repeat
     COLBK:=14;
     COLBK:=0;
  until false;

End.
