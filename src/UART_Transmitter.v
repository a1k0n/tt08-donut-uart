module UART_Transmitter (
    input wire clk,  // Clock input
    input wire nrst, // Reset input (active low)
    input wire start, // Start transmission signal
    input wire [7:0] data_in, // Data to transmit
    output reg tx,   // Serial data output
    output wire txe // Transmit buffer empty flag
);

// Parameter definition
//parameter BAUD_RATE = 115200;  // Adjust as needed
//parameter CLOCK_FREQ = 48_000_000;  // Adjust to your clock frequency
parameter CLOCK_DIVIDER = 2;  // CLOCK_FREQ / BAUD_RATE;

reg [7:0] next_data_buf;  // Next data to transmit
reg txbuf_empty = 1'b1;  // Transmit buffer empty flag
assign txe = txbuf_empty;

always @(posedge clk or negedge nrst) begin
    if (!nrst) begin
        txbuf_empty <= 1'b1;
    end else begin
        if (start && txbuf_empty) begin
            if (!transmit) begin
                // Start transmission immediately if buffer is empty
                transmit <= 1'b1;
                data_reg <= data_in;
                bit_count <= 0;
                clock_count <= 0;
            end else begin
                next_data_buf <= data_in;
                txbuf_empty <= 1'b0;
            end
        end
    end
end

// Registers and wires
reg [7:0] data_reg;  // ASCII 'A'
reg [3:0] bit_count = 0;  // Bit counter for serial transmission
reg [8:0] clock_count = 0;  // Clock divider counter
reg transmit = 0;  // Flag to start transmission

// Main process
always @(posedge clk or negedge nrst) begin
    if (!nrst) begin
        // Reset logic
        tx <= 1'b1;  // Idle state for UART is high
        data_reg <= 8'h41;  // Reload with ASCII 'A'
        bit_count <= 0;
        clock_count <= 0;
        transmit <= 1'b0;
    end else begin
        // Clock divider logic
        if (clock_count >= CLOCK_DIVIDER - 1) begin
            clock_count <= 0;
        end else begin
            clock_count <= clock_count + 1;
        end

        // Transmit logic
        if (transmit && clock_count == 0) begin
            if (bit_count == 0) begin
                tx <= 0;  // Start bit
                bit_count <= bit_count + 1;
            end else if (bit_count > 0 && bit_count < 9) begin
                tx <= ~data_reg[bit_count - 1];  // Transmitting data bits, LSB first
                bit_count <= bit_count + 1;
            end else if (bit_count == 9) begin
                tx <= 1;  // Stop bit
                bit_count <= 0;  // Reset bit count to send next byte
                data_reg <= next_data_buf;  // Reload with ASCII 'A'
                transmit <= !txbuf_empty;
                txbuf_empty <= 1'b1;
            end
        end
    end
end

endmodule
