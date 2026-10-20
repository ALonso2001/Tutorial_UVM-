package lab_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class simple_item extends uvm_sequence_item;
    rand bit [7:0] data;
    `uvm_object_utils_begin(simple_item)
      `uvm_field_int(data, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name = "simple_item"); super.new(name); endfunction
  endclass

  class simple_driver extends uvm_driver #(simple_item);
    `uvm_component_utils(simple_driver)
    virtual simple_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // TODO 1: recupera "vif" con uvm_config_db y lanza `uvm_fatal si falla
      if (!uvm_config_db #(virtual simple_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", {"Falta 'vif' para ", get_full_name()})  
      
    endfunction

    task run_phase(uvm_phase phase);
      vif.valid <= 0;
      forever begin
        seq_item_port.get_next_item(req);
        @(posedge vif.clk);
        vif.valid <= 1; vif.data <= req.data;
        @(posedge vif.clk);
        vif.valid <= 0;
        seq_item_port.item_done();
      end
    endtask
  endclass

  class simple_monitor extends uvm_monitor;
    `uvm_component_utils(simple_monitor)
    virtual simple_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // TODO 2: recupera "vif" igual que en el driver

        if (!uvm_config_db #(virtual simple_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", {"Falta 'vif' para ", get_full_name()})

    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        @(posedge vif.clk);
        if (vif.valid) `uvm_info("MON", $sformatf("data = 0x%02h", vif.data), UVM_MEDIUM)
      end
    endtask
  endclass

  typedef uvm_sequencer #(simple_item) simple_sequencer;

  class simple_agent extends uvm_agent;
    `uvm_component_utils(simple_agent)
    simple_driver    drv;
    simple_monitor   mon;
    simple_sequencer sqr;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = simple_monitor::type_id::create("mon", this);
      drv = simple_driver::type_id::create("drv", this);
      sqr = simple_sequencer::type_id::create("sqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class simple_env extends uvm_env;
    `uvm_component_utils(simple_env)
    simple_agent agt;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      agt = simple_agent::type_id::create("agt", this);
    endfunction
  endclass

  class simple_seq extends uvm_sequence #(simple_item);
    `uvm_object_utils(simple_seq)
    int unsigned n_items = 5;
    function new(string name = "simple_seq"); super.new(name); endfunction
    task body();
      repeat (n_items) begin
        req = simple_item::type_id::create("req");
        start_item(req);
        if (!req.randomize()) `uvm_error("RAND", "randomize falló")
        finish_item(req);
      end
    endtask
  endclass

  class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    simple_env env;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      env = simple_env::type_id::create("env", this);
    endfunction
    function void end_of_elaboration_phase(uvm_phase phase);
      uvm_top.print_topology();
    endfunction
    task run_phase(uvm_phase phase);
      simple_seq seq = simple_seq::type_id::create("seq");
      phase.raise_objection(this);
      seq.start(env.agt.sqr);
      phase.drop_objection(this);
    endtask
  endclass
endpackage