#include <iostream>
#include <string>
#include <memory>
#include <chrono>
#include <verilated.h>          // Defines common routines
#include "VGADefines.h"
#include "VGADisplay.h"
#include "VVGA800x600.h"
#include "VVGA800x600_VGA800x600.h"

unsigned int frame_count = 0;

void vsyncPulse(VGADisplay *vga) {
    frame_count++;

    std::string name = "frame" + std::to_string(frame_count) + ".bmp";
    vga->paint();
    vga->saveScreenshot(name.c_str());

    std::cout << "Frame count = " << frame_count << '\n';
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);   // Remember args

    std::unique_ptr<VVGA800x600> uut = std::make_unique<VVGA800x600>();

    //VGA stuff
    int last_clock = 0, last_vsync, counter = 0;

    std::unique_ptr<VGADisplay> vga = std::make_unique<VGADisplay>(*uut, VGA_WIDTH, VGA_HEIGHT);

    if (!vga->initDisplay()) {
        std::cerr << "Failed to init VGA display" << std::endl;
        return 1;
    }

    uut->reset = 0;
    uut->clk = 0;
    uut->eval();

    uut->reset = 1;
    uut->eval();

    uut->reset = 0;
    uut->eval();
    
    last_vsync = uut->vsync;
    last_clock = uut->clk;
    std::cout << "VSync: " << static_cast<int>(uut->vsync) << '\n';

    int pulse_count = 0;
    
    auto start = std::chrono::high_resolution_clock::now();

    while (!Verilated::gotFinish()) {
        uut->eval();
    
        //VGA clock positive edge
        if (uut->clk == 1) {
            vga->clockPulse(uut->red, uut->green, uut->blue);
        }

		

        //Check for vsync pulse
        if (last_vsync != uut->vsync) {
            if ((last_vsync == 0) && (uut->vsync == 1)) {
                //Positive pulse
                auto finish = std::chrono::high_resolution_clock::now();
                std::chrono::duration<double> elapsed = finish - start;
                std::cout << "Elapsed Time: " << elapsed.count() << "s" << '\n';
                start = finish;

                vsyncPulse(vga.get());
            }

            last_vsync = uut->vsync;
        }

        uut->clk = !uut->clk;

        if (vga->isWindowClosed()) {
            break;
        }
    }

    uut->final(); // Done simulating

    return 0;
}



/* module VGA800x600(
	input clk,
    input reset,
	output reg [2:0] red,
    output reg [2:0] green,
    output reg [1:0] blue,
	output reg hsync,
	output reg vsync
);

 reg [9:0]hcount /* verilator public  ;
 reg [9:0]vcount /* verilator public  ;
 reg [2:0]color;

 always @(posedge clk or posedge reset)
 begin 
 if(reset) begin
    hcount <= 0;
    vcount <= 0;
 end

 else begin
    
	if(hcount == 1055)
	begin
		hcount <=0;
		if(vcount == 627)
		begin
			vcount <=0;
		end else begin
			vcount <= vcount+1;
		end
	end else begin
		hcount <= hcount +1;
	end
	
	if(vcount >= 601 && vcount <604) begin
		vsync =0;
	end else begin
		vsync =1;
	end
	
	if(hcount >=840 && hcount <928) begin
		hsync =0;
	end else begin
		hsync =1;
	end
	
	if(hcount < 800 && vcount <600) begin
		red =color[0];
		green = color[1];
		blue=color[2];
	end else begin
		red =1'b0;
		green = 1'b0;
		blue=1'b0;
	end
	if(hcount < 800 && vcount <600)
	begin
		if(hcount < 80)
		begin
			color = 3'b000;
		end else if(hcount < 160) begin
			color = 3'b001;
		end else if(hcount < 240) begin
			color = 3'b010;
		end else if(hcount < 320) begin
			color = 3'b011;
		end else if(hcount < 400) begin
			color = 3'b100;
		end else if(hcount < 480) begin
			color = 3'b101;
		end else if(hcount < 560) begin
			color = 3'b110;
		end else begin
			color = 3'b111;
		end
	end
    end
    
 end
 
 initial 
	begin
	hcount = 0;
	vcount=0;
	color = 3'b0;
	end
endmodule */
