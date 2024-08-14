module top (
    input wire clk,  // Clock input
    input wire nrst, // Reset input (active low)
    output reg tx    // Serial data output
);

// "Hello world!" ROM array
reg [7:0] rom [0:12];
initial begin
    rom[0] = 8'h48;  // 'H'
    rom[1] = 8'h65;  // 'e'
    rom[2] = 8'h6C;  // 'l'
    rom[3] = 8'h6C;  // 'l'
    rom[4] = 8'h6F;  // 'o'
    rom[5] = 8'h20;  // ' '
    rom[6] = 8'h77;  // 'w'
    rom[7] = 8'h6F;  // 'o'
    rom[8] = 8'h72;  // 'r'
    rom[9] = 8'h6C;  // 'l'
    rom[10] = 8'h64;  // 'd'
    rom[11] = 8'h21;  // '!'
    rom[12] = 8'h0a;  // '\n'
end

reg [3:0] rom_addr = 0;  // ROM address counter
wire txe; // Transmit buffer empty flag
wire start = txe; // Start transmission signal

UART_Transmitter tx_inst (
    .clk(clk),
    .nrst(nrst),
    .start(start),
    .data_in(rom[rom_addr]),
    .tx(tx),
    .txe(txe)
);

always @(posedge clk) begin
    if (!nrst) begin
        rom_addr <= 0;
    end else begin
        if (txe) begin
            if (rom_addr == 12)
                rom_addr <= 0;
            else
                rom_addr <= rom_addr + 1;
        end
    end
end

endmodule
