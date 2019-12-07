//	==================================================
//	Copyright (c) 2019 Sookmyung Women's University.
//	--------------------------------------------------
//	FILE 			: practice07.v
//	DEPARTMENT		: EE
//	AUTHOR			: WOONG CHOI
//	EMAIL			: woongchoi@sookmyung.ac.kr
//	--------------------------------------------------
//	RELEASE HISTORY
//	--------------------------------------------------
//	VERSION			DATE
//	0.0			2019-11-09
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
 		4'd0 : o_seg = 7'b111_1110	; 
 		4'd1 : o_seg = 7'b011_0000	; 
 		4'd2 : o_seg = 7'b110_1101	; 
 		4'd3 : o_seg = 7'b111_1001	; 
 		4'd4 : o_seg = 7'b011_0011	; 
 		4'd5 : o_seg = 7'b101_1011	; 
 		4'd6 : o_seg = 7'b101_1111	; 
 		4'd7 : o_seg = 7'b111_0000	; 
 		4'd8 : o_seg = 7'b111_1111	; 
 		4'd9 : o_seg = 7'b111_0011	; 
		default : o_seg = 7'b000_0000	; 
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
// 	Add Blink ( Set up MODE & Alarm Mode )
//	--------------------------------------------------
module	led_disp(
		o_seg,
		o_seg_dp,
		o_seg_enb,
		i_six_digit_seg,
		i_six_dp,
		i_mode,
		i_position,
		clk,
		rst_n);

output	[5:0]	o_seg_enb		;
output		o_seg_dp		;
output	[6:0]	o_seg			;

input	[41:0]	i_six_digit_seg		;
input	[5:0]	i_six_dp		;
input	[2:0]	i_mode			;
input	[1:0]	i_position		;
input		clk			;
input		rst_n			;

wire		gen_clk			;
wire		blink_clk		;
		

nco		u_nco0(
		.o_gen_clk	( gen_clk	),
		.i_nco_num	( 32'd5000	),//10000Hz
		.clk		( clk		),
		.rst_n		( rst_n		));

nco		u_nco1(
		.o_gen_clk	( blink_clk	),
		.i_nco_num	( 32'd25000000	),//25Hz
		.clk		( clk		),
		.rst_n		( rst_n		));


reg	[3:0]	cnt_common_node	;

always @(posedge gen_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cnt_common_node <= 4'd0;
	end else begin
		if(cnt_common_node >= 4'd5) begin
			cnt_common_node <= 4'd0;
		end else begin
			cnt_common_node <= cnt_common_node + 1'b1;
		end
	end
end

reg	  	blink		; // 7_segment_ led display 
always @(posedge blink_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
 		blink <= 1'd0	;
 	end else begin
  		blink <= ~blink	;
	end
end

reg 	[5:0] 	o_seg_enb  	;



always @(i_mode, i_position, blink, o_seg_enb, cnt_common_node) begin
	if (i_mode == 3'b001 || i_mode == 3'b010 || i_mode == 3'b100 ) begin
 		if ( (blink == 1'b0) && (i_position == 2'b00) ) begin 
 			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
  				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b1) && (i_position == 2'b00) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111111;
  				4'd1: o_seg_enb = 6'b111111;
  				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
 				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b0) && (i_position == 2'b01) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
  				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b1) && (i_position == 2'b01) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
  				4'd2: o_seg_enb = 6'b111111;
  				4'd3: o_seg_enb = 6'b111111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b0) && (i_position == 2'b10) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
 				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b101111;
  				4'd5: o_seg_enb = 6'b011111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end else if( ( blink == 1'b1) && (i_position == 2'b10) ) begin
			case (cnt_common_node)
  				4'd0: o_seg_enb = 6'b111110;
  				4'd1: o_seg_enb = 6'b111101;
  				4'd2: o_seg_enb = 6'b111011;
  				4'd3: o_seg_enb = 6'b110111;
  				4'd4: o_seg_enb = 6'b111111;
  				4'd5: o_seg_enb = 6'b111111;
  				default:o_seg_enb = 6'b111111;
 			endcase
		end
	end else begin
		case (cnt_common_node)
  			4'd0: o_seg_enb = 6'b111110;
  			4'd1: o_seg_enb = 6'b111101;
  			4'd2: o_seg_enb = 6'b111011;
  			4'd3: o_seg_enb = 6'b110111;
  			4'd4: o_seg_enb = 6'b101111;
  			4'd5: o_seg_enb = 6'b011111;
  			default:o_seg_enb = 6'b111111;
 		endcase
	end
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
	endcase
end

endmodule

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) UP Counter
//	--------------------------------------------------
module	hms_cnt(
		o_hms_cnt,
		o_max_hit,
		i_max_cnt,
		clk,
		rst_n);


output	[5:0]	o_hms_cnt	;
output			o_max_hit	;

input	[5:0]	i_max_cnt	;
input		clk			;
input		rst_n		;

reg	[5:0]	o_hms_cnt		;
reg			o_max_hit		;

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
/// reset module // 
module	reset(
		o_hms_cnt,
		o_max_hit,
		clk,
		rst_n);

output	[5:0]	o_hms_cnt	;
output			o_max_hit	;


input		clk			;
input		rst_n		;

hms_cnt		reset_hms_cnt( .o_hms_cnt	( 6'd0 ),
						   .o_max_hit	( 6'd0 ),
						   .i_max_cnt	(),
						   .clk			( clk  ),
					       .rst_n		( rst_n ));

endmodule

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) DOWN Counter
//	--------------------------------------------------
module	hms_dcnt(
		o_hms_dcnt,
		o_min_hit,
		i_hms_dcnt,
		i_max_cnt,
		clk,
		rst_n);

output	[5:0]	o_hms_dcnt		;
output		o_min_hit		;

input	[5:0]	i_hms_dcnt		;
input	[5:0]	i_max_cnt		;
input		clk			;
input		rst_n			;


reg	[5:0]	o_hms_dcnt		;
reg		o_min_hit		;

always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_hms_dcnt <= 6'd0;
		o_min_hit <= 1'b0;
	end else begin
		if(o_hms_dcnt <= 6'd0) begin
			o_hms_dcnt <= i_max_cnt;
			o_min_hit <= 1'b1;
		end else begin
			o_hms_dcnt <= i_hms_dcnt;
			o_hms_dcnt <= o_hms_dcnt - 1'b1;
			o_min_hit <= 1'b0;
		end
	end
end

endmodule

//	--------------------------------------------------
//	Debounce
//	--------------------------------------------------
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
		o_timer_r,
		o_timer_ss,
		o_sec_clk,
		o_min_clk,
		o_hour_clk,
		o_alarm_sec_clk,
		o_alarm_min_clk,
		o_alarm_hour_clk,
		o_timer_up_sec_clk,
		o_timer_up_min_clk,
		o_timer_up_hour_clk,
		o_timer_downs_sec_clk,				
		o_timer_downs_min_clk,
		o_timer_downs_hour_clk,
		o_timer_down_sec_clk,				
		o_timer_down_min_clk,
		o_timer_down_hour_clk,
		i_max_hit_sec,
		i_max_hit_min,
		i_max_hit_hour,
		i_max_hit_sec_timer,
		i_max_hit_min_timer,
		i_max_hit_hour_timer,
		i_min_hit_sec_timer,
		i_min_hit_min_timer,
		i_min_hit_hour_timer,
		i_sw0,
		i_sw1,
		i_sw2,
		i_sw3,
		i_sw4,
		i_sw5,
		clk,
		rst_n);


output	[2:0]	o_mode			;
output	[1:0]	o_position		;

output		o_alarm_en		;

output		o_timer_r		;
output		o_timer_ss		;

output		o_sec_clk		;
output		o_min_clk		;
output		o_hour_clk		;

output		o_alarm_sec_clk		;
output		o_alarm_min_clk		;
output		o_alarm_hour_clk	;

output		o_timer_up_sec_clk	;	
output		o_timer_up_min_clk	;
output		o_timer_up_hour_clk	;

output		o_timer_downs_sec_clk	;		
output		o_timer_downs_min_clk	;
output		o_timer_downs_hour_clk	;

output		o_timer_down_sec_clk	;		
output		o_timer_down_min_clk	;
output		o_timer_down_hour_clk	;

input		i_max_hit_sec		;
input		i_max_hit_min		;
input		i_max_hit_hour		;

input		i_max_hit_sec_timer	;
input		i_max_hit_min_timer	;
input		i_max_hit_hour_timer	;

input		i_min_hit_sec_timer	;
input		i_min_hit_min_timer	;
input		i_min_hit_hour_timer	;

input		i_sw0			;
input		i_sw1			;
input		i_sw2			;
input		i_sw3			;
input		i_sw4			;
input		i_sw5			;

input		clk			;
input		rst_n			;

parameter	MODE_CLOCK	= 3'b000;
parameter	MODE_SETUP	= 3'b001;
parameter	MODE_ALARM	= 3'b010;
parameter	MODE_TIMER_UP	= 3'b011;
parameter	MODE_TIMER_DOWN_S= 3'b100;
parameter	MODE_TIMER_DOWN	= 3'b101;

parameter	POS_SEC		= 2'b00	;
parameter	POS_MIN		= 2'b01	;
parameter	POS_HOUR	= 2'b10	;

parameter	TIMER_RESET	= 1'b1	;

parameter	TIMER_STOP	= 1'b0	;
parameter	TIMER_START	= 1'b1	;


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

wire		sw4			;
debounce	u4_debounce(
		.o_sw		( sw4		),
		.i_sw		( i_sw4		),
		.clk		( clk_100hz	));

wire		sw5			;
debounce	u5_debounce(
		.o_sw		( sw5		),
		.i_sw		( i_sw5		),
		.clk		( clk_100hz	));




reg	[2:0]	o_mode			;
always @(posedge sw0 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_mode <= MODE_CLOCK;
	end else begin
		if(o_mode >= MODE_TIMER_DOWN) begin
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
		if(o_position >= POS_HOUR) begin
			o_position <= POS_SEC;
		end else begin
			o_position <= o_position + 1'b1;
		end
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

reg		o_timer_r		;	
always @(posedge sw4 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_timer_r <= 1'b0;
	end else begin
		if(o_timer_r >= TIMER_RESET) begin
			o_timer_r <= 1'b0;
		end else begin
			o_timer_r <= o_timer_r + 1'b1;
		end
	end
end 

reg		o_timer_ss		;	
always @(posedge sw5 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_timer_ss <= TIMER_STOP;
	end else begin
		if(o_timer_ss >= TIMER_START) begin
			o_timer_ss <= TIMER_STOP;
		end else begin
			o_timer_ss <= o_timer_ss + 1'b1;
		end
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

reg		o_timer_up_sec_clk	;
reg		o_timer_up_min_clk	;
reg		o_timer_up_hour_clk	;

reg		o_timer_down_sec_clk	;		
reg		o_timer_down_min_clk	;
reg		o_timer_down_hour_clk	;


always @(*) begin
	case(o_mode)
		MODE_CLOCK : begin
			o_sec_clk = clk_1hz;
			o_min_clk = i_max_hit_sec;
			o_hour_clk = i_max_hit_min;
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
			o_alarm_hour_clk = 1'b0;
			o_timer_up_sec_clk = 1'b0;		
			o_timer_up_min_clk = 1'b0;
			o_timer_up_hour_clk = 1'b0;
			o_timer_down_sec_clk = 1'b0;		
			o_timer_down_min_clk = 1'b0;
			o_timer_down_hour_clk = 1'b0;
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
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk = 1'b0;
					o_min_clk = ~sw2;
					o_hour_clk = 1'b0;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
				end
				POS_HOUR : begin
					o_sec_clk = 1'b0;
					o_min_clk = 1'b0;
					o_hour_clk = ~sw2;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
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
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = ~sw2;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
				end
				POS_HOUR : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = ~sw2;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
				end
			endcase
		end
		MODE_TIMER_UP : begin	
						
			case(o_timer_r)
				TIMER_RESET : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;				
				end			
			endcase
			case(o_timer_ss)
				TIMER_START : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = clk_1hz;		
					o_timer_up_min_clk = i_max_hit_sec_timer;
					o_timer_up_hour_clk = i_max_hit_min_timer;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;				
				end
				TIMER_STOP : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;			
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk =  1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;				
				end
			endcase
		end
		MODE_TIMER_DOWN_S : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = ~sw2;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = ~sw2;
					o_timer_down_hour_clk = 1'b0;
				end
				POS_HOUR : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = ~sw2;
				end
			endcase
		end	
		MODE_TIMER_DOWN : begin			
			case(o_position)
				POS_SEC : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = clk_1hz;		
					o_timer_down_min_clk = i_min_hit_sec_timer;
					o_timer_down_hour_clk = i_min_hit_min_timer;
				end
				POS_MIN : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = clk_1hz;		
					o_timer_down_min_clk = i_min_hit_sec_timer;
					o_timer_down_hour_clk =i_min_hit_min_timer;
				end
				POS_HOUR : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = clk_1hz;		
					o_timer_down_min_clk = i_min_hit_sec_timer;
					o_timer_down_hour_clk = i_min_hit_min_timer;
				end
			endcase
			case(o_timer_r)
				TIMER_RESET : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;
				end
			endcase
			case(o_timer_ss)
				TIMER_START : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk = 1'b0;
					o_timer_down_sec_clk = clk_1hz;			
					o_timer_down_min_clk = i_min_hit_sec_timer;
					o_timer_down_hour_clk = i_min_hit_min_timer;
				end
				TIMER_STOP : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_timer_up_sec_clk = 1'b0;		
					o_timer_up_min_clk = 1'b0;
					o_timer_up_hour_clk =  1'b0;
					o_timer_down_sec_clk = 1'b0;		
					o_timer_down_min_clk = 1'b0;
					o_timer_down_hour_clk = 1'b0;		
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
			o_timer_up_sec_clk = 1'b0;		
			o_timer_up_min_clk = 1'b0;
			o_timer_up_hour_clk = 1'b0;
			o_timer_down_sec_clk = 1'b0;		
			o_timer_down_min_clk = 1'b0;
			o_timer_down_hour_clk = 1'b0;
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
		o_max_hit_sec_timer,
		o_max_hit_min_timer,
		o_max_hit_hour_timer,
		o_min_hit_sec_timer,
		o_min_hit_min_timer,
		o_min_hit_hour_timer,
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
		i_timer_up_sec_clk,			
		i_timer_up_min_clk,
		i_timer_up_hour_clk,
		i_timer_down_sec_clk,			
		i_timer_down_min_clk,
		i_timer_down_hour_clk,
		i_timer_r,
		i_timer_ss,
		clk,
		rst_n);

output	[5:0]	o_sec		;
output	[5:0]	o_min		;
output	[5:0]	o_hour		;

output		o_max_hit_sec	;
output		o_max_hit_min	;
output		o_max_hit_hour	;

output		o_max_hit_sec_timer	;
output		o_max_hit_min_timer	;
output		o_max_hit_hour_timer	;

output		o_min_hit_sec_timer	;
output		o_min_hit_min_timer	;
output		o_min_hit_hour_timer	;

output		o_alarm		;

input	[2:0]	i_mode		;
input	[1:0]	i_position	;

input		i_sec_clk	;
input		i_min_clk	;
input		i_hour_clk	;

input		i_alarm_sec_clk	;
input		i_alarm_min_clk	;
input		i_alarm_hour_clk;

input		i_timer_up_sec_clk	;			
input		i_timer_up_min_clk	;
input		i_timer_up_hour_clk	;

input		i_timer_down_sec_clk	;			
input		i_timer_down_min_clk	;
input		i_timer_down_hour_clk	;

input		i_alarm_en		;

input		i_timer_r		;
input		i_timer_ss		;	

input		clk		;
input		rst_n		;

parameter	MODE_CLOCK	= 3'b000;
parameter	MODE_SETUP	= 3'b001;
parameter	MODE_ALARM	= 3'b010;
parameter	MODE_TIMER_UP	= 3'b011;		
parameter	MODE_TIMER_DOWN_S= 3'b100;
parameter	MODE_TIMER_DOWN= 3'b101;

parameter	POS_SEC		= 2'b00	;
parameter	POS_MIN		= 2'b01	;
parameter	POS_HOUR	= 2'b10	;

parameter	TIMER_RESET	= 1'b1	;


parameter	TIMER_STOP	= 1'b0	;
parameter	TIMER_START	= 1'b1	;


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

//	MODE_TIMER_UP					
wire	[5:0]	timer_up_sec	 ;
wire		max_hit_sec_timer;
hms_cnt		u_hms_cnt_timer_up_sec(
		.o_hms_cnt	( timer_up_sec		),
		.o_max_hit	( o_max_hit_sec_timer	),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_up_sec_clk	),
		.rst_n		( rst_n			));

reset		u_reset_timer_up_sec(
		.o_hms_cnt  ( ,
		o_max_hit,
		clk,
		rst_n);

wire	[5:0]	timer_up_min	 ;
wire		max_hit_min_timer;
hms_cnt		u_hms_cnt_timer_up_min(
		.o_hms_cnt	( timer_up_min		),
		.o_max_hit	( o_max_hit_min_timer	),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_up_min_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	timer_up_hour	  ;
wire		max_hit_hour_timer;
hms_cnt		u_hms_cnt_timer_up_hour(
		.o_hms_cnt	( timer_up_hour		),
		.o_max_hit	( o_max_hit_hour_timer  ),
		.i_max_cnt	( 6'd23			),
		.clk		( i_timer_up_hour_clk	),
		.rst_n		( rst_n			));

//	MODE_TIMER_DOWN_S
wire	[5:0]	timer_down_sec	 	;
hms_dcnt	u_hms_cnt_timer_downs_sec(			
		.o_hms_dcnt	( timer_down_sec 	),		
		.o_max_hit	( 			),
		.i_hms_cnt	( ),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_down_sec_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	timer_down_min		;
hms_dcnt	u_hms_cnt_timer_downs_min(
		.o_hms_dcnt	( timer_down_min	),
		.o_max_hit	( 			),
		.i_hms_cnt	( ),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_down_min_clk	),
		.rst_n		( rst_n			));

wire	[5:0]	timer_down_hour		;
hms_dcnt	u_hms_cnt_timer_downs_hour(
		.o_hms_dcnt	( timer_down_hour	),
		.o_max_hit	( 			),
		.i_hms_cnt	( ),
		.i_max_cnt	( 6'd23			),
		.clk		( i_timer_down_hour_clk),
		.rst_n		( rst_n			));

//	MODE_TIMER_DOWN
wire		min_hit_sec_timer	;
wire	[5:0]	timer_down_sec2	 	;
hms_dcnt	u_hms_dcnt_timer_down_sec(			
		.o_hms_dcnt	( timer_down_sec2 	),		
		.o_min_hit	( o_min_hit_sec_timer	),
		.i_hms_dcnt	( timer_down_sec	),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_down_sec_clk	),
		.rst_n		( rst_n			));

wire		min_hit_min_timer	;
wire	[5:0]	timer_down_min2		;
hms_dcnt	u_hms_dcnt_timer_down_min(
		.o_hms_dcnt	( timer_down_min2	),
		.o_min_hit	( o_min_hit_min_timer	),
		.i_hms_dcnt	( timer_down_min	),
		.i_max_cnt	( 6'd59			),
		.clk		( i_timer_down_min_clk	),
		.rst_n		( rst_n			));

wire		min_hit_hour_timer	;
wire	[5:0]	timer_down_hour2		;
hms_dcnt	u_hms_dcnt_timer_down_hour(
		.o_hms_dcnt	( timer_down_hour2	),
		.o_min_hit	( o_min_hit_hour_timer	),
		.i_hms_dcnt	( timer_down_hour	),
		.i_max_cnt	( 6'd23			),
		.clk		( i_timer_down_hour_clk),
		.rst_n		( rst_n			));

reg	[5:0]	o_sec		;
reg	[5:0]	o_min		;
reg	[5:0]	o_hour		;

always @ (i_mode, i_timer_r, o_sec, o_min, o_hour) begin
	
	if (i_timer_r == TIMER_RESET) begin
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
			MODE_TIMER_UP:	  begin				
				o_sec	= 0 ;
				o_min	= 0 ;
				o_hour	= 0 ;
			end
			MODE_TIMER_DOWN_S:  begin				
				o_sec	= 0 ;
				o_min	= 0 ;
				o_hour	= 0 ;
			end
			MODE_TIMER_DOWN:  begin				
				o_sec	= 0 ; 
				o_min	= 0 ;
				o_hour	= 0 ;
			end
		endcase
	end else begin
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
			MODE_TIMER_UP:	  begin				
				o_sec	= timer_up_sec ;
				o_min	= timer_up_min ;
				o_hour	= timer_up_hour;
			end
			MODE_TIMER_DOWN_S:  begin				
				o_sec	= timer_down_sec ;
				o_min	= timer_down_min ;
				o_hour	= timer_down_hour;
			end
			MODE_TIMER_DOWN:  begin				
				o_sec	= timer_down_sec2 ; 
				o_min	= timer_down_min2 ;
				o_hour	= timer_down_hour2;
			end
		endcase
	end
		
end

reg		o_alarm		;
always @ (posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		o_alarm <= 1'b0;
	end else begin			
		if( ((sec == alarm_sec) && (min == alarm_min) && (hour == alarm_hour)) ) begin
			o_alarm <= 1'b1 & i_alarm_en;
		end else begin
			o_alarm <= o_alarm & i_alarm_en;
		end
	end
end


always @ (posedge clk or negedge rst_n) begin
	if ((timer_down_sec2 == 6'd0) && (timer_down_min2 == 6'd0) && (timer_down_hour2 == 6'd0)) begin
			i_timer_down_sec_clk = 1'b0;
			i_timer_down_min_clk = 1'b0;
			i_timer_down_hour_clk = 1'b0;
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
	default  : nco_num = 32'd0 ; 
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
module	top_hms_clock(
		o_seg_enb,
		o_seg_dp,
		o_seg,
		o_alarm,
		i_sw0,
		i_sw1,
		i_sw2,
		i_sw3,
		i_sw4,
		i_sw5,
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
input		i_sw4		;
input		i_sw5		;

input		clk		;
input		rst_n		;

wire	[2:0]	o_mode		;
wire	[1:0]	o_position	;

wire		o_alarm_w	;
wire		o_alarm_en	;

wire		o_timer_r	;
wire		o_timer_ss	;		

wire		o_sec_clk	;
wire		o_min_clk	;
wire		o_hour_clk	;

wire		o_alarm_sec_clk	;
wire		o_alarm_min_clk	;
wire		o_alarm_hour_clk;

wire		o_timer_up_sec_clk ;		
wire		o_timer_up_min_clk ;
wire		o_timer_up_hour_clk;

wire		o_timer_down_sec_clk ;		
wire		o_timer_down_min_clk ;
wire		o_timer_down_hour_clk;

wire		o_max_hit_sec	;
wire		o_max_hit_min	;
wire		o_max_hit_hour	;

wire		o_max_hit_sec_timer	;
wire		o_max_hit_min_timer	;
wire		o_max_hit_hour_timer	;

wire		o_min_hit_sec_timer	;
wire		o_min_hit_min_timer	;
wire		o_min_hit_hour_timer	;

wire	[5:0]	o_sec		;
wire	[5:0]	o_min		;
wire	[5:0]	o_hour		;

wire	[3:0]	o_sec1		;
wire	[3:0]	o_sec2		;

wire	[3:0]	o_min1		;
wire	[3:0]	o_min2		;

wire	[3:0]	o_hour1	;
wire	[3:0]	o_hour2	;

wire	[6:0]	o_seg_sec1	;
wire	[6:0]	o_seg_sec2	;
wire	[6:0]	o_seg_min1	;
wire	[6:0]	o_seg_min2	;
wire	[6:0]	o_seg_hour1	;
wire	[6:0]	o_seg_hour2	;


wire	[41:0]	six_digit_seg	;

assign		six_digit_seg = { o_seg_hour1, o_seg_hour2, o_seg_min1, o_seg_min2, o_seg_sec1, o_seg_sec2 } ;
	

controller	u_controller( .o_mode		     ( o_mode	   	      ),
			      .o_position	     ( o_position	      ),
			      .o_alarm_en	     ( o_alarm_en	      ),
			      .o_timer_r	     ( o_timer_r       	      ),
			      .o_timer_ss	     ( o_timer_ss             ),
			      .o_sec_clk	     ( o_sec_clk      	      ),
			      .o_min_clk	     ( o_min_clk              ),
			      .o_hour_clk	     ( o_hour_clk             ),
			      .o_alarm_sec_clk       ( o_alarm_sec_clk        ),
			      .o_alarm_min_clk       ( o_alarm_min_clk        ),
			      .o_alarm_hour_clk      ( o_alarm_hour_clk       ),
			      .o_timer_up_sec_clk    ( o_timer_up_sec_clk     ),			
			      .o_timer_up_min_clk    ( o_timer_up_min_clk     ),
			      .o_timer_up_hour_clk   ( o_timer_up_hour_clk    ),
			      .o_timer_downs_sec_clk  ( o_timer_downs_sec_clk   ),			
			      .o_timer_downs_min_clk  ( o_timer_downs_min_clk   ),
			      .o_timer_downs_hour_clk ( o_timer_downs_hour_clk  ),
			      .o_timer_down_sec_clk  ( o_timer_down_sec_clk   ),			
			      .o_timer_down_min_clk  ( o_timer_down_min_clk   ),
			      .o_timer_down_hour_clk ( o_timer_down_hour_clk  ),
			      .i_max_hit_sec	     ( o_max_hit_sec          ),
			      .i_max_hit_min	     ( o_max_hit_min          ),
			      .i_max_hit_hour	     ( o_max_hit_hour         ),
			      .i_max_hit_sec_timer   ( o_max_hit_sec_timer    ),
			      .i_max_hit_min_timer   ( o_max_hit_min_timer    ),
			      .i_max_hit_hour_timer  ( o_max_hit_hour_timer   ),
			      .i_min_hit_sec_timer   ( o_min_hit_sec_timer    ),  				
			      .i_min_hit_min_timer   ( o_min_hit_min_timer    ),
			      .i_min_hit_hour_timer  ( o_min_hit_hour_timer   ),
			      .i_sw0		     ( i_sw0 	      	      ),
			      .i_sw1		     ( i_sw1 	      	      ),
			      .i_sw2		     ( i_sw2 	      	      ),
			      .i_sw3		     ( i_sw3 	      	      ),
			      .i_sw4		     ( i_sw4 	      	      ),
			      .i_sw5		     ( i_sw5 	      	      ),
			      .clk		     ( clk		      ),
			      .rst_n		     ( rst_n		      ));

hourminsec	u_hourminsec( .o_sec		     ( o_sec		      ),
			      .o_min		     ( o_min		      ),
			      .o_hour		     ( o_hour 		      ),
			      .o_max_hit_sec	     ( o_max_hit_sec          ),
			      .o_max_hit_min	     ( o_max_hit_min          ),
			      .o_max_hit_hour	     ( o_max_hit_hour         ),
			      .o_max_hit_sec_timer   ( o_max_hit_sec_timer    ),
			      .o_max_hit_min_timer   ( o_max_hit_min_timer    ),
			      .o_max_hit_hour_timer  ( o_max_hit_hour_timer   ),
			      .o_min_hit_sec_timer   ( o_min_hit_sec_timer    ),		
			      .o_min_hit_min_timer   ( o_min_hit_min_timer    ),
			      .o_min_hit_hour_timer  ( o_min_hit_hour_timer   ),
			      .o_alarm		     ( o_alarm_w	      ),
			      .i_mode		     ( o_mode	    	      ),
			      .i_position	     ( o_position	      ),
			      .i_sec_clk	     ( o_sec_clk	      ),
			      .i_min_clk	     ( o_min_clk              ),
			      .i_hour_clk	     ( o_hour_clk             ),
			      .i_alarm_sec_clk       ( o_alarm_sec_clk        ),
			      .i_alarm_min_clk       ( o_alarm_min_clk        ),
			      .i_alarm_hour_clk      ( o_alarm_hour_clk       ),
			      .i_alarm_en	     ( o_alarm_en             ),
			      .i_timer_up_sec_clk    ( o_timer_up_sec_clk     ),
			      .i_timer_up_min_clk    ( o_timer_up_min_clk     ),
			      .i_timer_up_hour_clk   ( o_timer_up_hour_clk    ),
			      .i_timer_down_sec_clk  ( o_timer_down_sec_clk   ),
			      .i_timer_down_min_clk  ( o_timer_down_min_clk   ),
			      .i_timer_down_hour_clk ( o_timer_down_hour_clk  ),
			      .i_timer_r	     ( o_timer_r              ),
			      .i_timer_ss	     ( o_timer_ss             ),
			      .clk		     ( clk		      ),
		 	      .rst_n		     ( rst_n		      ));


double_fig_sep	      u0_dfs( .o_left		     ( o_sec1		      ),
			      .o_right	     	     ( o_sec2		      ),
			      .i_double_fig	     ( o_sec		      ));

double_fig_sep	      u1_dfs( .o_left		     ( o_min1		      ),
			      .o_right	     	     ( o_min2		      ),
			      .i_double_fig	     ( o_min		      ));

double_fig_sep	      u2_dfs( .o_left		     ( o_hour1	              ),
			      .o_right	     	     ( o_hour2	              ),
			      .i_double_fig	     ( o_hour		      ));

fnd_dec		  u0_fnd_dec( .o_seg		     ( o_seg_sec1	      ),
			      .i_num		     ( o_sec1		      ));

fnd_dec		  u1_fnd_dec( .o_seg		     ( o_seg_sec2	      ),
			      .i_num		     ( o_sec2		      ));

fnd_dec		  u2_fnd_dec( .o_seg		     ( o_seg_min1	      ),
			      .i_num		     ( o_min1		      ));

fnd_dec		  u3_fnd_dec( .o_seg		     ( o_seg_min2	      ),
			      .i_num		     ( o_min2		      ));

fnd_dec		  u4_fnd_dec( .o_seg		     ( o_seg_hour1	      ),
			      .i_num		     ( o_hour1	      	      ));

fnd_dec		  u5_fnd_dec( .o_seg		     ( o_seg_hour2	      ),
			      .i_num		     ( o_hour2	              ));


led_disp	  u_led_disp( .o_seg		     ( o_seg 		      ),
			      .o_seg_dp	     	     ( o_seg_dp 	      ),
			      .o_seg_enb	     ( o_seg_enb 	      ),
			      .i_six_digit_seg       ( six_digit_seg	      ),
			      .i_six_dp	       	     ( o_mode		      ),
			      .i_mode		     ( o_mode		      ),
			      .i_position	     ( o_position	      ),
			      .clk		     ( clk		      ),
			      .rst_n		     ( rst_n		      ));


buzz		      u_buzz( .o_buzz		     ( o_alarm		      ),
			      .i_buzz_en	     ( o_alarm_w	      ),
			      .clk		     ( clk		      ),
			      .rst_n		     ( rst_n		      ));

endmodule