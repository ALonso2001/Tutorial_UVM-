// Secuencia: genera 'num' transacciones aleatorias de tipo switch_item.
// Nota: en la presentación se escribe "extends uvm_sequence;" (sin parámetro).
// Parametrizarla con #(switch_item) es la práctica recomendada: así REQ/RSP
// quedan tipados correctamente.
class gen_item_seq extends uvm_sequence #(switch_item);
  `uvm_object_utils(gen_item_seq)
  function new(string name="gen_item_seq");
    super.new(name);
  endfunction

  rand int num;     // Config total number of items to be sent

  constraint c1 { num inside {[2:5]}; }

  virtual task body();
    for (int i = 0; i < num; i ++) begin
      switch_item m_item = switch_item::type_id::create("m_item");
      start_item(m_item);
      if (!m_item.randomize())
        `uvm_error("SEQ", "Fallo al aleatorizar m_item")
      `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
      m_item.print();
      finish_item(m_item);
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass
