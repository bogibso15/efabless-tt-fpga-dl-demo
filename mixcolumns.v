\m5_TLV_version 1d: tl-x.org
\m5
   
   // =================================================
   // Welcome!  New to Makerchip? Try the "Learn" menu.
   // =================================================
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   |mixcolumn
      @0
         $reset = *reset;
         $rst_low = !$reset && >>1$reset;
         $block_in[127:0] = 128'ha7be1a6997ad739bd8c9ca451f618b61;
         $const_matrix[127:0] = 128'h02030101010203010101020303010102;

         /xx[3:0]
            /yy[3:0]
               $ss[7:0] = |mixcolumn$block_in[(#yy * 8 + #xx * 32) + 7 : (#yy * 8 + #xx * 32)];
               $cc[7:0] = |mixcolumn$const_matrix[(#yy * 32 + #xx * 8) + 7 : (#yy * 32 + #xx * 8)];
               /exp[3:0]
                  ///xx[#xx]/yy[#exp]$ss * /xx[#exp]/yy[#yy]$cc
                  $reduce_check[7:0] = (/xx[#xx]/yy[#exp]$ss[7] == 1) && (/xx[#exp]/yy[#yy]$cc != 8'h01) ? 8'h1b : 8'h00;
                  $three_check[7:0] = /xx[#exp]/yy[#yy]$cc == 8'h03 ? /xx[#xx]/yy[#exp]$ss : 8'h00;
                  $op[7:0] = /xx[#exp]/yy[#yy]$cc == 8'h01 ? /xx[#xx]/yy[#exp]$ss : ((/xx[#xx]/yy[#exp]$ss << 1) ^ $three_check ^ $reduce_check);
                  
               $oo[7:0] = /exp[0]$op ^ /exp[1]$op ^ /exp[2]$op ^ /exp[3]$op;
               \viz_js
                  box: {width: 60, height: 60},
                  layout: "vertical",
                  render() {
                     return [new fabric.Text('$oo'.asInt().toString(16), {fill: "black"})];
                  }
            $out_matrix[31:0] = /yy[*]$oo;
         $block_out[127:0] = /xx[*]$out_matrix;
         
         $test[7:0] = 8'hbf * 8'h03;
         $test2[7:0] = (8'hbf << 1) ^ (8'hbf);
         //$block_out = /xx[*]/yy[*]$out_matrix;

      //...

      // Assert these to end simulation (before Makerchip cycle limit).
         *passed = *cyc_cnt > 40;
         *failed = 1'b0;
\SV
   endmodule

