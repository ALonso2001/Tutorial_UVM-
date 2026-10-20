// Scoreboard: compara lo observado contra el comportamiento esperado.
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  uvm_analysis_imp #(switch_item, scoreboard) m_analysis_imp;

  int unsigned n_pass;   // (añadido) contadores para el resumen final
  int unsigned n_fail;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  // OJO: la presentación declara "virtual function write(...)" sin tipo de
  // retorno (implícitamente devuelve 1 bit). Debe ser "function void".
  virtual function void write(switch_item item);
    if (item.addr inside {[0:'h3f]}) begin
      if (item.addr_a != item.addr | item.data_a != item.data) begin
        `uvm_error("SCBD", $sformatf("ERROR! Mismatch addr=0x%0h data=0x%0h addr_a=0x%0h data_a=0x%0h",
                   item.addr, item.data, item.addr_a, item.data_a))
        n_fail++;
      end else begin
        `uvm_info("SCBD", $sformatf("PASS! Match addr=0x%0h data=0x%0h addr_a=0x%0h data_a=0x%0h",
                  item.addr, item.data, item.addr_a, item.data_a), UVM_LOW)
        n_pass++;
      end
    end else begin
      if (item.addr_b != item.addr | item.data_b != item.data) begin
        `uvm_error("SCBD", $sformatf("ERROR! Mismatch addr=0x%0h data=0x%0h addr_b=0x%0h data_b=0x%0h",
                   item.addr, item.data, item.addr_b, item.data_b))
        n_fail++;
      end else begin
        `uvm_info("SCBD", $sformatf("PASS! Match addr=0x%0h data=0x%0h addr_b=0x%0h data_b=0x%0h",
                  item.addr, item.data, item.addr_b, item.data_b), UVM_LOW)
        n_pass++;
      end
    end
  endfunction

  // (añadido) Resumen al final de la simulación
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCBD", $sformatf("Resumen: %0d PASS, %0d FAIL", n_pass, n_fail), UVM_NONE)
  endfunction
endclass
