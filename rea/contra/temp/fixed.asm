; 魂斗罗1.nes bank=fixed base=$C000 入口=['$F80D', '$F889', '$F8E1', '$F880']
; 代码 3977 字节（递归下降）
$C000: 1e        .byte $1E
$C001: e6 1a     INC   $1A
$C003: a5 18     LDA   $18
$C005: f0 07     BEQ   $C00E
$C007: c9 03     CMP   #$03
$C009: b0 03     BCS   $C00E
$C00B: 20 1e c2  JSR   $C21E
$C00E: a5 18     LDA   $18
$C010: 20 f2 c6  JSR   $C6F2
$C014: c0 32 c0 a6 c0 bd c0 02 c1 42 cc 5a fa 53 c1 .byte $C0 …
$C023: 20 43 c7  JSR   $C743
$C026: a9 07     LDA   #$07
$C028: 20 82 fa  JSR   $FA82
$C02B: a0 00     LDY   #$00
$C02D: 84 3f     STY   $3F
$C02F: 4c 62 c1  JMP   $C162
$C032: 20 93 c1  JSR   $C193
$C035: a9 08     LDA   #$08
$C037: 20 a1 c8  JSR   $C8A1
$C03A: a6 19     LDX   $19
$C03C: d0 1c     BNE   $C05A
$C03E: a9 ab     LDA   #$AB
$C040: 8d 01 03  STA   $0301
$C043: a9 b3     LDA   #$B3
$C045: 8d 35 03  STA   $0335
$C048: a9 77     LDA   #$77
$C04A: 8d 1b 03  STA   $031B
$C04D: a9 00     LDA   #$00
$C04F: 20 8c fa  JSR   $FA8C
$C052: 90 25     BCC   $C079
$C054: 20 6c c2  JSR   $C26C
$C057: 4c 5f c1  JMP   $C15F
$C05A: ca        DEX
$C05B: d0 1d     BNE   $C07A
$C05D: a9 2c     LDA   #$2C
$C05F: 8d 34 03  STA   $0334
$C062: a9 aa     LDA   #$AA
$C064: 8d 00 03  STA   $0300
$C067: a6 22     LDX   $22
$C069: bd a4 c0  LDA   $C0A4,X
$C06C: 8d 1a 03  STA   $031A
$C06F: a9 00     LDA   #$00
$C071: 8d 4e 03  STA   $034E
$C074: 20 77 c1  JSR   $C177
$C077: f0 66     BEQ   $C0DF
$C079: 60        RTS
$C07A: ca        DEX
$C07B: d0 08     BNE   $C085
$C07D: a9 01     LDA   #$01
$C07F: 20 8c fa  JSR   $FA8C
$C082: b0 d3     BCS   $C057
$C084: 60        RTS
$C085: ca        DEX
$C086: d0 06     BNE   $C08E
$C088: 20 72 fa  JSR   $FA72
$C08B: 4c 57 c0  JMP   $C057
$C08E: ca        DEX
$C08F: d0 0b     BNE   $C09C
$C091: 20 7a fa  JSR   $FA7A
$C094: 90 05     BCC   $C09B
$C096: a9 80     LDA   #$80
$C098: 4c 5d c1  JMP   $C15D
$C09B: 60        RTS
$C09C: 20 77 c1  JSR   $C177
$C09F: d0 fa     BNE   $C09B
$C0A1: 4c 66 c1  JMP   $C166
$C0A4: 96 af     .byte $96 …
$C0A6: a6 19     LDX   $19
$C0A8: d0 05     BNE   $C0AF
$C0AA: e6 19     INC   $19
$C0AC: 4c 82 c2  JMP   $C282
$C0AF: 20 39 cc  JSR   $CC39
$C0B2: a5 1f     LDA   $1F
$C0B4: f0 e5     BEQ   $C09B
$C0B6: a9 00     LDA   #$00
$C0B8: 85 23     STA   $23
$C0BA: 4c 6f c1  JMP   $C16F
$C0BD: a9 08     LDA   #$08
$C0BF: 20 a1 c8  JSR   $C8A1
$C0C2: a6 19     LDX   $19
$C0C4: d0 09     BNE   $C0CF
$C0C6: a9 00     LDA   #$00
$C0C8: 85 1c     STA   $1C
$C0CA: a9 40     LDA   #$40
$C0CC: 4c 5d c1  JMP   $C15D
$C0CF: ca        DEX
$C0D0: d0 15     BNE   $C0E7
$C0D2: 20 75 c2  JSR   $C275
$C0D5: a5 2a     LDA   $2A
$C0D7: f0 02     BEQ   $C0DB
$C0D9: c6 2a     DEC   $2A
$C0DB: 05 28     ORA   $28
$C0DD: d0 0f     BNE   $C0EE
$C0DF: a9 01     LDA   #$01
$C0E1: 20 82 fa  JSR   $FA82
$C0E4: 4c 5f c1  JMP   $C15F
$C0E7: a9 01     LDA   #$01
$C0E9: 20 8c fa  JSR   $FA8C
$C0EC: b0 78     BCS   $C166
$C0EE: a9 01     LDA   #$01
$C0F0: 18        CLC
$C0F1: 65 22     ADC   $22
$C0F3: 85 00     STA   $00
$C0F5: a9 08     LDA   #$08
$C0F7: 25 1a     AND   $1A
$C0F9: 0a        ASL
$C0FA: 0a        ASL
$C0FB: 0a        ASL
$C0FC: 0a        ASL
$C0FD: 05 00     ORA   $00
$C0FF: 4c c5 ca  JMP   $CAC5
$C102: a6 19     LDX   $19
$C104: d0 15     BNE   $C11B
$C106: 20 10 c9  JSR   $C910
$C109: a9 00     LDA   #$00
$C10B: 8d ea 07  STA   $07EA
$C10E: a5 f1     LDA   $F1
$C110: c9 20     CMP   #$20
$C112: f0 04     BEQ   $C118
$C114: a9 03     LDA   #$03
$C116: d0 54     BNE   $C16C
$C118: 4c 5f c1  JMP   $C15F
$C11B: ca        DEX
$C11C: d0 06     BNE   $C124
$C11E: 20 b6 fa  JSR   $FAB6
$C121: 4c 61 fb  JMP   $FB61
$C124: ca        DEX
$C125: d0 0a     BNE   $C131
$C127: 20 be fa  JSR   $FABE
$C12A: 90 04     BCC   $C130
$C12C: a9 05     LDA   #$05
$C12E: d0 3c     BNE   $C16C
$C130: 60        RTS
$C131: ca        DEX
$C132: d0 06     BNE   $C13A
$C134: 20 96 fa  JSR   $FA96
$C137: 4c 5f c1  JMP   $C15F
$C13A: ca        DEX
$C13B: d0 10     BNE   $C14D
$C13D: a5 f5     LDA   $F5
$C13F: 29 10     AND   #$10
$C141: d0 07     BNE   $C14A
$C143: 20 9e fa  JSR   $FA9E
$C146: a5 42     LDA   $42
$C148: f0 17     BEQ   $C161
$C14A: 4c 5f c1  JMP   $C15F
$C14D: 20 c1 c2  JSR   $C2C1
$C150: 4c 66 c1  JMP   $C166
$C153: a9 08     LDA   #$08
$C155: 20 a1 c8  JSR   $C8A1
$C158: 4c ae fa  JMP   $FAAE
$C15B: a9 80     .byte $A9 …
$C15D: 85 2a     STA   $2A
$C15F: e6 19     INC   $19
$C161: 60        RTS
$C162: a9 80     LDA   #$80
$C164: 85 2a     STA   $2A
$C166: e6 18     INC   $18
$C168: a9 00     LDA   #$00
$C16A: 85 1f     STA   $1F
$C16C: 85 19     STA   $19
$C16E: 60        RTS
$C16F: 85 18     STA   $18
$C171: 20 8a c1  JSR   $C18A
$C174: 4c 68 c1  JMP   $C168
$C177: a5 2a     LDA   $2A
$C179: 05 2b     ORA   $2B
$C17B: f0 0c     BEQ   $C189
$C17D: c6 2a     DEC   $2A
$C17F: d0 08     BNE   $C189
$C181: a5 2b     LDA   $2B
$C183: f0 02     BEQ   $C187
$C185: c6 2b     DEC   $2B
$C187: a9 01     LDA   #$01
$C189: 60        RTS
$C18A: a2 40     LDX   #$40
$C18C: 86 2a     STX   $2A
$C18E: a2 02     LDX   #$02
$C190: 86 2b     STX   $2B
$C192: 60        RTS
$C193: a4 3f     LDY   $3F
$C195: 30 1b     BMI   $C1B2
$C197: a5 f5     LDA   $F5
$C199: 29 cf     AND   #$CF
$C19B: f0 15     BEQ   $C1B2
$C19D: d9 b3 c1  CMP   $C1B3,Y
$C1A0: f0 05     BEQ   $C1A7
$C1A2: a9 ff     LDA   #$FF
$C1A4: 85 3f     STA   $3F
$C1A6: 60        RTS
$C1A7: c8        INY
$C1A8: 84 3f     STY   $3F
$C1AA: c0 0a     CPY   #$0A
$C1AC: 90 04     BCC   $C1B2
$C1AE: a9 01     LDA   #$01
$C1B0: 85 24     STA   $24
$C1B2: 60        RTS
$C1B3: 08 08 04 04 02 01 02 01 40 80 .byte $08 …
$C1BD: 20 f9 c1  JSR   $C1F9
$C1C0: a5 04     LDA   $04
$C1C2: 85 00     STA   $00
$C1C4: a5 05     LDA   $05
$C1C6: 85 01     STA   $01
$C1C8: 20 f9 c1  JSR   $C1F9
$C1CB: a2 01     LDX   #$01
$C1CD: b5 04     LDA   $04,X
$C1CF: d5 00     CMP   $00,X
$C1D1: f0 04     BEQ   $C1D7
$C1D3: b5 f9     LDA   $F9,X
$C1D5: 95 04     STA   $04,X
$C1D7: ca        DEX
$C1D8: 10 f3     BPL   $C1CD
$C1DA: a5 1d     LDA   $1D
$C1DC: 29 04     AND   #$04
$C1DE: d0 06     BNE   $C1E6
$C1E0: a5 04     LDA   $04
$C1E2: 05 05     ORA   $05
$C1E4: 85 04     STA   $04
$C1E6: a2 01     LDX   #$01
$C1E8: b5 04     LDA   $04,X
$C1EA: a8        TAY
$C1EB: 55 f9     EOR   $F9,X
$C1ED: 35 04     AND   $04,X
$C1EF: 95 f5     STA   $F5,X
$C1F1: 94 f1     STY   $F1,X
$C1F3: 94 f9     STY   $F9,X
$C1F5: ca        DEX
$C1F6: 10 f0     BPL   $C1E8
$C1F8: 60        RTS
$C1F9: a2 01     LDX   #$01
$C1FB: 8e 16 40  STX   $4016
$C1FE: ca        DEX
$C1FF: 8e 16 40  STX   $4016
$C202: a0 08     LDY   #$08
$C204: ad 16 40  LDA   $4016
$C207: 85 07     STA   $07
$C209: 4a        LSR
$C20A: 05 07     ORA   $07
$C20C: 4a        LSR
$C20D: 26 04     ROL   $04
$C20F: ad 17 40  LDA   $4017
$C212: 85 07     STA   $07
$C214: 4a        LSR
$C215: 05 07     ORA   $07
$C217: 4a        LSR
$C218: 26 05     ROL   $05
$C21A: 88        DEY
$C21B: d0 e7     BNE   $C204
$C21D: 60        RTS
$C21E: 20 75 c2  JSR   $C275
$C221: a5 f5     LDA   $F5
$C223: 29 30     AND   #$30
$C225: f0 30     BEQ   $C257
$C227: 20 8a c1  JSR   $C18A
$C22A: a6 18     LDX   $18
$C22C: e0 01     CPX   #$01
$C22E: d0 28     BNE   $C258
$C230: a6 19     LDX   $19
$C232: f0 30     BEQ   $C264
$C234: ca        DEX
$C235: d0 21     BNE   $C258
$C237: 29 20     AND   #$20
$C239: d0 11     BNE   $C24C
$C23B: a5 f1     LDA   $F1
$C23D: 29 c0     AND   #$C0
$C23F: c9 c0     CMP   #$C0
$C241: d0 04     BNE   $C247
$C243: a9 07     LDA   #$07
$C245: d0 02     BNE   $C249
$C247: a9 03     LDA   #$03
$C249: 4c 6f c1  JMP   $C16F
$C24C: e6 22     INC   $22
$C24E: a9 02     LDA   #$02
$C250: 38        SEC
$C251: e5 22     SBC   $22
$C253: d0 02     BNE   $C257
$C255: 85 22     STA   $22
$C257: 60        RTS
$C258: a9 00     LDA   #$00
$C25A: 85 23     STA   $23
$C25C: 20 43 c7  JSR   $C743
$C25F: a9 01     LDA   #$01
$C261: 20 6f c1  JSR   $C16F
$C264: a0 00     LDY   #$00
$C266: 84 40     STY   $40
$C268: c8        INY
$C269: 84 41     STY   $41
$C26B: 60        RTS
$C26C: a9 a4     LDA   #$A4
$C26E: 85 28     STA   $28
$C270: a9 3f     LDA   #$3F
$C272: 4c bc f9  JMP   $F9BC
$C275: a5 1a     LDA   $1A
$C277: 29 01     AND   #$01
$C279: d0 dc     BNE   $C257
$C27B: a5 28     LDA   $28
$C27D: f0 d8     BEQ   $C257
$C27F: c6 28     DEC   $28
$C281: 60        RTS
$C282: a0 03     LDY   #$03
$C284: 98        TYA
$C285: 29 01     AND   #$01
$C287: 8d e9 07  STA   $07E9
$C28A: ea        NOP
$C28B: ea        NOP
$C28C: ea        NOP
$C28D: ea        NOP
$C28E: ea        NOP
$C28F: ea        NOP
$C290: 29 01     AND   #$01
$C292: cd e9 07  CMP   $07E9
$C295: d0 05     BNE   $C29C
$C297: 88        DEY
$C298: 10 ea     BPL   $C284
$C29A: 30 03     BMI   $C29F
$C29C: 4c 00 00  JMP   $0000
$C29F: 20 07 c3  JSR   $C307
$C2A2: a9 07     LDA   #$07
$C2A4: 85 1d     STA   $1D
$C2A6: a9 00     LDA   #$00
$C2A8: 85 1a     STA   $1A
$C2AA: 85 34     STA   $34
$C2AC: a5 27     LDA   $27
$C2AE: c9 03     CMP   #$03
$C2B0: 90 02     BCC   $C2B4
$C2B2: a9 00     LDA   #$00
$C2B4: 85 27     STA   $27
$C2B6: 85 30     STA   $30
$C2B8: e6 27     INC   $27
$C2BA: a9 62     LDA   #$62
$C2BC: 85 32     STA   $32
$C2BE: 85 33     STA   $33
$C2C0: 60        RTS
$C2C1: 20 07 c3  JSR   $C307
$C2C4: 85 27     STA   $27
$C2C6: a9 03     LDA   #$03
$C2C8: 85 3a     STA   $3A
$C2CA: ad ea 07  LDA   $07EA
$C2CD: 85 30     STA   $30
$C2CF: a2 03     LDX   #$03
$C2D1: a9 00     LDA   #$00
$C2D3: 9d e2 07  STA   $07E2,X
$C2D6: ca        DEX
$C2D7: 10 fa     BPL   $C2D3
$C2D9: 85 1c     STA   $1C
$C2DB: 85 38     STA   $38
$C2DD: a6 22     LDX   $22
$C2DF: bd 03 c3  LDA   $C303,X
$C2E2: 85 1d     STA   $1D
$C2E4: bd 05 c3  LDA   $C305,X
$C2E7: 85 39     STA   $39
$C2E9: a9 02     LDA   #$02
$C2EB: a4 24     LDY   $24
$C2ED: f0 02     BEQ   $C2F1
$C2EF: a9 1d     LDA   #$1D
$C2F1: 95 32     STA   $32,X
$C2F3: ca        DEX
$C2F4: 10 f3     BPL   $C2E9
$C2F6: a9 c8     LDA   #$C8
$C2F8: 85 3c     STA   $3C
$C2FA: 85 3e     STA   $3E
$C2FC: a9 00     LDA   #$00
$C2FE: 85 3d     STA   $3D
$C300: 85 3f     STA   $3F
$C302: 60        RTS
$C303: 01 07 01 00 .byte $01 …
$C307: a2 28     LDX   #$28
$C309: a9 00     LDA   #$00
$C30B: 95 00     STA   $00,X
$C30D: e8        INX
$C30E: e0 f0     CPX   #$F0
$C310: d0 f9     BNE   $C30B
$C312: a2 07     LDX   #$07
$C314: a0 03     LDY   #$03
$C316: 84 01     STY   $01
$C318: 85 00     STA   $00
$C31A: a0 00     LDY   #$00
$C31C: 91 00     STA   ($00),Y
$C31E: c8        INY
$C31F: d0 fb     BNE   $C31C
$C321: e6 01     INC   $01
$C323: e4 01     CPX   $01
$C325: d0 f5     BNE   $C31C
$C327: 60        RTS
$C328: a9 00     LDA   #$00
$C32A: a2 06     LDX   #$06
$C32C: d0 e6     BNE   $C314
$C32E: a2 40     LDX   #$40
$C330: a9 00     LDA   #$00
$C332: 95 00     STA   $00,X
$C334: e8        INX
$C335: e0 50     CPX   #$50
$C337: d0 f9     BNE   $C332
$C339: f0 ed     BEQ   $C328
$C33B: a5 1c     LDA   $1C
$C33D: d0 e8     BNE   $C327
$C33F: a9 00     LDA   #$00
$C341: 85 01     STA   $01
$C343: 98        TYA
$C344: 85 02     STA   $02
$C346: 0a        ASL
$C347: a8        TAY
$C348: a5 00     LDA   $00
$C34A: 79 e2 07  ADC   $07E2,Y
$C34D: 99 e2 07  STA   $07E2,Y
$C350: a5 01     LDA   $01
$C352: 79 e3 07  ADC   $07E3,Y
$C355: 90 05     BCC   $C35C
$C357: a9 ff     LDA   #$FF
$C359: 99 e2 07  STA   $07E2,Y
$C35C: 99 e3 07  STA   $07E3,Y
$C35F: a6 01     LDX   $01
$C361: f0 05     BEQ   $C368
$C363: a9 88     LDA   #$88
$C365: 18        CLC
$C366: 90 18     BCC   $C380
$C368: d9 3d 00  CMP   $003D,Y
$C36B: 90 45     BCC   $C3B2
$C36D: d0 08     BNE   $C377
$C36F: b9 e2 07  LDA   $07E2,Y
$C372: d9 3c 00  CMP   $003C,Y
$C375: 90 3b     BCC   $C3B2
$C377: b9 3d 00  LDA   $003D,Y
$C37A: c9 75     CMP   #$75
$C37C: b0 34     BCS   $C3B2
$C37E: a9 2c     LDA   #$2C
$C380: 79 3c 00  ADC   $003C,Y
$C383: 99 3c 00  STA   $003C,Y
$C386: a9 01     LDA   #$01
$C388: a6 01     LDX   $01
$C38A: f0 02     BEQ   $C38E
$C38C: a9 13     LDA   #$13
$C38E: 79 3d 00  ADC   $003D,Y
$C391: 90 05     BCC   $C398
$C393: a9 ff     LDA   #$FF
$C395: 99 3c 00  STA   $003C,Y
$C398: 99 3d 00  STA   $003D,Y
$C39B: a6 02     LDX   $02
$C39D: f6 32     INC   $32,X
$C39F: b5 32     LDA   $32,X
$C3A1: c9 63     CMP   #$63
$C3A3: 90 02     BCC   $C3A7
$C3A5: a9 63     LDA   #$63
$C3A7: 95 32     STA   $32,X
$C3A9: a5 01     LDA   $01
$C3AB: d0 05     BNE   $C3B2
$C3AD: a9 39     LDA   #$39
$C3AF: 20 bc f9  JSR   $F9BC
$C3B2: b9 e3 07  LDA   $07E3,Y
$C3B5: cd e1 07  CMP   $07E1
$C3B8: 90 16     BCC   $C3D0
$C3BA: d0 08     BNE   $C3C4
$C3BC: b9 e2 07  LDA   $07E2,Y
$C3BF: cd e0 07  CMP   $07E0
$C3C2: 90 0c     BCC   $C3D0
$C3C4: b9 e2 07  LDA   $07E2,Y
$C3C7: 8d e0 07  STA   $07E0
$C3CA: b9 e3 07  LDA   $07E3,Y
$C3CD: 8d e1 07  STA   $07E1
$C3D0: 60        RTS
$C3D1: 85 11 a5 21 c9 40 b0 f7 20 56 c6 a6 21 a5 30 a4 .byte $85 …
$C3E1: 40 10 02 a9 08 0a 0a a8 b9 6e c5 85 16 b9 6f c5 .byte $40 …
$C3F1: 85 17 a5 0f d0 19 b9 70 c5 85 0e b9 71 c5 85 0f .byte $85 …
$C401: a4 10 a5 00 d0 64 20 d7 c6 b1 0e 9d 00 07 e8 a9 .byte $A4 …
$C411: 00 85 11 a5 10 0a 0a 26 11 0a 26 11 0a 26 11 65 .byte $00 …
$C421: 16 85 16 a5 11 65 17 85 17 a9 01 9d 00 07 e8 a9 .byte $16 …
$C431: 04 85 14 9d 00 07 e8 9d 00 07 e8 a0 00 a5 0d 9d .byte $04 …
$C441: 00 07 e8 a5 0c 9d 00 07 e8 b1 16 9d 00 07 e8 c8 .byte $00 …
$C451: 98 29 03 d0 f4 a5 0c 18 69 20 85 0c a5 0d 69 00 .byte $98 …
$C461: 85 0d c6 14 d0 d7 86 21 18 60 aa b1 0e ca 86 01 .byte $85 …
$C471: d0 29 aa 29 33 0a 0a 85 08 8a 29 cc 4a 4a 85 09 .byte $D0 …
$C481: a6 02 bc 00 06 b1 46 29 33 05 08 85 08 bc 01 06 .byte $A6 …
$C491: b1 46 29 cc 05 09 85 09 4c 16 c5 ca d0 2d a2 00 .byte $B1 …
$C4A1: 86 09 0a 26 09 0a 26 09 0a 26 09 0a 26 09 85 08 .byte $86 …
$C4B1: a6 02 bc 00 06 b1 46 29 0f 05 08 85 08 bc 08 06 .byte $A6 …
$C4C1: b1 46 29 f0 05 09 85 09 4c 16 c5 a2 00 86 08 86 .byte $B1 …
$C4D1: 0b 4a 66 08 4a 66 08 29 0c 85 0a b1 0e 0a 26 0b .byte $0B …
$C4E1: 0a 26 0b 29 30 85 09 a6 02 bc 00 06 b1 46 29 3f .byte $0A …
$C4F1: 05 08 85 08 bc 01 06 b1 46 29 cf 05 09 85 09 bc .byte $05 …
$C501: 08 06 b1 46 29 f3 05 0a 85 0a bc 09 06 b1 46 29 .byte $08 …
$C511: fc 05 0b 85 0b a5 01 0a a8 a6 21 a9 01 9d 00 07 .byte $FC …
$C521: e8 b9 68 c5 9d 00 07 e8 b9 69 c5 9d 00 07 e8 a0 .byte $E8 …
$C531: 00 a5 15 9d 00 07 e8 a5 14 9d 00 07 e8 b9 08 00 .byte $00 …
$C541: 9d 00 07 e8 a5 00 c9 02 f0 08 c8 b9 08 00 9d 00 .byte $9D …
$C551: 07 e8 a5 01 f0 0e c8 a5 14 18 69 08 85 14 a9 00 .byte $07 …
$C561: 85 01 f0 cd 4c 10 c4 02 01 01 02 02 02 b1 83 fc .byte $85 …
$C571: 86 f8 88 e1 8e b8 93 df 96 f8 88 e1 8e 28 9c 39 .byte $86 …
$C581: 9e 2e a5 e7 a5 6a ac 2e ae da b2 53 b6 2a bb d4 .byte $9E …
$C591: be 60 85 11 a5 21 c9 50 b0 f7 20 56 c6 a5 10 0a .byte $BE …
$C5A1: 0a 65 10 a8 a5 30 0a aa bd 3a c6 85 16 bd 3b c6 .byte $0A …
$C5B1: 85 17 a2 02 b1 16 10 03 29 07 aa 86 14 a6 21 a5 .byte $85 …
$C5C1: 0f d0 33 b1 16 84 0e a4 00 f0 0c 88 f0 07 88 f0 .byte $0F …
$C5D1: 02 0a 0a 0a 0a 0a 0a 85 08 a6 02 bc 00 06 b1 46 .byte $02 …
$C5E1: a4 00 39 52 c6 05 08 85 08 a6 21 20 d7 c6 a5 08 .byte $A4 …
$C5F1: 9d 00 07 e8 a4 0e c8 a9 01 9d 00 07 e8 a9 02 9d .byte $9D …
$C601: 00 07 e8 a5 14 9d 00 07 e8 a9 02 85 15 a5 0d 9d .byte $00 …
$C611: 00 07 e8 a5 0c 9d 00 07 e8 b1 16 9d 00 07 e8 c8 .byte $00 …
$C621: c6 15 d0 f5 a5 0c 18 69 20 85 0c a5 0d 69 00 85 .byte $C6 …
$C631: 0d c6 14 d0 d4 86 21 18 60 01 80 31 87 48 8f 31 .byte $0D …
$C641: 87 18 97 58 9e ee a5 4a ae 8a b6 20 24 23 27 00 .byte $87 …
$C651: 40 fc f3 cf 3f a5 10 29 80 85 0f a5 10 29 7f 85 .byte $40 …
$C661: 10 98 18 65 fc b0 04 c9 f0 90 02 69 0f 29 f8 85 .byte $10 …
$C671: 12 4a 4a a8 4a 29 02 85 00 98 29 38 85 14 a9 00 .byte $12 …
$C681: 06 12 2a 06 12 2a 85 13 a5 11 18 65 fd 85 11 a5 .byte $06 …
$C691: ff 29 01 90 02 49 01 a8 b9 4e c6 09 03 85 15 b9 .byte $FF …
$C6A1: 4c c6 05 13 85 13 85 0d b9 50 c6 85 02 a5 11 29 .byte $4C …
$C6B1: f8 4a 4a 4a a8 4a aa 29 01 05 00 85 00 8a 4a 05 .byte $F8 …
$C6C1: 14 85 03 18 69 c0 85 14 98 05 12 85 12 85 0c a5 .byte $14 …
$C6D1: 02 05 03 85 02 60 a9 01 9d 00 07 e8 9d 00 07 e8 .byte $02 …
$C6E1: 9d 00 07 e8 a5 15 9d 00 07 e8 a5 14 9d 00 07 e8 .byte $9D …
$C6F1: 60        .byte $60
$C6F2: 0a        ASL
$C6F3: 84 03     STY   $03
$C6F5: a8        TAY
$C6F6: c8        INY
$C6F7: 68        PLA
$C6F8: 85 00     STA   $00
$C6FA: 68        PLA
$C6FB: 85 01     STA   $01
$C6FD: b1 00     LDA   ($00),Y
$C6FF: 85 02     STA   $02
$C701: c8        INY
$C702: b1 00     LDA   ($00),Y
$C704: a4 03     LDY   $03
$C706: 85 03     STA   $03
$C708: 6c 02 00  JMP   ($0002)
$C70B: 86 00 84 01 .byte $86 …
$C70F: a9 00     LDA   #$00
$C711: 85 02     STA   $02
$C713: a0 10     LDY   #$10
$C715: 26 00     ROL   $00
$C717: 26 01     ROL   $01
$C719: 26 02     ROL   $02
$C71B: a5 02     LDA   $02
$C71D: c5 03     CMP   $03
$C71F: 90 04     BCC   $C725
$C721: e5 03     SBC   $03
$C723: 85 02     STA   $02
$C725: 26 00     ROL   $00
$C727: 26 01     ROL   $01
$C729: 88        DEY
$C72A: d0 ed     BNE   $C719
$C72C: 60        RTS
$C72D: 18        CLC
$C72E: 75 00     ADC   $00,X
$C730: 95 00     STA   $00,X
$C732: 90 02     BCC   $C736
$C734: f6 01     INC   $01,X
$C736: 60        RTS
$C737: 49 ff 38 75 00 95 00 b0 02 d6 01 60 .byte $49 …
$C743: 20 10 c9  JSR   $C910
$C746: 20 d4 f9  JSR   $F9D4
$C749: 20 07 c3  JSR   $C307
$C74C: a9 1e     LDA   #$1E
$C74E: 85 fe     STA   $FE
$C750: a0 00     LDY   #$00
$C752: 84 37     STY   $37
$C754: c8        INY
$C755: 84 1c     STY   $1C
$C757: a9 0b     LDA   #$0B
$C759: 20 78 c7  JSR   $C778
$C75C: a2 02     LDX   #$02
$C75E: 20 12 c9  JSR   $C912
$C761: a9 06     LDA   #$06
$C763: 20 c5 ca  JSR   $CAC5
$C766: a9 00     LDA   #$00
$C768: 85 40     STA   $40
$C76A: 4c 8a c1  JMP   $C18A
$C76D: 60        .byte $60
$C76E: a4 30     LDY   $30
$C770: b9 8b c7  LDA   $C78B,Y
$C773: d0 03     BNE   $C778
$C775: 60        RTS
$C776: a5 30     LDA   $30
$C778: 0a        ASL
$C779: 0a        ASL
$C77A: 0a        ASL
$C77B: a8        TAY
$C77C: a2 00     LDX   #$00
$C77E: b9 93 c7  LDA   $C793,Y
$C781: 9d f0 07  STA   $07F0,X
$C784: c8        INY
$C785: e8        INX
$C786: e0 08     CPX   #$08
$C788: d0 f4     BNE   $C77E
$C78A: 60        RTS
$C78B: 0d 00 0e 00 0f 10 00 11 04 04 06 07 44 45 46 47 .byte $0D …
$C79B: 3e 05 08 09 48 49 4a 4b 04 04 0a 0b 60 61 46 63 .byte $3E …
$C7AB: 3e 05 08 09 48 49 68 4b 04 04 0e 0f 50 51 52 53 .byte $3E …
$C7BB: 04 04 10 11 54 55 56 57 04 04 12 13 58 59 5a 5b .byte $04 …
$C7CB: 04 04 14 15 5c 5d 5e 5f 3e 05 0c 0d 4c 4d 4e 4f .byte $04 …
$C7DB: 3e 05 18 0d 4c 4d 4e 4f 1a 00 1a 1b 00 26 27 28 .byte $3E …
$C7EB: 18 19 1a 1b 40 41 42 43 04 04 02 03 00 1d 00 3a .byte $18 …
$C7FB: 04 04 06 07 44 45 67 62 04 04 0a 0b 60 71 72 73 .byte $04 …
$C80B: 04 04 0e 0f 50 51 6b 53 04 04 16 17 54 55 56 57 .byte $04 …
$C81B: 04 04 14 15 5c 5d 70 77 32 33 32 32 7a 29 2a 2b .byte $04 …
$C82B: 32 33 32 32 7a 2c 2d 2e 04 04 31 1e 37 38 39 3a .byte $32 …
$C83B: a5 6a     LDA   $6A
$C83D: d0 19     BNE   $C858
$C83F: c6 5c     DEC   $5C
$C841: 10 24     BPL   $C867
$C843: a5 30     LDA   $30
$C845: 20 f2 c6  JSR   $C6F2
$C848: 68        PLA
$C849: c8        INY
$C84A: 71 c8     ADC   ($C8),Y
$C84C: 79 c8 71  ADC   $71C8,Y
$C84F: c8        INY
$C850: 86 c8     STX   $C8
$C853: c8 67 c8 92 c8 .byte $C8 …
$C858: a9 80     LDA   #$80
$C85A: 85 6a     STA   $6A
$C85C: a9 4b     LDA   #$4B
$C85E: a2 03     LDX   #$03
$C860: 9d f4 07  STA   $07F4,X
$C863: a9 00     LDA   #$00
$C865: 85 5c     STA   $5C
$C867: 60        RTS
$C868: a5 34     LDA   $34
$C86A: 29 07     AND   #$07
$C86C: 18        CLC
$C86D: 69 04     ADC   #$04
$C86F: d0 3a     BNE   $C8AB
$C871: a5 40     LDA   $40
$C873: 30 f2     BMI   $C867
$C875: a9 04     LDA   #$04
$C877: d0 32     BNE   $C8AB
$C879: a5 48     LDA   $48
$C87B: 30 ea     BMI   $C867
$C87D: a5 34     LDA   $34
$C87F: 29 01     AND   #$01
$C881: 18        CLC
$C882: 69 06     ADC   #$06
$C884: d0 25     BNE   $C8AB
$C886: a5 34     LDA   $34
$C888: 29 03     AND   #$03
$C88A: 18        CLC
$C88B: 69 01     ADC   #$01
$C88D: 65 5d     ADC   $5D
$C88F: 4c ab c8  JMP   $C8AB
$C892: a5 5d     LDA   $5D
$C894: f0 04     BEQ   $C89A
$C896: e6 5d     INC   $5D
$C898: d0 11     BNE   $C8AB
$C89A: a9 0c     LDA   #$0C
$C89C: 38        SEC
$C89D: e5 64     SBC   $64
$C89F: d0 0a     BNE   $C8AB
$C8A1: a5 1a     LDA   $1A
$C8A3: 29 07     AND   #$07
$C8A5: d0 c0     BNE   $C867
$C8A7: a9 08     LDA   #$08
$C8A9: d0 04     BNE   $C8AF
$C8AB: 85 5c     STA   $5C
$C8AD: a5 30     LDA   $30
$C8AF: 85 00     STA   $00
$C8B1: 0a        ASL
$C8B2: 0a        ASL
$C8B3: 65 00     ADC   $00
$C8B5: a8        TAY
$C8B6: be df c8  LDX   $C8DF,Y
$C8B9: c6 71     DEC   $71
$C8BB: 10 04     BPL   $C8C1
$C8BD: a9 03     LDA   #$03
$C8BF: 85 71     STA   $71
$C8C1: 98        TYA
$C8C2: 18        CLC
$C8C3: 65 71     ADC   $71
$C8C5: a8        TAY
$C8C6: b9 e0 c8  LDA   $C8E0,Y
$C8C9: 9d f4 07  STA   $07F4,X
$C8CC: a5 30     LDA   $30
$C8CE: c9 07     CMP   #$07
$C8D0: d0 0c     BNE   $C8DE
$C8D2: a5 48     LDA   $48
$C8D4: 30 08     BMI   $C8DE
$C8D6: a4 71     LDY   $71
$C8D8: b9 0c c9  LDA   $C90C,Y
$C8DB: 8d f7 07  STA   $07F7
$C8DE: 60        RTS
$C8DF: 01 22 21 20 45 03 69 6a 69 6a 03 25 24 23 63 03 .byte $01 …
$C8EF: 69 6a 69 6a 01 6e 6d 6c 51 00 40 41 42 43 00 00 .byte $69 …
$C8FF: 00 00 00 00 76 75 74 5c 02 66 65 64 42 36 35 34 .byte $00 …
$C90F: 5f        .byte $5F
$C910: a2 00     LDX   #$00
$C912: a0 03     LDY   #$03
$C914: 98        TYA
$C915: 29 01     AND   #$01
$C917: 8d e9 07  STA   $07E9
$C91A: ea        NOP
$C91B: ea        NOP
$C91C: ea        NOP
$C91D: ea        NOP
$C91E: ea        NOP
$C91F: ea        NOP
$C920: 29 01     AND   #$01
$C922: cd e9 07  CMP   $07E9
$C925: d0 05     BNE   $C92C
$C927: 88        DEY
$C928: 10 ea     BPL   $C914
$C92A: 30 03     BMI   $C92F
$C92C: 4c 00 00  JMP   $0000
$C92F: a0 18     LDY   #$18
$C931: 20 89 f9  JSR   $F989
$C934: 20 3a c9  JSR   $C93A
$C937: 4c 97 f9  JMP   $F997
$C93A: bd b1 c9  LDA   $C9B1,X
$C93D: 85 00     STA   $00
$C93F: bd b2 c9  LDA   $C9B2,X
$C942: 85 01     STA   $01
$C944: 20 46 f9  JSR   $F946
$C947: 85 21     STA   $21
$C949: 85 fc     STA   $FC
$C94B: 85 fd     STA   $FD
$C94D: ad 02 20  LDA   $2002
$C950: a0 01     LDY   #$01
$C952: b1 00     LDA   ($00),Y
$C954: 8d 06 20  STA   $2006
$C957: 88        DEY
$C958: b1 00     LDA   ($00),Y
$C95A: 8d 06 20  STA   $2006
$C95D: a9 02     LDA   #$02
$C95F: a2 00     LDX   #$00
$C961: 20 2d c7  JSR   $C72D
$C964: a0 00     LDY   #$00
$C966: b1 00     LDA   ($00),Y
$C968: c9 ff     CMP   #$FF
$C96A: f0 42     BEQ   $C9AE
$C96C: c9 7f     CMP   #$7F
$C96E: f0 34     BEQ   $C9A4
$C970: a8        TAY
$C971: 10 1f     BPL   $C992
$C973: 29 7f     AND   #$7F
$C975: 85 02     STA   $02
$C977: a0 01     LDY   #$01
$C979: b1 00     LDA   ($00),Y
$C97B: 8d 07 20  STA   $2007
$C97E: c4 02     CPY   $02
$C980: f0 03     BEQ   $C985
$C982: c8        INY
$C983: d0 f4     BNE   $C979
$C985: a9 01     LDA   #$01
$C987: 18        CLC
$C988: 65 02     ADC   $02
$C98A: a2 00     LDX   #$00
$C98C: 20 2d c7  JSR   $C72D
$C98F: 4c 64 c9  JMP   $C964
$C992: a0 01     LDY   #$01
$C994: 85 02     STA   $02
$C996: b1 00     LDA   ($00),Y
$C998: a4 02     LDY   $02
$C99A: 8d 07 20  STA   $2007
$C99D: 88        DEY
$C99E: d0 fa     BNE   $C99A
$C9A0: a9 02     LDA   #$02
$C9A2: d0 e6     BNE   $C98A
$C9A4: a9 01     LDA   #$01
$C9A6: a2 00     LDX   #$00
$C9A8: 20 2d c7  JSR   $C72D
$C9AB: 4c 4d c9  JMP   $C94D
$C9AE: 4c 16 f9  JMP   $F916
$C9B1: 9b ca 01 ac df 8e e0 99 62 9a d6 9a b6 91 d3 85 .byte $9B …
$C9C1: 83 a4 4b a5 c1 8c df 8e a9 1e 85 02 a9 07 18 65 .byte $83 …
$C9D1: 1e 20 c5 ca a6 1e b5 38 49 01 18 75 32 f0 30 10 .byte $1E …
$C9E1: 02 a9 00 a2 00 85 00 c9 0a 90 0a e9 0a e8 e0 0a .byte $02 …
$C9F1: 90 f3 a2 09 8a a4 21 18 69 01 e0 00 d0 04 c9 01 .byte $90 …
$CA01: f0 0c 99 fe 06 8a f0 06 18 69 01 99 fd 06 .byte $F0 …
$CA0F: 60        RTS
$CA10: 8a 18 69 0f 4c c5 ca a9 0c 20 c5 ca a5 30 18 69 .byte $8A …
$CA20: 02 9d fc 06 a5 30 69 11 4c c5 ca .byte $02 …
$CA2B: a9 09     LDA   #$09
$CA2D: 20 c5 ca  JSR   $CAC5
$CA30: ad e0 07  LDA   $07E0
$CA33: 85 00     STA   $00
$CA35: ad e1 07  LDA   $07E1
$CA38: 85 01     STA   $01
$CA3A: 20 62 ca  JSR   $CA62
$CA3D: a9 0a     LDA   #$0A
$CA3F: 20 c5 ca  JSR   $CAC5
$CA42: ad e2 07  LDA   $07E2
$CA45: 85 00     STA   $00
$CA47: ad e3 07  LDA   $07E3
$CA4A: 85 01     STA   $01
$CA4C: 20 62 ca  JSR   $CA62
$CA4F: a5 22     LDA   $22
$CA51: f0 bc     BEQ   $CA0F
$CA53: a9 0b     LDA   #$0B
$CA55: 20 c5 ca  JSR   $CAC5
$CA58: ad e4 07  LDA   $07E4
$CA5B: 85 00     STA   $00
$CA5D: ad e5 07  LDA   $07E5
$CA60: 85 01     STA   $01
$CA62: a9 05     LDA   #$05
$CA64: 85 04     STA   $04
$CA66: a9 0a     LDA   #$0A
$CA68: 85 03     STA   $03
$CA6A: 20 0f c7  JSR   $C70F
$CA6D: a5 02     LDA   $02
$CA6F: 18        CLC
$CA70: 69 01     ADC   #$01
$CA72: 9d fc 06  STA   $06FC,X
$CA75: ca        DEX
$CA76: a5 00     LDA   $00
$CA78: 05 01     ORA   $01
$CA7A: f0 04     BEQ   $CA80
$CA7C: c6 04     DEC   $04
$CA7E: d0 e6     BNE   $CA66
$CA80: a6 21     LDX   $21
$CA82: a5 04     LDA   $04
$CA84: 38        SEC
$CA85: e9 05     SBC   #$05
$CA87: 05 02     ORA   $02
$CA89: f0 09     BEQ   $CA94
$CA8B: a9 01     LDA   #$01
$CA8D: 9d fd 06  STA   $06FD,X
$CA90: 9d fe 06  STA   $06FE,X
$CA93: 60        RTS
$CA94: 9d fc 06  STA   $06FC,X
$CA97: a9 01     LDA   #$01
$CA99: d0 f5     BNE   $CA90
$CA9B: 00        BRK
$CA9C: 20 78 00 78 00 78 00 78 00 78 00 78 00 78 00 78 .byte $20 …
$CAAC: 00 40 00 7f 00 24 78 00 78 00 78 00 78 00 78 00 .byte $00 …
$CABC: 78 00 78 00 78 00 40 00 ff .byte $78 …
$CAC5: 48        PHA
$CAC6: a9 02     LDA   #$02
$CAC8: 85 03     STA   $03
$CACA: a9 01     LDA   #$01
$CACC: 20 22 cb  JSR   $CB22
$CACF: 68        PLA
$CAD0: 85 02     STA   $02
$CAD2: 0a        ASL
$CAD3: aa        TAX
$CAD4: bd 78 f5  LDA   $F578,X
$CAD7: 85 00     STA   $00
$CAD9: bd 79 f5  LDA   $F579,X
$CADC: 85 01     STA   $01
$CADE: a6 21     LDX   $21
$CAE0: a0 00     LDY   #$00
$CAE2: b1 00     LDA   ($00),Y
$CAE4: c8        INY
$CAE5: c9 ff     CMP   #$FF
$CAE7: f0 3f     BEQ   $CB28
$CAE9: c9 fe     CMP   #$FE
$CAEB: f0 19     BEQ   $CB06
$CAED: c9 fd     CMP   #$FD
$CAEF: f0 19     BEQ   $CB0A
$CAF1: 9d 00 07  STA   $0700,X
$CAF4: a5 02     LDA   $02
$CAF6: 10 0b     BPL   $CB03
$CAF8: a5 03     LDA   $03
$CAFA: d0 05     BNE   $CB01
$CAFC: 9d 00 07  STA   $0700,X
$CAFF: f0 02     BEQ   $CB03
$CB01: c6 03     DEC   $03
$CB03: e8        INX
$CB04: d0 dc     BNE   $CAE2
$CB06: a9 ff     LDA   #$FF
$CB08: d0 1a     BNE   $CB24
$CB0A: a9 ff     LDA   #$FF
$CB0C: 20 24 cb  JSR   $CB24
$CB0F: a9 02     LDA   #$02
$CB11: 85 03     STA   $03
$CB13: a9 01     LDA   #$01
$CB15: 20 24 cb  JSR   $CB24
$CB18: d0 c8     BNE   $CAE2
$CB1A: a9 ff     LDA   #$FF
$CB1C: d0 04     BNE   $CB22
$CB1E: a9 00     LDA   #$00
$CB20: f0 00     BEQ   $CB22
$CB22: a6 21     LDX   $21
$CB24: 9d 00 07  STA   $0700,X
$CB27: e8        INX
$CB28: 86 21     STX   $21
$CB2A: 60        RTS
$CB2B: 00 04 00 00 04 .byte $00 …
$CB30: a5 23     LDA   $23
$CB32: f0 03     BEQ   $CB37
$CB34: 4c c0 cb  JMP   $CBC0
$CB37: a0 00     LDY   #$00
$CB39: 84 08     STY   $08
$CB3B: a5 08     LDA   $08
$CB3D: c9 3f     CMP   #$3F
$CB3F: d0 0e     BNE   $CB4F
$CB41: 8d 06 20  STA   $2006
$CB44: a9 00     LDA   #$00
$CB46: 8d 06 20  STA   $2006
$CB49: 8d 06 20  STA   $2006
$CB4C: 8d 06 20  STA   $2006
$CB4F: be 00 07  LDX   $0700,Y
$CB52: f0 38     BEQ   $CB8C
$CB54: a5 ff     LDA   $FF
$CB56: 29 18     AND   #$18
$CB58: 1d 2a cb  ORA   $CB2A,X
$CB5B: 8d 00 20  STA   $2000
$CB5E: c8        INY
$CB5F: ad 02 20  LDA   $2002
$CB62: b9 00 07  LDA   $0700,Y
$CB65: 85 08     STA   $08
$CB67: 8d 06 20  STA   $2006
$CB6A: c8        INY
$CB6B: b9 00 07  LDA   $0700,Y
$CB6E: 8d 06 20  STA   $2006
$CB71: c8        INY
$CB72: e0 03     CPX   #$03
$CB74: f0 06     BEQ   $CB7C
$CB76: e0 04     CPX   #$04
$CB78: b0 35     BCS   $CBAF
$CB7A: d0 22     BNE   $CB9E
$CB7C: b9 00 07  LDA   $0700,Y
$CB7F: 85 09     STA   $09
$CB81: c8        INY
$CB82: b9 00 07  LDA   $0700,Y
$CB85: 8d 07 20  STA   $2007
$CB88: c6 09     DEC   $09
$CB8A: d0 f5     BNE   $CB81
$CB8C: a9 00     LDA   #$00
$CB8E: 8d 00 07  STA   $0700
$CB91: 85 21     STA   $21
$CB93: a5 ff     LDA   $FF
$CB95: 8d 00 20  STA   $2000
$CB98: 60        RTS
$CB99: a9 ff     LDA   #$FF
$CB9B: 8d 07 20  STA   $2007
$CB9E: b9 00 07  LDA   $0700,Y
$CBA1: c8        INY
$CBA2: c9 ff     CMP   #$FF
$CBA4: d0 f5     BNE   $CB9B
$CBA6: b9 00 07  LDA   $0700,Y
$CBA9: c9 06     CMP   #$06
$CBAB: b0 ec     BCS   $CB99
$CBAD: 90 8c     BCC   $CB3B
$CBAF: be 00 07  LDX   $0700,Y
$CBB2: c8        INY
$CBB3: b9 00 07  LDA   $0700,Y
$CBB6: c8        INY
$CBB7: 8d 07 20  STA   $2007
$CBBA: ca        DEX
$CBBB: d0 fa     BNE   $CBB7
$CBBD: 4c 3b cb  JMP   $CB3B
$CBC0: a2 00     LDX   #$00
$CBC2: a5 ff     LDA   $FF
$CBC4: 29 18     AND   #$18
$CBC6: 85 02     STA   $02
$CBC8: bc 00 07  LDY   $0700,X
$CBCB: f0 bf     BEQ   $CB8C
$CBCD: a5 02     LDA   $02
$CBCF: 19 2a cb  ORA   $CB2A,Y
$CBD2: 8d 00 20  STA   $2000
$CBD5: e8        INX
$CBD6: bd 00 07  LDA   $0700,X
$CBD9: 85 00     STA   $00
$CBDB: e8        INX
$CBDC: bd 00 07  LDA   $0700,X
$CBDF: 85 01     STA   $01
$CBE1: a4 00     LDY   $00
$CBE3: e8        INX
$CBE4: bd 00 07  LDA   $0700,X
$CBE7: 8d 06 20  STA   $2006
$CBEA: e8        INX
$CBEB: bd 00 07  LDA   $0700,X
$CBEE: 8d 06 20  STA   $2006
$CBF1: e8        INX
$CBF2: bd 00 07  LDA   $0700,X
$CBF5: 8d 07 20  STA   $2007
$CBF8: 88        DEY
$CBF9: d0 f6     BNE   $CBF1
$CBFB: c6 01     DEC   $01
$CBFD: d0 e2     BNE   $CBE1
$CBFF: e8        INX
$CC00: d0 c6     BNE   $CBC8
$CC02: a6 36     LDX   $36
$CC04: f0 32     BEQ   $CC38
$CC06: a5 21     LDA   $21
$CC08: c9 47     CMP   #$47
$CC0A: b0 2c     BCS   $CC38
$CC0C: a5 ff     LDA   $FF
$CC0E: 29 18     AND   #$18
$CC10: 8d 00 20  STA   $2000
$CC13: a9 3f     LDA   #$3F
$CC15: 8d 06 20  STA   $2006
$CC18: a9 00     LDA   #$00
$CC1A: 8d 06 20  STA   $2006
$CC1D: a8        TAY
$CC1E: b9 c0 07  LDA   $07C0,Y
$CC21: 8d 07 20  STA   $2007
$CC24: c8        INY
$CC25: ca        DEX
$CC26: d0 f6     BNE   $CC1E
$CC28: a9 3f     LDA   #$3F
$CC2A: 8d 06 20  STA   $2006
$CC2D: 8e 06 20  STX   $2006
$CC30: 8e 06 20  STX   $2006
$CC33: 8e 06 20  STX   $2006
$CC36: 86 36     STX   $36
$CC38: 60        RTS
$CC39: a5 2c     LDA   $2C
$CC3B: c9 04     CMP   #$04
$CC3D: d0 05     BNE   $CC44
$CC3F: 20 62 fa  JSR   $FA62
$CC42: a5 2c     LDA   $2C
$CC44: 20 f2 c6  JSR   $C6F2
$CC48: cc c6 fa 7d cc c0 cc cc cc 1f cd af cd f1 cd f8 .byte $CC …
$CC58: cd 3a ce a6 fa 4f ce .byte $CD …
$CC5F: a9 1e     LDA   #$1E
$CC61: 85 fe     STA   $FE
$CC63: 20 d4 f9  JSR   $F9D4
$CC66: a9 0a     LDA   #$0A
$CC68: 20 78 c7  JSR   $C778
$CC6B: 20 50 fb  JSR   $FB50
$CC6E: a9 06     LDA   #$06
$CC70: 20 c5 ca  JSR   $CAC5
$CC73: 20 2a fa  JSR   $FA2A
$CC76: e6 2c     INC   $2C
$CC78: a9 00     LDA   #$00
$CC7A: 85 2d     STA   $2D
$CC7C: 60        RTS
$CC7D: 20 28 c3  JSR   $C328
$CC80: 20 10 c9  JSR   $C910
$CC83: 20 76 c7  JSR   $C776
$CC86: a0 14     LDY   #$14
$CC88: 20 89 f9  JSR   $F989
$CC8B: 20 16 a8  JSR   $A816
$CC8E: 20 d3 da  JSR   $DAD3
$CC91: a9 20     LDA   #$20
$CC93: 20 e3 ce  JSR   $CEE3
$CC96: a5 30     LDA   $30
$CC98: 0a        ASL
$CC99: a8        TAY
$CC9A: b9 b0 cc  LDA   $CCB0,Y
$CC9D: 85 fc     STA   $FC
$CC9F: a5 1c     LDA   $1C
$CCA1: d0 06     BNE   $CCA9
$CCA3: b9 b1 cc  LDA   $CCB1,Y
$CCA6: 20 bc f9  JSR   $F9BC
$CCA9: a0 ff     LDY   #$FF
$CCAB: 84 23     STY   $23
$CCAD: e6 2c     INC   $2C
$CCAF: 60        RTS
$CCB0: e0 46 e8 5a 00 4a e8 5a e0 4e e0 52 e0 46 e0 56 .byte $E0 …
$CCC0: 20 42 fa  JSR   $FA42
$CCC3: d0 ea     BNE   $CCAF
$CCC5: a9 ff     LDA   #$FF
$CCC7: 85 37     STA   $37
$CCC9: 4c 76 cc  JMP   $CC76
$CCCC: a9 01     LDA   #$01
$CCCE: 8d eb 07  STA   $07EB
$CCD1: 20 94 ce  JSR   $CE94
$CCD4: a5 25     LDA   $25
$CCD6: d0 22     BNE   $CCFA
$CCD8: a5 3b     LDA   $3B
$CCDA: d0 3a     BNE   $CD16
$CCDC: 20 59 ce  JSR   $CE59
$CCDF: 20 96 d2  JSR   $D296
$CCE2: a5 38     LDA   $38
$CCE4: 25 39     AND   $39
$CCE6: d0 13     BNE   $CCFB
$CCE8: 20 3a fa  JSR   $FA3A
$CCEB: 20 1a fa  JSR   $FA1A
$CCEE: 20 22 fa  JSR   $FA22
$CCF1: 20 32 fa  JSR   $FA32
$CCF4: 20 3b c8  JSR   $C83B
$CCF7: 20 6d cf  JSR   $CF6D
$CCFA: 60        RTS
$CCFB: a9 60     LDA   #$60
$CCFD: 85 29     STA   $29
$CCFF: a9 0b     LDA   #$0B
$CD01: d0 15     BNE   $CD18
$CD03: a9 00     LDA   #$00
$CD05: 85 3b     STA   $3B
$CD07: a9 05     LDA   #$05
$CD09: 20 18 cd  JSR   $CD18
$CD0C: a9 00     LDA   #$00
$CD0E: 85 23     STA   $23
$CD10: 8d 00 07  STA   $0700
$CD13: 4c d4 f9  JMP   $F9D4
$CD16: a9 08     LDA   #$08
$CD18: 85 2c     STA   $2C
$CD1A: a9 00     LDA   #$00
$CD1C: 85 2d     STA   $2D
$CD1E: 60        RTS
$CD1F: a0 03     LDY   #$03
$CD21: 98        TYA
$CD22: 29 01     AND   #$01
$CD24: 8d e9 07  STA   $07E9
$CD27: ea        NOP
$CD28: ea        NOP
$CD29: ea        NOP
$CD2A: ea        NOP
$CD2B: ea        NOP
$CD2C: ea        NOP
$CD2D: 29 01     AND   #$01
$CD2F: cd e9 07  CMP   $07E9
$CD32: d0 05     BNE   $CD39
$CD34: 88        DEY
$CD35: 10 ea     BPL   $CD21
$CD37: 30 03     BMI   $CD3C
$CD39: 4c 00 00  JMP   $0000
$CD3C: a9 00     LDA   #$00
$CD3E: 85 37     STA   $37
$CD40: 85 6a     STA   $6A
$CD42: a5 aa     LDA   $AA
$CD44: 85 10     STA   $10
$CD46: a5 ab     LDA   $AB
$CD48: 85 11     STA   $11
$CD4A: a2 40     LDX   #$40
$CD4C: 20 09 c3  JSR   $C309
$CD4F: a5 3b     LDA   $3B
$CD51: f0 1e     BEQ   $CD71
$CD53: a5 10     LDA   $10
$CD55: 85 aa     STA   $AA
$CD57: a5 11     LDA   $11
$CD59: 85 ab     STA   $AB
$CD5B: e6 30     INC   $30
$CD5D: a5 30     LDA   $30
$CD5F: c9 08     CMP   #$08
$CD61: 90 05     BCC   $CD68
$CD63: 20 62 c1  JSR   $C162
$CD66: e6 31     INC   $31
$CD68: a9 00     LDA   #$00
$CD6A: 85 2c     STA   $2C
$CD6C: 85 2d     STA   $2D
$CD6E: 85 37     STA   $37
$CD70: 60        RTS
$CD71: a5 1c     LDA   $1C
$CD73: d0 37     BNE   $CDAC
$CD75: a9 00     LDA   #$00
$CD77: 85 5a     STA   $5A
$CD79: a2 0f     LDX   #$0F
$CD7B: 9d b0 07  STA   $07B0,X
$CD7E: ca        DEX
$CD7F: 10 fa     BPL   $CD7B
$CD81: 20 10 c9  JSR   $C910
$CD84: a9 0a     LDA   #$0A
$CD86: 20 78 c7  JSR   $C778
$CD89: a9 06     LDA   #$06
$CD8B: 20 c5 ca  JSR   $CAC5
$CD8E: a9 0d     LDA   #$0D
$CD90: 20 c5 ca  JSR   $CAC5
$CD93: 20 2b ca  JSR   $CA2B
$CD96: a9 6e     LDA   #$6E
$CD98: 20 45 fb  JSR   $FB45
$CD9B: c6 3a     DEC   $3A
$CD9D: 30 08     BMI   $CDA7
$CD9F: a9 0e     LDA   #$0E
$CDA1: 20 c5 ca  JSR   $CAC5
$CDA4: 4c 76 cc  JMP   $CC76
$CDA7: a9 07     LDA   #$07
$CDA9: 4c 18 cd  JMP   $CD18
$CDAC: e6 1f     INC   $1F
$CDAE: 60        RTS
$CDAF: a5 f5     LDA   $F5
$CDB1: 29 10     AND   #$10
$CDB3: f0 18     BEQ   $CDCD
$CDB5: 20 d4 f9  JSR   $F9D4
$CDB8: a5 6b     LDA   $6B
$CDBA: d0 30     BNE   $CDEC
$CDBC: 20 cf c2  JSR   $C2CF
$CDBF: a9 00     LDA   #$00
$CDC1: 85 2c     STA   $2C
$CDC3: 8d 34 03  STA   $0334
$CDC6: 8d 1a 03  STA   $031A
$CDC9: 8d 00 03  STA   $0300
$CDCC: 60        RTS
$CDCD: a5 f5     LDA   $F5
$CDCF: 29 20     AND   #$20
$CDD1: f0 06     BEQ   $CDD9
$CDD3: a5 6b     LDA   $6B
$CDD5: 49 01     EOR   #$01
$CDD7: 85 6b     STA   $6B
$CDD9: a9 62     LDA   #$62
$CDDB: 8d 34 03  STA   $0334
$CDDE: a9 aa     LDA   #$AA
$CDE0: 8d 00 03  STA   $0300
$CDE3: a6 6b     LDX   $6B
$CDE5: bd 43 fb  LDA   $FB43,X
$CDE8: 8d 1a 03  STA   $031A
$CDEB: 60        RTS
$CDEC: a9 00     LDA   #$00
$CDEE: 4c 6f c1  JMP   $C16F
$CDF1: a5 f5     LDA   $F5
$CDF3: 29 10     AND   #$10
$CDF5: d0 f5     BNE   $CDEC
$CDF7: 60        RTS
$CDF8: 20 dc cc a5 2c c9 0b f0 30 a4 2a f0 08 c8 f0 29 .byte $20 …
$CE08: 20 77 c1 d0 24 a2 01 a0 00 b5 38 d0 07 b5 90 c9 .byte $20 …
$CE18: 01 d0 01 c8 ca 10 f2 98 8d 94 01 f0 0c a4 30 b9 .byte $01 …
$CE28: 32 ce f0 03 20 bc f9 e6 2c 60 00 00 00 00 62 62 .byte $32 …
$CE38: 00 66 20 6a fa 20 96 d2 20 3a fa 20 1a fa a5 30 .byte $00 …
$CE48: c9 07 f0 e5 4c 6d cf 20 e8 cc c6 29 d0 db 4c 03 .byte $C9 …
$CE58: cd        .byte $CD
$CE59: a5 30     LDA   $30
$CE5B: c9 04     CMP   #$04
$CE5D: d0 27     BNE   $CE86
$CE5F: a4 5b     LDY   $5B
$CE61: a5 64     LDA   $64
$CE63: d9 87 ce  CMP   $CE87,Y
$CE66: 90 1e     BCC   $CE86
$CE68: f0 02     BEQ   $CE6C
$CE6A: b0 07     BCS   $CE73
$CE6C: a5 65     LDA   $65
$CE6E: d9 88 ce  CMP   $CE88,Y
$CE71: 90 13     BCC   $CE86
$CE73: b9 89 ce  LDA   $CE89,Y
$CE76: 85 5a     STA   $5A
$CE78: 4a        LSR
$CE79: a9 01     LDA   #$01
$CE7B: b0 02     BCS   $CE7F
$CE7D: a9 03     LDA   #$03
$CE7F: 85 5d     STA   $5D
$CE81: c8        INY
$CE82: c8        INY
$CE83: c8        INY
$CE84: 84 5b     STY   $5B
$CE86: 60        RTS
$CE87: 00 00 01 02 00 00 03 80 01 11 00 00 ff .byte $00 …
$CE94: a5 1c     LDA   $1C
$CE96: 05 26     ORA   $26
$CE98: 05 20     ORA   $20
$CE9A: d0 29     BNE   $CEC5
$CE9C: a5 f5     LDA   $F5
$CE9E: a4 25     LDY   $25
$CEA0: d0 0d     BNE   $CEAF
$CEA2: 29 10     AND   #$10
$CEA4: f0 1f     BEQ   $CEC5
$CEA6: a9 01     LDA   #$01
$CEA8: 85 25     STA   $25
$CEAA: a9 74     LDA   #$74
$CEAC: 4c bc f9  JMP   $F9BC
$CEAF: 20 b0 d2  JSR   $D2B0
$CEB2: 20 52 fa  JSR   $FA52
$CEB5: 20 3b c8  JSR   $C83B
$CEB8: 20 6d cf  JSR   $CF6D
$CEBB: a5 f5     LDA   $F5
$CEBD: 29 10     AND   #$10
$CEBF: f0 04     BEQ   $CEC5
$CEC1: a9 00     LDA   #$00
$CEC3: 85 25     STA   $25
$CEC5: 60        RTS
$CEC6: a9 ff     LDA   #$FF
$CEC8: 85 48     STA   $48
$CECA: a5 30     LDA   $30
$CECC: 0a        ASL
$CECD: 0a        ASL
$CECE: 0a        ASL
$CECF: 0a        ASL
$CED0: 38        SEC
$CED1: e5 30     SBC   $30
$CED3: a8        TAY
$CED4: a2 00     LDX   #$00
$CED6: b9 5a d0  LDA   $D05A,Y
$CED9: 95 49     STA   $49,X
$CEDB: c8        INY
$CEDC: e8        INX
$CEDD: e0 0f     CPX   #$0F
$CEDF: d0 f5     BNE   $CED6
$CEE1: a9 20     LDA   #$20
$CEE3: 85 02     STA   $02
$CEE5: 85 36     STA   $36
$CEE7: a5 1a     LDA   $1A
$CEE9: 29 30     AND   #$30
$CEEB: 85 03     STA   $03
$CEED: a2 00     LDX   #$00
$CEEF: 86 00     STX   $00
$CEF1: a9 00     LDA   #$00
$CEF3: 85 07     STA   $07
$CEF5: a4 00     LDY   $00
$CEF7: b9 50 00  LDA   $0050,Y
$CEFA: 0a        ASL
$CEFB: 26 07     ROL   $07
$CEFD: 18        CLC
$CEFE: 79 50 00  ADC   $0050,Y
$CF01: 90 03     BCC   $CF06
$CF03: e6 07     INC   $07
$CF05: 18        CLC
$CF06: 6d e1 d0  ADC   $D0E1
$CF09: 85 06     STA   $06
$CF0B: a5 07     LDA   $07
$CF0D: 6d e2 d0  ADC   $D0E2
$CF10: 85 07     STA   $07
$CF12: a0 00     LDY   #$00
$CF14: a9 0f     LDA   #$0F
$CF16: 9d c0 07  STA   $07C0,X
$CF19: e8        INX
$CF1A: a5 74     LDA   $74
$CF1C: d0 1a     BNE   $CF38
$CF1E: b1 06     LDA   ($06),Y
$CF20: 9d c0 07  STA   $07C0,X
$CF23: c8        INY
$CF24: e8        INX
$CF25: c0 03     CPY   #$03
$CF27: d0 f1     BNE   $CF1A
$CF29: e6 00     INC   $00
$CF2B: e4 02     CPX   $02
$CF2D: d0 c2     BNE   $CEF1
$CF2F: a5 74     LDA   $74
$CF31: f0 04     BEQ   $CF37
$CF33: 30 02     BMI   $CF37
$CF35: c6 74     DEC   $74
$CF37: 60        RTS
$CF38: 84 03     STY   $03
$CF3A: a4 40     LDY   $40
$CF3C: 30 06     BMI   $CF44
$CF3E: a4 03     LDY   $03
$CF40: e0 04     CPX   #$04
$CF42: 90 da     BCC   $CF1E
$CF44: a4 03     LDY   $03
$CF46: e0 10     CPX   #$10
$CF48: b0 d4     BCS   $CF1E
$CF4A: a5 74     LDA   $74
$CF4C: 30 13     BMI   $CF61
$CF4E: c9 09     CMP   #$09
$CF50: b0 0f     BCS   $CF61
$CF52: a8        TAY
$CF53: b9 64 cf  LDA   $CF64,Y
$CF56: 85 04     STA   $04
$CF58: a4 03     LDY   $03
$CF5A: b1 06     LDA   ($06),Y
$CF5C: 38        SEC
$CF5D: e5 04     SBC   $04
$CF5F: b0 bf     BCS   $CF20
$CF61: a9 0f     LDA   #$0F
$CF63: d0 bb     BNE   $CF20
$CF65: 00        BRK
$CF66: 00 10 10 20 20 30 30 .byte $00 …
$CF6D: a5 36     LDA   $36
$CF6F: c5 18     CMP   $18
$CF71: b0 60     BCS   $CFD3
$CF73: a5 1a     LDA   $1A
$CF75: 29 07     AND   #$07
$CF77: c9 05     CMP   #$05
$CF79: d0 37     BNE   $CFB2
$CF7B: a5 78     LDA   $78
$CF7D: d0 33     BNE   $CFB2
$CF7F: e6 72     INC   $72
$CF81: a5 72     LDA   $72
$CF83: a4 30     LDY   $30
$CF85: d9 3d d0  CMP   $D03D,Y
$CF88: 90 04     BCC   $CF8E
$CF8A: a9 00     LDA   #$00
$CF8C: 85 72     STA   $72
$CF8E: a8        TAY
$CF8F: b9 4c 00  LDA   $004C,Y
$CF92: 85 53     STA   $53
$CF94: a5 40     LDA   $40
$CF96: 30 41     BMI   $CFD9
$CF98: a5 30     LDA   $30
$CF9A: f0 0c     BEQ   $CFA8
$CF9C: c9 07     CMP   #$07
$CF9E: f0 0d     BEQ   $CFAD
$CFA0: c9 08     CMP   #$08
$CFA2: f0 30     BEQ   $CFD4
$CFA4: a5 48     LDA   $48
$CFA6: 30 05     BMI   $CFAD
$CFA8: b9 52 d0  LDA   $D052,Y
$CFAB: 85 52     STA   $52
$CFAD: a9 10     LDA   #$10
$CFAF: 20 e3 ce  JSR   $CEE3
$CFB2: a5 7d     LDA   $7D
$CFB4: f0 1d     BEQ   $CFD3
$CFB6: c6 7d     DEC   $7D
$CFB8: a5 7d     LDA   $7D
$CFBA: 4a        LSR
$CFBB: b0 16     BCS   $CFD3
$CFBD: 29 03     AND   #$03
$CFBF: a8        TAY
$CFC0: b9 4e d0  LDA   $D04E,Y
$CFC3: 8d d0 07  STA   $07D0
$CFC6: 8d d4 07  STA   $07D4
$CFC9: 8d d8 07  STA   $07D8
$CFCC: 8d dc 07  STA   $07DC
$CFCF: a9 20     LDA   #$20
$CFD1: 85 36     STA   $36
$CFD3: 60        RTS
$CFD4: b9 56 d0  LDA   $D056,Y
$CFD7: d0 d2     BNE   $CFAB
$CFD9: a5 30     LDA   $30
$CFDB: 29 02     AND   #$02
$CFDD: 0a        ASL
$CFDE: 65 72     ADC   $72
$CFE0: a8        TAY
$CFE1: b9 46 d0  LDA   $D046,Y
$CFE4: 85 52     STA   $52
$CFE6: a5 30     LDA   $30
$CFE8: c9 01     CMP   #$01
$CFEA: d0 c1     BNE   $CFAD
$CFEC: a5 1a     LDA   $1A
$CFEE: 4a        LSR
$CFEF: 4a        LSR
$CFF0: 4a        LSR
$CFF1: 29 0f     AND   #$0F
$CFF3: a8        TAY
$CFF4: a6 21     LDX   $21
$CFF6: a9 01     LDA   #$01
$CFF8: 9d 00 07  STA   $0700,X
$CFFB: 9d 02 07  STA   $0702,X
$CFFE: a9 04     LDA   #$04
$D000: 9d 01 07  STA   $0701,X
$D003: a9 23     LDA   #$23
$D005: 9d 03 07  STA   $0703,X
$D008: a9 c2     LDA   #$C2
$D00A: 9d 04 07  STA   $0704,X
$D00D: 98        TYA
$D00E: 09 50     ORA   #$50
$D010: 9d 05 07  STA   $0705,X
$D013: 98        TYA
$D014: 18        CLC
$D015: 69 03     ADC   #$03
$D017: 29 0f     AND   #$0F
$D019: 09 50     ORA   #$50
$D01B: 9d 06 07  STA   $0706,X
$D01E: 98        TYA
$D01F: 18        CLC
$D020: 69 0c     ADC   #$0C
$D022: 29 0f     AND   #$0F
$D024: 09 50     ORA   #$50
$D026: 9d 07 07  STA   $0707,X
$D029: 98        TYA
$D02A: 18        CLC
$D02B: 69 0f     ADC   #$0F
$D02D: 29 0f     AND   #$0F
$D02F: 09 50     ORA   #$50
$D031: 9d 08 07  STA   $0708,X
$D034: 8a        TXA
$D035: 18        CLC
$D036: 69 09     ADC   #$09
$D038: 85 21     STA   $21
$D03A: 4c ad cf  JMP   $CFAD
$D03D: 04 04 03 04 04 04 04 04 04 13 14 15 14 1b 1c 1d .byte $04 …
$D04D: 1c 0f 20 16 11 04 5c 04 5d 66 6a 6b 6a 06 a8 a8 .byte $1C …
$D05D: 23 23 23 23 02 03 04 23 00 01 22 07 00 ff ff 16 .byte $23 …
$D06D: 17 18 17 11 12 13 16 00 01 22 21 07 ff ff 27 54 .byte $17 …
$D07D: 55 54 0b 25 26 27 00 01 22 07 00 ff ff 1e 1f 20 .byte $55 …
$D08D: 1f 19 1a 1c 1e 00 01 22 2b 20 f0 f0 42 42 42 42 .byte $1F …
$D09D: 3d 3e 40 42 00 01 22 06 0c de de 3a 3b 3a 3c 39 .byte $3D …
$D0AD: 39 04 3a 00 01 22 56 0e f1 f1 5a 5f 5a 5b 45 46 .byte $39 …
$D0BD: 59 5f 00 01 22 07 05 b6 b6 4b 50 4b 50 48 49 4a .byte $59 …
$D0CD: 4b 00 01 43 44 00 00 00 67 68 69 68 8e 65 66 67 .byte $4B …
$D0DD: 6d 6c 22 64 e3 d0 37 12 0f 36 16 0f 19 29 08 27 .byte $6D …
$D0ED: 18 08 16 30 10 11 21 30 16 20 00 20 00 0f 11 30 .byte $18 …
$D0FD: 21 10 00 09 00 0c 20 0a 1a 00 28 18 07 0c 11 21 .byte $21 …
$D10D: 0c 1c 2c 2c 0c 1c 10 2b 0f 06 00 08 20 00 08 06 .byte $0C …
$D11D: 00 08 16 00 08 26 00 08 20 00 06 20 00 16 20 00 .byte $00 …
$D12D: 26 0c 18 09 20 18 09 06 18 09 16 18 09 26 18 09 .byte $26 …
$D13D: 20 18 06 20 18 16 20 18 26 20 22 02 20 26 16 01 .byte $20 …
$D14D: 30 10 36 06 02 30 10 00 28 18 08 05 18 08 36 06 .byte $30 …
$D15D: 22 36 06 32 20 1b 0f 20 22 1c 10 00 0c 00 06 20 .byte $22 …
$D16D: 38 09 06 38 09 16 38 09 26 0f 20 2c 0f 20 26 00 .byte $38 …
$D17D: 20 1a 01 20 00 20 27 17 20 26 07 20 27 16 20 26 .byte $20 …
$D18D: 06 00 10 13 16 20 00 06 20 00 26 20 00 20 10 1c .byte $06 …
$D19D: 20 10 0a 20 00 17 20 12 00 07 00 17 20 16 00 30 .byte $20 …
$D1AD: 28 16 30 25 14 27 17 06 20 10 00 06 1b 0b 10 00 .byte $28 …
$D1BD: 07 36 15 06 35 15 04 35 16 1c 22 13 03 23 13 03 .byte $07 …
$D1CD: 24 13 03 23 13 03 26 16 03 20 13 27 20 16 27 00 .byte $24 …
$D1DD: 00 00 15 18 08 35 18 08 20 12 17 15 1b 0b 0f 1b .byte $00 …
$D1ED: 0b 24 13 03 27 17 06 17 06 0f 06 30 10 26 30 10 .byte $0B …
$D1FD: 00 00 00 20 27 17 10 26 06 10 16 07 20 22 02 22 .byte $00 …
$D20D: 20 02 20 10 00 18 07 1a 16 18 07 20 10 11 20 11 .byte $20 …
$D21D: 11 20 2c 11 26 18 07 16 18 07 16 00 00 0b 1b 3b .byte $11 …
$D22D: 0f 30 30 30 0f 30 32 12 02 22 18 02 18 12 02 22 .byte $0F …
$D23D: 09 02 28 18 08 20 21 02 20 28 18 20 10 00 20 26 .byte $09 …
$D24D: 06 20 20 0f 27 17 07 19 09 17 2c 09 06 27 17 06 .byte $06 …
$D25D: 32 1c 01 20 37 26 10 00 02 20 1b 0c 14 04 17 20 .byte $32 …
$D26D: 26 16 10 1b 0a 29 01 1a 0b 1b 0a 29 19 17 37 12 .byte $26 …
$D27D: 0f 36 16 0f 30 36 26 00 06 06 30 37 27 0b 1b 0a .byte $0F …
$D28D: 30 00 0f 30 00 10 03 07 16 .byte $30 …
$D296: 20 d9 d2  JSR   $D2D9
$D299: a5 73     LDA   $73
$D29B: c9 02     CMP   #$02
$D29D: 90 02     BCC   $D2A1
$D29F: a9 00     LDA   #$00
$D2A1: 85 73     STA   $73
$D2A3: a5 75     LDA   $75
$D2A5: 05 76     ORA   $76
$D2A7: f0 04     BEQ   $D2AD
$D2A9: a9 01     LDA   #$01
$D2AB: 85 68     STA   $68
$D2AD: 20 0a fa  JSR   $FA0A
$D2B0: a0 07     LDY   #$07
$D2B2: 98        TYA
$D2B3: 0a        ASL
$D2B4: 85 08     STA   $08
$D2B6: a5 1a     LDA   $1A
$D2B8: 29 01     AND   #$01
$D2BA: 05 08     ORA   $08
$D2BC: aa        TAX
$D2BD: bd 68 03  LDA   $0368,X
$D2C0: 99 02 03  STA   $0302,Y
$D2C3: bd 78 03  LDA   $0378,X
$D2C6: 99 50 03  STA   $0350,Y
$D2C9: bd b8 03  LDA   $03B8,X
$D2CC: 99 1c 03  STA   $031C,Y
$D2CF: bd c8 03  LDA   $03C8,X
$D2D2: 99 36 03  STA   $0336,Y
$D2D5: 88        DEY
$D2D6: 10 da     BPL   $D2B2
$D2D8: 60        RTS
$D2D9: a9 00     LDA   #$00
$D2DB: 85 68     STA   $68
$D2DD: 85 a2     STA   $A2
$D2DF: 85 a3     STA   $A3
$D2E1: 85 8e     STA   $8E
$D2E3: 85 2f     STA   $2F
$D2E5: a4 38     LDY   $38
$D2E7: d0 02     BNE   $D2EB
$D2E9: 09 01     ORA   #$01
$D2EB: a4 39     LDY   $39
$D2ED: d0 02     BNE   $D2F1
$D2EF: 09 02     ORA   #$02
$D2F1: aa        TAX
$D2F2: f0 17     BEQ   $D30B
$D2F4: ca        DEX
$D2F5: 86 df     STX   $DF
$D2F7: 8a        TXA
$D2F8: 29 01     AND   #$01
$D2FA: aa        TAX
$D2FB: 20 8a d3  JSR   $D38A
$D2FE: a5 df     LDA   $DF
$D300: c9 02     CMP   #$02
$D302: d0 07     BNE   $D30B
$D304: e8        INX
$D305: 20 8a d3  JSR   $D38A
$D308: 20 56 d3  JSR   $D356
$D30B: a5 2c     LDA   $2C
$D30D: c9 04     CMP   #$04
$D30F: d0 44     BNE   $D355
$D311: a5 22     LDA   $22
$D313: f0 40     BEQ   $D355
$D315: a2 01     LDX   #$01
$D317: b5 38     LDA   $38,X
$D319: d0 05     BNE   $D320
$D31B: ca        DEX
$D31C: 10 f9     BPL   $D317
$D31E: 30 35     BMI   $D355
$D320: b5 f5     LDA   $F5,X
$D322: 29 80     AND   #$80
$D324: f0 2f     BEQ   $D355
$D326: 8a        TXA
$D327: 49 01     EOR   #$01
$D329: a8        TAY
$D32A: b9 32 00  LDA   $0032,Y
$D32D: f0 26     BEQ   $D355
$D32F: c9 01     CMP   #$01
$D331: d0 07     BNE   $D33A
$D333: b9 90 00  LDA   $0090,Y
$D336: c9 01     CMP   #$01
$D338: d0 1b     BNE   $D355
$D33A: b9 d0 00  LDA   $00D0,Y
$D33D: d0 16     BNE   $D355
$D33F: b9 32 00  LDA   $0032,Y
$D342: 38        SEC
$D343: e9 01     SBC   #$01
$D345: c9 ff     CMP   #$FF
$D347: d0 02     BNE   $D34B
$D349: a9 00     LDA   #$00
$D34B: 99 32 00  STA   $0032,Y
$D34E: 20 07 da  JSR   $DA07
$D351: 95 90     STA   $90,X
$D353: 95 38     STA   $38,X
$D355: 60        RTS
$D356: a5 40     LDA   $40
$D358: d0 23     BNE   $D37D
$D35A: a5 41     LDA   $41
$D35C: d0 09     BNE   $D367
$D35E: 20 7e d3  JSR   $D37E
$D361: f0 03     BEQ   $D366
$D363: de 34 03  DEC   $0334,X
$D366: 60        RTS
$D367: a5 75     LDA   $75
$D369: d0 12     BNE   $D37D
$D36B: 20 7e d3  JSR   $D37E
$D36E: f0 0d     BEQ   $D37D
$D370: bd 1a 03  LDA   $031A,X
$D373: 18        CLC
$D374: 65 68     ADC   $68
$D376: 9d 1a 03  STA   $031A,X
$D379: 90 02     BCC   $D37D
$D37B: f6 ba     INC   $BA,X
$D37D: 60        RTS
$D37E: a2 00     LDX   #$00
$D380: a5 a2     LDA   $A2
$D382: c5 a3     CMP   $A3
$D384: f0 03     BEQ   $D389
$D386: 90 01     BCC   $D389
$D388: e8        INX
$D389: 60        RTS
$D38A: 20 ca d3  JSR   $D3CA
$D38D: b5 ae     LDA   $AE,X
$D38F: f0 05     BEQ   $D396
$D391: d6 ae     DEC   $AE,X
$D393: 4c a0 d3  JMP   $D3A0
$D396: b5 90     LDA   $90,X
$D398: c9 01     CMP   #$01
$D39A: d0 04     BNE   $D3A0
$D39C: a9 01     LDA   #$01
$D39E: 85 8e     STA   $8E
$D3A0: b5 b0     LDA   $B0,X
$D3A2: f0 08     BEQ   $D3AC
$D3A4: a5 1a     LDA   $1A
$D3A6: 29 07     AND   #$07
$D3A8: d0 02     BNE   $D3AC
$D3AA: d6 b0     DEC   $B0,X
$D3AC: b5 ce     LDA   $CE,X
$D3AE: f0 02     BEQ   $D3B2
$D3B0: d6 ce     DEC   $CE,X
$D3B2: a9 00     LDA   #$00
$D3B4: 95 d4     STA   $D4,X
$D3B6: b5 aa     LDA   $AA,X
$D3B8: 29 07     AND   #$07
$D3BA: a8        TAY
$D3BB: b9 c5 d3  LDA   $D3C5,Y
$D3BE: c5 2f     CMP   $2F
$D3C0: 90 02     BCC   $D3C4
$D3C2: 85 2f     STA   $2F
$D3C4: 60        RTS
$D3C5: 00 02 01 03 02 .byte $00 …
$D3CA: a4 30     LDY   $30
$D3CC: a5 40     LDA   $40
$D3CE: 0a        ASL
$D3CF: b9 e5 d3  LDA   $D3E5,Y
$D3D2: 90 02     BCC   $D3D6
$D3D4: a9 03     LDA   #$03
$D3D6: 85 08     STA   $08
$D3D8: b5 90     LDA   $90,X
$D3DA: 20 f2 c6  JSR   $C6F2
$D3DD: ed d3 5e  SBC   $5ED3
$D3E0: d4 bd     NOP   $BD
$D3E2: d4 0b     NOP   $0B
$D3E5: 00 01 02 01 00 00 00 00 .byte $00 …
$D3ED: 20 0b da  JSR   $DA0B
$D3F0: 8a        TXA
$D3F1: 0a        ASL
$D3F2: 0a        ASL
$D3F3: 18        CLC
$D3F4: 65 08     ADC   $08
$D3F6: a8        TAY
$D3F7: b9 4e d4  LDA   $D44E,Y
$D3FA: 9d 1a 03  STA   $031A,X
$D3FD: b9 56 d4  LDA   $D456,Y
$D400: 9d 34 03  STA   $0334,X
$D403: a9 01     LDA   #$01
$D405: 95 a0     STA   $A0,X
$D407: a5 40     LDA   $40
$D409: d0 24     BNE   $D42F
$D40B: 20 3e d4  JSR   $D43E
$D40E: 90 1f     BCC   $D42F
$D410: a9 10     LDA   #$10
$D412: 9d 34 03  STA   $0334,X
$D415: 20 3e d4  JSR   $D43E
$D418: 90 15     BCC   $D42F
$D41A: bd 34 03  LDA   $0334,X
$D41D: 18        CLC
$D41E: 69 10     ADC   #$10
$D420: 9d 34 03  STA   $0334,X
$D423: c9 e0     CMP   #$E0
$D425: b0 03     BCS   $D42A
$D427: 4c 15 d4  JMP   $D415
$D42A: a9 30     LDA   #$30
$D42C: 9d 34 03  STA   $0334,X
$D42F: a9 02     LDA   #$02
$D431: 95 a6     STA   $A6,X
$D433: a9 00     LDA   #$00
$D435: 95 c6     STA   $C6,X
$D437: a9 80     LDA   #$80
$D439: 95 ae     STA   $AE,X
$D43B: f6 90     INC   $90,X
$D43D: 60        RTS
$D43E: 20 d9 d8  JSR   $D8D9
$D441: 0a        ASL
$D442: b0 09     BCS   $D44D
$D444: bd 1a 03  LDA   $031A,X
$D447: 18        CLC
$D448: 69 20     ADC   #$20
$D44A: 4c d7 d9  JMP   $D9D7
$D44D: 60        RTS
$D44E: 20 60 50 60 20 60 50 60 30 70 30 70 20 90 20 90 .byte $20 …
$D45E: 20 95 d4  JSR   $D495
$D461: 20 4a fa  JSR   $FA4A
$D464: b5 c2     LDA   $C2,X
$D466: 95 c0     STA   $C0,X
$D468: b5 ba     LDA   $BA,X
$D46A: d0 07     BNE   $D473
$D46C: bd 1a 03  LDA   $031A,X
$D46F: c9 e8     CMP   #$E8
$D471: b0 01     BCS   $D474
$D473: 60        RTS
$D474: a9 72     LDA   #$72
$D476: 20 bc f9  JSR   $F9BC
$D479: 20 be d7  JSR   $D7BE
$D47C: 95 b2     STA   $B2,X
$D47E: 95 c8     STA   $C8,X
$D480: 95 d2     STA   $D2,X
$D482: 95 a6     STA   $A6,X
$D484: 95 9e     STA   $9E,X
$D486: a9 01     LDA   #$01
$D488: 95 b4     STA   $B4,X
$D48A: a9 fd     LDA   #$FD
$D48C: 95 c6     STA   $C6,X
$D48E: a9 80     LDA   #$80
$D490: 95 c4     STA   $C4,X
$D492: f6 90     INC   $90,X
$D494: 60        RTS
$D495: 20 48 d8  JSR   $D848
$D498: 20 b0 d8  JSR   $D8B0
$D49B: 20 12 fa  JSR   $FA12
$D49E: 20 18 d5  JSR   $D518
$D4A1: a5 75     LDA   $75
$D4A3: 05 76     ORA   $76
$D4A5: f0 15     BEQ   $D4BC
$D4A7: a5 41     LDA   $41
$D4A9: d0 0e     BNE   $D4B9
$D4AB: bd 34 03  LDA   $0334,X
$D4AE: a0 00     LDY   #$00
$D4B0: d9 92 d5  CMP   $D592,Y
$D4B3: 90 07     BCC   $D4BC
$D4B5: de 34 03  DEC   $0334,X
$D4B8: 60        RTS
$D4B9: fe 1a 03  INC   $031A,X
$D4BC: 60        RTS
$D4BD: 20 a1 d4  JSR   $D4A1
$D4C0: 20 a1 d6  JSR   $D6A1
$D4C3: b9 12 d5  LDA   $D512,Y
$D4C6: 95 bc     STA   $BC,X
$D4C8: b5 9e     LDA   $9E,X
$D4CA: f0 07     BEQ   $D4D3
$D4CC: d6 9e     DEC   $9E,X
$D4CE: d0 3f     BNE   $D50F
$D4D0: 4c 30 d9  JMP   $D930
$D4D3: b9 15 d5  LDA   $D515,Y
$D4D6: 95 98     STA   $98,X
$D4D8: b5 c2     LDA   $C2,X
$D4DA: c9 05     CMP   #$05
$D4DC: 90 0d     BCC   $D4EB
$D4DE: b5 b4     LDA   $B4,X
$D4E0: 09 02     ORA   #$02
$D4E2: 95 b4     STA   $B4,X
$D4E4: a9 00     LDA   #$00
$D4E6: 38        SEC
$D4E7: f5 98     SBC   $98,X
$D4E9: 95 98     STA   $98,X
$D4EB: b5 c6     LDA   $C6,X
$D4ED: 30 1a     BMI   $D509
$D4EF: c9 02     CMP   #$02
$D4F1: 90 16     BCC   $D509
$D4F3: b5 ba     LDA   $BA,X
$D4F5: c9 01     CMP   #$01
$D4F7: f0 0c     BEQ   $D505
$D4F9: 20 d9 d8  JSR   $D8D9
$D4FC: f0 0b     BEQ   $D509
$D4FE: c9 02     CMP   #$02
$D500: f0 07     BEQ   $D509
$D502: 20 25 d8  JSR   $D825
$D505: a9 40     LDA   #$40
$D507: 95 9e     STA   $9E,X
$D509: 20 fe d8  JSR   $D8FE
$D50C: 20 25 d5  JSR   $D525
$D50F: 4c 4a fa  JMP   $FA4A
$D512: 04 04 06 ff 00 00 .byte $04 …
$D518: b5 d0     LDA   $D0,X
$D51A: d0 06     BNE   $D522
$D51C: a9 00     LDA   #$00
$D51E: 95 98     STA   $98,X
$D520: 95 96     STA   $96,X
$D522: 20 95 d5  JSR   $D595
$D525: b5 98     LDA   $98,X
$D527: 18        CLC
$D528: 75 d4     ADC   $D4,X
$D52A: 95 98     STA   $98,X
$D52C: b5 b2     LDA   $B2,X
$D52E: 30 5e     BMI   $D58E
$D530: b5 98     LDA   $98,X
$D532: 15 96     ORA   $96,X
$D534: f0 58     BEQ   $D58E
$D536: b5 98     LDA   $98,X
$D538: 30 2f     BMI   $D569
$D53A: a5 3b     LDA   $3B
$D53C: 30 1d     BMI   $D55B
$D53E: a9 08     LDA   #$08
$D540: 20 5e da  JSR   $DA5E
$D543: b0 49     BCS   $D58E
$D545: 20 a1 d6  JSR   $D6A1
$D548: bd 34 03  LDA   $0334,X
$D54B: d9 8f d5  CMP   $D58F,Y
$D54E: b0 3e     BCS   $D58E
$D550: a4 84     LDY   $84
$D552: f0 07     BEQ   $D55B
$D554: a4 30     LDY   $30
$D556: d9 61 d5  CMP   $D561,Y
$D559: b0 33     BCS   $D58E
$D55B: 20 41 d9  JSR   $D941
$D55E: 4c 7f d5  JMP   $D57F
$D561: 90 ff ff ff a0 d0 b0 b0 .byte $90 …
$D569: a9 f8     LDA   #$F8
$D56B: 20 5e da  JSR   $DA5E
$D56E: b0 1e     BCS   $D58E
$D570: a5 3b     LDA   $3B
$D572: 30 0b     BMI   $D57F
$D574: 20 a1 d6  JSR   $D6A1
$D577: bd 34 03  LDA   $0334,X
$D57A: d9 92 d5  CMP   $D592,Y
$D57D: 90 0f     BCC   $D58E
$D57F: b5 92     LDA   $92,X
$D581: 18        CLC
$D582: 75 96     ADC   $96,X
$D584: 95 92     STA   $92,X
$D586: bd 34 03  LDA   $0334,X
$D589: 75 98     ADC   $98,X
$D58B: 9d 34 03  STA   $0334,X
$D58E: 60        RTS
$D58F: e6 e0 d0 1a 20 30 .byte $E6 …
$D595: a9 03     LDA   #$03
$D597: 95 bc     STA   $BC,X
$D599: b5 ca     LDA   $CA,X
$D59B: f0 0c     BEQ   $D5A9
$D59D: a9 00     LDA   #$00
$D59F: 95 ca     STA   $CA,X
$D5A1: 95 d0     STA   $D0,X
$D5A3: 20 8a d7  JSR   $D78A
$D5A6: 4c fd d5  JMP   $D5FD
$D5A9: b5 c8     LDA   $C8,X
$D5AB: f0 03     BEQ   $D5B0
$D5AD: 4c 62 d7  JMP   $D762
$D5B0: b5 a4     LDA   $A4,X
$D5B2: f0 03     BEQ   $D5B7
$D5B4: 4c ad d6  JMP   $D6AD
$D5B7: b5 a0     LDA   $A0,X
$D5B9: f0 03     BEQ   $D5BE
$D5BB: 4c dd d6  JMP   $D6DD
$D5BE: b5 d0     LDA   $D0,X
$D5C0: f0 03     BEQ   $D5C5
$D5C2: 4c 71 d7  JMP   $D771
$D5C5: b5 b2     LDA   $B2,X
$D5C7: d0 5d     BNE   $D626
$D5C9: b5 f5     LDA   $F5,X
$D5CB: 29 80     AND   #$80
$D5CD: f0 57     BEQ   $D626
$D5CF: b5 f1     LDA   $F1,X
$D5D1: 29 07     AND   #$07
$D5D3: c9 04     CMP   #$04
$D5D5: d0 26     BNE   $D5FD
$D5D7: a9 02     LDA   #$02
$D5D9: 95 bc     STA   $BC,X
$D5DB: 20 c7 d9  JSR   $D9C7
$D5DE: b0 1c     BCS   $D5FC
$D5E0: a9 81     LDA   #$81
$D5E2: d0 0a     BNE   $D5EE
$D5E4: b5 c2     LDA   $C2,X
$D5E6: c9 05     CMP   #$05
$D5E8: a9 21     LDA   #$21
$D5EA: 90 02     BCC   $D5EE
$D5EC: a9 41     LDA   #$41
$D5EE: 95 a4     STA   $A4,X
$D5F0: bd 1a 03  LDA   $031A,X
$D5F3: 18        CLC
$D5F4: 69 14     ADC   #$14
$D5F6: 90 02     BCC   $D5FA
$D5F8: a9 ff     LDA   #$FF
$D5FA: 95 b8     STA   $B8,X
$D5FC: 60        RTS
$D5FD: b5 a0     LDA   $A0,X
$D5FF: d0 24     BNE   $D625
$D601: b5 c2     LDA   $C2,X
$D603: c9 05     CMP   #$05
$D605: a9 91     LDA   #$91
$D607: b0 02     BCS   $D60B
$D609: a9 11     LDA   #$11
$D60B: 95 a0     STA   $A0,X
$D60D: a9 00     LDA   #$00
$D60F: 95 9e     STA   $9E,X
$D611: 95 a6     STA   $A6,X
$D613: a5 40     LDA   $40
$D615: 4a        LSR
$D616: a9 fb     LDA   #$FB
$D618: a0 f0     LDY   #$F0
$D61A: 90 04     BCC   $D620
$D61C: a9 fc     LDA   #$FC
$D61E: a0 90     LDY   #$90
$D620: 95 c6     STA   $C6,X
$D622: 98        TYA
$D623: 95 c4     STA   $C4,X
$D625: 60        RTS
$D626: b5 f1     LDA   $F1,X
$D628: 4a        LSR
$D629: b0 5f     BCS   $D68A
$D62B: 4a        LSR
$D62C: b0 60     BCS   $D68E
$D62E: a0 02     LDY   #$02
$D630: 4a        LSR
$D631: b0 05     BCS   $D638
$D633: 88        DEY
$D634: 4a        LSR
$D635: b0 05     BCS   $D63C
$D637: 88        DEY
$D638: 98        TYA
$D639: 95 bc     STA   $BC,X
$D63B: 60        RTS
$D63C: a5 40     LDA   $40
$D63E: 4a        LSR
$D63F: 90 f7     BCC   $D638
$D641: 20 38 d6  JSR   $D638
$D644: a5 6a     LDA   $6A
$D646: d0 09     BNE   $D651
$D648: a9 30     LDA   #$30
$D64A: 95 c8     STA   $C8,X
$D64C: a9 34     LDA   #$34
$D64E: 4c bc f9  JMP   $F9BC
$D651: 86 10     STX   $10
$D653: 8a        TXA
$D654: 49 01     EOR   #$01
$D656: aa        TAX
$D657: b5 38     LDA   $38,X
$D659: d0 0a     BNE   $D665
$D65B: b5 90     LDA   $90,X
$D65D: c9 01     CMP   #$01
$D65F: d0 23     BNE   $D684
$D661: b5 a0     LDA   $A0,X
$D663: d0 1f     BNE   $D684
$D665: a2 01     LDX   #$01
$D667: a9 05     LDA   #$05
$D669: 95 bc     STA   $BC,X
$D66B: b5 d0     LDA   $D0,X
$D66D: d0 0f     BNE   $D67E
$D66F: a9 01     LDA   #$01
$D671: 85 73     STA   $73
$D673: 95 d0     STA   $D0,X
$D675: a9 00     LDA   #$00
$D677: 95 a6     STA   $A6,X
$D679: 95 9e     STA   $9E,X
$D67B: 20 d1 d7  JSR   $D7D1
$D67E: ca        DEX
$D67F: 10 e6     BPL   $D667
$D681: a6 10     LDX   $10
$D683: 60        RTS
$D684: a6 10     LDX   $10
$D686: a9 00     LDA   #$00
$D688: f0 af     BEQ   $D639
$D68A: a9 01     LDA   #$01
$D68C: d0 02     BNE   $D690
$D68E: a9 ff     LDA   #$FF
$D690: b4 b2     LDY   $B2,X
$D692: f0 0a     BEQ   $D69E
$D694: 85 08     STA   $08
$D696: b5 f1     LDA   $F1,X
$D698: 29 04     AND   #$04
$D69A: d0 04     BNE   $D6A0
$D69C: a5 08     LDA   $08
$D69E: 95 98     STA   $98,X
$D6A0: 60        RTS
$D6A1: a0 00     LDY   #$00
$D6A3: a5 40     LDA   $40
$D6A5: f0 05     BEQ   $D6AC
$D6A7: c8        INY
$D6A8: 0a        ASL
$D6A9: b0 01     BCS   $D6AC
$D6AB: c8        INY
$D6AC: 60        RTS
$D6AD: bd 1a 03  LDA   $031A,X
$D6B0: d5 b8     CMP   $B8,X
$D6B2: 90 0b     BCC   $D6BF
$D6B4: 20 d9 d8  JSR   $D8D9
$D6B7: f0 06     BEQ   $D6BF
$D6B9: 20 25 d8  JSR   $D825
$D6BC: 4c 9d d7  JMP   $D79D
$D6BF: 20 fe d8  JSR   $D8FE
$D6C2: bd 1a 03  LDA   $031A,X
$D6C5: d5 b8     CMP   $B8,X
$D6C7: 90 0f     BCC   $D6D8
$D6C9: 20 52 d7  JSR   $D752
$D6CC: f0 0a     BEQ   $D6D8
$D6CE: 85 08     STA   $08
$D6D0: b5 a4     LDA   $A4,X
$D6D2: 29 9f     AND   #$9F
$D6D4: 05 08     ORA   $08
$D6D6: 95 a4     STA   $A4,X
$D6D8: b5 a4     LDA   $A4,X
$D6DA: 4c 46 d7  JMP   $D746
$D6DD: a9 00     LDA   #$00
$D6DF: 95 d0     STA   $D0,X
$D6E1: b5 c6     LDA   $C6,X
$D6E3: 30 28     BMI   $D70D
$D6E5: a4 40     LDY   $40
$D6E7: d0 16     BNE   $D6FF
$D6E9: c9 01     CMP   #$01
$D6EB: 90 39     BCC   $D726
$D6ED: b5 c6     LDA   $C6,X
$D6EF: c9 04     CMP   #$04
$D6F1: b0 0c     BCS   $D6FF
$D6F3: bd 1a 03  LDA   $031A,X
$D6F6: 18        CLC
$D6F7: 65 fc     ADC   $FC
$D6F9: 29 0f     AND   #$0F
$D6FB: c9 08     CMP   #$08
$D6FD: b0 27     BCS   $D726
$D6FF: 20 d9 d8  JSR   $D8D9
$D702: f0 22     BEQ   $D726
$D704: 20 25 d8  JSR   $D825
$D707: 20 35 d7  JSR   $D735
$D70A: 4c 9d d7  JMP   $D79D
$D70D: a5 3b     LDA   $3B
$D70F: 30 15     BMI   $D726
$D711: bd 1a 03  LDA   $031A,X
$D714: 18        CLC
$D715: 69 f6     ADC   #$F6
$D717: a8        TAY
$D718: bd 34 03  LDA   $0334,X
$D71B: 20 ec df  JSR   $DFEC
$D71E: 10 06     BPL   $D726
$D720: a9 00     LDA   #$00
$D722: 95 c6     STA   $C6,X
$D724: 95 c4     STA   $C4,X
$D726: 20 22 d9  JSR   $D922
$D729: a5 41     LDA   $41
$D72B: f0 05     BEQ   $D732
$D72D: 20 41 d9  JSR   $D941
$D730: b0 03     BCS   $D735
$D732: 20 01 d9  JSR   $D901
$D735: 20 52 d7  JSR   $D752
$D738: f0 0a     BEQ   $D744
$D73A: 85 08     STA   $08
$D73C: b5 a0     LDA   $A0,X
$D73E: 29 9f     AND   #$9F
$D740: 05 08     ORA   $08
$D742: 95 a0     STA   $A0,X
$D744: b5 a0     LDA   $A0,X
$D746: 0a        ASL
$D747: 10 03     BPL   $D74C
$D749: 4c 8e d6  JMP   $D68E
$D74C: 0a        ASL
$D74D: 10 12     BPL   $D761
$D74F: 4c 8a d6  JMP   $D68A
$D752: a0 00     LDY   #$00
$D754: b5 f1     LDA   $F1,X
$D756: 4a        LSR
$D757: 90 02     BCC   $D75B
$D759: a0 20     LDY   #$20
$D75B: 4a        LSR
$D75C: 90 02     BCC   $D760
$D75E: a0 40     LDY   #$40
$D760: 98        TYA
$D761: 60        RTS
$D762: a9 01     LDA   #$01
$D764: 95 bc     STA   $BC,X
$D766: d6 c8     DEC   $C8,X
$D768: a5 6a     LDA   $6A
$D76A: f0 04     BEQ   $D770
$D76C: a9 00     LDA   #$00
$D76E: 95 c8     STA   $C8,X
$D770: 60        RTS
$D771: a9 05     LDA   #$05
$D773: 95 bc     STA   $BC,X
$D775: b5 94     LDA   $94,X
$D777: 18        CLC
$D778: 75 9a     ADC   $9A,X
$D77A: 95 94     STA   $94,X
$D77C: bd 1a 03  LDA   $031A,X
$D77F: 75 9c     ADC   $9C,X
$D781: 9d 1a 03  STA   $031A,X
$D784: a5 73     LDA   $73
$D786: c9 02     CMP   #$02
$D788: 90 12     BCC   $D79C
$D78A: b5 a0     LDA   $A0,X
$D78C: d0 0e     BNE   $D79C
$D78E: a9 00     LDA   #$00
$D790: 95 d0     STA   $D0,X
$D792: b5 a8     LDA   $A8,X
$D794: 9d 1a 03  STA   $031A,X
$D797: b5 be     LDA   $BE,X
$D799: 9d 34 03  STA   $0334,X
$D79C: 60        RTS
$D79D: b5 a0     LDA   $A0,X
$D79F: 15 a4     ORA   $A4,X
$D7A1: f0 0d     BEQ   $D7B0
$D7A3: a9 00     LDA   #$00
$D7A5: 95 a6     STA   $A6,X
$D7A7: 95 9e     STA   $9E,X
$D7A9: 95 b8     STA   $B8,X
$D7AB: a9 0b     LDA   #$0B
$D7AD: 20 bc f9  JSR   $F9BC
$D7B0: b5 c2     LDA   $C2,X
$D7B2: c9 05     CMP   #$05
$D7B4: b5 d8     LDA   $D8,X
$D7B6: 29 3f     AND   #$3F
$D7B8: 90 02     BCC   $D7BC
$D7BA: 09 40     ORA   #$40
$D7BC: 95 d8     STA   $D8,X
$D7BE: a9 00     LDA   #$00
$D7C0: 95 a0     STA   $A0,X
$D7C2: 95 a4     STA   $A4,X
$D7C4: 95 bc     STA   $BC,X
$D7C6: a9 00     LDA   #$00
$D7C8: 95 c4     STA   $C4,X
$D7CA: 95 c6     STA   $C6,X
$D7CC: 95 9a     STA   $9A,X
$D7CE: 95 9c     STA   $9C,X
$D7D0: 60        RTS
$D7D1: a9 00     LDA   #$00
$D7D3: 85 12     STA   $12
$D7D5: a9 58     LDA   #$58
$D7D7: 20 03 d8  JSR   $D803
$D7DA: a5 0f     LDA   $0F
$D7DC: 95 9c     STA   $9C,X
$D7DE: a5 0e     LDA   $0E
$D7E0: 95 9a     STA   $9A,X
$D7E2: bd 1a 03  LDA   $031A,X
$D7E5: 95 a8     STA   $A8,X
$D7E7: bd 34 03  LDA   $0334,X
$D7EA: 95 be     STA   $BE,X
$D7EC: 38        SEC
$D7ED: e9 80     SBC   #$80
$D7EF: 85 12     STA   $12
$D7F1: b0 04     BCS   $D7F7
$D7F3: 49 ff     EOR   #$FF
$D7F5: 69 01     ADC   #$01
$D7F7: 20 03 d8  JSR   $D803
$D7FA: a5 0f     LDA   $0F
$D7FC: 95 98     STA   $98,X
$D7FE: a5 0e     LDA   $0E
$D800: 95 96     STA   $96,X
$D802: 60        RTS
$D803: 85 0f     STA   $0F
$D805: a9 00     LDA   #$00
$D807: 85 0e     STA   $0E
$D809: a0 07     LDY   #$07
$D80B: 46 0f     LSR   $0F
$D80D: 66 0e     ROR   $0E
$D80F: 88        DEY
$D810: d0 f9     BNE   $D80B
$D812: a5 12     LDA   $12
$D814: 10 01     BPL   $D817
$D816: 60        RTS
$D817: a9 00     LDA   #$00
$D819: 38        SEC
$D81A: e5 0e     SBC   $0E
$D81C: 85 0e     STA   $0E
$D81E: a9 00     LDA   #$00
$D820: e5 0f     SBC   $0F
$D822: 85 0f     STA   $0F
$D824: 60        RTS
$D825: 20 a1 d6  JSR   $D6A1
$D828: b9 45 d8  LDA   $D845,Y
$D82B: d0 14     BNE   $D841
$D82D: a5 fc     LDA   $FC
$D82F: 29 0f     AND   #$0F
$D831: 09 f0     ORA   #$F0
$D833: 85 00     STA   $00
$D835: 18        CLC
$D836: 7d 1a 03  ADC   $031A,X
$D839: 29 f0     AND   #$F0
$D83B: 38        SEC
$D83C: e5 00     SBC   $00
$D83E: 18        CLC
$D83F: 69 04     ADC   #$04
$D841: 9d 1a 03  STA   $031A,X
$D844: 60        RTS
$D845: 00 c9 a8  .byte $00 …
$D848: a0 20     LDY   #$20
$D84A: a5 a0     LDA   $A0
$D84C: f0 02     BEQ   $D850
$D84E: a0 30     LDY   #$30
$D850: a5 08     LDA   $08
$D852: c9 03     CMP   #$03
$D854: f0 0a     BEQ   $D860
$D856: a0 00     LDY   #$00
$D858: b5 c0     LDA   $C0,X
$D85A: c9 05     CMP   #$05
$D85C: 90 02     BCC   $D860
$D85E: a0 10     LDY   #$10
$D860: 84 08     STY   $08
$D862: b5 f1     LDA   $F1,X
$D864: 29 0f     AND   #$0F
$D866: 18        CLC
$D867: 65 08     ADC   $08
$D869: a8        TAY
$D86A: b9 70 d8  LDA   $D870,Y
$D86D: 95 c2     STA   $C2,X
$D86F: 60        RTS
$D870: 02 02 07 02 04 03 06 02 00 01 08 02 07 02 07 02 .byte $02 …
$D880: 07 02 07 02 05 03 06 02 09 01 08 02 07 02 07 02 .byte $07 …
$D890: 00 02 07 00 00 02 07 02 00 01 08 02 07 02 07 02 .byte $00 …
$D8A0: 00 02 07 00 0a 03 06 02 00 01 08 02 07 02 07 02 .byte $00 …
$D8B0: b5 b6     LDA   $B6,X
$D8B2: d0 18     BNE   $D8CC
$D8B4: b5 b2     LDA   $B2,X
$D8B6: 15 a0     ORA   $A0,X
$D8B8: 15 a4     ORA   $A4,X
$D8BA: 15 d0     ORA   $D0,X
$D8BC: d0 12     BNE   $D8D0
$D8BE: b5 da     LDA   $DA,X
$D8C0: 4a        LSR
$D8C1: b0 09     BCS   $D8CC
$D8C3: 20 d9 d8  JSR   $D8D9
$D8C6: f0 0e     BEQ   $D8D6
$D8C8: c9 02     CMP   #$02
$D8CA: f0 05     BEQ   $D8D1
$D8CC: a9 00     LDA   #$00
$D8CE: 95 a4     STA   $A4,X
$D8D0: 60        RTS
$D8D1: a9 01     LDA   #$01
$D8D3: 95 b2     STA   $B2,X
$D8D5: 60        RTS
$D8D6: 4c e4 d5  JMP   $D5E4
$D8D9: a5 40     LDA   $40
$D8DB: 30 15     BMI   $D8F2
$D8DD: d0 0f     BNE   $D8EE
$D8DF: bd 1a 03  LDA   $031A,X
$D8E2: 18        CLC
$D8E3: 69 10     ADC   #$10
$D8E5: b0 14     BCS   $D8FB
$D8E7: a8        TAY
$D8E8: bd 34 03  LDA   $0334,X
$D8EB: 4c ec df  JMP   $DFEC
$D8EE: a9 a0     LDA   #$A0
$D8F0: d0 02     BNE   $D8F4
$D8F2: a9 c8     LDA   #$C8
$D8F4: dd 1a 03  CMP   $031A,X
$D8F7: a9 01     LDA   #$01
$D8F9: 90 02     BCC   $D8FD
$D8FB: a9 00     LDA   #$00
$D8FD: 60        RTS
$D8FE: 20 22 d9  JSR   $D922
$D901: b5 c6     LDA   $C6,X
$D903: 0a        ASL
$D904: a9 00     LDA   #$00
$D906: 90 02     BCC   $D90A
$D908: a9 ff     LDA   #$FF
$D90A: 85 08     STA   $08
$D90C: b5 94     LDA   $94,X
$D90E: 18        CLC
$D90F: 75 c4     ADC   $C4,X
$D911: 95 94     STA   $94,X
$D913: bd 1a 03  LDA   $031A,X
$D916: 75 c6     ADC   $C6,X
$D918: 9d 1a 03  STA   $031A,X
$D91B: b5 ba     LDA   $BA,X
$D91D: 65 08     ADC   $08
$D91F: 95 ba     STA   $BA,X
$D921: 60        RTS
$D922: 18        CLC
$D923: b5 c4     LDA   $C4,X
$D925: 69 23     ADC   #$23
$D927: 95 c4     STA   $C4,X
$D929: b5 c6     LDA   $C6,X
$D92B: 69 00     ADC   #$00
$D92D: 95 c6     STA   $C6,X
$D92F: 60        RTS
$D930: 20 07 da  JSR   $DA07
$D933: 95 90     STA   $90,X
$D935: b5 32     LDA   $32,X
$D937: f0 03     BEQ   $D93C
$D939: d6 32     DEC   $32,X
$D93B: 60        RTS
$D93C: a9 01     LDA   #$01
$D93E: 95 38     STA   $38,X
$D940: 60        RTS
$D941: a5 40     LDA   $40
$D943: 05 75     ORA   $75
$D945: 05 76     ORA   $76
$D947: d0 4b     BNE   $D994
$D949: b5 90     LDA   $90,X
$D94B: c9 01     CMP   #$01
$D94D: d0 45     BNE   $D994
$D94F: a5 41     LDA   $41
$D951: d0 46     BNE   $D999
$D953: a5 58     LDA   $58
$D955: 30 3d     BMI   $D994
$D957: a4 df     LDY   $DF
$D959: bd 34 03  LDA   $0334,X
$D95C: d9 96 d9  CMP   $D996,Y
$D95F: 90 33     BCC   $D994
$D961: c0 02     CPY   #$02
$D963: d0 0b     BNE   $D970
$D965: 8a        TXA
$D966: 49 01     EOR   #$01
$D968: a8        TAY
$D969: b9 34 03  LDA   $0334,Y
$D96C: c9 21     CMP   #$21
$D96E: 90 1e     BCC   $D98E
$D970: 20 67 e0  JSR   $E067
$D973: f0 1f     BEQ   $D994
$D975: b5 96     LDA   $96,X
$D977: 18        CLC
$D978: 75 92     ADC   $92,X
$D97A: 95 92     STA   $92,X
$D97C: b5 98     LDA   $98,X
$D97E: 69 00     ADC   #$00
$D980: 85 68     STA   $68
$D982: a9 01     LDA   #$01
$D984: 95 a2     STA   $A2,X
$D986: a9 00     LDA   #$00
$D988: 95 96     STA   $96,X
$D98A: 95 98     STA   $98,X
$D98C: 38        SEC
$D98D: 60        RTS
$D98E: a9 00     LDA   #$00
$D990: 95 96     STA   $96,X
$D992: 95 98     STA   $98,X
$D994: 18        CLC
$D995: 60        RTS
$D996: 80 80 a8  .byte $80 …
$D999: bd 1a 03  LDA   $031A,X
$D99C: c9 50     CMP   #$50
$D99E: b0 25     BCS   $D9C5
$D9A0: b5 c6     LDA   $C6,X
$D9A2: 10 21     BPL   $D9C5
$D9A4: 20 67 e0  JSR   $E067
$D9A7: f0 1c     BEQ   $D9C5
$D9A9: b5 94     LDA   $94,X
$D9AB: 18        CLC
$D9AC: 75 c4     ADC   $C4,X
$D9AE: 95 94     STA   $94,X
$D9B0: bd 1a 03  LDA   $031A,X
$D9B3: 75 c6     ADC   $C6,X
$D9B5: 85 08     STA   $08
$D9B7: bd 1a 03  LDA   $031A,X
$D9BA: 38        SEC
$D9BB: e5 08     SBC   $08
$D9BD: 85 68     STA   $68
$D9BF: a9 01     LDA   #$01
$D9C1: 95 a2     STA   $A2,X
$D9C3: 38        SEC
$D9C4: 60        RTS
$D9C5: 18        CLC
$D9C6: 60        RTS
$D9C7: a5 58     LDA   $58
$D9C9: c9 ff     CMP   #$FF
$D9CB: f0 04     BEQ   $D9D1
$D9CD: a5 41     LDA   $41
$D9CF: d0 32     BNE   $DA03
$D9D1: bd 1a 03  LDA   $031A,X
$D9D4: 18        CLC
$D9D5: 69 10     ADC   #$10
$D9D7: a8        TAY
$D9D8: 4a        LSR
$D9D9: 4a        LSR
$D9DA: 4a        LSR
$D9DB: 4a        LSR
$D9DC: 85 08     STA   $08
$D9DE: bd 34 03  LDA   $0334,X
$D9E1: 20 b8 df  JSR   $DFB8
$D9E4: 30 1f     BMI   $DA05
$D9E6: e6 08     INC   $08
$D9E8: a5 08     LDA   $08
$D9EA: c9 0e     CMP   #$0E
$D9EC: b0 16     BCS   $DA04
$D9EE: a5 13     LDA   $13
$D9F0: 29 c0     AND   #$C0
$D9F2: 85 17     STA   $17
$D9F4: a5 13     LDA   $13
$D9F6: 18        CLC
$D9F7: 69 04     ADC   #$04
$D9F9: 29 3f     AND   #$3F
$D9FB: 05 17     ORA   $17
$D9FD: a8        TAY
$D9FE: 20 e6 df  JSR   $DFE6
$DA01: f0 e3     BEQ   $D9E6
$DA03: 18        CLC
$DA04: 60        RTS
$DA05: 38        SEC
$DA06: 60        RTS
$DA07: a9 00     LDA   #$00
$DA09: 95 aa     STA   $AA,X
$DA0B: a9 00     LDA   #$00
$DA0D: 9d 00 03  STA   $0300,X
$DA10: 9d 1a 03  STA   $031A,X
$DA13: 9d 34 03  STA   $0334,X
$DA16: 9d 4e 03  STA   $034E,X
$DA19: 95 92     STA   $92,X
$DA1B: 95 94     STA   $94,X
$DA1D: 95 96     STA   $96,X
$DA1F: 95 98     STA   $98,X
$DA21: 95 9a     STA   $9A,X
$DA23: 95 9c     STA   $9C,X
$DA25: 95 9e     STA   $9E,X
$DA27: 95 a0     STA   $A0,X
$DA29: 95 a2     STA   $A2,X
$DA2B: 95 a4     STA   $A4,X
$DA2D: 95 a6     STA   $A6,X
$DA2F: 95 a8     STA   $A8,X
$DA31: 95 ac     STA   $AC,X
$DA33: 95 ae     STA   $AE,X
$DA35: 95 b0     STA   $B0,X
$DA37: 95 b2     STA   $B2,X
$DA39: 95 b4     STA   $B4,X
$DA3B: 95 b6     STA   $B6,X
$DA3D: 95 b8     STA   $B8,X
$DA3F: 95 ba     STA   $BA,X
$DA41: 95 bc     STA   $BC,X
$DA43: 95 be     STA   $BE,X
$DA45: 95 c0     STA   $C0,X
$DA47: 95 c2     STA   $C2,X
$DA49: 95 c4     STA   $C4,X
$DA4B: 95 c6     STA   $C6,X
$DA4D: 95 c8     STA   $C8,X
$DA4F: 95 ca     STA   $CA,X
$DA51: 95 cc     STA   $CC,X
$DA53: 95 ce     STA   $CE,X
$DA55: 95 d0     STA   $D0,X
$DA57: 95 d6     STA   $D6,X
$DA59: 95 d8     STA   $D8,X
$DA5B: 95 da     STA   $DA,X
$DA5D: 60        RTS
$DA5E: 18        CLC
$DA5F: 7d 34 03  ADC   $0334,X
$DA62: 85 0a     STA   $0A
$DA64: a0 0b     LDY   #$0B
$DA66: b5 d6     LDA   $D6,X
$DA68: c9 17     CMP   #$17
$DA6A: d0 02     BNE   $DA6E
$DA6C: a0 00     LDY   #$00
$DA6E: 84 08     STY   $08
$DA70: b5 ba     LDA   $BA,X
$DA72: d0 0c     BNE   $DA80
$DA74: bd 1a 03  LDA   $031A,X
$DA77: 38        SEC
$DA78: e5 08     SBC   $08
$DA7A: 90 04     BCC   $DA80
$DA7C: c9 10     CMP   #$10
$DA7E: b0 02     BCS   $DA82
$DA80: a9 0a     LDA   #$0A
$DA82: 85 09     STA   $09
$DA84: 20 d9 d8  JSR   $D8D9
$DA87: d0 07     BNE   $DA90
$DA89: b5 a0     LDA   $A0,X
$DA8B: 4a        LSR
$DA8C: a9 1b     LDA   #$1B
$DA8E: b0 05     BCS   $DA95
$DA90: a9 0a     LDA   #$0A
$DA92: 18        CLC
$DA93: 65 08     ADC   $08
$DA95: 85 08     STA   $08
$DA97: a5 09     LDA   $09
$DA99: 18        CLC
$DA9A: 65 fc     ADC   $FC
$DA9C: 29 0f     AND   #$0F
$DA9E: 85 0b     STA   $0B
$DAA0: a9 10     LDA   #$10
$DAA2: 38        SEC
$DAA3: e5 0b     SBC   $0B
$DAA5: 85 0b     STA   $0B
$DAA7: a5 0a     LDA   $0A
$DAA9: a4 09     LDY   $09
$DAAB: 20 b8 df  JSR   $DFB8
$DAAE: 30 1f     BMI   $DACF
$DAB0: a5 0b     LDA   $0B
$DAB2: c5 08     CMP   $08
$DAB4: b0 1b     BCS   $DAD1
$DAB6: 69 10     ADC   #$10
$DAB8: 85 0b     STA   $0B
$DABA: a5 13     LDA   $13
$DABC: 29 c0     AND   #$C0
$DABE: 85 17     STA   $17
$DAC0: a5 13     LDA   $13
$DAC2: 18        CLC
$DAC3: 69 04     ADC   #$04
$DAC5: 29 3f     AND   #$3F
$DAC7: 05 17     ORA   $17
$DAC9: a8        TAY
$DACA: 20 e0 df  JSR   $DFE0
$DACD: 10 e1     BPL   $DAB0
$DACF: 38        SEC
$DAD0: 60        RTS
$DAD1: 18        CLC
$DAD2: 60        RTS
$DAD3: a5 41     LDA   $41
$DAD5: d0 23     BNE   $DAFA
$DAD7: a5 40     LDA   $40
$DAD9: d0 36     BNE   $DB11
$DADB: a9 30     LDA   #$30
$DADD: 85 61     STA   $61
$DADF: a9 00     LDA   #$00
$DAE1: 85 64     STA   $64
$DAE3: 85 65     STA   $65
$DAE5: 85 69     STA   $69
$DAE7: 85 60     STA   $60
$DAE9: 85 62     STA   $62
$DAEB: a9 20     LDA   #$20
$DAED: 85 63     STA   $63
$DAEF: a9 c0     LDA   #$C0
$DAF1: 85 66     STA   $66
$DAF3: a9 23     LDA   #$23
$DAF5: 85 67     STA   $67
$DAF7: 4c 9a e0  JMP   $E09A
$DAFA: a9 00     LDA   #$00
$DAFC: 85 65     STA   $65
$DAFE: 85 64     STA   $64
$DB00: 85 69     STA   $69
$DB02: a9 1d     LDA   #$1D
$DB04: 85 60     STA   $60
$DB06: a9 a0     LDA   #$A0
$DB08: 85 62     STA   $62
$DB0A: a9 23     LDA   #$23
$DB0C: 85 63     STA   $63
$DB0E: 4c 9a e0  JMP   $E09A
$DB11: a9 10     LDA   #$10
$DB13: 85 74     STA   $74
$DB15: 20 e3 ce  JSR   $CEE3
$DB18: a9 20     LDA   #$20
$DB1A: d0 c1     BNE   $DADD
$DB1C: a5 41     LDA   $41
$DB1E: d0 30     BNE   $DB50
$DB20: a5 40     LDA   $40
$DB22: d0 50     BNE   $DB74
$DB24: 20 4b dd  JSR   $DD4B
$DB27: 20 79 de  JSR   $DE79
$DB2A: e6 62     INC   $62
$DB2C: e6 60     INC   $60
$DB2E: c6 61     DEC   $61
$DB30: f0 1d     BEQ   $DB4F
$DB32: a5 60     LDA   $60
$DB34: c9 20     CMP   #$20
$DB36: 90 15     BCC   $DB4D
$DB38: a9 00     LDA   #$00
$DB3A: 85 62     STA   $62
$DB3C: 85 60     STA   $60
$DB3E: a9 24     LDA   #$24
$DB40: 85 63     STA   $63
$DB42: a9 27     LDA   #$27
$DB44: 85 67     STA   $67
$DB46: a9 40     LDA   #$40
$DB48: 85 69     STA   $69
$DB4A: 20 93 e0  JSR   $E093
$DB4D: a9 ff     LDA   #$FF
$DB4F: 60        RTS
$DB50: 20 ef dd  JSR   $DDEF
$DB53: 20 c7 de  JSR   $DEC7
$DB56: a5 62     LDA   $62
$DB58: 38        SEC
$DB59: e9 20     SBC   #$20
$DB5B: 85 62     STA   $62
$DB5D: a5 63     LDA   $63
$DB5F: e9 00     SBC   #$00
$DB61: 85 63     STA   $63
$DB63: c6 60     DEC   $60
$DB65: 10 e6     BPL   $DB4D
$DB67: 20 fa da  JSR   $DAFA
$DB6A: a9 40     LDA   #$40
$DB6C: 85 69     STA   $69
$DB6E: 20 93 e0  JSR   $E093
$DB71: a9 00     LDA   #$00
$DB73: 60        RTS
$DB74: 20 4b dd  JSR   $DD4B
$DB77: 20 79 de  JSR   $DE79
$DB7A: e6 62     INC   $62
$DB7C: e6 60     INC   $60
$DB7E: c6 61     DEC   $61
$DB80: 60        RTS
$DB81: a5 41     LDA   $41
$DB83: f0 03     BEQ   $DB88
$DB85: 4c 0d dc  JMP   $DC0D
$DB88: a5 40     LDA   $40
$DB8A: f0 03     BEQ   $DB8F
$DB8C: 4c 93 dc  JMP   $DC93
$DB8F: a5 76     LDA   $76
$DB91: f0 04     BEQ   $DB97
$DB93: c6 76     DEC   $76
$DB95: d0 0a     BNE   $DBA1
$DB97: a5 75     LDA   $75
$DB99: f0 0a     BEQ   $DBA5
$DB9B: c6 75     DEC   $75
$DB9D: d0 02     BNE   $DBA1
$DB9F: e6 84     INC   $84
$DBA1: a9 01     LDA   #$01
$DBA3: 85 68     STA   $68
$DBA5: a5 68     LDA   $68
$DBA7: 18        CLC
$DBA8: 65 77     ADC   $77
$DBAA: f0 52     BEQ   $DBFE
$DBAC: 85 17     STA   $17
$DBAE: e6 65     INC   $65
$DBB0: d0 18     BNE   $DBCA
$DBB2: e6 64     INC   $64
$DBB4: a5 64     LDA   $64
$DBB6: c5 48     CMP   $48
$DBB8: d0 06     BNE   $DBC0
$DBBA: 20 6e c7  JSR   $C76E
$DBBD: 20 c6 ce  JSR   $CEC6
$DBC0: a9 00     LDA   #$00
$DBC2: 85 82     STA   $82
$DBC4: a5 ff     LDA   $FF
$DBC6: 49 01     EOR   #$01
$DBC8: 85 ff     STA   $FF
$DBCA: a5 65     LDA   $65
$DBCC: 29 07     AND   #$07
$DBCE: d0 2f     BNE   $DBFF
$DBD0: 20 4b dd  JSR   $DD4B
$DBD3: e6 62     INC   $62
$DBD5: e6 60     INC   $60
$DBD7: a5 60     LDA   $60
$DBD9: c9 20     CMP   #$20
$DBDB: 90 1b     BCC   $DBF8
$DBDD: a5 69     LDA   $69
$DBDF: 49 40     EOR   #$40
$DBE1: 85 69     STA   $69
$DBE3: 20 8c e0  JSR   $E08C
$DBE6: a9 00     LDA   #$00
$DBE8: 85 62     STA   $62
$DBEA: 85 60     STA   $60
$DBEC: a5 63     LDA   $63
$DBEE: 49 04     EOR   #$04
$DBF0: 85 63     STA   $63
$DBF2: a5 67     LDA   $67
$DBF4: 49 04     EOR   #$04
$DBF6: 85 67     STA   $67
$DBF8: e6 fd     INC   $FD
$DBFA: c6 17     DEC   $17
$DBFC: d0 b0     BNE   $DBAE
$DBFE: 60        RTS
$DBFF: a5 65     LDA   $65
$DC01: 29 0f     AND   #$0F
$DC03: c9 03     CMP   #$03
$DC05: d0 f1     BNE   $DBF8
$DC07: 20 79 de  JSR   $DE79
$DC0A: 4c f8 db  JMP   $DBF8
$DC0D: a5 75     LDA   $75
$DC0F: f0 0e     BEQ   $DC1F
$DC11: a9 10     LDA   #$10
$DC13: 85 74     STA   $74
$DC15: a9 01     LDA   #$01
$DC17: 85 68     STA   $68
$DC19: c6 75     DEC   $75
$DC1B: d0 02     BNE   $DC1F
$DC1D: e6 84     INC   $84
$DC1F: a5 68     LDA   $68
$DC21: f0 61     BEQ   $DC84
$DC23: 85 17     STA   $17
$DC25: e6 65     INC   $65
$DC27: a5 65     LDA   $65
$DC29: c9 f0     CMP   #$F0
$DC2B: 90 18     BCC   $DC45
$DC2D: a9 00     LDA   #$00
$DC2F: 85 65     STA   $65
$DC31: 85 82     STA   $82
$DC33: e6 64     INC   $64
$DC35: a5 64     LDA   $64
$DC37: c5 48     CMP   $48
$DC39: d0 0a     BNE   $DC45
$DC3B: 20 6e c7  JSR   $C76E
$DC3E: a9 80     LDA   #$80
$DC40: 85 74     STA   $74
$DC42: 20 c6 ce  JSR   $CEC6
$DC45: a5 65     LDA   $65
$DC47: 29 07     AND   #$07
$DC49: d0 3a     BNE   $DC85
$DC4B: 20 ef dd  JSR   $DDEF
$DC4E: a5 62     LDA   $62
$DC50: 38        SEC
$DC51: e9 20     SBC   #$20
$DC53: 85 62     STA   $62
$DC55: a5 63     LDA   $63
$DC57: e9 00     SBC   #$00
$DC59: 85 63     STA   $63
$DC5B: c6 60     DEC   $60
$DC5D: 10 15     BPL   $DC74
$DC5F: a5 69     LDA   $69
$DC61: 49 40     EOR   #$40
$DC63: 85 69     STA   $69
$DC65: 20 93 e0  JSR   $E093
$DC68: a9 1d     LDA   #$1D
$DC6A: 85 60     STA   $60
$DC6C: a9 a0     LDA   #$A0
$DC6E: 85 62     STA   $62
$DC70: a9 23     LDA   #$23
$DC72: 85 63     STA   $63
$DC74: c6 fc     DEC   $FC
$DC76: a5 fc     LDA   $FC
$DC78: c9 ff     CMP   #$FF
$DC7A: d0 04     BNE   $DC80
$DC7C: a9 ef     LDA   #$EF
$DC7E: 85 fc     STA   $FC
$DC80: c6 17     DEC   $17
$DC82: d0 a1     BNE   $DC25
$DC84: 60        RTS
$DC85: a5 65     LDA   $65
$DC87: 29 0f     AND   #$0F
$DC89: c9 07     CMP   #$07
$DC8B: d0 e7     BNE   $DC74
$DC8D: 20 c7 de  JSR   $DEC7
$DC90: 4c 74 dc  JMP   $DC74
$DC93: a5 6a     LDA   $6A
$DC95: 10 5c     BPL   $DCF3
$DC97: a5 61     LDA   $61
$DC99: 30 59     BMI   $DCF4
$DC9B: d0 44     BNE   $DCE1
$DC9D: a5 73     LDA   $73
$DC9F: f0 52     BEQ   $DCF3
$DCA1: a9 00     LDA   #$00
$DCA3: 85 60     STA   $60
$DCA5: 85 62     STA   $62
$DCA7: 85 66     STA   $66
$DCA9: a9 20     LDA   #$20
$DCAB: 85 61     STA   $61
$DCAD: a5 63     LDA   $63
$DCAF: 49 04     EOR   #$04
$DCB1: 85 63     STA   $63
$DCB3: a5 67     LDA   $67
$DCB5: 49 04     EOR   #$04
$DCB7: 85 67     STA   $67
$DCB9: a5 64     LDA   $64
$DCBB: c5 48     CMP   $48
$DCBD: d0 18     BNE   $DCD7
$DCBF: a5 65     LDA   $65
$DCC1: c9 03     CMP   #$03
$DCC3: d0 12     BNE   $DCD7
$DCC5: a0 00     LDY   #$00
$DCC7: b9 45 dd  LDA   $DD45,Y
$DCCA: 99 42 00  STA   $0042,Y
$DCCD: c8        INY
$DCCE: c0 06     CPY   #$06
$DCD0: d0 f5     BNE   $DCC7
$DCD2: a5 30     LDA   $30
$DCD4: 4a        LSR
$DCD5: b0 07     BCS   $DCDE
$DCD7: a5 64     LDA   $64
$DCD9: 0a        ASL
$DCDA: 0a        ASL
$DCDB: 38        SEC
$DCDC: 65 65     ADC   $65
$DCDE: 20 9c e0  JSR   $E09C
$DCE1: 20 4b dd  JSR   $DD4B
$DCE4: 20 79 de  JSR   $DE79
$DCE7: e6 60     INC   $60
$DCE9: e6 62     INC   $62
$DCEB: c6 61     DEC   $61
$DCED: d0 04     BNE   $DCF3
$DCEF: a9 80     LDA   #$80
$DCF1: 85 61     STA   $61
$DCF3: 60        RTS
$DCF4: a9 00     LDA   #$00
$DCF6: 85 61     STA   $61
$DCF8: e6 73     INC   $73
$DCFA: e6 65     INC   $65
$DCFC: a5 65     LDA   $65
$DCFE: c9 04     CMP   #$04
$DD00: d0 3c     BNE   $DD3E
$DD02: e6 ca     INC   $CA
$DD04: e6 cb     INC   $CB
$DD06: a9 00     LDA   #$00
$DD08: 85 6a     STA   $6A
$DD0A: 85 65     STA   $65
$DD0C: 85 82     STA   $82
$DD0E: e6 64     INC   $64
$DD10: a5 64     LDA   $64
$DD12: c5 58     CMP   $58
$DD14: d0 1f     BNE   $DD35
$DD16: a9 80     LDA   #$80
$DD18: 85 40     STA   $40
$DD1A: 20 c6 ce  JSR   $CEC6
$DD1D: 20 d4 f9  JSR   $F9D4
$DD20: a5 30     LDA   $30
$DD22: 4a        LSR
$DD23: 09 08     ORA   #$08
$DD25: 20 78 c7  JSR   $C778
$DD28: a9 5e     LDA   #$5E
$DD2A: 20 bc f9  JSR   $F9BC
$DD2D: a9 b1     LDA   #$B1
$DD2F: 85 ff     STA   $FF
$DD31: a9 e0     LDA   #$E0
$DD33: 85 fc     STA   $FC
$DD35: a9 0c     LDA   #$0C
$DD37: 85 74     STA   $74
$DD39: a9 20     LDA   #$20
$DD3B: 20 e3 ce  JSR   $CEE3
$DD3E: a5 ff     LDA   $FF
$DD40: 49 01     EOR   #$01
$DD42: 85 ff     STA   $FF
$DD44: 60        RTS
$DD45: e3 90 8a b6 8a be .byte $E3 …
$DD4B: a6 21     LDX   $21
$DD4D: a9 02     LDA   #$02
$DD4F: 9d 00 07  STA   $0700,X
$DD52: a9 1c     LDA   #$1C
$DD54: e8        INX
$DD55: 9d 00 07  STA   $0700,X
$DD58: a9 01     LDA   #$01
$DD5A: e8        INX
$DD5B: 9d 00 07  STA   $0700,X
$DD5E: a5 63     LDA   $63
$DD60: e8        INX
$DD61: 9d 00 07  STA   $0700,X
$DD64: 85 12     STA   $12
$DD66: a5 62     LDA   $62
$DD68: e8        INX
$DD69: 9d 00 07  STA   $0700,X
$DD6C: e8        INX
$DD6D: a0 ff     LDY   #$FF
$DD6F: 4a        LSR
$DD70: b0 14     BCS   $DD86
$DD72: 85 13     STA   $13
$DD74: 46 12     LSR   $12
$DD76: 46 12     LSR   $12
$DD78: 46 12     LSR   $12
$DD7A: 6a        ROR
$DD7B: 4a        LSR
$DD7C: 85 12     STA   $12
$DD7E: a5 13     LDA   $13
$DD80: 29 03     AND   #$03
$DD82: 85 13     STA   $13
$DD84: a0 00     LDY   #$00
$DD86: 84 11     STY   $11
$DD88: a5 60     LDA   $60
$DD8A: 29 03     AND   #$03
$DD8C: 85 02     STA   $02
$DD8E: a5 60     LDA   $60
$DD90: 4a        LSR
$DD91: 4a        LSR
$DD92: 05 69     ORA   $69
$DD94: 85 10     STA   $10
$DD96: a8        TAY
$DD97: a9 00     LDA   #$00
$DD99: 85 08     STA   $08
$DD9B: b9 00 06  LDA   $0600,Y
$DD9E: 0a        ASL
$DD9F: 0a        ASL
$DDA0: 26 08     ROL   $08
$DDA2: 0a        ASL
$DDA3: 26 08     ROL   $08
$DDA5: 0a        ASL
$DDA6: 26 08     ROL   $08
$DDA8: 65 44     ADC   $44
$DDAA: 85 00     STA   $00
$DDAC: a5 08     LDA   $08
$DDAE: 65 45     ADC   $45
$DDB0: 85 01     STA   $01
$DDB2: a4 02     LDY   $02
$DDB4: b1 00     LDA   ($00),Y
$DDB6: 9d 00 07  STA   $0700,X
$DDB9: 20 30 df  JSR   $DF30
$DDBC: e8        INX
$DDBD: c8        INY
$DDBE: c8        INY
$DDBF: c8        INY
$DDC0: c8        INY
$DDC1: b1 00     LDA   ($00),Y
$DDC3: 9d 00 07  STA   $0700,X
$DDC6: e8        INX
$DDC7: c8        INY
$DDC8: c8        INY
$DDC9: c8        INY
$DDCA: c8        INY
$DDCB: b1 00     LDA   ($00),Y
$DDCD: 9d 00 07  STA   $0700,X
$DDD0: 20 30 df  JSR   $DF30
$DDD3: e8        INX
$DDD4: c8        INY
$DDD5: c8        INY
$DDD6: c8        INY
$DDD7: c8        INY
$DDD8: b1 00     LDA   ($00),Y
$DDDA: 9d 00 07  STA   $0700,X
$DDDD: e8        INX
$DDDE: a5 10     LDA   $10
$DDE0: 18        CLC
$DDE1: 69 08     ADC   #$08
$DDE3: 85 10     STA   $10
$DDE5: a8        TAY
$DDE6: 29 3f     AND   #$3F
$DDE8: c9 38     CMP   #$38
$DDEA: 90 ab     BCC   $DD97
$DDEC: 86 21     STX   $21
$DDEE: 60        RTS
$DDEF: a6 21     LDX   $21
$DDF1: a9 01     LDA   #$01
$DDF3: 9d 00 07  STA   $0700,X
$DDF6: 9d 02 07  STA   $0702,X
$DDF9: a9 20     LDA   #$20
$DDFB: e8        INX
$DDFC: 9d 00 07  STA   $0700,X
$DDFF: e8        INX
$DE00: a5 63     LDA   $63
$DE02: e8        INX
$DE03: 9d 00 07  STA   $0700,X
$DE06: a5 62     LDA   $62
$DE08: e8        INX
$DE09: 9d 00 07  STA   $0700,X
$DE0C: e8        INX
$DE0D: a9 00     LDA   #$00
$DE0F: 85 11     STA   $11
$DE11: 85 13     STA   $13
$DE13: a5 60     LDA   $60
$DE15: 29 03     AND   #$03
$DE17: 0a        ASL
$DE18: 0a        ASL
$DE19: 85 02     STA   $02
$DE1B: a5 60     LDA   $60
$DE1D: 29 1c     AND   #$1C
$DE1F: 0a        ASL
$DE20: 05 69     ORA   $69
$DE22: 85 10     STA   $10
$DE24: a5 60     LDA   $60
$DE26: 4a        LSR
$DE27: 66 11     ROR   $11
$DE29: 0a        ASL
$DE2A: 0a        ASL
$DE2B: 85 12     STA   $12
$DE2D: a4 10     LDY   $10
$DE2F: a9 00     LDA   #$00
$DE31: 85 08     STA   $08
$DE33: b9 00 06  LDA   $0600,Y
$DE36: 0a        ASL
$DE37: 0a        ASL
$DE38: 26 08     ROL   $08
$DE3A: 0a        ASL
$DE3B: 26 08     ROL   $08
$DE3D: 0a        ASL
$DE3E: 26 08     ROL   $08
$DE40: 65 44     ADC   $44
$DE42: 85 00     STA   $00
$DE44: a5 08     LDA   $08
$DE46: 65 45     ADC   $45
$DE48: 85 01     STA   $01
$DE4A: a4 02     LDY   $02
$DE4C: b1 00     LDA   ($00),Y
$DE4E: 9d 00 07  STA   $0700,X
$DE51: 20 30 df  JSR   $DF30
$DE54: e8        INX
$DE55: c8        INY
$DE56: b1 00     LDA   ($00),Y
$DE58: 9d 00 07  STA   $0700,X
$DE5B: e8        INX
$DE5C: c8        INY
$DE5D: b1 00     LDA   ($00),Y
$DE5F: 9d 00 07  STA   $0700,X
$DE62: 20 30 df  JSR   $DF30
$DE65: e8        INX
$DE66: c8        INY
$DE67: b1 00     LDA   ($00),Y
$DE69: 9d 00 07  STA   $0700,X
$DE6C: e8        INX
$DE6D: e6 10     INC   $10
$DE6F: a5 10     LDA   $10
$DE71: a8        TAY
$DE72: 29 07     AND   #$07
$DE74: d0 b9     BNE   $DE2F
$DE76: 86 21     STX   $21
$DE78: 60        RTS
$DE79: a6 21     LDX   $21
$DE7B: a9 01     LDA   #$01
$DE7D: 9d 00 07  STA   $0700,X
$DE80: e8        INX
$DE81: 9d 00 07  STA   $0700,X
$DE84: e8        INX
$DE85: a9 07     LDA   #$07
$DE87: 9d 00 07  STA   $0700,X
$DE8A: e8        INX
$DE8B: a5 60     LDA   $60
$DE8D: 4a        LSR
$DE8E: 4a        LSR
$DE8F: 09 c0     ORA   #$C0
$DE91: 85 00     STA   $00
$DE93: 29 0f     AND   #$0F
$DE95: 05 69     ORA   $69
$DE97: 85 10     STA   $10
$DE99: a8        TAY
$DE9A: a5 67     LDA   $67
$DE9C: 9d 00 07  STA   $0700,X
$DE9F: e8        INX
$DEA0: a5 00     LDA   $00
$DEA2: 9d 00 07  STA   $0700,X
$DEA5: e8        INX
$DEA6: b9 00 06  LDA   $0600,Y
$DEA9: a8        TAY
$DEAA: b1 46     LDA   ($46),Y
$DEAC: 9d 00 07  STA   $0700,X
$DEAF: e8        INX
$DEB0: a5 00     LDA   $00
$DEB2: 18        CLC
$DEB3: 69 08     ADC   #$08
$DEB5: 85 00     STA   $00
$DEB7: c9 f8     CMP   #$F8
$DEB9: b0 09     BCS   $DEC4
$DEBB: a5 10     LDA   $10
$DEBD: 69 08     ADC   #$08
$DEBF: 85 10     STA   $10
$DEC1: a8        TAY
$DEC2: 90 d6     BCC   $DE9A
$DEC4: 86 21     STX   $21
$DEC6: 60        RTS
$DEC7: a6 21     LDX   $21
$DEC9: a9 01     LDA   #$01
$DECB: 9d 00 07  STA   $0700,X
$DECE: 9d 02 07  STA   $0702,X
$DED1: a9 08     LDA   #$08
$DED3: e8        INX
$DED4: 9d 00 07  STA   $0700,X
$DED7: e8        INX
$DED8: a9 23     LDA   #$23
$DEDA: e8        INX
$DEDB: 9d 00 07  STA   $0700,X
$DEDE: a5 60     LDA   $60
$DEE0: 0a        ASL
$DEE1: 29 38     AND   #$38
$DEE3: 05 69     ORA   $69
$DEE5: 85 10     STA   $10
$DEE7: 29 bf     AND   #$BF
$DEE9: 18        CLC
$DEEA: 69 c0     ADC   #$C0
$DEEC: e8        INX
$DEED: 9d 00 07  STA   $0700,X
$DEF0: e8        INX
$DEF1: a5 60     LDA   $60
$DEF3: 29 03     AND   #$03
$DEF5: c9 03     CMP   #$03
$DEF7: f0 18     BEQ   $DF11
$DEF9: a5 10     LDA   $10
$DEFB: a8        TAY
$DEFC: b9 00 06  LDA   $0600,Y
$DEFF: a8        TAY
$DF00: b1 46     LDA   ($46),Y
$DF02: 9d 00 07  STA   $0700,X
$DF05: e8        INX
$DF06: e6 10     INC   $10
$DF08: a5 10     LDA   $10
$DF0A: 29 07     AND   #$07
$DF0C: d0 e3     BNE   $DEF1
$DF0E: 86 21     STX   $21
$DF10: 60        RTS
$DF11: a5 10     LDA   $10
$DF13: a8        TAY
$DF14: b9 00 06  LDA   $0600,Y
$DF17: a8        TAY
$DF18: b1 46     LDA   ($46),Y
$DF1A: 29 f0     AND   #$F0
$DF1C: 85 11     STA   $11
$DF1E: a5 10     LDA   $10
$DF20: 49 40     EOR   #$40
$DF22: a8        TAY
$DF23: b9 00 06  LDA   $0600,Y
$DF26: a8        TAY
$DF27: b1 46     LDA   ($46),Y
$DF29: 29 0f     AND   #$0F
$DF2B: 05 11     ORA   $11
$DF2D: 4c 02 df  JMP   $DF02
$DF30: 84 14     STY   $14
$DF32: a4 11     LDY   $11
$DF34: d0 6f     BNE   $DFA5
$DF36: a8        TAY
$DF37: f0 0c     BEQ   $DF45
$DF39: c5 49     CMP   $49
$DF3B: b0 04     BCS   $DF41
$DF3D: a9 01     LDA   #$01
$DF3F: d0 12     BNE   $DF53
$DF41: c5 4a     CMP   $4A
$DF43: b0 04     BCS   $DF49
$DF45: a9 00     LDA   #$00
$DF47: f0 0a     BEQ   $DF53
$DF49: c5 4b     CMP   $4B
$DF4B: b0 04     BCS   $DF51
$DF4D: a9 02     LDA   #$02
$DF4F: d0 02     BNE   $DF53
$DF51: a9 03     LDA   #$03
$DF53: a4 13     LDY   $13
$DF55: d0 12     BNE   $DF69
$DF57: 0a        ASL
$DF58: 0a        ASL
$DF59: 0a        ASL
$DF5A: 0a        ASL
$DF5B: 0a        ASL
$DF5C: 0a        ASL
$DF5D: 85 15     STA   $15
$DF5F: a4 12     LDY   $12
$DF61: b9 80 06  LDA   $0680,Y
$DF64: 29 3f     AND   #$3F
$DF66: 4c 96 df  JMP   $DF96
$DF69: 88        DEY
$DF6A: d0 10     BNE   $DF7C
$DF6C: 0a        ASL
$DF6D: 0a        ASL
$DF6E: 0a        ASL
$DF6F: 0a        ASL
$DF70: 85 15     STA   $15
$DF72: a4 12     LDY   $12
$DF74: b9 80 06  LDA   $0680,Y
$DF77: 29 cf     AND   #$CF
$DF79: 4c 96 df  JMP   $DF96
$DF7C: 88        DEY
$DF7D: d0 0e     BNE   $DF8D
$DF7F: 0a        ASL
$DF80: 0a        ASL
$DF81: 85 15     STA   $15
$DF83: a4 12     LDY   $12
$DF85: b9 80 06  LDA   $0680,Y
$DF88: 29 f3     AND   #$F3
$DF8A: 4c 96 df  JMP   $DF96
$DF8D: 85 15     STA   $15
$DF8F: a4 12     LDY   $12
$DF91: b9 80 06  LDA   $0680,Y
$DF94: 29 fc     AND   #$FC
$DF96: 05 15     ORA   $15
$DF98: 99 80 06  STA   $0680,Y
$DF9B: a5 41     LDA   $41
$DF9D: d0 09     BNE   $DFA8
$DF9F: 98        TYA
$DFA0: 18        CLC
$DFA1: 69 04     ADC   #$04
$DFA3: 85 12     STA   $12
$DFA5: a4 14     LDY   $14
$DFA7: 60        RTS
$DFA8: e6 13     INC   $13
$DFAA: a5 13     LDA   $13
$DFAC: c9 04     CMP   #$04
$DFAE: 90 f5     BCC   $DFA5
$DFB0: a9 00     LDA   #$00
$DFB2: 85 13     STA   $13
$DFB4: e6 12     INC   $12
$DFB6: d0 ed     BNE   $DFA5
$DFB8: 20 ec df  JSR   $DFEC
$DFBB: 48        PHA
$DFBC: 90 20     BCC   $DFDE
$DFBE: a5 13     LDA   $13
$DFC0: 85 16     STA   $16
$DFC2: 29 c0     AND   #$C0
$DFC4: 85 17     STA   $17
$DFC6: a5 16     LDA   $16
$DFC8: 18        CLC
$DFC9: 69 04     ADC   #$04
$DFCB: 29 3f     AND   #$3F
$DFCD: 05 17     ORA   $17
$DFCF: a8        TAY
$DFD0: 20 e6 df  JSR   $DFE6
$DFD3: 0a        ASL
$DFD4: a5 16     LDA   $16
$DFD6: 85 13     STA   $13
$DFD8: 90 04     BCC   $DFDE
$DFDA: 68        PLA
$DFDB: a9 80     LDA   #$80
$DFDD: 60        RTS
$DFDE: 68        PLA
$DFDF: 60        RTS
$DFE0: 20 e6 df  JSR   $DFE6
$DFE3: 4c bb df  JMP   $DFBB
$DFE6: a9 00     LDA   #$00
$DFE8: 85 15     STA   $15
$DFEA: f0 4a     BEQ   $E036
$DFEC: 85 13     STA   $13
$DFEE: a9 00     LDA   #$00
$DFF0: 85 10     STA   $10
$DFF2: f0 02     BEQ   $DFF6
$DFF4: 85 13     STA   $13
$DFF6: 98        TYA
$DFF7: 85 15     STA   $15
$DFF9: 18        CLC
$DFFA: 65 fc     ADC   $FC
$DFFC: b0 04     BCS   $E002
$DFFE: c9 f0     CMP   #$F0
$E000: 90 02     BCC   $E004
$E002: 69 0f     ADC   #$0F
$E004: 85 11     STA   $11
$E006: a5 13     LDA   $13
$E008: 18        CLC
$E009: 65 fd     ADC   $FD
$E00B: 85 12     STA   $12
$E00D: a5 ff     LDA   $FF
$E00F: 45 10     EOR   $10
$E011: 29 01     AND   #$01
$E013: 90 02     BCC   $E017
$E015: 49 01     EOR   #$01
$E017: a8        TAY
$E018: a5 11     LDA   $11
$E01A: 4a        LSR
$E01B: 4a        LSR
$E01C: 29 3c     AND   #$3C
$E01E: 85 11     STA   $11
$E020: a5 12     LDA   $12
$E022: 4a        LSR
$E023: 4a        LSR
$E024: 4a        LSR
$E025: 4a        LSR
$E026: 85 12     STA   $12
$E028: 4a        LSR
$E029: 4a        LSR
$E02A: 05 11     ORA   $11
$E02C: 19 61 e0  ORA   $E061,Y
$E02F: a8        TAY
$E030: a5 12     LDA   $12
$E032: 29 03     AND   #$03
$E034: 85 12     STA   $12
$E036: 84 13     STY   $13
$E038: a5 15     LDA   $15
$E03A: c9 e0     CMP   #$E0
$E03C: a9 00     LDA   #$00
$E03E: b0 1b     BCS   $E05B
$E040: b9 80 06  LDA   $0680,Y
$E043: a4 12     LDY   $12
$E045: f0 08     BEQ   $E04F
$E047: 88        DEY
$E048: f0 07     BEQ   $E051
$E04A: 88        DEY
$E04B: f0 06     BEQ   $E053
$E04D: d0 06     BNE   $E055
$E04F: 4a        LSR
$E050: 4a        LSR
$E051: 4a        LSR
$E052: 4a        LSR
$E053: 4a        LSR
$E054: 4a        LSR
$E055: 29 03     AND   #$03
$E057: a8        TAY
$E058: b9 63 e0  LDA   $E063,Y
$E05B: 85 14     STA   $14
$E05D: 4a        LSR
$E05E: a5 14     LDA   $14
$E060: 60        RTS
$E061: 00 40 00 01 02 80 .byte $00 …
$E067: a5 3b     LDA   $3B
$E069: d0 1c     BNE   $E087
$E06B: a5 58     LDA   $58
$E06D: 30 16     BMI   $E085
$E06F: c5 64     CMP   $64
$E071: d0 14     BNE   $E087
$E073: a4 41     LDY   $41
$E075: a5 65     LDA   $65
$E077: d9 88 e0  CMP   $E088,Y
$E07A: 90 0b     BCC   $E087
$E07C: b9 8a e0  LDA   $E08A,Y
$E07F: 85 75     STA   $75
$E081: a9 ff     LDA   #$FF
$E083: 85 58     STA   $58
$E085: a9 00     LDA   #$00
$E087: 60        RTS
$E088: a0 c0 60 40 .byte $A0 …
$E08C: a5 64     LDA   $64
$E08E: 18        CLC
$E08F: 69 02     ADC   #$02
$E091: d0 09     BNE   $E09C
$E093: a5 64     LDA   $64
$E095: 18        CLC
$E096: 69 01     ADC   #$01
$E098: d0 02     BNE   $E09C
$E09A: a5 64     LDA   $64
$E09C: 0a        ASL
$E09D: aa        TAX
$E09E: a0 14     LDY   #$14
$E0A0: 20 89 f9  JSR   $F989
$E0A3: 8a        TXA
$E0A4: a8        TAY
$E0A5: b1 42     LDA   ($42),Y
$E0A7: 85 00     STA   $00
$E0A9: c8        INY
$E0AA: b1 42     LDA   ($42),Y
$E0AC: 85 01     STA   $01
$E0AE: a0 00     LDY   #$00
$E0B0: a6 69     LDX   $69
$E0B2: b1 00     LDA   ($00),Y
$E0B4: c8        INY
$E0B5: c9 80     CMP   #$80
$E0B7: b0 1e     BCS   $E0D7
$E0B9: 9d 00 06  STA   $0600,X
$E0BC: e8        INX
$E0BD: a5 41     LDA   $41
$E0BF: d0 0b     BNE   $E0CC
$E0C1: e0 38     CPX   #$38
$E0C3: f0 0f     BEQ   $E0D4
$E0C5: e0 78     CPX   #$78
$E0C7: 90 e9     BCC   $E0B2
$E0C9: 4c 97 f9  JMP   $F997
$E0CC: e0 40     CPX   #$40
$E0CE: f0 04     BEQ   $E0D4
$E0D0: e0 80     CPX   #$80
$E0D2: 90 de     BCC   $E0B2
$E0D4: 4c 97 f9  JMP   $F997
$E0D7: c9 f0     CMP   #$F0
$E0D9: b0 11     BCS   $E0EC
$E0DB: 29 7f     AND   #$7F
$E0DD: 85 02     STA   $02
$E0DF: b1 00     LDA   ($00),Y
$E0E1: c8        INY
$E0E2: 9d 00 06  STA   $0600,X
$E0E5: e8        INX
$E0E6: c6 02     DEC   $02
$E0E8: d0 f8     BNE   $E0E2
$E0EA: f0 d1     BEQ   $E0BD
$E0EC: 29 0f     AND   #$0F
$E0EE: 0a        ASL
$E0EF: 0a        ASL
$E0F0: 0a        ASL
$E0F1: 05 69     ORA   $69
$E0F3: 84 03     STY   $03
$E0F5: a8        TAY
$E0F6: a9 08     LDA   #$08
$E0F8: 85 02     STA   $02
$E0FA: b9 00 06  LDA   $0600,Y
$E0FD: 9d 00 06  STA   $0600,X
$E100: e8        INX
$E101: c8        INY
$E102: c6 02     DEC   $02
$E104: d0 f4     BNE   $E0FA
$E106: a4 03     LDY   $03
$E108: d0 b3     BNE   $E0BD
$E10A: a2 01     LDX   #$01
$E10C: a4 83     LDY   $83
$E10E: b5 90     LDA   $90,X
$E110: c9 01     CMP   #$01
$E112: d0 79     BNE   $E18D
$E114: a5 40     LDA   $40
$E116: 4a        LSR
$E117: 90 0f     BCC   $E128
$E119: b9 28 05  LDA   $0528,Y
$E11C: c9 01     CMP   #$01
$E11E: d0 3b     BNE   $E15B
$E120: b5 bc     LDA   $BC,X
$E122: c9 02     CMP   #$02
$E124: d0 35     BNE   $E15B
$E126: f0 65     BEQ   $E18D
$E128: b9 98 05  LDA   $0598,Y
$E12B: 0a        ASL
$E12C: 10 2d     BPL   $E15B
$E12E: 0a        ASL
$E12F: 10 1c     BPL   $E14D
$E131: b9 24 03  LDA   $0324,Y
$E134: 38        SEC
$E135: fd 1a 03  SBC   $031A,X
$E138: 90 09     BCC   $E143
$E13A: c9 08     CMP   #$08
$E13C: b9 98 05  LDA   $0598,Y
$E13F: 29 ef     AND   #$EF
$E141: b0 05     BCS   $E148
$E143: b9 98 05  LDA   $0598,Y
$E146: 09 10     ORA   #$10
$E148: 99 98 05  STA   $0598,Y
$E14B: d0 0e     BNE   $E15B
$E14D: b5 a0     LDA   $A0,X
$E14F: f0 0a     BEQ   $E15B
$E151: b5 c6     LDA   $C6,X
$E153: 30 38     BMI   $E18D
$E155: c9 01     CMP   #$01
$E157: 90 34     BCC   $E18D
$E159: b0 00     BCS   $E15B
$E15B: a0 00     LDY   #$00
$E15D: b5 b2     LDA   $B2,X
$E15F: f0 08     BEQ   $E169
$E161: b5 f1     LDA   $F1,X
$E163: 29 04     AND   #$04
$E165: d0 26     BNE   $E18D
$E167: f0 0d     BEQ   $E176
$E169: c8        INY
$E16A: b5 a0     LDA   $A0,X
$E16C: d0 08     BNE   $E176
$E16E: c8        INY
$E16F: b5 d6     LDA   $D6,X
$E171: c9 17     CMP   #$17
$E173: f0 01     BEQ   $E176
$E175: c8        INY
$E176: 20 42 e3  JSR   $E342
$E179: bd 1a 03  LDA   $031A,X
$E17C: 38        SEC
$E17D: e5 08     SBC   $08
$E17F: c5 0a     CMP   $0A
$E181: b0 0a     BCS   $E18D
$E183: bd 34 03  LDA   $0334,X
$E186: 38        SEC
$E187: e5 09     SBC   $09
$E189: c5 0b     CMP   $0B
$E18B: 90 43     BCC   $E1D0
$E18D: ca        DEX
$E18E: 30 03     BMI   $E193
$E190: 4c 0c e1  JMP   $E10C
$E193: a6 83     LDX   $83
$E195: 60        RTS
$E196: bd 1a 03  LDA   $031A,X
$E199: d5 b8     CMP   $B8,X
$E19B: 90 f0     BCC   $E18D
$E19D: a9 01     LDA   #$01
$E19F: 99 68 05  STA   $0568,Y
$E1A2: b9 18 05  LDA   $0518,Y
$E1A5: 18        CLC
$E1A6: 79 d8 04  ADC   $04D8,Y
$E1A9: b9 08 05  LDA   $0508,Y
$E1AC: 69 00     ADC   #$00
$E1AE: 18        CLC
$E1AF: 75 d4     ADC   $D4,X
$E1B1: 95 d4     STA   $D4,X
$E1B3: b9 98 05  LDA   $0598,Y
$E1B6: 0a        ASL
$E1B7: 0a        ASL
$E1B8: 0a        ASL
$E1B9: a9 e4     LDA   #$E4
$E1BB: 90 02     BCC   $E1BF
$E1BD: a9 e8     LDA   #$E8
$E1BF: 18        CLC
$E1C0: 79 24 03  ADC   $0324,Y
$E1C3: 9d 1a 03  STA   $031A,X
$E1C6: a9 01     LDA   #$01
$E1C8: 95 b6     STA   $B6,X
$E1CA: 20 9d d7  JSR   $D79D
$E1CD: 4c 8d e1  JMP   $E18D
$E1D0: a4 83     LDY   $83
$E1D2: b9 3e 03  LDA   $033E,Y
$E1D5: 38        SEC
$E1D6: fd 34 03  SBC   $0334,X
$E1D9: b0 04     BCS   $E1DF
$E1DB: 49 ff     EOR   #$FF
$E1DD: 69 01     ADC   #$01
$E1DF: c9 80     CMP   #$80
$E1E1: b0 aa     BCS   $E18D
$E1E3: b9 98 05  LDA   $0598,Y
$E1E6: 0a        ASL
$E1E7: 10 04     BPL   $E1ED
$E1E9: 29 20     AND   #$20
$E1EB: f0 a9     BEQ   $E196
$E1ED: b9 28 05  LDA   $0528,Y
$E1F0: f0 2b     BEQ   $E21D
$E1F2: b5 ae     LDA   $AE,X
$E1F4: d0 97     BNE   $E18D
$E1F6: b5 b0     LDA   $B0,X
$E1F8: d0 0d     BNE   $E207
$E1FA: 20 74 d4  JSR   $D474
$E1FD: b9 28 05  LDA   $0528,Y
$E200: c9 01     CMP   #$01
$E202: f0 6d     BEQ   $E271
$E204: a6 83     LDX   $83
$E206: 60        RTS
$E207: 86 17     STX   $17
$E209: a6 83     LDX   $83
$E20B: bd 78 05  LDA   $0578,X
$E20E: f0 0c     BEQ   $E21C
$E210: c9 f0     CMP   #$F0
$E212: b0 08     BCS   $E21C
$E214: a9 00     LDA   #$00
$E216: 9d 78 05  STA   $0578,X
$E219: 20 a6 e8  JSR   $E8A6
$E21C: 60        RTS
$E21D: 86 10     STX   $10
$E21F: a9 0a     LDA   #$0A
$E221: 85 00     STA   $00
$E223: 8a        TXA
$E224: a8        TAY
$E225: 20 3b c3  JSR   $C33B
$E228: a6 10     LDX   $10
$E22A: a4 83     LDY   $83
$E22C: a9 38     LDA   #$38
$E22E: 20 bc f9  JSR   $F9BC
$E231: b9 a8 05  LDA   $05A8,Y
$E234: 29 07     AND   #$07
$E236: f0 1e     BEQ   $E256
$E238: c9 05     CMP   #$05
$E23A: 90 22     BCC   $E25E
$E23C: f0 09     BEQ   $E247
$E23E: 20 49 e9  JSR   $E949
$E241: a9 20     LDA   #$20
$E243: 85 7d     STA   $7D
$E245: d0 2a     BNE   $E271
$E247: a9 80     LDA   #$80
$E249: a4 30     LDY   $30
$E24B: c0 06     CPY   #$06
$E24D: d0 02     BNE   $E251
$E24F: a9 90     LDA   #$90
$E251: 95 b0     STA   $B0,X
$E253: 4c 71 e2  JMP   $E271
$E256: a9 10     LDA   #$10
$E258: 85 08     STA   $08
$E25A: a0 ff     LDY   #$FF
$E25C: d0 0c     BNE   $E26A
$E25E: a0 f0     LDY   #$F0
$E260: 85 08     STA   $08
$E262: 55 aa     EOR   $AA,X
$E264: 29 0f     AND   #$0F
$E266: f0 02     BEQ   $E26A
$E268: a0 e0     LDY   #$E0
$E26A: 98        TYA
$E26B: 35 aa     AND   $AA,X
$E26D: 05 08     ORA   $08
$E26F: 95 aa     STA   $AA,X
$E271: a6 83     LDX   $83
$E273: 4c 3a e7  JMP   $E73A
$E276: bd 98 05  LDA   $0598,X
$E279: 29 30     AND   #$30
$E27B: 0a        ASL
$E27C: 0a        ASL
$E27D: 85 10     STA   $10
$E27F: a0 04     LDY   #$04
$E281: 20 42 e3  JSR   $E342
$E284: a2 0f     LDX   #$0F
$E286: bd 68 03  LDA   $0368,X
$E289: f0 30     BEQ   $E2BB
$E28B: bd 38 04  LDA   $0438,X
$E28E: c9 01     CMP   #$01
$E290: d0 29     BNE   $E2BB
$E292: a5 40     LDA   $40
$E294: 4a        LSR
$E295: 90 12     BCC   $E2A9
$E297: a4 10     LDY   $10
$E299: 10 07     BPL   $E2A2
$E29B: bd 88 03  LDA   $0388,X
$E29E: 30 09     BMI   $E2A9
$E2A0: 10 19     BPL   $E2BB
$E2A2: bd 18 04  LDA   $0418,X
$E2A5: c9 02     CMP   #$02
$E2A7: b0 12     BCS   $E2BB
$E2A9: bd b8 03  LDA   $03B8,X
$E2AC: e5 08     SBC   $08
$E2AE: c5 0a     CMP   $0A
$E2B0: b0 09     BCS   $E2BB
$E2B2: bd c8 03  LDA   $03C8,X
$E2B5: e5 09     SBC   $09
$E2B7: c5 0b     CMP   $0B
$E2B9: 90 06     BCC   $E2C1
$E2BB: ca        DEX
$E2BC: 10 c8     BPL   $E286
$E2BE: a6 83     LDX   $83
$E2C0: 60        RTS
$E2C1: a4 83     LDY   $83
$E2C3: b9 3e 03  LDA   $033E,Y
$E2C6: 38        SEC
$E2C7: fd c8 03  SBC   $03C8,X
$E2CA: b0 04     BCS   $E2D0
$E2CC: 49 ff     EOR   #$FF
$E2CE: 69 01     ADC   #$01
$E2D0: c9 80     CMP   #$80
$E2D2: b0 e7     BCS   $E2BB
$E2D4: bd 48 04  LDA   $0448,X
$E2D7: 20 09 e3  JSR   $E309
$E2DA: bd 88 03  LDA   $0388,X
$E2DD: c9 05     CMP   #$05
$E2DF: d0 17     BNE   $E2F8
$E2E1: 86 08     STX   $08
$E2E3: 8a        TXA
$E2E4: a2 00     LDX   #$00
$E2E6: c9 0a     CMP   #$0A
$E2E8: 90 02     BCC   $E2EC
$E2EA: a2 0a     LDX   #$0A
$E2EC: bd 38 04  LDA   $0438,X
$E2EF: c9 01     CMP   #$01
$E2F1: f0 05     BEQ   $E2F8
$E2F3: e8        INX
$E2F4: e4 08     CPX   $08
$E2F6: d0 f4     BNE   $E2EC
$E2F8: 20 fe e2  JSR   $E2FE
$E2FB: a6 83     LDX   $83
$E2FD: 60        RTS
$E2FE: a9 02     LDA   #$02
$E300: 9d 38 04  STA   $0438,X
$E303: a9 06     LDA   #$06
$E305: 9d 18 04  STA   $0418,X
$E308: 60        RTS
$E309: 85 17     STA   $17
$E30B: 86 11     STX   $11
$E30D: a4 83     LDY   $83
$E30F: b9 78 05  LDA   $0578,Y
$E312: f0 28     BEQ   $E33C
$E314: c9 f0     CMP   #$F0
$E316: b0 24     BCS   $E33C
$E318: e9 00     SBC   #$00
$E31A: b0 02     BCS   $E31E
$E31C: a9 00     LDA   #$00
$E31E: 99 78 05  STA   $0578,Y
$E321: d0 08     BNE   $E32B
$E323: a6 83     LDX   $83
$E325: 20 a6 e8  JSR   $E8A6
$E328: a6 11     LDX   $11
$E32A: 60        RTS
$E32B: b9 98 05  LDA   $0598,Y
$E32E: 29 04     AND   #$04
$E330: f0 0a     BEQ   $E33C
$E332: b9 48 05  LDA   $0548,Y
$E335: a8        TAY
$E336: b9 3d e3  LDA   $E33D,Y
$E339: 20 bc f9  JSR   $F9BC
$E33C: 60        RTS
$E33D: 2c 2c 2c 2e 2a .byte $2C …
$E342: 86 11     STX   $11
$E344: a6 83     LDX   $83
$E346: 98        TYA
$E347: 0a        ASL
$E348: a8        TAY
$E349: b9 19 e4  LDA   $E419,Y
$E34C: 85 0e     STA   $0E
$E34E: b9 1a e4  LDA   $E41A,Y
$E351: 85 0f     STA   $0F
$E353: bd 88 05  LDA   $0588,X
$E356: 29 0f     AND   #$0F
$E358: c9 0f     CMP   #$0F
$E35A: f0 20     BEQ   $E37C
$E35C: 0a        ASL
$E35D: 0a        ASL
$E35E: a8        TAY
$E35F: bd 24 03  LDA   $0324,X
$E362: 71 0e     ADC   ($0E),Y
$E364: 85 08     STA   $08
$E366: c8        INY
$E367: bd 3e 03  LDA   $033E,X
$E36A: 18        CLC
$E36B: 71 0e     ADC   ($0E),Y
$E36D: 85 09     STA   $09
$E36F: c8        INY
$E370: b1 0e     LDA   ($0E),Y
$E372: 85 0a     STA   $0A
$E374: c8        INY
$E375: b1 0e     LDA   ($0E),Y
$E377: 85 0b     STA   $0B
$E379: a6 11     LDX   $11
$E37B: 60        RTS
$E37C: bd a8 05  LDA   $05A8,X
$E37F: 0a        ASL
$E380: 0a        ASL
$E381: bd b8 05  LDA   $05B8,X
$E384: 90 04     BCC   $E38A
$E386: 49 ff     EOR   #$FF
$E388: 69 00     ADC   #$00
$E38A: 18        CLC
$E38B: 69 08     ADC   #$08
$E38D: 85 0c     STA   $0C
$E38F: 98        TYA
$E390: 0a        ASL
$E391: a8        TAY
$E392: b9 f5 e3  LDA   $E3F5,Y
$E395: 85 08     STA   $08
$E397: b9 f6 e3  LDA   $E3F6,Y
$E39A: 85 09     STA   $09
$E39C: b9 f7 e3  LDA   $E3F7,Y
$E39F: 85 0a     STA   $0A
$E3A1: b9 f8 e3  LDA   $E3F8,Y
$E3A4: 85 0b     STA   $0B
$E3A6: bd a8 05  LDA   $05A8,X
$E3A9: 4a        LSR
$E3AA: 4a        LSR
$E3AB: 4a        LSR
$E3AC: 4a        LSR
$E3AD: 29 0c     AND   #$0C
$E3AF: a8        TAY
$E3B0: b9 09 e4  LDA   $E409,Y
$E3B3: 20 e7 e3  JSR   $E3E7
$E3B6: 18        CLC
$E3B7: 65 08     ADC   $08
$E3B9: 18        CLC
$E3BA: 7d 24 03  ADC   $0324,X
$E3BD: 85 08     STA   $08
$E3BF: b9 0a e4  LDA   $E40A,Y
$E3C2: 20 e7 e3  JSR   $E3E7
$E3C5: 18        CLC
$E3C6: 65 09     ADC   $09
$E3C8: 18        CLC
$E3C9: 7d 3e 03  ADC   $033E,X
$E3CC: 85 09     STA   $09
$E3CE: b9 0b e4  LDA   $E40B,Y
$E3D1: 20 e7 e3  JSR   $E3E7
$E3D4: 18        CLC
$E3D5: 65 0a     ADC   $0A
$E3D7: 85 0a     STA   $0A
$E3D9: b9 0c e4  LDA   $E40C,Y
$E3DC: 20 e7 e3  JSR   $E3E7
$E3DF: 18        CLC
$E3E0: 65 0b     ADC   $0B
$E3E2: 85 0b     STA   $0B
$E3E4: a6 11     LDX   $11
$E3E6: 60        RTS
$E3E7: c9 fe     CMP   #$FE
$E3E9: 90 09     BCC   $E3F4
$E3EB: 4a        LSR
$E3EC: a5 0c     LDA   $0C
$E3EE: b0 04     BCS   $E3F4
$E3F0: 49 ff     EOR   #$FF
$E3F2: 69 01     ADC   #$01
$E3F4: 60        RTS
$E3F5: 00 fb 0a 0a f8 fc 10 08 f4 f5 04 16 f1 fc 1d 08 .byte $00 …
$E405: fe fe 04 04 fa f8 0c ff fa fe 0c ff f8 fa ff 0c .byte $FE …
$E415: fe f6 ff 14 23 e4 5f e4 9b e4 d7 e4 13 e5 f1 f7 .byte $FE …
$E425: 28 12 fe f9 14 14 f8 f3 1a 1a f2 ed 26 26 e0 f0 .byte $28 …
$E435: 08 20 fd f8 10 10 f5 f7 20 12 e7 e2 3c 3c f1 e2 .byte $08 …
$E445: 28 3c e4 d3 48 5a 00 f6 16 16 08 f1 12 1e f5 f1 .byte $28 …
$E455: 20 1e ea ec 37 28 f3 f3 11 1a ea f8 1e 10 f6 fa .byte $20 …
$E465: 0c 0c f1 f5 12 16 ea ee 24 24 e0 f0 08 20 f5 f9 .byte $0C …
$E475: 0e 0e ed f8 1e 10 df e3 3a 3a e9 e3 26 3a dc d4 .byte $0E …
$E485: 46 58 f8 f7 14 14 00 f2 10 1c ed f2 1e 1c e2 ed .byte $46 …
$E495: 35 26 f3 f1 12 1e f4 f1 0d 1e f3 f4 04 18 ec ed .byte $35 …
$E4A5: 10 26 e6 e7 1c 32 e0 f0 08 20 f1 f2 06 1c e9 f1 .byte $10 …
$E4B5: 16 1e db dc 32 48 e5 dc 1e 48 d8 cd 3e 66 f4 f0 .byte $16 …
$E4C5: 19 22 fc eb 08 2a e3 f2 1a 1c de e6 2d 34 e9 ea .byte $19 …
$E4D5: 0d 2c f3 f8 24 10 f0 fb 1f 0a ea f5 2b 16 e3 ee .byte $0D …
$E4E5: 39 24 e0 f0 08 20 ee f9 23 0e e6 f8 33 10 d8 e3 .byte $39 …
$E4F5: 4f 3a e2 e3 3b 3a d5 d4 5b 58 f1 f7 29 14 f9 f2 .byte $4F …
$E505: 25 1c e4 f2 35 1c da ed 4a 26 e6 f1 2a 1e ee f5 .byte $25 …
$E515: 24 16 fc fc 08 08 f6 f5 14 16 ef ef 22 22 e0 f0 .byte $24 …
$E525: 08 20 fa fa 0c 0c f3 fa 16 0c e4 e4 38 38 ee e4 .byte $08 …
$E535: 24 38 e1 d5 44 56 fd f8 12 12 05 f3 0e 1a f3 f3 .byte $24 …
$E545: 1a 1a e7 ee 33 24 f2 f2 13 1c .byte $1A …
$E54F: a9 00     LDA   #$00
$E551: 85 b6     STA   $B6
$E553: 85 b7     STA   $B7
$E555: a2 0f     LDX   #$0F
$E557: bd b8 04  LDA   $04B8,X
$E55A: f0 2a     BEQ   $E586
$E55C: 86 83     STX   $83
$E55E: 0a        ASL
$E55F: 85 04     STA   $04
$E561: 20 8a e5  JSR   $E58A
$E564: bd 0a 03  LDA   $030A,X
$E567: f0 1d     BEQ   $E586
$E569: a5 40     LDA   $40
$E56B: 4a        LSR
$E56C: 90 07     BCC   $E575
$E56E: bd 24 03  LDA   $0324,X
$E571: c9 9c     CMP   #$9C
$E573: 90 09     BCC   $E57E
$E575: bd 98 05  LDA   $0598,X
$E578: 4a        LSR
$E579: b0 03     BCS   $E57E
$E57B: 20 0a e1  JSR   $E10A
$E57E: bd 98 05  LDA   $0598,X
$E581: 30 03     BMI   $E586
$E583: 20 76 e2  JSR   $E276
$E586: ca        DEX
$E587: 10 ce     BPL   $E557
$E589: 60        RTS
$E58A: bd 28 05  LDA   $0528,X
$E58D: 0a        ASL
$E58E: a8        TAY
$E58F: 4a        LSR
$E590: c9 10     CMP   #$10
$E592: b0 18     BCS   $E5AC
$E594: b9 d9 e5  LDA   $E5D9,Y
$E597: 85 02     STA   $02
$E599: b9 da e5  LDA   $E5DA,Y
$E59C: 85 03     STA   $03
$E59E: a4 04     LDY   $04
$E5A0: b1 02     LDA   ($02),Y
$E5A2: 85 04     STA   $04
$E5A4: c8        INY
$E5A5: b1 02     LDA   ($02),Y
$E5A7: 85 05     STA   $05
$E5A9: 6c 04 00  JMP   ($0004)
$E5AC: 98        TYA
$E5AD: e9 20     SBC   #$20
$E5AF: a8        TAY
$E5B0: b1 80     LDA   ($80),Y
$E5B2: 85 02     STA   $02
$E5B4: c8        INY
$E5B5: b1 80     LDA   ($80),Y
$E5B7: 4c 9c e5  JMP   $E59C
$E5BA: a5 30     LDA   $30
$E5BC: 0a        ASL
$E5BD: a8        TAY
$E5BE: b9 c9 e5  LDA   $E5C9,Y
$E5C1: 85 80     STA   $80
$E5C3: b9 ca e5  LDA   $E5CA,Y
$E5C6: 85 81     STA   $81
$E5C8: 60        RTS
$E5C9: f9 e5 ff e5 21 e6 ff e5 2d e6 3b e6 45 e6 57 e6 .byte $F9 …
$E5D9: ff 7f 45 81 03 82 03 83 86 83 15 86 53 89 c5 84 .byte $FF …
$E5E9: 1b ef 63 e6 db ef 28 f1 9f f0 63 e6 21 f0 7d f0 .byte $1B …
$E5F9: 56 8b d6 8b 5f 8c 74 8e 8f 8f d6 8f 99 90 1d 91 .byte $56 …
$E609: c7 92 7d 93 5c 94 33 95 26 8d c4 95 42 8f 0e 9f .byte $C7 …
$E619: 6a a0 62 a1 73 a2 17 a3 fe 97 55 98 70 98 96 98 .byte $6A …
$E629: 31 99 a5 9a 9d a3 c4 a3 27 a4 a6 a9 bd a6 0f a9 .byte $31 …
$E639: 8f a9 bc a9 70 aa bf aa a2 ab 65 ae de ae ed af .byte $8F …
$E649: 1e b1 41 b1 9d b1 fc b1 26 b2 97 b2 51 b3 47 b4 .byte $1E …
$E659: 05 b7 19 b8 8b b8 4e ba da bb a5 bc 67 e6 60 20 .byte $05 …
$E669: 7c e6 a9 00 9d 68 05 60 20 d4 f9 a9 77 20 50 ea .byte $7C …
$E679: 20 49 e9 bd 98 05 09 81 d0 0c a9 0d 9d 88 05 bd .byte $20 …
$E689: 98 05 29 be 09 80 9d 98 05 29 02 f0 05 a9 2f 20 .byte $98 …
$E699: bc f9 bd 58 03 29 fc 09 06 9d 58 03 bd 0a 03 d0 .byte $BC …
$E6A9: 03 4c 3a e7 a9 ff 9d 68 05 a9 01 9d 0a 03 20 47 .byte $03 …
$E6B9: e8 a9 01 9d 38 05 bd b8 04 f0 7b fe b8 04 60 bd .byte $E8 …
$E6C9: b8 04 f0 72 fe b8 04 a9 3d 4c bc f9 a9 03 a0 02 .byte $B8 …
$E6D9: d0 12 a9 02 a0 03 d0 0c bd 98 05 a0 03 29 08 f0 .byte $D0 …
$E6E9: 01 c8 a9 00 84 08 85 09 20 47 e8 bd b8 04 f0 3d .byte $01 …
$E6F9: de 38 05 d0 38 fe 68 05 bc 68 05 c4 08 b0 b7 c8 .byte $DE …
$E709: c4 08 90 03 20 6d ea a9 0a 9d 38 05 a4 09 d0 08 .byte $C4 …
$E719: bd 98 05 29 08 f0 01 c8 98 0a a8 b9 54 e7 85 0a .byte $BD …
$E729: b9 55 e7 85 0b bc 68 05 b1 0a 9d 0a 03 60 20 47 .byte $B9 …
$E739: e8        .byte $E8
$E73A: a9 00     LDA   #$00
$E73C: 9d b8 04  STA   $04B8,X
$E73F: a9 00     LDA   #$00
$E741: 9d 0a 03  STA   $030A,X
$E744: 60        RTS
$E745: 20 3f e7 4c bf e6 bc b8 04 f0 ef 9d b8 04 60 5c .byte $20 …
$E755: e7 5f e7 63 e7 66 e7 38 39 3a 37 35 36 37 9d 9e .byte $E7 …
$E765: 9f 36 37 a5 41 f0 32 bd c8 04 18 7d f8 04 9d c8 .byte $9F …
$E775: 04 bd 24 03 7d e8 04 18 65 68 9d 24 03 c9 e8 b0 .byte $04 …
$E785: 49 bd d8 04 18 7d 18 05 9d d8 04 bd 3e 03 7d 08 .byte $49 …
$E795: 05 9d 3e 03 c9 08 90 32 60 bd d8 04 18 7d 18 05 .byte $05 …
$E7A5: 9d d8 04 bd 3e 03 7d 08 05 38 e5 68 9d 3e 03 c9 .byte $9D …
$E7B5: 08 90 17 bd c8 04 18 7d f8 04 9d c8 04 bd 24 03 .byte $08 …
$E7C5: 7d e8 04 9d 24 03 c9 e8 90 ce 4c 3a e7 a5 41 f0 .byte $7D …
$E7D5: 2d a0 00 bd e8 04 18 65 68 10 01 88 85 00 bd c8 .byte $2D …
$E7E5: 04 18 7d f8 04 9d c8 04 bd 24 03 65 00 9d 24 03 .byte $04 …
$E7F5: 98 7d 68 05 9d 68 05 c9 01 f0 cf 4c 86 e7 bd d8 .byte $98 …
$E805: 04 18 7d 18 05 9d d8 04 bd 3e 03 7d 08 05 38 e5 .byte $04 …
$E815: 68 9d 3e 03 c9 08 90 27 a0 00 bd e8 04 10 01 88 .byte $68 …
$E825: 85 00 bd c8 04 18 7d f8 04 9d c8 04 bd 24 03 65 .byte $85 …
$E835: 00 9d 24 03 98 7d 68 05 9d 68 05 c9 01 d0 14 4c .byte $00 …
$E845: 3a e7 a5 41 f0 0e bd 24 03 18 65 68 9d 24 03 c9 .byte $3A …
$E855: e8 b0 ec 60 bd 3e 03 38 e5 68 9d 3e 03 c9 08 90 .byte $E8 …
$E865: de 60 20 86 e7 4c b8 e7 20 79 e8 a9 00 9d f8 04 .byte $DE …
$E875: 9d e8 04 60 a9 00 9d 18 05 9d 08 05 60 a9 00 38 .byte $9D …
$E885: fd 18 05 9d 18 05 a9 00 fd 08 05 9d 08 05 60 a9 .byte $FD …
$E895: 00 38 fd f8 04 9d f8 04 a9 00 fd e8 04 9d e8 04 .byte $00 …
$E8A5: 60        .byte $60
$E8A6: bd 88 05  LDA   $0588,X
$E8A9: 4a        LSR
$E8AA: 4a        LSR
$E8AB: 4a        LSR
$E8AC: 4a        LSR
$E8AD: a8        TAY
$E8AE: c0 0a     CPY   #$0A
$E8B0: d0 10     BNE   $E8C2
$E8B2: a9 88     LDA   #$88
$E8B4: 85 00     STA   $00
$E8B6: a9 13     LDA   #$13
$E8B8: 85 01     STA   $01
$E8BA: a4 17     LDY   $17
$E8BC: 20 43 c3  JSR   $C343
$E8BF: 4c ce e8  JMP   $E8CE
$E8C2: b9 07 e9  LDA   $E907,Y
$E8C5: f0 07     BEQ   $E8CE
$E8C7: 85 00     STA   $00
$E8C9: a4 17     LDY   $17
$E8CB: 20 3b c3  JSR   $C33B
$E8CE: a6 83     LDX   $83
$E8D0: bd 88 05  LDA   $0588,X
$E8D3: 29 0f     AND   #$0F
$E8D5: 9d 88 05  STA   $0588,X
$E8D8: bd 28 05  LDA   $0528,X
$E8DB: c9 10     CMP   #$10
$E8DD: a0 10     LDY   #$10
$E8DF: 90 04     BCC   $E8E5
$E8E1: a5 30     LDA   $30
$E8E3: 0a        ASL
$E8E4: a8        TAY
$E8E5: b9 11 e9  LDA   $E911,Y
$E8E8: 85 08     STA   $08
$E8EA: b9 12 e9  LDA   $E912,Y
$E8ED: 85 09     STA   $09
$E8EF: bd 28 05  LDA   $0528,X
$E8F2: 4a        LSR
$E8F3: a8        TAY
$E8F4: b1 08     LDA   ($08),Y
$E8F6: b0 04     BCS   $E8FC
$E8F8: 4a        LSR
$E8F9: 4a        LSR
$E8FA: 4a        LSR
$E8FB: 4a        LSR
$E8FC: 29 0f     AND   #$0F
$E8FE: dd b8 04  CMP   $04B8,X
$E901: 90 03     BCC   $E906
$E903: 9d b8 04  STA   $04B8,X
$E906: 60        RTS
$E907: 00 01 03 05 0a 14 1e 32 64 96 23 e9 25 e9 2e e9 .byte $00 …
$E917: 25 e9 31 e9 35 e9 38 e9 3d e9 23 e9 04 53 75 56 .byte $25 …
$E927: 50 44 44 43 33 20 43 45 53 33 43 33 43 54 30 22 .byte $50 …
$E937: 24 65 33 50 a5 20 00 07 30 05 30 44 35 50 43 34 .byte $24 …
$E947: 63 40     .byte $63 …
$E949: 86 10     STX   $10
$E94B: a2 0f     LDX   #$0F
$E94D: bd b8 04  LDA   $04B8,X
$E950: f0 24     BEQ   $E976
$E952: bd 0a 03  LDA   $030A,X
$E955: f0 1f     BEQ   $E976
$E957: bd 28 05  LDA   $0528,X
$E95A: c9 02     CMP   #$02
$E95C: f0 18     BEQ   $E976
$E95E: c9 03     CMP   #$03
$E960: f0 14     BEQ   $E976
$E962: bd 78 05  LDA   $0578,X
$E965: f0 0f     BEQ   $E976
$E967: c9 f0     CMP   #$F0
$E969: f0 0b     BEQ   $E976
$E96B: 20 d8 e8  JSR   $E8D8
$E96E: bd a8 05  LDA   $05A8,X
$E971: 09 80     ORA   #$80
$E973: 9d a8 05  STA   $05A8,X
$E976: ca        DEX
$E977: 10 d4     BPL   $E94D
$E979: a6 10     LDX   $10
$E97B: 60        RTS
$E97C: 86 10 a2 0f 20 3a e7 ca 10 fa a6 10 60 a9 00 a8 .byte $86 …
$E98C: 85 11 84 14 a5 12 4a 29 03 85 00 a5 13 29 07 06 .byte $85 …
$E99C: 12 2a 06 12 2a 06 12 06 12 2a 06 12 2a 85 04 a9 .byte $12 …
$E9AC: 02 85 01 a5 00 85 02 20 ca e9 46 11 46 11 46 14 .byte $02 …
$E9BC: 46 14 a5 04 18 69 04 85 04 c6 01 d0 e6 60 a5 04 .byte $46 …
$E9CC: 85 07 a9 01 85 06 a4 02 b9 0d ea 85 05 a5 06 4a .byte $85 …
$E9DC: a5 11 b0 02 a5 14 29 03 c8 c0 04 b0 05 0a 0a 4c .byte $A5 …
$E9EC: e4 e9 85 03 a4 07 b9 80 06 25 05 05 03 99 80 06 .byte $E4 …
$E9FC: e6 02 a5 02 29 03 85 02 d0 02 e6 07 c6 06 10 c6 .byte $E6 …
$EA0C: 60 3f cf f3 fc a9 89 85 0a a9 09 d0 0a a9 89 d0 .byte $60 …
$EA1C: 02 a9 08 85 0a a9 06 85 0b 86 10 20 34 ed d0 21 .byte $02 …
$EA2C: a9 02 9d 28 05 20 ad ed a5 0b 9d b8 04 a9 01 9d .byte $A9 …
$EA3C: 0a 03 a5 0a 9d 98 05 a5 08 9d 24 03 a5 09 9d 3e .byte $0A …
$EA4C: 03 a6 10 60 20 bc f9 a9 ff 85 2a a9 01 85 3b 60 .byte $03 …
$EA5C: 85 2a a9 00 85 2b 4c 3a e7 a9 01 d0 06 a9 80 d0 .byte $85 …
$EA6C: 02 a9 81 1d 98 05 d0 0d a9 fe d0 06 a9 7f d0 02 .byte $02 …
$EA7C: a9 7e 3d 98 05 9d 98 05 60 18 7d 24 03 9d 24 03 .byte $A9 …
$EA8C: 60 18 7d 3e 03 9d 3e 03 60 a9 00 a8 18 7d 3e 03 .byte $60 …
$EA9C: 85 09 98 18 7d 24 03 85 08 60 a9 10 18 7d f8 04 .byte $85 …
$EAAC: 9d f8 04 bd e8 04 69 00 9d e8 04 60 85 0a a9 00 .byte $9D …
$EABC: a8 84 08 85 09 8a a8 20 34 ed d0 21 a5 0a 9d 28 .byte $A8 …
$EACC: 05 20 ad ed b9 24 03 18 65 08 9d 24 03 b9 3e 03 .byte $05 …
$EADC: 18 65 09 9d 3e 03 8a a8 a6 83 a9 00 60 a6 83 a9 .byte $18 …
$EAEC: 01 60 a9 04 85 01 a5 fc 29 0f 09 f0 85 00 18 7d .byte $01 …
$EAFC: 24 03 29 f0 38 e5 00 18 65 01 9d 24 03 60 20 6e .byte $24 …
$EB0C: eb 4c 13 eb 20 1b eb 90 05 a9 01 9d 38 05 60 85 .byte $EB …
$EB1C: 10 bd 24 03 38 e9 0c 90 64 a8 bd 3e 03 38 e9 0c .byte $10 …
$EB2C: 90 5b 20 e4 f9 a6 83 60 84 07 48 20 1d eb 68 b0 .byte $90 …
$EB3C: 30 85 10 a5 07 d0 07 a9 00 a0 0f 20 8c e9 bd 24 .byte $30 …
$EB4C: 03 18 69 14 b0 37 a8 bd 3e 03 38 e9 0c 90 2e 20 .byte $03 …
$EB5C: e4 f9 b0 0b a5 07 d0 07 a9 01 a0 01 20 8c e9 a6 .byte $E4 …
$EB6C: 83 60 09 80 85 10 bd 24 03 38 e9 04 90 0f a8 bd .byte $83 …
$EB7C: 3e 03 38 e9 04 90 06 20 f7 f9 a6 83 60 18 a6 83 .byte $3E …
$EB8C: 60 a0 00 a9 00 20 9b eb 4c bb df a0 00 a9 00 18 .byte $60 …
$EB9C: 7d 3e 03 85 13 98 18 7d 24 03 b0 04 a8 4c ee df .byte $7D …
$EBAC: a9 00 60 a0 00 bd 24 03 85 01 bd b8 05 85 03 bd .byte $A9 …
$EBBC: e8 04 85 04 bd f8 04 85 05 20 f9 eb a5 00 9d e8 .byte $E8 …
$EBCC: 04 a5 01 9d f8 04 60 a0 00 bd 3e 03 85 01 bd c8 .byte $04 …
$EBDC: 05 85 03 bd 08 05 85 04 bd 18 05 85 05 20 f9 eb .byte $05 …
$EBEC: a5 00 9d 08 05 a5 01 9d 18 05 60 a0 00 a5 01 38 .byte $A5 …
$EBFC: e5 03 85 01 a9 00 e9 00 85 00 85 07 98 f0 14 30 .byte $E5 …
$EC0C: 09 06 01 26 00 88 d0 f9 f0 09 46 07 66 00 66 01 .byte $09 …
$EC1C: c8 d0 f7 a5 05 38 e5 01 85 01 a5 04 e5 00 85 00 .byte $C8 …
$EC2C: 60 20 5b ec 98 49 01 85 0c a5 08 85 0a a5 09 85 .byte $60 …
$EC3C: 0b 20 74 ec 98 49 01 c5 0c d0 03 98 85 0c aa a8 .byte $0B …
$EC4C: b5 08 a6 0c d5 0a 90 04 a4 0c b5 0a a6 83 60 ad .byte $B5 …
$EC5C: 34 03 38 fd 3e 03 b0 04 49 ff 69 01 85 08 ad 35 .byte $34 …
$EC6C: 03 38 fd 3e 03 4c 8a ec ad 1a 03 38 fd 24 03 b0 .byte $03 …
$EC7C: 04 49 ff 69 01 85 08 ad 1b 03 38 fd 24 03 b0 04 .byte $04 …
$EC8C: 49 ff 69 01 85 09 a0 fe a5 90 c9 01 f0 02 84 08 .byte $49 …
$EC9C: a0 ff a5 91 c9 01 f0 02 84 09 a5 09 a0 01 c5 08 .byte $A0 …
$ECAC: 90 03 88 a5 08 60 a5 09 a0 06 d9 c5 ec 90 08 88 .byte $90 …
$ECBC: 30 02 b0 f6 a9 00 60 98 60 ff 94 8c 84 7c 74 6c .byte $30 …
$ECCC: bd c8 05 18 7d e8 05 9d c8 05 bd d8 05 7d 58 05 .byte $BD …
$ECDC: 9d d8 05 bd c8 04 18 7d f8 04 9d c8 04 bd b8 05 .byte $9D …
$ECEC: 7d e8 04 9d b8 05 c9 f0 b0 0a 18 7d d8 05 9d 24 .byte $7D …
$ECFC: 03 4c 86 e7 4c 3a e7 bd 3e 03 20 b4 ec 0a a8 b9 .byte $03 …
$ED0C: 22 ed 9d 18 05 b9 23 ed 9d 08 05 a9 00 9d f8 04 .byte $22 …
$ED1C: a9 01 9d e8 04 60 aa 00 71 00 38 00 00 00 c8 ff .byte $A9 …
$ED2C: 8f ff 56 ff a2 06 d0 02 a2 0f bd b8 04 f0 03 ca .byte $8F …
$ED3C: 10 f8 60 a2 0f bd 28 05 c9 01 f0 f6 ca 10 f6 a2 .byte $10 …
$ED4C: 00 60 a2 0f 20 62 ed ca 10 fa 60 a9 00 9d 0a 03 .byte $00 …
$ED5C: f0 21 a9 00 f0 3e a9 00 9d b8 04 9d 78 05 9d 28 .byte $F0 …
$ED6C: 05 9d 0a 03 9d a8 05 9d 24 03 9d 3e 03 9d c8 04 .byte $05 …
$ED7C: 9d d8 04 9d 58 03 9d f8 04 9d 18 05 9d e8 04 9d .byte $9D …
$ED8C: 08 05 9d 38 05 9d 48 05 9d 58 05 9d 68 05 9d 98 .byte $08 …
$ED9C: 05 9d 88 05 9d b8 05 9d c8 05 9d d8 05 9d e8 05 .byte $05 …
$EDAC: 60 a9 01 9d b8 04 9d 0a 03 a9 00 20 70 ed 98 48 .byte $60 …
$EDBC: bd 28 05 c9 10 a0 10 90 04 a5 30 0a a8 b9 f3 ed .byte $BD …
$EDCC: 85 8c b9 f4 ed 85 8d bd 28 05 0a 0a a8 b1 8c 9d .byte $85 …
$EDDC: 98 05 c8 b1 8c 9d 88 05 c8 b1 8c 9d 78 05 c8 b1 .byte $98 …
$EDEC: 8c 9d 48 05 68 a8 60 05 ee 11 ee 55 ee 11 ee 6d .byte $8C …
$EDFC: ee 89 ee 9d ee c1 ee 05 ee 82 22 01 00 80 00 01 .byte $EE …
$EE0C: 00 0f 32 f0 00 0b 32 01 00 8f 22 08 00 83 10 01 .byte $00 …
$EE1C: 00 83 30 01 00 8f 30 08 00 0f 52 f1 00 00 00 01 .byte $00 …
$EE2C: 00 0f 42 f0 00 8a 05 01 00 83 42 01 00 00 00 01 .byte $00 …
$EE3C: 00 0e 33 0a 00 80 01 01 00 0f 42 10 00 0c 82 20 .byte $00 …
$EE4C: 00 89 00 01 00 8d 02 01 00 2f 22 05 00 81 03 01 .byte $00 …
$EE5C: 00 9f 35 04 00 9f 05 01 00 13 16 01 00 13 16 01 .byte $00 …
$EE6C: 00 13 36 01 00 13 16 01 00 89 00 f1 00 81 00 f1 .byte $00 …
$EE7C: 00 8f 13 02 01 8f 02 01 00 0a 15 01 00 03 30 01 .byte $00 …
$EE8C: 00 03 30 01 00 81 00 f1 00 c0 04 f0 00 80 02 f0 .byte $00 …
$EE9C: 00 81 00 f0 00 8f 31 05 00 8d 83 f1 02 0e 52 f1 .byte $00 …
$EEAC: 00 81 00 f0 00 81 02 f1 00 85 79 f0 00 81 00 f0 .byte $00 …
$EEBC: 00 8d 93 20 00 02 20 01 00 0a 12 01 00 81 0f f0 .byte $00 …
$EECC: 00 81 0f f0 00 81 0f f0 00 04 9d 01 02 80 05 01 .byte $00 …
$EEDC: 00 80 0a f0 00 8d 0f 10 00 0c 0f 10 00 81 00 f0 .byte $00 …
$EEEC: 00 6e 0c 03 00 6e 0c 03 00 0c 93 20 00 8f 72 08 .byte $00 …
$EEFC: 00 89 00 01 00 04 78 01 02 06 22 01 01 06 42 01 .byte $00 …
$EF0C: 01 02 22 01 00 06 33 01 01 06 62 10 01 04 a7 01 .byte $01 …
$EF1C: 03 2d ef 3a ef 6d ef ae ef d3 ef 7c e6 e1 e6 37 .byte $03 …
$EF2C: e7 a9 08 9d b8 05 a9 50 9d 38 05 4c bf e6 a5 8e .byte $E7 …
$EF3C: f0 14 de 38 05 d0 0f 20 62 ef b0 0a bd 68 05 c9 .byte $F0 …
$EF4C: 02 b0 04 fe 68 05 60 bd b8 05 9d 78 05 a9 04 9d .byte $02 …
$EF5C: 58 05 a9 40 d0 d2 a9 06 9d 38 05 bd 68 05 4c 10 .byte $58 …
$EF6C: eb bd 58 05 f0 21 de 58 05 d0 1c a9 02 85 16 a4 .byte $EB …
$EF7C: 16 b9 a8 ef a0 08 20 98 ea a4 16 b9 ab ef a0 07 .byte $16 …
$EF8C: 20 25 f2 c6 16 10 e8 de 38 05 d0 ba bd 78 05 9d .byte $20 …
$EF9C: b8 05 a9 f1 9d 78 05 a9 06 4c 34 ef f8 00 08 48 .byte $B8 …
$EFAC: 46 44 de 38 05 d0 9f 20 62 ef b0 08 bd 68 05 f0 .byte $46 …
$EFBC: 04 de 68 05 60 a5 2f c9 02 a9 c0 90 02 a9 60 9d .byte $04 …
$EFCC: 38 05 a9 02 4c 4b e7 a9 05 20 1b eb b0 e6 4c bf .byte $38 …
$EFDC: e6 eb ef f0 ef 16 f0 17 f0 7c e6 e1 e6 37 e7 a9 .byte $E6 …
$EFEC: 80 4c 34 ef de 38 05 d0 21 a9 04 9d 38 05 bd 68 .byte $80 …
$EFFC: 05 18 69 03 20 10 eb b0 11 fe 68 05 bd 68 05 c9 .byte $05 …
$F00C: 02 90 07 a9 0a 9d 78 05 b0 0a 60 a9 05 20 1b eb .byte $02 …
$F01C: b0 f8 e6 87 4c bf e6 2f f0 41 f0 52 f0 7c e6 e1 .byte $B0 …
$F02C: e6 37 e7 a9 bd 9d 0a 03 bd a8 05 0a 0a 0a 0a 18 .byte $E6 …
$F03C: 69 01 4c 34 ef 20 47 e8 de 38 05 d0 08 fe 0a 03 .byte $69 …
$F04C: a9 05 4c 34 ef 60 20 47 e8 de 38 05 d0 f7 a9 1c .byte $A9 …
$F05C: 20 bc f9 a9 0f 85 0a a9 f0 a0 fc 20 bd ea bd a8 .byte $20 …
$F06C: 05 0a 0a 0a 0a 18 69 30 9d 38 05 de 0a 03 a9 02 .byte $05 …
$F07C: 4c 4b e7 85 f0 97 f0 3a e7 a9 fd 9d 08 05 a9 80 .byte $4C …
$F08C: 9d 18 05 a9 1f 9d 0a 03 4c bf e6 bd 3e 03 c9 f0 .byte $9D …
$F09C: b0 f6 4c 68 e7 ad f0 b2 f0 e9 f0 7c e6 e1 e6 37 .byte $B0 …
$F0AC: e7 a9 80 4c 34 ef a9 4b 9d 0a 03 bd 38 05 0a 0a .byte $E7 …
$F0BC: 0a 0a a9 08 90 02 a9 00 9d 58 03 20 47 e8 de 38 .byte $0A …
$F0CC: 05 d0 0c bd 24 03 c9 b8 b0 06 a9 10 9d 38 05 60 .byte $05 …
$F0DC: 20 7c ea a9 10 9d 58 05 a9 30 4c 34 ef a9 4c 9d .byte $20 …
$F0EC: 0a 03 a9 00 bc b8 05 f0 05 de b8 05 a9 08 9d 58 .byte $0A …
$F0FC: 03 de 38 05 f0 18 de 58 05 d0 10 a9 07 9d b8 05 .byte $03 …
$F10C: a9 0b 85 0a a0 e8 a9 05 20 bd ea 4c 47 e8 20 47 .byte $A9 …
$F11C: e8 a9 c0 9d 38 05 20 6d ea a9 02 4c 4b e7 3c f1 .byte $E8 …
$F12C: 9d f1 d4 f1 7c e6 e1 e6 37 e7 83 e6 e1 e6 37 e7 .byte $9D …
$F13C: a9 8a bc a8 05 f0 02 a9 80 9d 98 05 a9 20 9d 0a .byte $A9 …
$F14C: 03 a9 06 9d 58 03 bd a8 05 d0 08 bd b8 05 f0 03 .byte $03 …
$F15C: 18 69 03 0a 0a a8 b9 7d f1 9d f8 04 b9 7e f1 9d .byte $18 …
$F16C: e8 04 b9 7f f1 9d 18 05 b9 80 f1 9d 08 05 4c bf .byte $E8 …
$F17C: e6 00 fb 00 00 00 fe 00 00 40 fe 90 00 40 fe 70 .byte $E6 …
$F18C: ff 00 fb c0 ff 00 fb 80 ff 00 fb 40 ff 00 fb 00 .byte $FF …
$F19C: ff 20 a6 ea 20 68 e7 bd a8 05 d0 0d bd e8 04 10 .byte $FF …
$F1AC: cd bd 24 03 c9 30 90 c6 60 bd e8 04 30 fa 20 5b .byte $CD …
$F1BC: ec bd 24 03 d9 1a 03 90 ef 20 97 eb f0 ea a9 3d .byte $EC …
$F1CC: 20 bc f9 a9 07 4c 4b e7 20 68 e7 a9 03 85 08 8a .byte $20 …
$F1DC: a8 20 34 ed d0 1d a9 0b 9d 28 05 20 ad ed b9 3e .byte $A8 …
$F1EC: 03 9d 3e 03 b9 24 03 9d 24 03 a5 08 9d a8 05 c6 .byte $03 …
$F1FC: 08 d0 de a6 83 4c bf e6 84 06 85 00 a9 01 85 0f .byte $08 …
$F20C: a5 0a 10 0a a5 0c 85 0a 20 c4 f4 4c 1d f2 20 92 .byte $A5 …
$F21C: f4 05 00 85 0a 4c 3e f2 0a 84 06 85 0a 29 1f a0 .byte $F4 …
$F22C: 00 c9 07 90 06 c9 12 b0 02 a0 02 c9 0d 90 01 c8 .byte $00 …
$F23C: 84 07 a5 0a 29 e0 c9 20 f0 04 a5 8e f0 4b 20 34 .byte $84 …
$F24C: ed d0 46 a9 01 9d 28 05 20 ad ed a5 0a 4a 4a 4a .byte $ED …
$F25C: 4a 4a 9d b8 05 a5 06 c9 07 90 02 a9 07 85 06 a5 .byte $4A …
$F26C: 08 9d 24 03 a5 09 9d 3e 03 a5 0a 29 1f 20 9a f2 .byte $08 …
$F27C: a5 05 9d e8 04 a5 04 9d f8 04 a5 0b 9d 08 05 a5 .byte $A5 …
$F28C: 0a 9d 18 05 a6 83 a9 00 60 a6 83 a9 01 60 a8 b9 .byte $0A …
$F29C: e5 f2 a8 b9 fe f2 85 04 a9 00 85 05 20 0b f3 a5 .byte $E5 …
$F2AC: 04 85 0a a5 05 85 0b b9 fd f2 85 04 a9 00 85 05 .byte $04 …
$F2BC: 20 0b f3 a5 07 4a 90 0d a9 00 38 e5 04 85 04 a9 .byte $20 …
$F2CC: 00 e5 05 85 05 a5 07 4a 4a 90 0d a9 00 38 e5 0a .byte $00 …
$F2DC: 85 0a a9 00 e5 0b 85 0b 60 00 02 04 06 08 0a 0c .byte $85 …
$F2EC: 0a 08 06 04 02 00 02 04 06 08 0a 0c 0a 08 06 04 .byte $0A …
$F2FC: 02 00 ff 42 f7 80 dd b5 b5 dd 80 f7 42 ff 00 a5 .byte $02 …
$F30C: 06 29 07 20 f2 c6 24 f3 29 f3 4a f3 30 f3 39 f3 .byte $06 …
$F31C: 4b f3 56 f3 65 f3 7b f3 46 05 66 04 60 46 05 66 .byte $4B …
$F32C: 04 4c 39 f3 a5 05 4a a5 04 6a 4a 10 06 a5 05 4a .byte $04 …
$F33C: a5 04 6a 18 65 04 85 04 a5 05 69 00 85 05 60 a5 .byte $A5 …
$F34C: 05 4a a5 04 6a 85 00 4a 10 08 a5 05 4a a5 04 6a .byte $05 …
$F35C: 85 00 4a 18 65 00 4c 3f f3 a5 05 4a a5 04 6a 85 .byte $85 …
$F36C: 00 4a 85 01 18 65 00 46 01 18 65 01 4c 3f f3 06 .byte $00 …
$F37C: 04 26 05 60 20 b7 f3 4c 89 f3 20 b3 f3 30 26 d0 .byte $04 …
$F38C: 0e fe b8 05 bd b8 05 c5 06 90 11 a9 00 f0 0a de .byte $0E …
$F39C: b8 05 10 08 a5 06 38 e9 01 9d b8 05 bd b8 05 c5 .byte $B8 …
$F3AC: 0c f0 02 18 60 38 60 a9 00 f0 02 a9 01 85 0f a5 .byte $0C …
$F3BC: 0a 10 0a a5 0c 85 0a 20 c4 f4 4c cc f3 20 92 f4 .byte $0A …
$F3CC: 85 0c a5 0f 4a a9 06 a0 0c 90 04 a9 0c a0 18 85 .byte $85 …
$F3DC: 05 84 06 a5 07 29 02 f0 07 a5 05 38 e5 0c 85 0c .byte $05 …
$F3EC: 46 07 90 0d a5 06 38 e5 0c c5 06 90 02 a9 00 85 .byte $46 …
$F3FC: 0c a9 00 85 0e bd b8 05 18 65 05 c5 06 90 04 e6 .byte $0C …
$F40C: 0e e5 06 85 0d a5 0c dd b8 05 f0 17 a4 0e d0 0a .byte $0E …
$F41C: 90 0e c5 0d b0 0a a9 00 f0 08 b0 fa c5 0d 90 f6 .byte $90 …
$F42C: a9 01 60 a9 80 d0 fb 20 95 ea a9 02 85 0f 20 92 .byte $A9 …
$F43C: f4 85 0c bc d8 05 a5 07 4a 4a 90 07 a9 20 38 e5 .byte $F4 …
$F44C: 0c 85 0c 46 07 90 09 a9 40 38 e5 0c 29 3f 85 0c .byte $0C …
$F45C: a9 00 85 0e b9 08 05 18 69 20 c9 40 90 04 e6 0e .byte $A9 …
$F46C: e9 40 85 0d a5 0c d9 08 05 f0 17 a4 0e d0 0a 90 .byte $E9 …
$F47C: 0e c5 0d b0 0a a9 00 f0 08 b0 fa c5 0d 90 f6 a9 .byte $0E …
$F48C: 01 60 a9 80 d0 fb a5 0a 29 01 a8 b9 90 00 c9 01 .byte $01 …
$F49C: f0 15 98 49 01 a8 b9 90 00 c9 01 f0 0a a9 ff 85 .byte $F0 …
$F4AC: 0a a9 80 85 0b d0 11 a5 40 4a a9 b0 b0 03 b9 1a .byte $0A …
$F4BC: 03 85 0a b9 34 03 85 0b a0 00 a5 0a 38 e5 08 b0 .byte $03 …
$F4CC: 05 49 ff 69 01 c8 4a 4a 4a 4a 4a 85 0a a5 0b 38 .byte $05 …
$F4DC: e5 09 b0 06 49 ff 69 01 c8 c8 4a 4a 4a 4a 4a 84 .byte $E5 …
$F4EC: 07 4a 85 0b 08 a5 0f 0a a8 b9 12 f5 85 0c b9 13 .byte $07 …
$F4FC: f5 85 0d a5 0a 0a 0a 65 0b a8 b1 0c 28 b0 04 4a .byte $F5 …
$F50C: 4a 4a 4a 29 0f 60 18 f5 38 f5 58 f5 00 00 00 00 .byte $4A …
$F51C: 32 11 00 00 32 11 11 11 32 22 11 11 33 22 11 11 .byte $32 …
$F52C: 33 22 22 11 33 22 22 11 33 22 22 22 00 00 00 00 .byte $33 …
$F53C: 63 21 11 11 64 32 21 11 65 43 22 22 65 44 33 22 .byte $63 …
$F54C: 65 54 33 32 65 54 43 33 65 54 44 33 80 00 00 00 .byte $65 …
$F55C: f8 53 32 21 fb 86 54 33 fd a8 75 54 fe b9 87 65 .byte $F8 …
$F56C: fe cb 98 76 fe db a9 87 ff dc ba 98 14 f6 14 f6 .byte $FE …
$F57C: 2c fb 06 f6 c6 f5 c6 f5 66 f6 40 b8 80 b9 80 b8 .byte $2C …
$F58C: c0 b8 00 b9 40 b9 40 b9 80 b9 c0 b9 00 ba 40 ba .byte $C0 …
$F59C: 60 ba 80 ba a0 ba c0 ba e0 ba 00 bb 20 bb e1 f6 .byte $60 …
$F5AC: f2 f6 03 f7 14 f7 25 f7 36 f7 47 f7 58 f7 69 f7 .byte $F2 …
$F5BC: 7a f7 8b f7 a0 f7 e4 f7 f6 f7 20 e3 0b 1c 0f 0b .byte $7A …
$F5CC: 00 00 00 29 fe 22 2a 11 0b 17 0f 00 19 20 0f 1c .byte $00 …
$F5DC: fe 20 a1 11 0b 17 0f 00 19 20 0f 1c fe 20 b6 11 .byte $FE …
$F5EC: 0b 17 0f 00 19 20 0f 1c fe 22 8c 0d 19 18 1e 13 .byte $0B …
$F5FC: 18 1f 0f fd 22 cc 0f 18 0e fe 22 8a 50 4c 41 59 .byte $18 …
$F60C: 00 53 45 4c 45 43 54 fe 22 47 68 69 6c 6d 5c 5d .byte $00 …
$F61C: 6e 6f fd 22 67 78 79 7c 7d 5e 5f 7e 7f 00 fe 20 .byte $6E …
$F62C: a1 1c 0f 1d 1e 00 00 00 fe 20 b8 1c 0f 1d 1e 00 .byte $A1 …
$F63C: 00 00 fe 20 ab 12 13 00 00 00 00 00 00 00 00 fe .byte $00 …
$F64C: 20 61 02 1a 00 00 00 00 00 00 00 00 fe 20 75 03 .byte $20 …
$F65C: 1a 00 00 00 00 00 00 00 00 fe 3f 00 0f 30 28 16 .byte $1A …
$F66C: 0f 30 06 16 0f 10 28 16 0f 30 36 26 0f 30 10 00 .byte $0F …
$F67C: 0f 30 38 28 0f 2c 1c 0c 0f 00 00 00 fe 20 ec 14 .byte $0F …
$F68C: 1f 18 11 16 0f fe 20 ec 0c 0b 1d 0f 02 fe 20 ec .byte $1F …
$F69C: 21 0b 1e 0f 1c 10 0b 16 16 fe 20 ec 0c 0b 1d 0f .byte $21 …
$F6AC: 03 fe 20 ec 1d 18 19 21 00 10 13 0f 16 0e fe 20 .byte $03 …
$F6BC: ec 0f 18 0f 1c 11 23 00 24 19 18 0f fe 20 ec 12 .byte $EC …
$F6CC: 0b 18 11 0b 1c fe 20 ec 0b 16 13 0f 18 27 1d 00 .byte $0B …
$F6DC: 16 0b 13 1c fe 21 42 a2 ae ae a5 ae ae ae ae aa .byte $16 …
$F6EC: ab ae a5 ae af fe 21 62 e2 b3 b4 b5 b6 b7 bc b7 .byte $AB …
$F6FC: be be bc e5 be bf fe 21 82 c2 a7 c4 c5 c6 c7 c8 .byte $BE …
$F70C: c9 ca cb cc cd ca cf fe 21 a2 e2 d3 d4 d5 d6 d7 .byte $C9 …
$F71C: d8 d9 da db dc dd de bf fe 21 c2 e2 be be bd e6 .byte $D8 …
$F72C: e7 e8 e9 ea eb ec ed ee bf fe 21 e2 c2 be be e5 .byte $E7 …
$F73C: be f7 ea f9 ef f8 ce c3 be bf fe 22 02 d2 f5 f6 .byte $BE …
$F74C: e5 be a6 a0 a1 c0 c1 be e1 e0 bf fe 22 22 b2 fa .byte $E5 …
$F75C: fa e3 e4 a7 b0 b1 d0 d1 f0 f1 a8 cf fe 22 42 d2 .byte $FA …
$F76C: f3 f3 f4 f5 f6 b8 b9 ba b9 bb bd be bf fe 22 62 .byte $F3 …
$F77C: f2 a3 a3 a4 a9 a9 ad ac ac ac ac ad ac df fe 23 .byte $F2 …
$F78C: d0 a0 a0 a0 f0 fd 23 d8 8a a0 7d dd fd 23 e0 98 .byte $D0 …
$F79C: aa f7 f9 fe 22 1e 7c 7d fd 22 3e 7d 7c fd 22 5e .byte $AA …
$F7AC: 7c 7d fd 22 7e 7d 7c fd 22 9e 7c 7d fd 22 be 7d .byte $7C …
$F7BC: 7c fd 22 de 5b 5b fd 22 fc 56 57 62 62 fd 26 c0 .byte $7C …
$F7CC: 61 61 5b 5b fd 26 e0 67 67 62 62 fd 23 e7 98 fd .byte $61 …
$F7DC: 23 ef 99 fd 27 e8 a5 fe 26 c4 64 65 64 65 64 65 .byte $23 …
$F7EC: fd 26 e4 78 78 78 78 78 78 fe 26 ca 75 74 75 74 .byte $FD …
$F7FC: 75 74 fd 26 ea 74 75 74 75 74 75 fd 27 ea 95 a5 .byte $75 …
$F80C: fe        .byte $FE
$F80D: d8        CLD
$F80E: 78        SEI
$F80F: ad 02 20  LDA   $2002
$F812: 10 fb     BPL   $F80F
$F814: ad 02 20  LDA   $2002
$F817: 10 fb     BPL   $F814
$F819: a9 00     LDA   #$00
$F81B: 85 18     STA   $18
$F81D: 20 46 f9  JSR   $F946
$F820: a2 ff     LDX   #$FF
$F822: 9a        TXS
$F823: a9 01     LDA   #$01
$F825: a2 01     LDX   #$01
$F827: a0 bf     LDY   #$BF
$F829: 20 55 f9  JSR   $F955
$F82C: a9 07     LDA   #$07
$F82E: a2 05     LDX   #$05
$F830: a0 df     LDY   #$DF
$F832: 20 55 f9  JSR   $F955
$F835: a2 f8     LDX   #$F8
$F837: 8a        TXA
$F838: dd 00 07  CMP   $0700,X
$F83B: d0 05     BNE   $F842
$F83D: e8        INX
$F83E: d0 f7     BNE   $F837
$F840: f0 13     BEQ   $F855
$F842: a2 f8     LDX   #$F8
$F844: 8a        TXA
$F845: 9d 00 07  STA   $0700,X
$F848: e8        INX
$F849: d0 f9     BNE   $F844
$F84B: a9 c8     LDA   #$C8
$F84D: 8d e0 07  STA   $07E0
$F850: a9 00     LDA   #$00
$F852: 8d e1 07  STA   $07E1
$F855: a9 00     LDA   #$00
$F857: 8d 00 07  STA   $0700
$F85A: 20 0b f9  JSR   $F90B
$F85D: 20 d4 f9  JSR   $F9D4
$F860: 20 16 f9  JSR   $F916
$F863: a0 03     LDY   #$03
$F865: 98        TYA
$F866: 29 01     AND   #$01
$F868: 8d e9 07  STA   $07E9
$F86B: 8d 00 e0  STA   $E000
$F86E: a9 00     LDA   #$00
$F870: 8d 01 a0  STA   $A001
$F873: 4e e9 07  LSR   $07E9
$F876: d0 05     BNE   $F87D
$F878: 88        DEY
$F879: 10 ea     BPL   $F865
$F87B: 30 03     BMI   $F880
$F87D: 4c 00 00  JMP   $0000
$F880: a5 1a     LDA   $1A
$F882: 65 34     ADC   $34
$F884: 85 34     STA   $34
$F886: 4c 80 f8  JMP   $F880
$F889: 08        PHP
$F88A: 48        PHA
$F88B: 8a        TXA
$F88C: 48        PHA
$F88D: 98        TYA
$F88E: 48        PHA
$F88F: ad 02 20  LDA   $2002
$F892: a4 1b     LDY   $1B
$F894: d0 4c     BNE   $F8E2
$F896: 20 46 f9  JSR   $F946
$F899: 8d 03 20  STA   $2003
$F89C: a0 02     LDY   #$02
$F89E: 8c 14 40  STY   $4014
$F8A1: 20 02 cc  JSR   $CC02
$F8A4: 20 30 cb  JSR   $CB30
$F8A7: a5 fe     LDA   $FE
$F8A9: a6 20     LDX   $20
$F8AB: f0 06     BEQ   $F8B3
$F8AD: c6 20     DEC   $20
$F8AF: f0 02     BEQ   $F8B3
$F8B1: a9 00     LDA   #$00
$F8B3: 8d 01 20  STA   $2001
$F8B6: 20 26 f9  JSR   $F926
$F8B9: 20 ce fa  JSR   $FACE
$F8BC: e6 1b     INC   $1B
$F8BE: a0 12     LDY   #$12
$F8C0: 20 89 f9  JSR   $F989
$F8C3: 20 d5 80  JSR   $80D5
$F8C6: 20 bd c1  JSR   $C1BD
$F8C9: 20 01 c0  JSR   $C001
$F8CC: a0 14     LDY   #$14
$F8CE: 20 89 f9  JSR   $F989
$F8D1: 20 9f 91  JSR   $919F
$F8D4: 20 1e cb  JSR   $CB1E
$F8D7: a9 00     LDA   #$00
$F8D9: 85 1b     STA   $1B
$F8DB: 68        PLA
$F8DC: a8        TAY
$F8DD: 68        PLA
$F8DE: aa        TAX
$F8DF: 68        PLA
$F8E0: 28        PLP
$F8E1: 40        RTI
$F8E2: a5 fe     LDA   $FE
$F8E4: a6 20     LDX   $20
$F8E6: f0 02     BEQ   $F8EA
$F8E8: a9 00     LDA   #$00
$F8EA: 8d 01 20  STA   $2001
$F8ED: ad 00 80  LDA   $8000
$F8F0: 48        PHA
$F8F1: a5 1b     LDA   $1B
$F8F3: 30 08     BMI   $F8FD
$F8F5: a0 12     LDY   #$12
$F8F7: 20 8f f9  JSR   $F98F
$F8FA: 20 d5 80  JSR   $80D5
$F8FD: 68        PLA
$F8FE: a8        TAY
$F8FF: 20 8f f9  JSR   $F98F
$F902: 20 33 f9  JSR   $F933
$F905: 20 ce fa  JSR   $FACE
$F908: 4c db f8  JMP   $F8DB
$F90B: a9 0f     LDA   #$0F
$F90D: 8d 15 40  STA   $4015
$F910: a9 c0     LDA   #$C0
$F912: 8d 17 40  STA   $4017
$F915: 60        RTS
$F916: a9 05     LDA   #$05
$F918: 85 20     STA   $20
$F91A: a9 b0     LDA   #$B0
$F91C: 85 ff     STA   $FF
$F91E: 8d 00 20  STA   $2000
$F921: a9 05     LDA   #$05
$F923: 85 20     STA   $20
$F925: 60        RTS
$F926: ad 02 20  LDA   $2002
$F929: a9 20     LDA   #$20
$F92B: 8d 06 20  STA   $2006
$F92E: a9 00     LDA   #$00
$F930: 8d 06 20  STA   $2006
$F933: ad 02 20  LDA   $2002
$F936: a5 fd     LDA   $FD
$F938: 8d 05 20  STA   $2005
$F93B: a5 fc     LDA   $FC
$F93D: 8d 05 20  STA   $2005
$F940: a5 ff     LDA   $FF
$F942: 8d 00 20  STA   $2000
$F945: 60        RTS
$F946: a9 00     LDA   #$00
$F948: 8d 06 20  STA   $2006
$F94B: 8d 06 20  STA   $2006
$F94E: 8d 00 20  STA   $2000
$F951: 8d 01 20  STA   $2001
$F954: 60        RTS
$F955: 85 01     STA   $01
$F957: a9 00     LDA   #$00
$F959: 85 00     STA   $00
$F95B: 91 00     STA   ($00),Y
$F95D: 88        DEY
$F95E: c0 ff     CPY   #$FF
$F960: d0 f9     BNE   $F95B
$F962: c6 01     DEC   $01
$F964: ca        DEX
$F965: 10 f4     BPL   $F95B
$F967: 60        RTS
$F968: ad 02 20 0a 30 fa ad 02 20 0a 10 fa a0 00 c8 c0 .byte $AD …
$F978: a0 d0 fb ad 02 20 a5 70 8d 05 20 a4 fc 8c 05 20 .byte $A0 …
$F988: 60        .byte $60
$F989: ad 00 80  LDA   $8000
$F98C: 8d ec 07  STA   $07EC
$F98F: 20 16 fb  JSR   $FB16
$F992: c8        INY
$F993: 20 21 fb  JSR   $FB21
$F996: 60        RTS
$F997: ac ec 07  LDY   $07EC
$F99A: 4c 8f f9  JMP   $F98F
$F99D: 48        PHA
$F99E: 98        TYA
$F99F: 48        PHA
$F9A0: ad 00 80  LDA   $8000
$F9A3: 8d ed 07  STA   $07ED
$F9A6: a0 12     LDY   #$12
$F9A8: 20 8f f9  JSR   $F98F
$F9AB: 68        PLA
$F9AC: a8        TAY
$F9AD: 68        PLA
$F9AE: 60        RTS
$F9AF: 48        PHA
$F9B0: 98        TYA
$F9B1: 48        PHA
$F9B2: ac ed 07  LDY   $07ED
$F9B5: 20 8f f9  JSR   $F98F
$F9B8: 68        PLA
$F9B9: a8        TAY
$F9BA: 68        PLA
$F9BB: 60        RTS
$F9BC: 48        PHA
$F9BD: a5 1b     LDA   $1B
$F9BF: 09 80     ORA   #$80
$F9C1: 85 1b     STA   $1B
$F9C3: 68        PLA
$F9C4: 20 9d f9  JSR   $F99D
$F9C7: 20 a2 87  JSR   $87A2
$F9CA: 20 af f9  JSR   $F9AF
$F9CD: a5 1b     LDA   $1B
$F9CF: 29 7f     AND   #$7F
$F9D1: 85 1b     STA   $1B
$F9D3: 60        RTS
$F9D4: 84 f7     STY   $F7
$F9D6: a0 12     LDY   #$12
$F9D8: 20 9d f9  JSR   $F99D
$F9DB: 20 19 87  JSR   $8719
$F9DE: 20 af f9  JSR   $F9AF
$F9E1: a4 f7     LDY   $F7
$F9E3: 60        RTS
$F9E4: 85 f3 84 f7 a0 16 20 89 f9 a5 f3 a4 f7 20 d1 c3 .byte $85 …
$F9F4: 4c 97 f9 85 f3 84 f7 a0 16 20 89 f9 a5 f3 a4 f7 .byte $4C …
$FA04: 20 93 c5 4c 97 f9 .byte $20 …
$FA0A: a0 1c     LDY   #$1C
$FA0C: 20 89 f9  JSR   $F989
$FA0F: 4c 84 85  JMP   $8584
$FA12: a0 1c     LDY   #$1C
$FA14: 20 89 f9  JSR   $F989
$FA17: 4c 01 80  JMP   $8001
$FA1A: a0 10     LDY   #$10
$FA1C: 20 89 f9  JSR   $F989
$FA1F: 4c 4f e5  JMP   $E54F
$FA22: a0 14     LDY   #$14
$FA24: 20 89 f9  JSR   $F989
$FA27: 4c 7b a9  JMP   $A97B
$FA2A: a0 10     LDY   #$10
$FA2C: 20 89 f9  JSR   $F989
$FA2F: 4c ba e5  JMP   $E5BA
$FA32: a0 14     LDY   #$14
$FA34: 20 89 f9  JSR   $F989
$FA37: 4c 85 aa  JMP   $AA85
$FA3A: a0 16     LDY   #$16
$FA3C: 20 89 f9  JSR   $F989
$FA3F: 4c 81 db  JMP   $DB81
$FA42: a0 16     LDY   #$16
$FA44: 20 89 f9  JSR   $F989
$FA47: 4c 1c db  JMP   $DB1C
$FA4A: a0 14     LDY   #$14
$FA4C: 20 89 f9  JSR   $F989
$FA4F: 4c f8 a4  JMP   $A4F8
$FA52: a0 14     LDY   #$14
$FA54: 20 89 f9  JSR   $F989
$FA57: 4c ef a4  JMP   $A4EF
$FA5A: a0 18     LDY   #$18
$FA5C: 20 89 f9  JSR   $F989
$FA5F: 4c 51 81  JMP   $8151
$FA62: a0 1a     LDY   #$1A
$FA64: 20 89 f9  JSR   $F989
$FA67: 4c 01 80  JMP   $8001
$FA6A: a0 1a 20 89 f9 4c 8b 88 .byte $A0 …
$FA72: a0 18     LDY   #$18
$FA74: 20 89 f9  JSR   $F989
$FA77: 4c 47 8f  JMP   $8F47
$FA7A: a0 18     LDY   #$18
$FA7C: 20 89 f9  JSR   $F989
$FA7F: 4c 8f 8f  JMP   $8F8F
$FA82: a0 18     LDY   #$18
$FA84: 48        PHA
$FA85: 20 89 f9  JSR   $F989
$FA88: 68        PLA
$FA89: 4c d9 91  JMP   $91D9
$FA8C: a0 18     LDY   #$18
$FA8E: 48        PHA
$FA8F: 20 89 f9  JSR   $F989
$FA92: 68        PLA
$FA93: 4c e0 91  JMP   $91E0
$FA96: a0 18     LDY   #$18
$FA98: 20 89 f9  JSR   $F989
$FA9B: 4c e9 92  JMP   $92E9
$FA9E: a0 18     LDY   #$18
$FAA0: 20 89 f9  JSR   $F989
$FAA3: 4c 48 93  JMP   $9348
$FAA6: a0 18 20 89 f9 4c 22 9e .byte $A0 …
$FAAE: a0 18     LDY   #$18
$FAB0: 20 89 f9  JSR   $F989
$FAB3: 4c 7c a6  JMP   $A67C
$FAB6: a0 18     LDY   #$18
$FAB8: 20 89 f9  JSR   $F989
$FABB: 4c b2 9b  JMP   $9BB2
$FABE: a0 18     LDY   #$18
$FAC0: 20 89 f9  JSR   $F989
$FAC3: 4c ca 9b  JMP   $9BCA
$FAC6: a0 1a     LDY   #$1A
$FAC8: 20 89 f9  JSR   $F989
$FACB: 4c d7 82  JMP   $82D7
$FACE: a9 00     LDA   #$00
$FAD0: 8d 00 80  STA   $8000
$FAD3: ad f0 07  LDA   $07F0
$FAD6: 8d 01 80  STA   $8001
$FAD9: a9 01     LDA   #$01
$FADB: 8d 00 80  STA   $8000
$FADE: ad f2 07  LDA   $07F2
$FAE1: 8d 01 80  STA   $8001
$FAE4: a9 02     LDA   #$02
$FAE6: 8d 00 80  STA   $8000
$FAE9: ad f4 07  LDA   $07F4
$FAEC: 8d 01 80  STA   $8001
$FAEF: a9 03     LDA   #$03
$FAF1: 8d 00 80  STA   $8000
$FAF4: ad f5 07  LDA   $07F5
$FAF7: 8d 01 80  STA   $8001
$FAFA: a9 04     LDA   #$04
$FAFC: 8d 00 80  STA   $8000
$FAFF: ad f6 07  LDA   $07F6
$FB02: 8d 01 80  STA   $8001
$FB05: a9 05     LDA   #$05
$FB07: 8d 00 80  STA   $8000
$FB0A: ad f7 07  LDA   $07F7
$FB0D: 8d 01 80  STA   $8001
$FB10: a9 00     LDA   #$00
$FB12: 8d 00 a0  STA   $A000
$FB15: 60        RTS
$FB16: 48        PHA
$FB17: a9 06     LDA   #$06
$FB19: 8d 00 80  STA   $8000
$FB1C: 68        PLA
$FB1D: 8c 01 80  STY   $8001
$FB20: 60        RTS
$FB21: 48        PHA
$FB22: a9 07     LDA   #$07
$FB24: 8d 00 80  STA   $8000
$FB27: 68        PLA
$FB28: 8c 01 80  STY   $8001
$FB2B: 60        RTS
$FB2C: 22 a7 6a 6b 6c 6d 5c 5d 6e 6f fd 22 c7 7a 7b 7c .byte $22 …
$FB3C: 7d 5e 5f 7e 7f 00 fe a5 bd .byte $7D …
$FB45: 48        PHA
$FB46: a9 92     LDA   #$92
$FB48: 8d f4 07  STA   $07F4
$FB4B: 68        PLA
$FB4C: 20 bc f9  JSR   $F9BC
$FB4F: 60        RTS
$FB50: 20 10 c9  JSR   $C910
$FB53: a9 93     LDA   #$93
$FB55: 18        CLC
$FB56: 65 30     ADC   $30
$FB58: 8d f4 07  STA   $07F4
$FB5B: a9 ab     LDA   #$AB
$FB5D: 8d f6 07  STA   $07F6
$FB60: 60        RTS
$FB61: a9 9b     LDA   #$9B
$FB63: 8d f5 07  STA   $07F5
$FB66: a9 9c     LDA   #$9C
$FB68: 8d f6 07  STA   $07F6
$FB6B: 4c 5f c1  JMP   $C15F
$FB6E: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FB7E: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FB8E: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FB9E: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FBAE: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FBBE: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FBCE: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FBDE: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FBEE: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FBFE: ff ff aa aa aa aa aa af f0 9e 9f f0 06 ae 7c 1b .byte $FF …
$FC0E: 98 f0 00 03 00 0c 01 ce 01 80 00 00 00 00 00 0f .byte $98 …
$FC1E: 1f ff fb f3 cf f3 ef de b8 f9 a6 a2 24 39 81 43 .byte $1F …
$FC2E: 80 86 19 02 38 51 87 86 15 39 8c a6 55 4d 16 8c .byte $80 …
$FC3E: a3 45 45 90 ca 56 22 52 70 d6 53 16 d3 54 d7 4b .byte $A3 …
$FC4E: 37 4b 5b 6b 56 ce b5 5b 5d 59 b6 d5 ab d6 b5 d7 .byte $37 …
$FC5E: 6b 6d ad ae b6 d6 b5 b5 aa d6 aa ac aa a9 54 a9 .byte $6B …
$FC6E: 94 a4 a9 4a 4a 8a 92 54 a5 49 29 4a 54 a5 29 52 .byte $94 …
$FC7E: a5 4a a5 54 a9 54 aa 95 2a aa 94 95 2a aa 55 55 .byte $A5 …
$FC8E: 2a 56 66 aa 9a aa b5 5a ad ab 5a b5 6b 6b 6b 5a .byte $2A …
$FC9E: b5 aa b5 56 aa d5 55 56 aa aa aa aa aa aa aa 95 .byte $B5 …
$FCAE: 55 55 ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $55 …
$FCBE: ff ff fe ff de ff e3 ef 8c 44 40 31 37 09 80 18 .byte $FF …
$FCCE: 60 00 c0 20 2f 3a a3 ee 3c ef 77 57 ef 9f af ff .byte $60 …
$FCDE: de bf 9e c9 24 41 09 09 09 29 00 00 04 00 18 74 .byte $DE …
$FCEE: 9b bf 76 eb cf 7b df fd f3 e7 c6 f3 81 e2 68 31 .byte $9B …
$FCFE: 1c 31 88 6a c0 8f 06 0a 61 c6 38 d4 c5 c7 2f 1d .byte $1C …
$FD0E: 63 a7 d0 fc 63 cf b8 f1 b1 cf f1 dc 76 33 ee 30 .byte $63 …
$FD1E: e2 d0 08 38 84 01 42 0e 07 0c 1d 1e 7d 9e 7f e7 .byte $E2 …
$FD2E: ef 3f 7f 3f 87 dc 63 18 73 0c 23 18 88 53 11 06 .byte $EF …
$FD3E: 0d 62 03 3c 33 24 e7 7c ae f3 e7 1f f8 f0 f3 cf .byte $0D …
$FD4E: 71 ae 1c 8e cf 08 ce 0c cc 18 31 c2 40 e1 8e 18 .byte $71 …
$FD5E: 2c d1 91 ed 9f 0f cf a7 3c ff 93 c7 cc f5 38 39 .byte $2C …
$FD6E: b8 19 47 88 46 d6 04 76 31 85 1c 58 63 9c 61 79 .byte $B8 …
$FD7E: 8c f3 98 f7 78 27 c7 9f 64 77 39 0f 8c f5 86 2f .byte $8C …
$FD8E: 91 8c 71 c7 21 e1 c4 19 8c 41 66 07 a6 2e 8a e7 .byte $91 …
$FD9E: 43 cf 9e 1f 9e 71 f3 e3 b7 18 fc 63 c3 18 c3 b0 .byte $43 …
$FDAE: e0 e3 0f 08 e0 71 8c c1 8f 19 c3 39 39 99 f1 bc .byte $E0 …
$FDBE: 74 76 e2 f3 c7 97 19 e3 63 39 87 c6 37 0f 09 c6 .byte $74 …
$FDCE: 71 23 88 e0 a9 83 8b 19 87 66 71 8c ef 0d da f4 .byte $71 …
$FDDE: 73 ee 1c db 8e 76 1a 39 0e 71 c6 2e 31 c3 9c 59 .byte $73 …
$FDEE: 07 a1 c0 f1 19 9c 58 ce 2e 2d 6e 3c e3 39 e3 8e .byte $07 …
$FDFE: b8 e7 1c e3 a7 0d 8e 47 94 b7 05 c2 39 e6 26 36 .byte $B8 …
$FE0E: 19 8c 74 98 cd 47 38 59 e8 d3 53 b8 f2 6e ac b3 .byte $19 …
$FE1E: b4 e5 71 27 8e 8c 8f 1a 3c 8a 73 8e 1c 6b 29 8e .byte $B4 …
$FE2E: 1c 2c 68 d9 31 e3 55 47 39 ab 2d 97 38 d3 b1 ce .byte $1C …
$FE3E: 38 f1 d4 b3 4e a9 62 ad 54 b2 38 c9 a8 ac a9 18 .byte $38 …
$FE4E: e6 51 9a 73 29 9e 39 9a d5 a7 96 d3 65 9d 58 ba .byte $E6 …
$FE5E: 61 da 46 aa 3c 52 b1 a5 66 63 8d 31 e0 e5 95 2a .byte $61 …
$FE6E: cc b2 9c ac ab 39 66 a7 4b 99 5a 6a cc ab 8b 55 .byte $CC …
$FE7E: a6 a6 aa 3c 5a 39 38 e2 a4 b9 30 b9 54 aa 95 aa .byte $A6 …
$FE8E: 65 5a 9c c7 59 b2 ae 6b 34 dc b2 d4 b1 d4 63 c5 .byte $65 …
$FE9E: 34 6a 65 69 65 4c e3 35 4c 71 a5 54 d6 33 4d 71 .byte $34 …
$FEAE: 92 ea 9a ab 56 55 5a ca 6a ce 33 3a 3c 65 56 39 .byte $92 …
$FEBE: 8d 62 c6 6a 33 49 a9 55 61 ac ad 2a aa d5 8d 6a .byte $8D …
$FECE: ac d5 5a d3 95 3a c8 e6 95 94 ad 4b 16 5a 62 e3 .byte $AC …
$FEDE: 4c cb 2a b3 2a aa 96 a6 5a 9a aa aa ac d3 55 55 .byte $4C …
$FEEE: 55 a6 a6 aa aa b4 cb 2c d2 ca ca aa 96 95 55 52 .byte $55 …
$FEFE: ca aa 96 66 55 55 aa 96 ab 2c ad 59 65 a6 aa ac .byte $CA …
$FF0E: b3 34 cb 4c aa ca aa a5 a6 56 55 54 d3 2a c6 aa .byte $B3 …
$FF1E: 6a 96 a6 66 aa aa b2 b4 d5 55 66 9a aa aa aa aa .byte $6A …
$FF2E: aa aa aa aa aa aa 9a a6 56 55 52 b2 aa aa aa 96 .byte $AA …
$FF3E: aa 65 aa aa aa b5 55 56 6a 6a aa aa aa 6a 72 9a .byte $AA …
$FF4E: aa 9a 9a a9 96 59 55 55 55 52 d2 b2 aa a9 aa aa .byte $AA …
$FF5E: aa ac b2 cc d5 55 55 65 96 59 aa aa 9a 9a 9a aa .byte $AA …
$FF6E: 6a 56 a5 65 95 55 55 55 54 b5 32 aa aa b2 aa b2 .byte $6A …
$FF7E: aa ab 55 55 55 55 55 69 aa aa 96 9a 99 5a 59 5a .byte $AA …
$FF8E: 55 65 96 59 55 55 55 55 55 52 b4 aa aa aa aa b2 .byte $55 …
$FF9E: d3 55 55 55 55 55 56 55 66 aa aa aa aa a6 9a aa .byte $D3 …
$FFAE: 65 55 55 55 55 55 32 cc aa aa aa ff ff ff ff ff .byte $65 …
$FFBE: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff .byte $FF …
$FFCE: ff ff ff ff ff ff ff ff ff ff 3f 3f 3f 3f 3f ff .byte $FF …
$FFDE: ff ff 00 00 00 00 00 00 00 00 00 00 43 4f 4e 54 .byte $FF …
$FFEE: 52 41 00 00 00 00 38 02 01 05 a4 1c 89 f8 0d f8 .byte $52 …
$FFFE: e1 f8     .byte $E1 …
