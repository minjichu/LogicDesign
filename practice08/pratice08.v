//	==================================================
//	Copyright (c) 2019 Sookmyung Women's University.
//	--------------------------------------------------
//	FILE 			: dut.v
//	DEPARTMENT		: EE
//	AUTHOR			: WOONG CHOI
//	EMAIL			: woongchoi@sookmyung.ac.kr
//	--------------------------------------------------
//	RELEASE HISTORY
//	--------------------------------------------------
//	VERSION			DATE
//	0.0			2019-11-18
//	--------------------------------------------------
//	PURPOSE			: Digital Clock
//	==================================================

//	--------------------------------------------------
//	Numerical Controlled Oscillator
//	Hz of o_gen_clk = Clock Hz / num
//	--------------------------------------------------
module	nco(	
		o_gen_clk,
		i_nco_num,
		clk,
		rst_n);

output		o_gen_clk	;	// 1Hz CLK

input	[31:0]	i_nco_num	;
input		clk		;	// 50Mhz CLK
input		rst_n		;

reg	[31:0]	cnt		;
reg		o_gen_clk	;

always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt		<= 32'd0;
		o_gen_clk	<= 1'd0	;
	end else begin
		if(cnt >= i_nco_num/2-1) begin
			cnt 	<= 32'd0;
			o_gen_clk	<= ~o_gen_clk;
		end else begin
			cnt <= cnt + 1'b1;
		end
	end
end

endmodule

//	--------------------------------------------------
//	Flexible Numerical Display Decoder
//	--------------------------------------------------
module	fnd_dec(
		o_seg,
		i_num);

output	[6:0]	o_seg		;	// {o_seg_a, o_seg_b, ... , o_seg_g}

input	[3:0]	i_num		;
reg	[6:0]	o_seg		;
//making
always @(i_num) begin 
 	case(i_num) 
 		4'd0:	o_seg = 7'b111_1110; 
 		4'd1:	o_seg = 7'b011_0000; 
 		4'd2:	o_seg = 7'b110_1101; 
 		4'd3:	o_seg = 7'b111_1001; 
 		4'd4:	o_seg = 7'b011_0011; 
 		4'd5:	o_seg = 7'b101_1011; 
 		4'd6:	o_seg = 7'b101_1111; 
 		4'd7:	o_seg = 7'b111_0000; 
 		4'd8:	o_seg = 7'b111_1111; 
 		4'd9:	o_seg = 7'b111_0011; 
		default:o_seg = 7'b000_0000; 
	endcase 
end


endmodule

//	--------------------------------------------------
//	0~59 --> 2 Separated Segments
//	--------------------------------------------------
module	double_fig_sep(
		o_left,
		o_right,
		i_double_fig);

output	[3:0]	o_left		;
output	[3:0]	o_right		;

input	[5:0]	i_double_fig	;

assign		o_left	= i_double_fig / 10	;
assign		o_right	= i_double_fig % 10	;

endmodule

//	--------------------------------------------------
//	0~59 --> 2 Separated Segments
//	--------------------------------------------------
module	led_disp(
		o_seg,
		o_seg_dp,
		o_seg_enb,
		i_six_digit_seg,
		i_six_dp,
		clk,
		rst_n);

output	[5:0]	o_seg_enb		;
output		o_seg_dp		;
output	[6:0]	o_seg			;

input	[41:0]	i_six_digit_seg		;
input	[5:0]	i_six_dp		;
input		clk			;
input		rst_n			;

wire		gen_clk		;

nco		u_nco(
		.o_gen_clk	( gen_clk	),
		.i_nco_num	( 32'd5000	),
		.clk		( clk		),
		.rst_n		( rst_n		));


reg	[3:0]	cnt_common_node	;

always @(posedge gen_clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt_common_node <= 4'd0;
	end else begin
		if(cnt_common_node >= 4'd5) begin
			cnt_common_node <= 4'd0;
		end else begin
			cnt_common_node <= cnt_common_node + 1'b1;
		end
	end
end

reg	[5:0]	o_seg_enb		;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0:	o_seg_enb = 6'b111110;
		4'd1:	o_seg_enb = 6'b111101;
		4'd2:	o_seg_enb = 6'b111011;
		4'd3:	o_seg_enb = 6'b110111;
		4'd4:	o_seg_enb = 6'b101111;
		4'd5:	o_seg_enb = 6'b011111;
		default:o_seg_enb = 6'b111111;
	endcase
end

reg		o_seg_dp		;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0:	o_seg_dp = i_six_dp[0];
		4'd1:	o_seg_dp = i_six_dp[1];
		4'd2:	o_seg_dp = i_six_dp[2];
		4'd3:	o_seg_dp = i_six_dp[3];
		4'd4:	o_seg_dp = i_six_dp[4];
		4'd5:	o_seg_dp = i_six_dp[5];
		default:o_seg_dp = 1'b0;
	endcase
end

reg	[6:0]	o_seg			;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0:	o_seg = i_six_digit_seg[6:0];
		4'd1:	o_seg = i_six_digit_seg[13:7];
		4'd2:	o_seg = i_six_digit_seg[20:14];
		4'd3:	o_seg = i_six_digit_seg[27:21];
		4'd4:	o_seg = i_six_digit_seg[34:28];
		4'd5:	o_seg = i_six_digit_seg[41:35];
		default:o_seg = 7'b111_1110; // 0 display
	endcase
end

endmodule

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) Counter
//	--------------------------------------------------
module	hms_cnt(
		o_hms_cnt,
		o_max_hit,
		i_max_cnt,
		clk,
		rst_n);

output	[5:0]	o_hms_cnt		;
output		o_max_hit		;

input	[5:0]	i_max_cnt		;
input		clk			;
input		rst_n			;

reg	[5:0]	o_hms_cnt		;
reg		o_max_hit		;
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_hms_cnt <= 6'd0;
		o_max_hit <= 1'b0;
	end else begin
		if(o_hms_cnt >= i_max_cnt) begin
			o_hms_cnt <= 6'd0;
			o_max_hit <= 1'b1;
		end else begin
			o_hms_cnt <= o_hms_cnt + 1'b1;
			o_max_hit <= 1'b0;
		end
	end
end

endmodule

module  debounce(
		o_sw,
		i_sw,
		clk);
output		o_sw			;

input		i_sw			;
input		clk			;

reg		dly1_sw			;
always @(posedge clk) begin
	dly1_sw <= i_sw;
end

reg		dly2_sw			;
always @(posedge clk) begin
	dly2_sw <= dly1_sw;
end

assign		o_sw = dly1_sw | ~dly2_sw;

endmodule

//	--------------------------------------------------
//	Clock Controller
//	--------------------------------------------------
module	controller(
		o_mode,
		o_position,
		o_alarm_en,
		o_sec_clk,
		o_min_clk,
		o_alarm_sec_clk,
		o_alarm_min_clk,
		i_max_hit_sec,
		i_max_hit_min,
		i_sw0,
		i_sw1,
		i_sw2,
		i_sw3,
		clk,
		rst_n);

output	[1:0]	o_mode			;
output		o_position		;
output		o_alarm_en		;
output		o_sec_clk		;
output		o_min_clk		;
output		o_alarm_sec_clk		;
output		o_alarm_min_clk		;

input		i_max_hit_sec		;
input		i_max_hit_min		;

input		i_sw0			;
input		i_sw1			;
input		i_sw2			;
input		i_sw3			;

input		clk			;
input		rst_n			;

parameter	MODE_CLOCK	= 2'b00	;
parameter	MODE_SETUP	= 2'b01	;
parameter	MODE_ALARM	= 2'b10	;
parameter	POS_SEC		= 1'b0	;
parameter	POS_MIN		= 1'b1	;

wire		clk_100hz		;
nco		u0_nco(
		.o_gen_clk	( clk_100hz	),
		.i_nco_num	( 32'd500000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

wire		sw0			;
debounce	u0_debounce(
		.o_sw		( sw0		),
		.i_sw		( i_sw0		),
		.clk		( clk_100hz	));

wire		sw1			;
debounce	u1_debounce(
		.o_sw		( sw1		),
		.i_sw		( i_sw1		),
		.clk		( clk_100hz	));

wire		sw2			;
debounce	u2_debounce(
		.o_sw		( sw2		),
		.i_sw		( i_sw2		),
		.clk		( clk_100hz	));

wire		sw3			;
debounce	u3_debounce(
		.o_sw		( sw3		),
		.i_sw		( i_sw3		),
		.clk		( clk_100hz	));

reg	[1:0]	o_mode			;
always @(posedge sw0 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_mode <= MODE_CLOCK;
	end else begin
		if(o_mode >= MODE_ALARM) begin
			o_mode <= MODE_CLOCK;
		end else begin
			o_mode <= o_mode + 1'b1;
		end
	end
end

reg		o_position		;
always @(posedge sw1 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_position <= POS_SEC;
	end else begin
		o_position <= o_position + 1'b1;
	end
end

reg		o_alarm_en		;
always @(posedge sw3 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_alarm_en <= 1'b0;
	end else begin
		o_alarm_en <= o_alarm_en + 1'b1;
	end
end

wire		clk_1hz			;
nco		u1_nco(
		.o_gen_clk	( clk_1hz	),
		.i_nco_num	( 32'd50000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg		o_sec_clk		;
reg		o_min_clk		;
reg		o_alarm_sec_clk		;
reg		o_alarm_min_clk		;
always @(*) begin
	case(o_mode)
		MODE_CLOCK : begin
			o_sec_clk = clk_1hz;
			o_min_clk = i_max_hit_sec;
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
		end
		MODE_SETUP : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk = ~sw2;
					o_min_clk = 1'b0;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk = 1'b0;
					o_min_clk = ~sw2;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
				end
			endcase
		end
		MODE_ALARM : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_alarm_sec_clk = ~sw2;
					o_alarm_min_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = ~sw2;
				end
			endcase
		end
		default: begin
			o_sec_clk = 1'b0;
			o_min_clk = 1'b0;
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
		end
	endcase
end

endmodule

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) Counter
//	--------------------------------------------------
module	minsec(	
		o_sec,
		o_min,
		o_max_hit_sec,
		o_max_hit_min,
		o_alarm,
		i_mode,
		i_position,
		i_sec_clk,
		i_min_clk,
		i_alarm_sec_clk,
		i_alarm_min_clk,
		i_alarm_en,
		clk,
		rst_n);

output	[5:0]	o_sec		;
output	[5:0]	o_min		;
output		o_max_hit_sec	;
output		o_max_hit_min	;
output		o_alarm		;

input	[1:0]	i_mode		;
input		i_position	;
input		i_sec_clk	;
input		i_min_clk	;
input		i_alarm_sec_clk	;
input		i_alarm_min_clk	;
input		i_alarm_en	;

input		clk		;
input		rst_n		;

parameter	MODE_CLOCK	= 2'b00	;
parameter	MODE_SETUP	= 2'b01	;
parameter	MODE_ALARM	= 2'b10	;
parameter	POS_SEC		= 1'b0	;
parameter	POS_MIN		= 1'b1	;

//	MODE_CLOCK
wire	[5:0]	sec		;
wire		max_hit_sec	;
hms_cnt		u_hms_cnt_sec(
		.o_hms_cnt	( sec			),
		.o_max_hit	( o_max_hit_sec		),
		.i_max_cnt	( 6'd59			),
		.clk		( i_sec_clk		),
		.rst_n		( rst_n			));

wire	[5:0]	min		;
wire		max_hit_min	;
hms_cnt		u_hms_cnt_min(
		.o_hms_cnt	( min			),
		.o_max_hit	( o_max_hit_min		),
		.i_max_cnt	( 6'd59			),
		.clk		( i_min_clk		),
		.rst_n		( rst_n			));

wire	[5:0]	alarm_sec	;
//	MODE_ALARM
hms_cnt		u_hms_cnt_alarm_sec(
		.o_hms_cnt	( alarm_sec		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd59			),
		.clk		( i_alarm_sec_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	alarm_min	;
hms_cnt		u_hms_cnt_alarm_min(
		.o_hms_cnt	( alarm_min		),
		.o_max_hit	( 			),
		.i_max_cnt	( 6'd59			),
		.clk		( i_alarm_min_clk	),
		.rst_n		( rst_n			));

reg	[5:0]	o_sec		;
reg	[5:0]	o_min		;
always @ (*) begin
	case(i_mode)
		MODE_CLOCK: 	begin
			o_sec	= sec;
			o_min	= min;
		end
		MODE_SETUP:	begin
			o_sec	= sec;
			o_min	= min;
		end
		MODE_ALARM:	begin
			o_sec	= alarm_sec;
			o_min	= alarm_min;
		end
	endcase
end

reg		o_alarm		;
always @ (posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		o_alarm <= 1'b0;
	end else begin
		if( (sec == alarm_sec) && (min == alarm_min)) begin
			o_alarm <= 1'b1 & i_alarm_en;
		end else begin
			o_alarm <= o_alarm & i_alarm_en;
		end
	end
end

endmodule

module	buzz(
		o_buzz,
		i_buzz_en,
		clk,
		rst_n);

output		o_buzz		;

input		i_buzz_en	;
input		clk		;
input		rst_n		;

parameter	C = 23889.09725;
parameter	D = 21282.77228;
parameter	E = 18960.79666;
parameter	F = 17896.60487;
parameter	G = 15944.06567;
parameter	A = 14204.54545;
parameter	B =12654.81265;

wire		clk_bit		;
nco	u_nco_bit(	
		.o_gen_clk	( clk_bit	),
		.i_nco_num	( 25000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg	[4:0]	cnt		;
always @ (posedge clk_bit or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt <= 5'd0;
	end else begin
		if(cnt >= 5'd24) begin
			cnt <= 5'd0;
		end else begin
			cnt <= cnt + 1'd1;
		end
	end
end

reg	[31:0]	nco_num		;
always @ (*) begin
	case(cnt)
		5'd00: nco_num = E	;
		5'd01: nco_num = D	;
		5'd02: nco_num = C	;
		5'd03: nco_num = D	;
		5'd04: nco_num = E	;
		5'd05: nco_num = E	;
		5'd06: nco_num = E	;
		5'd07: nco_num = D	;
		5'd08: nco_num = D	;
		5'd09: nco_num = D	;
		5'd10: nco_num = E	;
		5'd11: nco_num = E	;
		5'd12: nco_num = E	;
		5'd13: nco_num = E	;
		5'd14: nco_num = D	;
		5'd15: nco_num = C	;
		5'd16: nco_num = D	;
		5'd17: nco_num = E	;
		5'd18: nco_num = E	;
		5'd19: nco_num = E	;
		5'd20: nco_num = D	;
		5'd21: nco_num = D	;
		5'd22: nco_num = E	;
		5'd23: nco_num = D	;
		5'd24: nco_num = C	;
	endcase
end

wire		buzz		;
nco	u_nco_buzz(	
		.o_gen_clk	( buzz		),
		.i_nco_num	( nco_num	),
		.clk		( clk		),
		.rst_n		( rst_n		));

assign		o_buzz = buzz & i_buzz_en & clk_bit ;

endmodule

module	top(
		o_seg_enb,
		o_seg_dp,
		o_seg,
		o_alarm,
		i_sw0,
		i_sw1,
		i_sw2,
		i_sw3,
		clk,
		rst_n);

output	[5:0]	o_seg_enb	;
output			o_seg_dp	;
output	[6:0]	o_seg		;
output			o_alarm		;
	
input			i_sw0		;
input			i_sw1		;
input			i_sw2		;
input			i_sw3		;
input			clk			;
input			rst_n		;

wire	[1:0]		o_mode				;
wire				o_position			;
wire				o_min_clk			;
wire				o_sec_clk			;
wire	 			o_alarm_en			;
wire				o_alarm_sec_clk		;
wire			    o_alarm_min_clk		;
wire				i_max_hit_sec		;
wire				i_max_hit_min		;
wire			    i_sw0				;
wire				i_sw1				;	
wire				i_sw2				;
wire				i_sw3				;
wire				clk					;
wire				rst_n				;
wire	[5:0]		o_sec				;
wire	[5:0]		o_min				;
wire				o_alarm				;
wire 	[3:0]		o_left_i			;
wire 	[3:0]		o_right_i			;
wire 	[3:0]		o_left_j			;
wire 	[3:0]		o_right_j			;
wire	[41:0]		i_six_digit_seg		;
wire	[6:0]		i_six_digit_seg_i	;
wire	[6:0]		i_six_digit_seg_j	;
wire	[6:0]		i_six_digit_seg_k	;
wire	[6:0]		i_six_digit_seg_l	;
wire				o_seg_dp			;
wire	[6:0]		o_seg				;
wire	[5:0]		o_seg_enb			;
wire				o_alarm_o			;
	







controller		controller_u_controller(		.o_mode				(	o_mode			),			
												.o_position	 		(	o_position		),	
												.o_min_clk 			(   o_min_clk		),
												.o_sec_clk 			(   o_sec_clk		),
												.o_alarm_en 		(   o_alarm_en		),
												.o_alarm_sec_clk	(   o_alarm_sec_clk	),
												.o_alarm_min_clk 	(   o_alarm_min_clk ),
												.i_max_hit_sec 		(  	i_max_hit_sec	),
												.i_max_hit_min 		(   i_max_hit_min	),
												.i_sw0				(   i_sw0			),
												.i_sw1				(  	i_sw1			),
												.i_sw2				(   i_sw2			),	
												.i_sw3				(   i_sw3			),	
												.clk				(   clk				),
												.rst_n				(   rst_n			));


								



minsec			minsec_u_minsec			(		.o_sec				(		o_sec				),
												.i_mode				(		o_mode				),
												.o_min				(		o_min				),
												.o_max_hit_sec		(		i_max_hit_sec		),
												.o_max_hit_min		(		i_max_hit_min		),
												.o_alarm			(		o_alarm_o			),
												.i_position			(		o_position			),
												.i_sec_clk			(		o_sec_clk			),
												.i_min_clk			(		o_min_clk			),
												.i_alarm_sec_clk	(		o_alarm_sec_clk		),
												.i_alarm_min_clk	(		o_alarm_min_clk 	),
												.i_alarm_en			(		o_alarm_en			),
												.clk				(		clk					),
												.rst_n				(		rst_n				));



double_fig_sep	 double_fig_sep_u1_dfs	(		.i_double_fig		(			o_min			),
												.o_left				(		    o_left_i		),	
												.o_right			(		    o_right_i		));



double_fig_sep	 double_fig_sep_u0_dfs	(		.i_double_fig		(			o_sec				),
												.o_left				(		    o_left_j		),	
												.o_right			(		    o_right_j		));



fnd_dec			fnd_dec_u2_fnd_dec		(		.i_num			 	(	o_left_i				),
												.o_seg				(	i_six_digit_seg_i		));	




fnd_dec			fnd_dec_u3_fnd_dec		(		.i_num			 	(	o_right_i				),
												.o_seg				(	i_six_digit_seg_j		));	





fnd_dec			fnd_dec_u0_fnd_dec		(		.i_num			 	(	o_left_j				),
												.o_seg				(	i_six_digit_seg_k		));	




fnd_dec			fnd_dec_u1_fnd_dec		(		.i_num			 	(   o_right_j				),
												.o_seg				(	i_six_digit_seg_l		));	




assign			i_six_digit_seg	 = { {2{7'b0000000}}, i_six_digit_seg_i,i_six_digit_seg_j,i_six_digit_seg_k,i_six_digit_seg_l };

led_disp		led_disp_u_led_disp		(		.o_seg				(	o_seg					),
												.o_seg_dp			(	o_seg_dp				),
												.o_seg_enb			(	o_seg_enb				),
												.i_six_digit_seg	(	i_six_digit_seg			),
												.clk				(   clk						),
												.rst_n				(	rst_n					));




buzz			buzz_u_buzz				(		.o_buzz				(	o_alarm					),
												.i_buzz_en			(	o_alarm_o				),
												.clk				(	clk						),
												.rst_n				(   rst_n					));

endmodule
