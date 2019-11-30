==================================================

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



/*//	--------------------------------------------------

//	Numerical Controlled Oscillator		// blink	<--- This module is not used below yet.

//	Hz of o_gen_clk = Clock Hz / num

//	--------------------------------------------------

module	nco_blink(	

		o_gen_clk,

		i_nco_num,

		clk,

		rst_n);



output		o_gen_clk	;	// 1Hz CLK



input	[31:0]	i_nco_num	;

input		clk		;	// 50Mhz CLK

input		rst_n		;



nco		nco_blink(

		.o_gen_clk	( gen_clk	),

		.i_nco_num	( 32'd5000	),

		.clk		( ~clk		),

		.rst_n		( rst_n		));



endmodule

*/

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

//	LED Display

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

//	0~59 --> 2 Separated Segments

//	--------------------------------------------------

/*module	led_disp_blink(

		o_seg,

		o_seg_dp,

		o_seg_enb,

		i_seg,

		i_seg_dp,

		i_seg_enb,

		clk,

		rst_n);



output	[5:0]	o_seg_enb		;

output		o_seg_dp		;

output	[6:0]	o_seg			;



output	[5:0]	i_seg_enb		;

output		i_seg_dp		;

output	[6:0]	i_seg			;

input		clk			;

input		rst_n			;



wire 	[41:0]	i_six_digit_seg		;

wire 	[5:0]	i_six_dp		;



wire	[5:0]	o_seg_enb		;

wire		o_seg_dp		;

wire	[6:0]	o_seg			;



led_disp	u_led_disp_blink(

		.o_seg			( o_seg  		),

		.o_seg_dp		( o_seg_dp  		),

		.o_seg_enb		( o_seg_enb  		),

		.i_six_digit_seg	( i_six_digit_seg  	),

		.i_six_dp		( i_six_dp		),

		.clk			( ~clk			),

		.rst_n			( rst_n			));



reg	[6:0]	o_seg;

reg		o_seg_dp;

reg	[5:0]	o_seg_enb;

always @(posedge clk or negedge rst_n) begin

	if(i_seg_dp == i_six_dp[1]) begin

		o_seg_enb = 6'b111111;

	end else begin

		o_seg <= i_seg;

	end

end



endmodule*/



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

		o_hour_clk,

		o_alarm_sec_clk,

		o_alarm_min_clk,

		o_alarm_hour_clk,

		i_max_hit_sec,

		i_max_hit_min,

		i_max_hit_hour,

		i_sw0,

		i_sw1,

		i_sw2,

		i_sw3,

		clk,

		rst_n);



output	[1:0]	o_mode			;

output	[1:0]	o_position		;

output		o_alarm_en		;

output		o_sec_clk		;

output		o_min_clk		;

output		o_hour_clk		;

output		o_alarm_sec_clk		;

output		o_alarm_min_clk		;

output		o_alarm_hour_clk	;



input		i_max_hit_sec		;

input		i_max_hit_min		;

input		i_max_hit_hour		;



input		i_sw0			;

input		i_sw1			;

input		i_sw2			;

input		i_sw3			;



input		clk			;

input		rst_n			;



parameter	MODE_CLOCK	= 2'b00	;

parameter	MODE_SETUP	= 2'b01	;

parameter	MODE_ALARM	= 2'b10	;



parameter	POS_SEC		= 2'b00	;

parameter	POS_MIN		= 2'b01	;

parameter	POS_HOUR	= 2'b10	;



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



reg	[1:0]	o_position		;

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

reg		o_hour_clk		;

reg		o_alarm_sec_clk		;

reg		o_alarm_min_clk		;

reg		o_alarm_hour_clk	;

always @(*) begin

	case(o_mode)

		MODE_CLOCK : begin

			o_sec_clk = clk_1hz;

			o_min_clk = i_max_hit_sec;

			o_hour_clk = i_max_hit_min;

			o_alarm_sec_clk = 1'b0;

			o_alarm_min_clk = 1'b0;

			o_alarm_hour_clk = 1'b0;

		end

		MODE_SETUP : begin

			case(o_position)

				POS_SEC : begin

					o_sec_clk = ~sw2;

					o_min_clk = 1'b0;

					o_hour_clk = 1'b0;

					o_alarm_sec_clk = 1'b0;

					o_alarm_min_clk = 1'b0;

					o_alarm_hour_clk = 1'b0;

				end

				POS_MIN : begin

					o_sec_clk = 1'b0;

					o_min_clk = ~sw2;

					o_hour_clk = 1'b0;

					o_alarm_sec_clk = 1'b0;

					o_alarm_min_clk = 1'b0;

					o_alarm_hour_clk = 1'b0;

				end

				POS_HOUR : begin

					o_sec_clk = 1'b0;

					o_min_clk = 1'b0;

					o_hour_clk = ~sw2;

					o_alarm_sec_clk = 1'b0;

					o_alarm_min_clk = 1'b0;

					o_alarm_hour_clk = 1'b0;

				end

			endcase

		end

		MODE_ALARM : begin

			case(o_position)

				POS_SEC : begin

					o_sec_clk = clk_1hz;

					o_min_clk = i_max_hit_sec;

					o_hour_clk = i_max_hit_min;

					o_alarm_sec_clk = ~sw2;

					o_alarm_min_clk = 1'b0;

					o_alarm_hour_clk = 1'b0;

				end

				POS_MIN : begin

					o_sec_clk = clk_1hz;

					o_min_clk = i_max_hit_sec;

					o_hour_clk = i_max_hit_min;

					o_alarm_sec_clk = 1'b0;

					o_alarm_min_clk = ~sw2;

					o_alarm_min_clk = 1'b0;

				end

				POS_HOUR : begin

					o_sec_clk = clk_1hz;

					o_min_clk = i_max_hit_sec;

					o_hour_clk = i_max_hit_min;

					o_alarm_sec_clk = 1'b0;

					o_alarm_min_clk = 1'b0;

					o_alarm_hour_clk = ~sw2;

				end

			endcase

		end

		default: begin

			o_sec_clk = 1'b0;

			o_min_clk = 1'b0;

			o_hour_clk = 1'b0;

			o_alarm_sec_clk = 1'b0;

			o_alarm_min_clk = 1'b0;

			o_alarm_hour_clk = 1'b0;

		end

	endcase

end



endmodule



//	--------------------------------------------------

//	HMS(Hour:Min:Sec) Counter

//	--------------------------------------------------

module	hourminsec(	

		o_sec,

		o_min,

		o_hour,

		o_max_hit_sec,

		o_max_hit_min,

		o_max_hit_hour,

		o_alarm,

		i_mode,

		i_position,

		i_sec_clk,

		i_min_clk,

		i_hour_clk,

		i_alarm_sec_clk,

		i_alarm_min_clk,

		i_alarm_hour_clk,

		i_alarm_en,

		clk,

		rst_n);



output	[5:0]	o_sec		;

output	[5:0]	o_min		;

output	[5:0]	o_hour		;

output		o_max_hit_sec	;

output		o_max_hit_min	;

output		o_max_hit_hour	;

output		o_alarm		;



input	[1:0]	i_mode		;

input	[1:0]	i_position	;

input		i_sec_clk	;

input		i_min_clk	;

input		i_hour_clk	;

input		i_alarm_sec_clk	;

input		i_alarm_min_clk	;

input		i_alarm_hour_clk;

input		i_alarm_en	;



input		clk		;

input		rst_n		;



parameter	MODE_CLOCK	= 2'b00	;

parameter	MODE_SETUP	= 2'b01	;

parameter	MODE_ALARM	= 2'b10	;

parameter	POS_SEC		= 2'b00	;

parameter	POS_MIN		= 2'b01	;

parameter	POS_HOUR	= 2'b10	;



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



wire	[5:0]	hour		;

wire		max_hit_hour	;

hms_cnt		u_hms_cnt_hour(

		.o_hms_cnt	( hour			),

		.o_max_hit	( o_max_hit_hour	),

		.i_max_cnt	( 6'd23			),

		.clk		( i_hour_clk		),

		.rst_n		( rst_n			));



//	MODE_ALARM

wire	[5:0]	alarm_sec	;

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



wire	[5:0]	alarm_hour	;

hms_cnt		u_hms_cnt_alarm_hour(

		.o_hms_cnt	( alarm_hour		),

		.o_max_hit	( 			),

		.i_max_cnt	( 6'd23			),

		.clk		( i_alarm_hour_clk	),

		.rst_n		( rst_n			));



reg	[5:0]	o_sec		;

reg	[5:0]	o_min		;

reg	[5:0]	o_hour		;

always @ (*) begin

	case(i_mode)

		MODE_CLOCK: 	begin

			o_sec	= sec ;

			o_min	= min ;

			o_hour	= hour;

		end

		MODE_SETUP:	begin

			o_sec	= sec ;

			o_min	= min ;

			o_hour	= hour;

		end

		MODE_ALARM:	begin

			o_sec	= alarm_sec ;

			o_min	= alarm_min ;

			o_hour	= alarm_hour;

		end

	endcase

end



reg		o_alarm		;

always @ (posedge clk or negedge rst_n) begin

	if (rst_n == 1'b0) begin

		o_alarm <= 1'b0;

	end else begin

		if( (sec == alarm_sec) && (min == alarm_min) && (hour == alarm_hour) ) begin

			o_alarm <= 1'b1 & i_alarm_en;

		end else begin

			o_alarm <= o_alarm & i_alarm_en;

		end

	end

end



endmodule



//	--------------------------------------------------

//	Buzz

//	--------------------------------------------------

module	buzz(

		o_buzz,

		i_buzz_en,

		clk,

		rst_n);



output		o_buzz		;



input		i_buzz_en	;

input		clk		;

input		rst_n		;



parameter	C = 23889 ;

parameter	D = 21283 ;

parameter	E = 18961 ;

parameter	F = 17897 ;

parameter	G = 15944 ;

parameter	A = 14205 ;

parameter	B = 12655 ;

parameter	HC = 11944;

parameter	HD = 10641;

parameter	HE = 9480 ;

parameter	HF = 8948 ;

parameter	HG = 7972 ;

parameter	HA = 7102 ;

parameter	HB = 6327 ;

parameter	O = 1000  ;

/*parameter	C = 47778 ;

parameter	D = 42566 ;

parameter	E = 37922 ;

parameter	F = 35793 ;

parameter	G = 31888 ;

parameter	A = 28409 ;

parameter	B = 25310 ;

parameter	HC = 23889 ;

parameter	HD = 21283 ;

parameter	HE = 18961 ;

parameter	HF = 17897 ;

parameter	HG = 15944 ;

parameter	HA = 14205 ;

parameter	HB = 12655 ;

parameter	O = 1000  ;*/

/*parameter	C = 11944;

parameter	D = 10641;

parameter	E = 9480 ;

parameter	F = 8948 ;

parameter	G = 7972 ;

parameter	A = 7102 ;

parameter	B = 6327 ;

parameter	HC = 5975;

parameter	HD = 5325;

parameter	HE = 4746 ;

parameter	HF = 4482 ;

parameter	HG = 3994 ;

parameter	HA = 3560 ;

parameter	HB = 3173 ;

parameter	O = 1500   ;*/



wire		clk_bit		;

nco	u_nco_bit(	

		.o_gen_clk	( clk_bit	),

		.i_nco_num	( 25000000	),

		.clk		( clk		),

		.rst_n		( rst_n		));



reg	[6:0]	cnt		;

always @ (posedge clk_bit or negedge rst_n) begin

	if(rst_n == 1'b0) begin

		cnt <= 7'd0;

	end else begin

		if (cnt >= 7'd96) begin

			cnt <= 7'd0;

		end else begin

			if (i_buzz_en == 1'b1) begin

				cnt <= cnt + 1'b1;

			end

		end

	end

end



reg	[31:0]	nco_num		;

always @ (*) begin

	case(cnt)

		7'd00: nco_num = O	;

		7'd01: nco_num = E	;

		7'd02: nco_num = O	;

		7'd03: nco_num = G	;

		7'd04: nco_num = HD	;

		7'd05: nco_num = O	;

		7'd06: nco_num = O	;

		7'd07: nco_num = HC	;

		7'd08: nco_num = O	;

		7'd09: nco_num = G	;

		7'd10: nco_num = F	;

		7'd11: nco_num = O	;

		7'd12: nco_num = O	;

		7'd13: nco_num = E	;

		7'd14: nco_num = O	;

		7'd15: nco_num = E	;

		7'd16: nco_num = E	;

		7'd17: nco_num = F	;

		7'd18: nco_num = G	;

		7'd19: nco_num = A	;

		7'd20: nco_num = O	;

		7'd21: nco_num = O	;

		7'd22: nco_num = G	;

		7'd23: nco_num = O	;

		7'd24: nco_num = O	;

		7'd25: nco_num = E	;

		7'd26: nco_num = O	;

		7'd27: nco_num = G	;

		7'd28: nco_num = HD	;

		7'd29: nco_num = O	;

		7'd30: nco_num = O	;

		7'd31: nco_num = HC	;

		7'd32: nco_num = O	;

		7'd33: nco_num = G	;

		7'd34: nco_num = F	;

		7'd35: nco_num = O	;

		7'd36: nco_num = O	;

		7'd37: nco_num = E	;

		7'd38: nco_num = O	;

		7'd39: nco_num = G	;

		7'd40: nco_num = G	;

		7'd41: nco_num = A	;

		7'd42: nco_num = B	;

		7'd43: nco_num = HC	;

		7'd44: nco_num = O	;

		7'd45: nco_num = O	;

		7'd46: nco_num = HC	;

		7'd47: nco_num = O	;

		7'd48: nco_num = O	;

		7'd49: nco_num = HD	;

		7'd50: nco_num = O	;

		7'd51: nco_num = G	;

		7'd52: nco_num = B	;

		7'd53: nco_num = A	;

		7'd54: nco_num = G	;

		7'd55: nco_num = E	;

		7'd56: nco_num = O	;

		7'd57: nco_num = G	;

		7'd58: nco_num = HC	;

		7'd59: nco_num = O	;

		7'd60: nco_num = O	;

		7'd61: nco_num = A	;

		7'd62: nco_num = O	;

		7'd63: nco_num = HC	;

		7'd64: nco_num = HD	;

		7'd65: nco_num = O	;

		7'd66: nco_num = HC	;

		7'd67: nco_num = B	;

		7'd68: nco_num = O	;

		7'd69: nco_num = O	;

		7'd70: nco_num = G	;

		7'd71: nco_num = O	;

		7'd72: nco_num = O	;

		7'd73: nco_num = E	;

		7'd74: nco_num = O	;

		7'd75: nco_num = G	;

		7'd76: nco_num = HD	;

		7'd77: nco_num = O	;

		7'd78: nco_num = O	;

		7'd79: nco_num = HC	;

		7'd80: nco_num = O	;

		7'd81: nco_num = G	;

		7'd82: nco_num = F	;

		7'd83: nco_num = O	;

		7'd84: nco_num = O	;

		7'd85: nco_num = E	;

		7'd86: nco_num = O	;

		7'd87: nco_num = G	;

		7'd88: nco_num = G	;

		7'd89: nco_num = A	;

		7'd90: nco_num = B	;

		7'd91: nco_num = HC	;

		7'd92: nco_num = O	;

		7'd93: nco_num = O	;

		7'd94: nco_num = HC	;

		7'd95: nco_num = O	;

		7'd96: nco_num = O	;

	endcase

end



wire		buzz		;

nco	u_nco_buzz(	

		.o_gen_clk	( buzz		),

		.i_nco_num	( nco_num	),

		.clk		( clk		),

		.rst_n		( rst_n		));



assign		o_buzz = buzz & i_buzz_en & clk_bit;



endmodule



//	--------------------------------------------------

//	Top Module

//	--------------------------------------------------

module	top_hms_alarm(

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

output		o_seg_dp	;

output	[6:0]	o_seg		;

output		o_alarm		;



input		i_sw0		;

input		i_sw1		;

input		i_sw2		;

input		i_sw3		;

input		clk		;

input		rst_n		;



wire	[1:0]	o_mode_w	    ;

wire	[1:0]	o_position_w	    ;



wire		o_alarm_w	    ;

wire		o_alarm_en_w	    ;



wire		o_alarm_sec_clk_w   ;

wire		o_alarm_min_clk_w   ;

wire		o_alarm_hour_clk_w  ;



wire		o_sec_clk_w	    ;

wire		o_min_clk_w	    ;

wire		o_hour_clk_w	    ;



wire		o_max_hit_sec_w	    ;

wire		o_max_hit_min_w	    ;

wire		o_max_hit_hour_w    ;



wire	[5:0]   i_double_fig_sec_w  ;

wire	[5:0]   i_double_fig_min_w  ;

wire	[5:0]   i_double_fig_hour_w ;



wire	[3:0]   i_num_sec_1_w	    ;

wire	[3:0]   i_num_sec_2_w	    ;



wire	[3:0]   i_num_min_1_w	    ;

wire	[3:0]   i_num_min_2_w	    ;



wire	[3:0]   i_num_hour_1_w	    ;

wire	[3:0]   i_num_hour_2_w	    ;



/*wire	[6:0]	o_seg_w	    ;

wire		o_seg_dp_w	    ;

wire	[5:0]	o_seg_enb_w	    ;*/





wire	[6:0]	o_seg_sec_1_w	    ;

wire	[6:0]	o_seg_sec_2_w	    ;



wire	[6:0]	o_seg_min_1_w	    ;

wire	[6:0]	o_seg_min_2_w	    ;



wire	[6:0]	o_seg_hour_1_w	    ;

wire	[6:0]	o_seg_hour_2_w	    ;



wire	[41:0]	i_six_digit_seg_w   ;

assign          i_six_digit_seg_w = { o_seg_hour_1_w, o_seg_hour_2_w, o_seg_min_1_w, o_seg_min_2_w, o_seg_sec_1_w, o_seg_sec_2_w };



controller	u_controller( .o_mode		( o_mode_w	      ),

			      .o_position	( o_position_w	      ),

			      .o_alarm_en	( o_alarm_en_w        ),

			      .o_sec_clk	( o_sec_clk_w	      ),

			      .o_min_clk	( o_min_clk_w         ),

			      .o_hour_clk	( o_hour_clk_w        ),

			      .o_alarm_sec_clk  ( o_alarm_sec_clk_w   ),

			      .o_alarm_min_clk  ( o_alarm_min_clk_w   ),

			      .o_alarm_hour_clk ( o_alarm_hour_clk_w  ),

			      .i_max_hit_sec	( o_max_hit_sec_w     ),

			      .i_max_hit_min	( o_max_hit_min_w     ),

			      .i_max_hit_hour	( o_max_hit_hour_w    ),

			      .i_sw0		( i_sw0 	      ),

			      .i_sw1		( i_sw1 	      ),

			      .i_sw2		( i_sw2 	      ),

			      .i_sw3		( i_sw3 	      ),

			      .clk		( clk		      ),

			      .rst_n		( rst_n		      ));



hourminsec	u_hourminsec( .o_sec		( i_double_fig_sec_w  ),

			      .o_min		( i_double_fig_min_w  ),

			      .o_hour		( i_double_fig_hour_w ),

			      .o_max_hit_sec	( o_max_hit_sec_w     ),

			      .o_max_hit_min	( o_max_hit_min_w     ),

			      .o_max_hit_hour	( o_max_hit_hour_w    ),

			      .o_alarm		( o_alarm_w	      ),

			      .i_mode		( o_mode_w	      ),

			      .i_position	( o_position_w	      ),

			      .i_sec_clk	( o_sec_clk_w	      ),

			      .i_min_clk	( o_min_clk_w         ),

			      .i_hour_clk	( o_hour_clk_w        ),

			      .i_alarm_sec_clk  ( o_alarm_sec_clk_w   ),

			      .i_alarm_min_clk  ( o_alarm_min_clk_w   ),

			      .i_alarm_hour_clk ( o_alarm_hour_clk_w  ),

			      .i_alarm_en	( o_alarm_en_w        ),

			      .clk		( clk		      ),

		 	      .rst_n		( rst_n		      ));



double_fig_sep	      u0_dfs( .o_left		( i_num_sec_1_w	       ),

			      .o_right		( i_num_sec_2_w	       ),

			      .i_double_fig	( i_double_fig_sec_w   ));



double_fig_sep	      u1_dfs( .o_left		( i_num_min_1_w	       ),

			      .o_right		( i_num_min_2_w	       ),

			      .i_double_fig	( i_double_fig_min_w   ));



double_fig_sep	      u2_dfs( .o_left	     	( i_num_hour_1_w       ),

			      .o_right	  	( i_num_hour_2_w       ),

			      .i_double_fig     ( i_double_fig_hour_w  ));



fnd_dec		  u0_fnd_dec( .o_seg	     	( o_seg_sec_1_w        ),

		              .i_num	     	( i_num_sec_1_w        ));



fnd_dec		  u1_fnd_dec( .o_seg	     	( o_seg_sec_2_w        ),

		              .i_num	     	( i_num_sec_2_w        ));



fnd_dec		  u2_fnd_dec( .o_seg	     	( o_seg_min_1_w        ),

		              .i_num	     	( i_num_min_1_w        ));



fnd_dec		  u3_fnd_dec( .o_seg	     	( o_seg_min_2_w        ),

		              .i_num	     	( i_num_min_2_w        ));



fnd_dec		  u4_fnd_dec( .o_seg	     	( o_seg_hour_1_w       ),

			      .i_num	    	( i_num_hour_1_w       ));



fnd_dec		  u5_fnd_dec( .o_seg	     	( o_seg_hour_2_w       ),

			      .i_num	    	( i_num_hour_2_w       ));



led_disp	  u_led_disp( .o_seg		( o_seg	       ),

			      .o_seg_dp	        ( o_seg_dp	       ),

			      .o_seg_enb	( o_seg_enb 	       ),

			      .i_six_digit_seg  ( i_six_digit_seg_w    ),

			      .i_six_dp		( o_mode_w	       ),

			      .clk		( clk		       ),

			      .rst_n		( rst_n		       ));



/*led_disp_blink   u_led_disp_blink( .o_seg	( o_seg		       ),

			      .o_seg_dp	        ( o_seg_dp	       ),

			      .o_seg_enb	( o_seg_enb	       ),

			      .i_seg		( o_seg_w	       ),

			      .i_seg_dp	        ( o_seg_dp_w	       ),

			      .i_seg_enb	( o_seg_enb_w	       ),

			      .clk		( clk		       ),

			      .rst_n		( rst_n		       ));*/



buzz		      u_buzz( .o_buzz		( o_alarm	       ),

			      .i_buzz_en	( o_alarm_w	       ),

			      .clk		( clk		       ),

		  	      .rst_n		( rst_n		       ));





endmodule


