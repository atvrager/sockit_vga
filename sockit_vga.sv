module sockit_vga(
  input logic clk, 
  input logic reset_n,
  output logic vga_clk,
  output logic vga_hs_n,
  output logic vga_vs_n,
  output logic vga_blank_n,
  output logic[7:0] red,
  output logic[7:0] green,
  output logic[7:0] blue
);

logic reset;
logic pll_out_clk;

assign vga_clk = pll_out_clk;

pll p(clk, reset, pll_out_clk);

always_ff @(posedge clk) begin
  reset <= ~reset_n;
end

logic[9:0] hsync_counter;
logic[9:0] vsync_counter;

always_ff @(posedge vga_clk) begin
  if (reset) begin
    vga_hs_n <= 1'b1;
    vga_vs_n <= 1'b1;
    hsync_counter = 10'b0;
    vsync_counter = 10'b0;
    vga_blank_n = 1'b1;
    red <= 8'h0;
    green <= 8'h0;
    blue <=8'h0;
  end else begin
    red <= hsync_counter[7:0];
    green <= vsync_counter[7:0];
    blue <= {hsync_counter[3:0], vsync_counter[3:0]};
    // Horizontal and vertical counters
    hsync_counter <= (hsync_counter + 1) % 800;
    if (hsync_counter == 799) begin
      vsync_counter <= (vsync_counter + 1) % 525;
    end
    
    // Generate Hsync (Active low)
    if (hsync_counter >= 656 && hsync_counter < 752) begin
      vga_hs_n <= 1'b0;
    end else begin
      vga_hs_n <= 1'b1;
    end
    
    // Generate Vsync (Active low)
    if (vsync_counter >= 489 && vsync_counter < 491) begin
      vga_vs_n <= 1'b0;
    end else begin
      vga_vs_n <= 1'b1;
    end
    
    // Generate blank (Active low)
    if (hsync_counter < 640 && vsync_counter < 480) begin
      vga_blank_n <= 1'b1;
    end else begin
      vga_blank_n <= 1'b0;
    end
  end
end

endmodule