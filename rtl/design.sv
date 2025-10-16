//=========================================================
// Modulo: FSM
// Descripción: Maquina de estados finitos (FSM) secuencial
// con tres estados (idle, s0, s1), controlada por 'din'.
// La salida 'dout' se activa solo en estado s1 con din=1.
//=========================================================

module FSM (
  input  logic clk,       // Señal de reloj
  input  logic rst,       // Reset sincrono activo en alto
  input  logic din,       // Entrada de control
  output logic dout);     // Salida binaria

 
  // Definición de estados mediante enumeración

 typedef enum logic [2:0] {
    idle = 3'b001,         // Estado inicial tras reset
    s0   = 3'b010,         // Estado intermedio sin salida
    s1   = 3'b100          // Estado que puede generar salida alta
  } state_t;

  state_t state, next_state;

  // Lógica secuencial: transición de estado
  always_ff @(posedge clk) begin
    if (rst)
      state <= idle;       // Reinicio: forzar estado inicial
    else
      state <= next_state; // Actualizar estado
  end

  // Lógica combinacional: cálculo de proximo estado y salida
  
  always_comb begin
    // Valores por defecto
    next_state = idle;
    dout       = 1'b0;

    case (state)
      // Estado IDLE: transición a S0 si rst está desactivado
      idle: begin
        dout = 1'b0;
        if (rst)
          next_state = idle;
        else
          next_state = s0;
      end

      // Estado S0: transición a S1 si din=1, se mantiene si din=0
      s0: begin
        if (din) begin
          next_state = s1;
          dout = 1'b0;
        end else begin
          next_state = s0;
          dout = 1'b0;
        end
      end

      // Estado S1: transición a S0 si din=1 (dout=1), se mantiene si din=0
      s1: begin
        if (din) begin
          next_state = s0;
          dout = 1'b1; // Única condición donde dout=1
        end else begin
          next_state = s1;
          dout = 1'b0;
        end
      end

      // Estado por defecto: regresar a IDLE
      default: begin
        next_state = idle;
        dout = 1'b0;
      end
    endcase
  end

endmodule
