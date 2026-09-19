// tb.v

module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  reg  [3:0] expected;
  integer    errors;
  integer    ia, ib, iop;

  alu DUT (
    .a     (t_a),
    .b     (t_b),
    .op    (t_op),
    .result(t_result)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    errors = 0;
    t_a = 0; t_b = 0; t_op = 0;
    #5;

    for (ia = 0; ia < 16; ia = ia + 1)
      for (ib = 0; ib < 16; ib = ib + 1)
        for (iop = 0; iop < 2; iop = iop + 1) begin
          t_a  = ia[3:0];
          t_b  = ib[3:0];
          t_op = iop[0];
          #5;  

          expected = t_op ? (t_a - t_b) : (t_a + t_b);

          if (t_result !== expected) begin
            errors = errors + 1;
            $display("%0t FAIL: a=%0d b=%0d op=%b | result=%0d expected=%0d",
                     $time, t_a, t_b, t_op, t_result, expected);
          end
        end

    if (errors == 0)
      $display("PASS: all 512 combinations correct");
    else
      $display("FAILED: %0d error(s)", errors);
    $finish;
  end

endmodule