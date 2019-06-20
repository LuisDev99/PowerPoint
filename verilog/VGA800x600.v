`define IMG_WIDTH 168
`define IMG_HEIGHT 192
`define IMG_NUMBER_OF_LINES (32256) - 1

module ImageRom (
    input [15:0] address,
    output reg [7:0] data
);
reg [7:0] rom_content[0:`IMG_NUMBER_OF_LINES];

always @ (address)
	data = rom_content[address];

initial begin
	$readmemh("/home/luis/Pictures/bird1.mif", rom_content, 0, `IMG_NUMBER_OF_LINES);
end
endmodule

module VGA800x600(
    input reset,
    input clk,
    output [2:0] red,
    output [2:0] green,
    output [1:0] blue,
    output reg hsync,
    output reg vsync
);
reg [9:0] vcount /*verilator public */;
reg [10:0] hcount /*verilator public*/;
reg [7:0] rgb;
reg [7:0] color;

reg [15:0] address;
wire [7:0] img_pixel; 

// assign red = (3*rgb[2]);
// assign green = (3*rgb[1]);
// assign blue = (2*rgb[0]);

assign red = rgb[7:5];
assign green = rgb[4:2];
assign blue = rgb[1:0];

assign color = img_pixel;

ImageRom romi(
.address(address),
.data(img_pixel)
);

// wire out2;

always @(*) begin
    if (vcount >= 10'd601 && vcount < 10'd605)
    begin
        vsync = 1'd0;
    end
    else
    begin
        vsync = 1'd1;
    end

    if (hcount >= 11'd840 && hcount < 11'd968)
    begin
        hsync = 1'd0;
    end
    else
    begin
        hsync = 1'd1;
    end
end

always @ (posedge clk)
begin
    if (address >= `IMG_NUMBER_OF_LINES) begin
        address <= 16'd0;
    end

    if (hcount == 11'd1055)
    begin
        hcount <= 11'd0;

        if (vcount == 10'd627) begin
            vcount <= 10'd0;
        end else begin
            vcount <= vcount + 10'd1;
        end
    end else begin
        hcount <= hcount + 11'd1;
    end

    if (hcount < 11'd800 && vcount < 10'd600) begin
        if(vcount >= 10'd10 && vcount <= `IMG_HEIGHT && hcount >= 11'd10 && hcount <= `IMG_WIDTH) begin
            address <= address + 16'd1;                
            rgb <= color;
        end else begin
            rgb <= 8'd4;
        end
    end else begin
       rgb <= 8'd0;
    end
end

always @ (posedge clk)
begin
    if(reset)
    begin
        vcount <= 10'd0;
        hcount <= 11'd0;
        vsync = 1'd0;
        hsync = 1'd0;
    end
end
endmodule

/*`include "VGADefines.vh"
module VGA800x600(
	input clk,
    input reset,
	output reg [2:0] red,
    output reg [2:0] green,
    output reg [1:0] blue,
	output reg hsync,
	output reg vsync
);

 reg [10:0]hcount /* verilator public */ ;
 /*reg [10:0]vcount /* verilator public */ ;
 /*reg [2:0]color;

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
		if(vcount ==627)
		begin
			vcount <=0;
		end else begin
			vcount <= vcount+1;
		end
	end else begin
		hcount <= hcount +1;
	end
	
	if(vcount >= 601 && vcount <605) begin
		vsync =1;
	end else begin
		vsync =0;
	end
	
	if(hcount >=840 && hcount < 968) begin
		hsync =1;
	end else begin
		hsync =0;
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
endmodule*/