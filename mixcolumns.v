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
         $block_in[127:0] = 128'ha7be1a6997ad739bd8c9ca451f618b61; //dummy test vector
         $const_matrix[127:0] = 128'h02030101010203010101020303010102; //constant matrix for column multiplicaiton in the form of a vector

         /xx[3:0]
            /yy[3:0]
               $ss[7:0] = |mixcolumn$block_in[(#yy * 8 + #xx * 32) + 7 : (#yy * 8 + #xx * 32)];     //breaks the input vector and
               $cc[7:0] = |mixcolumn$const_matrix[(#yy * 32 + #xx * 8) + 7 : (#yy * 32 + #xx * 8)]; //constant matrix into matrices
               /exp[3:0]
                  ///xx[#xx]/yy[#exp]$ss * /xx[#exp]/yy[#yy]$cc
                  $reduce_check[7:0] = (/xx[#xx]/yy[#exp]$ss[7] == 1) && (/xx[#exp]/yy[#yy]$cc != 8'h01) ? 8'h1b : 8'h00; //check if a reduction by the irreducibly polynomial is necessary
                  $three_check[7:0] = /xx[#exp]/yy[#yy]$cc == 8'h03 ? /xx[#xx]/yy[#exp]$ss : 8'h00; //check if a multiplication by 3 is being done
                  $op[7:0] = /xx[#exp]/yy[#yy]$cc == 8'h01 ? /xx[#xx]/yy[#exp]$ss : ((/xx[#xx]/yy[#exp]$ss << 1) ^ $three_check ^ $reduce_check); //if 1, identity. otherwise, bitshift & other operations.
                  
               $oo[7:0] = /exp[0]$op ^ /exp[1]$op ^ /exp[2]$op ^ /exp[3]$op; //xor the bytes together
               \viz_js
                  box: {width: 60, height: 60},
                  layout: "vertical",
                  render() {
                     return [new fabric.Text('$oo'.asInt().toString(16), {fill: "black"})];
                  }
            $out_matrix[31:0] = /yy[*]$oo; //concat matrix rows
         $block_out[127:0] = /xx[*]$out_matrix; //concat matrix columns
         //$block_out = /xx[*]/yy[*]$out_matrix;

      //...

      // Assert these to end simulation (before Makerchip cycle limit).
         *passed = *cyc_cnt > 40;
         *failed = 1'b0;
\SV
   endmodule

