//------------------------------------------------------------------------------
//  Copyright 2020 Taichi Ishitani
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//------------------------------------------------------------------------------
`ifndef TUE_REG_CBS_SVH
`define TUE_REG_CBS_SVH
class tue_reg_cbs_base extends uvm_reg_cbs;
  protected function bit m_is_reg_cb_registed(uvm_reg rg);
    uvm_reg_cb_iter cbs;

    cbs = new(rg);
    void'(cbs.first());
    while (cbs.get_cb() != null) begin
      if (cbs.get_cb() == this) begin
        return 1;
      end
      else begin
        void'(cbs.next());
      end
    end

    return 0;
  endfunction

  protected function bit m_is_field_cb_registered(uvm_reg_field field);
    uvm_reg_field_cb_iter cbs;

    cbs = new(field);
    void'(cbs.first());
    while (cbs.get_cb() != null) begin
      if (cbs.get_cb() == this) begin
        return 1;
      end
      else begin
        void'(cbs.next());
      end
    end

    return 0;
  endfunction

  protected function void m_add(uvm_reg rg);
    if (!m_is_reg_cb_registed(rg)) begin
      uvm_reg_cb::add(rg, this);
    end

    begin
      uvm_reg_field fields[$];
      rg.get_fields(fields);
      foreach (fields[i]) begin
        if (!m_is_field_cb_registered(fields[i])) begin
          uvm_reg_field_cb::add(fields[i], this);
        end
      end
    end
  endfunction

  protected function void m_remove(uvm_reg rg);;
    if (m_is_reg_cb_registed(rg)) begin
      uvm_reg_cb::delete(rg, this);
    end

    begin
      uvm_reg_field fields[$];
      rg.get_fields(fields);
      foreach (fields[i]) begin
        if (m_is_field_cb_registered(fields[i])) begin
          uvm_reg_field_cb::delete(fields[i], this);
        end
      end
    end
  endfunction

  `tue_object_default_constructor(tue_reg_cbs_base)
endclass

class tue_reg_read_only_cbs #(
  uvm_severity  SEVERITY  = UVM_ERROR
) extends tue_reg_cbs_base;
  typedef tue_reg_read_only_cbs #(SEVERITY) this_type;

  virtual task pre_write(uvm_reg_item rw);
    string  name;
    string  message;

    if (rw.status != UVM_IS_OK) begin
      return;
    end

    if (rw.element_kind == UVM_FIELD) begin
      uvm_reg_field field;
      uvm_reg       rg;
      $cast(field, rw.element);
      rg    = field.get_parent();
      name  = rg.get_full_name();
    end
    else begin
      name  = rw.element.get_full_name();
    end

    $sformat(message, "%s is read-only. Cannot call write() method.", name);
    if (SEVERITY == UVM_WARNING) begin
      `uvm_warning("UVM/REG/READONLY", message)
    end
    else begin
      `uvm_error("UVM/REG/READONLY", message);
    end
  endtask

  local static  this_type m_me;

  local static function this_type get();
    if (m_me == null) begin
      m_me  = new;
    end
    return m_me;
  endfunction

  static function void add(uvm_reg rg);
    this_type cb  = get();
    cb.m_add(rg);
  endfunction

  static function void remove(uvm_reg rg);
    this_type cb  = get();
    cb.m_remove(rg);
  endfunction

  `tue_object_default_constructor(tue_reg_read_only_cbs)
  `uvm_object_param_utils(tue_reg_read_only_cbs #(SEVERITY))
endclass

typedef tue_reg_read_only_cbs #(UVM_WARNING)  tue_reg_read_only_warning_cbs;
typedef tue_reg_read_only_cbs #(UVM_ERROR)    tue_reg_read_only_error_cbs;

class tue_reg_write_only_cbs #(
  uvm_severity  SEVERITY  = UVM_ERROR
) extends tue_reg_cbs_base;
  typedef tue_reg_write_only_cbs #(SEVERITY)  this_type;

  virtual task pre_read(uvm_reg_item rw);
    string  name;
    string  message;

    if (rw.status != UVM_IS_OK) begin
      return;
    end

    if (rw.element_kind == UVM_FIELD) begin
      uvm_reg_field field;
      uvm_reg       rg;
      $cast(field, rw.element);
      rg    = field.get_parent();
      name  = rg.get_full_name();
    end
    else begin
      name  = rw.element.get_full_name();
    end

    $sformat(message, "%s is write-only. Cannot call read() method.", name);
    if (SEVERITY == UVM_WARNING) begin
      `uvm_warning("UVM/REG/WRITEONLY", message)
    end
    else begin
      `uvm_error("UVM/REG/WRITEONLY", message);
    end
  endtask

  local static  this_type m_me;

  local static function this_type get();
    if (m_me == null) begin
      m_me  = new;
    end
    return m_me;
  endfunction

  static function void add(uvm_reg rg);
    this_type cb  = get();
    cb.m_add(rg);
  endfunction

  static function void remove(uvm_reg rg);
    this_type cb  = get();
    cb.m_remove(rg);
  endfunction

  `tue_object_default_constructor(tue_reg_write_only_cbs)
  `uvm_object_param_utils(tue_reg_write_only_cbs #(SEVERITY))
endclass

typedef tue_reg_write_only_cbs #(UVM_WARNING) tue_reg_write_only_warning_cbs;
typedef tue_reg_write_only_cbs #(UVM_ERROR)   tue_reg_write_only_error_cbs;
`endif
