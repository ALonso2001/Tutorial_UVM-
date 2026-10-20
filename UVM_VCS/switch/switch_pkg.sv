// Paquete: reúne todas las clases del testbench en un solo espacio de nombres.
package switch_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "switch_item.sv"
  `include "gen_item_seq.sv"
  `include "driver.sv"
  `include "monitor.sv"
  `include "agent.sv"
  `include "scoreboard.sv"
  `include "env.sv"
  `include "test.sv"
endpackage
