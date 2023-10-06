// Opsero Electronic Design Inc. 2023

`timescale 1ns / 1ps

import axi_vip_pkg::*;
import maxtp_sim_axi_vip_0_0_pkg::*;

// Clock and Reset
bit aclk = 0, aresetn = 1;

// AXI4-Lite signals
xil_axi_resp_t resp;
bit[31:0]  addr, data, base_addr = 32'h4000_0000, switch_state;

module maxtp_tb( );

maxtp_sim_wrapper UUT
(
    .aclk               (aclk),
    .aresetn            (aresetn)
);

// Generate the clock : 50 MHz    
always #10ns aclk = ~aclk;

initial begin
    // Assert the reset
    aresetn = 0;
    #340ns
    // Release the reset
    aresetn = 1;
end

// Declare the agent for the master VIP
maxtp_sim_axi_vip_0_0_mst_t      master_agent;

initial begin    

    // Create a new agent
    master_agent = new("master vip agent",UUT.maxtp_sim_i.axi_vip_0.inst.IF);
    
    // Start the agent
    master_agent.start_master();
    
    // Wait for the reset to be released
    wait (aresetn == 1'b1);
    
    // Set register: dst mac addr lo
    #500ns
    addr = 32'h0;
    data = 32'hFFFF_1E00;
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);
    
    // Set register: dst mac addr hi
    #200ns
    addr = 32'h20;
    data = 32'h0000_FFFF;
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);

    // Set register: src mac addr lo
    #200ns
    addr = 32'h28;
    data = 32'hA4A5_2737;
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);

    // Set register: src mac addr hi
    #200ns
    addr = 32'h30;
    data = 32'h0000_FFFF;
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);

    // Set register: packet length
    #200ns
    addr = 32'h38;
    data = 30;
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);

    // Set register: force error
    #200ns
    addr = 32'h10;
    data = 1;
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);

end

endmodule

