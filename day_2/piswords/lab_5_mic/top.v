`include "config.vh"

module top
# (
    parameter clk_mhz = 50,
              strobe_to_update_xy_counter_width = 20
)
(
    input             clk,
    input      [ 3:0] key,
    input      [ 3:0] sw,
    output     [ 7:0] led,

    output reg [ 7:0] abcdefgh,
    output     [ 7:0] digit,

    output            vsync,
    output            hsync,
    output     [ 2:0] rgb,

    output            buzzer,
    inout      [15:0] gpio
);

    wire   reset  = ~ key [3];
    assign buzzer = ~ reset;

    //------------------------------------------------------------------------

    wire [15:0] value;

    pmod_mic3_spi_receiver i_microphone
    (
        .clock ( clk        ),
        .reset ( reset      ),
        .cs    ( gpio  [14] ),
        .sck   ( gpio  [ 8] ),
        .sdo   ( gpio  [10] ),
        .value ( value      )
    );

    assign gpio [4] = 1'b1;  // VCC
    assign gpio [6] = 1'b0;  // GND

    //------------------------------------------------------------------------

    assign led = ~ value [13:6];

    //------------------------------------------------------------------------

    // It is enough for the counter to be 20 bit. Why?

    reg [15:0] prev_value;
    reg [19:0] counter;
    reg [19:0] distance;

    localparam [15:0] threshold = 16'h1000;

    always @ (posedge clk or posedge reset)
        if (reset)
        begin
            prev_value <= 16'h0;
            counter    <= 20'h0;
            distance   <= 20'h0;
        end
        else
        begin
            prev_value <= value;

            if (  value      > threshold
                & prev_value < threshold)
            begin
               distance <= counter;
               counter  <= 20'h0;
            end
            else if (counter != ~ 20'h0)  // To prevent overflow
            begin
               counter <= counter + 20'h1;
            end
        end

    //------------------------------------------------------------------------

    // Frequencies, Hz * 100

    localparam C  = 26163, Cs = 27718, D  = 29366, Ds = 31113,
               E  = 32963, F  = 34923, Fs = 36999, G  = 39200,
               Gs = 41530, A  = 44000, As = 46616, B  = 49388;

    function [19:0] low_distance (input [15:0] frq_100);
       low_distance = clk_mhz * 1000 * 1000 / frq_100 * 98;
    endfunction

    function [19:0] high_distance (input [15:0] frq_100);
       high_distance = clk_mhz * 1000 * 1000 / frq_100 * 102;
    endfunction

    wire C__in = distance > low_distance (C ) & distance < high_distance (C );
    wire Cs_in = distance > low_distance (Cs) & distance < high_distance (Cs);
    wire D__in = distance > low_distance (D ) & distance < high_distance (D );
    wire Ds_in = distance > low_distance (Ds) & distance < high_distance (Ds);
    wire E__in = distance > low_distance (E ) & distance < high_distance (E );
    wire F__in = distance > low_distance (F ) & distance < high_distance (F );
    wire Fs_in = distance > low_distance (Fs) & distance < high_distance (Fs);
    wire G__in = distance > low_distance (G ) & distance < high_distance (G );
    wire Gs_in = distance > low_distance (Gs) & distance < high_distance (Gs);
    wire A__in = distance > low_distance (A ) & distance < high_distance (A );
    wire As_in = distance > low_distance (As) & distance < high_distance (As);
    wire B__in = distance > low_distance (B ) & distance < high_distance (B );

    //------------------------------------------------------------------------

    assign digit = 8'b1111_1110;

    always @ (posedge clk or posedge reset)
        if (reset)
          abcdefgh <= 8'b11111111;
        else
          case ({ C__in, Cs_in, D__in, Ds_in,
                  E__in, F__in, Fs_in, G__in,
                  Gs_in, A__in, As_in, B__in })

          12'b1000_0000_0000: abcdefgh <= 8'b01100011;  // C   // abcdefgh
          12'b0100_0000_0000: abcdefgh <= 8'b01100010;  // C#
          12'b0010_0000_0000: abcdefgh <= 8'b10000101;  // D   //   --a-- 
          12'b0001_0000_0000: abcdefgh <= 8'b10000100;  // D#  //  |     |
          12'b0000_1000_0000: abcdefgh <= 8'b01100001;  // E   //  f     b
          12'b0000_0100_0000: abcdefgh <= 8'b01110001;  // F   //  |     |
          12'b0000_0010_0000: abcdefgh <= 8'b01110000;  // F#  //   --g-- 
          12'b0000_0001_0000: abcdefgh <= 8'b01000011;  // G   //  |     |
          12'b0000_0000_1000: abcdefgh <= 8'b01000010;  // G#  //  e     c
          12'b0000_0000_0100: abcdefgh <= 8'b00010001;  // A   //  |     |
          12'b0000_0000_0010: abcdefgh <= 8'b00010000;  // A#  //   --d--  h
          12'b0000_0000_0001: abcdefgh <= 8'b11000001;  // B
          default:            ;  // No assignment
          endcase

endmodule