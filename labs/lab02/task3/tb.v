module tb;

  reg  [1:0] t_a, t_b;
  wire       t_gt, t_lt, t_eq;

  integer errors;
  integer i;

  comp2 DUT (
    .A (t_a),
    .B (t_b),
    .GT(t_gt),
    .LT(t_lt),
    .EQ(t_eq)
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
    for (i = 0; i < 16; i = i + 1) begin
      {t_a, t_b} = i[3:0];
      #1;


      if (t_gt !== (t_a >  t_b) ||
          t_lt !== (t_a <  t_b) ||
          t_eq !== (t_a == t_b)) begin
        errors = errors + 1;
        $display("%0t FAIL: A=%0d B=%0d | GT=%b LT=%b EQ=%b (expected GT=%b LT=%b EQ=%b)",
                 $time, t_a, t_b, t_gt, t_lt, t_eq,
                 (t_a > t_b), (t_a < t_b), (t_a == t_b));
      end


      if ((t_gt + t_lt + t_eq) !== 1) begin
        errors = errors + 1;
        $display("%0t FAIL: A=%0d B=%0d not one-hot (GT=%b LT=%b EQ=%b)",
                 $time, t_a, t_b, t_gt, t_lt, t_eq);
      end

      #4;
    end

    if (errors == 0)
      $display("PASS: all 16 combinations correct");
    else
      $display("FAILED: %0d error(s)", errors);
    $finish;
  end

endmodule