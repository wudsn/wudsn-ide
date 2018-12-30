######################################################################
# General-purpose makefile for compiling Atari 2600 projects.        #
# This should work for most projects without any changes.            #
# Default output is $(CURDIR).bin.  Override PROGRAM to change this. #  
######################################################################
 
PROGRAM := $(shell basename $(CURDIR)).bin
SOURCES := .
INCLUDES :=
LIBS :=
OBJDIR := obj
DEBUGDIR := $(OBJDIR)
 
LINKCFG := atari2600.cfg
ASFLAGS :=
LDFLAGS	= -C$(LINKCFG) \
          -m $(DEBUGDIR)/$(notdir $(basename $@)).map \
          -Ln $(DEBUGDIR)/$(notdir $(basename $@)).labels -vm
 
EMULATORFLAGS := -format pal -ystart 44
 
################################################################################
 
CC 	      := cc65 
LD            := ld65
AS	      := ca65
AR	      := ar65
EMULATOR      := stella
 
MKDIR         := mkdir
RM            := rm -f
RMDIR         := rm -rf
 
################################################################################
 
ofiles :=
sfiles := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))
extra_includes := $(foreach i, $(INCLUDES), -I $i)
 
define depend
  my_obj := $$(addprefix $$(OBJDIR)/, $$(addsuffix .o, $$(notdir $$(basename $(1)))))
  ofiles += $$(my_obj)
 
  $$(my_obj):  $(1)
	$$(AS) -g -o $$@ $$(ASFLAGS) $(extra_includes) $$<
endef
 
################################################################################
 
.SUFFIXES:
.PHONY: all clean run rundebug
all: $(PROGRAM)
 
$(foreach file,$(sfiles),$(eval $(call depend,$(file))))
 
$(OBJDIR):
	[ -d $@ ] || mkdir -p $@
 
$(PROGRAM): $(OBJDIR) $(ofiles)
	$(LD)  $(LDFLAGS) $(ofiles) $(LIBS) -o $@ 
 
run: $(PROGRAM)
	$(EMULATOR) $(EMULATORFLAGS) $(PROGRAM)
 
rundebug: $(PROGRAM)
	$(EMULATOR) -debug $(EMULATORFLAGS) $(PROGRAM)
 
clean:
	$(RM) $(ofiles) $(PROGRAM)
	$(RMDIR) $(OBJDIR)

