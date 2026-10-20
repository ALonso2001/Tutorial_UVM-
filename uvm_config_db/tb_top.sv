module tb_top;
  import uvm_pkg::*;
  import lab_pkg::*;

  logic clk = 0;
  always #5 clk = ~clk;

  simple_if sif (clk);

  initial begin
    // TODO 3: publica 'sif' con el nombre "vif" para todo lo que cuelgue del test
    uvm_config_db #(virtual simple_if)::set(null, "uvm_test_top.*", "vif", sif);
    run_test("base_test");
  end
endmodule
