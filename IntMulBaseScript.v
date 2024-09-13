module lab1_imul_IntMulBase
(
  input  logic        clk,
  input  logic        reset,

  input  logic        istream_val,   // Input stream valid signal
  output logic        istream_rdy,   // Input stream ready signal
  input  logic [63:0] istream_msg,   // Input message: [a (31:0), b (31:0)]

  output logic        ostream_val,   // Output stream valid signal
  input  logic        ostream_rdy,   // Output stream ready signal
  output logic [31:0] ostream_msg    // Output message: result of multiplication
);

  //----------------------------------------------------------------------
  // Split input message into two 32-bit values (a and b)
  //----------------------------------------------------------------------
  logic [31:0] a_in, b_in;
  assign a_in = istream_msg[63:32];  // Extract upper 32 bits as a
  assign b_in = istream_msg[31:0];   // Extract lower 32 bits as b

  //----------------------------------------------------------------------
  // Control Signals for Datapath
  //----------------------------------------------------------------------
  logic        b_mux_sel, a_mux_sel, result_mux_sel, result_en, add_mux_sel;
  logic        b_lsb;  // Least significant bit of b
  logic [31:0] result_out;

  //----------------------------------------------------------------------
  // Datapath Instantiation
  //----------------------------------------------------------------------
  multiplier_datapath datapath (
    .clk           (clk),
    .reset         (reset),
    .a_in          (a_in),
    .b_in          (b_in),
    .a_mux_sel     (a_mux_sel),
    .b_mux_sel     (b_mux_sel),
    .result_mux_sel(result_mux_sel),
    .result_en     (result_en),
    .add_mux_sel   (add_mux_sel),
    .b_lsb         (b_lsb),
    .result_out    (result_out)
  );

  //----------------------------------------------------------------------
  // FSM State Declarations
  //----------------------------------------------------------------------
  typedef enum logic [1:0] {IDLE, CALC, DONE} state_t;
  state_t state, next_state;
  logic [5:0] cycle_count;  // 6-bit counter for 32 iterations

  //----------------------------------------------------------------------
  // FSM Logic
  //----------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      state <= IDLE;
    else
      state <= next_state;
  end

  always_comb begin
    // Default signal assignments
    istream_rdy = 1'b0;
    ostream_val = 1'b0;
    b_mux_sel   = 1'b0;  // Default to loading initial value of b
    a_mux_sel   = 1'b0;  // Default to loading initial value of a
    result_mux_sel = 1'b0; // Default to zero the result at start
    result_en   = 1'b0;
    add_mux_sel = 1'b0;

    case (state)
      IDLE: begin
        istream_rdy = 1'b1;
        if (istream_val) begin
          next_state = CALC;
          // Load initial values into a, b, and result registers
          b_mux_sel = 1'b0;
          a_mux_sel = 1'b0;
          result_mux_sel = 1'b0;
          result_en = 1'b1; // Enable result register to load zero initially
        end
        else begin
          next_state = IDLE;
        end
      end

      CALC: begin
        result_en = 1'b1;  // Enable result updates
        b_mux_sel = 1'b1;  // Shift b
        a_mux_sel = 1'b1;  // Shift a
        if (b_lsb == 1'b1) begin
          add_mux_sel = 1'b1;  // Add a to result if b_lsb == 1
        end
        if (cycle_count == 6'd32) begin
          next_state = DONE;
        end
        else begin
          next_state = CALC;
        end
      end

      DONE: begin
        ostream_val = 1'b1;
        if (ostream_rdy) begin
          next_state = IDLE;
        end
        else begin
          next_state = DONE;
        end
      end
    endcase
  end

  //----------------------------------------------------------------------
  // Cycle Counter Logic
  //----------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      cycle_count <= 6'b0;
    else if (state == CALC)
      cycle_count <= cycle_count + 1;
    else
      cycle_count <= 6'b0;
  end

  //----------------------------------------------------------------------
  // Output result
  //----------------------------------------------------------------------
  assign ostream_msg = result_out;

endmodule
