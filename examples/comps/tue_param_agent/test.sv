package sample_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;

  `include "uvm_macros.svh"
  `include "tue_macros.svh"

  class sample_configuration extends tue_configuration;
    `tue_object_default_constructor(sample_configuration)
    `uvm_object_utils(sample_configuration)
  endclass

  class sample_status extends tue_status;
    `tue_object_default_constructor(sample_status)
    `uvm_object_utils(sample_status)
  endclass

  class sample_item extends tue_sequence_item #(sample_configuration, sample_status);
    `tue_object_default_constructor(sample_item)
    `uvm_object_utils(sample_item)
  endclass

  class sample_monitor extends tue_param_monitor #(sample_configuration, sample_status, sample_item);
    `tue_component_default_constructor(sample_monitor)
    `uvm_component_utils(sample_monitor)
  endclass

  typedef tue_sequencer #(sample_configuration, sample_status, sample_item) sample_sequencer;

  class sample_driver extends tue_driver #(sample_configuration, sample_status, sample_item);
    `tue_component_default_constructor(sample_driver)
    `uvm_component_utils(sample_driver)
  endclass

  class sample_active_agent extends tue_param_agent #(
    sample_configuration, sample_status, sample_item, sample_monitor, sample_sequencer, sample_driver
  );
    `tue_component_default_constructor(sample_active_agent)
    `uvm_component_utils(sample_active_agent)
  endclass

  class sample_passive_agent extends tue_param_agent #(
    sample_configuration, sample_status, sample_item, sample_monitor
  );
    `tue_component_default_constructor(sample_passive_agent)
    `uvm_component_utils(sample_passive_agent)
  endclass

  class sample_test extends uvm_test;
    sample_configuration  configuration;
    sample_status         status;
    sample_active_agent   active_agent_0;
    sample_active_agent   active_agent_1;
    sample_passive_agent  passive_agent;

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      configuration = new();
      status        = new();

      active_agent_0  = sample_active_agent::type_id::create("active_agent_0", this);
      active_agent_0.set_context(configuration, status);

      active_agent_1  = sample_active_agent::type_id::create("active_agent_1", this);
      active_agent_1.passive_agent();
      active_agent_1.set_context(configuration, status);

      passive_agent = sample_passive_agent::type_id::create("passive_agent", this);
      passive_agent.set_context(configuration, status);
    endfunction

    function void report_phase(uvm_phase phase);
      uvm_analysis_port #(sample_item)  analysis_port;
      sample_monitor                    monitor;
      sample_sequencer                  sequencer;
      sample_driver                     driver;
      if (!(
        $cast(analysis_port, active_agent_0.analysis_port) &&
        $cast(monitor, active_agent_0.get_child("monitor")) &&
        $cast(sequencer, active_agent_0.sequencer) &&
        $cast(driver, active_agent_0.get_child("driver"))
      )) begin
        `uvm_error(get_name(), "Error!")
      end
      if (!(
        $cast(analysis_port, active_agent_1.analysis_port) &&
        $cast(monitor, active_agent_1.get_child("monitor")) &&
        (!active_agent_1.has_child("sequencer")) &&
        (!active_agent_1.has_child("driver"   ))
      )) begin
        `uvm_error(get_name(), "Error!")
      end
      if (!(
        $cast(analysis_port, passive_agent.analysis_port) &&
        $cast(monitor, passive_agent.get_child("monitor")) &&
        (!passive_agent.has_child("sequencer")) &&
        (!passive_agent.has_child("driver"   ))
      )) begin
        `uvm_error(get_name(), "Error!")
      end
    endfunction

    `tue_component_default_constructor(sample_test)
    `uvm_component_utils(sample_test)
  endclass
endpackage

module top();
  import uvm_pkg::*;
  import sample_pkg::*;

  initial begin
    run_test("sample_test");
  end
endmodule