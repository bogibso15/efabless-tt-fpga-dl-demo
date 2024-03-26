\m5_TLV_version 1d: tl-x.org
\m5
   use(m5-1.0)

   //-------------------------------------------------------
   // Build Target Configuration
   //
   // To build within Makerchip for the FPGA or ASIC:
   //   o Use first line of file: \m5_TLV_version 1d --inlineGen --noDirectiveComments --noline --clkAlways --bestsv --debugSigsYosys: tl-x.org
   //   o set(MAKERCHIP, 0)  // (below)
   //   o For ASIC, set my_design (below) to match the configuration of your repositoy:
   //       - tt_um_fpga_hdl_demo for tt_fpga_hdl_demo repo
   //       - tt_um_example for tt06_verilog_template repo
   //   o var(target, FPGA)  // or ASIC (below)
   set(MAKERCHIP, 1)   /// 1 for simulating in Makerchip.
   var(my_design, tt_um_template)   /// The name of your top-level TT module, to match your info.yml.
   var(target, FPGA)  /// FPGA or ASIC
   //-------------------------------------------------------
   
   var(debounce_inputs, 1)         /// 1: Provide synchronization and debouncing on all input signals.
                                   /// 0: Don't provide synchronization and debouncing.
                                   /// m5_neq(m5_MAKERCHIP, 1): Debounce unless in Makerchip.
   
   // ======================
   // Computed From Settings
   // ======================
   
   // If debouncing, a user's module is within a wrapper, so it has a different name.
   var(user_module_name, m5_if(m5_debounce_inputs, my_design, m5_my_design))
   var(debounce_cnt, m5_if_eq(m5_MAKERCHIP, 1, 8'h03, 8'hff))

\SV
   m4_include_lib(https:/['']/raw.githubusercontent.com/efabless/chipcraft---mest-course/main/tlv_lib/calculator_shell_lib.tlv)
   // Include Tiny Tapeout Lab.
   m4_include_lib(https:/['']/raw.githubusercontent.com/os-fpga/Virtual-FPGA-Lab/35e36bd144fddd75495d4cbc01c4fc50ac5bde6f/tlv_lib/tiny_tapeout_lib.tlv)


\TLV aes_viz()
   |encrypt
      @0
         m5_fn(stroke_for_row_val, i, ['stroke: function (row) {return row == 0 ? "red" : row == 1 ? "#2040ff" : row == 2 ? "#00dd00" : "#ff00ff"}(m5_i)'])
         m5_fn(stroke_for_row, i, ['m5_stroke_for_row_val(this.getIndex("m5_i"))'])
         \viz_js
            box: {width: 960, height: 960, strokeWidth: 0},
            init() {
               return {bg: this.newImageFromURL("https://upload.wikimedia.org/wikipedia/commons/5/50/AES_(Rijndael)_Round_Function.png",
                                                "John Savard - CC0",
                                                {width: 640, height: 960, fill: "#30483c", strokeWidth: 1,},
                                                {strokeWidth: 0}
                                               )}
            },
            where: {left: 0, top: 0, height: 100}
         /subbytes
            /legend
               \viz_js
                  box: {strokeWidth: 0},
                  init() {
                     return {
                        circle: new fabric.Circle({
                           fill: "#FFFD", radius: 40,
                           strokeWidth: 2, stroke: "gray",
                        }),
                        text: new fabric.Text(
                           "$word_byte\n$sb_intermed",
                           {originX: "center", originY: "center", textAlign: "center", left: 40, top: 40,
                            fontFamily: "roboto", fontSize: 12})
                     }
                  },
                  where: {left: 30, top: 30}
            /sub_word[*]
               \viz_js
                  box: {strokeWidth: 0},
                  layout: {left: 43, top: -24},
                  where: {left: 57, top: 60}
               /sbox_subword[*]
                  \viz_js
                     box: {strokeWidth: 0},
                     layout: {left: 56, top: 32},
                     init() {
                        test = this
                        circ = new fabric.Circle({
                            fill: "#FFFD", radius: 25,
                            strokeWidth: 2, m5_stroke_for_row(sbox_subword)
                        })
                        let text = new fabric.Text("--\n--", {originX: "center", originY: "center", textAlign: "center", left: 25, top: 25, fontFamily: "roboto mono", fontSize: 12.5})
                        return {circ, text}
                     },
                     render() {
                        if ('|encrypt$valid_blk'.asBool()) {
                           this.getObjects().text.set({
                              text: `${'$word_idx'.asInt().toString(16)}\n${'$sb_intermed'.asInt().toString(16)}`
                           })
                        }
                        return [];
                     }
            /map
               \viz_js
                  box: {strokeWidth: 0},
                  init() {
                     this.sbox_cyc = -1   // Indicate that sbox_prop must be updated.
                     let img = this.newImageFromURL(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/AES-SubBytes.svg/1920px-AES-SubBytes.svg.png",
                        "Matt Crypto -- CC0",
                        {left: 0, top: 20, width: 300, fill: "#30483c", strokeWidth: 1,},
                        {strokeWidth: 0}
                     )
                     let label1 = new fabric.Text("$word_idx", {originX: "center", left: 56, top: 0, fill: "white", fontFamily: "roboto mono", fontSize: 15})
                     let label2 = new fabric.Text("$sb_intermed", {originX: "center", left: 244, top: 0, fill: "white", fontFamily: "roboto mono", fontSize: 15})
                     let S = new fabric.Text("Sbox", {fill: "white", fontFamily: "roboto mono", fontSize: 17, left: 130, top: 107})
                     return {img, label1, label2, S}
                  },
                  where: {left: 460, top: 75}
               /sbox_x[15:0]
                  \viz_js
                     box: {width: 10, height: 160, fill: "white"},
                     where: {left: 120, top: 130, width: 60, height: 60}
                  /sbox_y[15:0]
                     \viz_js
                        box: {width: 10, height: 10},
                        layout: "vertical",
                        render() {
                           let index = this.getIndex("sbox_y") * 16 + this.getIndex("sbox_x")
                           let val = parseInt('|encrypt$sbox_vec'.asBinaryStr().substr(index * 8, 8), 2)
                           ret = [
                              new fabric.Text(index.toString(16), {
                                   fontFamily: "roboto mono", fontSize: 3.5,
                                   originX: "center", left: 5, top: 0.5,
                              }),
                              new fabric.Text(val.toString(16).padStart(2, "0"), {
                                   fontFamily: "roboto mono", fontSize: 3.5,
                                   originX: "center", left: 5, top: 5
                              }),
                           ]
                           // Sbox properties (only once), as sparse array sbox_prop[0..255].
                           debugger
                           let ctx = this.getScope("map").context
                           if (this.getScope("map").context.sbox_cyc != this.getCycle()) {
                              this.getScope("map").context.sbox_cyc = this.getCycle()
                              ctx.sbox_prop = {}
                              for (let y = 0; y < 4; y++) {
                                 for (let x = 0; x < 4; x++) {
                                    let idx = '/subbytes/sub_word[x]/sbox_subword[y]$word_idx'.asInt()
                                    ctx.sbox_prop[idx] = {m5_stroke_for_row_val(y), yellow: x == 2 && y == 2}
                                 }
                              }
                           }
                           // Colored circle and yellow box.
                           if (index in ctx.sbox_prop) {
                              debugger
                              let prop = ctx.sbox_prop[index]
                              ret.unshift(new fabric.Circle({left: 0, top: 0, radius: 4.5, strokeWidth: 1, stroke: prop.stroke, fill: "transparent"}))
                              if (prop.yellow) {
                                 ret.unshift(new fabric.Rect({left: 0, top: 0, width: 9, height: 9, fill: "#fdd58a", strokeWidth: 1, stroke: "black"}))
                              }
                           }
                           return ret
                        },

               /ax[3:0]
                  /ay[3:0]
                     $ANY = /subbytes/sub_word[#ax]/sbox_subword[#ay]$ANY;
                     \viz_js
                        box: {strokeWidth: 0},
                        layout: "vertical",
                        init() {
                           circ = new fabric.Circle({
                               fill: "#FFFD", radius: 13,
                               strokeWidth: 1, m5_stroke_for_row(ay)
                           })
                           let text = new fabric.Text(
                                    "--", {originX: "center", originY: "center", textAlign: "center", left: 13, top: 13,
                                    fontFamily: "roboto mono", fontSize: 12.5})
                           return {circ, text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$word_idx'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 3, top: 26}
               /bx[3:0]
                  /by[3:0]
                     $ANY = /subbytes/sub_word[#bx]/sbox_subword[#by]$ANY;
                     \viz_js
                        box: {strokeWidth: 0},
                        layout: "vertical",
                        init() {
                           circ = new fabric.Circle({
                               fill: "#FFFD", radius: 13,
                               strokeWidth: 1, m5_stroke_for_row(by)
                           })
                           let text = new fabric.Text("--", {originX: "center", originY: "center", textAlign: "center", left: 13, top: 13, fontFamily: "roboto mono", fontSize: 12.5})
                           return {circ, text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$sb_intermed'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 191, top: 26}
         /shift_row
            /map
               \viz_js
                  box: {strokeWidth: 0},
                  init() {
                     let img = this.newImageFromURL(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/AES-ShiftRows.svg/1920px-AES-ShiftRows.svg.png",
                        "Matt Crypto -- CC0",
                        {left: -30, top: 34, width: 331, fill: "#30483c", strokeWidth: 1,},
                        {strokeWidth: 0}
                     )
                     let label1 = new fabric.Text("$sb_intermed", {originX: "center", left: 56, top: 9, fill: "white", fontFamily: "roboto mono", fontSize: 15})
                     let label2 = new fabric.Text("$ssr_out_byte", {originX: "center", left: 244, top: 9, fill: "white", fontFamily: "roboto mono", fontSize: 15})
                     return {img, label1, label2}
                  },
                  where: {left: 430, top: 255}
               /ax[3:0]
                  /ay[3:0]
                     $ANY = |encrypt/subbytes/sub_word[#ax]/sbox_subword[#ay]$ANY;
                     \viz_js
                        box: {strokeWidth: 0},
                        layout: "vertical",
                        init() {
                           circ = new fabric.Circle({
                               fill: "#FFFD", radius: 13,
                               strokeWidth: 1, m5_stroke_for_row(ay)
                           })
                           let text = new fabric.Text("--", {originX: "center", originY: "center", textAlign: "center", left: 13, top: 13, fontFamily: "roboto mono", fontSize: 12.5})
                           return {circ, text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$sb_intermed'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 3, top: 36}
               /bx[3:0]
                  /by[3:0]
                     $ssr_out_byte[7:0] = |encrypt/subbytes$ssr_out[(15 - ((#bx * 4) + #by)) * 8 +: 8];
                     \viz_js
                        box: {strokeWidth: 0},
                        layout: "vertical",
                        init() {
                           circ = new fabric.Circle({
                               fill: "#FFFD", radius: 13,
                               strokeWidth: 1, m5_stroke_for_row(by)
                           })
                           let text = new fabric.Text("--", {originX: "center", originY: "center", textAlign: "center", left: 13, top: 13, fontFamily: "roboto mono", fontSize: 12.5})
                           return {circ, text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$ssr_out_byte'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 191, top: 36}
         /mixcolumn
            /legend
               \viz_js
                  box: {strokeWidth: 0},
                  init() {
                     return {
                        circle: new fabric.Circle({
                           fill: "#FFFD", radius: 40,
                           strokeWidth: 2, stroke: "gray",
                        }),
                        text: new fabric.Text(
                           "$ssr_out_byte\n$ss\n$oo",
                           {originX: "center", originY: "center", textAlign: "center", left: 40, top: 40,
                            fontFamily: "roboto", fontSize: 10})
                     }
                  },
                  where: {left: 30, top: 400}
            /xx[*]
               \viz_js
                  box: {strokeWidth: 0},
                  layout: {left: 43, top: -24},
                  where: {left: 57, top: 430}
               /yy[*]
                  $ssr_out_byte[7:0] = |encrypt/shift_row/map/bx[#xx]/by[#yy]$ssr_out_byte;
                  // $ss, $cc, $oo
                  \viz_js
                     box: {strokeWidth: 0},
                     layout: {left: 56, top: 32},
                     init() {
                        circ = new fabric.Circle({
                            fill: "#FFFD", radius: 25,
                            strokeWidth: 2, m5_stroke_for_row(yy)
                        })
                        let text = new fabric.Text("--\n--\n--\n--", {originX: "center", originY: "center", textAlign: "center", left: 25, top: 25, fontFamily: "roboto mono", fontSize: 9})
                        return {circ, text}
                     },
                     render() {
                        if ('|encrypt$valid_blk'.asBool()) {
                           this.getObjects().text.set({
                              text: `${'$ssr_out_byte'.asInt().toString(16)}\n${'$ss'.asInt().toString(16)}\n${'$oo'.asInt().toString(16)}`
                           })
                        }
                        return [];
                     }
            /map
               \viz_js
                  box: {strokeWidth: 0},
                  init() {
                     let img = this.newImageFromURL(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/AES-MixColumns.svg/1920px-AES-MixColumns.svg.png",
                        "Matt Crypto -- CC0",
                        {left: 1, top: 16, width: 300, fill: "#30483c", strokeWidth: 1,},
                        {strokeWidth: 0}
                     )
                     let label1 = new fabric.Text("$ss", {originX: "center", left: 86, top: 11, fill: "white", fontFamily: "roboto mono", fontSize: 15})
                     let label2 = new fabric.Text("$oo", {originX: "center", left: 274, top: 11, fill: "white", fontFamily: "roboto mono", fontSize: 15})
                     return {img, label1, label2}
                  },
                  where: {left: 460, top: 425}
               /ax[3:0]
                  /ay[3:0]
                     $ANY = /mixcolumn/xx[#ax]/yy[#ay]$ANY;
                     \viz_js
                        box: {strokeWidth: 0},
                        layout: "vertical",
                        init() {
                           circ = new fabric.Circle({
                               fill: "#FFFD", radius: 13,
                               strokeWidth: 1, m5_stroke_for_row(ay)
                           })
                           let text = new fabric.Text("--", {originX: "center", originY: "center", textAlign: "center", left: 13, top: 13, fontFamily: "roboto mono", fontSize: 12.5})
                           return {circ, text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$ss'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 3, top: 36}
               /bx[3:0]
                  /by[3:0]
                     $ANY = /mixcolumn/xx[#bx]/yy[#by]$ANY;
                     \viz_js
                        box: {strokeWidth: 0},
                        layout: "vertical",
                        init() {
                           circ = new fabric.Circle({
                               fill: "#FFFD", radius: 13,
                               strokeWidth: 1, m5_stroke_for_row(by)
                           })
                           let text = new fabric.Text("--", {originX: "center", originY: "center", textAlign: "center", left: 13, top: 13, fontFamily: "roboto mono", fontSize: 12.5})
                           return {circ, text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$oo'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 191, top: 36}
               /cx[3:0]
                  /cy[3:0]
                     $ANY = /mixcolumn/xx[#cx]/yy[#cy]$ANY;
                     \viz_js
                        box: {width: 10, height: 10, strokeWidth: 0, fill: "white"},
                        layout: "vertical",
                        init() {
                           let text = new fabric.Text("-", {originX: "center", originY: "center", textAlign: "center", left: 5, top: 5, fontFamily: "roboto mono", fontSize: 9})
                           return {text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$cc'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 139, top: 139, width: 11}
         /keyschedule
            /legend
               \viz_js
                  box: {strokeWidth: 0},
                  init() {
                     return {
                        circle: new fabric.Circle({
                           fill: "#FFFD", radius: 40,
                           strokeWidth: 2, stroke: "gray",
                        }),
                        text: new fabric.Text(
                           "$oo\n$key_byte\n$state_ark_byte",
                           {originX: "center", originY: "center", textAlign: "center", left: 40, top: 40,
                            fontFamily: "roboto", fontSize: 11})
                     }
                  },
                  where: {left: 30, top: 625}
            /sbox_k[*]
               \viz_js
                  box: {strokeWidth: 0},
                  layout: {left: 43, top: -24},
                  where: {left: 57, top: 655}
               /yy[3:0]
                  $oo[7:0] = |encrypt/mixcolumn/xx[#sbox_k]/yy[#yy]$oo;
                  $key_byte[7:0] = |encrypt/keyschedule$key[(15 - ((#sbox_k * 4) + #yy)) +: 8];
                  $state_ark_byte[7:0] = |encrypt$state_ark[(15 - ((#sbox_k * 4) + #yy)) +: 8];
                  
                  \viz_js
                     box: {strokeWidth: 0},
                     layout: {left: 56, top: 32},
                     init() {
                        circ = new fabric.Circle({
                            fill: "#FFFD", radius: 25,
                            strokeWidth: 2, m5_stroke_for_row(yy)
                        })
                        let text = new fabric.Text("--\n--\n--", {originX: "center", originY: "center", textAlign: "center", left: 25, top: 25, fontFamily: "roboto mono", fontSize: 12.5})
                        return {circ, text}
                     },
                     render() {
                        if ('|encrypt$valid_blk'.asBool()) {
                           this.getObjects().text.set({
                              text: `${'$oo'.asInt().toString(16)}\n${'$key_byte'.asInt().toString(16)}\n${'$state_ark_byte'.asInt().toString(16)}`
                           })
                        }
                        return [];
                     }
            
            /map
               \viz_js
                  box: {strokeWidth: 0},
                  init() {
                     let img = this.newImageFromURL(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/AES-AddRoundKey.svg/1024px-AES-AddRoundKey.svg.png",
                        "Matt Crypto -- CC0",
                        {left: 0, top: 30, width: 300, fill: "#30483c", strokeWidth: 1,},
                        {strokeWidth: 0}
                     )
                     let label1 = new fabric.Text("$oo", {originX: "center", left: 56, top: 9, fill: "white", fontFamily: "roboto mono", fontSize: 15})
                     let label2 = new fabric.Text("$state_ark_byte", {originX: "center", left: 244, top: 9, fill: "white", fontFamily: "roboto mono", fontSize: 15})
                     let label3 = new fabric.Text("$key_byte", {originX: "center", left: 56, top: 139, fill: "white", fontFamily: "roboto mono", fontSize: 15})
                     return {img, label1, label2, label3}
                  },
                  where: {left: 460, top: 630}
               /ax[3:0]
                  /ay[3:0]
                     $ANY = /keyschedule/sbox_k[#ax]/yy[#ay]$ANY;
                     \viz_js
                        box: {strokeWidth: 0},
                        layout: "vertical",
                        init() {
                           circ = new fabric.Circle({
                               fill: "#FFFD", radius: 13,
                               strokeWidth: 1, m5_stroke_for_row(ay)
                           })
                           let text = new fabric.Text("--", {originX: "center", originY: "center", textAlign: "center", left: 13, top: 13, fontFamily: "roboto mono", fontSize: 12.5})
                           return {circ, text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$oo'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 2, top: 31}
               /bx[3:0]
                  /by[3:0]
                     $ANY = /keyschedule/sbox_k[#bx]/yy[#by]$ANY;
                     \viz_js
                        box: {strokeWidth: 0},
                        layout: "vertical",
                        init() {
                           circ = new fabric.Circle({
                               fill: "#FFFD", radius: 13,
                               strokeWidth: 1, m5_stroke_for_row(by)
                           })
                           let text = new fabric.Text("--", {originX: "center", originY: "center", textAlign: "center", left: 13, top: 13, fontFamily: "roboto mono", fontSize: 12.5})
                           return {circ, text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$state_ark_byte'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 190, top: 31}
               /kx[3:0]
                  /ky[3:0]
                     $ANY = /keyschedule/sbox_k[#kx]/yy[#ky]$ANY;
                     \viz_js
                        box: {strokeWidth: 0},
                        layout: "vertical",
                        init() {
                           circ = new fabric.Circle({
                               fill: "#FFFD", radius: 13,
                               strokeWidth: 1, m5_stroke_for_row(ky)
                           })
                           let text = new fabric.Text("--", {originX: "center", originY: "center", textAlign: "center", left: 13, top: 13, fontFamily: "roboto mono", fontSize: 12.5})
                           return {circ, text}
                        },
                        render() {
                           if ('|encrypt$valid_blk'.asBool()) {
                              this.getObjects().text.set({
                                 text: `${'$key_byte'.asInt().toString(16)}`
                              })
                           }
                           return [];
                        },
                        where: {left: 2, top: 155}

//Module to perform the Subbytes AND Shift Rows subroutines.
//It is trivial to combine these subroutines, and so we combine
//them into one module.
//See Sections 5.1.1 and 5.1.2 (pages 15-17) of the NIST AES Specification for more details.
//https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf
\TLV subbytes(/_top, /_name, $_state_in)
   /_name
      /sub_word[3:0]
         $word[31:0] = /_top$_state_in[128-(32*(#sub_word+1))+:32];
         m5+sbox(/sub_word, /sbox_subword, $word)
         
      $ssr_out[127:0] = {/sub_word[0]$sb_out[31:24], /sub_word[1]$sb_out[23:16], /sub_word[2]$sb_out[15:8], /sub_word[3]$sb_out[7:0],
                         /sub_word[1]$sb_out[31:24], /sub_word[2]$sb_out[23:16], /sub_word[3]$sb_out[15:8], /sub_word[0]$sb_out[7:0],
                         /sub_word[2]$sb_out[31:24], /sub_word[3]$sb_out[23:16], /sub_word[0]$sb_out[15:8], /sub_word[1]$sb_out[7:0],
                         /sub_word[3]$sb_out[31:24], /sub_word[0]$sb_out[23:16], /sub_word[1]$sb_out[15:8], /sub_word[2]$sb_out[7:0]};
   
\TLV sbox(/_top, /_name, $_word, _where)
   /_name[3:0]
      $sb_idx[10:0] = 2040-8*$word_idx;
      $word_idx[7:0] = /_top$_word[32-(8 * (#m5_strip_prefix(/_name)+1)) +: 8];
      $sb_intermed[7:0] = |encrypt$sbox_vec[$sb_idx +: 8];
   $sb_out[31:0] = {/_name[0]$sb_intermed, /_name[1]$sb_intermed, /_name[2]$sb_intermed, /_name[3]$sb_intermed};

//Module to verify that the AES encryption has been performed successfully
//The check module can only be run if in ECB
\TLV check(/_top, /_name, $_state_f, $_ui_in)
   
   /_name
      
      $pass[0:0] = /_top$_ui_in == 1 ? (/_top$_state_f == 128'hb6768473ce9843ea66a81405dd50b345) : 
                   /_top$_ui_in == 2 ? (/_top$_state_f == 128'hcb2f430383f9084e03a653571e065de6) :
                   /_top$_ui_in == 4 ? (/_top$_state_f == 128'hff4e66c07bae3e79fb7d210847a3b0ba) :
                   /_top$_ui_in == 8 ? (/_top$_state_f == 128'h7b90785125505fad59b13c186dd66ce3) :
                   (/_top$_state_f == 128'h8b527a6aebdaec9eaef8eda2cb7783e5);

//Module to perform the mix columns subroutine. See Section
//5.1.3 (page 17) of the NIST AES Specification for more details.
//https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf
\TLV mixcolumn(/_top, /_name, $_block_in)
   /_name

      $const_matrix[127:0] = 128'h02030101010203010101020303010102; //constant matrix for column multiplicaiton in the form of a vector
      /xx[3:0]
         /yy[3:0]
            $ss[7:0] = /_top$_block_in[(#yy * 8 + #xx * 32) + 7 : (#yy * 8 + #xx * 32)];     //breaks the input vector and
            $cc[7:0] = /_name$const_matrix[(#yy * 32 + #xx * 8) + 7 : (#yy * 32 + #xx * 8)]; //constant matrix into matrices
            /exp[3:0]
               ///xx[#xx]/yy[#exp]$ss * /xx[#exp]/yy[#yy]$cc
               $reduce_check[7:0] = (/xx[#xx]/yy[#exp]$ss[7] == 1) && (/xx[#exp]/yy[#yy]$cc != 8'h01) ? 8'h1b : 8'h00; //check if a reduction by the irreducibly polynomial is necessary
               $three_check[7:0] = /xx[#exp]/yy[#yy]$cc == 8'h03 ? /xx[#xx]/yy[#exp]$ss : 8'h00; //check if a multiplication by 3 is being done
               $op[7:0] = /xx[#exp]/yy[#yy]$cc == 8'h01 ? /xx[#xx]/yy[#exp]$ss : ((/xx[#xx]/yy[#exp]$ss << 1) ^ $three_check ^ $reduce_check); //if 1, identity. otherwise, bitshift & other operations.
            $oo[7:0] = /exp[0]$op ^ /exp[1]$op ^ /exp[2]$op ^ /exp[3]$op; //xor the bytes together
         $out_matrix[31:0] = {/yy[3]$oo, /yy[2]$oo, /yy[1]$oo, /yy[0]$oo} ; //concat matrix rows
      $block_out[127:0] = {/xx[3]$out_matrix, /xx[2]$out_matrix, /xx[1]$out_matrix, /xx[0]$out_matrix}; //concat matrix columns

//Module to perform the key schedule, or key expansion, subroutine. 
//See Section 5.2(page 19) of the NIST AES Specification for more details.
//https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf
\TLV keyschedule(/_top, /_name, $_start_key, $_run_key, $_reset, $_r_counter, $_ld_key)
   /_name
      
      //KEY is the exposed output to main. The current key to use will be displayed.
      //After ARK is done on main, it should pulse the keyschedule which will cause
      //it to calculate the next key and have it ready for use.
      $key[127:0] = /_top$_reset ?  '0 : //resets key (loads dummy for testing)
                    /_top$_ld_key ? /_top$_start_key :  //pulls in initial key
                    >>1$next_key; //loads next key
                    
      $next_key[127:0] = /_top$_ld_key ? /_top$_start_key : //full key for next clock
                         /_top$_run_key ? {$next_worda, $next_wordb, $next_wordc, $next_wordd} :
                         >>1$next_key;
      $run_key = /_top$_run_key;
      ?$run_key
         $rot[31:0] = {$key[23:0],$key[31:24]}; // rotate word
         
         m5+sbox(/_name, /sbox_k, $rot)
         
         $rcon[7:0] = /_top$_r_counter == 0 ? 8'h01 : //round constant
                      >>1$rcon <  8'h80 ? (2 * >>1$rcon) :
                                 ((2 * >>1$rcon) ^ 8'h1B);
         $xor_con[31:0] = $sb_out[31:0] ^ {$rcon, 24'b0}; // xor with the round constant
         $next_worda[31:0] = $xor_con ^ $key[127:96];  // ripple solve for next words
         $next_wordb[31:0] = $next_worda ^ $key[95:64];
         $next_wordc[31:0] = $next_wordb ^ $key[63:32];
         $next_wordd[31:0] = $next_wordc ^ $key[31:0];

\TLV calc()
   |encrypt
      @0
         $sbox_vec[2047:0] = 2048'h637c777bf26b6fc5_3001672bfed7ab76_ca82c97dfa5947f0_add4a2af9ca472c0_b7fd9326363ff7cc_34a5e5f171d83115_04c723c31896059a_071280e2eb27b275_09832c1a1b6e5aa0_523bd6b329e32f84_53d100ed20fcb15b_6acbbe394a4c58cf_d0efaafb434d3385_45f9027f503c9fa8_51a3408f929d38f5_bcb6da2110fff3d2_cd0c13ec5f974417_c4a77e3d645d1973_60814fdc222a9088_46eeb814de5e0bdb_e0323a0a4906245c_c2d3ac629195e479_e7c8376d8dd54ea9_6c56f4ea657aae08_ba78252e1ca6b4c6_e8dd741f4bbd8b8a_703eb5664803f60e_613557b986c11d9e_e1f8981169d98e94_9b1e87e9ce5528df_8ca1890dbfe64268_41992d0fb054bb16;
         // TODO: Reverse the order of bytes, as:
         //$sbox_vec_new[2047:0] = {
         //   128'h16bb54b00f2d99416842e6bf0d89a18c,
         //   128'hdf2855cee9871e9b948ed9691198f8e1,
         //   128'h9e1dc186b95735610ef6034866b53e70,
         //   128'h8a8bbd4b1f74dde8c6b4a61c2e2578ba,
         //   128'h08ae7a65eaf4566ca94ed58d6d37c8e7,
         //   128'h79e4959162acd3c25c2406490a3a32e0,
         //   128'hdb0b5ede14b8ee4688902a22dc4f8160,
         //   128'h73195d643d7ea7c41744975fec130ccd,
         //   128'hd2f3ff1021dab6bcf5389d928f40a351,
         //   128'ha89f3c507f02f94585334d43fbaaefd0,
         //   128'hcf584c4a39becb6a5bb1fc20ed00d153,
         //   128'h842fe329b3d63b52a05a6e1b1a2c8309,
         //   128'h75b227ebe28012079a059618c323c704,
         //   128'h1531d871f1e5a534ccf73f362693fdb7,
         //   128'hc072a49cafa2d4adf04759fa7dc982ca,
         //   128'h76abd7fe2b670130c56f6bf27b777c63
         //   };
         
         $ui_in[7:0] = *ui_in;   //Input to determine mode/keys
         $ofb = $ui_in[7];             //Switch to determine mode
         $blocks_to_run[22:0] = 2000000;     //Blocks of AES to run if in OFB
         
         //Initial State or IV
         $test_state[127:0] =  128'h00112233445566778899aabbccddeeff;
         
         //Initial Key
         $start_key[127:0] =  $ui_in[0] ? 128'hffff_ffff_ffff_80000000000000000000 :
                              $ui_in[1] ? 128'hffffffffffffc0000000000000000000 :
                              $ui_in[2] ? 128'hffffffffffffe0000000000000000000 :
                              $ui_in[3] ? 128'hfffffffffffff0000000000000000000 :
                              128'h000102030405060708090a0b0c0d0e0f;
         
         $valid_blk = ($ofb && ($blk_counter <= $blocks_to_run)) || !$ofb;
         //Counter to count the number of AES blocks performed
         $blk_counter[22:0] = !$reset && >>1$reset ? 0 :
                              !$ld_key && >>1$ld_key ? >>1$blk_counter+1 :
                              >>1$blk_counter;
         
         //Reset if *reset or if the ofb_count reaches 12 when in OFB
         $reset = *reset;
         $valid_check = $valid && !$ofb;
         $valid = $r_counter==11;
         ?$valid_blk
            
            
            //If in ECB, this checks to see if the AES block if completed
            
            
            $ld_key = ((!$reset && >>1$reset) || >>1$r_counter == 10) ? 1 : 0;
            
            $run_key = (!$ld_key && >>1$ld_key) ? 1 :
                       (>>1$run_key && $ofb && >>1$blk_counter <= $blocks_to_run ) ? 1 :
                       (!$ofb && >>1$r_counter < 11) ? 1 :
                       0;
                       
            $ld_init = !$reset && >>1$reset ? 1 : 0;
            //round counter
            $r_counter[4:0] = $reset ? 0 :
                              !$ld_key && >>1$ld_key ? 0 :
                              ($ofb && >>1$r_counter > 10) ? 0 :
                              $run_key ? >>1$r_counter+1 :
                              >>1$r_counter;
                              
            //Perform the key schedule subroutine
            m5+keyschedule(|encrypt, /keyschedule, $start_key, $run_key, $reset, $r_counter, $ld_key)
            //set the initial state
            $state_i[127:0] = $reset ? '0:
                              !$ld_init && >>1$ld_init ? $test_state :
                              ($run_key && >>1$r_counter<11) ? >>1$state_ark :
                              >>1$state_i;
                              
            //Perform the subbytes and shift row subroutines
            m5+subbytes(|encrypt, /subbytes, $state_i)
            $state_ssr[127:0] = $r_counter ==0 ? $state_i : /subbytes$ssr_out;
            
            //Perform the mixcolumn subroutine
            m5+mixcolumn(|encrypt, /mixcolumn, $state_ssr)
            $state_mc[127:0] = ($r_counter ==0 || $r_counter == 10) ? $state_ssr : /mixcolumn$block_out;
            
            //Perform the add round key subroutine
            $state_ark[127:0] = $state_mc ^ /keyschedule$key;
            
            //If in ECB, check for a correct encryption
            
         ?$valid_check
            m5+check(|encrypt, /check, $state_i, $ui_in)
         
         // Capture and drive pass/fail on 7-seg.
         $passed = $reset       ? 1'b0 :
                   $valid_check ? /check$pass :
                                  $RETAIN;
         *uo_out = $passed ? 8'b00111111 :
                   8'b01110110;

   m5_if(m5_MAKERCHIP, ['m5+aes_viz()'])
   
   // Connect Tiny Tapeout outputs. Note that uio_ outputs are not available in the Tiny-Tapeout-3-based FPGA boards.
   //*uo_out = 8'b0;
   m5_if_neq(m5_target, FPGA, ['*uio_out = 8'b0;'])
   m5_if_neq(m5_target, FPGA, ['*uio_oe = 8'b0;'])
   
\SV

// ================================================
// A simple Makerchip Verilog test bench driving random stimulus.
// Modify the module contents to your needs.
// ================================================

module top(input logic clk, input logic reset, input logic [31:0] cyc_cnt, output logic passed, output logic failed);
   // Tiny tapeout I/O signals.
   logic [7:0] ui_in, uo_out;
   m5_if_neq(m5_target, FPGA, ['logic [7:0]uio_in,  uio_out, uio_oe;'])
   logic [31:0] r;
   always @(posedge clk) r <= m5_if(m5_MAKERCHIP, ['$urandom()'], ['0']);
   assign ui_in = 8'b00000001;
   m5_if_neq(m5_target, FPGA, ['assign uio_in = 8'b0;'])
   logic ena = 1'b0;
   logic rst_n = ! reset;
   
   // Instantiate the Tiny Tapeout module.
   m5_user_module_name tt(.*);
   
   assign passed = top.cyc_cnt > 60;
   assign failed = 1'b0;
endmodule


// Provide a wrapper module to debounce input signals if requested.
m5_if(m5_debounce_inputs, ['m5_tt_top(m5_my_design)'])
\SV



// =======================
// The Tiny Tapeout module
// =======================

module m5_user_module_name (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    m5_if_eq(m5_target, FPGA, ['/']['*'])   // The FPGA is based on TinyTapeout 3 which has no bidirectional I/Os (vs. TT6 for the ASIC).
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    m5_if_eq(m5_target, FPGA, ['*']['/'])
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
   wire reset = ! rst_n;
   
\TLV
   /* verilator lint_off UNOPTFLAT */
   // Connect Tiny Tapeout I/Os to Virtual FPGA Lab.
   m5+tt_connections()
   
   // Instantiate the Virtual FPGA Lab.
   m5+board(/top, /fpga, 7, $, , calc)
   // Label the switch inputs [0..7] (1..8 on the physical switch panel) (top-to-bottom).
   m5+tt_input_labels_viz(['"Value[0]", "Value[1]", "Value[2]", "Value[3]", "Op[0]", "Op[1]", "Op[2]", "="'])

\SV
endmodule
