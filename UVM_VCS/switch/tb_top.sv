// Módulo superior: reloj, interfaz, DUT y arranque de UVM.
`include "uvm_macros.svh"

module tb_top;
  import uvm_pkg::*;
  import switch_pkg::*;

  bit clk;
  always #10 clk = ~clk;          // periodo de 20 ns

  switch_if _if (clk);

  switch u0 ( .clk    (clk),
              .rstn   (_if.rstn),
              .vld    (_if.vld),
              .addr   (_if.addr),
              .data   (_if.data),
              .addr_a (_if.addr_a),
              .data_a (_if.data_a),
              .addr_b (_if.addr_b),
              .data_b (_if.data_b));

  initial begin
    // Publica la interfaz para el test (instancia "uvm_test_top")
    uvm_config_db#(virtual switch_if)::set(null, "uvm_test_top", "switch_vif", _if);
    run_test("test");
  end

  // Formas de onda opcionales: ./simv ... +VCD
  initial begin
    if ($test$plusargs("VCD")) begin
      $dumpfile("switch.vcd");
      $dumpvars(0, tb_top);
    end
  end
endmodule
