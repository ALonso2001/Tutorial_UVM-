# Makefile para VCS + UVM
# Uso: make            -> compila y simula
#      make SEED=7     -> otra semilla
#      make VERB=UVM_HIGH
#      make waves      -> genera archivo VCD

TEST  ?= test
VERB  ?= UVM_LOW
SEED  ?= 1
UVM   ?= uvm-1.2

VCS_OPTS = -full64 -sverilog -ntb_opts $(UVM) -timescale=1ns/1ps \
           -debug_access+all -f files.f -l comp.log
SIM_OPTS = +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) \
           +ntb_random_seed=$(SEED) -l sim.log

all: comp sim

comp:
	vcs $(VCS_OPTS)

sim:
	./simv $(SIM_OPTS)

waves:
	./simv $(SIM_OPTS) +VCD

clean:
	rm -rf simv simv.daidir csrc *.log *.vcd ucli.key vc_hdrs.h \
	       DVEfiles verdiLog novas.* *.fsdb AN.DB

.PHONY: all comp sim waves clean
