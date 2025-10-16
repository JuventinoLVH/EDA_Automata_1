// Link: https://www.edaplayground.com/x/WA4J
`timescale 1ns/1ps

//=================
// Testbenche FSM
// Modulo tb_top
//==================

module tb;

// ===================================================
// Señales del DUT
    integer i;
    logic clk;
    logic rst;
    logic din;
    logic dout;

// ===================================================
// Instancia del DUT
    FSM dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .dout(dout)
    );

// ===================================================
// Generación de reloj
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

// ===================================================
// Asserciones SVA
    // El estado es one-hot
    state_onehot : assert property (@(posedge clk) 1'b1 |=> $onehot(dut.state));
 
    // El estado de idle solo se activa si rst=1
    state_rst_high:  assert property (@(posedge clk) rst |=> (dut.state == dut.idle));
    state_idle: assert property (@(posedge clk) (dut.idle) |=> rst);

    // Si el valor de din es 1 el estado cambia
    idle_change: assert property (@(posedge clk) (dut.state == dut.idle && rst == 1'b0) |=> 
        (dut.next_state == dut.s0));
     
    // Si el valor de din es 1 el estado cambia
    state_change: assert property (@(posedge clk) (din == 1'b1 && rst == 1'b0 && dut.state != dut.idle) |=> 
        (dut.next_state != dut.state));
 
    // Si el valor de din es 0 el estado se mantiene
    state_unchange: assert property (@(posedge clk) (din == 1'b0 && rst == 1'b0 && dut.state != dut.idle) |=>
        (dut.next_state == dut.state));
 
    // La salida 'dout' se activa solo en estado s1 con din=1.
    out_dout: assert property (@(posedge clk) (dout == 1'b1) |=> (dut.state == dut.s1 && din == 1'b1) );

// ===================================================
// Self check manual
    task self_check();
        for(i = 0; i < 20; i++) begin
            @(posedge clk);
            if(dout == 1'b1)
                if(dut.state == dut.s1 && dut.din == 1'b1)
                    $display($time, ": Valor dout valido");
                else
                    $error($time, ": Failure");
        end
    endtask  

// ===================================================
// Generación de estímulos
    initial begin
        rst=1;din=0;
 
        #10 rst=1;din=0;
        #10 rst=0;din=0;
        #10 rst=0;din=1;
        #10 rst=0;din=1;
        #10 rst=0;din=1;
        #10 rst=0;din=0;
        #10 rst=0;din=1;
        #10 rst=1;din=1;
  
        $finish;
    end

// ===================================================
// Crear covergroup
covergroup cg_ejemplo @(posedge clk);
 
    coverpoint din {
        bins alto = {1};
        bins bajo = {0};
    }
 
    coverpoint dout {
        bins bajo_out = {0};
        bins alto_out = {1};
    }

    coverpoint dut.state {
        bins idle = {dut.idle};
        bins s0 = {dut.s0};
        bins s1 = {dut.s1};
    }

    coverpoint dut.next_state {
        bins to_idle = {dut.idle};
        bins to_s0   = {dut.s0};
        bins to_s1   = {dut.s1};
    }

    cross dut.state, din;
    cross dut.state, dut.next_state;
    cross dut.state, dout;
    cross dut.next_state, dout;

endgroup

// ===================================================
// Instancia de las pruebas
    cg_ejemplo cg1 = new();
    initial begin
        $dumpfile("dumpb.vcd"); $dumpvars;
        $display("############################################");
        $display("Inicio de simulación");
        $monitor($time," CONDICIONES: din=%b, reset=%b",din,rst);
        $monitor($time," AUTOMATA %b: state=%b, next=%b, dout=%b",clk,dut.state,dut.next_state, dout);
        $assertvacuousoff(0);

        cg1.sample();
        //self_check();
    end

endmodule
