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

  class simple_agent_cfg extends uvm_object;
  `uvm_object_utils(simple_agent_cfg)
  uvm_active_passive_enum is_active   = UVM_ACTIVE;
  virtual simple_if       vif;
  int unsigned            idle_cycles = 0;   // ciclos entre transacciones
  bit                     has_checks  = 1;
  function new(string name = "simple_agent_cfg"); super.new(name); endfunction
endclass




  class simple_driver extends uvm_driver #(simple_item);
    `uvm_component_utils(simple_driver)
    virtual simple_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    simple_agent_cfg cfg;

    function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // TODO 6: recupera "cfg" y asigna vif = cfg.vif
    endfunction

// En run_phase, tras item_done():
repeat (cfg.idle_cycles) @(posedge vif.clk);

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

    simple_agent_cfg cfg;

    function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // TODO 6: recupera "cfg" y asigna vif = cfg.vif
    endfunction

// En run_phase, tras item_done():
repeat (cfg.idle_cycles) @(posedge vif.clk);

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
  simple_agent_cfg cfg;
  simple_driver    drv;
  simple_monitor   mon;
  simple_sequencer sqr;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // TODO 4: recupera "cfg" (tipo simple_agent_cfg); `uvm_fatal si falta
    // TODO 5: reenvía cfg a todos los hijos del agente con un set
    mon = simple_monitor::type_id::create("mon", this);
    if (cfg.is_active == UVM_ACTIVE) begin
      drv = simple_driver::type_id::create("drv", this);
      sqr = simple_sequencer::type_id::create("sqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    if (cfg.is_active == UVM_ACTIVE)
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
  simple_env       env;
  simple_agent_cfg cfg;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  virtual function void configure(); // los tests hijos la sobrescriben
    cfg.idle_cycles = 2;
  endfunction

  function void build_phase(uvm_phase phase);
    cfg = simple_agent_cfg::type_id::create("cfg");
    // TODO 7: recupera "vif" publicada por tb_top y guárdala en cfg.vif
    configure();
    // TODO 8: publica cfg para el agente "env.agt"
    env = simple_env::type_id::create("env", this);
  endfunction
  // end_of_elaboration_phase y run_phase como en la Práctica 1,
  // pero lanzando la secuencia solo si cfg.is_active == UVM_ACTIVE
endclass

class passive_test extends base_test;
  `uvm_component_utils(passive_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void configure();
    cfg.is_active = UVM_PASSIVE;
  endfunction
endclass
endpackage