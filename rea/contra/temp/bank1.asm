8000: 12        .byte $12
8001: 21 9b     AND   ($9B,X)
8003: 29 9b     AND   #$9B
8005: 2e 9b 3b  ROL   $3B9B
8008: 9B        .byte $9B
8009: 48        PHA
800A: 9B        .byte $9B
800B: 5a        NOP
800C: 9B        .byte $9B
800D: 6d 9b 80  ADC   $809B
8010: 9B        .byte $9B
8011: 1F        .byte $1F
8012: ad 2c ad  LDA   $AD2C
8015: 32        .byte $32
8016: ad 39 ad  LDA   $AD39
8019: 46 ad     LSR   $AD
801B: 53        .byte $53
801C: ad 4a b0  LDA   $B04A
801F: A3        .byte $A3
8020: B3        .byte $B3
8021: b0 b3     BCS   $7FD6
8023: B7        .byte $B7
8024: B3        .byte $B3
8025: 90 b4     BCC   $7FDB
8027: 9d b4 aa  STA   $AAB4,X
802A: b4 b5     LDY   $B5,X
802C: b4 bc     LDY   $BC,X
802E: B3        .byte $B3
802F: 0e a2 19  ASL   $19A2
8032: a2 2e     LDX   #$2E
8034: a2 35     LDX   #$35
8036: a2 41     LDX   #$41
8038: a2 48     LDX   #$48
803A: a2 4d     LDX   #$4D
803C: a2 59     LDX   #$59
803E: a2 60     LDX   #$60
8040: a2 6c     LDX   #$6C
8042: a2 b5     LDX   #$B5
8044: A7        .byte $A7
8045: c1 a7     CMP   ($A7,X)
8047: 87        .byte $87
8048: a5 94     LDA   $94
804A: a5 9d     LDA   $9D
804C: a5 a9     LDA   $A9
804E: a5 a8     LDA   $A8
8050: a9 b6     LDA   #$B6
8052: a9 c4     LDA   #$C4
8054: a9 cc     LDA   #$CC
8056: a9 c8     LDA   #$C8
8058: A7        .byte $A7
8059: d4 a7     NOP   $A7
805B: e0 a7     CPX   #$A7
805D: 57        .byte $57
805E: b0 5f     BCS   $80BF
8060: b0 6c     BCS   $80CE
8062: b0 5e     BCS   $80C2
8064: b5 67     LDA   $67,X
8066: b5 77     LDA   $77,X
8068: b5 78     LDA   $78,X
806A: b5 c9     LDA   $C9,X
806C: B3        .byte $B3
806D: a9 30     LDA   #$30
806F: 9d 00 40  STA   $4000,X
8072: 20 0c 87  JSR   $870C
8075: d0 16     BNE   $808D
8077: bd 24 01  LDA   $0124,X
807A: 29 41     AND   #$41
807C: 0d 2f 01  ORA   $012F
807F: d0 ec     BNE   $806D
8081: bd 60 01  LDA   $0160,X
8084: 1d 4e 01  ORA   $014E,X
8087: 99 00 40  STA   $4000,Y
808A: 20 0c 87  JSR   $870C
808D: bd 72 01  LDA   $0172,X
8090: 99 02 40  STA   $4002,Y
8093: 20 0c 87  JSR   $870C
8096: bd 0c 01  LDA   $010C,X
8099: 99 03 40  STA   $4003,Y
809C: 4c 0c 87  JMP   $870C
809F: a5 25     LDA   $25
80A1: cd 2f 01  CMP   $012F
80A4: f0 2e     BEQ   $80D4
80A6: 8d 2f 01  STA   $012F
80A9: c9 00     CMP   #$00
80AB: f0 03     BEQ   $80B0
80AD: 4c 58 87  JMP   $8758
80B0: ad 0a 01  LDA   $010A
80B3: f0 13     BEQ   $80C8
80B5: ad 28 01  LDA   $0128
80B8: 10 06     BPL   $80C0
80BA: ad 2d 01  LDA   $012D
80BD: 8d 01 40  STA   $4001
80C0: a2 04     LDX   #$04
80C2: a0 00     LDY   #$00
80C4: 20 81 80  JSR   $8081
80C7: 60        RTS
80C8: ad 06 01  LDA   $0106
80CB: f0 07     BEQ   $80D4
80CD: a2 00     LDX   #$00
80CF: a0 00     LDY   #$00
80D1: 20 77 80  JSR   $8077
80D4: 60        RTS
80D5: 20 9f 80  JSR   $809F
80D8: a2 00     LDX   #$00
80DA: a0 00     LDY   #$00
80DC: 8e 20 01  STX   $0120
80DF: 8c 23 01  STY   $0123
80E2: bd 06 01  LDA   $0106,X
80E5: f0 04     BEQ   $80EB
80E7: a8        TAY
80E8: 20 03 81  JSR   $8103
80EB: e8        INX
80EC: e0 06     CPX   #$06
80EE: f0 12     BEQ   $8102
80F0: e0 05     CPX   #$05
80F2: d0 05     BNE   $80F9
80F4: a9 0c     LDA   #$0C
80F6: 4c fe 80  JMP   $80FE
80F9: 8a        TXA
80FA: 0a        ASL
80FB: 0a        ASL
80FC: 29 0f     AND   #$0F
80FE: a8        TAY
80FF: 4c dc 80  JMP   $80DC
8102: 60        RTS
8103: ad 2f 01  LDA   $012F
8106: f0 07     BEQ   $810F
8108: bd 06 01  LDA   $0106,X
810B: c9 74     CMP   #$74
810D: d0 f3     BNE   $8102
810F: 20 1d 86  JSR   $861D
8112: bd 24 01  LDA   $0124,X
8115: de 00 01  DEC   $0100,X
8118: d0 03     BNE   $811D
811A: 4c 59 82  JMP   $8259
811D: 29 41     AND   #$41
811F: d0 6e     BNE   $818F
8121: e0 02     CPX   #$02
8123: f0 6a     BEQ   $818F
8125: e0 03     CPX   #$03
8127: f0 66     BEQ   $818F
8129: e0 02     CPX   #$02
812B: b0 13     BCS   $8140
812D: bd 78 01  LDA   $0178,X
8130: 30 0e     BMI   $8140
8132: fe 7a 01  INC   $017A,X
8135: bd 7e 01  LDA   $017E,X
8138: dd 7a 01  CMP   $017A,X
813B: b0 03     BCS   $8140
813D: 20 f5 81  JSR   $81F5
8140: bd 24 01  LDA   $0124,X
8143: 29 20     AND   #$20
8145: d0 05     BNE   $814C
8147: bd 1e 01  LDA   $011E,X
814A: 30 71     BMI   $81BD
814C: bd 24 01  LDA   $0124,X
814F: a8        TAY
8150: 29 04     AND   #$04
8152: d0 53     BNE   $81A7
8154: bd 1e 01  LDA   $011E,X
8157: 0a        ASL
8158: a8        TAY
8159: b9 01 80  LDA   $8001,Y
815C: 85 e4     STA   $E4
815E: b9 02 80  LDA   $8002,Y
8161: 85 e5     STA   $E5
8163: bd 2a 01  LDA   $012A,X
8166: a8        TAY
8167: b1 e4     LDA   ($E4),Y
8169: c9 fe     CMP   #$FE
816B: b0 23     BCS   $8190
816D: fe 2a 01  INC   $012A,X
8170: 29 1f     AND   #$1F
8172: 9d 60 01  STA   $0160,X
8175: c9 02     CMP   #$02
8177: 90 08     BCC   $8181
8179: 38        SEC
817A: ed 3c 01  SBC   $013C
817D: 10 02     BPL   $8181
817F: a9 00     LDA   #$00
8181: 1d 4e 01  ORA   $014E,X
8184: 20 37 86  JSR   $8637
8187: b0 03     BCS   $818C
8189: 9d 00 40  STA   $4000,X
818C: ae 20 01  LDX   $0120
818F: 60        RTS
8190: d0 0c     BNE   $819E
8192: c8        INY
8193: b1 e4     LDA   ($E4),Y
8195: 9d 2a 01  STA   $012A,X
8198: 20 ac 81  JSR   $81AC
819B: 4c 63 81  JMP   $8163
819E: bd 24 01  LDA   $0124,X
81A1: 09 04     ORA   #$04
81A3: 9d 24 01  STA   $0124,X
81A6: 60        RTS
81A7: 98        TYA
81A8: 29 02     AND   #$02
81AA: d0 2c     BNE   $81D8
81AC: bd 00 01  LDA   $0100,X
81AF: dd 30 01  CMP   $0130,X
81B2: b0 08     BCS   $81BC
81B4: bd 24 01  LDA   $0124,X
81B7: 09 06     ORA   #$06
81B9: 9d 24 01  STA   $0124,X
81BC: 60        RTS
81BD: de 2a 01  DEC   $012A,X
81C0: 30 0b     BMI   $81CD
81C2: de 60 01  DEC   $0160,X
81C5: 30 1c     BMI   $81E3
81C7: bd 60 01  LDA   $0160,X
81CA: 4c 75 81  JMP   $8175
81CD: bd 24 01  LDA   $0124,X
81D0: 09 20     ORA   #$20
81D2: 9d 24 01  STA   $0124,X
81D5: 4c 9e 81  JMP   $819E
81D8: de 60 01  DEC   $0160,X
81DB: f0 06     BEQ   $81E3
81DD: bd 60 01  LDA   $0160,X
81E0: 4c 75 81  JMP   $8175
81E3: fe 60 01  INC   $0160,X
81E6: 60        RTS
81E7: b1 e0     LDA   ($E0),Y
81E9: c9 fd     CMP   #$FD
81EB: 90 05     BCC   $81F2
81ED: 29 0f     AND   #$0F
81EF: 4c a2 84  JMP   $84A2
81F2: 4c d5 82  JMP   $82D5
81F5: 98        TYA
81F6: 48        PHA
81F7: ac 23 01  LDY   $0123
81FA: 38        SEC
81FB: fd 7e 01  SBC   $017E,X
81FE: 85 e4     STA   $E4
8200: bd 80 01  LDA   $0180,X
8203: 29 f0     AND   #$F0
8205: 4a        LSR
8206: 4a        LSR
8207: 4a        LSR
8208: 4a        LSR
8209: c5 e4     CMP   $E4
820B: d0 15     BNE   $8222
820D: bd 7e 01  LDA   $017E,X
8210: 9d 7a 01  STA   $017A,X
8213: fe 78 01  INC   $0178,X
8216: bd 78 01  LDA   $0178,X
8219: c9 04     CMP   #$04
821B: 90 05     BCC   $8222
821D: a9 00     LDA   #$00
821F: 9d 78 01  STA   $0178,X
8222: bd 78 01  LDA   $0178,X
8225: 29 01     AND   #$01
8227: d0 0c     BNE   $8235
8229: bd 7c 01  LDA   $017C,X
822C: 99 02 40  STA   $4002,Y
822F: 20 0c 87  JSR   $870C
8232: 68        PLA
8233: a8        TAY
8234: 60        RTS
8235: bd 80 01  LDA   $0180,X
8238: 29 0f     AND   #$0F
823A: 85 e4     STA   $E4
823C: bd 78 01  LDA   $0178,X
823F: 29 02     AND   #$02
8241: d0 0d     BNE   $8250
8243: a5 e4     LDA   $E4
8245: 18        CLC
8246: 7d 7c 01  ADC   $017C,X
8249: 90 e1     BCC   $822C
824B: a9 ff     LDA   #$FF
824D: 4c 2c 82  JMP   $822C
8250: bd 7c 01  LDA   $017C,X
8253: 38        SEC
8254: e5 e4     SBC   $E4
8256: 4c 2c 82  JMP   $822C
8259: 4a        LSR
825A: b0 8b     BCS   $81E7
825C: ad 20 01  LDA   $0120
825F: c9 03     CMP   #$03
8261: f0 25     BEQ   $8288
8263: b1 e0     LDA   ($E0),Y
8265: 29 f0     AND   #$F0
8267: c9 c0     CMP   #$C0
8269: b0 03     BCS   $826E
826B: 4c 95 83  JMP   $8395
826E: 29 30     AND   #$30
8270: 4a        LSR
8271: 4a        LSR
8272: 4a        LSR
8273: aa        TAX
8274: bd d4 86  LDA   $86D4,X
8277: 85 e4     STA   $E4
8279: bd d5 86  LDA   $86D5,X
827C: 85 e5     STA   $E5
827E: ae 20 01  LDX   $0120
8281: b1 e0     LDA   ($E0),Y
8283: 29 0f     AND   #$0F
8285: 6c e4 00  JMP   ($00E4)
8288: b1 e0     LDA   ($E0),Y
828A: 29 f0     AND   #$F0
828C: c9 f0     CMP   #$F0
828E: d0 07     BNE   $8297
8290: b1 e0     LDA   ($E0),Y
8292: 29 0f     AND   #$0F
8294: 4c a2 84  JMP   $84A2
8297: c9 d0     CMP   #$D0
8299: f0 03     BEQ   $829E
829B: 4c b7 85  JMP   $85B7
829E: b1 e0     LDA   ($E0),Y
82A0: 29 0f     AND   #$0F
82A2: 9d 54 01  STA   $0154,X
82A5: c8        INY
82A6: 4c 88 82  JMP   $8288
82A9: b1 e0     LDA   ($E0),Y
82AB: 4a        LSR
82AC: 4a        LSR
82AD: 4a        LSR
82AE: 4a        LSR
82AF: c9 0c     CMP   #$0C
82B1: f0 16     BEQ   $82C9
82B3: aa        TAX
82B4: 8d 21 01  STA   $0121
82B7: bd cd 82  LDA   $82CD,X
82BA: 20 a2 87  JSR   $87A2
82BD: ad 21 01  LDA   $0121
82C0: c9 03     CMP   #$03
82C2: 90 05     BCC   $82C9
82C4: a9 02     LDA   #$02
82C6: 20 a2 87  JSR   $87A2
82C9: ae 20 01  LDX   $0120
82CC: 60        RTS
82CD: 02        .byte $02
82CE: 7F        .byte $7F
82CF: 80 7f     NOP   $7F
82D1: 80 3e     NOP   $3E
82D3: 81 82     STA   ($82,X)
82D5: 29 f0     AND   #$F0
82D7: c9 20     CMP   #$20
82D9: d0 18     BNE   $82F3
82DB: b1 e0     LDA   ($E0),Y
82DD: 29 0f     AND   #$0F
82DF: d0 03     BNE   $82E4
82E1: c8        INY
82E2: b1 e0     LDA   ($E0),Y
82E4: 9d 54 01  STA   $0154,X
82E7: c8        INY
82E8: b1 e0     LDA   ($E0),Y
82EA: 9d 4e 01  STA   $014E,X
82ED: c8        INY
82EE: f0 03     BEQ   $82F3
82F0: 4c e7 81  JMP   $81E7
82F3: c9 10     CMP   #$10
82F5: d0 42     BNE   $8339
82F7: b1 e0     LDA   ($E0),Y
82F9: c8        INY
82FA: c9 10     CMP   #$10
82FC: d0 30     BNE   $832E
82FE: b1 e0     LDA   ($E0),Y
8300: d0 0c     BNE   $830E
8302: bd 24 01  LDA   $0124,X
8305: 29 7f     AND   #$7F
8307: 9d 24 01  STA   $0124,X
830A: a9 7f     LDA   #$7F
830C: d0 0a     BNE   $8318
830E: bd 24 01  LDA   $0124,X
8311: 09 80     ORA   #$80
8313: 9d 24 01  STA   $0124,X
8316: b1 e0     LDA   ($E0),Y
8318: e0 04     CPX   #$04
831A: d0 03     BNE   $831F
831C: 8d 2d 01  STA   $012D
831F: 20 37 86  JSR   $8637
8322: b0 03     BCS   $8327
8324: 9d 01 40  STA   $4001,X
8327: ae 20 01  LDX   $0120
832A: c8        INY
832B: 4c e7 81  JMP   $81E7
832E: bd 24 01  LDA   $0124,X
8331: 09 10     ORA   #$10
8333: 9d 24 01  STA   $0124,X
8336: 4c e7 81  JMP   $81E7
8339: bd 54 01  LDA   $0154,X
833C: 9d 00 01  STA   $0100,X
833F: b1 e0     LDA   ($E0),Y
8341: c9 f8     CMP   #$F8
8343: d0 03     BNE   $8348
8345: c8        INY
8346: b1 e0     LDA   ($E0),Y
8348: 4a        LSR
8349: 4a        LSR
834A: 4a        LSR
834B: 4a        LSR
834C: 9d 42 01  STA   $0142,X
834F: bd 4e 01  LDA   $014E,X
8352: 29 10     AND   #$10
8354: f0 1f     BEQ   $8375
8356: bd 42 01  LDA   $0142,X
8359: 1d 4e 01  ORA   $014E,X
835C: 20 37 86  JSR   $8637
835F: b0 03     BCS   $8364
8361: 9d 00 40  STA   $4000,X
8364: ae 20 01  LDX   $0120
8367: b1 e0     LDA   ($E0),Y
8369: 29 0f     AND   #$0F
836B: 85 ef     STA   $EF
836D: c8        INY
836E: b1 e0     LDA   ($E0),Y
8370: 85 ee     STA   $EE
8372: 4c 09 84  JMP   $8409
8375: bd 4e 01  LDA   $014E,X
8378: 4c 5c 83  JMP   $835C
837B: ad 44 01  LDA   $0144
837E: 8d 08 40  STA   $4008
8381: 4c ad 83  JMP   $83AD
8384: bd 42 01  LDA   $0142,X
8387: 20 72 81  JSR   $8172
838A: bd 1e 01  LDA   $011E,X
838D: 29 0f     AND   #$0F
838F: 9d 2a 01  STA   $012A,X
8392: 4c ad 83  JMP   $83AD
8395: 20 b7 85  JSR   $85B7
8398: e0 02     CPX   #$02
839A: f0 df     BEQ   $837B
839C: bd 1e 01  LDA   $011E,X
839F: 30 e3     BMI   $8384
83A1: a9 00     LDA   #$00
83A3: 9d 2a 01  STA   $012A,X
83A6: 84 e6     STY   $E6
83A8: 20 54 81  JSR   $8154
83AB: a4 e6     LDY   $E6
83AD: bd 24 01  LDA   $0124,X
83B0: 29 99     AND   #$99
83B2: 9d 24 01  STA   $0124,X
83B5: b1 e0     LDA   ($E0),Y
83B7: 29 f0     AND   #$F0
83B9: 4a        LSR
83BA: 4a        LSR
83BB: 4a        LSR
83BC: aa        TAX
83BD: 98        TYA
83BE: 48        PHA
83BF: ac 20 01  LDY   $0120
83C2: b9 32 01  LDA   $0132,Y
83C5: f0 06     BEQ   $83CD
83C7: 8a        TXA
83C8: 18        CLC
83C9: 79 32 01  ADC   $0132,Y
83CC: aa        TAX
83CD: 68        PLA
83CE: a8        TAY
83CF: bd dc 86  LDA   $86DC,X
83D2: 85 ee     STA   $EE
83D4: bd dd 86  LDA   $86DD,X
83D7: 85 ef     STA   $EF
83D9: ae 20 01  LDX   $0120
83DC: bd 5a 01  LDA   $015A,X
83DF: aa        TAX
83E0: e0 04     CPX   #$04
83E2: f0 07     BEQ   $83EB
83E4: 46 ef     LSR   $EF
83E6: 66 ee     ROR   $EE
83E8: e8        INX
83E9: d0 f5     BNE   $83E0
83EB: ae 20 01  LDX   $0120
83EE: e0 02     CPX   #$02
83F0: b0 17     BCS   $8409
83F2: bd 78 01  LDA   $0178,X
83F5: 30 12     BMI   $8409
83F7: a5 ee     LDA   $EE
83F9: 9d 7c 01  STA   $017C,X
83FC: bd 24 01  LDA   $0124,X
83FF: 29 10     AND   #$10
8401: f0 03     BEQ   $8406
8403: fe 7c 01  INC   $017C,X
8406: ae 20 01  LDX   $0120
8409: bd 24 01  LDA   $0124,X
840C: 29 10     AND   #$10
840E: f0 06     BEQ   $8416
8410: e6 ee     INC   $EE
8412: d0 02     BNE   $8416
8414: e6 ef     INC   $EF
8416: a5 ef     LDA   $EF
8418: e0 02     CPX   #$02
841A: f0 17     BEQ   $8433
841C: e0 05     CPX   #$05
841E: f0 11     BEQ   $8431
8420: dd 0c 01  CMP   $010C,X
8423: d0 0e     BNE   $8433
8425: bd 24 01  LDA   $0124,X
8428: 30 07     BMI   $8431
842A: bd 4e 01  LDA   $014E,X
842D: 29 10     AND   #$10
842F: d0 0f     BNE   $8440
8431: a5 ef     LDA   $EF
8433: 9d 0c 01  STA   $010C,X
8436: 09 08     ORA   #$08
8438: 20 37 86  JSR   $8637
843B: b0 03     BCS   $8440
843D: 9d 03 40  STA   $4003,X
8440: a5 ee     LDA   $EE
8442: ae 20 01  LDX   $0120
8445: e0 02     CPX   #$02
8447: b0 03     BCS   $844C
8449: 9d 72 01  STA   $0172,X
844C: 20 37 86  JSR   $8637
844F: b0 03     BCS   $8454
8451: 9d 02 40  STA   $4002,X
8454: ae 20 01  LDX   $0120
8457: c8        INY
8458: 98        TYA
8459: 18        CLC
845A: 65 e0     ADC   $E0
845C: 9d 12 01  STA   $0112,X
845F: a9 00     LDA   #$00
8461: 65 e1     ADC   $E1
8463: 9d 18 01  STA   $0118,X
8466: 60        RTS
8467: bd 66 01  LDA   $0166,X
846A: 85 e0     STA   $E0
846C: bd 6c 01  LDA   $016C,X
846F: 85 e1     STA   $E1
8471: bd 24 01  LDA   $0124,X
8474: 29 f7     AND   #$F7
8476: 9d 24 01  STA   $0124,X
8479: a0 00     LDY   #$00
847B: 4c dc 84  JMP   $84DC
847E: bd 24 01  LDA   $0124,X
8481: 29 08     AND   #$08
8483: d0 e2     BNE   $8467
8485: bd 06 01  LDA   $0106,X
8488: 85 e6     STA   $E6
848A: a9 00     LDA   #$00
848C: 9d 06 01  STA   $0106,X
848F: 8a        TXA
8490: 0a        ASL
8491: aa        TAX
8492: bd c6 86  LDA   $86C6,X
8495: 85 e4     STA   $E4
8497: bd c7 86  LDA   $86C7,X
849A: 85 e5     STA   $E5
849C: ae 20 01  LDX   $0120
849F: 6c e4 00  JMP   ($00E4)
84A2: c9 0e     CMP   #$0E
84A4: f0 20     BEQ   $84C6
84A6: b0 d6     BCS   $847E
84A8: 20 2a 86  JSR   $862A
84AB: c8        INY
84AC: 98        TYA
84AD: 18        CLC
84AE: 65 e0     ADC   $E0
84B0: 9d 66 01  STA   $0166,X
84B3: a9 00     LDA   #$00
84B5: a8        TAY
84B6: 65 e1     ADC   $E1
84B8: 9d 6c 01  STA   $016C,X
84BB: bd 24 01  LDA   $0124,X
84BE: 09 08     ORA   #$08
84C0: 9d 24 01  STA   $0124,X
84C3: 4c d9 84  JMP   $84D9
84C6: fe 48 01  INC   $0148,X
84C9: bd 48 01  LDA   $0148,X
84CC: c8        INY
84CD: d1 e0     CMP   ($E0),Y
84CF: f0 17     BEQ   $84E8
84D1: 30 03     BMI   $84D6
84D3: de 48 01  DEC   $0148,X
84D6: 20 2a 86  JSR   $862A
84D9: 20 1d 86  JSR   $861D
84DC: bd 24 01  LDA   $0124,X
84DF: 4a        LSR
84E0: b0 03     BCS   $84E5
84E2: 4c 5c 82  JMP   $825C
84E5: 4c e7 81  JMP   $81E7
84E8: a9 00     LDA   #$00
84EA: 9d 48 01  STA   $0148,X
84ED: c8        INY
84EE: c8        INY
84EF: c8        INY
84F0: 98        TYA
84F1: 18        CLC
84F2: 65 e0     ADC   $E0
84F4: 85 e0     STA   $E0
84F6: a9 00     LDA   #$00
84F8: a8        TAY
84F9: 65 e1     ADC   $E1
84FB: 85 e1     STA   $E1
84FD: 4c dc 84  JMP   $84DC
8500: 20 bb 85  JSR   $85BB
8503: a9 00     LDA   #$00
8505: e0 02     CPX   #$02
8507: f0 03     BEQ   $850C
8509: bd 4e 01  LDA   $014E,X
850C: 20 37 86  JSR   $8637
850F: b0 03     BCS   $8514
8511: 9d 00 40  STA   $4000,X
8514: ae 20 01  LDX   $0120
8517: bd 24 01  LDA   $0124,X
851A: 09 40     ORA   #$40
851C: 9d 24 01  STA   $0124,X
851F: 4c 57 84  JMP   $8457
8522: 9d 54 01  STA   $0154,X
8525: c8        INY
8526: b1 e0     LDA   ($E0),Y
8528: e0 02     CPX   #$02
852A: f0 29     BEQ   $8555
852C: 29 0f     AND   #$0F
852E: 38        SEC
852F: ed 3c 01  SBC   $013C
8532: 10 05     BPL   $8539
8534: a9 00     LDA   #$00
8536: 4c 8c 84  JMP   $848C
8539: 9d 42 01  STA   $0142,X
853C: b1 e0     LDA   ($E0),Y
853E: 29 f0     AND   #$F0
8540: 9d 4e 01  STA   $014E,X
8543: c8        INY
8544: b1 e0     LDA   ($E0),Y
8546: 9d 1e 01  STA   $011E,X
8549: c8        INY
854A: b1 e0     LDA   ($E0),Y
854C: 29 0f     AND   #$0F
854E: 9d 36 01  STA   $0136,X
8551: c8        INY
8552: 4c 5c 82  JMP   $825C
8555: 8d 44 01  STA   $0144
8558: c8        INY
8559: 4c 5c 82  JMP   $825C
855C: c9 05     CMP   #$05
855E: b0 07     BCS   $8567
8560: 9d 5a 01  STA   $015A,X
8563: c8        INY
8564: 4c 5c 82  JMP   $825C
8567: c9 08     CMP   #$08
8569: f0 0c     BEQ   $8577
856B: c9 0b     CMP   #$0B
856D: f0 14     BEQ   $8583
856F: c9 0c     CMP   #$0C
8571: f0 32     BEQ   $85A5
8573: c8        INY
8574: 4c 5c 82  JMP   $825C
8577: bd 24 01  LDA   $0124,X
857A: 49 10     EOR   #$10
857C: 9d 24 01  STA   $0124,X
857F: c8        INY
8580: 4c 5c 82  JMP   $825C
8583: c8        INY
8584: b1 e0     LDA   ($E0),Y
8586: 9d 7e 01  STA   $017E,X
8589: c9 ff     CMP   #$FF
858B: f0 0f     BEQ   $859C
858D: c8        INY
858E: b1 e0     LDA   ($E0),Y
8590: 9d 80 01  STA   $0180,X
8593: a9 00     LDA   #$00
8595: 9d 78 01  STA   $0178,X
8598: c8        INY
8599: 4c 5c 82  JMP   $825C
859C: a9 80     LDA   #$80
859E: 9d 78 01  STA   $0178,X
85A1: c8        INY
85A2: 4c 5c 82  JMP   $825C
85A5: c8        INY
85A6: b1 e0     LDA   ($E0),Y
85A8: 0a        ASL
85A9: 9d 32 01  STA   $0132,X
85AC: c8        INY
85AD: 4c 5c 82  JMP   $825C
85B0: 20 57 84  JSR   $8457
85B3: 88        DEY
85B4: 4c a9 82  JMP   $82A9
85B7: b1 e0     LDA   ($E0),Y
85B9: 29 0f     AND   #$0F
85BB: 85 e4     STA   $E4
85BD: f0 0d     BEQ   $85CC
85BF: bd 54 01  LDA   $0154,X
85C2: 18        CLC
85C3: 7d 54 01  ADC   $0154,X
85C6: c6 e4     DEC   $E4
85C8: d0 f8     BNE   $85C2
85CA: f0 03     BEQ   $85CF
85CC: bd 54 01  LDA   $0154,X
85CF: 9d 00 01  STA   $0100,X
85D2: e0 02     CPX   #$02
85D4: b0 0a     BCS   $85E0
85D6: bd 78 01  LDA   $0178,X
85D9: 30 05     BMI   $85E0
85DB: a9 00     LDA   #$00
85DD: 9d 7a 01  STA   $017A,X
85E0: e0 02     CPX   #$02
85E2: f0 0d     BEQ   $85F1
85E4: e0 03     CPX   #$03
85E6: f0 c8     BEQ   $85B0
85E8: bd 36 01  LDA   $0136,X
85EB: 20 f2 85  JSR   $85F2
85EE: 9d 30 01  STA   $0130,X
85F1: 60        RTS
85F2: 29 0f     AND   #$0F
85F4: 85 e4     STA   $E4
85F6: a9 00     LDA   #$00
85F8: 85 e6     STA   $E6
85FA: 85 e7     STA   $E7
85FC: c6 e4     DEC   $E4
85FE: 30 0e     BMI   $860E
8600: 18        CLC
8601: bd 00 01  LDA   $0100,X
8604: 65 e6     ADC   $E6
8606: 85 e6     STA   $E6
8608: 90 f2     BCC   $85FC
860A: e6 e7     INC   $E7
860C: d0 ee     BNE   $85FC
860E: 0a        ASL
860F: 26 e7     ROL   $E7
8611: 0a        ASL
8612: 26 e7     ROL   $E7
8614: 0a        ASL
8615: 26 e7     ROL   $E7
8617: 0a        ASL
8618: 26 e7     ROL   $E7
861A: a5 e7     LDA   $E7
861C: 60        RTS
861D: a0 00     LDY   #$00
861F: bd 12 01  LDA   $0112,X
8622: 85 e0     STA   $E0
8624: bd 18 01  LDA   $0118,X
8627: 85 e1     STA   $E1
8629: 60        RTS
862A: c8        INY
862B: b1 e0     LDA   ($E0),Y
862D: 9d 12 01  STA   $0112,X
8630: c8        INY
8631: b1 e0     LDA   ($E0),Y
8633: 9d 18 01  STA   $0118,X
8636: 60        RTS
8637: 48        PHA
8638: e0 01     CPX   #$01
863A: 90 06     BCC   $8642
863C: 18        CLC
863D: ae 23 01  LDX   $0123
8640: 68        PLA
8641: 60        RTS
8642: e8        INX
8643: e8        INX
8644: e8        INX
8645: e8        INX
8646: bd 06 01  LDA   $0106,X
8649: f0 f1     BEQ   $863C
864B: ae 20 01  LDX   $0120
864E: 38        SEC
864F: 68        PLA
8650: 60        RTS
8651: a9 30     LDA   #$30
8653: 20 37 86  JSR   $8637
8656: b0 03     BCS   $865B
8658: 9d 00 40  STA   $4000,X
865B: ae 20 01  LDX   $0120
865E: 60        RTS
865F: a9 0b     LDA   #$0B
8661: 8d 15 40  STA   $4015
8664: a9 00     LDA   #$00
8666: 8d 08 40  STA   $4008
8669: a9 0f     LDA   #$0F
866B: 8d 15 40  STA   $4015
866E: 60        RTS
866F: ae 23 01  LDX   $0123
8672: a9 30     LDA   #$30
8674: 9d 00 40  STA   $4000,X
8677: 20 0c 87  JSR   $870C
867A: a9 7f     LDA   #$7F
867C: 9d 01 40  STA   $4001,X
867F: 8a        TXA
8680: 4a        LSR
8681: 4a        LSR
8682: aa        TAX
8683: bd 06 01  LDA   $0106,X
8686: f0 36     BEQ   $86BE
8688: ac 23 01  LDY   $0123
868B: 20 77 80  JSR   $8077
868E: ae 20 01  LDX   $0120
8691: 60        RTS
8692: a9 30     LDA   #$30
8694: 8d 0c 40  STA   $400C
8697: a5 e6     LDA   $E6
8699: c9 6a     CMP   #$6A
869B: d0 06     BNE   $86A3
869D: a9 6e     LDA   #$6E
869F: 4c a2 87  JMP   $87A2
86A2: 60        RTS
86A3: c9 77     CMP   #$77
86A5: d0 a9     BNE   $8650
86A7: ad 20 01  LDA   $0120
86AA: c9 05     CMP   #$05
86AC: d0 a2     BNE   $8650
86AE: ad 94 01  LDA   $0194
86B1: f0 9d     BEQ   $8650
86B3: a9 62     LDA   #$62
86B5: 20 a2 87  JSR   $87A2
86B8: 60        RTS
86B9: a9 66     LDA   #$66
86BB: 4c a2 87  JMP   $87A2
86BE: ae 20 01  LDX   $0120
86C1: a5 e6     LDA   $E6
86C3: 4c 50 86  JMP   $8650
86C6: 51 86     EOR   ($86),Y
86C8: 51 86     EOR   ($86),Y
86CA: 5F        .byte $5F
86CB: 86 92     STX   $92
86CD: 86 6f     STX   $6F
86CF: 86 92     STX   $92
86D1: 86 51     STX   $51
86D3: 86 00     STX   $00
86D5: 85 22     STA   $22
86D7: 85 5c     STA   $5C
86D9: 85 a2     STA   $A2
86DB: 84 ae     STY   $AE
86DD: 06 4e     ASL   $4E
86DF: 06 f4     ASL   $F4
86E1: 05 9e     ORA   $9E
86E3: 05 4e     ORA   $4E
86E5: 05 01     ORA   $01
86E7: 05 b9     ORA   $B9
86E9: 04 76     NOP   $76
86EB: 04 36     NOP   $36
86ED: 04 f9     NOP   $F9
86EF: 03        .byte $03
86F0: c0 03     CPY   #$03
86F2: 8a        TXA
86F3: 03        .byte $03
86F4: 57        .byte $57
86F5: 03        .byte $03
86F6: 27        .byte $27
86F7: 03        .byte $03
86F8: fa        NOP
86F9: 02        .byte $02
86FA: CF        .byte $CF
86FB: 02        .byte $02
86FC: A7        .byte $A7
86FD: 02        .byte $02
86FE: 81 02     STA   ($02,X)
8700: 5d 02 3b  EOR   $3B02,X
8703: 02        .byte $02
8704: 1B        .byte $1B
8705: 02        .byte $02
8706: fd 01 e0  SBC   $E001,X
8709: 01 c5     ORA   ($C5,X)
870B: 01 ea     ORA   ($EA,X)
870D: ea        NOP
870E: ea        NOP
870F: ea        NOP
8710: ea        NOP
8711: ea        NOP
8712: ea        NOP
8713: ea        NOP
8714: ea        NOP
8715: ea        NOP
8716: 60        RTS
8717: 20 89 8a  JSR   $8A89
871A: 48        PHA
871B: 98        TYA
871C: 48        PHA
871D: a9 00     LDA   #$00
871F: aa        TAX
8720: 9d 06 01  STA   $0106,X
8723: e8        INX
8724: e0 06     CPX   #$06
8726: 90 f8     BCC   $8720
8728: 8d 40 01  STA   $0140
872B: 8d 3e 01  STA   $013E
872E: 8d 3c 01  STA   $013C
8731: 20 5f 86  JSR   $865F
8734: a9 30     LDA   #$30
8736: 8d 00 40  STA   $4000
8739: 20 0c 87  JSR   $870C
873C: 8d 04 40  STA   $4004
873F: 20 0c 87  JSR   $870C
8742: 8d 0c 40  STA   $400C
8745: 20 0c 87  JSR   $870C
8748: a2 7f     LDX   #$7F
874A: 8e 01 40  STX   $4001
874D: 20 0c 87  JSR   $870C
8750: 8e 05 40  STX   $4005
8753: 68        PLA
8754: a8        TAY
8755: 68        PLA
8756: aa        TAX
8757: 60        RTS
8758: 20 5f 86  JSR   $865F
875B: a9 30     LDA   #$30
875D: 8d 00 40  STA   $4000
8760: 20 0c 87  JSR   $870C
8763: 8d 04 40  STA   $4004
8766: 20 0c 87  JSR   $870C
8769: 8d 0c 40  STA   $400C
876C: 20 0c 87  JSR   $870C
876F: a2 7f     LDX   #$7F
8771: 8e 01 40  STX   $4001
8774: 20 0c 87  JSR   $870C
8777: 8e 05 40  STX   $4005
877A: 60        RTS
877B: 8a        TXA
877C: 48        PHA
877D: 98        TYA
877E: 48        PHA
877F: a2 00     LDX   #$00
8781: 86 e6     STX   $E6
8783: ad 0a 01  LDA   $010A
8786: f0 09     BEQ   $8791
8788: 8e 0a 01  STX   $010A
878B: 8e 23 01  STX   $0123
878E: 20 6f 86  JSR   $866F
8791: 68        PLA
8792: a8        TAY
8793: 68        PLA
8794: aa        TAX
8795: 60        RTS
8796: 8d 3e 01  STA   $013E
8799: 8d 41 01  STA   $0141
879C: a9 00     LDA   #$00
879E: 8d 3c 01  STA   $013C
87A1: 60        RTS
87A2: 8d 22 01  STA   $0122
87A5: c9 82     CMP   #$82
87A7: 90 01     BCC   $87AA
87A9: 60        RTS
87AA: c9 7f     CMP   #$7F
87AC: 90 03     BCC   $87B1
87AE: 4c da 88  JMP   $88DA
87B1: ad 07 01  LDA   $0107
87B4: c9 62     CMP   #$62
87B6: d0 08     BNE   $87C0
87B8: ad 22 01  LDA   $0122
87BB: c9 0b     CMP   #$0B
87BD: f0 01     BEQ   $87C0
87BF: 60        RTS
87C0: ad 22 01  LDA   $0122
87C3: c9 77     CMP   #$77
87C5: d0 06     BNE   $87CD
87C7: 20 19 87  JSR   $8719
87CA: 4c fa 87  JMP   $87FA
87CD: c9 62     CMP   #$62
87CF: d0 0d     BNE   $87DE
87D1: ad 07 01  LDA   $0107
87D4: c9 77     CMP   #$77
87D6: d0 01     BNE   $87D9
87D8: 60        RTS
87D9: c9 62     CMP   #$62
87DB: d0 01     BNE   $87DE
87DD: 60        RTS
87DE: c9 46     CMP   #$46
87E0: f0 08     BEQ   $87EA
87E2: c9 4a     CMP   #$4A
87E4: f0 04     BEQ   $87EA
87E6: c9 07     CMP   #$07
87E8: d0 10     BNE   $87FA
87EA: ad 35 01  LDA   $0135
87ED: 8d 11 40  STA   $4011
87F0: 38        SEC
87F1: e9 01     SBC   #$01
87F3: 10 f8     BPL   $87ED
87F5: a9 00     LDA   #$00
87F7: 8d 11 40  STA   $4011
87FA: c9 18     CMP   #$18
87FC: d0 08     BNE   $8806
87FE: ad 0a 01  LDA   $010A
8801: c9 16     CMP   #$16
8803: d0 01     BNE   $8806
8805: 60        RTS
8806: 8a        TXA
8807: 48        PHA
8808: 98        TYA
8809: 48        PHA
880A: ad 17 87  LDA   $8717
880D: 85 ec     STA   $EC
880F: ad 18 87  LDA   $8718
8812: 85 ed     STA   $ED
8814: a9 03     LDA   #$03
8816: 85 ea     STA   $EA
8818: ad 22 01  LDA   $0122
881B: 18        CLC
881C: 65 ec     ADC   $EC
881E: 85 ec     STA   $EC
8820: a9 00     LDA   #$00
8822: 65 ed     ADC   $ED
8824: 85 ed     STA   $ED
8826: c6 ea     DEC   $EA
8828: d0 ee     BNE   $8818
882A: a0 00     LDY   #$00
882C: 84 eb     STY   $EB
882E: b1 ec     LDA   ($EC),Y
8830: 4a        LSR
8831: 4a        LSR
8832: 4a        LSR
8833: 29 03     AND   #$03
8835: 85 ea     STA   $EA
8837: a5 eb     LDA   $EB
8839: 0a        ASL
883A: 18        CLC
883B: 65 eb     ADC   $EB
883D: a8        TAY
883E: b1 ec     LDA   ($EC),Y
8840: 29 07     AND   #$07
8842: aa        TAX
8843: ad 22 01  LDA   $0122
8846: dd 06 01  CMP   $0106,X
8849: 90 75     BCC   $88C0
884B: a9 00     LDA   #$00
884D: 9d 06 01  STA   $0106,X
8850: c8        INY
8851: b1 ec     LDA   ($EC),Y
8853: 9d 12 01  STA   $0112,X
8856: 85 e8     STA   $E8
8858: c8        INY
8859: b1 ec     LDA   ($EC),Y
885B: 9d 18 01  STA   $0118,X
885E: 85 e9     STA   $E9
8860: a9 f8     LDA   #$F8
8862: 9d 0c 01  STA   $010C,X
8865: a9 01     LDA   #$01
8867: 9d 00 01  STA   $0100,X
886A: e0 03     CPX   #$03
886C: b0 0e     BCS   $887C
886E: e0 02     CPX   #$02
8870: f0 05     BEQ   $8877
8872: a9 80     LDA   #$80
8874: 9d 78 01  STA   $0178,X
8877: a9 00     LDA   #$00
8879: 9d 32 01  STA   $0132,X
887C: a9 00     LDA   #$00
887E: 9d 48 01  STA   $0148,X
8881: a8        TAY
8882: b1 e8     LDA   ($E8),Y
8884: c8        INY
8885: c9 30     CMP   #$30
8887: 90 07     BCC   $8890
8889: 88        DEY
888A: 8c 3e 01  STY   $013E
888D: 8c 3c 01  STY   $013C
8890: 98        TYA
8891: 9d 24 01  STA   $0124,X
8894: ad 22 01  LDA   $0122
8897: 9d 06 01  STA   $0106,X
889A: 8a        TXA
889B: c9 01     CMP   #$01
889D: 90 2f     BCC   $88CE
889F: e0 05     CPX   #$05
88A1: d0 05     BNE   $88A8
88A3: a9 0c     LDA   #$0C
88A5: 4c ac 88  JMP   $88AC
88A8: 0a        ASL
88A9: 0a        ASL
88AA: 29 0f     AND   #$0F
88AC: aa        TAX
88AD: a9 00     LDA   #$00
88AF: e0 08     CPX   #$08
88B1: f0 02     BEQ   $88B5
88B3: a9 30     LDA   #$30
88B5: 9d 00 40  STA   $4000,X
88B8: 20 0c 87  JSR   $870C
88BB: a9 7f     LDA   #$7F
88BD: 9d 01 40  STA   $4001,X
88C0: e6 eb     INC   $EB
88C2: c6 ea     DEC   $EA
88C4: 10 05     BPL   $88CB
88C6: 68        PLA
88C7: a8        TAY
88C8: 68        PLA
88C9: aa        TAX
88CA: 60        RTS
88CB: 4c 37 88  JMP   $8837
88CE: 09 04     ORA   #$04
88D0: a8        TAY
88D1: b9 06 01  LDA   $0106,Y
88D4: d0 ea     BNE   $88C0
88D6: 8a        TXA
88D7: 4c a8 88  JMP   $88A8
88DA: 38        SEC
88DB: e9 7f     SBC   #$7F
88DD: 8d 22 01  STA   $0122
88E0: 98        TYA
88E1: 48        PHA
88E2: ad 22 01  LDA   $0122
88E5: 0a        ASL
88E6: 0a        ASL
88E7: a8        TAY
88E8: b9 14 89  LDA   $8914,Y
88EB: 8d 35 01  STA   $0135
88EE: a9 0f     LDA   #$0F
88F0: 8d 15 40  STA   $4015
88F3: b9 13 89  LDA   $8913,Y
88F6: 8d 10 40  STA   $4010
88F9: b9 14 89  LDA   $8914,Y
88FC: 8d 11 40  STA   $4011
88FF: b9 15 89  LDA   $8915,Y
8902: 8d 12 40  STA   $4012
8905: b9 16 89  LDA   $8916,Y
8908: 8d 13 40  STA   $4013
890B: a9 1f     LDA   #$1F
890D: 8d 15 40  STA   $4015
8910: 68        PLA
8911: a8        TAY
8912: 60        RTS
8913: 0F        .byte $0F
8914: 2F        .byte $2F
8915: f0 05     BEQ   $891C
8917: 0F        .byte $0F
8918: 75 f3     ADC   $F3,X
891A: 25 0f     AND   $0F
891C: 7F        .byte $7F
891D: F3        .byte $F3
891E: 03        .byte $03
891F: 0F        .byte $0F
8920: 00        BRK
8921: F3        .byte $F3
8922: 25 03     AND   $03
8924: CB        .byte $CB
8925: 8a        TXA
8926: 05 a9     ORA   $A9
8928: 8a        TXA
8929: 18        CLC
892A: 47        .byte $47
892B: 92        .byte $92
892C: 01 47     ORA   ($47,X)
892E: 92        .byte $92
892F: 02        .byte $02
8930: 56 92     LSR   $92,X
8932: 05 61     ORA   $61
8934: 92        .byte $92
8935: 18        CLC
8936: 68        PLA
8937: 92        .byte $92
8938: 01 68     ORA   ($68,X)
893A: 92        .byte $92
893B: 02        .byte $02
893C: c4 92     CPY   $92
893E: 05 91     ORA   $91
8940: 92        .byte $92
8941: 0c cc 8a  NOP   $8ACC
8944: 05 dd     ORA   $DD
8946: 8a        TXA
8947: 04 e8     NOP   $E8
8949: 8a        TXA
894A: 0c 1f 8b  NOP   $8B1F
894D: 05 29     ORA   $29
894F: 8B        .byte $8B
8950: 14 37     NOP   $37
8952: 8B        .byte $8B
8953: 01 41     ORA   ($41,X)
8955: 8B        .byte $8B
8956: 05 48     ORA   $48
8958: 8B        .byte $8B
8959: 04 56     NOP   $56
895B: 8B        .byte $8B
895C: 0c ae 8b  NOP   $8BAE
895F: 01 ea     ORA   ($EA,X)
8961: 8B        .byte $8B
8962: 0c 22 8c  NOP   $8C22
8965: 01 59     ORA   ($59,X)
8967: 8c 00 95  STY   $9500
896A: 8B        .byte $8B
896B: 05 26     ORA   $26
896D: 8F        .byte $8F
896E: 0c 90 8c  NOP   $8C90
8971: 05 b9     ORA   $B9
8973: 8c 0c e2  STY   $E20C
8976: 8c 05 0f  STY   $0F05
8979: 8d 0c 36  STA   $360C
897C: 8d 05 63  STA   $6305
897F: 8d 1c 8a  STA   $8A1C
8982: 8d 01 a1  STA   $A101
8985: 8d 03 b5  STA   $B503
8988: 8d 05 bc  STA   $BC05
898B: 8d 0c fe  STA   $FE0C
898E: 8d 05 35  STA   $3505
8991: 8e 0c 98  STX   $980C
8994: 8e 05 ac  STX   $AC05
8997: 8e 0c be  STX   $BE0C
899A: 8e 05 cc  STX   $CC05
899D: 8e 04 5f  STX   $5F04
89A0: 8F        .byte $8F
89A1: 04 ee     NOP   $EE
89A3: 8F        .byte $8F
89A4: 0c 79 8f  NOP   $8F79
89A7: 05 9c     ORA   $9C
89A9: 8F        .byte $8F
89AA: 04 c1     NOP   $C1
89AC: 8F        .byte $8F
89AD: 04 d8     NOP   $D8
89AF: 8F        .byte $8F
89B0: 04 82     NOP   $82
89B2: 90 0c     BCC   $89C0
89B4: d4 90     NOP   $90
89B6: 05 4e     ORA   $4E
89B8: 91 04     STA   ($04),Y
89BA: 1B        .byte $1B
89BB: 90 0c     BCC   $89C9
89BD: 09 92     ORA   #$92
89BF: 05 2a     ORA   $2A
89C1: 92        .byte $92
89C2: 04 77     NOP   $77
89C4: 91 04     STA   ($04),Y
89C6: 8F        .byte $8F
89C7: 91 04     STA   ($04),Y
89C9: aa        TAX
89CA: 91 04     STA   ($04),Y
89CC: c1 91     CMP   ($91,X)
89CE: 14 57     NOP   $57
89D0: 96 01     STX   $01,Y
89D2: 57        .byte $57
89D3: 96 05     STX   $05,Y
89D5: 16 97     ASL   $97,X
89D7: 05 55     ORA   $55
89D9: 97        .byte $97
89DA: 05 94     ORA   $94
89DC: 97        .byte $97
89DD: 18        CLC
89DE: 71 99     ADC   ($99),Y
89E0: 01 87     ORA   ($87,X)
89E2: 99 02 9f  STA   $9F02,Y
89E5: 99 03 af  STA   $AF03,Y
89E8: 99 10 ef  STA   $EF10,Y
89EB: 99 01 61  STA   $6101,Y
89EE: 9a        TXS
89EF: 02        .byte $02
89F0: E2        .byte $E2
89F1: 9a        TXS
89F2: 18        CLC
89F3: 6c 9d 01  JMP   ($019D)
89F6: 92        .byte $92
89F7: 9B        .byte $9B
89F8: 02        .byte $02
89F9: 0B        .byte $0B
89FA: 9F        .byte $9F
89FB: 03        .byte $03
89FC: b9 a0 18  LDA   $18A0,Y
89FF: c9 a2     CMP   #$A2
8A01: 01 b5     ORA   ($B5,X)
8A03: A3        .byte $A3
8A04: 02        .byte $02
8A05: AB        .byte $AB
8A06: a4 03     LDY   $03
8A08: 12        .byte $12
8A09: a5 18     LDA   $18
8A0B: e8        INX
8A0C: a5 01     LDA   $01
8A0E: 76 a6     ROR   $A6,X
8A10: 02        .byte $02
8A11: de a6 03  DEC   $03A6,X
8A14: 62        .byte $62
8A15: A7        .byte $A7
8A16: 18        CLC
8A17: ec a7 01  CPX   $01A7
8A1A: 8a        TXA
8A1B: a8        TAY
8A1C: 02        .byte $02
8A1D: fc a8 03  NOP   $03A8
8A20: 47        .byte $47
8A21: a9 18     LDA   #$18
8A23: d6 a9     DEC   $A9,X
8A25: 01 eb     ORA   ($EB,X)
8A27: aa        TAX
8A28: 02        .byte $02
8A29: d9 ab 03  CMP   $03AB,Y
8A2C: 73        .byte $73
8A2D: ac 18 ac  LDY   $AC18
8A30: ad 01 b4  LDA   $B401
8A33: ae 02 2f  LDX   $2F02
8A36: AF        .byte $AF
8A37: 03        .byte $03
8A38: be af 18  LDX   $18AF,Y
8A3B: D7        .byte $D7
8A3C: b0 01     BCS   $8A3F
8A3E: bc b1 02  LDY   $02B1,X
8A41: 3F        .byte $3F
8A42: B2        .byte $B2
8A43: 03        .byte $03
8A44: 52        .byte $52
8A45: B3        .byte $B3
8A46: 18        CLC
8A47: d6 b3     DEC   $B3,X
8A49: 01 f7     ORA   ($F7,X)
8A4B: B3        .byte $B3
8A4C: 02        .byte $02
8A4D: 18        CLC
8A4E: b4 03     LDY   $03,X
8A50: 33        .byte $33
8A51: b4 18     LDY   $18,X
8A53: 48        PHA
8A54: b4 01     LDY   $01,X
8A56: 5e b4 02  LSR   $02B4,X
8A59: 75 b4     ADC   $B4,X
8A5B: 03        .byte $03
8A5C: 85 b4     STA   $B4
8A5E: 18        CLC
8A5F: 2c b6 01  BIT   $01B6
8A62: A7        .byte $A7
8A63: b6 02     LDX   $02,Y
8A65: 92        .byte $92
8A66: B7        .byte $B7
8A67: 03        .byte $03
8A68: 14 b8     NOP   $B8
8A6A: 18        CLC
8A6B: c0 b4     CPY   #$B4
8A6D: 01 e8     ORA   ($E8,X)
8A6F: b4 02     LDY   $02,X
8A71: 12        .byte $12
8A72: b5 03     LDA   $03,X
8A74: 3e b5 0c  ROL   $0CB5,X
8A77: F3        .byte $F3
8A78: 98        TYA
8A79: 05 46     ORA   $46
8A7B: 99 04 b1  STA   $B104,Y
8A7E: 8a        TXA
8A7F: 0c cf 97  NOP   $97CF
8A82: 05 e8     ORA   $E8
8A84: 97        .byte $97
8A85: 1c 27 98  NOP   $9827
8A88: 01 6f     ORA   ($6F,X)
8A8A: 98        TYA
8A8B: 03        .byte $03
8A8C: B3        .byte $B3
8A8D: 98        TYA
8A8E: 05 b8     ORA   $B8
8A90: 98        TYA
8A91: 1c 27 98  NOP   $9827
8A94: 01 6f     ORA   ($6F,X)
8A96: 98        TYA
8A97: 03        .byte $03
8A98: B3        .byte $B3
8A99: 98        TYA
8A9A: 05 b8     ORA   $B8
8A9C: 98        TYA
8A9D: 03        .byte $03
8A9E: CB        .byte $CB
8A9F: 8a        TXA
8AA0: 03        .byte $03
8AA1: CB        .byte $CB
8AA2: 8a        TXA
8AA3: 03        .byte $03
8AA4: CB        .byte $CB
8AA5: 8a        TXA
8AA6: 03        .byte $03
8AA7: CB        .byte $CB
8AA8: 8a        TXA
8AA9: 21 33     AND   ($33,X)
8AAB: 60        RTS
8AAC: 03        .byte $03
8AAD: f8        SED
8AAE: 20 02 ff  JSR   $FF02
8AB1: 25 82     AND   $82
8AB3: 00        BRK
8AB4: d5 00     CMP   $00,X
8AB6: 8e 00 a9  STX   $A900
8AB9: 22        .byte $22
8ABA: b0 e0     BCS   $8A9C
8ABC: 6a        ROR
8ABD: d0 6a     BNE   $8B29
8ABF: b0 6a     BCS   $8B2B
8AC1: a0 6a     LDY   #$6A
8AC3: 90 6a     BCC   $8B2F
8AC5: 70 6a     BVS   $8B31
8AC7: 50 6a     BVC   $8B33
8AC9: 40        RTI
8ACA: 6a        ROR
8ACB: FF        .byte $FF
8ACC: 21 30     AND   ($30,X)
8ACE: 40        RTI
8ACF: f0 00     BEQ   $8AD1
8AD1: 00        BRK
8AD2: 00        BRK
8AD3: 00        BRK
8AD4: 21 f0     AND   ($F0,X)
8AD6: f8        SED
8AD7: 20 0a f8  JSR   $F80A
8ADA: 10 0b     BPL   $8AE7
8ADC: FF        .byte $FF
8ADD: 21 0f     AND   ($0F,X)
8ADF: a0 0c     LDY   #$0C
8AE1: 00        BRK
8AE2: 00        BRK
8AE3: 23        .byte $23
8AE4: 30 30     BMI   $8B16
8AE6: 02        .byte $02
8AE7: FF        .byte $FF
8AE8: 21 70     AND   ($70,X)
8AEA: 10 83     BPL   $8A6F
8AEC: F3        .byte $F3
8AED: 8c f2 f6  STY   $F6F2
8AF0: F3        .byte $F3
8AF1: 15 73     ORA   $73,X
8AF3: 77        .byte $77
8AF4: D3        .byte $D3
8AF5: 8c 00 00  STY   $0000
8AF8: D3        .byte $D3
8AF9: 15 00     ORA   $00,X
8AFB: 00        BRK
8AFC: D3        .byte $D3
8AFD: 8c b3 45  STY   $45B3
8B00: 33        .byte $33
8B01: 11 b3     ORA   ($B3),Y
8B03: 50 73     BVC   $8B78
8B05: 33        .byte $33
8B06: b4 00     LDY   $00,X
8B08: 00        BRK
8B09: 00        BRK
8B0A: B2        .byte $B2
8B0B: dd 00 00  CMP   $0000,X
8B0E: 00        BRK
8B0F: 00        BRK
8B10: A3        .byte $A3
8B11: 50 00     BVC   $8B13
8B13: 00        BRK
8B14: 73        .byte $73
8B15: 22        .byte $22
8B16: 00        BRK
8B17: 00        BRK
8B18: 53        .byte $53
8B19: 50 00     BVC   $8B1B
8B1B: 00        BRK
8B1C: 32        .byte $32
8B1D: ee ff 26  INC   $26FF
8B20: 30 10     BMI   $8B32
8B22: 99 40 a9  STA   $A940,Y
8B25: f8        SED
8B26: 10 a9     BPL   $8AD1
8B28: FF        .byte $FF
8B29: 21 30     AND   ($30,X)
8B2B: f0 07     BEQ   $8B34
8B2D: 90 02     BCC   $8B31
8B2F: 70 07     BVS   $8B38
8B31: 50 02     BVC   $8B35
8B33: f8        SED
8B34: 20 02 ff  JSR   $FF02
8B37: 26 30     ROL   $30
8B39: 10 b9     BPL   $8AF4
8B3B: 30 b0     BMI   $8AED
8B3D: f8        SED
8B3E: 10 b0     BPL   $8AF0
8B40: FF        .byte $FF
8B41: 26 f0     ROL   $F0
8B43: 10 89     BPL   $8ACE
8B45: 30 b0     BMI   $8AF7
8B47: FF        .byte $FF
8B48: 21 30     AND   ($30,X)
8B4A: f0 07     BEQ   $8B53
8B4C: 90 02     BCC   $8B50
8B4E: 70 07     BVS   $8B57
8B50: 50 02     BVC   $8B54
8B52: f8        SED
8B53: 20 02 ff  JSR   $FF02
8B56: 21 30     AND   ($30,X)
8B58: 10 8a     BPL   $8AE4
8B5A: f8        SED
8B5B: 21 02     AND   ($02,X)
8B5D: 30 f1     BMI   $8B50
8B5F: 40        RTI
8B60: e0 50     CPX   #$50
8B62: d0 60     BNE   $8BC4
8B64: c1 60     CMP   ($60,X)
8B66: B2        .byte $B2
8B67: 60        RTS
8B68: A3        .byte $A3
8B69: 60        RTS
8B6A: 95 60     STA   $60,X
8B6C: 87        .byte $87
8B6D: 60        RTS
8B6E: 79 60 6b  ADC   $6B60,Y
8B71: 60        RTS
8B72: 5e 60 51  LSR   $5160,X
8B75: 70 4e     BVS   $8BC5
8B77: 80 4b     NOP   $4B
8B79: 90 49     BCC   $8BC4
8B7B: a0 46     LDY   #$46
8B7D: f8        SED
8B7E: 10 79     BPL   $8BF9
8B80: f8        SED
8B81: 10 6b     BPL   $8BEE
8B83: f8        SED
8B84: 10 5e     BPL   $8BE4
8B86: f8        SED
8B87: 10 51     BPL   $8BDA
8B89: f8        SED
8B8A: 10 4e     BPL   $8BDA
8B8C: f8        SED
8B8D: 20 4b f8  JSR   $F84B
8B90: 20 49 30  JSR   $3049
8B93: 46 ff     LSR   $FF
8B95: 24 30     BIT   $30
8B97: 60        RTS
8B98: b4 00     LDY   $00,X
8B9A: 00        BRK
8B9B: 60        RTS
8B9C: d6 f8     DEC   $F8,X
8B9E: 20 b4 00  JSR   $00B4
8BA1: 00        BRK
8BA2: f8        SED
8BA3: 20 d6 f8  JSR   $F8D6
8BA6: 10 b4     BPL   $8B5C
8BA8: 00        BRK
8BA9: 00        BRK
8BAA: f8        SED
8BAB: 10 d6     BPL   $8B83
8BAD: FF        .byte $FF
8BAE: 29 b0     AND   #$B0
8BB0: 00        BRK
8BB1: 00        BRK
8BB2: 21 b0     AND   ($B0,X)
8BB4: f8        SED
8BB5: 12        .byte $12
8BB6: c0 f8     CPY   #$F8
8BB8: 22        .byte $22
8BB9: 91 32     STA   ($32),Y
8BBB: 68        PLA
8BBC: 42        .byte $42
8BBD: 40        RTI
8BBE: 52        .byte $52
8BBF: 20 52 00  JSR   $0052
8BC2: 51 e8     EOR   ($E8),Y
8BC4: 51 d0     EOR   ($D0),Y
8BC6: 51 c0     EOR   ($C0),Y
8BC8: 51 b4     EOR   ($B4),Y
8BCA: 2F        .byte $2F
8BCB: b0 51     BCS   $8C1E
8BCD: b0 51     BCS   $8C20
8BCF: b0 51     BCS   $8C22
8BD1: b0 51     BCS   $8C24
8BD3: b0 26     BCS   $8BFB
8BD5: b0 51     BCS   $8C28
8BD7: b0 51     BCS   $8C2A
8BD9: b0 41     BCS   $8C1C
8BDB: b0 31     BCS   $8C0E
8BDD: b0 31     BCS   $8C10
8BDF: b0 f8     BCS   $8BD9
8BE1: 21 b0     AND   ($B0,X)
8BE3: f8        SED
8BE4: 11 b0     ORA   ($B0),Y
8BE6: fe ff b2  INC   $B2FF,X
8BE9: 8B        .byte $8B
8BEA: 21 b0     AND   ($B0,X)
8BEC: f8        SED
8BED: 12        .byte $12
8BEE: c0 f8     CPY   #$F8
8BF0: 22        .byte $22
8BF1: 91 32     STA   ($32),Y
8BF3: 68        PLA
8BF4: 42        .byte $42
8BF5: 40        RTI
8BF6: 52        .byte $52
8BF7: 20 52 00  JSR   $0052
8BFA: 51 e8     EOR   ($E8),Y
8BFC: 51 d0     EOR   ($D0),Y
8BFE: 51 c0     EOR   ($C0),Y
8C00: 51 b4     EOR   ($B4),Y
8C02: 2F        .byte $2F
8C03: b0 51     BCS   $8C56
8C05: AB        .byte $AB
8C06: 51 ab     EOR   ($AB),Y
8C08: 51 ab     EOR   ($AB),Y
8C0A: 51 ab     EOR   ($AB),Y
8C0C: 26 b0     ROL   $B0
8C0E: 51 ab     EOR   ($AB),Y
8C10: 51 ab     EOR   ($AB),Y
8C12: 41 ab     EOR   ($AB,X)
8C14: 31 ab     AND   ($AB),Y
8C16: 31 ab     AND   ($AB),Y
8C18: f8        SED
8C19: 21 ab     AND   ($AB,X)
8C1B: f8        SED
8C1C: 11 ab     ORA   ($AB),Y
8C1E: fe ff ea  INC   $EAFF,X
8C21: 8B        .byte $8B
8C22: 23        .byte $23
8C23: b0 b1     BCS   $8BD6
8C25: 00        BRK
8C26: 00        BRK
8C27: 00        BRK
8C28: b0 80     BCS   $8BAA
8C2A: 00        BRK
8C2B: 00        BRK
8C2C: b0 40     BCS   $8C6E
8C2E: 51 00     EOR   ($00),Y
8C30: b0 20     BCS   $8C52
8C32: 50 80     BVC   $8BB4
8C34: 00        BRK
8C35: 00        BRK
8C36: 50 40     BVC   $8C78
8C38: f8        SED
8C39: 21 00     AND   ($00,X)
8C3B: 50 20     BVC   $8C5D
8C3D: f8        SED
8C3E: 20 80 00  JSR   $0080
8C41: 00        BRK
8C42: f8        SED
8C43: 20 40 f8  JSR   $F840
8C46: 11 00     ORA   ($00),Y
8C48: f8        SED
8C49: 20 20 f8  JSR   $F820
8C4C: 10 80     BPL   $8BCE
8C4E: 00        BRK
8C4F: 00        BRK
8C50: f8        SED
8C51: 10 40     BPL   $8C93
8C53: 00        BRK
8C54: 00        BRK
8C55: f8        SED
8C56: 10 20     BPL   $8C78
8C58: FF        .byte $FF
8C59: 23        .byte $23
8C5A: b0 b1     BCS   $8C0D
8C5C: 80 00     NOP   $00
8C5E: 00        BRK
8C5F: b0 c0     BCS   $8C21
8C61: 00        BRK
8C62: 00        BRK
8C63: b0 60     BCS   $8CC5
8C65: 51 80     EOR   ($80),Y
8C67: b0 30     BCS   $8C99
8C69: 50 c0     BVC   $8C2B
8C6B: 00        BRK
8C6C: 00        BRK
8C6D: 50 60     BVC   $8CCF
8C6F: f8        SED
8C70: 21 80     AND   ($80,X)
8C72: 50 30     BVC   $8CA4
8C74: f8        SED
8C75: 20 c0 00  JSR   $00C0
8C78: 00        BRK
8C79: f8        SED
8C7A: 20 60 f8  JSR   $F860
8C7D: 11 80     ORA   ($80),Y
8C7F: f8        SED
8C80: 20 30 f8  JSR   $F830
8C83: 10 c0     BPL   $8C45
8C85: 00        BRK
8C86: 00        BRK
8C87: f8        SED
8C88: 10 60     BPL   $8CEA
8C8A: 00        BRK
8C8B: 00        BRK
8C8C: f8        SED
8C8D: 10 30     BPL   $8CBF
8C8F: FF        .byte $FF
8C90: 25 70     AND   $70
8C92: 10 83     BPL   $8C17
8C94: D2        .byte $D2
8C95: 86 b0     STX   $B0
8C97: c0 21     CPY   #$21
8C99: f0 a0     BEQ   $8C3B
8C9B: 09 25     ORA   #$25
8C9D: 70 60     BVS   $8CFF
8C9F: F2        .byte $F2
8CA0: 21 f0     AND   ($F0,X)
8CA2: a0 0a     LDY   #$0A
8CA4: 25 70     AND   $70
8CA6: 51 2b     EOR   ($2B),Y
8CA8: 41 76     EOR   ($76,X)
8CAA: 31 d3     AND   ($D3),Y
8CAC: f8        SED
8CAD: 22        .byte $22
8CAE: 44 f8     NOP   $F8
8CB0: 12        .byte $12
8CB1: dd f8 13  CMP   $13F8,X
8CB4: 99 f8 14  STA   $14F8,Y
8CB7: 7e ff 21  ROR   $21FF,X
8CBA: 30 f0     BMI   $8CAC
8CBC: 09 d0     ORA   #$D0
8CBE: 0e f8 20  ASL   $20F8
8CC1: 0a        ASL
8CC2: f8        SED
8CC3: 20 09 00  JSR   $0009
8CC6: 00        BRK
8CC7: fe 02 b9  INC   $B902,X
8CCA: 8c 23 30  STY   $3023
8CCD: 70 0b     BVS   $8CDA
8CCF: f8        SED
8CD0: 20 0e 30  JSR   $300E
8CD3: 0e f8 20  ASL   $20F8
8CD6: 0B        .byte $0B
8CD7: 00        BRK
8CD8: 00        BRK
8CD9: 30 0a     BMI   $8CE5
8CDB: f8        SED
8CDC: 20 0d f8  JSR   $F80D
8CDF: 10 0b     BPL   $8CEC
8CE1: FF        .byte $FF
8CE2: 21 f0     AND   ($F0,X)
8CE4: 10 83     BPL   $8C69
8CE6: C2        .byte $C2
8CE7: 3B        .byte $3B
8CE8: 81 0d     STA   ($0D,X)
8CEA: 71 c5     ADC   ($C5),Y
8CEC: c0 08     CPY   #$08
8CEE: fe 02 e2  INC   $E202,X
8CF1: 8c 25 f0  STY   $F025
8CF4: 60        RTS
8CF5: F2        .byte $F2
8CF6: 21 f0     AND   ($F0,X)
8CF8: b0 08     BCS   $8D02
8CFA: 25 f0     AND   $F0
8CFC: 51 2b     EOR   ($2B),Y
8CFE: 41 76     EOR   ($76,X)
8D00: 31 d3     AND   ($D3),Y
8D02: f8        SED
8D03: 22        .byte $22
8D04: 44 f8     NOP   $F8
8D06: 12        .byte $12
8D07: dd f8 13  CMP   $13F8,X
8D0A: 99 f8 14  STA   $14F8,Y
8D0D: 7e ff 21  ROR   $21FF,X
8D10: 30 f0     BMI   $8D02
8D12: 09 d0     ORA   #$D0
8D14: 0e f8 20  ASL   $20F8
8D17: 0a        ASL
8D18: f8        SED
8D19: 10 09     BPL   $8D24
8D1B: fe 02 0f  INC   $0F02,X
8D1E: 8d 23 30  STA   $3023
8D21: 70 0b     BVS   $8D2E
8D23: f8        SED
8D24: 20 0e 30  JSR   $300E
8D27: 0e f8 20  ASL   $20F8
8D2A: 0B        .byte $0B
8D2B: 00        BRK
8D2C: 00        BRK
8D2D: 30 0a     BMI   $8D39
8D2F: f8        SED
8D30: 20 0d f8  JSR   $F80D
8D33: 10 0b     BPL   $8D40
8D35: FF        .byte $FF
8D36: 21 f0     AND   ($F0,X)
8D38: 10 83     BPL   $8CBD
8D3A: C2        .byte $C2
8D3B: 3B        .byte $3B
8D3C: 81 0d     STA   ($0D,X)
8D3E: 71 c5     ADC   ($C5),Y
8D40: c0 08     CPY   #$08
8D42: fe 0a 36  INC   $360A,X
8D45: 8d 25 f0  STA   $F025
8D48: 60        RTS
8D49: F2        .byte $F2
8D4A: 21 f0     AND   ($F0,X)
8D4C: b0 08     BCS   $8D56
8D4E: 25 f0     AND   $F0
8D50: 51 2b     EOR   ($2B),Y
8D52: 41 76     EOR   ($76,X)
8D54: 31 d3     AND   ($D3),Y
8D56: f8        SED
8D57: 22        .byte $22
8D58: 44 f8     NOP   $F8
8D5A: 12        .byte $12
8D5B: dd f8 13  CMP   $13F8,X
8D5E: 99 f8 14  STA   $14F8,Y
8D61: 7e ff 21  ROR   $21FF,X
8D64: 30 f0     BMI   $8D56
8D66: 09 d0     ORA   #$D0
8D68: 0e f8 20  ASL   $20F8
8D6B: 0a        ASL
8D6C: f8        SED
8D6D: 10 09     BPL   $8D78
8D6F: fe 0a 63  INC   $630A,X
8D72: 8d 23 30  STA   $3023
8D75: 70 0b     BVS   $8D82
8D77: f8        SED
8D78: 20 0e 30  JSR   $300E
8D7B: 0e f8 20  ASL   $20F8
8D7E: 0B        .byte $0B
8D7F: 00        BRK
8D80: 00        BRK
8D81: 30 0a     BMI   $8D8D
8D83: f8        SED
8D84: 20 0d f8  JSR   $F80D
8D87: 10 0b     BPL   $8D94
8D89: FF        .byte $FF
8D8A: 21 30     AND   ($30,X)
8D8C: 10 83     BPL   $8D11
8D8E: 00        BRK
8D8F: 00        BRK
8D90: f1 3b     SBC   ($3B),Y
8D92: 31 0d     AND   ($0D),Y
8D94: f8        SED
8D95: 21 c5     AND   ($C5,X)
8D97: 00        BRK
8D98: 00        BRK
8D99: fe 30 90  INC   $9030,X
8D9C: 8d fd e3  STA   $E3FD
8D9F: 8d ff 21  STA   $21FF
8DA2: f0 10     BEQ   $8DB4
8DA4: 83        .byte $83
8DA5: F2        .byte $F2
8DA6: 3B        .byte $3B
8DA7: 61 0d     ADC   ($0D,X)
8DA9: 51 c5     EOR   ($C5),Y
8DAB: c0 09     CPY   #$09
8DAD: fe 30 a5  INC   $A530,X
8DB0: 8d fd e3  STA   $E3FD
8DB3: 8d ff d4  STA   $D4FF
8DB6: 60        RTS
8DB7: fe 30 b6  INC   $B630,X
8DBA: 8d ff 21  STA   $21FF
8DBD: 30 f0     BMI   $8DAF
8DBF: 08        PHP
8DC0: a0 0b     LDY   #$0B
8DC2: f8        SED
8DC3: 20 0a f8  JSR   $F80A
8DC6: 10 09     BPL   $8DD1
8DC8: fe 30 be  INC   $BE30,X
8DCB: 8d 23 30  STA   $3023
8DCE: 70 0b     BVS   $8DDB
8DD0: f8        SED
8DD1: 20 0e 30  JSR   $300E
8DD4: 0e f8 20  ASL   $20F8
8DD7: 0B        .byte $0B
8DD8: 00        BRK
8DD9: 00        BRK
8DDA: 30 0a     BMI   $8DE6
8DDC: f8        SED
8DDD: 20 0d f8  JSR   $F80D
8DE0: 10 0b     BPL   $8DED
8DE2: FF        .byte $FF
8DE3: 25 f0     AND   $F0
8DE5: 60        RTS
8DE6: F2        .byte $F2
8DE7: 21 f0     AND   ($F0,X)
8DE9: b0 08     BCS   $8DF3
8DEB: 25 f0     AND   $F0
8DED: 71 2b     ADC   ($2B),Y
8DEF: 61 76     ADC   ($76,X)
8DF1: 51 d3     EOR   ($D3),Y
8DF3: 42        .byte $42
8DF4: 44 32     NOP   $32
8DF6: dd f8 23  CMP   $23F8,X
8DF9: 99 f8 14  STA   $14F8,Y
8DFC: 7e ff 22  ROR   $22FF,X
8DFF: 30 10     BMI   $8E11
8E01: 83        .byte $83
8E02: 30 39     BMI   $8E3D
8E04: 40        RTI
8E05: 40        RTI
8E06: 50 47     BVC   $8E4F
8E08: 60        RTS
8E09: 50 70     BVC   $8E7B
8E0B: 5a        NOP
8E0C: 80 65     NOP   $65
8E0E: 90 71     BCC   $8E81
8E10: a0 7f     LDY   #$7F
8E12: a0 8f     LDY   #$8F
8E14: 90 a0     BCC   $8DB6
8E16: 90 b4     BCC   $8DCC
8E18: 80 ca     NOP   $CA
8E1A: 80 e2     NOP   $E2
8E1C: 80 fe     NOP   $FE
8E1E: 81 1d     STA   ($1D,X)
8E20: 71 40     ADC   ($40),Y
8E22: 71 68     ADC   ($68),Y
8E24: 61 94     ADC   ($94,X)
8E26: 61 c5     ADC   ($C5,X)
8E28: 61 fc     ADC   ($FC,X)
8E2A: 62        .byte $62
8E2B: 36 62     ROL   $62,X
8E2D: 81 52     STA   ($52,X)
8E2F: CF        .byte $CF
8E30: 53        .byte $53
8E31: 27        .byte $27
8E32: 53        .byte $53
8E33: 8a        TXA
8E34: FF        .byte $FF
8E35: 21 30     AND   ($30,X)
8E37: 30 0b     BMI   $8E44
8E39: 40        RTI
8E3A: 0a        ASL
8E3B: 50 09     BVC   $8E46
8E3D: 60        RTS
8E3E: 08        PHP
8E3F: 70 07     BVS   $8E48
8E41: 70 06     BVS   $8E49
8E43: 80 06     NOP   $06
8E45: 80 06     NOP   $06
8E47: 80 06     NOP   $06
8E49: 80 06     NOP   $06
8E4B: 80 06     NOP   $06
8E4D: 80 06     NOP   $06
8E4F: 80 07     NOP   $07
8E51: 80 06     NOP   $06
8E53: 80 07     NOP   $07
8E55: 80 07     NOP   $07
8E57: 80 08     NOP   $08
8E59: 80 07     NOP   $07
8E5B: 80 08     NOP   $08
8E5D: 80 08     NOP   $08
8E5F: 80 09     NOP   $09
8E61: 80 08     NOP   $08
8E63: 80 09     NOP   $09
8E65: 80 09     NOP   $09
8E67: 80 0a     NOP   $0A
8E69: 70 09     BVS   $8E74
8E6B: 70 0a     BVS   $8E77
8E6D: 70 0a     BVS   $8E79
8E6F: 70 0b     BVS   $8E7C
8E71: 70 0a     BVS   $8E7D
8E73: 70 0b     BVS   $8E80
8E75: 70 0b     BVS   $8E82
8E77: 70 0c     BVS   $8E85
8E79: 70 0b     BVS   $8E86
8E7B: 70 0c     BVS   $8E89
8E7D: 70 0c     BVS   $8E8B
8E7F: 60        RTS
8E80: 0d 60 0c  ORA   $0C60
8E83: 60        RTS
8E84: 0d 60 0d  ORA   $0D60
8E87: 50 0e     BVC   $8E97
8E89: 50 0d     BVC   $8E98
8E8B: 50 0e     BVC   $8E9B
8E8D: 50 0e     BVC   $8E9D
8E8F: 50 0e     BVC   $8E9F
8E91: 50 0e     BVC   $8EA1
8E93: 40        RTI
8E94: 0e 40 0e  ASL   $0E40
8E97: FF        .byte $FF
8E98: 23        .byte $23
8E99: f0 10     BEQ   $8EAB
8E9B: 82        .byte $82
8E9C: b0 35     BCS   $8ED3
8E9E: 90 50     BCC   $8EF0
8EA0: 70 78     BVS   $8F1A
8EA2: fe 03 98  INC   $9803,X
8EA5: 8e 30 b4  STX   $B430
8EA8: f8        SED
8EA9: 21 0d     AND   ($0D,X)
8EAB: FF        .byte $FF
8EAC: 23        .byte $23
8EAD: 30 40     BMI   $8EEF
8EAF: 06 50     ASL   $50
8EB1: 08        PHP
8EB2: 60        RTS
8EB3: 0a        ASL
8EB4: fe 03 ac  INC   $AC03,X
8EB7: 8e 30 0c  STX   $0C30
8EBA: f8        SED
8EBB: 10 0d     BPL   $8ECA
8EBD: FF        .byte $FF
8EBE: 2a        ROL
8EBF: 30 10     BMI   $8ED1
8EC1: 8B        .byte $8B
8EC2: B2        .byte $B2
8EC3: 66 72     ROR   $72
8EC5: 66 32     ROR   $32
8EC7: 66 f8     ROR   $F8
8EC9: 12        .byte $12
8ECA: 66 ff     ROR   $FF
8ECC: 21 30     AND   ($30,X)
8ECE: b0 0e     BCS   $8EDE
8ED0: b0 0d     BCS   $8EDF
8ED2: b0 0c     BCS   $8EE0
8ED4: b0 0b     BCS   $8EE1
8ED6: b0 0a     BCS   $8EE2
8ED8: b0 09     BCS   $8EE3
8EDA: b0 08     BCS   $8EE4
8EDC: b0 07     BCS   $8EE5
8EDE: b0 06     BCS   $8EE6
8EE0: b0 05     BCS   $8EE7
8EE2: 70 0e     BVS   $8EF2
8EE4: 70 0d     BVS   $8EF3
8EE6: 70 0c     BVS   $8EF4
8EE8: 70 0b     BVS   $8EF5
8EEA: 70 0a     BVS   $8EF6
8EEC: 70 09     BVS   $8EF7
8EEE: 70 08     BVS   $8EF8
8EF0: 70 07     BVS   $8EF9
8EF2: 70 06     BVS   $8EFA
8EF4: 70 05     BVS   $8EFB
8EF6: 30 0e     BMI   $8F06
8EF8: 30 0d     BMI   $8F07
8EFA: 30 0c     BMI   $8F08
8EFC: 30 0b     BMI   $8F09
8EFE: 30 0a     BMI   $8F0A
8F00: 30 09     BMI   $8F0B
8F02: 30 08     BMI   $8F0C
8F04: 30 07     BMI   $8F0D
8F06: 30 06     BMI   $8F0E
8F08: 30 05     BMI   $8F0F
8F0A: f8        SED
8F0B: 10 0e     BPL   $8F1B
8F0D: f8        SED
8F0E: 10 0d     BPL   $8F1D
8F10: f8        SED
8F11: 10 0c     BPL   $8F1F
8F13: f8        SED
8F14: 10 0b     BPL   $8F21
8F16: f8        SED
8F17: 10 0a     BPL   $8F23
8F19: f8        SED
8F1A: 10 09     BPL   $8F25
8F1C: f8        SED
8F1D: 10 08     BPL   $8F27
8F1F: f8        SED
8F20: 10 07     BPL   $8F29
8F22: f8        SED
8F23: 10 06     BPL   $8F2B
8F25: FF        .byte $FF
8F26: 22        .byte $22
8F27: 30 f0     BMI   $8F19
8F29: 0e f0 0d  ASL   $0DF0
8F2C: f0 0c     BEQ   $8F3A
8F2E: a0 07     LDY   #$07
8F30: a0 08     LDY   #$08
8F32: b0 09     BCS   $8F3D
8F34: c0 0a     CPY   #$0A
8F36: c0 0b     CPY   #$0B
8F38: c0 0c     CPY   #$0C
8F3A: c0 0d     CPY   #$0D
8F3C: 23        .byte $23
8F3D: 30 f0     BMI   $8F2F
8F3F: 0e e0 0e  ASL   $0EE0
8F42: d0 0e     BNE   $8F52
8F44: c0 0e     CPY   #$0E
8F46: b0 0e     BCS   $8F56
8F48: a0 0e     LDY   #$0E
8F4A: 90 0e     BCC   $8F5A
8F4C: 80 0e     NOP   $0E
8F4E: 70 0e     BVS   $8F5E
8F50: 60        RTS
8F51: 0e 50 0e  ASL   $0E50
8F54: 40        RTI
8F55: 0e 30 0e  ASL   $0E30
8F58: f8        SED
8F59: 20 0e f8  JSR   $F80E
8F5C: 10 0e     BPL   $8F6C
8F5E: FF        .byte $FF
8F5F: 21 30     AND   ($30,X)
8F61: 90 20     BCC   $8F83
8F63: c0 08     CPY   #$08
8F65: 60        RTS
8F66: 80 fe     NOP   $FE
8F68: 02        .byte $02
8F69: 5F        .byte $5F
8F6A: 8F        .byte $8F
8F6B: 30 20     BMI   $8F8D
8F6D: 24 30     BIT   $30
8F6F: 30 80     BMI   $8EF1
8F71: 30 20     BMI   $8F93
8F73: 50 08     BVC   $8F7D
8F75: f8        SED
8F76: 10 80     BPL   $8EF8
8F78: FF        .byte $FF
8F79: 23        .byte $23
8F7A: f0 10     BEQ   $8F8C
8F7C: 82        .byte $82
8F7D: b0 33     BCS   $8FB2
8F7F: 22        .byte $22
8F80: 30 10     BMI   $8F92
8F82: 8e b0 66  STX   $66B0
8F85: 70 5a     BVS   $8FE1
8F87: 50 50     BVC   $8FD9
8F89: 40        RTI
8F8A: 48        PHA
8F8B: 30 40     BMI   $8FCD
8F8D: 30 3f     BMI   $8FCE
8F8F: f8        SED
8F90: 20 3f f8  JSR   $F83F
8F93: 20 3f f8  JSR   $F83F
8F96: 10 3f     BPL   $8FD7
8F98: f8        SED
8F99: 10 3f     BPL   $8FDA
8F9B: FF        .byte $FF
8F9C: 21 30     AND   ($30,X)
8F9E: d0 0b     BNE   $8FAB
8FA0: 50 0a     BVC   $8FAC
8FA2: 30 09     BMI   $8FAD
8FA4: 70 0a     BVS   $8FB0
8FA6: 50 09     BVC   $8FB1
8FA8: 50 09     BVC   $8FB3
8FAA: 40        RTI
8FAB: 0a        ASL
8FAC: 40        RTI
8FAD: 0B        .byte $0B
8FAE: 30 0b     BMI   $8FBB
8FB0: 40        RTI
8FB1: 0B        .byte $0B
8FB2: 30 0b     BMI   $8FBF
8FB4: f8        SED
8FB5: 20 0b f8  JSR   $F80B
8FB8: 20 0b f8  JSR   $F80B
8FBB: 10 0b     BPL   $8FC8
8FBD: f8        SED
8FBE: 10 0a     BPL   $8FCA
8FC0: FF        .byte $FF
8FC1: 21 30     AND   ($30,X)
8FC3: 10 81     BPL   $8F46
8FC5: f0 59     BEQ   $9020
8FC7: 24 f0     BIT   $F0
8FC9: 10 82     BPL   $8F4D
8FCB: f0 fe     BEQ   $8FCB
8FCD: c0 35     CPY   #$35
8FCF: 90 59     BCC   $902A
8FD1: 70 d5     BVS   $8FA8
8FD3: 51 59     EOR   ($59),Y
8FD5: 31 7f     AND   ($7F),Y
8FD7: FF        .byte $FF
8FD8: 28        PLP
8FD9: b0 10     BCS   $8FEB
8FDB: 83        .byte $83
8FDC: f1 0d     SBC   ($0D),Y
8FDE: 28        PLP
8FDF: f0 10     BEQ   $8FF1
8FE1: 82        .byte $82
8FE2: f0 fe     BEQ   $8FE2
8FE4: c0 d5     CPY   #$D5
8FE6: 50 b3     BVC   $8F9B
8FE8: 30 a0     BMI   $8F8A
8FEA: f8        SED
8FEB: 10 a0     BPL   $8F8D
8FED: FF        .byte $FF
8FEE: 23        .byte $23
8FEF: b0 10     BCS   $9001
8FF1: 82        .byte $82
8FF2: F2        .byte $F2
8FF3: 70 00     BVS   $8FF5
8FF5: 00        BRK
8FF6: 23        .byte $23
8FF7: b0 f1     BCS   $8FEA
8FF9: AB        .byte $AB
8FFA: f1 67     SBC   ($67),Y
8FFC: e1 ab     SBC   ($AB,X)
8FFE: d1 67     CMP   ($67),Y
9000: c1 ab     CMP   ($AB,X)
9002: b1 67     LDA   ($67),Y
9004: a1 ab     LDA   ($AB,X)
9006: 91 67     STA   ($67),Y
9008: 81 ab     STA   ($AB,X)
900A: 71 67     ADC   ($67),Y
900C: 61 ab     ADC   ($AB,X)
900E: 51 67     EOR   ($67),Y
9010: 41 ab     EOR   ($AB,X)
9012: 31 67     AND   ($67),Y
9014: f8        SED
9015: 21 ab     AND   ($AB,X)
9017: f8        SED
9018: 11 67     ORA   ($67),Y
901A: FF        .byte $FF
901B: 21 b0     AND   ($B0,X)
901D: 00        BRK
901E: 00        BRK
901F: fd 29 90  SBC   $9029,X
9022: fd 29 90  SBC   $9029,X
9025: fd 29 90  SBC   $9029,X
9028: FF        .byte $FF
9029: 21 f0     AND   ($F0,X)
902B: 10 85     BPL   $8FB2
902D: f8        SED
902E: 12        .byte $12
902F: D7        .byte $D7
9030: f8        SED
9031: 22        .byte $22
9032: B7        .byte $B7
9033: 32        .byte $32
9034: 97        .byte $97
9035: 42        .byte $42
9036: 77        .byte $77
9037: 52        .byte $52
9038: 57        .byte $57
9039: 62        .byte $62
903A: 37        .byte $37
903B: 72        .byte $72
903C: 17        .byte $17
903D: 81 f7     STA   ($F7,X)
903F: 91 d7     STA   ($D7),Y
9041: a1 b7     LDA   ($B7,X)
9043: b1 97     LDA   ($97),Y
9045: c1 77     CMP   ($77,X)
9047: d1 57     CMP   ($57),Y
9049: d1 47     CMP   ($47),Y
904B: d1 3f     CMP   ($3F),Y
904D: d1 3b     CMP   ($3B),Y
904F: d1 37     CMP   ($37),Y
9051: 10 86     BPL   $8FD9
9053: e1 3a     SBC   ($3A,X)
9055: a1 3b     LDA   ($3B,X)
9057: fe 0c 53  INC   $530C,X
905A: 90 b1     BCC   $900D
905C: 37        .byte $37
905D: b1 37     LDA   ($37),Y
905F: a1 37     LDA   ($37,X)
9061: a1 37     LDA   ($37,X)
9063: 51 37     EOR   ($37),Y
9065: 24 f0     BIT   $F0
9067: 10 82     BPL   $8FEB
9069: b1 37     LDA   ($37),Y
906B: b1 37     LDA   ($37),Y
906D: 71 37     ADC   ($37),Y
906F: 71 37     ADC   ($37),Y
9071: 31 37     AND   ($37),Y
9073: 31 37     AND   ($37),Y
9075: f8        SED
9076: 11 37     ORA   ($37),Y
9078: f8        SED
9079: 11 37     ORA   ($37),Y
907B: f8        SED
907C: 11 37     ORA   ($37),Y
907E: f8        SED
907F: 11 37     ORA   ($37),Y
9081: FF        .byte $FF
9082: 23        .byte $23
9083: f0 f8     BEQ   $907D
9085: 10 1f     BPL   $90A6
9087: f8        SED
9088: 20 20 30  JSR   $3020
908B: 21 40     AND   ($40,X)
908D: 22        .byte $22
908E: 50 23     BVC   $90B3
9090: 60        RTS
9091: 24 70     BIT   $70
9093: 25 80     AND   $80
9095: 26 90     ROL   $90
9097: 27        .byte $27
9098: a0 28     LDY   #$28
909A: a0 29     LDY   #$29
909C: a0 2a     LDY   #$2A
909E: 90 2b     BCC   $90CB
90A0: 90 2c     BCC   $90CE
90A2: 90 2d     BCC   $90D1
90A4: 80 2e     NOP   $2E
90A6: 80 2f     NOP   $2F
90A8: 80 30     NOP   $30
90AA: 70 31     BVS   $90DD
90AC: 70 32     BVS   $90E0
90AE: 70 33     BVS   $90E3
90B0: 60        RTS
90B1: 34 60     NOP   $60
90B3: 35 60     AND   $60,X
90B5: 36 50     ROL   $50,X
90B7: 37        .byte $37
90B8: 50 38     BVC   $90F2
90BA: 50 39     BVC   $90F5
90BC: 40        RTI
90BD: 3a        NOP
90BE: 40        RTI
90BF: 3B        .byte $3B
90C0: 40        RTI
90C1: 3c 30 3d  NOP   $3D30
90C4: 30 3e     BMI   $9104
90C6: 30 3f     BMI   $9107
90C8: 30 40     BMI   $910A
90CA: f8        SED
90CB: 20 41 f8  JSR   $F841
90CE: 20 42 f8  JSR   $F842
90D1: 20 43 ff  JSR   $FF43
90D4: 22        .byte $22
90D5: 30 f8     BMI   $90CF
90D7: 20 e0 f8  JSR   $F8E0
90DA: 20 e2 30  JSR   $30E2
90DD: e4 30     CPX   $30
90DF: e6 40     INC   $40
90E1: e8        INX
90E2: 40        RTI
90E3: ea        NOP
90E4: 50 ec     BVC   $90D2
90E6: 50 ee     BVC   $90D6
90E8: 60        RTS
90E9: f0 60     BEQ   $914B
90EB: F2        .byte $F2
90EC: 70 f4     BVS   $90E2
90EE: 70 f6     BVS   $90E6
90F0: 70 f8     BVS   $90EA
90F2: 70 fa     BVS   $90EE
90F4: 70 fc     BVS   $90F2
90F6: 70 fe     BVS   $90F6
90F8: 71 00     ADC   ($00),Y
90FA: 71 02     ADC   ($02),Y
90FC: 71 04     ADC   ($04),Y
90FE: 71 06     ADC   ($06),Y
9100: 71 08     ADC   ($08),Y
9102: 71 0a     ADC   ($0A),Y
9104: 71 0c     ADC   ($0C),Y
9106: 71 0e     ADC   ($0E),Y
9108: 71 10     ADC   ($10),Y
910A: 71 12     ADC   ($12),Y
910C: 71 14     ADC   ($14),Y
910E: 71 16     ADC   ($16),Y
9110: 71 18     ADC   ($18),Y
9112: 71 1a     ADC   ($1A),Y
9114: 71 1c     ADC   ($1C),Y
9116: 71 1e     ADC   ($1E),Y
9118: 71 20     ADC   ($20),Y
911A: 71 22     ADC   ($22),Y
911C: 71 24     ADC   ($24),Y
911E: 71 26     ADC   ($26),Y
9120: 61 28     ADC   ($28,X)
9122: 61 2a     ADC   ($2A,X)
9124: 61 2c     ADC   ($2C,X)
9126: 61 2e     ADC   ($2E,X)
9128: 51 30     EOR   ($30),Y
912A: 51 32     EOR   ($32),Y
912C: 51 34     EOR   ($34),Y
912E: 51 36     EOR   ($36),Y
9130: 51 38     EOR   ($38),Y
9132: 51 3a     EOR   ($3A),Y
9134: 41 3c     EOR   ($3C,X)
9136: 41 3e     EOR   ($3E,X)
9138: 41 40     EOR   ($40,X)
913A: 41 42     EOR   ($42,X)
913C: 31 44     AND   ($44),Y
913E: 31 46     AND   ($46),Y
9140: 31 48     AND   ($48),Y
9142: 31 4a     AND   ($4A),Y
9144: f8        SED
9145: 21 4c     AND   ($4C,X)
9147: f8        SED
9148: 21 4e     AND   ($4E,X)
914A: f8        SED
914B: 21 50     AND   ($50,X)
914D: FF        .byte $FF
914E: 2a        ROL
914F: 30 40     BMI   $9191
9151: 0c 50 0b  NOP   $0B50
9154: 60        RTS
9155: 0a        ASL
9156: 70 09     BVS   $9161
9158: 80 0a     NOP   $0A
915A: 90 0b     BCC   $9167
915C: 90 0c     BCC   $916A
915E: 90 0d     BCC   $916D
9160: 90 0c     BCC   $916E
9162: 90 0b     BCC   $916F
9164: 80 0a     NOP   $0A
9166: 70 0b     BVS   $9173
9168: 60        RTS
9169: 0c 50 0d  NOP   $0D50
916C: 40        RTI
916D: 0e 30 0d  ASL   $0D30
9170: f8        SED
9171: 20 0c f8  JSR   $F80C
9174: 10 0b     BPL   $9181
9176: FF        .byte $FF
9177: 21 b0     AND   ($B0,X)
9179: 10 82     BPL   $90FD
917B: C3        .byte $C3
917C: 02        .byte $02
917D: 21 70     AND   ($70,X)
917F: f8        SED
9180: 20 66 21  JSR   $2166
9183: b0 c3     BCS   $9148
9185: 01 03     ORA   ($03,X)
9187: 01 c3     ORA   ($C3,X)
9189: 01 21     ORA   ($21,X)
918B: 70 30     BVS   $91BD
918D: 33        .byte $33
918E: FF        .byte $FF
918F: 21 b0     AND   ($B0,X)
9191: 10 82     BPL   $9115
9193: C3        .byte $C3
9194: 02        .byte $02
9195: 21 70     AND   ($70,X)
9197: f8        SED
9198: 20 66 21  JSR   $2166
919B: b0 c3     BCS   $9160
919D: 01 03     ORA   ($03,X)
919F: 01 c3     ORA   ($C3,X)
91A1: 01 21     ORA   ($21,X)
91A3: 70 30     BVS   $91D5
91A5: 33        .byte $33
91A6: fe ff 8f  INC   $8FFF,X
91A9: 91 28     STA   ($28),Y
91AB: b0 10     BCS   $91BD
91AD: 8B        .byte $8B
91AE: A3        .byte $A3
91AF: fa        NOP
91B0: b1 7d     LDA   ($7D),Y
91B2: 70 7f     BVS   $9233
91B4: 50 5f     BVC   $9215
91B6: 40        RTI
91B7: 5F        .byte $5F
91B8: 30 5f     BMI   $9219
91BA: f8        SED
91BB: 20 5f f8  JSR   $F85F
91BE: 10 5f     BPL   $921F
91C0: FF        .byte $FF
91C1: 22        .byte $22
91C2: f0 f0     BEQ   $91B4
91C4: 7F        .byte $7F
91C5: 21 30     AND   ($30,X)
91C7: f0 7f     BEQ   $9248
91C9: 00        BRK
91CA: 00        BRK
91CB: 00        BRK
91CC: 00        BRK
91CD: 25 f0     AND   $F0
91CF: d0 3f     BNE   $9210
91D1: 22        .byte $22
91D2: f0 f8     BEQ   $91CC
91D4: 20 7f 25  JSR   $257F
91D7: f0 b0     BEQ   $9189
91D9: 3F        .byte $3F
91DA: 22        .byte $22
91DB: f0 f8     BEQ   $91D5
91DD: 20 7f 25  JSR   $257F
91E0: f0 90     BEQ   $9172
91E2: 3F        .byte $3F
91E3: 22        .byte $22
91E4: f0 f8     BEQ   $91DE
91E6: 20 7f 25  JSR   $257F
91E9: f0 70     BEQ   $925B
91EB: 3F        .byte $3F
91EC: 22        .byte $22
91ED: f0 f8     BEQ   $91E7
91EF: 20 7f 25  JSR   $257F
91F2: f0 50     BEQ   $9244
91F4: 3F        .byte $3F
91F5: 22        .byte $22
91F6: f0 f8     BEQ   $91F0
91F8: 20 7f 25  JSR   $257F
91FB: f0 30     BEQ   $922D
91FD: 3F        .byte $3F
91FE: 22        .byte $22
91FF: f0 f8     BEQ   $91F9
9201: 10 7f     BPL   $9282
9203: 25 f0     AND   $F0
9205: f8        SED
9206: 10 3f     BPL   $9247
9208: FF        .byte $FF
9209: 21 30     AND   ($30,X)
920B: 10 89     BPL   $9196
920D: d1 fd     CMP   ($FD),Y
920F: fe 28 09  INC   $0928,X
9212: 92        .byte $92
9213: c1 fd     CMP   ($FD,X)
9215: b1 fd     LDA   ($FD),Y
9217: b1 fd     LDA   ($FD),Y
9219: 91 fd     STA   ($FD),Y
921B: 91 fd     STA   ($FD),Y
921D: 71 fd     ADC   ($FD),Y
921F: 61 fd     ADC   ($FD,X)
9221: 51 fd     EOR   ($FD),Y
9223: 51 fd     EOR   ($FD),Y
9225: 31 fd     AND   ($FD),Y
9227: 31 fd     AND   ($FD),Y
9229: FF        .byte $FF
922A: 21 30     AND   ($30,X)
922C: 70 06     BVS   $9234
922E: fe 28 2a  INC   $2A28,X
9231: 92        .byte $92
9232: 60        RTS
9233: 06 60     ASL   $60
9235: 06 50     ASL   $50
9237: 06 50     ASL   $50
9239: 06 50     ASL   $50
923B: 06 40     ASL   $40
923D: 06 40     ASL   $40
923F: 06 40     ASL   $40
9241: 06 30     ASL   $30
9243: 06 30     ASL   $30
9245: 06 ff     ASL   $FF
9247: 21 f0     AND   ($F0,X)
9249: 10 a2     BPL   $91ED
924B: C3        .byte $C3
924C: 8a        TXA
924D: 33        .byte $33
924E: 57        .byte $57
924F: f8        SED
9250: 23        .byte $23
9251: 27        .byte $27
9252: f8        SED
9253: 13        .byte $13
9254: 27        .byte $27
9255: FF        .byte $FF
9256: 21 88     AND   ($88,X)
9258: 01 9d     ORA   ($9D,X)
925A: 01 20     ORA   ($20,X)
925C: 01 9d     ORA   ($9D,X)
925E: 01 20     ORA   ($20,X)
9260: FF        .byte $FF
9261: 22        .byte $22
9262: 30 60     BMI   $92C4
9264: 0e 50 0e  ASL   $0E50
9267: FF        .byte $FF
9268: 21 f0     AND   ($F0,X)
926A: 10 a2     BPL   $920E
926C: D3        .byte $D3
926D: 8a        TXA
926E: 53        .byte $53
926F: 57        .byte $57
9270: 43        .byte $43
9271: 27        .byte $27
9272: 33        .byte $33
9273: 27        .byte $27
9274: fe 2b 6c  INC   $6C2B,X
9277: 92        .byte $92
9278: E3        .byte $E3
9279: 8a        TXA
927A: 63        .byte $63
927B: 57        .byte $57
927C: 53        .byte $53
927D: 27        .byte $27
927E: 43        .byte $43
927F: 27        .byte $27
9280: fe 2c 78  INC   $782C,X
9283: 92        .byte $92
9284: F3        .byte $F3
9285: 8a        TXA
9286: 73        .byte $73
9287: 57        .byte $57
9288: 63        .byte $63
9289: 27        .byte $27
928A: 63        .byte $63
928B: 27        .byte $27
928C: fe 30 84  INC   $8430,X
928F: 92        .byte $92
9290: FF        .byte $FF
9291: 22        .byte $22
9292: 30 60     BMI   $92F4
9294: 0e 50 0e  ASL   $0E50
9297: fe 13 91  INC   $9113,X
929A: 92        .byte $92
929B: 22        .byte $22
929C: 30 70     BMI   $930E
929E: 0e 60 0e  ASL   $0E60
92A1: fe 13 9b  INC   $9B13,X
92A4: 92        .byte $92
92A5: 22        .byte $22
92A6: 30 80     BMI   $9228
92A8: 0e 70 0e  ASL   $0E70
92AB: fe 13 a5  INC   $A513,X
92AE: 92        .byte $92
92AF: 22        .byte $22
92B0: 30 90     BMI   $9242
92B2: 0e 70 0e  ASL   $0E70
92B5: fe 13 af  INC   $AF13,X
92B8: 92        .byte $92
92B9: 22        .byte $22
92BA: 30 a0     BMI   $925C
92BC: 0e 80 0e  ASL   $0E80
92BF: fe 2d b9  INC   $B92D,X
92C2: 92        .byte $92
92C3: FF        .byte $FF
92C4: 21 88     AND   ($88,X)
92C6: 01 9d     ORA   ($9D,X)
92C8: 01 20     ORA   ($20,X)
92CA: 01 9d     ORA   ($9D,X)
92CC: 01 20     ORA   ($20,X)
92CE: 01 9c     ORA   ($9C,X)
92D0: 01 1f     ORA   ($1F,X)
92D2: 01 9c     ORA   ($9C,X)
92D4: 01 1f     ORA   ($1F,X)
92D6: 01 9b     ORA   ($9B,X)
92D8: 01 1e     ORA   ($1E,X)
92DA: 01 9b     ORA   ($9B,X)
92DC: 01 1e     ORA   ($1E,X)
92DE: 01 9a     ORA   ($9A,X)
92E0: 01 1d     ORA   ($1D,X)
92E2: 01 9a     ORA   ($9A,X)
92E4: 01 1d     ORA   ($1D,X)
92E6: 01 99     ORA   ($99,X)
92E8: 01 1c     ORA   ($1C,X)
92EA: 01 99     ORA   ($99,X)
92EC: 01 1c     ORA   ($1C,X)
92EE: 01 98     ORA   ($98,X)
92F0: 01 1b     ORA   ($1B,X)
92F2: 01 98     ORA   ($98,X)
92F4: 01 1b     ORA   ($1B,X)
92F6: 01 97     ORA   ($97,X)
92F8: 01 1a     ORA   ($1A,X)
92FA: 01 97     ORA   ($97,X)
92FC: 01 1a     ORA   ($1A,X)
92FE: 01 96     ORA   ($96,X)
9300: 01 19     ORA   ($19,X)
9302: 01 96     ORA   ($96,X)
9304: 01 19     ORA   ($19,X)
9306: 01 95     ORA   ($95,X)
9308: 01 18     ORA   ($18,X)
930A: 01 95     ORA   ($95,X)
930C: 01 18     ORA   ($18,X)
930E: 01 94     ORA   ($94,X)
9310: 01 17     ORA   ($17,X)
9312: 01 94     ORA   ($94,X)
9314: 01 17     ORA   ($17,X)
9316: 01 93     ORA   ($93,X)
9318: 01 16     ORA   ($16,X)
931A: 01 93     ORA   ($93,X)
931C: 01 16     ORA   ($16,X)
931E: 01 92     ORA   ($92,X)
9320: 01 15     ORA   ($15,X)
9322: 01 92     ORA   ($92,X)
9324: 01 15     ORA   ($15,X)
9326: 01 91     ORA   ($91,X)
9328: 01 14     ORA   ($14,X)
932A: 01 91     ORA   ($91,X)
932C: 01 14     ORA   ($14,X)
932E: 01 90     ORA   ($90,X)
9330: 01 13     ORA   ($13,X)
9332: 01 90     ORA   ($90,X)
9334: 01 13     ORA   ($13,X)
9336: 01 8f     ORA   ($8F,X)
9338: 01 12     ORA   ($12,X)
933A: 01 8f     ORA   ($8F,X)
933C: 01 12     ORA   ($12,X)
933E: 01 8e     ORA   ($8E,X)
9340: 01 11     ORA   ($11,X)
9342: 01 8e     ORA   ($8E,X)
9344: 01 11     ORA   ($11,X)
9346: 01 8d     ORA   ($8D,X)
9348: 01 10     ORA   ($10,X)
934A: 01 8d     ORA   ($8D,X)
934C: 01 10     ORA   ($10,X)
934E: 01 8c     ORA   ($8C,X)
9350: 01 0f     ORA   ($0F,X)
9352: 01 8c     ORA   ($8C,X)
9354: 01 0f     ORA   ($0F,X)
9356: 01 8b     ORA   ($8B,X)
9358: 01 0e     ORA   ($0E,X)
935A: 01 8b     ORA   ($8B,X)
935C: 01 0e     ORA   ($0E,X)
935E: 01 8a     ORA   ($8A,X)
9360: 01 0d     ORA   ($0D,X)
9362: 01 8a     ORA   ($8A,X)
9364: 01 0d     ORA   ($0D,X)
9366: 01 89     ORA   ($89,X)
9368: 01 0c     ORA   ($0C,X)
936A: 01 89     ORA   ($89,X)
936C: 01 0c     ORA   ($0C,X)
936E: 01 88     ORA   ($88,X)
9370: 01 0b     ORA   ($0B,X)
9372: 01 88     ORA   ($88,X)
9374: 01 0b     ORA   ($0B,X)
9376: 01 87     ORA   ($87,X)
9378: 01 0a     ORA   ($0A,X)
937A: 01 87     ORA   ($87,X)
937C: 01 0a     ORA   ($0A,X)
937E: 01 86     ORA   ($86,X)
9380: 01 09     ORA   ($09,X)
9382: 01 86     ORA   ($86,X)
9384: 01 09     ORA   ($09,X)
9386: 01 85     ORA   ($85,X)
9388: 01 08     ORA   ($08,X)
938A: 01 85     ORA   ($85,X)
938C: 01 08     ORA   ($08,X)
938E: 01 84     ORA   ($84,X)
9390: 01 07     ORA   ($07,X)
9392: 01 84     ORA   ($84,X)
9394: 01 07     ORA   ($07,X)
9396: 01 83     ORA   ($83,X)
9398: 01 06     ORA   ($06,X)
939A: 01 83     ORA   ($83,X)
939C: 01 06     ORA   ($06,X)
939E: 01 82     ORA   ($82,X)
93A0: 01 05     ORA   ($05,X)
93A2: 01 82     ORA   ($82,X)
93A4: 01 05     ORA   ($05,X)
93A6: 01 81     ORA   ($81,X)
93A8: 01 04     ORA   ($04,X)
93AA: 01 81     ORA   ($81,X)
93AC: 01 04     ORA   ($04,X)
93AE: 01 80     ORA   ($80,X)
93B0: 01 03     ORA   ($03,X)
93B2: 01 80     ORA   ($80,X)
93B4: 01 03     ORA   ($03,X)
93B6: 01 7f     ORA   ($7F,X)
93B8: 01 02     ORA   ($02,X)
93BA: 01 7f     ORA   ($7F,X)
93BC: 01 02     ORA   ($02,X)
93BE: 01 7e     ORA   ($7E,X)
93C0: 01 01     ORA   ($01,X)
93C2: 01 7e     ORA   ($7E,X)
93C4: 01 01     ORA   ($01,X)
93C6: 01 7d     ORA   ($7D,X)
93C8: 01 00     ORA   ($00,X)
93CA: 01 7d     ORA   ($7D,X)
93CC: 01 00     ORA   ($00,X)
93CE: 01 7c     ORA   ($7C,X)
93D0: 00        BRK
93D1: FF        .byte $FF
93D2: 01 7c     ORA   ($7C,X)
93D4: 00        BRK
93D5: FF        .byte $FF
93D6: 01 7b     ORA   ($7B,X)
93D8: 00        BRK
93D9: fe 01 7b  INC   $7B01,X
93DC: 00        BRK
93DD: fe 01 7a  INC   $7A01,X
93E0: 00        BRK
93E1: fd 01 7a  SBC   $7A01,X
93E4: 00        BRK
93E5: fd 01 79  SBC   $7901,X
93E8: 00        BRK
93E9: fc 01 79  NOP   $7901
93EC: 00        BRK
93ED: fc 01 78  NOP   $7801
93F0: 00        BRK
93F1: FB        .byte $FB
93F2: 01 78     ORA   ($78,X)
93F4: 00        BRK
93F5: FB        .byte $FB
93F6: 01 77     ORA   ($77,X)
93F8: 00        BRK
93F9: fa        NOP
93FA: 01 77     ORA   ($77,X)
93FC: 00        BRK
93FD: fa        NOP
93FE: 01 76     ORA   ($76,X)
9400: 00        BRK
9401: f9 01 76  SBC   $7601,Y
9404: 00        BRK
9405: f9 01 75  SBC   $7501,Y
9408: 00        BRK
9409: f8        SED
940A: 01 75     ORA   ($75,X)
940C: 00        BRK
940D: f8        SED
940E: 01 74     ORA   ($74,X)
9410: 00        BRK
9411: F7        .byte $F7
9412: 01 74     ORA   ($74,X)
9414: 00        BRK
9415: F7        .byte $F7
9416: 01 73     ORA   ($73,X)
9418: 00        BRK
9419: f6 01     INC   $01,X
941B: 73        .byte $73
941C: 00        BRK
941D: f6 01     INC   $01,X
941F: 72        .byte $72
9420: 00        BRK
9421: f5 01     SBC   $01,X
9423: 72        .byte $72
9424: 00        BRK
9425: f5 01     SBC   $01,X
9427: 71 00     ADC   ($00),Y
9429: f4 01     NOP   $01
942B: 71 00     ADC   ($00),Y
942D: f4 01     NOP   $01
942F: 70 00     BVS   $9431
9431: F3        .byte $F3
9432: 01 70     ORA   ($70,X)
9434: 00        BRK
9435: F3        .byte $F3
9436: 01 6f     ORA   ($6F,X)
9438: 00        BRK
9439: F2        .byte $F2
943A: 01 6f     ORA   ($6F,X)
943C: 00        BRK
943D: F2        .byte $F2
943E: 01 6e     ORA   ($6E,X)
9440: 00        BRK
9441: f1 01     SBC   ($01),Y
9443: 6e 00 f1  ROR   $F100
9446: 01 6d     ORA   ($6D,X)
9448: 00        BRK
9449: f0 01     BEQ   $944C
944B: 6d 00 f0  ADC   $F000
944E: 01 6c     ORA   ($6C,X)
9450: 00        BRK
9451: EF        .byte $EF
9452: 01 6c     ORA   ($6C,X)
9454: 00        BRK
9455: EF        .byte $EF
9456: 01 6b     ORA   ($6B,X)
9458: 00        BRK
9459: ee 01 6b  INC   $6B01
945C: 00        BRK
945D: ee 01 6a  INC   $6A01
9460: 00        BRK
9461: ed 01 6a  SBC   $6A01
9464: 00        BRK
9465: ed 01 69  SBC   $6901
9468: 00        BRK
9469: ec 01 69  CPX   $6901
946C: 00        BRK
946D: ec 01 68  CPX   $6801
9470: 00        BRK
9471: EB        .byte $EB
9472: 01 68     ORA   ($68,X)
9474: 00        BRK
9475: EB        .byte $EB
9476: 01 67     ORA   ($67,X)
9478: 00        BRK
9479: ea        NOP
947A: 01 67     ORA   ($67,X)
947C: 00        BRK
947D: ea        NOP
947E: 01 66     ORA   ($66,X)
9480: 00        BRK
9481: e9 01     SBC   #$01
9483: 66 00     ROR   $00
9485: e9 01     SBC   #$01
9487: 65 00     ADC   $00
9489: e8        INX
948A: 01 65     ORA   ($65,X)
948C: 00        BRK
948D: e8        INX
948E: 01 64     ORA   ($64,X)
9490: 00        BRK
9491: E7        .byte $E7
9492: 01 64     ORA   ($64,X)
9494: 00        BRK
9495: E7        .byte $E7
9496: 01 63     ORA   ($63,X)
9498: 00        BRK
9499: e6 01     INC   $01
949B: 63        .byte $63
949C: 00        BRK
949D: e6 01     INC   $01
949F: 62        .byte $62
94A0: 00        BRK
94A1: e5 01     SBC   $01
94A3: 62        .byte $62
94A4: 00        BRK
94A5: e5 01     SBC   $01
94A7: 61 00     ADC   ($00,X)
94A9: e4 01     CPX   $01
94AB: 61 00     ADC   ($00,X)
94AD: e4 01     CPX   $01
94AF: 60        RTS
94B0: 00        BRK
94B1: E3        .byte $E3
94B2: 01 60     ORA   ($60,X)
94B4: 00        BRK
94B5: E3        .byte $E3
94B6: 01 5f     ORA   ($5F,X)
94B8: 00        BRK
94B9: E2        .byte $E2
94BA: 01 5f     ORA   ($5F,X)
94BC: 00        BRK
94BD: E2        .byte $E2
94BE: 01 5e     ORA   ($5E,X)
94C0: 00        BRK
94C1: e1 01     SBC   ($01,X)
94C3: 5e 00 e1  LSR   $E100,X
94C6: 01 5d     ORA   ($5D,X)
94C8: 00        BRK
94C9: e0 01     CPX   #$01
94CB: 5d 00 e0  EOR   $E000,X
94CE: 01 5c     ORA   ($5C,X)
94D0: 00        BRK
94D1: DF        .byte $DF
94D2: 01 5c     ORA   ($5C,X)
94D4: 00        BRK
94D5: DF        .byte $DF
94D6: 01 5b     ORA   ($5B,X)
94D8: 00        BRK
94D9: de 01 5b  DEC   $5B01,X
94DC: 00        BRK
94DD: de 01 5a  DEC   $5A01,X
94E0: 00        BRK
94E1: dd 01 5a  CMP   $5A01,X
94E4: 00        BRK
94E5: dd 01 59  CMP   $5901,X
94E8: 00        BRK
94E9: dc 01 59  NOP   $5901
94EC: 00        BRK
94ED: dc 01 58  NOP   $5801
94F0: 00        BRK
94F1: DB        .byte $DB
94F2: 01 58     ORA   ($58,X)
94F4: 00        BRK
94F5: DB        .byte $DB
94F6: 01 57     ORA   ($57,X)
94F8: 00        BRK
94F9: da        NOP
94FA: 01 57     ORA   ($57,X)
94FC: 00        BRK
94FD: da        NOP
94FE: 01 56     ORA   ($56,X)
9500: 00        BRK
9501: d9 01 56  CMP   $5601,Y
9504: 00        BRK
9505: d9 01 55  CMP   $5501,Y
9508: 00        BRK
9509: d8        CLD
950A: 01 55     ORA   ($55,X)
950C: 00        BRK
950D: d8        CLD
950E: 01 54     ORA   ($54,X)
9510: 00        BRK
9511: D7        .byte $D7
9512: 01 54     ORA   ($54,X)
9514: 00        BRK
9515: D7        .byte $D7
9516: 01 53     ORA   ($53,X)
9518: 00        BRK
9519: d6 01     DEC   $01,X
951B: 53        .byte $53
951C: 00        BRK
951D: d6 01     DEC   $01,X
951F: 52        .byte $52
9520: 00        BRK
9521: d5 01     CMP   $01,X
9523: 52        .byte $52
9524: 00        BRK
9525: d5 01     CMP   $01,X
9527: 51 00     EOR   ($00),Y
9529: d4 01     NOP   $01
952B: 51 00     EOR   ($00),Y
952D: d4 01     NOP   $01
952F: 50 00     BVC   $9531
9531: D3        .byte $D3
9532: 01 50     ORA   ($50,X)
9534: 00        BRK
9535: D3        .byte $D3
9536: 01 4f     ORA   ($4F,X)
9538: 00        BRK
9539: D2        .byte $D2
953A: 01 4f     ORA   ($4F,X)
953C: 00        BRK
953D: D2        .byte $D2
953E: 01 4e     ORA   ($4E,X)
9540: 00        BRK
9541: d1 01     CMP   ($01),Y
9543: 4e 00 d1  LSR   $D100
9546: 01 4d     ORA   ($4D,X)
9548: 00        BRK
9549: d0 01     BNE   $954C
954B: 4d 00 d0  EOR   $D000
954E: 01 4c     ORA   ($4C,X)
9550: 00        BRK
9551: CF        .byte $CF
9552: 01 4c     ORA   ($4C,X)
9554: 00        BRK
9555: CF        .byte $CF
9556: 01 4b     ORA   ($4B,X)
9558: 00        BRK
9559: ce 01 4b  DEC   $4B01
955C: 00        BRK
955D: ce 01 4a  DEC   $4A01
9560: 00        BRK
9561: cd 01 4a  CMP   $4A01
9564: 00        BRK
9565: cd 01 49  CMP   $4901
9568: 00        BRK
9569: cc 01 49  CPY   $4901
956C: 00        BRK
956D: cc 01 48  CPY   $4801
9570: 00        BRK
9571: CB        .byte $CB
9572: 01 48     ORA   ($48,X)
9574: 00        BRK
9575: CB        .byte $CB
9576: 01 47     ORA   ($47,X)
9578: 40        RTI
9579: ca        DEX
957A: 01 47     ORA   ($47,X)
957C: 00        BRK
957D: ca        DEX
957E: 01 46     ORA   ($46,X)
9580: 00        BRK
9581: c9 01     CMP   #$01
9583: 46 00     LSR   $00
9585: c9 01     CMP   #$01
9587: 45 00     EOR   $00
9589: c8        INY
958A: 01 45     ORA   ($45,X)
958C: 00        BRK
958D: c8        INY
958E: 01 44     ORA   ($44,X)
9590: 00        BRK
9591: C7        .byte $C7
9592: 01 44     ORA   ($44,X)
9594: 00        BRK
9595: C7        .byte $C7
9596: 01 43     ORA   ($43,X)
9598: 00        BRK
9599: c6 01     DEC   $01
959B: 43        .byte $43
959C: 00        BRK
959D: c6 01     DEC   $01
959F: 42        .byte $42
95A0: 00        BRK
95A1: c5 01     CMP   $01
95A3: 42        .byte $42
95A4: 00        BRK
95A5: c5 01     CMP   $01
95A7: 41 00     EOR   ($00,X)
95A9: c4 01     CPY   $01
95AB: 41 00     EOR   ($00,X)
95AD: c4 01     CPY   $01
95AF: 40        RTI
95B0: 00        BRK
95B1: C3        .byte $C3
95B2: 01 40     ORA   ($40,X)
95B4: 00        BRK
95B5: C3        .byte $C3
95B6: 01 3f     ORA   ($3F,X)
95B8: 00        BRK
95B9: C2        .byte $C2
95BA: 01 3f     ORA   ($3F,X)
95BC: 00        BRK
95BD: C2        .byte $C2
95BE: 01 3e     ORA   ($3E,X)
95C0: 00        BRK
95C1: c1 01     CMP   ($01,X)
95C3: 3e 00 c1  ROL   $C100,X
95C6: 01 3d     ORA   ($3D,X)
95C8: 00        BRK
95C9: c0 01     CPY   #$01
95CB: 3d 00 c0  AND   $C000,X
95CE: 01 3c     ORA   ($3C,X)
95D0: 00        BRK
95D1: BF        .byte $BF
95D2: 01 3c     ORA   ($3C,X)
95D4: 00        BRK
95D5: BF        .byte $BF
95D6: 01 3b     ORA   ($3B,X)
95D8: 00        BRK
95D9: be 01 3b  LDX   $3B01,Y
95DC: 00        BRK
95DD: be 01 3a  LDX   $3A01,Y
95E0: 00        BRK
95E1: bd 01 3a  LDA   $3A01,X
95E4: 00        BRK
95E5: bd 01 39  LDA   $3901,X
95E8: 00        BRK
95E9: bc 01 39  LDY   $3901,X
95EC: 00        BRK
95ED: bc 01 38  LDY   $3801,X
95F0: 00        BRK
95F1: BB        .byte $BB
95F2: 01 38     ORA   ($38,X)
95F4: 00        BRK
95F5: BB        .byte $BB
95F6: 01 37     ORA   ($37,X)
95F8: 00        BRK
95F9: ba        TSX
95FA: 01 37     ORA   ($37,X)
95FC: 00        BRK
95FD: ba        TSX
95FE: 01 36     ORA   ($36,X)
9600: 00        BRK
9601: b9 01 36  LDA   $3601,Y
9604: 00        BRK
9605: b9 01 35  LDA   $3501,Y
9608: 00        BRK
9609: b8        CLV
960A: 01 35     ORA   ($35,X)
960C: 00        BRK
960D: b8        CLV
960E: 01 34     ORA   ($34,X)
9610: 40        RTI
9611: B7        .byte $B7
9612: 01 34     ORA   ($34,X)
9614: 00        BRK
9615: B7        .byte $B7
9616: 01 33     ORA   ($33,X)
9618: 00        BRK
9619: b6 01     LDX   $01,Y
961B: 33        .byte $33
961C: 00        BRK
961D: b6 01     LDX   $01,Y
961F: 32        .byte $32
9620: 00        BRK
9621: b5 01     LDA   $01,X
9623: 32        .byte $32
9624: 00        BRK
9625: b5 01     LDA   $01,X
9627: 31 00     AND   ($00),Y
9629: b4 01     LDY   $01,X
962B: 31 00     AND   ($00),Y
962D: b4 01     LDY   $01,X
962F: 30 00     BMI   $9631
9631: B3        .byte $B3
9632: 01 30     ORA   ($30,X)
9634: 00        BRK
9635: B3        .byte $B3
9636: 01 2f     ORA   ($2F,X)
9638: 00        BRK
9639: B2        .byte $B2
963A: 01 2f     ORA   ($2F,X)
963C: 00        BRK
963D: B2        .byte $B2
963E: 01 2e     ORA   ($2E,X)
9640: 00        BRK
9641: b1 01     LDA   ($01),Y
9643: 2e 00 b1  ROL   $B100
9646: 01 2d     ORA   ($2D,X)
9648: 00        BRK
9649: b0 01     BCS   $964C
964B: 2d 00 b0  AND   $B000
964E: 01 2c     ORA   ($2C,X)
9650: 00        BRK
9651: AF        .byte $AF
9652: 01 2c     ORA   ($2C,X)
9654: 00        BRK
9655: AF        .byte $AF
9656: FF        .byte $FF
9657: 21 30     AND   ($30,X)
9659: 10 82     BPL   $95DD
965B: 63        .byte $63
965C: 83        .byte $83
965D: 33        .byte $33
965E: 63        .byte $63
965F: f8        SED
9660: 23        .byte $23
9661: 53        .byte $53
9662: 00        BRK
9663: 00        BRK
9664: 73        .byte $73
9665: 83        .byte $83
9666: 33        .byte $33
9667: 64 f8     NOP   $F8
9669: 23        .byte $23
966A: 53        .byte $53
966B: f8        SED
966C: 13        .byte $13
966D: 33        .byte $33
966E: fe 0f 64  INC   $640F,X
9671: 96 83     STX   $83,Y
9673: 83        .byte $83
9674: 43        .byte $43
9675: 65 33     ADC   $33
9677: 53        .byte $53
9678: f8        SED
9679: 13        .byte $13
967A: 33        .byte $33
967B: fe 10 72  INC   $7210,X
967E: 96 93     STX   $93,Y
9680: 83        .byte $83
9681: 43        .byte $43
9682: 66 33     ROR   $33
9684: 53        .byte $53
9685: f8        SED
9686: 13        .byte $13
9687: 33        .byte $33
9688: fe 10 7f  INC   $7F10,X
968B: 96 a3     STX   $A3,Y
968D: 83        .byte $83
968E: 43        .byte $43
968F: 67        .byte $67
9690: 33        .byte $33
9691: 53        .byte $53
9692: f8        SED
9693: 13        .byte $13
9694: 33        .byte $33
9695: fe 10 8c  INC   $8C10,X
9698: 96 93     STX   $93,Y
969A: 83        .byte $83
969B: 43        .byte $43
969C: 66 33     ROR   $33
969E: 53        .byte $53
969F: f8        SED
96A0: 13        .byte $13
96A1: 33        .byte $33
96A2: fe 08 99  INC   $9908,X
96A5: 96 83     STX   $83,Y
96A7: 83        .byte $83
96A8: 43        .byte $43
96A9: 65 33     ADC   $33
96AB: 53        .byte $53
96AC: f8        SED
96AD: 13        .byte $13
96AE: 33        .byte $33
96AF: fe 08 a6  INC   $A608,X
96B2: 96 73     STX   $73,Y
96B4: 83        .byte $83
96B5: 33        .byte $33
96B6: 65 f8     ADC   $F8
96B8: 23        .byte $23
96B9: 53        .byte $53
96BA: f8        SED
96BB: 13        .byte $13
96BC: 33        .byte $33
96BD: fe 07 b3  INC   $B307,X
96C0: 96 63     STX   $63,Y
96C2: 83        .byte $83
96C3: 33        .byte $33
96C4: 63        .byte $63
96C5: f8        SED
96C6: 23        .byte $23
96C7: 53        .byte $53
96C8: 00        BRK
96C9: 00        BRK
96CA: fe 07 c1  INC   $C107,X
96CD: 96 53     STX   $53,Y
96CF: 83        .byte $83
96D0: f8        SED
96D1: 23        .byte $23
96D2: 63        .byte $63
96D3: f8        SED
96D4: 13        .byte $13
96D5: 53        .byte $53
96D6: 00        BRK
96D7: 00        BRK
96D8: fe 06 ce  INC   $CE06,X
96DB: 96 43     STX   $43,Y
96DD: 83        .byte $83
96DE: f8        SED
96DF: 23        .byte $23
96E0: 63        .byte $63
96E1: f8        SED
96E2: 13        .byte $13
96E3: 53        .byte $53
96E4: 00        BRK
96E5: 00        BRK
96E6: fe 06 dc  INC   $DC06,X
96E9: 96 33     STX   $33,Y
96EB: 83        .byte $83
96EC: f8        SED
96ED: 13        .byte $13
96EE: 63        .byte $63
96EF: f8        SED
96F0: 13        .byte $13
96F1: 53        .byte $53
96F2: 00        BRK
96F3: 00        BRK
96F4: fe 05 ea  INC   $EA05,X
96F7: 96 f8     STX   $F8,Y
96F9: 23        .byte $23
96FA: 83        .byte $83
96FB: f8        SED
96FC: 13        .byte $13
96FD: 63        .byte $63
96FE: f8        SED
96FF: 13        .byte $13
9700: 53        .byte $53
9701: 00        BRK
9702: 00        BRK
9703: fe 05 f8  INC   $F805,X
9706: 96 f8     STX   $F8,Y
9708: 13        .byte $13
9709: 83        .byte $83
970A: f8        SED
970B: 13        .byte $13
970C: 63        .byte $63
970D: 00        BRK
970E: 00        BRK
970F: 00        BRK
9710: 00        BRK
9711: fe 05 07  INC   $0705,X
9714: 97        .byte $97
9715: FF        .byte $FF
9716: 28        PLP
9717: 30 f8     BMI   $9711
9719: 20 0e f8  JSR   $F80E
971C: 20 0e fe  JSR   $FE0E
971F: 03        .byte $03
9720: 18        CLC
9721: 97        .byte $97
9722: 30 0e     BMI   $9732
9724: 30 0e     BMI   $9734
9726: fe 04 22  INC   $2204,X
9729: 97        .byte $97
972A: 40        RTI
972B: 0e 40 0e  ASL   $0E40
972E: fe 04 2a  INC   $2A04,X
9731: 97        .byte $97
9732: 50 0e     BVC   $9742
9734: 50 0e     BVC   $9744
9736: fe 06 32  INC   $3206,X
9739: 97        .byte $97
973A: 40        RTI
973B: 0e 40 0e  ASL   $0E40
973E: fe 04 3a  INC   $3A04,X
9741: 97        .byte $97
9742: 30 0e     BMI   $9752
9744: 30 0e     BMI   $9754
9746: fe 04 42  INC   $4204,X
9749: 97        .byte $97
974A: f8        SED
974B: 20 0e f8  JSR   $F80E
974E: 20 0e fe  JSR   $FE0E
9751: 04 4a     NOP   $4A
9753: 97        .byte $97
9754: FF        .byte $FF
9755: 21 30     AND   ($30,X)
9757: f0 0e     BEQ   $9767
9759: f0 0f     BEQ   $976A
975B: fe 02 55  INC   $5502,X
975E: 97        .byte $97
975F: 22        .byte $22
9760: 30 f0     BMI   $9752
9762: 0F        .byte $0F
9763: f0 08     BEQ   $976D
9765: f0 0f     BEQ   $9776
9767: f0 08     BEQ   $9771
9769: f0 0f     BEQ   $977A
976B: f0 0c     BEQ   $9779
976D: f0 0b     BEQ   $977A
976F: f0 0b     BEQ   $977C
9771: f0 0b     BEQ   $977E
9773: e0 0b     CPX   #$0B
9775: d0 0b     BNE   $9782
9777: c0 0d     CPY   #$0D
9779: b0 0c     BCS   $9787
977B: a0 0b     LDY   #$0B
977D: 90 0b     BCC   $978A
977F: b0 0b     BCS   $978C
9781: 70 0b     BVS   $978E
9783: 60        RTS
9784: 0B        .byte $0B
9785: 23        .byte $23
9786: 30 50     BMI   $97D8
9788: 0B        .byte $0B
9789: 40        RTI
978A: 0B        .byte $0B
978B: 30 0c     BMI   $9799
978D: f8        SED
978E: 20 0c f8  JSR   $F80C
9791: 10 0b     BPL   $979E
9793: FF        .byte $FF
9794: 21 30     AND   ($30,X)
9796: f0 0e     BEQ   $97A6
9798: f0 0f     BEQ   $97A9
979A: fe 04 94  INC   $9404,X
979D: 97        .byte $97
979E: 22        .byte $22
979F: 30 f0     BMI   $9791
97A1: 0F        .byte $0F
97A2: f0 08     BEQ   $97AC
97A4: f0 0f     BEQ   $97B5
97A6: 27        .byte $27
97A7: 30 f0     BMI   $9799
97A9: 0c f0 0b  NOP   $0BF0
97AC: f0 0b     BEQ   $97B9
97AE: f0 0b     BEQ   $97BB
97B0: e0 0b     CPX   #$0B
97B2: d0 0b     BNE   $97BF
97B4: c0 0d     CPY   #$0D
97B6: b0 0c     BCS   $97C4
97B8: a0 0b     LDY   #$0B
97BA: 90 0b     BCC   $97C7
97BC: 80 0b     NOP   $0B
97BE: 70 0b     BVS   $97CB
97C0: 60        RTS
97C1: 0c 50 0b  NOP   $0B50
97C4: 40        RTI
97C5: 0B        .byte $0B
97C6: 30 0c     BMI   $97D4
97C8: f8        SED
97C9: 20 0c f8  JSR   $F80C
97CC: 10 0b     BPL   $97D9
97CE: FF        .byte $FF
97CF: 23        .byte $23
97D0: b0 10     BCS   $97E2
97D2: 83        .byte $83
97D3: D2        .byte $D2
97D4: 11 d2     ORA   ($D2),Y
97D6: 11 26     ORA   ($26),Y
97D8: b0 c0     BCS   $979A
97DA: b8        CLV
97DB: b0 bc     BCS   $9799
97DD: a0 c0     LDY   #$C0
97DF: 90 c5     BCC   $97A6
97E1: 70 ca     BVS   $97AD
97E3: 50 cf     BVC   $97B4
97E5: 30 d4     BMI   $97BB
97E7: FF        .byte $FF
97E8: 21 30     AND   ($30,X)
97EA: f0 0e     BEQ   $97FA
97EC: f0 0f     BEQ   $97FD
97EE: fe 02 e8  INC   $E802,X
97F1: 97        .byte $97
97F2: 25 30     AND   $30
97F4: f0 0f     BEQ   $9805
97F6: f0 0a     BEQ   $9802
97F8: f0 0f     BEQ   $9809
97FA: f0 0a     BEQ   $9806
97FC: f0 0f     BEQ   $980D
97FE: f0 0c     BEQ   $980C
9800: f0 0c     BEQ   $980E
9802: f0 0b     BEQ   $980F
9804: f0 0b     BEQ   $9811
9806: e0 0b     CPX   #$0B
9808: d0 0c     BNE   $9816
980A: c0 0d     CPY   #$0D
980C: b0 0d     BCS   $981B
980E: a0 0c     LDY   #$0C
9810: 90 0c     BCC   $981E
9812: b0 0c     BCS   $9820
9814: 70 0c     BVS   $9822
9816: 60        RTS
9817: 0c 23 30  NOP   $3023
981A: 50 0c     BVC   $9828
981C: 40        RTI
981D: 0c 30 0d  NOP   $0D30
9820: f8        SED
9821: 20 0d f8  JSR   $F80D
9824: 20 0c ff  JSR   $FF0C
9827: 21 b0     AND   ($B0,X)
9829: 00        BRK
982A: 00        BRK
982B: 25 b0     AND   $B0
982D: 10 83     BPL   $97B2
982F: f1 fd     SBC   ($FD),Y
9831: 10 83     BPL   $97B6
9833: f0 fe     BEQ   $9833
9835: 2F        .byte $2F
9836: b0 10     BCS   $9848
9838: 83        .byte $83
9839: f0 fe     BEQ   $9839
983B: 10 83     BPL   $97C0
983D: 91 12     STA   ($12),Y
983F: 10 83     BPL   $97C4
9841: b1 23     LDA   ($23),Y
9843: 10 83     BPL   $97C8
9845: d1 01     CMP   ($01),Y
9847: 10 83     BPL   $97CC
9849: 91 12     STA   ($12),Y
984B: 10 83     BPL   $97D0
984D: 51 1d     EOR   ($1D),Y
984F: 10 83     BPL   $97D4
9851: 41 2e     EOR   ($2E,X)
9853: 10 83     BPL   $97D8
9855: 31 40     AND   ($40),Y
9857: 10 83     BPL   $97DC
9859: 31 1d     AND   ($1D),Y
985B: 10 83     BPL   $97E0
985D: f8        SED
985E: 21 2e     AND   ($2E,X)
9860: 10 83     BPL   $97E5
9862: f8        SED
9863: 21 40     AND   ($40,X)
9865: 10 83     BPL   $97EA
9867: f8        SED
9868: 11 1d     ORA   ($1D),Y
986A: 23        .byte $23
986B: b0 00     BCS   $986D
986D: 00        BRK
986E: FF        .byte $FF
986F: 25 b0     AND   $B0
9871: 10 83     BPL   $97F6
9873: f1 fd     SBC   ($FD),Y
9875: 10 83     BPL   $97FA
9877: f0 fe     BEQ   $9877
9879: 2F        .byte $2F
987A: b0 10     BCS   $988C
987C: 83        .byte $83
987D: f0 fe     BEQ   $987D
987F: 10 83     BPL   $9804
9881: 91 12     STA   ($12),Y
9883: 10 83     BPL   $9808
9885: b1 23     LDA   ($23),Y
9887: 10 83     BPL   $980C
9889: d1 01     CMP   ($01),Y
988B: 10 83     BPL   $9810
988D: 91 12     STA   ($12),Y
988F: 10 83     BPL   $9814
9891: 51 1d     EOR   ($1D),Y
9893: 10 83     BPL   $9818
9895: 41 2e     EOR   ($2E,X)
9897: 10 83     BPL   $981C
9899: 31 40     AND   ($40),Y
989B: 10 83     BPL   $9820
989D: 31 1d     AND   ($1D),Y
989F: 10 83     BPL   $9824
98A1: f8        SED
98A2: 21 2e     AND   ($2E,X)
98A4: 10 83     BPL   $9829
98A6: f8        SED
98A7: 21 40     AND   ($40,X)
98A9: 10 83     BPL   $982E
98AB: f8        SED
98AC: 11 1d     ORA   ($1D),Y
98AE: 24 b0     BIT   $B0
98B0: 00        BRK
98B1: 00        BRK
98B2: FF        .byte $FF
98B3: DF        .byte $DF
98B4: CB        .byte $CB
98B5: de c0 ff  DEC   $FFC0,X
98B8: 21 30     AND   ($30,X)
98BA: f0 0e     BEQ   $98CA
98BC: f0 0f     BEQ   $98CD
98BE: fe 04 b8  INC   $B804,X
98C1: 98        TYA
98C2: 22        .byte $22
98C3: 30 f0     BMI   $98B5
98C5: 0F        .byte $0F
98C6: f0 08     BEQ   $98D0
98C8: f0 0f     BEQ   $98D9
98CA: 2a        ROL
98CB: 30 f0     BMI   $98BD
98CD: 0c f0 0b  NOP   $0BF0
98D0: f0 0b     BEQ   $98DD
98D2: f0 0b     BEQ   $98DF
98D4: e0 0b     CPX   #$0B
98D6: d0 0b     BNE   $98E3
98D8: c0 0d     CPY   #$0D
98DA: b0 0c     BCS   $98E8
98DC: a0 0b     LDY   #$0B
98DE: 90 0b     BCC   $98EB
98E0: 80 0b     NOP   $0B
98E2: 70 0b     BVS   $98EF
98E4: 60        RTS
98E5: 0c 50 0b  NOP   $0B50
98E8: 40        RTI
98E9: 0B        .byte $0B
98EA: 30 0c     BMI   $98F8
98EC: f8        SED
98ED: 20 0c f8  JSR   $F80C
98F0: 10 0b     BPL   $98FD
98F2: FF        .byte $FF
98F3: 23        .byte $23
98F4: f0 10     BEQ   $9906
98F6: 81 f0     STA   ($F0,X)
98F8: fe 70 fe  INC   $FE70,X
98FB: 30 fe     BMI   $98FB
98FD: 22        .byte $22
98FE: 30 00     BMI   $9900
9900: 00        BRK
9901: 22        .byte $22
9902: 30 10     BMI   $9914
9904: 83        .byte $83
9905: f0 8e     BEQ   $9895
9907: f0 97     BEQ   $98A0
9909: f0 9b     BEQ   $98A6
990B: f0 ad     BEQ   $98BA
990D: f0 b7     BEQ   $98C6
990F: f0 cd     BEQ   $98DE
9911: f0 d9     BEQ   $98EC
9913: f0 f4     BEQ   $9909
9915: e1 02     SBC   ($02,X)
9917: e1 21     SBC   ($21,X)
9919: e1 32     SBC   ($32,X)
991B: e1 57     SBC   ($57,X)
991D: d1 6b     CMP   ($6B),Y
991F: d1 97     CMP   ($97),Y
9921: d1 af     CMP   ($AF),Y
9923: d1 e4     CMP   ($E4),Y
9925: C2        .byte $C2
9926: 01 c2     ORA   ($C2,X)
9928: 3F        .byte $3F
9929: C2        .byte $C2
992A: 61 c2     ADC   ($C2,X)
992C: AB        .byte $AB
992D: B2        .byte $B2
992E: D3        .byte $D3
992F: B3        .byte $B3
9930: 2B        .byte $2B
9931: B3        .byte $B3
9932: 5B        .byte $5B
9933: B3        .byte $B3
9934: c4 b3     CPY   $B3
9936: fa        NOP
9937: b4 76     LDY   $76,X
9939: b4 ba     LDY   $BA,X
993B: b5 4e     LDA   $4E,X
993D: b5 9e     LDA   $9E,X
993F: b6 4e     LDX   $4E,Y
9941: b6 ae     LDX   $AE,Y
9943: b6 ae     LDX   $AE,Y
9945: FF        .byte $FF
9946: 23        .byte $23
9947: 30 50     BMI   $9999
9949: 0c 40 06  NOP   $0640
994C: 30 03     BMI   $9951
994E: 22        .byte $22
994F: 30 00     BMI   $9951
9951: 00        BRK
9952: 24 30     BIT   $30
9954: 50 02     BVC   $9958
9956: 50 03     BVC   $995B
9958: 50 04     BVC   $995E
995A: 50 05     BVC   $9961
995C: 50 06     BVC   $9964
995E: 50 07     BVC   $9967
9960: 60        RTS
9961: 08        PHP
9962: 60        RTS
9963: 09 60     ORA   #$60
9965: 0a        ASL
9966: 60        RTS
9967: 0B        .byte $0B
9968: 70 0c     BVS   $9976
996A: 70 0d     BVS   $9979
996C: 70 0e     BVS   $997C
996E: 70 0f     BVS   $997F
9970: FF        .byte $FF
9971: e8        INX
9972: d9 f8 87  CMP   $87F8,Y
9975: 0a        ASL
9976: E3        .byte $E3
9977: 03        .byte $03
9978: d9 f7 84  CMP   $84F7,Y
997B: 06 e2     ASL   $E2
997D: 93        .byte $93
997E: 73        .byte $73
997F: 23        .byte $23
9980: da        NOP
9981: F7        .byte $F7
9982: 84 02     STY   $02
9984: E2        .byte $E2
9985: 4F        .byte $4F
9986: FF        .byte $FF
9987: d9 39 86  CMP   $8639,Y
998A: 0a        ASL
998B: E3        .byte $E3
998C: 53        .byte $53
998D: d9 3a 87  CMP   $873A,Y
9990: 05 e1     ORA   $E1
9992: 03        .byte $03
9993: E2        .byte $E2
9994: B3        .byte $B3
9995: 73        .byte $73
9996: da        NOP
9997: 38        SEC
9998: 85 03     STA   $03
999A: 95 e1     STA   $E1,X
999C: 21 47     AND   ($47,X)
999E: FF        .byte $FF
999F: d9 6f e3  CMP   $E36F,Y
99A2: 53        .byte $53
99A3: e1 43     SBC   ($43,X)
99A5: 23        .byte $23
99A6: E2        .byte $E2
99A7: B3        .byte $B3
99A8: da        NOP
99A9: 90 e3     BCC   $998E
99AB: 95 21     STA   $21,X
99AD: 97        .byte $97
99AE: FF        .byte $FF
99AF: d9 33 03  CMP   $0333,Y
99B2: 03        .byte $03
99B3: 33        .byte $33
99B4: da        NOP
99B5: 55 11     EOR   $11,X
99B7: 17        .byte $17
99B8: FF        .byte $FF
99B9: e1 40     SBC   ($40,X)
99BB: E2        .byte $E2
99BC: b0 e1     BCS   $999F
99BE: 60        RTS
99BF: 70 40     BVS   $9A01
99C1: E2        .byte $E2
99C2: b0 fe     BCS   $99C2
99C4: 04 b9     NOP   $B9
99C6: 99 e1 20  STA   $20E1,Y
99C9: E2        .byte $E2
99CA: 90 e1     BCC   $99AD
99CC: 40        RTI
99CD: 50 20     BVC   $99EF
99CF: E2        .byte $E2
99D0: 90 fe     BCC   $99D0
99D2: 04 c7     NOP   $C7
99D4: 99 e1 40  STA   $40E1,Y
99D7: E2        .byte $E2
99D8: b0 e1     BCS   $99BB
99DA: 60        RTS
99DB: 70 40     BVS   $9A1D
99DD: E2        .byte $E2
99DE: b0 fe     BCS   $99DE
99E0: 04 d5     NOP   $D5
99E2: 99 e1 70  STA   $70E1,Y
99E5: 20 90 a0  JSR   $A090
99E8: 70 20     BVS   $9A0A
99EA: fe 04 e3  INC   $E304,X
99ED: 99 ff da  STA   $DAFF,Y
99F0: F3        .byte $F3
99F1: 81 02     STA   ($02,X)
99F3: e1 40     SBC   ($40,X)
99F5: fd b9 99  SBC   $99B9,X
99F8: fd b9 99  SBC   $99B9,X
99FB: fd b9 99  SBC   $99B9,X
99FE: e1 40     SBC   ($40,X)
9A00: E2        .byte $E2
9A01: b0 e1     BCS   $99E4
9A03: 60        RTS
9A04: 70 40     BVS   $9A46
9A06: E2        .byte $E2
9A07: b0 fe     BCS   $9A07
9A09: 04 fe     NOP   $FE
9A0B: 99 e1 20  STA   $20E1,Y
9A0E: E2        .byte $E2
9A0F: 90 e1     BCC   $99F2
9A11: 40        RTI
9A12: 50 20     BVC   $9A34
9A14: E2        .byte $E2
9A15: 90 fe     BCC   $9A15
9A17: 04 0c     NOP   $0C
9A19: 9a        TXS
9A1A: da        NOP
9A1B: F3        .byte $F3
9A1C: 82        .byte $82
9A1D: 02        .byte $02
9A1E: e1 40     SBC   ($40,X)
9A20: E2        .byte $E2
9A21: b0 e1     BCS   $9A04
9A23: 60        RTS
9A24: 70 40     BVS   $9A66
9A26: E2        .byte $E2
9A27: b0 da     BCS   $9A03
9A29: F3        .byte $F3
9A2A: 82        .byte $82
9A2B: 02        .byte $02
9A2C: e1 40     SBC   ($40,X)
9A2E: E2        .byte $E2
9A2F: b0 e1     BCS   $9A12
9A31: 60        RTS
9A32: 70 40     BVS   $9A74
9A34: E2        .byte $E2
9A35: b0 da     BCS   $9A11
9A37: F2        .byte $F2
9A38: 81 02     STA   ($02,X)
9A3A: e1 40     SBC   ($40,X)
9A3C: E2        .byte $E2
9A3D: b0 e1     BCS   $9A20
9A3F: 60        RTS
9A40: 70 40     BVS   $9A82
9A42: E2        .byte $E2
9A43: b0 da     BCS   $9A1F
9A45: f1 81     SBC   ($81),Y
9A47: 02        .byte $02
9A48: e1 40     SBC   ($40,X)
9A4A: E2        .byte $E2
9A4B: b0 e1     BCS   $9A2E
9A4D: 60        RTS
9A4E: 70 40     BVS   $9A90
9A50: E2        .byte $E2
9A51: b0 da     BCS   $9A2D
9A53: f1 81     SBC   ($81),Y
9A55: 02        .byte $02
9A56: e1 20     SBC   ($20,X)
9A58: E2        .byte $E2
9A59: 90 e1     BCC   $9A3C
9A5B: 40        RTI
9A5C: 50 20     BVC   $9A7E
9A5E: E2        .byte $E2
9A5F: 90 ff     BCC   $9A60
9A61: da        NOP
9A62: f8        SED
9A63: 85 02     STA   $02
9A65: fd b9 99  SBC   $99B9,X
9A68: fd b9 99  SBC   $99B9,X
9A6B: fd b9 99  SBC   $99B9,X
9A6E: e1 40     SBC   ($40,X)
9A70: E2        .byte $E2
9A71: b0 e1     BCS   $9A54
9A73: 60        RTS
9A74: 70 40     BVS   $9AB6
9A76: E2        .byte $E2
9A77: b0 fe     BCS   $9A77
9A79: 04 6e     NOP   $6E
9A7B: 9a        TXS
9A7C: e1 20     SBC   ($20,X)
9A7E: E2        .byte $E2
9A7F: 90 e1     BCC   $9A62
9A81: 40        RTI
9A82: 50 20     BVC   $9AA4
9A84: E2        .byte $E2
9A85: 90 fe     BCC   $9A85
9A87: 04 7c     NOP   $7C
9A89: 9a        TXS
9A8A: da        NOP
9A8B: F7        .byte $F7
9A8C: 84 02     STY   $02
9A8E: e1 40     SBC   ($40,X)
9A90: E2        .byte $E2
9A91: b0 e1     BCS   $9A74
9A93: 60        RTS
9A94: 70 40     BVS   $9AD6
9A96: E2        .byte $E2
9A97: b0 da     BCS   $9A73
9A99: f6 83     INC   $83,X
9A9B: 02        .byte $02
9A9C: e1 40     SBC   ($40,X)
9A9E: E2        .byte $E2
9A9F: b0 e1     BCS   $9A82
9AA1: 60        RTS
9AA2: 70 40     BVS   $9AE4
9AA4: E2        .byte $E2
9AA5: b0 da     BCS   $9A81
9AA7: f5 83     SBC   $83,X
9AA9: 02        .byte $02
9AAA: e1 40     SBC   ($40,X)
9AAC: E2        .byte $E2
9AAD: b0 e1     BCS   $9A90
9AAF: 60        RTS
9AB0: 70 40     BVS   $9AF2
9AB2: E2        .byte $E2
9AB3: b0 da     BCS   $9A8F
9AB5: f4 83     NOP   $83
9AB7: 02        .byte $02
9AB8: e1 40     SBC   ($40,X)
9ABA: E2        .byte $E2
9ABB: b0 e1     BCS   $9A9E
9ABD: 60        RTS
9ABE: 70 40     BVS   $9B00
9AC0: E2        .byte $E2
9AC1: b0 da     BCS   $9A9D
9AC3: F3        .byte $F3
9AC4: 83        .byte $83
9AC5: 02        .byte $02
9AC6: e1 70     SBC   ($70,X)
9AC8: 20 90 a0  JSR   $A090
9ACB: 70 20     BVS   $9AED
9ACD: da        NOP
9ACE: F2        .byte $F2
9ACF: 82        .byte $82
9AD0: 02        .byte $02
9AD1: 70 20     BVS   $9AF3
9AD3: 90 a0     BCC   $9A75
9AD5: 70 20     BVS   $9AF7
9AD7: da        NOP
9AD8: f1 81     SBC   ($81),Y
9ADA: 02        .byte $02
9ADB: 70 20     BVS   $9AFD
9ADD: 90 a0     BCC   $9A7F
9ADF: 70 20     BVS   $9B01
9AE1: FF        .byte $FF
9AE2: da        NOP
9AE3: 90 e2     BCC   $9AC7
9AE5: 4a        LSR
9AE6: E3        .byte $E3
9AE7: b0 e2     BCS   $9ACB
9AE9: 49 60     EOR   #$60
9AEB: 70 2a     BVS   $9B17
9AED: E3        .byte $E3
9AEE: 90 e2     BCC   $9AD2
9AF0: 25 72     AND   $72
9AF2: 70 60     BVS   $9B54
9AF4: 50 49     BVC   $9B3F
9AF6: E3        .byte $E3
9AF7: b0 e2     BCS   $9ADB
9AF9: 40        RTI
9AFA: BB        .byte $BB
9AFB: 79 90 a0  ADC   $A090,Y
9AFE: e1 25     SBC   ($25,X)
9B00: E2        .byte $E2
9B01: 72        .byte $72
9B02: 70 60     BVS   $9B64
9B04: 50 fe     BVC   $9B04
9B06: 03        .byte $03
9B07: e4 9a     CPX   $9A
9B09: E2        .byte $E2
9B0A: 4a        LSR
9B0B: E3        .byte $E3
9B0C: b0 e2     BCS   $9AF0
9B0E: 49 60     EOR   #$60
9B10: 70 2a     BVS   $9B3C
9B12: E3        .byte $E3
9B13: 90 e2     BCC   $9AF7
9B15: 25 72     AND   $72
9B17: 70 60     BVS   $9B79
9B19: 50 e2     BVC   $9AFD
9B1B: 4a        LSR
9B1C: E3        .byte $E3
9B1D: b0 e2     BCS   $9B01
9B1F: 4B        .byte $4B
9B20: FF        .byte $FF
9B21: 05 06     ORA   $06
9B23: 07        .byte $07
9B24: 06 05     ASL   $05
9B26: 04 03     NOP   $03
9B28: FF        .byte $FF
9B29: 03        .byte $03
9B2A: 04 03     NOP   $03
9B2C: 02        .byte $02
9B2D: FF        .byte $FF
9B2E: 07        .byte $07
9B2F: 06 05     ASL   $05
9B31: 04 03     NOP   $03
9B33: 02        .byte $02
9B34: 01 00     ORA   ($00,X)
9B36: 00        BRK
9B37: 00        BRK
9B38: 02        .byte $02
9B39: 02        .byte $02
9B3A: FF        .byte $FF
9B3B: 06 05     ASL   $05
9B3D: 04 03     NOP   $03
9B3F: 02        .byte $02
9B40: 01 00     ORA   ($00,X)
9B42: 00        BRK
9B43: 00        BRK
9B44: 00        BRK
9B45: 01 01     ORA   ($01,X)
9B47: FF        .byte $FF
9B48: 07        .byte $07
9B49: 06 05     ASL   $05
9B4B: 04 03     NOP   $03
9B4D: 03        .byte $03
9B4E: 02        .byte $02
9B4F: 01 00     ORA   ($00,X)
9B51: 00        BRK
9B52: 00        BRK
9B53: 00        BRK
9B54: 00        BRK
9B55: 00        BRK
9B56: 00        BRK
9B57: 02        .byte $02
9B58: 02        .byte $02
9B59: FF        .byte $FF
9B5A: 07        .byte $07
9B5B: 06 05     ASL   $05
9B5D: 04 03     NOP   $03
9B5F: 00        BRK
9B60: 00        BRK
9B61: 00        BRK
9B62: 00        BRK
9B63: 00        BRK
9B64: 00        BRK
9B65: 00        BRK
9B66: 01 01     ORA   ($01,X)
9B68: 01 01     ORA   ($01,X)
9B6A: 01 01     ORA   ($01,X)
9B6C: FF        .byte $FF
9B6D: 05 04     ORA   $04
9B6F: 03        .byte $03
9B70: 02        .byte $02
9B71: 01 01     ORA   ($01,X)
9B73: 00        BRK
9B74: 00        BRK
9B75: 00        BRK
9B76: 00        BRK
9B77: 00        BRK
9B78: 00        BRK
9B79: 01 01     ORA   ($01,X)
9B7B: 01 01     ORA   ($01,X)
9B7D: 01 01     ORA   ($01,X)
9B7F: FF        .byte $FF
9B80: 06 05     ASL   $05
9B82: 04 03     NOP   $03
9B84: 02        .byte $02
9B85: 02        .byte $02
9B86: 02        .byte $02
9B87: 01 00     ORA   ($00,X)
9B89: 00        BRK
9B8A: 00        BRK
9B8B: 00        BRK
9B8C: 00        BRK
9B8D: 00        BRK
9B8E: 00        BRK
9B8F: 01 01     ORA   ($01,X)
9B91: FF        .byte $FF
9B92: ec 01 eb  CPX   $EB01
9B95: 2a        ROL
9B96: 22        .byte $22
9B97: d6 f7     DEC   $F7,X
9B99: 84 00     STY   $00
9B9B: e1 40     SBC   ($40,X)
9B9D: 20 e2 b0  JSR   $B0E2
9BA0: 90 b0     BCC   $9B52
9BA2: 90 70     BCC   $9C14
9BA4: 60        RTS
9BA5: 70 60     BVS   $9C07
9BA7: 40        RTI
9BA8: 20 40 e3  JSR   $E340
9BAB: 90 b0     BCC   $9B5D
9BAD: E2        .byte $E2
9BAE: 20 d6 f0  JSR   $F0D6
9BB1: 00        BRK
9BB2: 04 e2     NOP   $E2
9BB4: 49 b0     EOR   #$B0
9BB6: c0 90     CPY   #$90
9BB8: b1 e1     LDA   ($E1),Y
9BBA: 10 2f     BPL   $9BEB
9BBC: E2        .byte $E2
9BBD: 49 b0     EOR   #$B0
9BBF: c0 90     CPY   #$90
9BC1: b1 e1     LDA   ($E1),Y
9BC3: 10 e2     BPL   $9BA7
9BC5: 7e c0 fe  ROR   $FEC0,X
9BC8: 02        .byte $02
9BC9: AF        .byte $AF
9BCA: 9B        .byte $9B
9BCB: d6 f7     DEC   $F7,X
9BCD: 02        .byte $02
9BCE: 00        BRK
9BCF: E2        .byte $E2
9BD0: b0 c0     BCS   $9B92
9BD2: d6 f7     DEC   $F7,X
9BD4: 84 01     STY   $01
9BD6: B2        .byte $B2
9BD7: e1 12     SBC   ($12,X)
9BD9: d6 f7     DEC   $F7,X
9BDB: 02        .byte $02
9BDC: 00        BRK
9BDD: 20 c0 20  JSR   $20C0
9BE0: c0 d6     CPY   #$D6
9BE2: f1 80     SBC   ($80),Y
9BE4: 00        BRK
9BE5: c0 20     CPY   #$20
9BE7: c0 20     CPY   #$20
9BE9: d6 f7     DEC   $F7,X
9BEB: 02        .byte $02
9BEC: 00        BRK
9BED: e1 10     SBC   ($10,X)
9BEF: c0 d6     CPY   #$D6
9BF1: F7        .byte $F7
9BF2: 84 01     STY   $01
9BF4: 12        .byte $12
9BF5: 22        .byte $22
9BF6: d6 f7     DEC   $F7,X
9BF8: 02        .byte $02
9BF9: 00        BRK
9BFA: 40        RTI
9BFB: c0 40     CPY   #$40
9BFD: c0 20     CPY   #$20
9BFF: d6 f7     DEC   $F7,X
9C01: 84 01     STY   $01
9C03: 42        .byte $42
9C04: d6 f7     DEC   $F7,X
9C06: 02        .byte $02
9C07: 00        BRK
9C08: E2        .byte $E2
9C09: b0 c0     BCS   $9BCB
9C0B: d6 f7     DEC   $F7,X
9C0D: 84 01     STY   $01
9C0F: B2        .byte $B2
9C10: e1 12     SBC   ($12,X)
9C12: d6 f7     DEC   $F7,X
9C14: 02        .byte $02
9C15: 00        BRK
9C16: 20 c0 20  JSR   $20C0
9C19: c0 d6     CPY   #$D6
9C1B: f1 80     SBC   ($80),Y
9C1D: 00        BRK
9C1E: c0 20     CPY   #$20
9C20: c0 20     CPY   #$20
9C22: d6 f7     DEC   $F7,X
9C24: 02        .byte $02
9C25: 00        BRK
9C26: e1 10     SBC   ($10,X)
9C28: c0 d6     CPY   #$D6
9C2A: F7        .byte $F7
9C2B: 84 01     STY   $01
9C2D: 12        .byte $12
9C2E: 22        .byte $22
9C2F: d6 f7     DEC   $F7,X
9C31: 00        BRK
9C32: 00        BRK
9C33: 43        .byte $43
9C34: 93        .byte $93
9C35: d6 f7     DEC   $F7,X
9C37: 84 00     STY   $00
9C39: e1 60     SBC   ($60,X)
9C3B: 40        RTI
9C3C: e0 10     CPX   #$10
9C3E: e1 b0     SBC   ($B0,X)
9C40: 90 80     BCC   $9BC2
9C42: 60        RTS
9C43: 40        RTI
9C44: 60        RTS
9C45: 40        RTI
9C46: e1 10     SBC   ($10,X)
9C48: E2        .byte $E2
9C49: b0 e1     BCS   $9C2C
9C4B: 10 e2     BPL   $9C2F
9C4D: b0 90     BCS   $9BDF
9C4F: 80 eb     NOP   $EB
9C51: 2a        ROL
9C52: 24 d6     BIT   $D6
9C54: F7        .byte $F7
9C55: 85 01     STA   $01
9C57: E3        .byte $E3
9C58: B2        .byte $B2
9C59: c0 d6     CPY   #$D6
9C5B: F7        .byte $F7
9C5C: 04 00     NOP   $00
9C5E: b0 e2     BCS   $9C42
9C60: 11 20     ORA   ($20),Y
9C62: 61 41     ADC   ($41,X)
9C64: 20 11 e3  JSR   $E311
9C67: 90 d6     BCC   $9C3F
9C69: F7        .byte $F7
9C6A: 84 03     STY   $03
9C6C: BF        .byte $BF
9C6D: d6 f7     DEC   $F7,X
9C6F: 04 00     NOP   $00
9C71: 83        .byte $83
9C72: 90 b2     BCC   $9C26
9C74: E2        .byte $E2
9C75: 13        .byte $13
9C76: 20 42 63  JSR   $6342
9C79: 80 91     NOP   $91
9C7B: b0 e1     BCS   $9C5E
9C7D: 13        .byte $13
9C7E: E2        .byte $E2
9C7F: b0 eb     BCS   $9C6C
9C81: 2a        ROL
9C82: 22        .byte $22
9C83: d6 f7     DEC   $F7,X
9C85: 84 03     STY   $03
9C87: E3        .byte $E3
9C88: b0 e2     BCS   $9C6C
9C8A: 20 40 60  JSR   $6040
9C8D: 40        RTI
9C8E: 60        RTS
9C8F: E3        .byte $E3
9C90: b1 b0     LDA   ($B0),Y
9C92: E2        .byte $E2
9C93: 20 40 61  JSR   $6140
9C96: 90 80     BCC   $9C18
9C98: 90 81     BCC   $9C1B
9C9A: 40        RTI
9C9B: 6F        .byte $6F
9C9C: E3        .byte $E3
9C9D: 83        .byte $83
9C9E: 90 b2     BCC   $9C52
9CA0: E2        .byte $E2
9CA1: 13        .byte $13
9CA2: 20 42 60  JSR   $6042
9CA5: 60        RTS
9CA6: 60        RTS
9CA7: c0 60     CPY   #$60
9CA9: 81 90     STA   ($90,X)
9CAB: e1 13     SBC   ($13,X)
9CAD: E2        .byte $E2
9CAE: B3        .byte $B3
9CAF: d6 f7     DEC   $F7,X
9CB1: 05 00     ORA   $00
9CB3: E2        .byte $E2
9CB4: 90 90     BCC   $9C46
9CB6: 90 92     BCC   $9C4A
9CB8: 90 90     BCC   $9C4A
9CBA: 90 91     BCC   $9C4D
9CBC: 91 d6     STA   ($D6),Y
9CBE: F7        .byte $F7
9CBF: 84 03     STY   $03
9CC1: 82        .byte $82
9CC2: d6 f7     DEC   $F7,X
9CC4: 05 00     ORA   $00
9CC6: 60        RTS
9CC7: 60        RTS
9CC8: 60        RTS
9CC9: 62        .byte $62
9CCA: 60        RTS
9CCB: 60        RTS
9CCC: 60        RTS
9CCD: 61 61     ADC   ($61,X)
9CCF: d6 f7     DEC   $F7,X
9CD1: 84 03     STY   $03
9CD3: 82        .byte $82
9CD4: d6 f7     DEC   $F7,X
9CD6: 05 00     ORA   $00
9CD8: 90 90     BCC   $9C6A
9CDA: 90 92     BCC   $9C6E
9CDC: 90 90     BCC   $9C6E
9CDE: 90 91     BCC   $9C71
9CE0: 91 d6     STA   ($D6),Y
9CE2: F7        .byte $F7
9CE3: 84 03     STY   $03
9CE5: 82        .byte $82
9CE6: d6 f7     DEC   $F7,X
9CE8: 05 00     ORA   $00
9CEA: 60        RTS
9CEB: 60        RTS
9CEC: 60        RTS
9CED: 62        .byte $62
9CEE: 60        RTS
9CEF: 80 90     NOP   $90
9CF1: b0 e1     BCS   $9CD4
9CF3: 10 e2     BPL   $9CD7
9CF5: b1 d6     LDA   ($D6),Y
9CF7: F7        .byte $F7
9CF8: 84 03     STY   $03
9CFA: 82        .byte $82
9CFB: d6 f7     DEC   $F7,X
9CFD: 05 00     ORA   $00
9CFF: e1 10     SBC   ($10,X)
9D01: 10 10     BPL   $9D13
9D03: 12        .byte $12
9D04: 10 10     BPL   $9D16
9D06: 10 11     BPL   $9D19
9D08: 11 d6     ORA   ($D6),Y
9D0A: F7        .byte $F7
9D0B: 84 03     STY   $03
9D0D: E2        .byte $E2
9D0E: B2        .byte $B2
9D0F: d6 f7     DEC   $F7,X
9D11: 05 00     ORA   $00
9D13: 90 90     BCC   $9CA5
9D15: 90 92     BCC   $9CA9
9D17: 90 90     BCC   $9CA9
9D19: 90 91     BCC   $9CAC
9D1B: 91 d6     STA   ($D6),Y
9D1D: F7        .byte $F7
9D1E: 84 03     STY   $03
9D20: B2        .byte $B2
9D21: d6 f7     DEC   $F7,X
9D23: 05 00     ORA   $00
9D25: e1 10     SBC   ($10,X)
9D27: 10 10     BPL   $9D39
9D29: 12        .byte $12
9D2A: 10 10     BPL   $9D3C
9D2C: 10 11     BPL   $9D3F
9D2E: 11 d6     ORA   ($D6),Y
9D30: F7        .byte $F7
9D31: 84 03     STY   $03
9D33: 22        .byte $22
9D34: d6 f7     DEC   $F7,X
9D36: 05 00     ORA   $00
9D38: 40        RTI
9D39: 40        RTI
9D3A: 40        RTI
9D3B: 42        .byte $42
9D3C: 40        RTI
9D3D: 40        RTI
9D3E: 40        RTI
9D3F: 43        .byte $43
9D40: d6 f8     DEC   $F8,X
9D42: 00        BRK
9D43: 00        BRK
9D44: E3        .byte $E3
9D45: b0 e2     BCS   $9D29
9D47: 20 40 60  JSR   $6040
9D4A: 40        RTI
9D4B: 60        RTS
9D4C: E3        .byte $E3
9D4D: b1 b0     LDA   ($B0),Y
9D4F: E2        .byte $E2
9D50: 20 40 60  JSR   $6040
9D53: 40        RTI
9D54: 60        RTS
9D55: 91 90     STA   ($90),Y
9D57: 80 90     NOP   $90
9D59: 60        RTS
9D5A: 40        RTI
9D5B: 60        RTS
9D5C: E3        .byte $E3
9D5D: b1 b0     LDA   ($B0),Y
9D5F: E2        .byte $E2
9D60: 20 40 c0  JSR   $C040
9D63: 60        RTS
9D64: c0 80     CPY   #$80
9D66: c0 92     CPY   #$92
9D68: fe ff af  INC   $AFFF,X
9D6B: 9B        .byte $9B
9D6C: ec 01 e8  CPX   $E801
9D6F: d6 f6     DEC   $F6,X
9D71: 01 04     ORA   ($04,X)
9D73: E2        .byte $E2
9D74: b0 90     BCS   $9D06
9D76: 60        RTS
9D77: 40        RTI
9D78: 60        RTS
9D79: 40        RTI
9D7A: 20 10 20  JSR   $2010
9D7D: 10 e3     BPL   $9D62
9D7F: b0 90     BCS   $9D11
9D81: 90 40     BCC   $9DC3
9D83: 60        RTS
9D84: 90 d6     BCC   $9D5C
9D86: f6 01     INC   $01,X
9D88: 04 e3     NOP   $E3
9D8A: b9 e2 60  LDA   $60E2,Y
9D8D: c0 40     CPY   #$40
9D8F: 61 70     ADC   ($70,X)
9D91: 9F        .byte $9F
9D92: E3        .byte $E3
9D93: b9 e2 60  LDA   $60E2,Y
9D96: c0 40     CPY   #$40
9D98: 61 80     ADC   ($80,X)
9D9A: 2e c0 fe  ROL   $FEC0
9D9D: 02        .byte $02
9D9E: 89        .byte $89
9D9F: 9d d6 f7  STA   $F7D6,X
9DA2: 03        .byte $03
9DA3: 00        BRK
9DA4: E2        .byte $E2
9DA5: 60        RTS
9DA6: c0 62     CPY   #$62
9DA8: 82        .byte $82
9DA9: 90 c0     BCC   $9D6B
9DAB: 90 c0     BCC   $9D6D
9DAD: d6 b6     DEC   $B6,X
9DAF: 85 00     STA   $00
9DB1: c0 e2     CPY   #$E2
9DB3: 60        RTS
9DB4: 90 b0     BCC   $9D66
9DB6: d6 f7     DEC   $F7,X
9DB8: 03        .byte $03
9DB9: 00        BRK
9DBA: E2        .byte $E2
9DBB: 80 c0     NOP   $C0
9DBD: 82        .byte $82
9DBE: 92        .byte $92
9DBF: b0 c0     BCS   $9D81
9DC1: b0 c0     BCS   $9D83
9DC3: 90 d6     BCC   $9D9B
9DC5: f4 81     NOP   $81
9DC7: 00        BRK
9DC8: B2        .byte $B2
9DC9: d6 f7     DEC   $F7,X
9DCB: 03        .byte $03
9DCC: 00        BRK
9DCD: E2        .byte $E2
9DCE: 60        RTS
9DCF: c0 62     CPY   #$62
9DD1: 82        .byte $82
9DD2: 90 c0     BCC   $9D94
9DD4: 90 c0     BCC   $9D96
9DD6: d6 b6     DEC   $B6,X
9DD8: 85 00     STA   $00
9DDA: c0 e2     CPY   #$E2
9DDC: 60        RTS
9DDD: 90 b0     BCC   $9D8F
9DDF: d6 f7     DEC   $F7,X
9DE1: 03        .byte $03
9DE2: 00        BRK
9DE3: E2        .byte $E2
9DE4: 80 c0     NOP   $C0
9DE6: 82        .byte $82
9DE7: 92        .byte $92
9DE8: d6 f5     DEC   $F5,X
9DEA: 83        .byte $83
9DEB: 00        BRK
9DEC: B3        .byte $B3
9DED: e1 43     SBC   ($43,X)
9DEF: d6 f3     DEC   $F3,X
9DF1: 81 00     STA   ($00,X)
9DF3: e1 60     SBC   ($60,X)
9DF5: 40        RTI
9DF6: 60        RTS
9DF7: 40        RTI
9DF8: e0 10     CPX   #$10
9DFA: e1 b0     SBC   ($B0,X)
9DFC: 90 80     BCC   $9D7E
9DFE: 60        RTS
9DFF: 40        RTI
9E00: 60        RTS
9E01: 40        RTI
9E02: e1 10     SBC   ($10,X)
9E04: E2        .byte $E2
9E05: b0 e1     BCS   $9DE8
9E07: 10 e2     BPL   $9DEB
9E09: b0 d6     BCS   $9DE1
9E0B: f5 83     SBC   $83,X
9E0D: 03        .byte $03
9E0E: E3        .byte $E3
9E0F: 63        .byte $63
9E10: d6 f7     DEC   $F7,X
9E12: 07        .byte $07
9E13: 03        .byte $03
9E14: 60        RTS
9E15: E2        .byte $E2
9E16: 11 20     ORA   ($20),Y
9E18: 61 41     ADC   ($41,X)
9E1A: 20 11 e3  JSR   $E311
9E1D: 90 d6     BCC   $9DF5
9E1F: F7        .byte $F7
9E20: 86 00     STX   $00
9E22: e4 b0     CPX   $B0
9E24: b0 b1     BCS   $9DD7
9E26: b0 d6     BCS   $9DFE
9E28: F7        .byte $F7
9E29: 85 00     STA   $00
9E2B: E3        .byte $E3
9E2C: 12        .byte $12
9E2D: 22        .byte $22
9E2E: e4 b0     CPX   $B0
9E30: E3        .byte $E3
9E31: 40        RTI
9E32: 62        .byte $62
9E33: d6 f5     DEC   $F5,X
9E35: 07        .byte $07
9E36: 00        BRK
9E37: E3        .byte $E3
9E38: 43        .byte $43
9E39: 60        RTS
9E3A: 82        .byte $82
9E3B: 93        .byte $93
9E3C: b0 e2     BCS   $9E20
9E3E: 12        .byte $12
9E3F: 23        .byte $23
9E40: 20 41 60  JSR   $6041
9E43: 93        .byte $93
9E44: 80 d6     NOP   $D6
9E46: F7        .byte $F7
9E47: 84 03     STY   $03
9E49: E3        .byte $E3
9E4A: b0 e2     BCS   $9E2E
9E4C: 20 40 60  JSR   $6040
9E4F: 40        RTI
9E50: 60        RTS
9E51: E3        .byte $E3
9E52: b1 b0     LDA   ($B0),Y
9E54: E2        .byte $E2
9E55: 20 40 61  JSR   $6140
9E58: 90 80     BCC   $9DDA
9E5A: 90 81     BCC   $9DDD
9E5C: 40        RTI
9E5D: d6 37     DEC   $37,X
9E5F: 84 03     STY   $03
9E61: E2        .byte $E2
9E62: 60        RTS
9E63: 40        RTI
9E64: 60        RTS
9E65: E3        .byte $E3
9E66: b1 b0     LDA   ($B0),Y
9E68: E2        .byte $E2
9E69: 20 40 61  JSR   $6140
9E6C: 90 80     BCC   $9DEE
9E6E: 90 b1     BCC   $9E21
9E70: e1 10     SBC   ($10,X)
9E72: d6 f7     DEC   $F7,X
9E74: 84 03     STY   $03
9E76: E3        .byte $E3
9E77: 43        .byte $43
9E78: 60        RTS
9E79: 82        .byte $82
9E7A: 93        .byte $93
9E7B: b0 e2     BCS   $9E5F
9E7D: 12        .byte $12
9E7E: 20 20 20  JSR   $2020
9E81: c0 20     CPY   #$20
9E83: 41 60     EOR   ($60,X)
9E85: 93        .byte $93
9E86: 83        .byte $83
9E87: d6 f7     DEC   $F7,X
9E89: 06 00     ASL   $00
9E8B: E2        .byte $E2
9E8C: 60        RTS
9E8D: 60        RTS
9E8E: 60        RTS
9E8F: 62        .byte $62
9E90: 60        RTS
9E91: 60        RTS
9E92: 60        RTS
9E93: 61 61     ADC   ($61,X)
9E95: 42        .byte $42
9E96: 20 20 20  JSR   $2020
9E99: 22        .byte $22
9E9A: 20 20 20  JSR   $2020
9E9D: 21 21     AND   ($21,X)
9E9F: 42        .byte $42
9EA0: 60        RTS
9EA1: 60        RTS
9EA2: 60        RTS
9EA3: 62        .byte $62
9EA4: 60        RTS
9EA5: 60        RTS
9EA6: 60        RTS
9EA7: 61 61     ADC   ($61,X)
9EA9: 42        .byte $42
9EAA: 20 20 20  JSR   $2020
9EAD: 22        .byte $22
9EAE: 20 40 60  JSR   $6040
9EB1: 80 90     NOP   $90
9EB3: 81 42     STA   ($42,X)
9EB5: 90 90     BCC   $9E47
9EB7: 90 92     BCC   $9E4B
9EB9: 90 90     BCC   $9E4B
9EBB: 90 91     BCC   $9E4E
9EBD: 91 82     STA   ($82),Y
9EBF: 60        RTS
9EC0: 60        RTS
9EC1: 60        RTS
9EC2: 62        .byte $62
9EC3: 60        RTS
9EC4: 60        RTS
9EC5: 60        RTS
9EC6: 61 61     ADC   ($61,X)
9EC8: 82        .byte $82
9EC9: 90 90     BCC   $9E5B
9ECB: 90 92     BCC   $9E5F
9ECD: 90 90     BCC   $9E5F
9ECF: 90 91     BCC   $9E62
9ED1: 81 92     STA   ($92,X)
9ED3: b0 b0     BCS   $9E85
9ED5: b0 b2     BCS   $9E89
9ED7: b0 b0     BCS   $9E89
9ED9: b0 b3     BCS   $9E8E
9EDB: d6 f6     DEC   $F6,X
9EDD: 00        BRK
9EDE: 00        BRK
9EDF: E3        .byte $E3
9EE0: 60        RTS
9EE1: b0 e2     BCS   $9EC5
9EE3: 10 20     BPL   $9F05
9EE5: 10 20     BPL   $9F07
9EE7: E3        .byte $E3
9EE8: 61 60     ADC   ($60,X)
9EEA: b0 e2     BCS   $9ECE
9EEC: 10 20     BPL   $9F0E
9EEE: 10 20     BPL   $9F10
9EF0: 61 60     ADC   ($60,X)
9EF2: 40        RTI
9EF3: 60        RTS
9EF4: 20 10 20  JSR   $2010
9EF7: E3        .byte $E3
9EF8: 61 60     ADC   ($60,X)
9EFA: b0 e2     BCS   $9EDE
9EFC: 10 c0     BPL   $9EBE
9EFE: d6 f6     DEC   $F6,X
9F00: 01 04     ORA   ($04,X)
9F02: 20 c0 40  JSR   $40C0
9F05: c0 62     CPY   #$62
9F07: fe ff 89  INC   $89FF,X
9F0A: 9d ec 01  STA   $01EC,X
9F0D: d6 12     DEC   $12,X
9F0F: e1 40     SBC   ($40,X)
9F11: 20 e2 b0  JSR   $B0E2
9F14: 90 b0     BCC   $9EC6
9F16: 90 70     BCC   $9F88
9F18: 60        RTS
9F19: 70 60     BVS   $9F7B
9F1B: 40        RTI
9F1C: 20 40 e3  JSR   $E340
9F1F: 90 b0     BCC   $9ED1
9F21: E2        .byte $E2
9F22: 20 d6 0f  JSR   $0FD6
9F25: E3        .byte $E3
9F26: b0 90     BCS   $9EB8
9F28: b0 41     BCS   $9F6B
9F2A: 40        RTI
9F2B: 70 90     BVS   $9EBD
9F2D: b0 90     BCS   $9EBF
9F2F: b0 e2     BCS   $9F13
9F31: 21 20     AND   ($20,X)
9F33: 10 20     BPL   $9F55
9F35: E3        .byte $E3
9F36: b0 90     BCS   $9EC8
9F38: b0 41     BCS   $9F7B
9F3A: 40        RTI
9F3B: 70 90     BVS   $9ECD
9F3D: b0 c0     BCS   $9EFF
9F3F: E2        .byte $E2
9F40: 20 e3 b0  JSR   $B0E3
9F43: E2        .byte $E2
9F44: 20 11 e3  JSR   $E311
9F47: 90 fe     BCC   $9F47
9F49: 03        .byte $03
9F4A: 23        .byte $23
9F4B: 9F        .byte $9F
9F4C: E3        .byte $E3
9F4D: b0 90     BCS   $9EDF
9F4F: b0 41     BCS   $9F92
9F51: 40        RTI
9F52: 70 90     BVS   $9EE4
9F54: b0 90     BCS   $9EE6
9F56: b0 e2     BCS   $9F3A
9F58: 21 20     AND   ($20,X)
9F5A: 10 20     BPL   $9F7C
9F5C: E3        .byte $E3
9F5D: b0 90     BCS   $9EEF
9F5F: b0 41     BCS   $9FA2
9F61: 40        RTI
9F62: 70 90     BVS   $9EF4
9F64: b0 90     BCS   $9EF6
9F66: b0 e2     BCS   $9F4A
9F68: 21 20     AND   ($20,X)
9F6A: 40        RTI
9F6B: 60        RTS
9F6C: d6 12     DEC   $12,X
9F6E: E3        .byte $E3
9F6F: b1 b2     LDA   ($B2),Y
9F71: E2        .byte $E2
9F72: 12        .byte $12
9F73: 21 e3     AND   ($E3,X)
9F75: b0 e2     BCS   $9F59
9F77: 41 60     EOR   ($60,X)
9F79: 90 b0     BCC   $9F2B
9F7B: 11 11     ORA   ($11),Y
9F7D: c0 22     CPY   #$22
9F7F: 41 41     EOR   ($41,X)
9F81: 20 d6 7f  JSR   $7FD6
9F84: 40        RTI
9F85: 40        RTI
9F86: 40        RTI
9F87: d6 12     DEC   $12,X
9F89: E3        .byte $E3
9F8A: b1 b2     LDA   ($B2),Y
9F8C: E2        .byte $E2
9F8D: 12        .byte $12
9F8E: 21 e3     AND   ($E3,X)
9F90: b0 e2     BCS   $9F74
9F92: 41 60     EOR   ($60,X)
9F94: 90 b0     BCC   $9F46
9F96: 11 12     ORA   ($12),Y
9F98: 22        .byte $22
9F99: E2        .byte $E2
9F9A: d6 7f     DEC   $7F,X
9F9C: 40        RTI
9F9D: 40        RTI
9F9E: 40        RTI
9F9F: 40        RTI
9FA0: 90 90     BCC   $9F32
9FA2: 90 90     BCC   $9F34
9FA4: d6 10     DEC   $10,X
9FA6: e1 60     SBC   ($60,X)
9FA8: 40        RTI
9FA9: e0 10     CPX   #$10
9FAB: e1 b0     SBC   ($B0,X)
9FAD: 90 80     BCC   $9F2F
9FAF: 60        RTS
9FB0: 40        RTI
9FB1: 60        RTS
9FB2: 40        RTI
9FB3: 10 e2     BPL   $9F97
9FB5: b0 e1     BCS   $9F98
9FB7: 10 e2     BPL   $9F9B
9FB9: b0 90     BCS   $9F4B
9FBB: 80 d6     NOP   $D6
9FBD: 10 e3     BPL   $9FA2
9FBF: b1 b1     LDA   ($B1),Y
9FC1: b0 e2     BCS   $9FA5
9FC3: 11 20     ORA   ($20),Y
9FC5: E3        .byte $E3
9FC6: b1 e2     LDA   ($E2),Y
9FC8: 10 21     BPL   $9FEB
9FCA: E3        .byte $E3
9FCB: 60        RTS
9FCC: 90 a0     BCC   $9F6E
9FCE: b0 b0     BCS   $9F80
9FD0: b1 b0     LDA   ($B0),Y
9FD2: d6 1a     DEC   $1A,X
9FD4: E2        .byte $E2
9FD5: 12        .byte $12
9FD6: 22        .byte $22
9FD7: d6 10     DEC   $10,X
9FD9: E3        .byte $E3
9FDA: b0 e2     BCS   $9FBE
9FDC: 40        RTI
9FDD: d6 7f     DEC   $7F,X
9FDF: 60        RTS
9FE0: 60        RTS
9FE1: 60        RTS
9FE2: d6 0f     DEC   $0F,X
9FE4: 41 40     EOR   ($40,X)
9FE6: 40        RTI
9FE7: 41 40     EOR   ($40,X)
9FE9: 40        RTI
9FEA: E3        .byte $E3
9FEB: 91 90     STA   ($90),Y
9FED: 90 91     BCC   $9F80
9FEF: 90 90     BCC   $9F81
9FF1: E2        .byte $E2
9FF2: 21 20     AND   ($20,X)
9FF4: 20 21 20  JSR   $2021
9FF7: 20 e3 61  JSR   $61E3
9FFA: 60        RTS
9FFB: 60        RTS
9FFC: 40        RTI
9FFD: 60        RTS
9FFE: 80 90     NOP   $90
A000: b1 b0     LDA   ($B0),Y
A002: b0 fe     BCS   $A002
A004: 04 00     NOP   $00
A006: a0 e2     LDY   #$E2
A008: 21 20     AND   ($20,X)
A00A: 20 fe 04  JSR   $04FE
A00D: 07        .byte $07
A00E: a0 41     LDY   #$41
A010: 40        RTI
A011: 40        RTI
A012: 41 40     EOR   ($40,X)
A014: 40        RTI
A015: E3        .byte $E3
A016: 91 90     STA   ($90),Y
A018: 90 91     BCC   $9FAB
A01A: 90 90     BCC   $9FAC
A01C: E2        .byte $E2
A01D: 20 20 21  JSR   $2120
A020: d6 20     DEC   $20,X
A022: 20 41 20  JSR   $2041
A025: d6 3f     DEC   $3F,X
A027: 63        .byte $63
A028: 43        .byte $43
A029: d6 10     DEC   $10,X
A02B: E2        .byte $E2
A02C: 60        RTS
A02D: 60        RTS
A02E: 60        RTS
A02F: 60        RTS
A030: c1 60     CMP   ($60,X)
A032: 60        RTS
A033: 60        RTS
A034: 60        RTS
A035: c0 60     CPY   #$60
A037: c0 d6     CPY   #$D6
A039: 2F        .byte $2F
A03A: 42        .byte $42
A03B: d6 10     DEC   $10,X
A03D: 20 20 20  JSR   $2020
A040: 20 c1 20  JSR   $20C1
A043: 20 20 20  JSR   $2020
A046: c0 20     CPY   #$20
A048: c0 d6     CPY   #$D6
A04A: 2F        .byte $2F
A04B: 42        .byte $42
A04C: d6 10     DEC   $10,X
A04E: 60        RTS
A04F: 60        RTS
A050: 60        RTS
A051: 60        RTS
A052: c1 60     CMP   ($60,X)
A054: 60        RTS
A055: 60        RTS
A056: 60        RTS
A057: c0 60     CPY   #$60
A059: c0 d6     CPY   #$D6
A05B: 2F        .byte $2F
A05C: 42        .byte $42
A05D: d6 10     DEC   $10,X
A05F: 20 20 20  JSR   $2020
A062: 20 c1 20  JSR   $20C1
A065: 40        RTI
A066: 60        RTS
A067: 80 90     NOP   $90
A069: 80 c0     NOP   $C0
A06B: d6 2f     DEC   $2F,X
A06D: 42        .byte $42
A06E: d6 10     DEC   $10,X
A070: 60        RTS
A071: 60        RTS
A072: 60        RTS
A073: 60        RTS
A074: c1 60     CMP   ($60,X)
A076: 60        RTS
A077: 60        RTS
A078: 60        RTS
A079: c0 60     CPY   #$60
A07B: c0 40     CPY   #$40
A07D: 60        RTS
A07E: 80 20     NOP   $20
A080: 20 20 20  JSR   $2020
A083: c1 20     CMP   ($20,X)
A085: 20 20 20  JSR   $2020
A088: c0 20     CPY   #$20
A08A: c0 20     CPY   #$20
A08C: 20 40 60  JSR   $6040
A08F: 60        RTS
A090: 60        RTS
A091: 60        RTS
A092: c1 60     CMP   ($60,X)
A094: 60        RTS
A095: 60        RTS
A096: 60        RTS
A097: c0 60     CPY   #$60
A099: c0 20     CPY   #$20
A09B: 40        RTI
A09C: 60        RTS
A09D: 40        RTI
A09E: 40        RTI
A09F: 40        RTI
A0A0: 40        RTI
A0A1: c1 40     CMP   ($40,X)
A0A3: 40        RTI
A0A4: 40        RTI
A0A5: 40        RTI
A0A6: c1 c3     CMP   ($C3,X)
A0A8: CF        .byte $CF
A0A9: C7        .byte $C7
A0AA: d6 10     DEC   $10,X
A0AC: E3        .byte $E3
A0AD: c0 60     CPY   #$60
A0AF: c0 80     CPY   #$80
A0B1: c0 d6     CPY   #$D6
A0B3: 2F        .byte $2F
A0B4: 92        .byte $92
A0B5: fe ff 23  INC   $23FF,X
A0B8: 9F        .byte $9F
A0B9: d6 00     DEC   $00,X
A0BB: 00        BRK
A0BC: 00        BRK
A0BD: 00        BRK
A0BE: fe 03 b9  INC   $B903,X
A0C1: a0 40     LDY   #$40
A0C3: 40        RTI
A0C4: 30 40     BMI   $A106
A0C6: 30 30     BMI   $A0F8
A0C8: 30 30     BMI   $A0FA
A0CA: 20 00 30  JSR   $3000
A0CD: 30 00     BMI   $A0CF
A0CF: 10 00     BPL   $A0D1
A0D1: 10 20     BPL   $A0F3
A0D3: 30 30     BMI   $A105
A0D5: 30 30     BMI   $A107
A0D7: 30 30     BMI   $A109
A0D9: 30 20     BMI   $A0FB
A0DB: 00        BRK
A0DC: 30 30     BMI   $A10E
A0DE: 00        BRK
A0DF: 10 00     BPL   $A0E1
A0E1: 10 20     BPL   $A103
A0E3: 40        RTI
A0E4: 30 40     BMI   $A126
A0E6: fe 03 c6  INC   $C603,X
A0E9: a0 30     LDY   #$30
A0EB: 30 30     BMI   $A11D
A0ED: 30 20     BMI   $A10F
A0EF: 00        BRK
A0F0: 30 30     BMI   $A122
A0F2: 00        BRK
A0F3: 10 00     BPL   $A0F5
A0F5: 10 20     BPL   $A117
A0F7: 30 30     BMI   $A129
A0F9: 30 30     BMI   $A12B
A0FB: 30 30     BMI   $A12D
A0FD: 30 20     BMI   $A11F
A0FF: 00        BRK
A100: 30 30     BMI   $A132
A102: 20 20 00  JSR   $0020
A105: 20 20 00  JSR   $0020
A108: 20 20 40  JSR   $4020
A10B: 00        BRK
A10C: 40        RTI
A10D: 30 00     BMI   $A10F
A10F: 20 00 30  JSR   $3000
A112: 40        RTI
A113: 10 40     BPL   $A155
A115: 10 00     BPL   $A117
A117: 30 30     BMI   $A149
A119: 30 40     BMI   $A15B
A11B: 00        BRK
A11C: 40        RTI
A11D: 30 00     BMI   $A11F
A11F: 40        RTI
A120: 00        BRK
A121: 30 40     BMI   $A163
A123: 10 40     BPL   $A165
A125: 10 40     BPL   $A167
A127: 40        RTI
A128: 30 30     BMI   $A15A
A12A: 40        RTI
A12B: 00        BRK
A12C: 40        RTI
A12D: 30 00     BMI   $A12F
A12F: 40        RTI
A130: 00        BRK
A131: 30 40     BMI   $A173
A133: 10 40     BPL   $A175
A135: 10 00     BPL   $A137
A137: 30 30     BMI   $A169
A139: 30 40     BMI   $A17B
A13B: 00        BRK
A13C: 40        RTI
A13D: 30 00     BMI   $A13F
A13F: 40        RTI
A140: 00        BRK
A141: 30 40     BMI   $A183
A143: 10 40     BPL   $A185
A145: 10 40     BPL   $A187
A147: 40        RTI
A148: 30 40     BMI   $A18A
A14A: 30 00     BMI   $A14C
A14C: 00        BRK
A14D: 00        BRK
A14E: 10 00     BPL   $A150
A150: 00        BRK
A151: 00        BRK
A152: 30 00     BMI   $A154
A154: 00        BRK
A155: 00        BRK
A156: 40        RTI
A157: 00        BRK
A158: 40        RTI
A159: 40        RTI
A15A: 30 30     BMI   $A18C
A15C: 30 30     BMI   $A18E
A15E: 20 00 30  JSR   $3000
A161: 30 00     BMI   $A163
A163: 10 00     BPL   $A165
A165: 10 20     BPL   $A187
A167: 30 30     BMI   $A199
A169: 30 30     BMI   $A19B
A16B: 30 30     BMI   $A19D
A16D: 30 20     BMI   $A18F
A16F: 00        BRK
A170: 30 30     BMI   $A1A2
A172: 00        BRK
A173: 10 00     BPL   $A175
A175: 10 20     BPL   $A197
A177: 30 40     BMI   $A1B9
A179: 40        RTI
A17A: 30 30     BMI   $A1AC
A17C: 30 30     BMI   $A1AE
A17E: 20 00 30  JSR   $3000
A181: 30 00     BMI   $A183
A183: 10 00     BPL   $A185
A185: 10 20     BPL   $A1A7
A187: 30 30     BMI   $A1B9
A189: 30 30     BMI   $A1BB
A18B: 30 30     BMI   $A1BD
A18D: 30 20     BMI   $A1AF
A18F: 00        BRK
A190: 30 30     BMI   $A1C2
A192: 00        BRK
A193: 10 00     BPL   $A195
A195: 10 30     BPL   $A1C7
A197: 40        RTI
A198: 40        RTI
A199: 40        RTI
A19A: 30 30     BMI   $A1CC
A19C: 30 30     BMI   $A1CE
A19E: 20 00 30  JSR   $3000
A1A1: 30 00     BMI   $A1A3
A1A3: 10 00     BPL   $A1A5
A1A5: 10 20     BPL   $A1C7
A1A7: 30 30     BMI   $A1D9
A1A9: 30 fe     BMI   $A1A9
A1AB: 03        .byte $03
A1AC: 9a        TXS
A1AD: a1 40     LDA   ($40,X)
A1AF: 40        RTI
A1B0: 40        RTI
A1B1: 00        BRK
A1B2: 40        RTI
A1B3: 41 40     EOR   ($40,X)
A1B5: 20 01 00  JSR   $0001
A1B8: 20 01 00  JSR   $0001
A1BB: 30 30     BMI   $A1ED
A1BD: 30 30     BMI   $A1EF
A1BF: 20 00 30  JSR   $3000
A1C2: 30 30     BMI   $A1F4
A1C4: 10 00     BPL   $A1C6
A1C6: 10 20     BPL   $A1E8
A1C8: 31 30     AND   ($30),Y
A1CA: fe 03 bb  INC   $BB03,X
A1CD: a1 30     LDA   ($30,X)
A1CF: 30 30     BMI   $A201
A1D1: 30 20     BMI   $A1F3
A1D3: 00        BRK
A1D4: 40        RTI
A1D5: 40        RTI
A1D6: 40        RTI
A1D7: 20 40 20  JSR   $2040
A1DA: 10 40     BPL   $A21C
A1DC: 30 30     BMI   $A20E
A1DE: 30 30     BMI   $A210
A1E0: 30 30     BMI   $A212
A1E2: 20 00 30  JSR   $3000
A1E5: 30 30     BMI   $A217
A1E7: 10 00     BPL   $A1E9
A1E9: 10 20     BPL   $A20B
A1EB: 31 30     AND   ($30),Y
A1ED: fe 03 de  INC   $DE03,X
A1F0: a1 40     LDA   ($40,X)
A1F2: 40        RTI
A1F3: 40        RTI
A1F4: 40        RTI
A1F5: 10 00     BPL   $A1F7
A1F7: 40        RTI
A1F8: 40        RTI
A1F9: 40        RTI
A1FA: 40        RTI
A1FB: c1 c3     CMP   ($C3,X)
A1FD: 33        .byte $33
A1FE: fe 06 fd  INC   $FD06,X
A201: a1 30     LDA   ($30,X)
A203: 40        RTI
A204: 30 40     BMI   $A246
A206: 30 40     BMI   $A248
A208: 00        BRK
A209: 30 fe     BMI   $A209
A20B: FF        .byte $FF
A20C: c6 a0     DEC   $A0
A20E: 07        .byte $07
A20F: 06 05     ASL   $05
A211: 04 03     NOP   $03
A213: 03        .byte $03
A214: 00        BRK
A215: 00        BRK
A216: 00        BRK
A217: 02        .byte $02
A218: FF        .byte $FF
A219: 03        .byte $03
A21A: 04 05     NOP   $05
A21C: 06 07     ASL   $07
A21E: 07        .byte $07
A21F: 07        .byte $07
A220: 06 06     ASL   $06
A222: 06 06     ASL   $06
A224: 05 05     ORA   $05
A226: 05 05     ORA   $05
A228: 04 04     NOP   $04
A22A: 04 04     NOP   $04
A22C: 03        .byte $03
A22D: FF        .byte $FF
A22E: 06 07     ASL   $07
A230: 06 05     ASL   $05
A232: 04 03     NOP   $03
A234: FF        .byte $FF
A235: 06 07     ASL   $07
A237: 06 05     ASL   $05
A239: 04 03     NOP   $03
A23B: 00        BRK
A23C: 00        BRK
A23D: 00        BRK
A23E: 00        BRK
A23F: 01 ff     ORA   ($FF,X)
A241: 04 05     NOP   $05
A243: 06 05     ASL   $05
A245: 04 03     NOP   $03
A247: FF        .byte $FF
A248: 04 05     NOP   $05
A24A: 04 03     NOP   $03
A24C: FF        .byte $FF
A24D: 03        .byte $03
A24E: 04 03     NOP   $03
A250: 03        .byte $03
A251: 03        .byte $03
A252: 03        .byte $03
A253: 00        BRK
A254: 00        BRK
A255: 00        BRK
A256: 00        BRK
A257: 01 ff     ORA   ($FF,X)
A259: 04 05     NOP   $05
A25B: 06 05     ASL   $05
A25D: 04 03     NOP   $03
A25F: FF        .byte $FF
A260: 08        PHP
A261: 07        .byte $07
A262: 06 05     ASL   $05
A264: 04 03     NOP   $03
A266: 00        BRK
A267: 00        BRK
A268: 00        BRK
A269: 00        BRK
A26A: 01 ff     ORA   ($FF,X)
A26C: FF        .byte $FF
A26D: d6 35     DEC   $35,X
A26F: 19 03 e2  ORA   $E203,Y
A272: 41 d6     EOR   ($D6,X)
A274: f5 1d     SBC   $1D,X
A276: 02        .byte $02
A277: 50 71     BVC   $A2EA
A279: d6 f5     DEC   $F5,X
A27B: 1c 02 92  NOP   $9202
A27E: 51 d6     EOR   ($D6),Y
A280: f5 1d     SBC   $1D,X
A282: 02        .byte $02
A283: 20 e3 b1  JSR   $B1E3
A286: d6 f5     DEC   $F5,X
A288: 1e 04 e3  ASL   $E304,X
A28B: 90 e2     BCC   $A26F
A28D: 70 d6     BVS   $A265
A28F: f8        SED
A290: 86 0a     STX   $0A
A292: e4 92     CPX   $92
A294: E3        .byte $E3
A295: 00        BRK
A296: e4 90     CPX   $90
A298: E3        .byte $E3
A299: 20 20 e4  JSR   $E420
A29C: 91 e3     STA   ($E3),Y
A29E: 00        BRK
A29F: 00        BRK
A2A0: e4 92     CPX   $92
A2A2: 71 60     ADC   ($60),Y
A2A4: fe 02 6d  INC   $6D02,X
A2A7: a2 d6     LDX   #$D6
A2A9: F7        .byte $F7
A2AA: 1d 02 e2  ORA   $E202,X
A2AD: 91 70     STA   ($70),Y
A2AF: 90 b1     BCC   $A262
A2B1: 90 b0     BCC   $A263
A2B3: e1 01     SBC   ($01,X)
A2B5: E2        .byte $E2
A2B6: b0 e1     BCS   $A299
A2B8: 00        BRK
A2B9: 23        .byte $23
A2BA: E2        .byte $E2
A2BB: b1 70     LDA   ($70),Y
A2BD: b0 e1     BCS   $A2A0
A2BF: 01 e2     ORA   ($E2,X)
A2C1: b0 e1     BCS   $A2A4
A2C3: 00        BRK
A2C4: 21 00     AND   ($00,X)
A2C6: 20 43 ff  JSR   $FF43
A2C9: d6 b8     DEC   $B8,X
A2CB: 18        CLC
A2CC: 01 e3     ORA   ($E3,X)
A2CE: 9F        .byte $9F
A2CF: E2        .byte $E2
A2D0: 2F        .byte $2F
A2D1: 4F        .byte $4F
A2D2: 7F        .byte $7F
A2D3: d6 b8     DEC   $B8,X
A2D5: 18        CLC
A2D6: 00        BRK
A2D7: BF        .byte $BF
A2D8: d6 b3     DEC   $B3,X
A2DA: 80 01     NOP   $01
A2DC: BF        .byte $BF
A2DD: fd 6d a2  SBC   $A26D,X
A2E0: d6 f8     DEC   $F8,X
A2E2: 87        .byte $87
A2E3: 00        BRK
A2E4: e4 71     CPX   $71
A2E6: E2        .byte $E2
A2E7: 40        RTI
A2E8: e4 90     CPX   $90
A2EA: 90 e2     BCC   $A2CE
A2EC: 40        RTI
A2ED: e4 90     CPX   $90
A2EF: 90 e2     BCC   $A2D3
A2F1: 20 e4 90  JSR   $90E4
A2F4: 90 e2     BCC   $A2D8
A2F6: 00        BRK
A2F7: e4 90     CPX   $90
A2F9: 90 e2     BCC   $A2DD
A2FB: 41 e4     EOR   ($E4,X)
A2FD: 71 e2     ADC   ($E2),Y
A2FF: 40        RTI
A300: e4 90     CPX   $90
A302: 90 e2     BCC   $A2E6
A304: 40        RTI
A305: e4 90     CPX   $90
A307: 90 e2     BCC   $A2EB
A309: 20 e4 90  JSR   $90E4
A30C: 90 e2     BCC   $A2F0
A30E: 00        BRK
A30F: e4 90     CPX   $90
A311: 90 e2     BCC   $A2F5
A313: 41 fd     EOR   ($FD,X)
A315: 6d a2 e8  ADC   $E8A2
A318: d6 36     DEC   $36,X
A31A: 85 00     STA   $00
A31C: E2        .byte $E2
A31D: 90 70     BCC   $A38F
A31F: 40        RTI
A320: 20 40 20  JSR   $2040
A323: 00        BRK
A324: E3        .byte $E3
A325: 90 e2     BCC   $A309
A327: 00        BRK
A328: E3        .byte $E3
A329: 90 70     BCC   $A39B
A32B: 90 c3     BCC   $A2F0
A32D: C7        .byte $C7
A32E: e8        INX
A32F: d6 f7     DEC   $F7,X
A331: 1F        .byte $1F
A332: 02        .byte $02
A333: E3        .byte $E3
A334: 40        RTI
A335: 40        RTI
A336: 41 51     EOR   ($51,X)
A338: 51 d6     EOR   ($D6),Y
A33A: 36 83     ROL   $83,X
A33C: 02        .byte $02
A33D: E2        .byte $E2
A33E: 01 00     ORA   ($00,X)
A340: 00        BRK
A341: 00        BRK
A342: 00        BRK
A343: 20 42 21  JSR   $2142
A346: 41 61     EOR   ($61,X)
A348: 01 00     ORA   ($00,X)
A34A: 00        BRK
A34B: 00        BRK
A34C: 00        BRK
A34D: 20 42 21  JSR   $2142
A350: 00        BRK
A351: E3        .byte $E3
A352: B2        .byte $B2
A353: E2        .byte $E2
A354: 01 00     ORA   ($00,X)
A356: 00        BRK
A357: 00        BRK
A358: 00        BRK
A359: 20 42 21  JSR   $2142
A35C: 41 61     EOR   ($61,X)
A35E: 00        BRK
A35F: 20 40 21  JSR   $2140
A362: 40        RTI
A363: 60        RTS
A364: 41 60     EOR   ($60,X)
A366: 70 61     BVS   $A3C9
A368: 70 91     BVS   $A2FB
A36A: fe ff dd  INC   $DDFF,X
A36D: a2 d6     LDX   #$D6
A36F: F7        .byte $F7
A370: 19 02 e2  ORA   $E202,Y
A373: 91 d6     STA   ($D6),Y
A375: F7        .byte $F7
A376: 1a        NOP
A377: 02        .byte $02
A378: b0 e1     BCS   $A35B
A37A: 01 d6     ORA   ($D6,X)
A37C: F7        .byte $F7
A37D: 19 02 22  ORA   $2202,Y
A380: E2        .byte $E2
A381: b1 d6     LDA   ($D6),Y
A383: F7        .byte $F7
A384: 1a        NOP
A385: 02        .byte $02
A386: 70 41     BVS   $A3C9
A388: d6 f7     DEC   $F7,X
A38A: 1B        .byte $1B
A38B: 04 e2     NOP   $E2
A38D: 90 e1     BCC   $A370
A38F: 70 65     BVS   $A3F6
A391: E2        .byte $E2
A392: 90 e1     BCC   $A375
A394: 60        RTS
A395: 48        PHA
A396: fe 02 6e  INC   $6E02,X
A399: A3        .byte $A3
A39A: d6 f7     DEC   $F7,X
A39C: 19 03 e1  ORA   $E103,Y
A39F: 51 20     EOR   ($20),Y
A3A1: 50 71     BVC   $A414
A3A3: 50 70     BVC   $A415
A3A5: 91 70     STA   ($70),Y
A3A7: 90 b3     BCC   $A35C
A3A9: 71 40     ADC   ($40),Y
A3AB: 70 91     BVS   $A33E
A3AD: 70 90     BVS   $A33F
A3AF: b1 90     LDA   ($90),Y
A3B1: b0 e0     BCS   $A393
A3B3: 03        .byte $03
A3B4: FF        .byte $FF
A3B5: d6 f6     DEC   $F6,X
A3B7: 17        .byte $17
A3B8: 00        BRK
A3B9: e1 70     SBC   ($70,X)
A3BB: 40        RTI
A3BC: 60        RTS
A3BD: 71 70     ADC   ($70),Y
A3BF: 40        RTI
A3C0: 60        RTS
A3C1: 70 40     BVS   $A403
A3C3: 60        RTS
A3C4: 71 70     ADC   ($70),Y
A3C6: 40        RTI
A3C7: 60        RTS
A3C8: fe 06 b9  INC   $B906,X
A3CB: A3        .byte $A3
A3CC: fd 6e a3  SBC   $A36E,X
A3CF: d6 f7     DEC   $F7,X
A3D1: 1F        .byte $1F
A3D2: 02        .byte $02
A3D3: E3        .byte $E3
A3D4: 71 e1     ADC   ($E1),Y
A3D6: 90 e2     BCC   $A3BA
A3D8: 90 90     BCC   $A36A
A3DA: e1 70     SBC   ($70,X)
A3DC: E2        .byte $E2
A3DD: 90 90     BCC   $A36F
A3DF: e1 60     SBC   ($60,X)
A3E1: E2        .byte $E2
A3E2: 90 90     BCC   $A374
A3E4: e1 40     SBC   ($40,X)
A3E6: E2        .byte $E2
A3E7: 90 90     BCC   $A379
A3E9: e1 71     SBC   ($71,X)
A3EB: fe 02 d3  INC   $D302,X
A3EE: A3        .byte $A3
A3EF: fd 6e a3  SBC   $A36E,X
A3F2: d6 f9     DEC   $F9,X
A3F4: 87        .byte $87
A3F5: 00        BRK
A3F6: e1 90     SBC   ($90,X)
A3F8: 70 40     BVS   $A43A
A3FA: 20 40 20  JSR   $2040
A3FD: 00        BRK
A3FE: E2        .byte $E2
A3FF: 90 e1     BCC   $A3E2
A401: 00        BRK
A402: E2        .byte $E2
A403: 90 70     BCC   $A475
A405: 90 c3     BCC   $A3CA
A407: C7        .byte $C7
A408: d6 f7     DEC   $F7,X
A40A: 1F        .byte $1F
A40B: 02        .byte $02
A40C: E3        .byte $E3
A40D: 90 90     BCC   $A39F
A40F: 91 81     STA   ($81),Y
A411: 81 d6     STA   ($D6,X)
A413: f8        SED
A414: 85 02     STA   $02
A416: E2        .byte $E2
A417: 91 90     STA   ($90),Y
A419: 90 90     BCC   $A3AB
A41B: 90 b0     BCC   $A3CD
A41D: e1 02     SBC   ($02,X)
A41F: E2        .byte $E2
A420: b1 e1     LDA   ($E1),Y
A422: 01 21     ORA   ($21,X)
A424: E2        .byte $E2
A425: 91 90     STA   ($90),Y
A427: 90 90     BCC   $A3B9
A429: 90 b0     BCC   $A3DB
A42B: e1 02     SBC   ($02,X)
A42D: E2        .byte $E2
A42E: b1 90     LDA   ($90),Y
A430: 72        .byte $72
A431: 91 90     STA   ($90),Y
A433: 90 90     BCC   $A3C5
A435: 90 b0     BCC   $A3E7
A437: e1 02     SBC   ($02,X)
A439: E2        .byte $E2
A43A: b1 e1     LDA   ($E1),Y
A43C: 01 21     ORA   ($21,X)
A43E: E2        .byte $E2
A43F: 40        RTI
A440: 60        RTS
A441: 70 61     BVS   $A4A4
A443: 70 90     BVS   $A3D5
A445: 71 90     ADC   ($90),Y
A447: b0 91     BCS   $A3DA
A449: b0 e1     BCS   $A42C
A44B: 01 fe     ORA   ($FE,X)
A44D: FF        .byte $FF
A44E: cc a3 d6  CPY   $D6A3
A451: 14 e3     NOP   $E3
A453: 91 d6     STA   ($D6),Y
A455: 0e e2 00  ASL   $00E2
A458: E3        .byte $E3
A459: 90 e2     BCC   $A43D
A45B: 20 20 d6  JSR   $D620
A45E: 14 e3     NOP   $E3
A460: 91 d6     STA   ($D6),Y
A462: 0e e2 00  ASL   $00E2
A465: 00        BRK
A466: d6 1b     DEC   $1B,X
A468: E3        .byte $E3
A469: 92        .byte $92
A46A: d6 0f     DEC   $0F,X
A46C: 71 80     ADC   ($80),Y
A46E: fe 04 50  INC   $5004,X
A471: a4 d6     LDY   $D6
A473: 14 e3     NOP   $E3
A475: 51 d6     EOR   ($D6),Y
A477: 0e 90 50  ASL   $5090
A47A: E2        .byte $E2
A47B: 20 20 d6  JSR   $D620
A47E: 14 e3     NOP   $E3
A480: 91 d6     STA   ($D6),Y
A482: 0e e2 00  ASL   $00E2
A485: 00        BRK
A486: d6 1b     DEC   $1B,X
A488: E3        .byte $E3
A489: 92        .byte $92
A48A: d6 0f     DEC   $0F,X
A48C: 51 60     EOR   ($60),Y
A48E: d6 15     DEC   $15,X
A490: E3        .byte $E3
A491: 71 d6     ADC   ($D6),Y
A493: 0e b0 70  ASL   $70B0
A496: E2        .byte $E2
A497: 20 20 d6  JSR   $D620
A49A: 14 e3     NOP   $E3
A49C: b1 d6     LDA   ($D6),Y
A49E: 0e e2 00  ASL   $00E2
A4A1: 00        BRK
A4A2: d6 1b     DEC   $1B,X
A4A4: E3        .byte $E3
A4A5: 92        .byte $92
A4A6: d6 0f     DEC   $0F,X
A4A8: 51 60     EOR   ($60),Y
A4AA: FF        .byte $FF
A4AB: d6 0d     DEC   $0D,X
A4AD: E2        .byte $E2
A4AE: 90 fe     BCC   $A4AE
A4B0: 60        RTS
A4B1: ae a4 fd  LDX   $FDA4
A4B4: 50 a4     BVC   $A45A
A4B6: d6 0f     DEC   $0F,X
A4B8: E3        .byte $E3
A4B9: 71 e2     ADC   ($E2),Y
A4BB: 90 e3     BCC   $A4A0
A4BD: 90 90     BCC   $A44F
A4BF: E2        .byte $E2
A4C0: 70 e3     BVS   $A4A5
A4C2: 90 90     BCC   $A454
A4C4: E2        .byte $E2
A4C5: 60        RTS
A4C6: E3        .byte $E3
A4C7: 90 90     BCC   $A459
A4C9: E2        .byte $E2
A4CA: 40        RTI
A4CB: E3        .byte $E3
A4CC: 90 90     BCC   $A45E
A4CE: E2        .byte $E2
A4CF: 71 fe     ADC   ($FE),Y
A4D1: 02        .byte $02
A4D2: b6 a4     LDX   $A4,Y
A4D4: fd 50 a4  SBC   $A450,X
A4D7: d6 0f     DEC   $0F,X
A4D9: E2        .byte $E2
A4DA: 90 70     BCC   $A54C
A4DC: 40        RTI
A4DD: 20 40 20  JSR   $2040
A4E0: 00        BRK
A4E1: E3        .byte $E3
A4E2: 90 e2     BCC   $A4C6
A4E4: 00        BRK
A4E5: E3        .byte $E3
A4E6: 90 70     BCC   $A558
A4E8: 90 c3     BCC   $A4AD
A4EA: C7        .byte $C7
A4EB: 90 90     BCC   $A47D
A4ED: 90 c0     BCC   $A4AF
A4EF: b0 c0     BCS   $A4B1
A4F1: b0 c0     BCS   $A4B3
A4F3: d6 0f     DEC   $0F,X
A4F5: E2        .byte $E2
A4F6: 91 91     STA   ($91),Y
A4F8: CB        .byte $CB
A4F9: 91 91     STA   ($91),Y
A4FB: C7        .byte $C7
A4FC: 71 71     ADC   ($71),Y
A4FE: 91 91     STA   ($91),Y
A500: CB        .byte $CB
A501: E2        .byte $E2
A502: 90 90     BCC   $A494
A504: 90 90     BCC   $A496
A506: C2        .byte $C2
A507: 01 20     ORA   ($20,X)
A509: 40        RTI
A50A: 20 20 40  JSR   $4020
A50D: 61 fe     ADC   ($FE,X)
A50F: FF        .byte $FF
A510: B3        .byte $B3
A511: a4 d6     LDY   $D6
A513: 00        BRK
A514: fe 50 13  INC   $1350,X
A517: a5 40     LDA   $40
A519: fe 10 18  INC   $1810,X
A51C: a5 30     LDA   $30
A51E: 10 30     BPL   $A550
A520: 30 40     BMI   $A562
A522: 30 00     BMI   $A524
A524: 30 31     BMI   $A557
A526: 30 30     BMI   $A558
A528: 40        RTI
A529: 31 30     AND   ($30),Y
A52B: 30 10     BMI   $A53D
A52D: 30 30     BMI   $A55F
A52F: 40        RTI
A530: 30 00     BMI   $A532
A532: 30 31     BMI   $A565
A534: 30 30     BMI   $A566
A536: 40        RTI
A537: 40        RTI
A538: 00        BRK
A539: 40        RTI
A53A: fe 07 1d  INC   $1D07,X
A53D: a5 40     LDA   $40
A53F: 40        RTI
A540: 40        RTI
A541: 40        RTI
A542: 40        RTI
A543: 40        RTI
A544: 40        RTI
A545: 40        RTI
A546: 40        RTI
A547: 40        RTI
A548: 40        RTI
A549: 40        RTI
A54A: C3        .byte $C3
A54B: 40        RTI
A54C: 42        .byte $42
A54D: 33        .byte $33
A54E: 40        RTI
A54F: 40        RTI
A550: 40        RTI
A551: c0 40     CPY   #$40
A553: 30 40     BMI   $A595
A555: 30 31     BMI   $A588
A557: 31 00     AND   ($00),Y
A559: 00        BRK
A55A: 01 00     ORA   ($00,X)
A55C: 00        BRK
A55D: 01 00     ORA   ($00,X)
A55F: 02        .byte $02
A560: 31 31     AND   ($31),Y
A562: 00        BRK
A563: 00        BRK
A564: 01 00     ORA   ($00,X)
A566: 00        BRK
A567: 01 01     ORA   ($01,X)
A569: 01 31     ORA   ($31,X)
A56B: 31 00     AND   ($00),Y
A56D: 00        BRK
A56E: 01 00     ORA   ($00,X)
A570: 00        BRK
A571: 01 00     ORA   ($00,X)
A573: 02        .byte $02
A574: 30 30     BMI   $A5A6
A576: 30 30     BMI   $A5A8
A578: 40        RTI
A579: 40        RTI
A57A: 40        RTI
A57B: 40        RTI
A57C: 40        RTI
A57D: 40        RTI
A57E: 40        RTI
A57F: 40        RTI
A580: 40        RTI
A581: 40        RTI
A582: 41 fe     EOR   ($FE,X)
A584: FF        .byte $FF
A585: 1d a5 08  ORA   $08A5,X
A588: 07        .byte $07
A589: 06 05     ASL   $05
A58B: 04 00     NOP   $00
A58D: 00        BRK
A58E: 00        BRK
A58F: 00        BRK
A590: 00        BRK
A591: 00        BRK
A592: 01 ff     ORA   ($FF,X)
A594: 08        PHP
A595: 07        .byte $07
A596: 06 05     ASL   $05
A598: 04 03     NOP   $03
A59A: 02        .byte $02
A59B: 01 ff     ORA   ($FF,X)
A59D: 07        .byte $07
A59E: 06 05     ASL   $05
A5A0: 04 03     NOP   $03
A5A2: 02        .byte $02
A5A3: 01 00     ORA   ($00,X)
A5A5: 00        BRK
A5A6: 00        BRK
A5A7: 01 ff     ORA   ($FF,X)
A5A9: 04 03     NOP   $03
A5AB: 02        .byte $02
A5AC: 02        .byte $02
A5AD: 02        .byte $02
A5AE: 00        BRK
A5AF: 00        BRK
A5B0: 00        BRK
A5B1: 00        BRK
A5B2: 00        BRK
A5B3: 01 ff     ORA   ($FF,X)
A5B5: d6 f7     DEC   $F7,X
A5B7: 24 00     BIT   $00
A5B9: E2        .byte $E2
A5BA: 91 e1     STA   ($E1),Y
A5BC: 21 31     AND   ($31,X)
A5BE: 20 01 e2  JSR   $E201
A5C1: a0 e1     LDY   #$E1
A5C3: 01 e2     ORA   ($E2,X)
A5C5: 71 91     ADC   ($91),Y
A5C7: 91 e1     STA   ($E1),Y
A5C9: 21 31     AND   ($31,X)
A5CB: 20 51 30  JSR   $3051
A5CE: 71 e2     ADC   ($E2),Y
A5D0: 71 91     ADC   ($91),Y
A5D2: d6 35     DEC   $35,X
A5D4: 25 00     AND   $00
A5D6: e1 21     SBC   ($21,X)
A5D8: 91 e0     STA   ($E0),Y
A5DA: 21 e1     AND   ($E1,X)
A5DC: 91 fe     STA   ($FE),Y
A5DE: 02        .byte $02
A5DF: d6 a5     DEC   $A5,X
A5E1: 21 51     AND   ($51,X)
A5E3: 91 91     STA   ($91),Y
A5E5: 21 51     AND   ($51,X)
A5E7: FF        .byte $FF
A5E8: e8        INX
A5E9: d6 37     DEC   $37,X
A5EB: 26 00     ROL   $00
A5ED: E3        .byte $E3
A5EE: 41 fe     EOR   ($FE,X)
A5F0: 10 ee     BPL   $A5E0
A5F2: a5 e8     LDA   $E8
A5F4: d6 f8     DEC   $F8,X
A5F6: 86 05     STX   $05
A5F8: E2        .byte $E2
A5F9: 50 46     BVC   $A641
A5FB: d6 36     DEC   $36,X
A5FD: 84 0f     STY   $0F
A5FF: 81 41     STA   ($41,X)
A601: 81 91     STA   ($91,X)
A603: fe 04 f4  INC   $F404,X
A606: a5 d6     LDA   $D6
A608: f8        SED
A609: 86 05     STX   $05
A60B: E2        .byte $E2
A60C: 80 76     NOP   $76
A60E: d6 36     DEC   $36,X
A610: 84 0f     STY   $0F
A612: b1 71     LDA   ($71),Y
A614: b1 e1     LDA   ($E1),Y
A616: 01 fe     ORA   ($FE,X)
A618: 04 07     NOP   $07
A61A: a6 d6     LDX   $D6
A61C: f8        SED
A61D: 86 05     STX   $05
A61F: E2        .byte $E2
A620: b0 a6     BCS   $A5C8
A622: d6 36     DEC   $36,X
A624: 84 0f     STY   $0F
A626: E2        .byte $E2
A627: 21 21     AND   ($21,X)
A629: 21 21     AND   ($21,X)
A62B: d6 f8     DEC   $F8,X
A62D: 86 05     STX   $05
A62F: e1 10     SBC   ($10,X)
A631: 06 d6     ASL   $D6
A633: 36 84     ROL   $84,X
A635: 0F        .byte $0F
A636: E2        .byte $E2
A637: 41 41     EOR   ($41,X)
A639: 41 41     EOR   ($41,X)
A63B: fe 02 1b  INC   $1B02,X
A63E: a6 fd     LDX   $FD
A640: b5 a5     LDA   $A5,X
A642: 91 91     STA   ($91),Y
A644: fd b5 a5  SBC   $A5B5,X
A647: 93        .byte $93
A648: fe ff f4  INC   $F4FF,X
A64B: a5 d6     LDA   $D6
A64D: F7        .byte $F7
A64E: 24 00     BIT   $00
A650: e1 21     SBC   ($21,X)
A652: 91 a1     STA   ($A1),Y
A654: 90 71     BCC   $A6C7
A656: 50 71     BVC   $A6C9
A658: 01 21     ORA   ($21,X)
A65A: 21 91     AND   ($91,X)
A65C: a1 90     LDA   ($90,X)
A65E: e0 01     CPX   #$01
A660: e1 a0     SBC   ($A0,X)
A662: e0 01     CPX   #$01
A664: e1 01     SBC   ($01,X)
A666: 2F        .byte $2F
A667: c1 d6     CMP   ($D6,X)
A669: 35 25     AND   $25,X
A66B: 00        BRK
A66C: e1 51     SBC   ($51,X)
A66E: 91 e0     STA   ($E0),Y
A670: 21 01     AND   ($01,X)
A672: e1 51     SBC   ($51,X)
A674: 91 ff     STA   ($FF),Y
A676: d6 f7     DEC   $F7,X
A678: 23        .byte $23
A679: 00        BRK
A67A: e4 41     CPX   $41
A67C: fe 10 7b  INC   $7B10,X
A67F: a6 d6     LDX   $D6
A681: f8        SED
A682: 86 05     STX   $05
A684: E2        .byte $E2
A685: 90 86     BCC   $A60D
A687: d6 37     DEC   $37,X
A689: 86 00     STX   $00
A68B: b1 91     LDA   ($91),Y
A68D: b1 e1     LDA   ($E1),Y
A68F: 01 fe     ORA   ($FE,X)
A691: 04 80     NOP   $80
A693: a6 d6     LDX   $D6
A695: f8        SED
A696: 86 05     STX   $05
A698: e1 00     SBC   ($00,X)
A69A: E2        .byte $E2
A69B: b6 d6     LDX   $D6,Y
A69D: 37        .byte $37
A69E: 86 00     STX   $00
A6A0: e1 21     SBC   ($21,X)
A6A2: 01 21     ORA   ($21,X)
A6A4: 31 fe     AND   ($FE),Y
A6A6: 04 94     NOP   $94
A6A8: a6 d6     LDX   $D6
A6AA: f8        SED
A6AB: 86 05     STX   $05
A6AD: e1 30     SBC   ($30,X)
A6AF: 26 d6     ROL   $D6
A6B1: 37        .byte $37
A6B2: 86 00     STX   $00
A6B4: E2        .byte $E2
A6B5: a1 91     LDA   ($91,X)
A6B7: a1 e1     LDA   ($E1,X)
A6B9: 01 d6     ORA   ($D6,X)
A6BB: f8        SED
A6BC: 86 05     STX   $05
A6BE: e1 50     SBC   ($50,X)
A6C0: 46 d6     LSR   $D6
A6C2: 37        .byte $37
A6C3: 86 00     STX   $00
A6C5: E2        .byte $E2
A6C6: a1 91     LDA   ($91,X)
A6C8: a1 e1     LDA   ($E1,X)
A6CA: 01 fe     ORA   ($FE,X)
A6CC: 02        .byte $02
A6CD: a9 a6     LDA   #$A6
A6CF: fd 4c a6  SBC   $A64C,X
A6D2: e0 21     CPX   #$21
A6D4: 01 fd     ORA   ($FD,X)
A6D6: 4c a6 e0  JMP   $E0A6
A6D9: 23        .byte $23
A6DA: fe ff 80  INC   $80FF,X
A6DD: a6 d6     LDX   $D6
A6DF: 0e e2 41  ASL   $41E2
A6E2: fe 10 e1  INC   $E110,X
A6E5: a6 d6     LDX   $D6
A6E7: 0e 50 d6  ASL   $D650
A6EA: 20 42 d6  JSR   $D642
A6ED: 0e 41 41  ASL   $4141
A6F0: 41 41     EOR   ($41,X)
A6F2: 41 41     EOR   ($41,X)
A6F4: fe 04 e6  INC   $E604,X
A6F7: a6 d6     LDX   $D6
A6F9: 0e 80 d6  ASL   $D680
A6FC: 20 72 d6  JSR   $D672
A6FF: 0e 71 71  ASL   $7171
A702: 71 71     ADC   ($71),Y
A704: 71 71     ADC   ($71),Y
A706: fe 04 f8  INC   $F804,X
A709: a6 d6     LDX   $D6
A70B: 0e e2 b0  ASL   $B0E2
A70E: d6 20     DEC   $20,X
A710: a2 d6     LDX   #$D6
A712: 0e a1 a1  ASL   $A1A1
A715: a1 a1     LDA   ($A1,X)
A717: a1 a1     LDA   ($A1,X)
A719: e1 10     SBC   ($10,X)
A71B: d6 20     DEC   $20,X
A71D: 02        .byte $02
A71E: d6 0e     DEC   $0E,X
A720: 01 01     ORA   ($01,X)
A722: 01 01     ORA   ($01,X)
A724: 01 01     ORA   ($01,X)
A726: fe 02 0a  INC   $0A02,X
A729: A7        .byte $A7
A72A: d6 0e     DEC   $0E,X
A72C: E2        .byte $E2
A72D: 21 fe     AND   ($FE,X)
A72F: 10 2d     BPL   $A75E
A731: A7        .byte $A7
A732: 21 91     AND   ($91,X)
A734: fe 08 32  INC   $3208,X
A737: A7        .byte $A7
A738: d6 0e     DEC   $0E,X
A73A: E2        .byte $E2
A73B: 21 fe     AND   ($FE,X)
A73D: 10 3b     BPL   $A77A
A73F: A7        .byte $A7
A740: 21 91     AND   ($91,X)
A742: fe 08 40  INC   $4008,X
A745: A7        .byte $A7
A746: fe ff e6  INC   $E6FF,X
A749: a6 30     LDX   $30
A74B: 32        .byte $32
A74C: 31 31     AND   ($31),Y
A74E: 31 31     AND   ($31),Y
A750: 41 30     EOR   ($30,X)
A752: 00        BRK
A753: fe 03 4a  INC   $4A03,X
A756: A7        .byte $A7
A757: 30 32     BMI   $A78B
A759: 31 31     AND   ($31),Y
A75B: 30 00     BMI   $A75D
A75D: 31 30     AND   ($30),Y
A75F: 00        BRK
A760: 31 ff     AND   ($FF),Y
A762: d6 31     DEC   $31,X
A764: fe 10 63  INC   $6310,X
A767: A7        .byte $A7
A768: fd 4a a7  SBC   $A74A,X
A76B: fd 4a a7  SBC   $A74A,X
A76E: 30 32     BMI   $A7A2
A770: 31 31     AND   ($31),Y
A772: 31 31     AND   ($31),Y
A774: 41 30     EOR   ($30,X)
A776: 00        BRK
A777: fe 03 6e  INC   $6E03,X
A77A: A7        .byte $A7
A77B: 31 31     AND   ($31),Y
A77D: 31 31     AND   ($31),Y
A77F: 40        RTI
A780: 40        RTI
A781: 41 40     EOR   ($40,X)
A783: 40        RTI
A784: 41 31     EOR   ($31,X)
A786: 31 41     AND   ($41),Y
A788: 31 31     AND   ($31),Y
A78A: 31 41     AND   ($41),Y
A78C: 30 00     BMI   $A78E
A78E: fe 03 85  INC   $8503,X
A791: A7        .byte $A7
A792: 31 31     AND   ($31),Y
A794: 41 31     EOR   ($31,X)
A796: 41 41     EOR   ($41,X)
A798: 41 40     EOR   ($40,X)
A79A: 40        RTI
A79B: 31 31     AND   ($31),Y
A79D: 41 31     EOR   ($31,X)
A79F: 31 31     AND   ($31),Y
A7A1: 41 30     EOR   ($30,X)
A7A3: 00        BRK
A7A4: fe 03 9b  INC   $9B03,X
A7A7: A7        .byte $A7
A7A8: 31 31     AND   ($31),Y
A7AA: 41 31     EOR   ($31,X)
A7AC: 41 41     EOR   ($41,X)
A7AE: 40        RTI
A7AF: 40        RTI
A7B0: 41 fe     EOR   ($FE,X)
A7B2: FF        .byte $FF
A7B3: 68        PLA
A7B4: A7        .byte $A7
A7B5: 08        PHP
A7B6: 07        .byte $07
A7B7: 06 05     ASL   $05
A7B9: 04 03     NOP   $03
A7BB: 00        BRK
A7BC: 00        BRK
A7BD: 00        BRK
A7BE: 00        BRK
A7BF: 01 ff     ORA   ($FF,X)
A7C1: 06 07     ASL   $07
A7C3: 06 05     ASL   $05
A7C5: 04 03     NOP   $03
A7C7: FF        .byte $FF
A7C8: 05 04     ORA   $04
A7CA: 03        .byte $03
A7CB: 03        .byte $03
A7CC: 03        .byte $03
A7CD: 03        .byte $03
A7CE: 00        BRK
A7CF: 00        BRK
A7D0: 00        BRK
A7D1: 00        BRK
A7D2: 01 ff     ORA   ($FF,X)
A7D4: 08        PHP
A7D5: 07        .byte $07
A7D6: 06 05     ASL   $05
A7D8: 04 03     NOP   $03
A7DA: 03        .byte $03
A7DB: 00        BRK
A7DC: 00        BRK
A7DD: 00        BRK
A7DE: 01 ff     ORA   ($FF,X)
A7E0: 06 05     ASL   $05
A7E2: 04 03     NOP   $03
A7E4: 02        .byte $02
A7E5: 00        BRK
A7E6: 00        BRK
A7E7: 00        BRK
A7E8: 00        BRK
A7E9: 00        BRK
A7EA: 01 ff     ORA   ($FF,X)
A7EC: e8        INX
A7ED: d6 f9     DEC   $F9,X
A7EF: 87        .byte $87
A7F0: 00        BRK
A7F1: E3        .byte $E3
A7F2: c8        INY
A7F3: d6 f9     DEC   $F9,X
A7F5: 87        .byte $87
A7F6: 00        BRK
A7F7: E3        .byte $E3
A7F8: 70 80     BVS   $A77A
A7FA: a0 d6     LDY   #$D6
A7FC: 37        .byte $37
A7FD: 84 05     STY   $05
A7FF: E2        .byte $E2
A800: 08        PHP
A801: 00        BRK
A802: 10 30     BPL   $A834
A804: 71 56     ADC   ($56),Y
A806: 50 30     BVC   $A838
A808: 10 31     BPL   $A83B
A80A: 19 31 13  ORA   $1331,Y
A80D: E3        .byte $E3
A80E: a1 73     LDA   ($73,X)
A810: E2        .byte $E2
A811: 08        PHP
A812: 00        BRK
A813: 10 30     BPL   $A845
A815: 71 56     ADC   ($56),Y
A817: 50 30     BVC   $A849
A819: 10 31     BPL   $A84C
A81B: 13        .byte $13
A81C: d6 38     DEC   $38,X
A81E: 86 04     STX   $04
A820: E2        .byte $E2
A821: 81 73     STA   ($73,X)
A823: E2        .byte $E2
A824: 31 13     AND   ($13),Y
A826: E3        .byte $E3
A827: a1 73     LDA   ($73,X)
A829: d6 37     DEC   $37,X
A82B: 21 00     AND   ($00,X)
A82D: E2        .byte $E2
A82E: 01 00     ORA   ($00,X)
A830: d6 b7     DEC   $B7,X
A832: 21 00     AND   ($00,X)
A834: E3        .byte $E3
A835: 32        .byte $32
A836: 62        .byte $62
A837: 02        .byte $02
A838: fe 04 29  INC   $2904,X
A83B: a8        TAY
A83C: d6 37     DEC   $37,X
A83E: 21 00     AND   ($00,X)
A840: E3        .byte $E3
A841: 71 70     ADC   ($70),Y
A843: d6 b7     DEC   $B7,X
A845: 21 00     AND   ($00,X)
A847: E3        .byte $E3
A848: a2 e2     LDX   #$E2
A84A: 12        .byte $12
A84B: E3        .byte $E3
A84C: 72        .byte $72
A84D: fe 03 3c  INC   $3C03,X
A850: a8        TAY
A851: d6 37     DEC   $37,X
A853: 21 00     AND   ($00,X)
A855: E2        .byte $E2
A856: 71 70     ADC   ($70),Y
A858: d6 f7     DEC   $F7,X
A85A: 21 00     AND   ($00,X)
A85C: E3        .byte $E3
A85D: a2 e2     LDX   #$E2
A85F: 80 80     NOP   $80
A861: 80 a0     NOP   $A0
A863: a0 a0     LDY   #$A0
A865: d6 f4     DEC   $F4,X
A867: 82        .byte $82
A868: 00        BRK
A869: e0 51     CPX   #$51
A86B: 00        BRK
A86C: e1 80     SBC   ($80,X)
A86E: e0 00     CPX   #$00
A870: e1 80     SBC   ($80,X)
A872: 50 80     BVC   $A7F4
A874: 50 00     BVC   $A876
A876: 50 00     BVC   $A878
A878: E2        .byte $E2
A879: 80 e1     NOP   $E1
A87B: 50 00     BVC   $A87D
A87D: E2        .byte $E2
A87E: 80 e1     NOP   $E1
A880: 00        BRK
A881: E2        .byte $E2
A882: 80 50     NOP   $50
A884: 80 50     NOP   $50
A886: fe ff f3  INC   $F3FF,X
A889: A7        .byte $A7
A88A: d6 f9     DEC   $F9,X
A88C: 87        .byte $87
A88D: 04 e2     NOP   $E2
A88F: c8        INY
A890: d6 f8     DEC   $F8,X
A892: 85 05     STA   $05
A894: E2        .byte $E2
A895: 00        BRK
A896: 10 30     BPL   $A8C8
A898: E2        .byte $E2
A899: 58        CLI
A89A: 50 70     BVC   $A90C
A89C: 80 e1     NOP   $E1
A89E: 01 e2     ORA   ($E2,X)
A8A0: a6 a0     LDX   $A0
A8A2: 80 70     NOP   $70
A8A4: 81 79     STA   ($79,X)
A8A6: 81 73     STA   ($73,X)
A8A8: 31 03     AND   ($03),Y
A8AA: fe 02 98  INC   $9802,X
A8AD: a8        TAY
A8AE: d6 f7     DEC   $F7,X
A8B0: 21 00     AND   ($00,X)
A8B2: E2        .byte $E2
A8B3: 51 50     EOR   ($50),Y
A8B5: E3        .byte $E3
A8B6: 32        .byte $32
A8B7: 62        .byte $62
A8B8: 02        .byte $02
A8B9: fe 04 b2  INC   $B204,X
A8BC: a8        TAY
A8BD: e1 01     SBC   ($01,X)
A8BF: 00        BRK
A8C0: E3        .byte $E3
A8C1: a2 e2     LDX   #$E2
A8C3: 12        .byte $12
A8C4: E3        .byte $E3
A8C5: 72        .byte $72
A8C6: fe 03 bd  INC   $BD03,X
A8C9: a8        TAY
A8CA: e1 01     SBC   ($01,X)
A8CC: 00        BRK
A8CD: E3        .byte $E3
A8CE: a2 e1     LDX   #$E1
A8D0: 10 10     BPL   $A8E2
A8D2: 10 30     BPL   $A904
A8D4: 30 30     BMI   $A906
A8D6: d6 f7     DEC   $F7,X
A8D8: 83        .byte $83
A8D9: 00        BRK
A8DA: e0 50     CPX   #$50
A8DC: 00        BRK
A8DD: e1 80     SBC   ($80,X)
A8DF: e0 00     CPX   #$00
A8E1: e1 80     SBC   ($80,X)
A8E3: 50 80     BVC   $A865
A8E5: 50 00     BVC   $A8E7
A8E7: 50 00     BVC   $A8E9
A8E9: E2        .byte $E2
A8EA: 80 e1     NOP   $E1
A8EC: 50 00     BVC   $A8EE
A8EE: E2        .byte $E2
A8EF: 80 e1     NOP   $E1
A8F1: 00        BRK
A8F2: E2        .byte $E2
A8F3: 80 50     NOP   $50
A8F5: 80 50     NOP   $50
A8F7: 00        BRK
A8F8: fe ff 90  INC   $90FF,X
A8FB: a8        TAY
A8FC: d6 0e     DEC   $0E,X
A8FE: E2        .byte $E2
A8FF: c8        INY
A900: d6 0e     DEC   $0E,X
A902: E2        .byte $E2
A903: 00        BRK
A904: 10 30     BPL   $A936
A906: 50 c0     BVC   $A8C8
A908: 50 fe     BVC   $A908
A90A: 0F        .byte $0F
A90B: 06 a9     ASL   $A9
A90D: 00        BRK
A90E: 10 30     BPL   $A940
A910: 50 c0     BVC   $A8D2
A912: 50 fe     BVC   $A912
A914: 0F        .byte $0F
A915: 10 a9     BPL   $A8C0
A917: 00        BRK
A918: 10 30     BPL   $A94A
A91A: d6 12     DEC   $12,X
A91C: E2        .byte $E2
A91D: 52        .byte $52
A91E: 32        .byte $32
A91F: 62        .byte $62
A920: 02        .byte $02
A921: fe 04 1c  INC   $1C04,X
A924: a9 e2     LDA   #$E2
A926: 02        .byte $02
A927: E3        .byte $E3
A928: a2 e2     LDX   #$E2
A92A: 12        .byte $12
A92B: E3        .byte $E3
A92C: 72        .byte $72
A92D: fe 03 25  INC   $2503,X
A930: a9 e2     LDA   #$E2
A932: 01 00     ORA   ($00,X)
A934: E3        .byte $E3
A935: a2 d6     LDX   #$D6
A937: 10 e2     BPL   $A91B
A939: 10 10     BPL   $A94B
A93B: 10 30     BPL   $A96D
A93D: 30 30     BMI   $A96F
A93F: d6 90     DEC   $90,X
A941: 5B        .byte $5B
A942: 38        SEC
A943: fe ff 00  INC   $00FF,X
A946: a9 d6     LDA   #$D6
A948: 20 fe 09  JSR   $09FE
A94B: 48        PHA
A94C: a9 d6     LDA   #$D6
A94E: 40        RTI
A94F: 40        RTI
A950: 40        RTI
A951: 31 30     AND   ($30),Y
A953: 40        RTI
A954: 00        BRK
A955: 00        BRK
A956: 31 30     AND   ($30),Y
A958: 40        RTI
A959: 30 30     BMI   $A98B
A95B: fe 03 51  INC   $5103,X
A95E: a9 31     LDA   #$31
A960: 30 40     BMI   $A9A2
A962: 00        BRK
A963: 00        BRK
A964: 31 30     AND   ($30),Y
A966: 40        RTI
A967: 40        RTI
A968: 40        RTI
A969: 31 30     AND   ($30),Y
A96B: 40        RTI
A96C: 00        BRK
A96D: 00        BRK
A96E: 31 30     AND   ($30),Y
A970: 40        RTI
A971: 30 30     BMI   $A9A3
A973: fe 03 69  INC   $6903,X
A976: a9 31     LDA   #$31
A978: 30 40     BMI   $A9BA
A97A: 00        BRK
A97B: 00        BRK
A97C: 31 30     AND   ($30),Y
A97E: 40        RTI
A97F: 40        RTI
A980: 40        RTI
A981: 31 30     AND   ($30),Y
A983: 40        RTI
A984: 00        BRK
A985: 00        BRK
A986: 31 00     AND   ($00),Y
A988: 40        RTI
A989: 00        BRK
A98A: 00        BRK
A98B: fe 07 81  INC   $8107,X
A98E: a9 31     LDA   #$31
A990: 30 40     BMI   $A9D2
A992: 30 30     BMI   $A9C4
A994: 40        RTI
A995: 40        RTI
A996: 40        RTI
A997: 40        RTI
A998: 40        RTI
A999: 40        RTI
A99A: 30 00     BMI   $A99C
A99C: 00        BRK
A99D: fe 06 9a  INC   $9A06,X
A9A0: a9 40     LDA   #$40
A9A2: 40        RTI
A9A3: 40        RTI
A9A4: fe ff 4d  INC   $4DFF,X
A9A7: a9 07     LDA   #$07
A9A9: 06 05     ASL   $05
A9AB: 04 03     NOP   $03
A9AD: 03        .byte $03
A9AE: 03        .byte $03
A9AF: 03        .byte $03
A9B0: 00        BRK
A9B1: 00        BRK
A9B2: 00        BRK
A9B3: 00        BRK
A9B4: 01 ff     ORA   ($FF,X)
A9B6: 05 04     ORA   $04
A9B8: 03        .byte $03
A9B9: 03        .byte $03
A9BA: 03        .byte $03
A9BB: 03        .byte $03
A9BC: 03        .byte $03
A9BD: 03        .byte $03
A9BE: 00        BRK
A9BF: 00        BRK
A9C0: 00        BRK
A9C1: 00        BRK
A9C2: 01 ff     ORA   ($FF,X)
A9C4: 05 06     ORA   $06
A9C6: 07        .byte $07
A9C7: 06 05     ASL   $05
A9C9: 04 03     NOP   $03
A9CB: FF        .byte $FF
A9CC: 0B        .byte $0B
A9CD: 0a        ASL
A9CE: 09 08     ORA   #$08
A9D0: 07        .byte $07
A9D1: 06 05     ASL   $05
A9D3: 04 03     NOP   $03
A9D5: FF        .byte $FF
A9D6: dc f7 29  NOP   $29F7
A9D9: 02        .byte $02
A9DA: e1 1d     SBC   ($1D,X)
A9DC: 7d 3d 9d  ADC   $9D3D,X
A9DF: D7        .byte $D7
A9E0: 37        .byte $37
A9E1: 28        PLP
A9E2: 00        BRK
A9E3: E3        .byte $E3
A9E4: a2 e2     LDX   #$E2
A9E6: 32        .byte $32
A9E7: a1 e1     LDA   ($E1,X)
A9E9: 31 e2     AND   ($E2),Y
A9EB: 01 e1     ORA   ($E1,X)
A9ED: 53        .byte $53
A9EE: e8        INX
A9EF: D7        .byte $D7
A9F0: b9 87 00  LDA   $0087,Y
A9F3: E3        .byte $E3
A9F4: 00        BRK
A9F5: 50 50     BVC   $AA47
A9F7: E2        .byte $E2
A9F8: 00        BRK
A9F9: e1 00     SBC   ($00,X)
A9FB: E2        .byte $E2
A9FC: 00        BRK
A9FD: e8        INX
A9FE: fe 02 df  INC   $DF02,X
AA01: a9 e8     LDA   #$E8
AA03: D7        .byte $D7
AA04: 34 82     NOP   $82
AA06: 00        BRK
AA07: E2        .byte $E2
AA08: a1 e2     LDA   ($E2,X)
AA0A: a0 e1     LDY   #$E1
AA0C: a0 80     LDY   #$80
AA0E: 60        RTS
AA0F: 50 30     BVC   $AA41
AA11: 10 00     BPL   $AA13
AA13: E2        .byte $E2
AA14: a0 80     LDY   #$80
AA16: fe 02 09  INC   $0902,X
AA19: aa        TAX
AA1A: E2        .byte $E2
AA1B: a0 e1     LDY   #$E1
AA1D: a0 80     LDY   #$80
AA1F: 60        RTS
AA20: 50 30     BVC   $AA52
AA22: 10 00     BPL   $AA24
AA24: e8        INX
AA25: e8        INX
AA26: D7        .byte $D7
AA27: fa        NOP
AA28: 88        DEY
AA29: 00        BRK
AA2A: E3        .byte $E3
AA2B: 00        BRK
AA2C: E2        .byte $E2
AA2D: 00        BRK
AA2E: fe 03 2a  INC   $2A03,X
AA31: aa        TAX
AA32: D7        .byte $D7
AA33: F7        .byte $F7
AA34: 85 00     STA   $00
AA36: e4 a0     CPX   $A0
AA38: E3        .byte $E3
AA39: a0 e4     LDY   #$E4
AA3B: a1 a1     LDA   ($A1,X)
AA3D: D7        .byte $D7
AA3E: fa        NOP
AA3F: 88        DEY
AA40: 00        BRK
AA41: E3        .byte $E3
AA42: 00        BRK
AA43: E2        .byte $E2
AA44: 00        BRK
AA45: fe 03 41  INC   $4103,X
AA48: aa        TAX
AA49: D7        .byte $D7
AA4A: F7        .byte $F7
AA4B: 85 00     STA   $00
AA4D: e4 90     CPX   $90
AA4F: E3        .byte $E3
AA50: 90 e4     BCC   $AA36
AA52: 91 91     STA   ($91),Y
AA54: D7        .byte $D7
AA55: fa        NOP
AA56: 88        DEY
AA57: 00        BRK
AA58: E3        .byte $E3
AA59: 00        BRK
AA5A: E2        .byte $E2
AA5B: 00        BRK
AA5C: fe 03 58  INC   $5803,X
AA5F: aa        TAX
AA60: D7        .byte $D7
AA61: F7        .byte $F7
AA62: 85 00     STA   $00
AA64: e4 80     CPX   $80
AA66: E3        .byte $E3
AA67: 80 e4     NOP   $E4
AA69: 81 81     STA   ($81,X)
AA6B: D7        .byte $D7
AA6C: 37        .byte $37
AA6D: 84 00     STY   $00
AA6F: E2        .byte $E2
AA70: 30 e3     BMI   $AA55
AA72: a0 70     LDY   #$70
AA74: E2        .byte $E2
AA75: 20 e3 90  JSR   $90E3
AA78: 60        RTS
AA79: E2        .byte $E2
AA7A: 10 e3     BPL   $AA5F
AA7C: 80 60     NOP   $60
AA7E: E2        .byte $E2
AA7F: 00        BRK
AA80: E3        .byte $E3
AA81: 60        RTS
AA82: 30 d7     BMI   $AA5B
AA84: fa        NOP
AA85: 88        DEY
AA86: 00        BRK
AA87: E3        .byte $E3
AA88: 00        BRK
AA89: E2        .byte $E2
AA8A: 00        BRK
AA8B: fe 03 87  INC   $8703,X
AA8E: aa        TAX
AA8F: D7        .byte $D7
AA90: F7        .byte $F7
AA91: 85 00     STA   $00
AA93: e4 a0     CPX   $A0
AA95: E3        .byte $E3
AA96: a0 e4     LDY   #$E4
AA98: a1 a1     LDA   ($A1,X)
AA9A: D7        .byte $D7
AA9B: fa        NOP
AA9C: 88        DEY
AA9D: 00        BRK
AA9E: E3        .byte $E3
AA9F: 00        BRK
AAA0: E2        .byte $E2
AAA1: 00        BRK
AAA2: fe 03 9e  INC   $9E03,X
AAA5: aa        TAX
AAA6: D7        .byte $D7
AAA7: F7        .byte $F7
AAA8: 85 00     STA   $00
AAAA: e4 90     CPX   $90
AAAC: E3        .byte $E3
AAAD: 90 e4     BCC   $AA93
AAAF: 91 91     STA   ($91),Y
AAB1: e8        INX
AAB2: D7        .byte $D7
AAB3: f6 84     INC   $84,X
AAB5: 02        .byte $02
AAB6: E3        .byte $E3
AAB7: 80 80     NOP   $80
AAB9: 80 80     NOP   $80
AABB: 80 80     NOP   $80
AABD: 81 80     STA   ($80,X)
AABF: a2 e2     LDX   #$E2
AAC1: 80 80     NOP   $80
AAC3: 80 80     NOP   $80
AAC5: 80 80     NOP   $80
AAC7: 81 a1     STA   ($A1,X)
AAC9: e1 30     SBC   ($30,X)
AACB: 70 60     BVS   $AB2D
AACD: 60        RTS
AACE: 60        RTS
AACF: 30 30     BMI   $AB01
AAD1: 30 60     BMI   $AB33
AAD3: 60        RTS
AAD4: 20 20 50  JSR   $5020
AAD7: 50 10     BVC   $AAE9
AAD9: 10 60     BPL   $AB3B
AADB: 60        RTS
AADC: 60        RTS
AADD: 30 30     BMI   $AB0F
AADF: 30 80     BMI   $AA61
AAE1: 80 50     NOP   $50
AAE3: 50 a0     BVC   $AA85
AAE5: e0 12     CPX   #$12
AAE7: fe ff df  INC   $DFFF,X
AAEA: a9 dc     LDA   #$DC
AAEC: F7        .byte $F7
AAED: 29 02     AND   #$02
AAEF: e1 6d     SBC   ($6D,X)
AAF1: e0 0d     CPX   #$0D
AAF3: e1 8d     SBC   ($8D,X)
AAF5: e0 2d     CPX   #$2D
AAF7: D7        .byte $D7
AAF8: F7        .byte $F7
AAF9: 27        .byte $27
AAFA: 00        BRK
AAFB: E2        .byte $E2
AAFC: 32        .byte $32
AAFD: 62        .byte $62
AAFE: e1 31     SBC   ($31,X)
AB00: 61 e2     ADC   ($E2,X)
AB02: 51 e1     EOR   ($E1),Y
AB04: 93        .byte $93
AB05: D7        .byte $D7
AB06: 3B        .byte $3B
AB07: 89        .byte $89
AB08: 00        BRK
AB09: e4 00     CPX   $00
AB0B: 50 50     BVC   $AB5D
AB0D: E3        .byte $E3
AB0E: 00        BRK
AB0F: E2        .byte $E2
AB10: 00        BRK
AB11: E3        .byte $E3
AB12: 00        BRK
AB13: fe 02 f7  INC   $F702,X
AB16: aa        TAX
AB17: D7        .byte $D7
AB18: 39 86 00  AND   $0086,Y
AB1B: E2        .byte $E2
AB1C: a0 e1     LDY   #$E1
AB1E: a0 80     LDY   #$80
AB20: 60        RTS
AB21: 50 30     BVC   $AB53
AB23: 10 00     BPL   $AB25
AB25: E2        .byte $E2
AB26: a0 80     LDY   #$80
AB28: fe 03 17  INC   $1703,X
AB2B: AB        .byte $AB
AB2C: D7        .byte $D7
AB2D: 37        .byte $37
AB2E: 2a        ROL
AB2F: 04 e1     NOP   $E1
AB31: 75 d7     ADC   $D7,X
AB33: fa        NOP
AB34: 87        .byte $87
AB35: 00        BRK
AB36: e4 a0     CPX   $A0
AB38: E3        .byte $E3
AB39: a0 e4     LDY   #$E4
AB3B: a1 a1     LDA   ($A1,X)
AB3D: D7        .byte $D7
AB3E: 37        .byte $37
AB3F: 2a        ROL
AB40: 04 e1     NOP   $E1
AB42: 65 d7     ADC   $D7
AB44: fa        NOP
AB45: 87        .byte $87
AB46: 00        BRK
AB47: e4 90     CPX   $90
AB49: E3        .byte $E3
AB4A: 90 e4     BCC   $AB30
AB4C: 91 91     STA   ($91),Y
AB4E: D7        .byte $D7
AB4F: 37        .byte $37
AB50: 2a        ROL
AB51: 04 e1     NOP   $E1
AB53: 55 d7     EOR   $D7,X
AB55: fa        NOP
AB56: 87        .byte $87
AB57: 00        BRK
AB58: e4 80     CPX   $80
AB5A: E3        .byte $E3
AB5B: 80 e4     NOP   $E4
AB5D: 81 81     STA   ($81,X)
AB5F: D7        .byte $D7
AB60: FB        .byte $FB
AB61: 8a        TXA
AB62: 00        BRK
AB63: e1 30     SBC   ($30,X)
AB65: E3        .byte $E3
AB66: a0 70     LDY   #$70
AB68: E2        .byte $E2
AB69: 20 e3 90  JSR   $90E3
AB6C: 60        RTS
AB6D: E2        .byte $E2
AB6E: 10 e3     BPL   $AB53
AB70: 80 60     NOP   $60
AB72: E2        .byte $E2
AB73: 00        BRK
AB74: E3        .byte $E3
AB75: 60        RTS
AB76: 30 d7     BMI   $AB4F
AB78: 37        .byte $37
AB79: 2a        ROL
AB7A: 04 e1     NOP   $E1
AB7C: 75 d7     ADC   $D7,X
AB7E: fa        NOP
AB7F: 87        .byte $87
AB80: 00        BRK
AB81: e4 a0     CPX   $A0
AB83: E3        .byte $E3
AB84: a0 e4     LDY   #$E4
AB86: a1 a1     LDA   ($A1,X)
AB88: D7        .byte $D7
AB89: 37        .byte $37
AB8A: 2a        ROL
AB8B: 04 e1     NOP   $E1
AB8D: 65 d7     ADC   $D7
AB8F: fa        NOP
AB90: 87        .byte $87
AB91: 00        BRK
AB92: e4 90     CPX   $90
AB94: E3        .byte $E3
AB95: 90 e4     BCC   $AB7B
AB97: 91 91     STA   ($91),Y
AB99: D7        .byte $D7
AB9A: f8        SED
AB9B: 86 02     STX   $02
AB9D: E2        .byte $E2
AB9E: 10 10     BPL   $ABB0
ABA0: 10 10     BPL   $ABB2
ABA2: 10 10     BPL   $ABB4
ABA4: 11 10     ORA   ($10),Y
ABA6: 32        .byte $32
ABA7: e1 10     SBC   ($10,X)
ABA9: 10 10     BPL   $ABBB
ABAB: 10 10     BPL   $ABBD
ABAD: 10 11     BPL   $ABC0
ABAF: 31 70     AND   ($70),Y
ABB1: a0 e0     LDY   #$E0
ABB3: 30 30     BMI   $ABE5
ABB5: 30 e1     BMI   $AB98
ABB7: a0 a0     LDY   #$A0
ABB9: a0 e0     LDY   #$E0
ABBB: 20 20 e1  JSR   $E120
ABBE: a0 a0     LDY   #$A0
ABC0: e0 10     CPX   #$10
ABC2: 10 e1     BPL   $ABA5
ABC4: 80 80     NOP   $80
ABC6: e0 30     CPX   #$30
ABC8: 30 30     BMI   $ABFA
ABCA: e1 a0     SBC   ($A0,X)
ABCC: a0 a0     LDY   #$A0
ABCE: e0 50     CPX   #$50
ABD0: 50 00     BVC   $ABD2
ABD2: 00        BRK
ABD3: 60        RTS
ABD4: 82        .byte $82
ABD5: fe ff f7  INC   $F7FF,X
ABD8: aa        TAX
ABD9: D7        .byte $D7
ABDA: 12        .byte $12
ABDB: E2        .byte $E2
ABDC: 33        .byte $33
ABDD: 43        .byte $43
ABDE: 33        .byte $33
ABDF: 43        .byte $43
ABE0: 33        .byte $33
ABE1: 43        .byte $43
ABE2: fe 04 d9  INC   $D904,X
ABE5: AB        .byte $AB
ABE6: D7        .byte $D7
ABE7: 0F        .byte $0F
ABE8: E2        .byte $E2
ABE9: 00        BRK
ABEA: e1 00     SBC   ($00,X)
ABEC: fe 16 e6  INC   $E616,X
ABEF: AB        .byte $AB
ABF0: D7        .byte $D7
ABF1: 20 e1 12  JSR   $12E1
ABF4: 02        .byte $02
ABF5: D7        .byte $D7
ABF6: 12        .byte $12
ABF7: E2        .byte $E2
ABF8: a1 81     LDA   ($81,X)
ABFA: D7        .byte $D7
ABFB: 20 a2 82  JSR   $82A2
ABFE: D7        .byte $D7
ABFF: 12        .byte $12
AC00: 61 51     ADC   ($51,X)
AC02: D7        .byte $D7
AC03: 20 62 52  JSR   $5262
AC06: D7        .byte $D7
AC07: 12        .byte $12
AC08: 31 11     AND   ($11),Y
AC0A: D7        .byte $D7
AC0B: 0e e2 00  ASL   $00E2
AC0E: e1 00     SBC   ($00,X)
AC10: E2        .byte $E2
AC11: 00        BRK
AC12: e1 00     SBC   ($00,X)
AC14: E2        .byte $E2
AC15: 00        BRK
AC16: e1 00     SBC   ($00,X)
AC18: D7        .byte $D7
AC19: 90 e1     BCC   $ABFC
AC1B: 05 fe     ORA   $FE
AC1D: 03        .byte $03
AC1E: 0a        ASL
AC1F: ac d7 17  LDY   $17D7
AC22: e1 30     SBC   ($30,X)
AC24: E2        .byte $E2
AC25: a0 70     LDY   #$70
AC27: e1 20     SBC   ($20,X)
AC29: E2        .byte $E2
AC2A: 90 60     BCC   $AC8C
AC2C: e1 10     SBC   ($10,X)
AC2E: E2        .byte $E2
AC2F: 80 60     NOP   $60
AC31: e1 00     SBC   ($00,X)
AC33: E2        .byte $E2
AC34: 60        RTS
AC35: 30 d7     BMI   $AC0E
AC37: 0e e2 00  ASL   $00E2
AC3A: e1 00     SBC   ($00,X)
AC3C: E2        .byte $E2
AC3D: 00        BRK
AC3E: e1 00     SBC   ($00,X)
AC40: E2        .byte $E2
AC41: 00        BRK
AC42: e1 00     SBC   ($00,X)
AC44: D7        .byte $D7
AC45: 90 e1     BCC   $AC28
AC47: 05 fe     ORA   $FE
AC49: 02        .byte $02
AC4A: 36 ac     ROL   $AC,X
AC4C: D7        .byte $D7
AC4D: 0e e2 10  ASL   $10E2
AC50: e1 10     SBC   ($10,X)
AC52: fe 0c 4e  INC   $4E0C,X
AC55: ac d7 2f  LDY   $2FD7
AC58: E2        .byte $E2
AC59: 32        .byte $32
AC5A: 32        .byte $32
AC5B: 21 21     AND   ($21,X)
AC5D: D7        .byte $D7
AC5E: 10 10     BPL   $AC70
AC60: 10 10     BPL   $AC72
AC62: 10 d7     BPL   $AC3B
AC64: 2F        .byte $2F
AC65: 32        .byte $32
AC66: 32        .byte $32
AC67: 51 51     EOR   ($51),Y
AC69: D7        .byte $D7
AC6A: 10 60     BPL   $ACCC
AC6C: 80 80     NOP   $80
AC6E: 80 fe     NOP   $FE
AC70: FF        .byte $FF
AC71: e6 ab     INC   $AB
AC73: D7        .byte $D7
AC74: 33        .byte $33
AC75: fe 16 74  INC   $7416,X
AC78: ac 40 40  LDY   $4040
AC7B: 40        RTI
AC7C: 40        RTI
AC7D: 40        RTI
AC7E: 40        RTI
AC7F: 40        RTI
AC80: 30 30     BMI   $ACB2
AC82: 30 30     BMI   $ACB4
AC84: 30 00     BMI   $AC86
AC86: 00        BRK
AC87: 40        RTI
AC88: 00        BRK
AC89: 30 00     BMI   $AC8B
AC8B: 40        RTI
AC8C: 00        BRK
AC8D: 40        RTI
AC8E: 00        BRK
AC8F: 00        BRK
AC90: 00        BRK
AC91: 30 30     BMI   $ACC3
AC93: 40        RTI
AC94: 40        RTI
AC95: 40        RTI
AC96: 40        RTI
AC97: fe 02 81  INC   $8102,X
AC9A: ac 30 00  LDY   $0030
AC9D: 00        BRK
AC9E: 30 00     BMI   $ACA0
ACA0: 00        BRK
ACA1: 40        RTI
ACA2: 00        BRK
ACA3: 30 00     BMI   $ACA5
ACA5: fe 02 9b  INC   $9B02,X
ACA8: ac 30 00  LDY   $0030
ACAB: 00        BRK
ACAC: 30 00     BMI   $ACAE
ACAE: 00        BRK
ACAF: 40        RTI
ACB0: 40        RTI
ACB1: 40        RTI
ACB2: 40        RTI
ACB3: 30 30     BMI   $ACE5
ACB5: 30 30     BMI   $ACE7
ACB7: 30 30     BMI   $ACE9
ACB9: 40        RTI
ACBA: 40        RTI
ACBB: 40        RTI
ACBC: 30 40     BMI   $ACFE
ACBE: 30 fe     BMI   $ACBE
ACC0: 03        .byte $03
ACC1: B3        .byte $B3
ACC2: ac 40 40  LDY   $4040
ACC5: 40        RTI
ACC6: 40        RTI
ACC7: 40        RTI
ACC8: 40        RTI
ACC9: 40        RTI
ACCA: 40        RTI
ACCB: 40        RTI
ACCC: 40        RTI
ACCD: 40        RTI
ACCE: 40        RTI
ACCF: 30 30     BMI   $AD01
ACD1: 30 30     BMI   $AD03
ACD3: 30 30     BMI   $AD05
ACD5: 40        RTI
ACD6: 40        RTI
ACD7: 40        RTI
ACD8: 30 40     BMI   $AD1A
ACDA: 30 30     BMI   $AD0C
ACDC: 30 30     BMI   $AD0E
ACDE: 30 30     BMI   $AD10
ACE0: 30 40     BMI   $AD22
ACE2: 40        RTI
ACE3: 40        RTI
ACE4: 40        RTI
ACE5: 40        RTI
ACE6: 40        RTI
ACE7: 30 30     BMI   $AD19
ACE9: 30 40     BMI   $AD2B
ACEB: 30 30     BMI   $AD1D
ACED: 30 00     BMI   $ACEF
ACEF: 30 40     BMI   $AD31
ACF1: 30 30     BMI   $AD23
ACF3: 30 30     BMI   $AD25
ACF5: 30 40     BMI   $AD37
ACF7: 30 30     BMI   $AD29
ACF9: 30 00     BMI   $ACFB
ACFB: 30 40     BMI   $AD3D
ACFD: 40        RTI
ACFE: 40        RTI
ACFF: 40        RTI
AD00: 30 30     BMI   $AD32
AD02: 40        RTI
AD03: 30 30     BMI   $AD35
AD05: 40        RTI
AD06: 30 40     BMI   $AD48
AD08: 30 40     BMI   $AD4A
AD0A: 40        RTI
AD0B: 40        RTI
AD0C: 40        RTI
AD0D: 40        RTI
AD0E: 30 30     BMI   $AD40
AD10: 40        RTI
AD11: 30 30     BMI   $AD43
AD13: 40        RTI
AD14: 30 40     BMI   $AD56
AD16: 30 40     BMI   $AD58
AD18: 40        RTI
AD19: 40        RTI
AD1A: 30 fe     BMI   $AD1A
AD1C: FF        .byte $FF
AD1D: 81 ac     STA   ($AC,X)
AD1F: 07        .byte $07
AD20: 07        .byte $07
AD21: 06 05     ASL   $05
AD23: 04 03     NOP   $03
AD25: 00        BRK
AD26: 00        BRK
AD27: 00        BRK
AD28: 01 01     ORA   ($01,X)
AD2A: 01 ff     ORA   ($FF,X)
AD2C: 07        .byte $07
AD2D: 06 05     ASL   $05
AD2F: 04 03     NOP   $03
AD31: FF        .byte $FF
AD32: 03        .byte $03
AD33: 04 05     NOP   $05
AD35: 04 03     NOP   $03
AD37: 02        .byte $02
AD38: FF        .byte $FF
AD39: 06 07     ASL   $07
AD3B: 06 05     ASL   $05
AD3D: 04 03     NOP   $03
AD3F: 00        BRK
AD40: 00        BRK
AD41: 00        BRK
AD42: 00        BRK
AD43: 01 01     ORA   ($01,X)
AD45: FF        .byte $FF
AD46: 07        .byte $07
AD47: 06 05     ASL   $05
AD49: 04 03     NOP   $03
AD4B: 00        BRK
AD4C: 00        BRK
AD4D: 00        BRK
AD4E: 00        BRK
AD4F: 00        BRK
AD50: 01 01     ORA   ($01,X)
AD52: FF        .byte $FF
AD53: 05 04     ORA   $04
AD55: 03        .byte $03
AD56: 03        .byte $03
AD57: 03        .byte $03
AD58: 00        BRK
AD59: 00        BRK
AD5A: 00        BRK
AD5B: 00        BRK
AD5C: 00        BRK
AD5D: 01 01     ORA   ($01,X)
AD5F: FF        .byte $FF
AD60: d6 35     DEC   $35,X
AD62: 08        PHP
AD63: 02        .byte $02
AD64: E2        .byte $E2
AD65: 41 41     EOR   ($41,X)
AD67: d6 35     DEC   $35,X
AD69: 0a        ASL
AD6A: 01 71     ORA   ($71,X)
AD6C: 41 b2     EOR   ($B2,X)
AD6E: 92        .byte $92
AD6F: 71 fe     ADC   ($FE),Y
AD71: 03        .byte $03
AD72: 60        RTS
AD73: ad d6 35  LDA   $35D6
AD76: 08        PHP
AD77: 02        .byte $02
AD78: E2        .byte $E2
AD79: 41 41     EOR   ($41,X)
AD7B: d6 35     DEC   $35,X
AD7D: 0a        ASL
AD7E: 01 71     ORA   ($71,X)
AD80: 41 92     EOR   ($92,X)
AD82: B2        .byte $B2
AD83: e1 01     SBC   ($01,X)
AD85: d6 f7     DEC   $F7,X
AD87: 08        PHP
AD88: 02        .byte $02
AD89: E2        .byte $E2
AD8A: 51 51     EOR   ($51),Y
AD8C: d6 35     DEC   $35,X
AD8E: 0a        ASL
AD8F: 01 91     ORA   ($91,X)
AD91: 51 e1     EOR   ($E1),Y
AD93: 02        .byte $02
AD94: E2        .byte $E2
AD95: B2        .byte $B2
AD96: 91 fe     STA   ($FE),Y
AD98: 03        .byte $03
AD99: 85 ad     STA   $AD
AD9B: d6 f7     DEC   $F7,X
AD9D: 08        PHP
AD9E: 02        .byte $02
AD9F: 51 51     EOR   ($51),Y
ADA1: d6 35     DEC   $35,X
ADA3: 0a        ASL
ADA4: 01 91     ORA   ($91,X)
ADA6: 51 b2     EOR   ($B2),Y
ADA8: e1 02     SBC   ($02,X)
ADAA: 11 ff     ORA   ($FF),Y
ADAC: ec 01 d6  CPX   $D601
ADAF: F7        .byte $F7
ADB0: 08        PHP
ADB1: 02        .byte $02
ADB2: E2        .byte $E2
ADB3: 41 41     EOR   ($41,X)
ADB5: d6 f5     DEC   $F5,X
ADB7: 0a        ASL
ADB8: 01 71     ORA   ($71,X)
ADBA: 41 b2     EOR   ($B2,X)
ADBC: 92        .byte $92
ADBD: 71 fe     ADC   ($FE),Y
ADBF: 03        .byte $03
ADC0: ac ad d6  LDY   $D6AD
ADC3: F7        .byte $F7
ADC4: 08        PHP
ADC5: 02        .byte $02
ADC6: E2        .byte $E2
ADC7: 41 41     EOR   ($41,X)
ADC9: d6 f5     DEC   $F5,X
ADCB: 0a        ASL
ADCC: 01 71     ORA   ($71,X)
ADCE: 41 92     EOR   ($92,X)
ADD0: B2        .byte $B2
ADD1: e1 01     SBC   ($01,X)
ADD3: d6 f7     DEC   $F7,X
ADD5: 08        PHP
ADD6: 02        .byte $02
ADD7: E2        .byte $E2
ADD8: 51 51     EOR   ($51),Y
ADDA: d6 f5     DEC   $F5,X
ADDC: 0a        ASL
ADDD: 01 91     ORA   ($91,X)
ADDF: 51 e1     EOR   ($E1),Y
ADE1: 02        .byte $02
ADE2: E2        .byte $E2
ADE3: B2        .byte $B2
ADE4: 91 fe     STA   ($FE),Y
ADE6: 03        .byte $03
ADE7: D3        .byte $D3
ADE8: ad d6 f7  LDA   $F7D6
ADEB: 08        PHP
ADEC: 02        .byte $02
ADED: 51 51     EOR   ($51),Y
ADEF: d6 f5     DEC   $F5,X
ADF1: 0a        ASL
ADF2: 01 91     ORA   ($91,X)
ADF4: 51 b2     EOR   ($B2),Y
ADF6: e1 02     SBC   ($02,X)
ADF8: 11 d6     ORA   ($D6),Y
ADFA: 37        .byte $37
ADFB: 0B        .byte $0B
ADFC: 02        .byte $02
ADFD: E2        .byte $E2
ADFE: 00        BRK
ADFF: 01 e3     ORA   ($E3,X)
AE01: b4 d6     LDY   $D6,X
AE03: F7        .byte $F7
AE04: 0d 03 e2  ORA   $E203
AE07: 91 91     STA   ($91),Y
AE09: B3        .byte $B3
AE0A: d6 37     DEC   $37,X
AE0C: 0B        .byte $0B
AE0D: 02        .byte $02
AE0E: E3        .byte $E3
AE0F: 90 91     BCC   $ADA2
AE11: b4 d6     LDY   $D6,X
AE13: F7        .byte $F7
AE14: 0d 03 e1  ORA   $E103
AE17: 01 01     ORA   ($01,X)
AE19: 23        .byte $23
AE1A: d6 37     DEC   $37,X
AE1C: 0B        .byte $0B
AE1D: 02        .byte $02
AE1E: E2        .byte $E2
AE1F: 00        BRK
AE20: 01 e3     ORA   ($E3,X)
AE22: b4 d6     LDY   $D6,X
AE24: F7        .byte $F7
AE25: 0d 03 e1  ORA   $E103
AE28: 41 41     EOR   ($41,X)
AE2A: 53        .byte $53
AE2B: d6 37     DEC   $37,X
AE2D: 0B        .byte $0B
AE2E: 02        .byte $02
AE2F: E3        .byte $E3
AE30: 90 91     BCC   $ADC3
AE32: b4 d6     LDY   $D6,X
AE34: F7        .byte $F7
AE35: 0d 02 e1  ORA   $E102
AE38: 90 92     BCC   $ADCC
AE3A: 90 92     BCC   $ADCE
AE3C: fd 60 ad  SBC   $AD60,X
AE3F: d6 35     DEC   $35,X
AE41: 84 08     STY   $08
AE43: E3        .byte $E3
AE44: 73        .byte $73
AE45: 43        .byte $43
AE46: 83        .byte $83
AE47: 43        .byte $43
AE48: fe 04 3f  INC   $3F04,X
AE4B: ae 71 71  LDX   $7171
AE4E: 41 41     EOR   ($41,X)
AE50: 81 81     STA   ($81,X)
AE52: 41 41     EOR   ($41,X)
AE54: fe 04 4c  INC   $4C04,X
AE57: ae fd 60  LDX   $60FD
AE5A: ad fe ff  LDA   $FFFE
AE5D: f9 ad d6  SBC   $D6AD,Y
AE60: F7        .byte $F7
AE61: 08        PHP
AE62: 02        .byte $02
AE63: E2        .byte $E2
AE64: 91 91     STA   ($91),Y
AE66: d6 f7     DEC   $F7,X
AE68: 09 01     ORA   #$01
AE6A: e1 01     SBC   ($01,X)
AE6C: E2        .byte $E2
AE6D: 91 e1     STA   ($E1),Y
AE6F: 32        .byte $32
AE70: 22        .byte $22
AE71: 01 fe     ORA   ($FE,X)
AE73: 03        .byte $03
AE74: 5F        .byte $5F
AE75: ae d6 f7  LDX   $F7D6
AE78: 08        PHP
AE79: 02        .byte $02
AE7A: E2        .byte $E2
AE7B: 91 91     STA   ($91),Y
AE7D: d6 f7     DEC   $F7,X
AE7F: 09 01     ORA   #$01
AE81: e1 01     SBC   ($01,X)
AE83: E2        .byte $E2
AE84: 91 e1     STA   ($E1),Y
AE86: 22        .byte $22
AE87: 32        .byte $32
AE88: 41 d6     EOR   ($D6,X)
AE8A: F7        .byte $F7
AE8B: 08        PHP
AE8C: 02        .byte $02
AE8D: E2        .byte $E2
AE8E: b1 b1     LDA   ($B1),Y
AE90: d6 f7     DEC   $F7,X
AE92: 09 01     ORA   #$01
AE94: e1 21     SBC   ($21,X)
AE96: E2        .byte $E2
AE97: b1 e1     LDA   ($E1),Y
AE99: 52        .byte $52
AE9A: 42        .byte $42
AE9B: 21 fe     AND   ($FE,X)
AE9D: 03        .byte $03
AE9E: 89        .byte $89
AE9F: ae d6 f7  LDX   $F7D6
AEA2: 08        PHP
AEA3: 02        .byte $02
AEA4: E2        .byte $E2
AEA5: b1 b1     LDA   ($B1),Y
AEA7: d6 f7     DEC   $F7,X
AEA9: 09 01     ORA   #$01
AEAB: e1 21     SBC   ($21,X)
AEAD: E2        .byte $E2
AEAE: b1 e1     LDA   ($E1),Y
AEB0: 42        .byte $42
AEB1: 52        .byte $52
AEB2: 61 ff     ADC   ($FF,X)
AEB4: ec 01 fd  CPX   $FD01
AEB7: 5F        .byte $5F
AEB8: ae d6 f7  LDX   $F7D6
AEBB: 0B        .byte $0B
AEBC: 02        .byte $02
AEBD: E2        .byte $E2
AEBE: 50 51     BVC   $AF11
AEC0: 44 d6     NOP   $D6
AEC2: B7        .byte $B7
AEC3: 0c 03 e1  NOP   $E103
AEC6: 21 21     AND   ($21,X)
AEC8: 43        .byte $43
AEC9: d6 f7     DEC   $F7,X
AECB: 0B        .byte $0B
AECC: 02        .byte $02
AECD: E2        .byte $E2
AECE: 20 21 44  JSR   $4421
AED1: d6 b7     DEC   $B7,X
AED3: 0c 03 e1  NOP   $E103
AED6: 51 51     EOR   ($51),Y
AED8: 73        .byte $73
AED9: d6 f7     DEC   $F7,X
AEDB: 0B        .byte $0B
AEDC: 02        .byte $02
AEDD: E2        .byte $E2
AEDE: 50 51     BVC   $AF31
AEE0: 44 d6     NOP   $D6
AEE2: B7        .byte $B7
AEE3: 0c 03 e1  NOP   $E103
AEE6: 91 91     STA   ($91),Y
AEE8: B3        .byte $B3
AEE9: d6 f7     DEC   $F7,X
AEEB: 0B        .byte $0B
AEEC: 02        .byte $02
AEED: E2        .byte $E2
AEEE: 20 21 44  JSR   $4421
AEF1: d6 b7     DEC   $B7,X
AEF3: 0c 03 e0  NOP   $E003
AEF6: 20 22 40  JSR   $4022
AEF9: 42        .byte $42
AEFA: fd 5f ae  SBC   $AE5F,X
AEFD: d6 38     DEC   $38,X
AEFF: 87        .byte $87
AF00: 08        PHP
AF01: E2        .byte $E2
AF02: 03        .byte $03
AF03: E3        .byte $E3
AF04: 93        .byte $93
AF05: E2        .byte $E2
AF06: 13        .byte $13
AF07: E3        .byte $E3
AF08: 93        .byte $93
AF09: fe 04 fd  INC   $FD04,X
AF0C: ae e2 01  LDX   $01E2
AF0F: 01 e3     ORA   ($E3,X)
AF11: 91 91     STA   ($91),Y
AF13: E2        .byte $E2
AF14: 11 11     ORA   ($11),Y
AF16: E3        .byte $E3
AF17: 91 91     STA   ($91),Y
AF19: fe 04 0d  INC   $0D04,X
AF1C: AF        .byte $AF
AF1D: fe ff b4  INC   $B4FF,X
AF20: ae d6 10  LDX   $10D6
AF23: E3        .byte $E3
AF24: 91 fe     STA   ($FE),Y
AF26: 20 24 af  JSR   $AF24
AF29: b1 fe     LDA   ($FE),Y
AF2B: 20 29 af  JSR   $AF29
AF2E: FF        .byte $FF
AF2F: ec 01 d6  CPX   $D601
AF32: 10 e2     BPL   $AF16
AF34: 91 91     STA   ($91),Y
AF36: CB        .byte $CB
AF37: fe 04 2f  INC   $2F04,X
AF3A: AF        .byte $AF
AF3B: E3        .byte $E3
AF3C: b1 fe     LDA   ($FE),Y
AF3E: 20 3b af  JSR   $AF3B
AF41: d6 10     DEC   $10,X
AF43: E2        .byte $E2
AF44: 50 50     BVC   $AF96
AF46: c0 d6     CPY   #$D6
AF48: 7F        .byte $7F
AF49: 44 d6     NOP   $D6
AF4B: 10 21     BPL   $AF6E
AF4D: 21 43     AND   ($43,X)
AF4F: 20 20 c0  JSR   $C020
AF52: d6 7f     DEC   $7F,X
AF54: 44 d6     NOP   $D6
AF56: 10 51     BPL   $AFA9
AF58: 51 73     EOR   ($73),Y
AF5A: 50 50     BVC   $AFAC
AF5C: c0 d6     CPY   #$D6
AF5E: 7F        .byte $7F
AF5F: 44 d6     NOP   $D6
AF61: 10 91     BPL   $AEF4
AF63: 91 b3     STA   ($B3),Y
AF65: 20 20 c0  JSR   $C020
AF68: d6 7f     DEC   $7F,X
AF6A: 44 d6     NOP   $D6
AF6C: 10 20     BPL   $AF8E
AF6E: 22        .byte $22
AF6F: 40        RTI
AF70: 42        .byte $42
AF71: fd 21 af  SBC   $AF21,X
AF74: d6 15     DEC   $15,X
AF76: E2        .byte $E2
AF77: 03        .byte $03
AF78: 93        .byte $93
AF79: 13        .byte $13
AF7A: 93        .byte $93
AF7B: fe 04 74  INC   $7404,X
AF7E: AF        .byte $AF
AF7F: 01 01     ORA   ($01,X)
AF81: 91 91     STA   ($91),Y
AF83: 11 11     ORA   ($11),Y
AF85: 91 91     STA   ($91),Y
AF87: fe 04 7f  INC   $7F04,X
AF8A: AF        .byte $AF
AF8B: fd 21 af  SBC   $AF21,X
AF8E: fe ff 41  INC   $41FF,X
AF91: AF        .byte $AF
AF92: 31 01     AND   ($01),Y
AF94: 41 01     EOR   ($01,X)
AF96: 31 31     AND   ($31),Y
AF98: 41 01     EOR   ($01,X)
AF9A: fe 03 92  INC   $9203,X
AF9D: AF        .byte $AF
AF9E: 31 01     AND   ($01),Y
AFA0: 41 01     EOR   ($01,X)
AFA2: 31 31     AND   ($31),Y
AFA4: 41 40     EOR   ($40,X)
AFA6: 40        RTI
AFA7: 31 01     AND   ($01),Y
AFA9: 41 01     EOR   ($01,X)
AFAB: 31 31     AND   ($31),Y
AFAD: 41 01     EOR   ($01,X)
AFAF: fe 03 a7  INC   $A703,X
AFB2: AF        .byte $AF
AFB3: 31 01     AND   ($01),Y
AFB5: 41 01     EOR   ($01,X)
AFB7: 40        RTI
AFB8: 40        RTI
AFB9: 41 41     EOR   ($41,X)
AFBB: 40        RTI
AFBC: 40        RTI
AFBD: FF        .byte $FF
AFBE: d6 31     DEC   $31,X
AFC0: 31 03     AND   ($03),Y
AFC2: 03        .byte $03
AFC3: 03        .byte $03
AFC4: fe 03 be  INC   $BE03,X
AFC7: AF        .byte $AF
AFC8: 31 31     AND   ($31),Y
AFCA: 33        .byte $33
AFCB: 33        .byte $33
AFCC: 40        RTI
AFCD: 40        RTI
AFCE: 41 31     EOR   ($31,X)
AFD0: 01 41     ORA   ($41,X)
AFD2: 01 31     ORA   ($31,X)
AFD4: 31 41     AND   ($41),Y
AFD6: 01 fe     ORA   ($FE,X)
AFD8: 03        .byte $03
AFD9: CF        .byte $CF
AFDA: AF        .byte $AF
AFDB: 31 01     AND   ($01),Y
AFDD: 41 01     EOR   ($01,X)
AFDF: 31 31     AND   ($31),Y
AFE1: 41 40     EOR   ($40,X)
AFE3: 40        RTI
AFE4: 40        RTI
AFE5: 40        RTI
AFE6: 30 40     BMI   $B028
AFE8: 00        BRK
AFE9: 00        BRK
AFEA: 31 31     AND   ($31),Y
AFEC: 31 41     AND   ($41),Y
AFEE: 00        BRK
AFEF: 00        BRK
AFF0: fe 03 e4  INC   $E403,X
AFF3: AF        .byte $AF
AFF4: 40        RTI
AFF5: 40        RTI
AFF6: 30 40     BMI   $B038
AFF8: 00        BRK
AFF9: 00        BRK
AFFA: 31 40     AND   ($40),Y
AFFC: 40        RTI
AFFD: 00        BRK
AFFE: 00        BRK
AFFF: 40        RTI
B000: 40        RTI
B001: 00        BRK
B002: 00        BRK
B003: fd 92 af  SBC   $AF92,X
B006: 31 31     AND   ($31),Y
B008: 41 01     EOR   ($01,X)
B00A: 31 31     AND   ($31),Y
B00C: 41 01     EOR   ($01,X)
B00E: 31 01     AND   ($01),Y
B010: 41 01     EOR   ($01,X)
B012: 31 31     AND   ($31),Y
B014: 41 01     EOR   ($01,X)
B016: 31 31     AND   ($31),Y
B018: 41 01     EOR   ($01,X)
B01A: 31 31     AND   ($31),Y
B01C: 41 01     EOR   ($01,X)
B01E: 31 01     AND   ($01),Y
B020: 41 01     EOR   ($01,X)
B022: 31 31     AND   ($31),Y
B024: 40        RTI
B025: 40        RTI
B026: 40        RTI
B027: 40        RTI
B028: 31 31     AND   ($31),Y
B02A: 41 31     EOR   ($31,X)
B02C: fe 03 28  INC   $2803,X
B02F: b0 31     BCS   $B062
B031: 31 41     AND   ($41),Y
B033: 41 31     EOR   ($31,X)
B035: 31 41     AND   ($41),Y
B037: 31 fe     AND   ($FE),Y
B039: 03        .byte $03
B03A: 34 b0     NOP   $B0
B03C: 40        RTI
B03D: 40        RTI
B03E: 41 40     EOR   ($40,X)
B040: 40        RTI
B041: 40        RTI
B042: 40        RTI
B043: fd 92 af  SBC   $AF92,X
B046: fe ff e4  INC   $E4FF,X
B049: AF        .byte $AF
B04A: 05 06     ORA   $06
B04C: 05 04     ORA   $04
B04E: 03        .byte $03
B04F: 02        .byte $02
B050: 00        BRK
B051: 00        BRK
B052: 00        BRK
B053: 00        BRK
B054: 00        BRK
B055: 01 ff     ORA   ($FF,X)
B057: 0c 0b 0a  NOP   $0A0B
B05A: 09 08     ORA   #$08
B05C: 07        .byte $07
B05D: 06 ff     ASL   $FF
B05F: 08        PHP
B060: 07        .byte $07
B061: 06 05     ASL   $05
B063: 04 03     NOP   $03
B065: 03        .byte $03
B066: 00        BRK
B067: 00        BRK
B068: 00        BRK
B069: 00        BRK
B06A: 01 ff     ORA   ($FF,X)
B06C: 0a        ASL
B06D: 09 08     ORA   #$08
B06F: 07        .byte $07
B070: 06 05     ASL   $05
B072: 04 00     NOP   $00
B074: 00        BRK
B075: 00        BRK
B076: 00        BRK
B077: 01 ff     ORA   ($FF,X)
B079: e4 60     CPX   $60
B07B: 80 60     NOP   $60
B07D: 90 60     BCC   $B0DF
B07F: 80 60     NOP   $60
B081: 80 60     NOP   $60
B083: b0 60     BCS   $B0E5
B085: 80 fe     NOP   $FE
B087: 02        .byte $02
B088: 79 b0 e4  ADC   $E4B0,Y
B08B: 80 90     NOP   $90
B08D: 80 b0     NOP   $B0
B08F: 80 90     NOP   $90
B091: 80 90     NOP   $90
B093: 80 e3     NOP   $E3
B095: 10 e4     BPL   $B07B
B097: 80 90     NOP   $90
B099: fe 02 8a  INC   $8A02,X
B09C: b0 e4     BCS   $B082
B09E: 90 b0     BCC   $B050
B0A0: 90 e3     BCC   $B085
B0A2: 10 e4     BPL   $B088
B0A4: 90 b0     BCC   $B056
B0A6: 90 b0     BCC   $B058
B0A8: 90 e3     BCC   $B08D
B0AA: 10 e4     BPL   $B090
B0AC: 90 b0     BCC   $B05E
B0AE: fe 02 9d  INC   $9D02,X
B0B1: b0 e4     BCS   $B097
B0B3: b0 e3     BCS   $B098
B0B5: 10 e4     BPL   $B09B
B0B7: b0 e3     BCS   $B09C
B0B9: 20 e4 b0  JSR   $B0E4
B0BC: E3        .byte $E3
B0BD: 10 e4     BPL   $B0A3
B0BF: b0 e3     BCS   $B0A4
B0C1: 10 e4     BPL   $B0A7
B0C3: b0 e3     BCS   $B0A8
B0C5: 20 e4 b0  JSR   $B0E4
B0C8: E3        .byte $E3
B0C9: 10 10     BPL   $B0DB
B0CB: 20 10 40  JSR   $4010
B0CE: 10 20     BPL   $B0F0
B0D0: 10 40     BPL   $B112
B0D2: 10 50     BPL   $B124
B0D4: 10 80     BPL   $B056
B0D6: FF        .byte $FF
B0D7: D7        .byte $D7
B0D8: 36 0e     ROL   $0E,X
B0DA: 00        BRK
B0DB: E2        .byte $E2
B0DC: 60        RTS
B0DD: 61 60     ADC   ($60,X)
B0DF: 90 80     BCC   $B061
B0E1: 63        .byte $63
B0E2: 40        RTI
B0E3: 50 e2     BVC   $B0C7
B0E5: 60        RTS
B0E6: E3        .byte $E3
B0E7: 61 60     ADC   ($60,X)
B0E9: E2        .byte $E2
B0EA: 90 80     BCC   $B06C
B0EC: 91 81     STA   ($81),Y
B0EE: 41 80     EOR   ($80,X)
B0F0: 81 80     STA   ($80,X)
B0F2: b0 90     BCS   $B084
B0F4: 83        .byte $83
B0F5: 60        RTS
B0F6: 70 e2     BVS   $B0DA
B0F8: 80 e3     NOP   $E3
B0FA: 81 80     STA   ($80,X)
B0FC: E2        .byte $E2
B0FD: b0 90     BCS   $B08F
B0FF: b1 91     LDA   ($91),Y
B101: 81 90     STA   ($90,X)
B103: 91 90     STA   ($90),Y
B105: e1 10     SBC   ($10,X)
B107: E2        .byte $E2
B108: b0 93     BCS   $B09D
B10A: E2        .byte $E2
B10B: 70 80     BVS   $B08D
B10D: 90 e3     BCC   $B0F2
B10F: 91 90     STA   ($90),Y
B111: e1 10     SBC   ($10,X)
B113: E2        .byte $E2
B114: b0 e1     BCS   $B0F7
B116: 11 e2     ORA   ($E2),Y
B118: b1 91     LDA   ($91),Y
B11A: b0 b1     BCS   $B0CD
B11C: b0 e1     BCS   $B0FF
B11E: 20 10 e2  JSR   $E210
B121: B3        .byte $B3
B122: E2        .byte $E2
B123: b0 e1     BCS   $B106
B125: 00        BRK
B126: 10 e2     BPL   $B10A
B128: 11 10     ORA   ($10),Y
B12A: e1 40     SBC   ($40,X)
B12C: 50 11     BVC   $B13F
B12E: 51 81     EOR   ($81),Y
B130: fe 02 d7  INC   $D702,X
B133: b0 e8     BCS   $B11D
B135: D7        .byte $D7
B136: 38        SEC
B137: 2F        .byte $2F
B138: 00        BRK
B139: E2        .byte $E2
B13A: 20 21 e3  JSR   $E321
B13D: b0 b1     BCS   $B0F0
B13F: D7        .byte $D7
B140: 38        SEC
B141: 87        .byte $87
B142: 00        BRK
B143: E2        .byte $E2
B144: 20 20 20  JSR   $2020
B147: 20 20 20  JSR   $2020
B14A: 20 20 20  JSR   $2020
B14D: 20 20 10  JSR   $1020
B150: 20 20 20  JSR   $2020
B153: 20 20 20  JSR   $2020
B156: D7        .byte $D7
B157: 38        SEC
B158: 2F        .byte $2F
B159: 00        BRK
B15A: E2        .byte $E2
B15B: 20 21 80  JSR   $8021
B15E: 81 e1     STA   ($E1,X)
B160: 10 10     BPL   $B172
B162: 10 10     BPL   $B174
B164: 10 10     BPL   $B176
B166: 10 10     BPL   $B178
B168: 10 10     BPL   $B17A
B16A: 10 e2     BPL   $B14E
B16C: b0 e1     BCS   $B14F
B16E: 10 10     BPL   $B180
B170: 10 10     BPL   $B182
B172: 10 10     BPL   $B184
B174: E2        .byte $E2
B175: 60        RTS
B176: 61 40     ADC   ($40,X)
B178: 41 d7     EOR   ($D7,X)
B17A: 38        SEC
B17B: 87        .byte $87
B17C: 00        BRK
B17D: E2        .byte $E2
B17E: 20 20 20  JSR   $2020
B181: 20 20 20  JSR   $2020
B184: 20 20 20  JSR   $2020
B187: 20 20 10  JSR   $1020
B18A: 20 20 20  JSR   $2020
B18D: 20 20 20  JSR   $2020
B190: D7        .byte $D7
B191: 36 2f     ROL   $2F,X
B193: 00        BRK
B194: E2        .byte $E2
B195: 20 21 80  JSR   $8021
B198: 81 e1     STA   ($E1,X)
B19A: 10 10     BPL   $B1AC
B19C: 10 10     BPL   $B1AE
B19E: 10 10     BPL   $B1B0
B1A0: 10 10     BPL   $B1B2
B1A2: 10 10     BPL   $B1B4
B1A4: 10 10     BPL   $B1B6
B1A6: 40        RTI
B1A7: 40        RTI
B1A8: 40        RTI
B1A9: 40        RTI
B1AA: 40        RTI
B1AB: 40        RTI
B1AC: D7        .byte $D7
B1AD: f6 2f     INC   $2F,X
B1AF: 00        BRK
B1B0: e8        INX
B1B1: e1 60     SBC   ($60,X)
B1B3: 60        RTS
B1B4: 60        RTS
B1B5: 60        RTS
B1B6: 61 c5     ADC   ($C5,X)
B1B8: fe ff d7  INC   $D7FF,X
B1BB: b0 d7     BCS   $B194
B1BD: f8        SED
B1BE: 2e 00 fd  ROL   $FD00
B1C1: 79 b0 fd  ADC   $FDB0,Y
B1C4: 79 b0 d7  ADC   $D7B0,Y
B1C7: f8        SED
B1C8: 30 00     BMI   $B1CA
B1CA: E2        .byte $E2
B1CB: 60        RTS
B1CC: 61 40     ADC   ($40,X)
B1CE: 41 d7     EOR   ($D7,X)
B1D0: f8        SED
B1D1: 87        .byte $87
B1D2: 00        BRK
B1D3: e1 60     SBC   ($60,X)
B1D5: 60        RTS
B1D6: 60        RTS
B1D7: 60        RTS
B1D8: 60        RTS
B1D9: 60        RTS
B1DA: 80 80     NOP   $80
B1DC: 80 80     NOP   $80
B1DE: 80 80     NOP   $80
B1E0: 90 90     BCC   $B172
B1E2: 90 90     BCC   $B174
B1E4: 90 90     BCC   $B176
B1E6: b0 b0     BCS   $B198
B1E8: b0 b0     BCS   $B19A
B1EA: b0 b0     BCS   $B19C
B1EC: 60        RTS
B1ED: 60        RTS
B1EE: 60        RTS
B1EF: 60        RTS
B1F0: 60        RTS
B1F1: 60        RTS
B1F2: 80 80     NOP   $80
B1F4: 80 80     NOP   $80
B1F6: 80 80     NOP   $80
B1F8: 90 90     BCC   $B18A
B1FA: 90 90     BCC   $B18C
B1FC: 90 90     BCC   $B18E
B1FE: e0 10     CPX   #$10
B200: 10 10     BPL   $B212
B202: 10 10     BPL   $B214
B204: 10 e1     BPL   $B1E7
B206: 60        RTS
B207: 60        RTS
B208: 60        RTS
B209: 60        RTS
B20A: 60        RTS
B20B: 60        RTS
B20C: 80 80     NOP   $80
B20E: 80 80     NOP   $80
B210: 80 80     NOP   $80
B212: 90 90     BCC   $B1A4
B214: 90 90     BCC   $B1A6
B216: 90 90     BCC   $B1A8
B218: b0 b0     BCS   $B1CA
B21A: b0 b0     BCS   $B1CC
B21C: b0 b0     BCS   $B1CE
B21E: 60        RTS
B21F: 60        RTS
B220: 60        RTS
B221: 60        RTS
B222: 60        RTS
B223: 60        RTS
B224: 80 80     NOP   $80
B226: 80 80     NOP   $80
B228: 80 80     NOP   $80
B22A: 90 90     BCC   $B1BC
B22C: 90 90     BCC   $B1BE
B22E: 90 90     BCC   $B1C0
B230: e0 10     CPX   #$10
B232: 10 10     BPL   $B244
B234: 10 d7     BPL   $B20D
B236: f8        SED
B237: 30 00     BMI   $B239
B239: 11 c5     ORA   ($C5),Y
B23B: fe ff bc  INC   $BCFF,X
B23E: b1 d7     LDA   ($D7),Y
B240: 12        .byte $12
B241: E2        .byte $E2
B242: 60        RTS
B243: 60        RTS
B244: c0 60     CPY   #$60
B246: 90 80     BCC   $B1C8
B248: D7        .byte $D7
B249: 7F        .byte $7F
B24A: 63        .byte $63
B24B: D7        .byte $D7
B24C: 10 40     BPL   $B28E
B24E: 50 e2     BVC   $B232
B250: 60        RTS
B251: D7        .byte $D7
B252: 12        .byte $12
B253: E3        .byte $E3
B254: 61 60     ADC   ($60,X)
B256: E2        .byte $E2
B257: 90 80     BCC   $B1D9
B259: d1 2f     CMP   ($2F),Y
B25B: E2        .byte $E2
B25C: 80 dd     NOP   $DD
B25E: 28        PLP
B25F: 90 d7     BCC   $B238
B261: 28        PLP
B262: 81 41     STA   ($41,X)
B264: D7        .byte $D7
B265: 12        .byte $12
B266: 80 80     NOP   $80
B268: c0 80     CPY   #$80
B26A: b0 90     BCS   $B1FC
B26C: D7        .byte $D7
B26D: 7F        .byte $7F
B26E: 83        .byte $83
B26F: D7        .byte $D7
B270: 10 60     BPL   $B2D2
B272: 70 e2     BVS   $B256
B274: 80 d7     NOP   $D7
B276: 12        .byte $12
B277: E3        .byte $E3
B278: 81 80     STA   ($80,X)
B27A: E2        .byte $E2
B27B: b0 90     BCS   $B20D
B27D: D7        .byte $D7
B27E: 2F        .byte $2F
B27F: b1 91     LDA   ($91),Y
B281: 81 d7     STA   ($D7,X)
B283: 12        .byte $12
B284: 90 90     BCC   $B216
B286: c0 90     CPY   #$90
B288: e1 10     SBC   ($10,X)
B28A: E2        .byte $E2
B28B: b0 d7     BCS   $B264
B28D: 7F        .byte $7F
B28E: 93        .byte $93
B28F: D7        .byte $D7
B290: 10 e2     BPL   $B274
B292: 70 80     BVS   $B214
B294: 90 e3     BCC   $B279
B296: 91 90     STA   ($90),Y
B298: e1 10     SBC   ($10,X)
B29A: E2        .byte $E2
B29B: b0 d7     BCS   $B274
B29D: 2F        .byte $2F
B29E: e1 11     SBC   ($11,X)
B2A0: E2        .byte $E2
B2A1: b1 91     LDA   ($91),Y
B2A3: D7        .byte $D7
B2A4: 12        .byte $12
B2A5: b0 b0     BCS   $B257
B2A7: c0 b0     CPY   #$B0
B2A9: e1 20     SBC   ($20,X)
B2AB: 10 d7     BPL   $B284
B2AD: 7F        .byte $7F
B2AE: E2        .byte $E2
B2AF: B3        .byte $B3
B2B0: D7        .byte $D7
B2B1: 10 e2     BPL   $B295
B2B3: b0 e1     BCS   $B296
B2B5: 00        BRK
B2B6: 10 d7     BPL   $B28F
B2B8: 12        .byte $12
B2B9: E2        .byte $E2
B2BA: 11 10     ORA   ($10),Y
B2BC: e1 40     SBC   ($40,X)
B2BE: 50 d7     BVC   $B297
B2C0: 2F        .byte $2F
B2C1: 11 51     ORA   ($51),Y
B2C3: 81 fe     STA   ($FE,X)
B2C5: 02        .byte $02
B2C6: 3F        .byte $3F
B2C7: B2        .byte $B2
B2C8: D7        .byte $D7
B2C9: 12        .byte $12
B2CA: E2        .byte $E2
B2CB: 60        RTS
B2CC: 61 40     ADC   ($40,X)
B2CE: 41 d7     EOR   ($D7,X)
B2D0: 10 e2     BPL   $B2B4
B2D2: 20 20 20  JSR   $2020
B2D5: 20 20 20  JSR   $2020
B2D8: 20 20 20  JSR   $2020
B2DB: 20 20 10  JSR   $1020
B2DE: 20 20 20  JSR   $2020
B2E1: 20 20 20  JSR   $2020
B2E4: D7        .byte $D7
B2E5: 12        .byte $12
B2E6: E2        .byte $E2
B2E7: 20 21 80  JSR   $8021
B2EA: 81 d7     STA   ($D7,X)
B2EC: 10 60     BPL   $B34E
B2EE: 60        RTS
B2EF: 60        RTS
B2F0: 60        RTS
B2F1: 60        RTS
B2F2: 60        RTS
B2F3: 60        RTS
B2F4: 60        RTS
B2F5: 60        RTS
B2F6: 60        RTS
B2F7: 60        RTS
B2F8: 40        RTI
B2F9: 60        RTS
B2FA: 60        RTS
B2FB: 60        RTS
B2FC: 60        RTS
B2FD: 60        RTS
B2FE: 60        RTS
B2FF: D7        .byte $D7
B300: 12        .byte $12
B301: E2        .byte $E2
B302: 60        RTS
B303: 61 40     ADC   ($40,X)
B305: 41 d7     EOR   ($D7,X)
B307: 10 20     BPL   $B329
B309: 20 20 20  JSR   $2020
B30C: 20 20 20  JSR   $2020
B30F: 20 20 20  JSR   $2020
B312: 20 10 20  JSR   $2010
B315: 20 20 20  JSR   $2020
B318: 20 20 d7  JSR   $D720
B31B: 12        .byte $12
B31C: 20 21 80  JSR   $8021
B31F: 81 d7     STA   ($D7,X)
B321: 0F        .byte $0F
B322: 60        RTS
B323: 60        RTS
B324: 60        RTS
B325: 60        RTS
B326: 60        RTS
B327: 60        RTS
B328: 80 80     NOP   $80
B32A: 80 80     NOP   $80
B32C: 80 80     NOP   $80
B32E: 90 90     BCC   $B2C0
B330: 90 90     BCC   $B2C2
B332: 90 90     BCC   $B2C4
B334: D7        .byte $D7
B335: 0F        .byte $0F
B336: 60        RTS
B337: 60        RTS
B338: 60        RTS
B339: 60        RTS
B33A: 60        RTS
B33B: c0 c5     CPY   #$C5
B33D: fe ff 3f  INC   $3FFF,X
B340: B2        .byte $B2
B341: 40        RTI
B342: 40        RTI
B343: 00        BRK
B344: 40        RTI
B345: 40        RTI
B346: 00        BRK
B347: 40        RTI
B348: 40        RTI
B349: 40        RTI
B34A: 40        RTI
B34B: 40        RTI
B34C: 30 fe     BMI   $B34C
B34E: 03        .byte $03
B34F: 47        .byte $47
B350: B3        .byte $B3
B351: FF        .byte $FF
B352: D7        .byte $D7
B353: 30 40     BMI   $B395
B355: 10 30     BPL   $B387
B357: 40        RTI
B358: 30 30     BMI   $B38A
B35A: 10 00     BPL   $B35C
B35C: 10 40     BPL   $B39E
B35E: 40        RTI
B35F: 30 40     BMI   $B3A1
B361: 10 30     BPL   $B393
B363: 40        RTI
B364: 30 40     BMI   $B3A6
B366: 30 40     BMI   $B3A8
B368: 30 40     BMI   $B3AA
B36A: 40        RTI
B36B: fe 07 52  INC   $5207,X
B36E: B3        .byte $B3
B36F: 30 40     BMI   $B3B1
B371: 10 30     BPL   $B3A3
B373: 40        RTI
B374: 30 30     BMI   $B3A6
B376: 10 00     BPL   $B378
B378: 10 40     BPL   $B3BA
B37A: 40        RTI
B37B: 30 40     BMI   $B3BD
B37D: 10 30     BPL   $B3AF
B37F: 40        RTI
B380: 30 40     BMI   $B3C2
B382: 40        RTI
B383: 40        RTI
B384: 40        RTI
B385: 40        RTI
B386: 40        RTI
B387: fd 41 b3  SBC   $B341,X
B38A: fd 41 b3  SBC   $B341,X
B38D: fd 41 b3  SBC   $B341,X
B390: fd 41 b3  SBC   $B341,X
B393: 40        RTI
B394: 40        RTI
B395: 40        RTI
B396: 40        RTI
B397: 40        RTI
B398: 00        BRK
B399: 40        RTI
B39A: 30 40     BMI   $B3DC
B39C: 30 40     BMI   $B3DE
B39E: 40        RTI
B39F: fe ff 52  INC   $52FF,X
B3A2: B3        .byte $B3
B3A3: 08        PHP
B3A4: 07        .byte $07
B3A5: 06 05     ASL   $05
B3A7: 04 03     NOP   $03
B3A9: 03        .byte $03
B3AA: 00        BRK
B3AB: 00        BRK
B3AC: 00        BRK
B3AD: 00        BRK
B3AE: 01 ff     ORA   ($FF,X)
B3B0: 06 07     ASL   $07
B3B2: 06 05     ASL   $05
B3B4: 04 03     NOP   $03
B3B6: FF        .byte $FF
B3B7: 04 05     NOP   $05
B3B9: 04 03     NOP   $03
B3BB: FF        .byte $FF
B3BC: 09 08     ORA   #$08
B3BE: 07        .byte $07
B3BF: 06 05     ASL   $05
B3C1: 04 03     NOP   $03
B3C3: 00        BRK
B3C4: 00        BRK
B3C5: 00        BRK
B3C6: 00        BRK
B3C7: 01 ff     ORA   ($FF,X)
B3C9: 08        PHP
B3CA: 07        .byte $07
B3CB: 06 05     ASL   $05
B3CD: 04 03     NOP   $03
B3CF: 03        .byte $03
B3D0: 00        BRK
B3D1: 00        BRK
B3D2: 00        BRK
B3D3: 00        BRK
B3D4: 01 ff     ORA   ($FF,X)
B3D6: D7        .byte $D7
B3D7: F7        .byte $F7
B3D8: 35 00     AND   $00,X
B3DA: e1 c0     SBC   ($C0,X)
B3DC: 10 10     BPL   $B3EE
B3DE: 10 12     BPL   $B3F2
B3E0: 30 30     BMI   $B412
B3E2: 30 30     BMI   $B414
B3E4: E2        .byte $E2
B3E5: b0 b0     BCS   $B397
B3E7: b0 b1     BCS   $B39A
B3E9: D7        .byte $D7
B3EA: F7        .byte $F7
B3EB: 0F        .byte $0F
B3EC: 00        BRK
B3ED: E2        .byte $E2
B3EE: 40        RTI
B3EF: 50 90     BVC   $B381
B3F1: D7        .byte $D7
B3F2: F7        .byte $F7
B3F3: 11 02     ORA   ($02),Y
B3F5: bd ff d7  LDA   $D7FF,X
B3F8: F7        .byte $F7
B3F9: 16 00     ASL   $00,X
B3FB: e1 c0     SBC   ($C0,X)
B3FD: 40        RTI
B3FE: 40        RTI
B3FF: 40        RTI
B400: 42        .byte $42
B401: 60        RTS
B402: 60        RTS
B403: 60        RTS
B404: 60        RTS
B405: 20 20 20  JSR   $2020
B408: 21 d7     AND   ($D7,X)
B40A: F7        .byte $F7
B40B: 0F        .byte $0F
B40C: 00        BRK
B40D: E2        .byte $E2
B40E: 90 b0     BCC   $B3C0
B410: e1 20     SBC   ($20,X)
B412: D7        .byte $D7
B413: F7        .byte $F7
B414: 10 02     BPL   $B418
B416: 4d ff d7  EOR   $D7FF
B419: 10 e2     BPL   $B3FD
B41B: c0 90     CPY   #$90
B41D: 90 90     BCC   $B3AF
B41F: 90 c1     BCC   $B3E2
B421: b0 b0     BCS   $B3D3
B423: b0 b0     BCS   $B3D5
B425: 70 70     BVS   $B497
B427: 70 70     BVS   $B499
B429: c0 e3     CPY   #$E3
B42B: 70 90     BVS   $B3BD
B42D: E2        .byte $E2
B42E: 00        BRK
B42F: D7        .byte $D7
B430: 90 4d     BCC   $B47F
B432: FF        .byte $FF
B433: D7        .byte $D7
B434: c0 40     CPY   #$40
B436: 40        RTI
B437: 40        RTI
B438: 40        RTI
B439: 11 40     ORA   ($40),Y
B43B: 40        RTI
B43C: 40        RTI
B43D: 40        RTI
B43E: 40        RTI
B43F: 40        RTI
B440: 40        RTI
B441: 40        RTI
B442: c0 30     CPY   #$30
B444: 40        RTI
B445: 40        RTI
B446: 40        RTI
B447: FF        .byte $FF
B448: EB        .byte $EB
B449: 30 31     BMI   $B47C
B44B: D7        .byte $D7
B44C: 39 86 05  AND   $0586,Y
B44F: E2        .byte $E2
B450: c1 07     CMP   ($07,X)
B452: B7        .byte $B7
B453: 97        .byte $97
B454: 57        .byte $57
B455: D7        .byte $D7
B456: 37        .byte $37
B457: 84 02     STY   $02
B459: E3        .byte $E3
B45A: 9F        .byte $9F
B45B: E3        .byte $E3
B45C: 9F        .byte $9F
B45D: FF        .byte $FF
B45E: EB        .byte $EB
B45F: 30 31     BMI   $B492
B461: D7        .byte $D7
B462: 3B        .byte $3B
B463: 87        .byte $87
B464: 05 e2     ORA   $E2
B466: c1 97     CMP   ($97,X)
B468: e1 77     SBC   ($77,X)
B46A: 57        .byte $57
B46B: 27        .byte $27
B46C: D7        .byte $D7
B46D: 3B        .byte $3B
B46E: 87        .byte $87
B46F: 02        .byte $02
B470: E3        .byte $E3
B471: 4F        .byte $4F
B472: E2        .byte $E2
B473: 1F        .byte $1F
B474: FF        .byte $FF
B475: D7        .byte $D7
B476: 90 e2     BCC   $B45A
B478: c1 97     CMP   ($97,X)
B47A: e1 77     SBC   ($77,X)
B47C: 57        .byte $57
B47D: 27        .byte $27
B47E: E3        .byte $E3
B47F: 93        .byte $93
B480: 43        .byte $43
B481: 93        .byte $93
B482: 43        .byte $43
B483: 9F        .byte $9F
B484: FF        .byte $FF
B485: D7        .byte $D7
B486: c1 3f     CMP   ($3F,X)
B488: 37        .byte $37
B489: 37        .byte $37
B48A: 43        .byte $43
B48B: 33        .byte $33
B48C: 43        .byte $43
B48D: 33        .byte $33
B48E: 3F        .byte $3F
B48F: FF        .byte $FF
B490: 08        PHP
B491: 07        .byte $07
B492: 06 05     ASL   $05
B494: 04 03     NOP   $03
B496: 03        .byte $03
B497: 00        BRK
B498: 00        BRK
B499: 00        BRK
B49A: 00        BRK
B49B: 01 ff     ORA   ($FF,X)
B49D: 06 05     ASL   $05
B49F: 04 03     NOP   $03
B4A1: 03        .byte $03
B4A2: 03        .byte $03
B4A3: 03        .byte $03
B4A4: 00        BRK
B4A5: 00        BRK
B4A6: 00        BRK
B4A7: 00        BRK
B4A8: 01 ff     ORA   ($FF,X)
B4AA: 05 04     ORA   $04
B4AC: 03        .byte $03
B4AD: 02        .byte $02
B4AE: 02        .byte $02
B4AF: 02        .byte $02
B4B0: 00        BRK
B4B1: 00        BRK
B4B2: 00        BRK
B4B3: 01 ff     ORA   ($FF,X)
B4B5: 08        PHP
B4B6: 07        .byte $07
B4B7: 06 05     ASL   $05
B4B9: 04 03     NOP   $03
B4BB: 00        BRK
B4BC: 00        BRK
B4BD: 00        BRK
B4BE: 01 ff     ORA   ($FF,X)
B4C0: e8        INX
B4C1: D7        .byte $D7
B4C2: B7        .byte $B7
B4C3: 12        .byte $12
B4C4: 02        .byte $02
B4C5: E2        .byte $E2
B4C6: c0 41     CPY   #$41
B4C8: 42        .byte $42
B4C9: D7        .byte $D7
B4CA: F7        .byte $F7
B4CB: 13        .byte $13
B4CC: 02        .byte $02
B4CD: 70 90     BVS   $B45F
B4CF: b0 40     BCS   $B511
B4D1: 41 22     EOR   ($22,X)
B4D3: 03        .byte $03
B4D4: e1 00     SBC   ($00,X)
B4D6: 20 45 e2  JSR   $E245
B4D9: 22        .byte $22
B4DA: 32        .byte $32
B4DB: 41 e8     EOR   ($E8,X)
B4DD: D7        .byte $D7
B4DE: F3        .byte $F3
B4DF: 14 00     NOP   $00
B4E1: e1 41     SBC   ($41,X)
B4E3: 11 e2     ORA   ($E2),Y
B4E5: a1 97     LDA   ($97,X)
B4E7: FF        .byte $FF
B4E8: D7        .byte $D7
B4E9: f8        SED
B4EA: 12        .byte $12
B4EB: 02        .byte $02
B4EC: E2        .byte $E2
B4ED: c0 91     CPY   #$91
B4EF: 92        .byte $92
B4F0: 70 90     BVS   $B482
B4F2: b0 90     BCS   $B484
B4F4: 91 72     STA   ($72),Y
B4F6: 53        .byte $53
B4F7: D7        .byte $D7
B4F8: 38        SEC
B4F9: 12        .byte $12
B4FA: 02        .byte $02
B4FB: e1 00     SBC   ($00,X)
B4FD: 20 45 d7  JSR   $D745
B500: f8        SED
B501: 12        .byte $12
B502: 02        .byte $02
B503: E2        .byte $E2
B504: 72        .byte $72
B505: 82        .byte $82
B506: 91 d7     STA   ($D7),Y
B508: 37        .byte $37
B509: 15 00     ORA   $00,X
B50B: e0 41     CPX   #$41
B50D: 11 e1     ORA   ($E1),Y
B50F: a1 97     LDA   ($97,X)
B511: FF        .byte $FF
B512: D7        .byte $D7
B513: 10 e2     BPL   $B4F7
B515: c0 90     CPY   #$90
B517: c0 90     CPY   #$90
B519: c0 c0     CPY   #$C0
B51B: E3        .byte $E3
B51C: 70 90     BVS   $B4AE
B51E: b0 90     BCS   $B4B0
B520: 91 72     STA   ($72),Y
B522: D7        .byte $D7
B523: 7F        .byte $7F
B524: 53        .byte $53
B525: D7        .byte $D7
B526: 2F        .byte $2F
B527: E2        .byte $E2
B528: 00        BRK
B529: 20 d7 7f  JSR   $7FD7
B52C: 45 d7     EOR   $D7
B52E: 10 e3     BPL   $B513
B530: 72        .byte $72
B531: 82        .byte $82
B532: 91 d7     STA   ($D7),Y
B534: 0F        .byte $0F
B535: E2        .byte $E2
B536: 41 11     EOR   ($11,X)
B538: E3        .byte $E3
B539: a1 d7     LDA   ($D7,X)
B53B: 90 97     BCC   $B4D4
B53D: FF        .byte $FF
B53E: D7        .byte $D7
B53F: c0 30     CPY   #$30
B541: 00        BRK
B542: 31 c0     AND   ($C0),Y
B544: 00        BRK
B545: 00        BRK
B546: 00        BRK
B547: 40        RTI
B548: 40        RTI
B549: 30 40     BMI   $B58B
B54B: 40        RTI
B54C: 30 43     BMI   $B591
B54E: 00        BRK
B54F: 00        BRK
B550: 05 30     ORA   $30
B552: 00        BRK
B553: 00        BRK
B554: 30 00     BMI   $B556
B556: 00        BRK
B557: 31 d7     AND   ($D7),Y
B559: 01 01     ORA   ($01,X)
B55B: 01 01     ORA   ($01,X)
B55D: FF        .byte $FF
B55E: 08        PHP
B55F: 09 08     ORA   #$08
B561: 07        .byte $07
B562: 06 05     ASL   $05
B564: 04 03     NOP   $03
B566: FF        .byte $FF
B567: 07        .byte $07
B568: 06 05     ASL   $05
B56A: 04 03     NOP   $03
B56C: 03        .byte $03
B56D: 03        .byte $03
B56E: 03        .byte $03
B56F: 03        .byte $03
B570: 03        .byte $03
B571: 00        BRK
B572: 00        BRK
B573: 00        BRK
B574: 00        BRK
B575: 01 ff     ORA   ($FF,X)
B577: FF        .byte $FF
B578: FF        .byte $FF
B579: d6 38     DEC   $38,X
B57B: 85 03     STA   $03
B57D: E2        .byte $E2
B57E: 75 e4     ADC   $E4,X
B580: 00        BRK
B581: 00        BRK
B582: 01 01     ORA   ($01,X)
B584: c1 e2     CMP   ($E2,X)
B586: 77        .byte $77
B587: e4 00     CPX   $00
B589: 00        BRK
B58A: 01 01     ORA   ($01,X)
B58C: c1 e2     CMP   ($E2,X)
B58E: B7        .byte $B7
B58F: e4 00     CPX   $00
B591: 00        BRK
B592: E2        .byte $E2
B593: 52        .byte $52
B594: 72        .byte $72
B595: 91 47     STA   ($47),Y
B597: 07        .byte $07
B598: E2        .byte $E2
B599: 57        .byte $57
B59A: 52        .byte $52
B59B: 42        .byte $42
B59C: 21 07     AND   ($07,X)
B59E: E3        .byte $E3
B59F: 42        .byte $42
B5A0: 52        .byte $52
B5A1: 71 e2     ADC   ($E2),Y
B5A3: 25 70     AND   $70
B5A5: 90 77     BCC   $B61E
B5A7: E3        .byte $E3
B5A8: B7        .byte $B7
B5A9: B2        .byte $B2
B5AA: E2        .byte $E2
B5AB: 02        .byte $02
B5AC: 21 e2     AND   ($E2,X)
B5AE: 75 e4     ADC   $E4,X
B5B0: 00        BRK
B5B1: 00        BRK
B5B2: 01 01     ORA   ($01,X)
B5B4: c1 e2     CMP   ($E2,X)
B5B6: 77        .byte $77
B5B7: e4 00     CPX   $00
B5B9: 00        BRK
B5BA: 01 01     ORA   ($01,X)
B5BC: c1 e2     CMP   ($E2,X)
B5BE: B7        .byte $B7
B5BF: e4 00     CPX   $00
B5C1: 00        BRK
B5C2: E2        .byte $E2
B5C3: 52        .byte $52
B5C4: 72        .byte $72
B5C5: 91 47     STA   ($47),Y
B5C7: 07        .byte $07
B5C8: 27        .byte $27
B5C9: 22        .byte $22
B5CA: 02        .byte $02
B5CB: E3        .byte $E3
B5CC: b1 e2     LDA   ($E2),Y
B5CE: 07        .byte $07
B5CF: 42        .byte $42
B5D0: 52        .byte $52
B5D1: 71 e2     ADC   ($E2),Y
B5D3: 25 20     AND   $20
B5D5: 40        RTI
B5D6: 27        .byte $27
B5D7: 70 90     BVS   $B569
B5D9: b1 90     LDA   ($90),Y
B5DB: b0 e1     BCS   $B5BE
B5DD: 01 e2     ORA   ($E2,X)
B5DF: 57        .byte $57
B5E0: d6 37     DEC   $37,X
B5E2: 32        .byte $32
B5E3: 00        BRK
B5E4: e1 01     SBC   ($01,X)
B5E6: 01 e2     ORA   ($E2,X)
B5E8: b1 e1     LDA   ($E1),Y
B5EA: 03        .byte $03
B5EB: 01 e2     ORA   ($E2,X)
B5ED: b1 e1     LDA   ($E1),Y
B5EF: 01 e2     ORA   ($E2,X)
B5F1: b1 b1     LDA   ($B1),Y
B5F3: 91 b3     STA   ($B3),Y
B5F5: b1 91     LDA   ($91),Y
B5F7: b1 91     LDA   ($91),Y
B5F9: 91 71     STA   ($71),Y
B5FB: 91 d6     STA   ($D6),Y
B5FD: 38        SEC
B5FE: 85 03     STA   $03
B600: 92        .byte $92
B601: B2        .byte $B2
B602: e1 01     SBC   ($01,X)
B604: d6 38     DEC   $38,X
B606: 85 08     STA   $08
B608: 43        .byte $43
B609: 23        .byte $23
B60A: 03        .byte $03
B60B: E2        .byte $E2
B60C: B3        .byte $B3
B60D: d6 37     DEC   $37,X
B60F: 32        .byte $32
B610: 00        BRK
B611: e1 21     SBC   ($21,X)
B613: 21 01     AND   ($01,X)
B615: 23        .byte $23
B616: 21 01     AND   ($01,X)
B618: 21 21     AND   ($21,X)
B61A: 21 11     AND   ($11,X)
B61C: 23        .byte $23
B61D: 21 11     AND   ($11,X)
B61F: 21 21     AND   ($21,X)
B621: 21 01     AND   ($01,X)
B623: 21 d6     AND   ($D6,X)
B625: 38        SEC
B626: 85 03     STA   $03
B628: 22        .byte $22
B629: 42        .byte $42
B62A: 51 ff     EOR   ($FF),Y
B62C: e8        INX
B62D: fd 79 b5  SBC   $B579,X
B630: e1 47     SBC   ($47,X)
B632: 57        .byte $57
B633: fd 79 b5  SBC   $B579,X
B636: e1 47     SBC   ($47,X)
B638: 5F        .byte $5F
B639: FF        .byte $FF
B63A: d6 f8     DEC   $F8,X
B63C: 31 03     AND   ($03),Y
B63E: E2        .byte $E2
B63F: 77        .byte $77
B640: 72        .byte $72
B641: e1 22     SBC   ($22,X)
B643: 09 02     ORA   #$02
B645: 52        .byte $52
B646: 49 92     EOR   #$92
B648: B2        .byte $B2
B649: e0 01     CPX   #$01
B64B: e1 77     SBC   ($77,X)
B64D: 47        .byte $47
B64E: 97        .byte $97
B64F: 92        .byte $92
B650: 72        .byte $72
B651: 51 47     EOR   ($47),Y
B653: 42        .byte $42
B654: 22        .byte $22
B655: 01 e2     ORA   ($E2,X)
B657: 7F        .byte $7F
B658: 27        .byte $27
B659: 42        .byte $42
B65A: 52        .byte $52
B65B: 71 e2     ADC   ($E2),Y
B65D: 77        .byte $77
B65E: 72        .byte $72
B65F: e1 22     SBC   ($22,X)
B661: 09 02     ORA   #$02
B663: 52        .byte $52
B664: 49 92     EOR   #$92
B666: B2        .byte $B2
B667: e0 01     CPX   #$01
B669: e1 77     SBC   ($77,X)
B66B: 47        .byte $47
B66C: 57        .byte $57
B66D: 52        .byte $52
B66E: 42        .byte $42
B66F: 21 47     AND   ($47,X)
B671: 42        .byte $42
B672: 22        .byte $22
B673: 01 e2     ORA   ($E2,X)
B675: 75 70     ADC   $70,X
B677: 90 77     BCC   $B6F0
B679: b0 e1     BCS   $B65C
B67B: 00        BRK
B67C: 21 00     AND   ($00,X)
B67E: 20 41 d6  JSR   $D641
B681: f8        SED
B682: 31 03     AND   ($03),Y
B684: e1 97     SBC   ($97,X)
B686: 79 53 41  ADC   $4153,Y
B689: 59 43 21  EOR   $2143,Y
B68C: 07        .byte $07
B68D: 02        .byte $02
B68E: 22        .byte $22
B68F: 41 d6     EOR   ($D6,X)
B691: f9 85 08  SBC   $0885,Y
B694: e1 93     SBC   ($93,X)
B696: 73        .byte $73
B697: 53        .byte $53
B698: 43        .byte $43
B699: d6 f8     DEC   $F8,X
B69B: 31 03     AND   ($03),Y
B69D: 9F        .byte $9F
B69E: 77        .byte $77
B69F: 72        .byte $72
B6A0: 52        .byte $52
B6A1: 41 57     EOR   ($57,X)
B6A3: 52        .byte $52
B6A4: 72        .byte $72
B6A5: 91 ff     STA   ($FF),Y
B6A7: fd 3a b6  SBC   $B63A,X
B6AA: 77        .byte $77
B6AB: B7        .byte $B7
B6AC: fd 3a b6  SBC   $B63A,X
B6AF: 77        .byte $77
B6B0: BF        .byte $BF
B6B1: FF        .byte $FF
B6B2: d6 7f     DEC   $7F,X
B6B4: E2        .byte $E2
B6B5: 05 d6     ORA   $D6
B6B7: 0e 00 00  ASL   $0000
B6BA: 01 01     ORA   ($01,X)
B6BC: c1 00     CMP   ($00,X)
B6BE: 00        BRK
B6BF: fe 03 b2  INC   $B203,X
B6C2: b6 d6     LDX   $D6,Y
B6C4: 7F        .byte $7F
B6C5: 05 d6     ORA   $D6
B6C7: 0e 00 00  ASL   $0000
B6CA: 41 41     EOR   ($41,X)
B6CC: c1 41     CMP   ($41,X)
B6CE: d6 7f     DEC   $7F,X
B6D0: 55 d6     EOR   $D6,X
B6D2: 0e 50 50  ASL   $5050
B6D5: 51 51     EOR   ($51),Y
B6D7: c1 50     CMP   ($50,X)
B6D9: 50 d6     BVC   $B6B1
B6DB: 7F        .byte $7F
B6DC: 45 d6     EOR   $D6
B6DE: 0e 40 40  ASL   $4040
B6E1: 41 41     EOR   ($41,X)
B6E3: c1 40     CMP   ($40,X)
B6E5: 40        RTI
B6E6: d6 7f     DEC   $7F,X
B6E8: 75 d6     ADC   $D6,X
B6EA: 0e 70 70  ASL   $7070
B6ED: 71 71     ADC   ($71),Y
B6EF: c1 70     CMP   ($70,X)
B6F1: 70 fe     BVS   $B6F1
B6F3: 02        .byte $02
B6F4: e6 b6     INC   $B6
B6F6: d6 7f     DEC   $7F,X
B6F8: E2        .byte $E2
B6F9: 05 d6     ORA   $D6
B6FB: 0e 00 00  ASL   $0000
B6FE: 01 01     ORA   ($01,X)
B700: c1 00     CMP   ($00,X)
B702: 00        BRK
B703: fe 03 f6  INC   $F603,X
B706: b6 d6     LDX   $D6,Y
B708: 7F        .byte $7F
B709: 05 d6     ORA   $D6
B70B: 0e 00 00  ASL   $0000
B70E: 41 41     EOR   ($41,X)
B710: c1 41     CMP   ($41,X)
B712: d6 7f     DEC   $7F,X
B714: 55 d6     EOR   $D6,X
B716: 0e 50 50  ASL   $5050
B719: 51 51     EOR   ($51),Y
B71B: c1 50     CMP   ($50,X)
B71D: 50 d6     BVC   $B6F5
B71F: 7F        .byte $7F
B720: 45 d6     EOR   $D6
B722: 0e 40 40  ASL   $4040
B725: 41 41     EOR   ($41,X)
B727: c1 40     CMP   ($40,X)
B729: 40        RTI
B72A: d6 7f     DEC   $7F,X
B72C: 75 d6     ADC   $D6,X
B72E: 0e 70 70  ASL   $7070
B731: 71 71     ADC   ($71),Y
B733: c1 70     CMP   ($70,X)
B735: 70 fe     BVS   $B735
B737: 02        .byte $02
B738: 2a        ROL
B739: B7        .byte $B7
B73A: d6 7f     DEC   $7F,X
B73C: E2        .byte $E2
B73D: 05 d6     ORA   $D6
B73F: 0e 00 00  ASL   $0000
B742: 01 01     ORA   ($01,X)
B744: c1 00     CMP   ($00,X)
B746: 00        BRK
B747: d6 7f     DEC   $7F,X
B749: E3        .byte $E3
B74A: b5 d6     LDA   $D6,X
B74C: 0e b0 b0  ASL   $B0B0
B74F: b1 b1     LDA   ($B1),Y
B751: c1 b0     CMP   ($B0,X)
B753: b0 d6     BCS   $B72B
B755: 7F        .byte $7F
B756: a5 d6     LDA   $D6
B758: 0e a0 a0  ASL   $A0A0
B75B: a1 a1     LDA   ($A1,X)
B75D: c1 a0     CMP   ($A0,X)
B75F: a0 d6     LDY   #$D6
B761: 7F        .byte $7F
B762: 95 d6     STA   $D6,X
B764: 0e 90 90  ASL   $9090
B767: 91 91     STA   ($91),Y
B769: c1 90     CMP   ($90,X)
B76B: 90 d6     BCC   $B743
B76D: 7F        .byte $7F
B76E: E2        .byte $E2
B76F: 25 d6     AND   $D6
B771: 0e 20 20  ASL   $2020
B774: 21 21     AND   ($21,X)
B776: c1 20     CMP   ($20,X)
B778: 20 d6 7f  JSR   $7FD6
B77B: 15 d6     ORA   $D6,X
B77D: 0e 10 10  ASL   $1010
B780: 11 11     ORA   ($11),Y
B782: c1 10     CMP   ($10,X)
B784: 10 d6     BPL   $B75C
B786: 7F        .byte $7F
B787: 25 d6     AND   $D6
B789: 0e 20 20  ASL   $2020
B78C: 21 21     AND   ($21,X)
B78E: c1 20     CMP   ($20,X)
B790: 20 ff fd  JSR   $FDFF
B793: B2        .byte $B2
B794: b6 d6     LDX   $D6,Y
B796: 7F        .byte $7F
B797: E3        .byte $E3
B798: b5 d6     LDA   $D6,X
B79A: 0e b0 b0  ASL   $B0B0
B79D: E2        .byte $E2
B79E: 71 71     ADC   ($71),Y
B7A0: c1 71     CMP   ($71,X)
B7A2: fd b2 b6  SBC   $B6B2,X
B7A5: d6 90     DEC   $90,X
B7A7: E3        .byte $E3
B7A8: BF        .byte $BF
B7A9: B7        .byte $B7
B7AA: FF        .byte $FF
B7AB: d6 31     DEC   $31,X
B7AD: 01 41     ORA   ($41,X)
B7AF: 00        BRK
B7B0: 00        BRK
B7B1: 31 31     AND   ($31),Y
B7B3: 41 01     EOR   ($01,X)
B7B5: fe 03 ab  INC   $AB03,X
B7B8: B7        .byte $B7
B7B9: 31 01     AND   ($01),Y
B7BB: 41 00     EOR   ($00,X)
B7BD: 00        BRK
B7BE: 31 41     AND   ($41),Y
B7C0: 01 40     ORA   ($40,X)
B7C2: 40        RTI
B7C3: 31 01     AND   ($01),Y
B7C5: 41 00     EOR   ($00,X)
B7C7: 00        BRK
B7C8: 31 31     AND   ($31),Y
B7CA: 41 01     EOR   ($01,X)
B7CC: fe 03 c3  INC   $C303,X
B7CF: B7        .byte $B7
B7D0: 31 01     AND   ($01),Y
B7D2: 41 00     EOR   ($00,X)
B7D4: 00        BRK
B7D5: 31 31     AND   ($31),Y
B7D7: 41 41     EOR   ($41,X)
B7D9: 31 01     AND   ($01),Y
B7DB: 41 00     EOR   ($00,X)
B7DD: 00        BRK
B7DE: 31 31     AND   ($31),Y
B7E0: 41 01     EOR   ($01,X)
B7E2: fe 03 d9  INC   $D903,X
B7E5: B7        .byte $B7
B7E6: 31 01     AND   ($01),Y
B7E8: 41 00     EOR   ($00,X)
B7EA: 00        BRK
B7EB: 31 31     AND   ($31),Y
B7ED: 41 40     EOR   ($40,X)
B7EF: 40        RTI
B7F0: 31 01     AND   ($01),Y
B7F2: 41 00     EOR   ($00,X)
B7F4: 00        BRK
B7F5: 31 31     AND   ($31),Y
B7F7: 41 01     EOR   ($01,X)
B7F9: fe 03 f0  INC   $F003,X
B7FC: B7        .byte $B7
B7FD: 31 01     AND   ($01),Y
B7FF: 41 00     EOR   ($00,X)
B801: 00        BRK
B802: 31 31     AND   ($31),Y
B804: 41 41     EOR   ($41,X)
B806: 31 01     AND   ($01),Y
B808: 01 30     ORA   ($30,X)
B80A: 30 31     BMI   $B83D
B80C: 31 41     AND   ($41),Y
B80E: 01 fe     ORA   ($FE,X)
B810: 07        .byte $07
B811: 06 b8     ASL   $B8
B813: FF        .byte $FF
B814: fd ab b7  SBC   $B7AB,X
B817: 31 01     AND   ($01),Y
B819: 01 30     ORA   ($30,X)
B81B: 30 41     BMI   $B85E
B81D: 41 31     EOR   ($31,X)
B81F: 40        RTI
B820: 40        RTI
B821: fd ab b7  SBC   $B7AB,X
B824: 33        .byte $33
B825: 03        .byte $03
B826: 33        .byte $33
B827: 03        .byte $03
B828: C7        .byte $C7
B829: FF        .byte $FF
B82A: FF        .byte $FF
B82B: FF        .byte $FF
B82C: FF        .byte $FF
B82D: FF        .byte $FF
B82E: FF        .byte $FF
B82F: FF        .byte $FF
B830: FF        .byte $FF
B831: FF        .byte $FF
B832: FF        .byte $FF
B833: FF        .byte $FF
B834: FF        .byte $FF
B835: FF        .byte $FF
B836: FF        .byte $FF
B837: FF        .byte $FF
B838: FF        .byte $FF
B839: FF        .byte $FF
B83A: FF        .byte $FF
B83B: FF        .byte $FF
B83C: FF        .byte $FF
B83D: FF        .byte $FF
B83E: FF        .byte $FF
B83F: FF        .byte $FF
B840: FF        .byte $FF
B841: FF        .byte $FF
B842: FF        .byte $FF
B843: FF        .byte $FF
B844: FF        .byte $FF
B845: FF        .byte $FF
B846: FF        .byte $FF
B847: FF        .byte $FF
B848: FF        .byte $FF
B849: FF        .byte $FF
B84A: FF        .byte $FF
B84B: FF        .byte $FF
B84C: FF        .byte $FF
B84D: FF        .byte $FF
B84E: FF        .byte $FF
B84F: FF        .byte $FF
B850: FF        .byte $FF
B851: FF        .byte $FF
B852: FF        .byte $FF
B853: FF        .byte $FF
B854: FF        .byte $FF
B855: FF        .byte $FF
B856: FF        .byte $FF
B857: FF        .byte $FF
B858: FF        .byte $FF
B859: FF        .byte $FF
B85A: FF        .byte $FF
B85B: FF        .byte $FF
B85C: FF        .byte $FF
B85D: FF        .byte $FF
B85E: FF        .byte $FF
B85F: FF        .byte $FF
B860: FF        .byte $FF
B861: FF        .byte $FF
B862: FF        .byte $FF
B863: FF        .byte $FF
B864: FF        .byte $FF
B865: FF        .byte $FF
B866: FF        .byte $FF
B867: FF        .byte $FF
B868: FF        .byte $FF
B869: FF        .byte $FF
B86A: FF        .byte $FF
B86B: FF        .byte $FF
B86C: FF        .byte $FF
B86D: FF        .byte $FF
B86E: FF        .byte $FF
B86F: FF        .byte $FF
B870: FF        .byte $FF
B871: FF        .byte $FF
B872: FF        .byte $FF
B873: FF        .byte $FF
B874: FF        .byte $FF
B875: FF        .byte $FF
B876: FF        .byte $FF
B877: FF        .byte $FF
B878: FF        .byte $FF
B879: FF        .byte $FF
B87A: FF        .byte $FF
B87B: FF        .byte $FF
B87C: FF        .byte $FF
B87D: FF        .byte $FF
B87E: FF        .byte $FF
B87F: FF        .byte $FF
B880: 20 eb 2c  JSR   $2CEB
B883: 2d 2e 2f  AND   $2F2E
B886: fd 21 0b  SBC   $0B21,X
B889: 3c 3d 3e  NOP   $3E3D
B88C: 3F        .byte $3F
B88D: 00        BRK
B88E: 00        BRK
B88F: 00        BRK
B890: 00        BRK
B891: 00        BRK
B892: 00        BRK
B893: 00        BRK
B894: 00        BRK
B895: fe ff ff  INC   $FFFF,X
B898: FF        .byte $FF
B899: FF        .byte $FF
B89A: FF        .byte $FF
B89B: FF        .byte $FF
B89C: FF        .byte $FF
B89D: FF        .byte $FF
B89E: FF        .byte $FF
B89F: FF        .byte $FF
B8A0: FF        .byte $FF
B8A1: FF        .byte $FF
B8A2: FF        .byte $FF
B8A3: FF        .byte $FF
B8A4: FF        .byte $FF
B8A5: FF        .byte $FF
B8A6: FF        .byte $FF
B8A7: FF        .byte $FF
B8A8: FF        .byte $FF
B8A9: FF        .byte $FF
B8AA: FF        .byte $FF
B8AB: FF        .byte $FF
B8AC: FF        .byte $FF
B8AD: FF        .byte $FF
B8AE: FF        .byte $FF
B8AF: FF        .byte $FF
B8B0: FF        .byte $FF
B8B1: FF        .byte $FF
B8B2: FF        .byte $FF
B8B3: FF        .byte $FF
B8B4: FF        .byte $FF
B8B5: FF        .byte $FF
B8B6: FF        .byte $FF
B8B7: FF        .byte $FF
B8B8: FF        .byte $FF
B8B9: FF        .byte $FF
B8BA: FF        .byte $FF
B8BB: FF        .byte $FF
B8BC: FF        .byte $FF
B8BD: FF        .byte $FF
B8BE: FF        .byte $FF
B8BF: FF        .byte $FF
B8C0: 20 61 28  JSR   $2861
B8C3: 29 2a     AND   #$2A
B8C5: 2B        .byte $2B
B8C6: fd 20 81  SBC   $8120,X
B8C9: 38        SEC
B8CA: 39 3a 3b  AND   $3B3A,Y
B8CD: 02        .byte $02
B8CE: 00        BRK
B8CF: 00        BRK
B8D0: 00        BRK
B8D1: 00        BRK
B8D2: 00        BRK
B8D3: 00        BRK
B8D4: 00        BRK
B8D5: 00        BRK
B8D6: fe ff ff  INC   $FFFF,X
B8D9: FF        .byte $FF
B8DA: FF        .byte $FF
B8DB: FF        .byte $FF
B8DC: FF        .byte $FF
B8DD: FF        .byte $FF
B8DE: FF        .byte $FF
B8DF: FF        .byte $FF
B8E0: FF        .byte $FF
B8E1: FF        .byte $FF
B8E2: FF        .byte $FF
B8E3: FF        .byte $FF
B8E4: FF        .byte $FF
B8E5: FF        .byte $FF
B8E6: FF        .byte $FF
B8E7: FF        .byte $FF
B8E8: FF        .byte $FF
B8E9: FF        .byte $FF
B8EA: FF        .byte $FF
B8EB: FF        .byte $FF
B8EC: FF        .byte $FF
B8ED: FF        .byte $FF
B8EE: FF        .byte $FF
B8EF: FF        .byte $FF
B8F0: FF        .byte $FF
B8F1: FF        .byte $FF
B8F2: FF        .byte $FF
B8F3: FF        .byte $FF
B8F4: FF        .byte $FF
B8F5: FF        .byte $FF
B8F6: FF        .byte $FF
B8F7: FF        .byte $FF
B8F8: FF        .byte $FF
B8F9: FF        .byte $FF
B8FA: FF        .byte $FF
B8FB: FF        .byte $FF
B8FC: FF        .byte $FF
B8FD: FF        .byte $FF
B8FE: FF        .byte $FF
B8FF: FF        .byte $FF
B900: 20 72 28  JSR   $2872
B903: 29 2a     AND   #$2A
B905: 2B        .byte $2B
B906: fd 20 92  SBC   $9220,X
B909: 38        SEC
B90A: 39 3a 3b  AND   $3B3A,Y
B90D: 03        .byte $03
B90E: 00        BRK
B90F: 00        BRK
B910: 00        BRK
B911: 00        BRK
B912: 00        BRK
B913: 00        BRK
B914: 00        BRK
B915: 00        BRK
B916: fe ff ff  INC   $FFFF,X
B919: FF        .byte $FF
B91A: FF        .byte $FF
B91B: FF        .byte $FF
B91C: FF        .byte $FF
B91D: FF        .byte $FF
B91E: FF        .byte $FF
B91F: FF        .byte $FF
B920: FF        .byte $FF
B921: FF        .byte $FF
B922: FF        .byte $FF
B923: FF        .byte $FF
B924: FF        .byte $FF
B925: FF        .byte $FF
B926: FF        .byte $FF
B927: FF        .byte $FF
B928: FF        .byte $FF
B929: FF        .byte $FF
B92A: FF        .byte $FF
B92B: FF        .byte $FF
B92C: FF        .byte $FF
B92D: FF        .byte $FF
B92E: FF        .byte $FF
B92F: FF        .byte $FF
B930: FF        .byte $FF
B931: FF        .byte $FF
B932: FF        .byte $FF
B933: FF        .byte $FF
B934: FF        .byte $FF
B935: FF        .byte $FF
B936: FF        .byte $FF
B937: FF        .byte $FF
B938: FF        .byte $FF
B939: FF        .byte $FF
B93A: FF        .byte $FF
B93B: FF        .byte $FF
B93C: FF        .byte $FF
B93D: FF        .byte $FF
B93E: FF        .byte $FF
B93F: FF        .byte $FF
B940: 22        .byte $22
B941: 2c 0b 0c  BIT   $0C0B
B944: 0d 0e 20  ORA   $200E
B947: 21 22     AND   ($22,X)
B949: 23        .byte $23
B94A: fd 22 4c  SBC   $4C22,X
B94D: 1B        .byte $1B
B94E: 1c 1d 1e  NOP   $1E1D
B951: 30 31     BMI   $B984
B953: 32        .byte $32
B954: 33        .byte $33
B955: fe ff ff  INC   $FFFF,X
B958: FF        .byte $FF
B959: FF        .byte $FF
B95A: FF        .byte $FF
B95B: FF        .byte $FF
B95C: FF        .byte $FF
B95D: FF        .byte $FF
B95E: FF        .byte $FF
B95F: FF        .byte $FF
B960: FF        .byte $FF
B961: FF        .byte $FF
B962: FF        .byte $FF
B963: FF        .byte $FF
B964: FF        .byte $FF
B965: FF        .byte $FF
B966: FF        .byte $FF
B967: FF        .byte $FF
B968: FF        .byte $FF
B969: FF        .byte $FF
B96A: FF        .byte $FF
B96B: FF        .byte $FF
B96C: FF        .byte $FF
B96D: FF        .byte $FF
B96E: FF        .byte $FF
B96F: FF        .byte $FF
B970: FF        .byte $FF
B971: FF        .byte $FF
B972: FF        .byte $FF
B973: FF        .byte $FF
B974: FF        .byte $FF
B975: FF        .byte $FF
B976: FF        .byte $FF
B977: FF        .byte $FF
B978: FF        .byte $FF
B979: FF        .byte $FF
B97A: FF        .byte $FF
B97B: FF        .byte $FF
B97C: FF        .byte $FF
B97D: FF        .byte $FF
B97E: FF        .byte $FF
B97F: FF        .byte $FF
B980: 22        .byte $22
B981: 8e 24 25  STX   $2524
B984: 26 27     ROL   $27
B986: fd 22 ae  SBC   $AE22,X
B989: 34 35     NOP   $35
B98B: 36 37     ROL   $37,X
B98D: fd 22 ee  SBC   $EE22,X
B990: 20 21 22  JSR   $2221
B993: 23        .byte $23
B994: fd 23 0e  SBC   $0E23,X
B997: 30 31     BMI   $B9CA
B999: 32        .byte $32
B99A: 33        .byte $33
B99B: fe ff ff  INC   $FFFF,X
B99E: FF        .byte $FF
B99F: FF        .byte $FF
B9A0: FF        .byte $FF
B9A1: FF        .byte $FF
B9A2: FF        .byte $FF
B9A3: FF        .byte $FF
B9A4: FF        .byte $FF
B9A5: FF        .byte $FF
B9A6: FF        .byte $FF
B9A7: FF        .byte $FF
B9A8: FF        .byte $FF
B9A9: FF        .byte $FF
B9AA: FF        .byte $FF
B9AB: FF        .byte $FF
B9AC: FF        .byte $FF
B9AD: FF        .byte $FF
B9AE: FF        .byte $FF
B9AF: FF        .byte $FF
B9B0: FF        .byte $FF
B9B1: FF        .byte $FF
B9B2: FF        .byte $FF
B9B3: FF        .byte $FF
B9B4: FF        .byte $FF
B9B5: FF        .byte $FF
B9B6: FF        .byte $FF
B9B7: FF        .byte $FF
B9B8: FF        .byte $FF
B9B9: FF        .byte $FF
B9BA: FF        .byte $FF
B9BB: FF        .byte $FF
B9BC: FF        .byte $FF
B9BD: FF        .byte $FF
B9BE: FF        .byte $FF
B9BF: FF        .byte $FF
B9C0: FF        .byte $FF
B9C1: FF        .byte $FF
B9C2: FF        .byte $FF
B9C3: FF        .byte $FF
B9C4: FF        .byte $FF
B9C5: FF        .byte $FF
B9C6: FF        .byte $FF
B9C7: FF        .byte $FF
B9C8: FF        .byte $FF
B9C9: FF        .byte $FF
B9CA: FF        .byte $FF
B9CB: FF        .byte $FF
B9CC: FF        .byte $FF
B9CD: FF        .byte $FF
B9CE: FF        .byte $FF
B9CF: FF        .byte $FF
B9D0: FF        .byte $FF
B9D1: FF        .byte $FF
B9D2: FF        .byte $FF
B9D3: FF        .byte $FF
B9D4: FF        .byte $FF
B9D5: FF        .byte $FF
B9D6: FF        .byte $FF
B9D7: FF        .byte $FF
B9D8: FF        .byte $FF
B9D9: FF        .byte $FF
B9DA: FF        .byte $FF
B9DB: FF        .byte $FF
B9DC: FF        .byte $FF
B9DD: FF        .byte $FF
B9DE: FF        .byte $FF
B9DF: FF        .byte $FF
B9E0: FF        .byte $FF
B9E1: FF        .byte $FF
B9E2: FF        .byte $FF
B9E3: FF        .byte $FF
B9E4: FF        .byte $FF
B9E5: FF        .byte $FF
B9E6: FF        .byte $FF
B9E7: FF        .byte $FF
B9E8: FF        .byte $FF
B9E9: FF        .byte $FF
B9EA: FF        .byte $FF
B9EB: FF        .byte $FF
B9EC: FF        .byte $FF
B9ED: FF        .byte $FF
B9EE: FF        .byte $FF
B9EF: FF        .byte $FF
B9F0: FF        .byte $FF
B9F1: FF        .byte $FF
B9F2: FF        .byte $FF
B9F3: FF        .byte $FF
B9F4: FF        .byte $FF
B9F5: FF        .byte $FF
B9F6: FF        .byte $FF
B9F7: FF        .byte $FF
B9F8: FF        .byte $FF
B9F9: FF        .byte $FF
B9FA: FF        .byte $FF
B9FB: FF        .byte $FF
B9FC: FF        .byte $FF
B9FD: FF        .byte $FF
B9FE: FF        .byte $FF
B9FF: FF        .byte $FF
BA00: FF        .byte $FF
BA01: FF        .byte $FF
BA02: FF        .byte $FF
BA03: FF        .byte $FF
BA04: FF        .byte $FF
BA05: FF        .byte $FF
BA06: FF        .byte $FF
BA07: FF        .byte $FF
BA08: FF        .byte $FF
BA09: FF        .byte $FF
BA0A: FF        .byte $FF
BA0B: FF        .byte $FF
BA0C: FF        .byte $FF
BA0D: FF        .byte $FF
BA0E: FF        .byte $FF
BA0F: FF        .byte $FF
BA10: FF        .byte $FF
BA11: FF        .byte $FF
BA12: FF        .byte $FF
BA13: FF        .byte $FF
BA14: FF        .byte $FF
BA15: FF        .byte $FF
BA16: FF        .byte $FF
BA17: FF        .byte $FF
BA18: FF        .byte $FF
BA19: FF        .byte $FF
BA1A: FF        .byte $FF
BA1B: FF        .byte $FF
BA1C: FF        .byte $FF
BA1D: FF        .byte $FF
BA1E: FF        .byte $FF
BA1F: FF        .byte $FF
BA20: FF        .byte $FF
BA21: FF        .byte $FF
BA22: FF        .byte $FF
BA23: FF        .byte $FF
BA24: FF        .byte $FF
BA25: FF        .byte $FF
BA26: FF        .byte $FF
BA27: FF        .byte $FF
BA28: FF        .byte $FF
BA29: FF        .byte $FF
BA2A: FF        .byte $FF
BA2B: FF        .byte $FF
BA2C: FF        .byte $FF
BA2D: FF        .byte $FF
BA2E: FF        .byte $FF
BA2F: FF        .byte $FF
BA30: FF        .byte $FF
BA31: FF        .byte $FF
BA32: FF        .byte $FF
BA33: FF        .byte $FF
BA34: FF        .byte $FF
BA35: FF        .byte $FF
BA36: FF        .byte $FF
BA37: FF        .byte $FF
BA38: FF        .byte $FF
BA39: FF        .byte $FF
BA3A: FF        .byte $FF
BA3B: FF        .byte $FF
BA3C: FF        .byte $FF
BA3D: FF        .byte $FF
BA3E: FF        .byte $FF
BA3F: FF        .byte $FF
BA40: FF        .byte $FF
BA41: FF        .byte $FF
BA42: FF        .byte $FF
BA43: FF        .byte $FF
BA44: FF        .byte $FF
BA45: FF        .byte $FF
BA46: FF        .byte $FF
BA47: FF        .byte $FF
BA48: FF        .byte $FF
BA49: FF        .byte $FF
BA4A: FF        .byte $FF
BA4B: FF        .byte $FF
BA4C: FF        .byte $FF
BA4D: FF        .byte $FF
BA4E: FF        .byte $FF
BA4F: FF        .byte $FF
BA50: FF        .byte $FF
BA51: FF        .byte $FF
BA52: FF        .byte $FF
BA53: FF        .byte $FF
BA54: FF        .byte $FF
BA55: FF        .byte $FF
BA56: FF        .byte $FF
BA57: FF        .byte $FF
BA58: FF        .byte $FF
BA59: FF        .byte $FF
BA5A: FF        .byte $FF
BA5B: FF        .byte $FF
BA5C: FF        .byte $FF
BA5D: FF        .byte $FF
BA5E: FF        .byte $FF
BA5F: FF        .byte $FF
BA60: FF        .byte $FF
BA61: FF        .byte $FF
BA62: FF        .byte $FF
BA63: FF        .byte $FF
BA64: FF        .byte $FF
BA65: FF        .byte $FF
BA66: FF        .byte $FF
BA67: FF        .byte $FF
BA68: FF        .byte $FF
BA69: FF        .byte $FF
BA6A: FF        .byte $FF
BA6B: FF        .byte $FF
BA6C: FF        .byte $FF
BA6D: FF        .byte $FF
BA6E: FF        .byte $FF
BA6F: FF        .byte $FF
BA70: FF        .byte $FF
BA71: FF        .byte $FF
BA72: FF        .byte $FF
BA73: FF        .byte $FF
BA74: FF        .byte $FF
BA75: FF        .byte $FF
BA76: FF        .byte $FF
BA77: FF        .byte $FF
BA78: FF        .byte $FF
BA79: FF        .byte $FF
BA7A: FF        .byte $FF
BA7B: FF        .byte $FF
BA7C: FF        .byte $FF
BA7D: FF        .byte $FF
BA7E: FF        .byte $FF
BA7F: FF        .byte $FF
BA80: FF        .byte $FF
BA81: FF        .byte $FF
BA82: FF        .byte $FF
BA83: FF        .byte $FF
BA84: FF        .byte $FF
BA85: FF        .byte $FF
BA86: FF        .byte $FF
BA87: FF        .byte $FF
BA88: FF        .byte $FF
BA89: FF        .byte $FF
BA8A: FF        .byte $FF
BA8B: FF        .byte $FF
BA8C: FF        .byte $FF
BA8D: FF        .byte $FF
BA8E: FF        .byte $FF
BA8F: FF        .byte $FF
BA90: FF        .byte $FF
BA91: FF        .byte $FF
BA92: FF        .byte $FF
BA93: FF        .byte $FF
BA94: FF        .byte $FF
BA95: FF        .byte $FF
BA96: FF        .byte $FF
BA97: FF        .byte $FF
BA98: FF        .byte $FF
BA99: FF        .byte $FF
BA9A: FF        .byte $FF
BA9B: FF        .byte $FF
BA9C: FF        .byte $FF
BA9D: FF        .byte $FF
BA9E: FF        .byte $FF
BA9F: FF        .byte $FF
BAA0: FF        .byte $FF
BAA1: FF        .byte $FF
BAA2: FF        .byte $FF
BAA3: FF        .byte $FF
BAA4: FF        .byte $FF
BAA5: FF        .byte $FF
BAA6: FF        .byte $FF
BAA7: FF        .byte $FF
BAA8: FF        .byte $FF
BAA9: FF        .byte $FF
BAAA: FF        .byte $FF
BAAB: FF        .byte $FF
BAAC: FF        .byte $FF
BAAD: FF        .byte $FF
BAAE: FF        .byte $FF
BAAF: FF        .byte $FF
BAB0: FF        .byte $FF
BAB1: FF        .byte $FF
BAB2: FF        .byte $FF
BAB3: FF        .byte $FF
BAB4: FF        .byte $FF
BAB5: FF        .byte $FF
BAB6: FF        .byte $FF
BAB7: FF        .byte $FF
BAB8: FF        .byte $FF
BAB9: FF        .byte $FF
BABA: FF        .byte $FF
BABB: FF        .byte $FF
BABC: FF        .byte $FF
BABD: FF        .byte $FF
BABE: FF        .byte $FF
BABF: FF        .byte $FF
BAC0: FF        .byte $FF
BAC1: FF        .byte $FF
BAC2: FF        .byte $FF
BAC3: FF        .byte $FF
BAC4: FF        .byte $FF
BAC5: FF        .byte $FF
BAC6: FF        .byte $FF
BAC7: FF        .byte $FF
BAC8: FF        .byte $FF
BAC9: FF        .byte $FF
BACA: FF        .byte $FF
BACB: FF        .byte $FF
BACC: FF        .byte $FF
BACD: FF        .byte $FF
BACE: FF        .byte $FF
BACF: FF        .byte $FF
BAD0: FF        .byte $FF
BAD1: FF        .byte $FF
BAD2: FF        .byte $FF
BAD3: FF        .byte $FF
BAD4: FF        .byte $FF
BAD5: FF        .byte $FF
BAD6: FF        .byte $FF
BAD7: FF        .byte $FF
BAD8: FF        .byte $FF
BAD9: FF        .byte $FF
BADA: FF        .byte $FF
BADB: FF        .byte $FF
BADC: FF        .byte $FF
BADD: FF        .byte $FF
BADE: FF        .byte $FF
BADF: FF        .byte $FF
BAE0: FF        .byte $FF
BAE1: FF        .byte $FF
BAE2: FF        .byte $FF
BAE3: FF        .byte $FF
BAE4: FF        .byte $FF
BAE5: FF        .byte $FF
BAE6: FF        .byte $FF
BAE7: FF        .byte $FF
BAE8: FF        .byte $FF
BAE9: FF        .byte $FF
BAEA: FF        .byte $FF
BAEB: FF        .byte $FF
BAEC: FF        .byte $FF
BAED: FF        .byte $FF
BAEE: FF        .byte $FF
BAEF: FF        .byte $FF
BAF0: FF        .byte $FF
BAF1: FF        .byte $FF
BAF2: FF        .byte $FF
BAF3: FF        .byte $FF
BAF4: FF        .byte $FF
BAF5: FF        .byte $FF
BAF6: FF        .byte $FF
BAF7: FF        .byte $FF
BAF8: FF        .byte $FF
BAF9: FF        .byte $FF
BAFA: FF        .byte $FF
BAFB: FF        .byte $FF
BAFC: FF        .byte $FF
BAFD: FF        .byte $FF
BAFE: FF        .byte $FF
BAFF: FF        .byte $FF
BB00: FF        .byte $FF
BB01: FF        .byte $FF
BB02: FF        .byte $FF
BB03: FF        .byte $FF
BB04: FF        .byte $FF
BB05: FF        .byte $FF
BB06: FF        .byte $FF
BB07: FF        .byte $FF
BB08: FF        .byte $FF
BB09: FF        .byte $FF
BB0A: FF        .byte $FF
BB0B: FF        .byte $FF
BB0C: FF        .byte $FF
BB0D: FF        .byte $FF
BB0E: FF        .byte $FF
BB0F: FF        .byte $FF
BB10: FF        .byte $FF
BB11: FF        .byte $FF
BB12: FF        .byte $FF
BB13: FF        .byte $FF
BB14: FF        .byte $FF
BB15: FF        .byte $FF
BB16: FF        .byte $FF
BB17: FF        .byte $FF
BB18: FF        .byte $FF
BB19: FF        .byte $FF
BB1A: FF        .byte $FF
BB1B: FF        .byte $FF
BB1C: FF        .byte $FF
BB1D: FF        .byte $FF
BB1E: FF        .byte $FF
BB1F: FF        .byte $FF
BB20: FF        .byte $FF
BB21: FF        .byte $FF
BB22: FF        .byte $FF
BB23: FF        .byte $FF
BB24: FF        .byte $FF
BB25: FF        .byte $FF
BB26: FF        .byte $FF
BB27: FF        .byte $FF
BB28: FF        .byte $FF
BB29: FF        .byte $FF
BB2A: FF        .byte $FF
BB2B: FF        .byte $FF
BB2C: FF        .byte $FF
BB2D: FF        .byte $FF
BB2E: FF        .byte $FF
BB2F: FF        .byte $FF
BB30: FF        .byte $FF
BB31: FF        .byte $FF
BB32: FF        .byte $FF
BB33: FF        .byte $FF
BB34: FF        .byte $FF
BB35: FF        .byte $FF
BB36: FF        .byte $FF
BB37: FF        .byte $FF
BB38: FF        .byte $FF
BB39: FF        .byte $FF
BB3A: FF        .byte $FF
BB3B: FF        .byte $FF
BB3C: FF        .byte $FF
BB3D: FF        .byte $FF
BB3E: FF        .byte $FF
BB3F: FF        .byte $FF
BB40: FF        .byte $FF
BB41: FF        .byte $FF
BB42: FF        .byte $FF
BB43: FF        .byte $FF
BB44: FF        .byte $FF
BB45: FF        .byte $FF
BB46: FF        .byte $FF
BB47: FF        .byte $FF
BB48: FF        .byte $FF
BB49: FF        .byte $FF
BB4A: FF        .byte $FF
BB4B: FF        .byte $FF
BB4C: FF        .byte $FF
BB4D: FF        .byte $FF
BB4E: FF        .byte $FF
BB4F: FF        .byte $FF
BB50: FF        .byte $FF
BB51: FF        .byte $FF
BB52: FF        .byte $FF
BB53: FF        .byte $FF
BB54: FF        .byte $FF
BB55: FF        .byte $FF
BB56: FF        .byte $FF
BB57: FF        .byte $FF
BB58: FF        .byte $FF
BB59: FF        .byte $FF
BB5A: FF        .byte $FF
BB5B: FF        .byte $FF
BB5C: FF        .byte $FF
BB5D: FF        .byte $FF
BB5E: FF        .byte $FF
BB5F: FF        .byte $FF
BB60: FF        .byte $FF
BB61: FF        .byte $FF
BB62: FF        .byte $FF
BB63: FF        .byte $FF
BB64: FF        .byte $FF
BB65: FF        .byte $FF
BB66: FF        .byte $FF
BB67: FF        .byte $FF
BB68: FF        .byte $FF
BB69: FF        .byte $FF
BB6A: FF        .byte $FF
BB6B: FF        .byte $FF
BB6C: FF        .byte $FF
BB6D: FF        .byte $FF
BB6E: FF        .byte $FF
BB6F: FF        .byte $FF
BB70: FF        .byte $FF
BB71: FF        .byte $FF
BB72: FF        .byte $FF
BB73: FF        .byte $FF
BB74: FF        .byte $FF
BB75: FF        .byte $FF
BB76: FF        .byte $FF
BB77: FF        .byte $FF
BB78: FF        .byte $FF
BB79: FF        .byte $FF
BB7A: FF        .byte $FF
BB7B: FF        .byte $FF
BB7C: FF        .byte $FF
BB7D: FF        .byte $FF
BB7E: FF        .byte $FF
BB7F: FF        .byte $FF
BB80: FF        .byte $FF
BB81: FF        .byte $FF
BB82: FF        .byte $FF
BB83: FF        .byte $FF
BB84: FF        .byte $FF
BB85: FF        .byte $FF
BB86: FF        .byte $FF
BB87: FF        .byte $FF
BB88: FF        .byte $FF
BB89: FF        .byte $FF
BB8A: FF        .byte $FF
BB8B: FF        .byte $FF
BB8C: FF        .byte $FF
BB8D: FF        .byte $FF
BB8E: FF        .byte $FF
BB8F: FF        .byte $FF
BB90: FF        .byte $FF
BB91: FF        .byte $FF
BB92: FF        .byte $FF
BB93: FF        .byte $FF
BB94: FF        .byte $FF
BB95: FF        .byte $FF
BB96: FF        .byte $FF
BB97: FF        .byte $FF
BB98: FF        .byte $FF
BB99: FF        .byte $FF
BB9A: FF        .byte $FF
BB9B: FF        .byte $FF
BB9C: FF        .byte $FF
BB9D: FF        .byte $FF
BB9E: FF        .byte $FF
BB9F: FF        .byte $FF
BBA0: FF        .byte $FF
BBA1: FF        .byte $FF
BBA2: FF        .byte $FF
BBA3: FF        .byte $FF
BBA4: FF        .byte $FF
BBA5: FF        .byte $FF
BBA6: FF        .byte $FF
BBA7: FF        .byte $FF
BBA8: FF        .byte $FF
BBA9: FF        .byte $FF
BBAA: FF        .byte $FF
BBAB: FF        .byte $FF
BBAC: FF        .byte $FF
BBAD: FF        .byte $FF
BBAE: FF        .byte $FF
BBAF: FF        .byte $FF
BBB0: FF        .byte $FF
BBB1: FF        .byte $FF
BBB2: FF        .byte $FF
BBB3: FF        .byte $FF
BBB4: FF        .byte $FF
BBB5: FF        .byte $FF
BBB6: FF        .byte $FF
BBB7: FF        .byte $FF
BBB8: FF        .byte $FF
BBB9: FF        .byte $FF
BBBA: FF        .byte $FF
BBBB: FF        .byte $FF
BBBC: FF        .byte $FF
BBBD: FF        .byte $FF
BBBE: FF        .byte $FF
BBBF: FF        .byte $FF
BBC0: FF        .byte $FF
BBC1: FF        .byte $FF
BBC2: FF        .byte $FF
BBC3: FF        .byte $FF
BBC4: FF        .byte $FF
BBC5: FF        .byte $FF
BBC6: FF        .byte $FF
BBC7: FF        .byte $FF
BBC8: FF        .byte $FF
BBC9: FF        .byte $FF
BBCA: FF        .byte $FF
BBCB: FF        .byte $FF
BBCC: FF        .byte $FF
BBCD: FF        .byte $FF
BBCE: FF        .byte $FF
BBCF: FF        .byte $FF
BBD0: FF        .byte $FF
BBD1: FF        .byte $FF
BBD2: FF        .byte $FF
BBD3: FF        .byte $FF
BBD4: FF        .byte $FF
BBD5: FF        .byte $FF
BBD6: FF        .byte $FF
BBD7: FF        .byte $FF
BBD8: FF        .byte $FF
BBD9: FF        .byte $FF
BBDA: FF        .byte $FF
BBDB: FF        .byte $FF
BBDC: FF        .byte $FF
BBDD: FF        .byte $FF
BBDE: FF        .byte $FF
BBDF: FF        .byte $FF
BBE0: FF        .byte $FF
BBE1: FF        .byte $FF
BBE2: FF        .byte $FF
BBE3: FF        .byte $FF
BBE4: FF        .byte $FF
BBE5: FF        .byte $FF
BBE6: FF        .byte $FF
BBE7: FF        .byte $FF
BBE8: FF        .byte $FF
BBE9: FF        .byte $FF
BBEA: FF        .byte $FF
BBEB: FF        .byte $FF
BBEC: FF        .byte $FF
BBED: FF        .byte $FF
BBEE: FF        .byte $FF
BBEF: FF        .byte $FF
BBF0: FF        .byte $FF
BBF1: FF        .byte $FF
BBF2: FF        .byte $FF
BBF3: FF        .byte $FF
BBF4: FF        .byte $FF
BBF5: FF        .byte $FF
BBF6: FF        .byte $FF
BBF7: FF        .byte $FF
BBF8: FF        .byte $FF
BBF9: FF        .byte $FF
BBFA: FF        .byte $FF
BBFB: FF        .byte $FF
BBFC: FF        .byte $FF
BBFD: FF        .byte $FF
BBFE: FF        .byte $FF
BBFF: FF        .byte $FF
BC00: FF        .byte $FF
BC01: FF        .byte $FF
BC02: FF        .byte $FF
BC03: FF        .byte $FF
BC04: FF        .byte $FF
BC05: FF        .byte $FF
BC06: FF        .byte $FF
BC07: FF        .byte $FF
BC08: FF        .byte $FF
BC09: FF        .byte $FF
BC0A: FF        .byte $FF
BC0B: FF        .byte $FF
BC0C: FF        .byte $FF
BC0D: FF        .byte $FF
BC0E: FF        .byte $FF
BC0F: FF        .byte $FF
BC10: FF        .byte $FF
BC11: FF        .byte $FF
BC12: FF        .byte $FF
BC13: FF        .byte $FF
BC14: FF        .byte $FF
BC15: FF        .byte $FF
BC16: FF        .byte $FF
BC17: FF        .byte $FF
BC18: FF        .byte $FF
BC19: FF        .byte $FF
BC1A: FF        .byte $FF
BC1B: FF        .byte $FF
BC1C: FF        .byte $FF
BC1D: FF        .byte $FF
BC1E: FF        .byte $FF
BC1F: FF        .byte $FF
BC20: FF        .byte $FF
BC21: FF        .byte $FF
BC22: FF        .byte $FF
BC23: FF        .byte $FF
BC24: FF        .byte $FF
BC25: FF        .byte $FF
BC26: FF        .byte $FF
BC27: FF        .byte $FF
BC28: FF        .byte $FF
BC29: FF        .byte $FF
BC2A: FF        .byte $FF
BC2B: FF        .byte $FF
BC2C: FF        .byte $FF
BC2D: FF        .byte $FF
BC2E: FF        .byte $FF
BC2F: FF        .byte $FF
BC30: FF        .byte $FF
BC31: FF        .byte $FF
BC32: FF        .byte $FF
BC33: FF        .byte $FF
BC34: FF        .byte $FF
BC35: FF        .byte $FF
BC36: FF        .byte $FF
BC37: FF        .byte $FF
BC38: FF        .byte $FF
BC39: FF        .byte $FF
BC3A: FF        .byte $FF
BC3B: FF        .byte $FF
BC3C: FF        .byte $FF
BC3D: FF        .byte $FF
BC3E: FF        .byte $FF
BC3F: FF        .byte $FF
BC40: FF        .byte $FF
BC41: FF        .byte $FF
BC42: FF        .byte $FF
BC43: FF        .byte $FF
BC44: FF        .byte $FF
BC45: FF        .byte $FF
BC46: FF        .byte $FF
BC47: FF        .byte $FF
BC48: FF        .byte $FF
BC49: FF        .byte $FF
BC4A: FF        .byte $FF
BC4B: FF        .byte $FF
BC4C: FF        .byte $FF
BC4D: FF        .byte $FF
BC4E: FF        .byte $FF
BC4F: FF        .byte $FF
BC50: FF        .byte $FF
BC51: FF        .byte $FF
BC52: FF        .byte $FF
BC53: FF        .byte $FF
BC54: FF        .byte $FF
BC55: FF        .byte $FF
BC56: FF        .byte $FF
BC57: FF        .byte $FF
BC58: FF        .byte $FF
BC59: FF        .byte $FF
BC5A: FF        .byte $FF
BC5B: FF        .byte $FF
BC5C: FF        .byte $FF
BC5D: FF        .byte $FF
BC5E: FF        .byte $FF
BC5F: FF        .byte $FF
BC60: FF        .byte $FF
BC61: FF        .byte $FF
BC62: FF        .byte $FF
BC63: FF        .byte $FF
BC64: FF        .byte $FF
BC65: FF        .byte $FF
BC66: FF        .byte $FF
BC67: FF        .byte $FF
BC68: FF        .byte $FF
BC69: FF        .byte $FF
BC6A: FF        .byte $FF
BC6B: FF        .byte $FF
BC6C: FF        .byte $FF
BC6D: FF        .byte $FF
BC6E: FF        .byte $FF
BC6F: FF        .byte $FF
BC70: FF        .byte $FF
BC71: FF        .byte $FF
BC72: FF        .byte $FF
BC73: FF        .byte $FF
BC74: FF        .byte $FF
BC75: FF        .byte $FF
BC76: FF        .byte $FF
BC77: FF        .byte $FF
BC78: FF        .byte $FF
BC79: FF        .byte $FF
BC7A: FF        .byte $FF
BC7B: FF        .byte $FF
BC7C: FF        .byte $FF
BC7D: FF        .byte $FF
BC7E: FF        .byte $FF
BC7F: FF        .byte $FF
BC80: FF        .byte $FF
BC81: FF        .byte $FF
BC82: FF        .byte $FF
BC83: FF        .byte $FF
BC84: FF        .byte $FF
BC85: FF        .byte $FF
BC86: FF        .byte $FF
BC87: FF        .byte $FF
BC88: FF        .byte $FF
BC89: FF        .byte $FF
BC8A: FF        .byte $FF
BC8B: FF        .byte $FF
BC8C: FF        .byte $FF
BC8D: FF        .byte $FF
BC8E: FF        .byte $FF
BC8F: FF        .byte $FF
BC90: FF        .byte $FF
BC91: FF        .byte $FF
BC92: FF        .byte $FF
BC93: FF        .byte $FF
BC94: FF        .byte $FF
BC95: FF        .byte $FF
BC96: FF        .byte $FF
BC97: FF        .byte $FF
BC98: FF        .byte $FF
BC99: FF        .byte $FF
BC9A: FF        .byte $FF
BC9B: FF        .byte $FF
BC9C: FF        .byte $FF
BC9D: FF        .byte $FF
BC9E: FF        .byte $FF
BC9F: FF        .byte $FF
BCA0: FF        .byte $FF
BCA1: FF        .byte $FF
BCA2: FF        .byte $FF
BCA3: FF        .byte $FF
BCA4: FF        .byte $FF
BCA5: FF        .byte $FF
BCA6: FF        .byte $FF
BCA7: FF        .byte $FF
BCA8: FF        .byte $FF
BCA9: FF        .byte $FF
BCAA: FF        .byte $FF
BCAB: FF        .byte $FF
BCAC: FF        .byte $FF
BCAD: FF        .byte $FF
BCAE: FF        .byte $FF
BCAF: FF        .byte $FF
BCB0: FF        .byte $FF
BCB1: FF        .byte $FF
BCB2: FF        .byte $FF
BCB3: FF        .byte $FF
BCB4: FF        .byte $FF
BCB5: FF        .byte $FF
BCB6: FF        .byte $FF
BCB7: FF        .byte $FF
BCB8: FF        .byte $FF
BCB9: FF        .byte $FF
BCBA: FF        .byte $FF
BCBB: FF        .byte $FF
BCBC: FF        .byte $FF
BCBD: FF        .byte $FF
BCBE: FF        .byte $FF
BCBF: FF        .byte $FF
BCC0: FF        .byte $FF
BCC1: FF        .byte $FF
BCC2: FF        .byte $FF
BCC3: FF        .byte $FF
BCC4: FF        .byte $FF
BCC5: FF        .byte $FF
BCC6: FF        .byte $FF
BCC7: FF        .byte $FF
BCC8: FF        .byte $FF
BCC9: FF        .byte $FF
BCCA: FF        .byte $FF
BCCB: FF        .byte $FF
BCCC: FF        .byte $FF
BCCD: FF        .byte $FF
BCCE: FF        .byte $FF
BCCF: FF        .byte $FF
BCD0: FF        .byte $FF
BCD1: FF        .byte $FF
BCD2: FF        .byte $FF
BCD3: FF        .byte $FF
BCD4: FF        .byte $FF
BCD5: FF        .byte $FF
BCD6: FF        .byte $FF
BCD7: FF        .byte $FF
BCD8: FF        .byte $FF
BCD9: FF        .byte $FF
BCDA: FF        .byte $FF
BCDB: FF        .byte $FF
BCDC: FF        .byte $FF
BCDD: FF        .byte $FF
BCDE: FF        .byte $FF
BCDF: FF        .byte $FF
BCE0: FF        .byte $FF
BCE1: FF        .byte $FF
BCE2: FF        .byte $FF
BCE3: FF        .byte $FF
BCE4: FF        .byte $FF
BCE5: FF        .byte $FF
BCE6: FF        .byte $FF
BCE7: FF        .byte $FF
BCE8: FF        .byte $FF
BCE9: FF        .byte $FF
BCEA: FF        .byte $FF
BCEB: FF        .byte $FF
BCEC: FF        .byte $FF
BCED: FF        .byte $FF
BCEE: FF        .byte $FF
BCEF: FF        .byte $FF
BCF0: FF        .byte $FF
BCF1: FF        .byte $FF
BCF2: FF        .byte $FF
BCF3: FF        .byte $FF
BCF4: FF        .byte $FF
BCF5: FF        .byte $FF
BCF6: FF        .byte $FF
BCF7: FF        .byte $FF
BCF8: FF        .byte $FF
BCF9: FF        .byte $FF
BCFA: FF        .byte $FF
BCFB: FF        .byte $FF
BCFC: FF        .byte $FF
BCFD: FF        .byte $FF
BCFE: FF        .byte $FF
BCFF: FF        .byte $FF
BD00: FF        .byte $FF
BD01: FF        .byte $FF
BD02: FF        .byte $FF
BD03: FF        .byte $FF
BD04: FF        .byte $FF
BD05: FF        .byte $FF
BD06: FF        .byte $FF
BD07: FF        .byte $FF
BD08: FF        .byte $FF
BD09: FF        .byte $FF
BD0A: FF        .byte $FF
BD0B: FF        .byte $FF
BD0C: FF        .byte $FF
BD0D: FF        .byte $FF
BD0E: FF        .byte $FF
BD0F: FF        .byte $FF
BD10: FF        .byte $FF
BD11: FF        .byte $FF
BD12: FF        .byte $FF
BD13: FF        .byte $FF
BD14: FF        .byte $FF
BD15: FF        .byte $FF
BD16: FF        .byte $FF
BD17: FF        .byte $FF
BD18: FF        .byte $FF
BD19: FF        .byte $FF
BD1A: FF        .byte $FF
BD1B: FF        .byte $FF
BD1C: FF        .byte $FF
BD1D: FF        .byte $FF
BD1E: FF        .byte $FF
BD1F: FF        .byte $FF
BD20: FF        .byte $FF
BD21: FF        .byte $FF
BD22: FF        .byte $FF
BD23: FF        .byte $FF
BD24: FF        .byte $FF
BD25: FF        .byte $FF
BD26: FF        .byte $FF
BD27: FF        .byte $FF
BD28: FF        .byte $FF
BD29: FF        .byte $FF
BD2A: FF        .byte $FF
BD2B: FF        .byte $FF
BD2C: FF        .byte $FF
BD2D: FF        .byte $FF
BD2E: FF        .byte $FF
BD2F: FF        .byte $FF
BD30: FF        .byte $FF
BD31: FF        .byte $FF
BD32: FF        .byte $FF
BD33: FF        .byte $FF
BD34: FF        .byte $FF
BD35: FF        .byte $FF
BD36: FF        .byte $FF
BD37: FF        .byte $FF
BD38: FF        .byte $FF
BD39: FF        .byte $FF
BD3A: FF        .byte $FF
BD3B: FF        .byte $FF
BD3C: FF        .byte $FF
BD3D: FF        .byte $FF
BD3E: FF        .byte $FF
BD3F: FF        .byte $FF
BD40: FF        .byte $FF
BD41: FF        .byte $FF
BD42: FF        .byte $FF
BD43: FF        .byte $FF
BD44: FF        .byte $FF
BD45: FF        .byte $FF
BD46: FF        .byte $FF
BD47: FF        .byte $FF
BD48: FF        .byte $FF
BD49: FF        .byte $FF
BD4A: FF        .byte $FF
BD4B: FF        .byte $FF
BD4C: FF        .byte $FF
BD4D: FF        .byte $FF
BD4E: FF        .byte $FF
BD4F: FF        .byte $FF
BD50: FF        .byte $FF
BD51: FF        .byte $FF
BD52: FF        .byte $FF
BD53: FF        .byte $FF
BD54: FF        .byte $FF
BD55: FF        .byte $FF
BD56: FF        .byte $FF
BD57: FF        .byte $FF
BD58: FF        .byte $FF
BD59: FF        .byte $FF
BD5A: FF        .byte $FF
BD5B: FF        .byte $FF
BD5C: FF        .byte $FF
BD5D: FF        .byte $FF
BD5E: FF        .byte $FF
BD5F: FF        .byte $FF
BD60: FF        .byte $FF
BD61: FF        .byte $FF
BD62: FF        .byte $FF
BD63: FF        .byte $FF
BD64: FF        .byte $FF
BD65: FF        .byte $FF
BD66: FF        .byte $FF
BD67: FF        .byte $FF
BD68: FF        .byte $FF
BD69: FF        .byte $FF
BD6A: FF        .byte $FF
BD6B: FF        .byte $FF
BD6C: FF        .byte $FF
BD6D: FF        .byte $FF
BD6E: FF        .byte $FF
BD6F: FF        .byte $FF
BD70: FF        .byte $FF
BD71: FF        .byte $FF
BD72: FF        .byte $FF
BD73: FF        .byte $FF
BD74: FF        .byte $FF
BD75: FF        .byte $FF
BD76: FF        .byte $FF
BD77: FF        .byte $FF
BD78: FF        .byte $FF
BD79: FF        .byte $FF
BD7A: FF        .byte $FF
BD7B: FF        .byte $FF
BD7C: FF        .byte $FF
BD7D: FF        .byte $FF
BD7E: FF        .byte $FF
BD7F: FF        .byte $FF
BD80: FF        .byte $FF
BD81: FF        .byte $FF
BD82: FF        .byte $FF
BD83: FF        .byte $FF
BD84: FF        .byte $FF
BD85: FF        .byte $FF
BD86: FF        .byte $FF
BD87: FF        .byte $FF
BD88: FF        .byte $FF
BD89: FF        .byte $FF
BD8A: FF        .byte $FF
BD8B: FF        .byte $FF
BD8C: FF        .byte $FF
BD8D: FF        .byte $FF
BD8E: FF        .byte $FF
BD8F: FF        .byte $FF
BD90: FF        .byte $FF
BD91: FF        .byte $FF
BD92: FF        .byte $FF
BD93: FF        .byte $FF
BD94: FF        .byte $FF
BD95: FF        .byte $FF
BD96: FF        .byte $FF
BD97: FF        .byte $FF
BD98: FF        .byte $FF
BD99: FF        .byte $FF
BD9A: FF        .byte $FF
BD9B: FF        .byte $FF
BD9C: FF        .byte $FF
BD9D: FF        .byte $FF
BD9E: FF        .byte $FF
BD9F: FF        .byte $FF
BDA0: FF        .byte $FF
BDA1: FF        .byte $FF
BDA2: FF        .byte $FF
BDA3: FF        .byte $FF
BDA4: FF        .byte $FF
BDA5: FF        .byte $FF
BDA6: FF        .byte $FF
BDA7: FF        .byte $FF
BDA8: FF        .byte $FF
BDA9: FF        .byte $FF
BDAA: FF        .byte $FF
BDAB: FF        .byte $FF
BDAC: FF        .byte $FF
BDAD: FF        .byte $FF
BDAE: FF        .byte $FF
BDAF: FF        .byte $FF
BDB0: FF        .byte $FF
BDB1: FF        .byte $FF
BDB2: FF        .byte $FF
BDB3: FF        .byte $FF
BDB4: FF        .byte $FF
BDB5: FF        .byte $FF
BDB6: FF        .byte $FF
BDB7: FF        .byte $FF
BDB8: FF        .byte $FF
BDB9: FF        .byte $FF
BDBA: FF        .byte $FF
BDBB: FF        .byte $FF
BDBC: FF        .byte $FF
BDBD: FF        .byte $FF
BDBE: FF        .byte $FF
BDBF: FF        .byte $FF
BDC0: FF        .byte $FF
BDC1: FF        .byte $FF
BDC2: FF        .byte $FF
BDC3: FF        .byte $FF
BDC4: FF        .byte $FF
BDC5: FF        .byte $FF
BDC6: FF        .byte $FF
BDC7: FF        .byte $FF
BDC8: FF        .byte $FF
BDC9: FF        .byte $FF
BDCA: FF        .byte $FF
BDCB: FF        .byte $FF
BDCC: FF        .byte $FF
BDCD: FF        .byte $FF
BDCE: FF        .byte $FF
BDCF: FF        .byte $FF
BDD0: FF        .byte $FF
BDD1: FF        .byte $FF
BDD2: FF        .byte $FF
BDD3: FF        .byte $FF
BDD4: FF        .byte $FF
BDD5: FF        .byte $FF
BDD6: FF        .byte $FF
BDD7: FF        .byte $FF
BDD8: FF        .byte $FF
BDD9: FF        .byte $FF
BDDA: FF        .byte $FF
BDDB: FF        .byte $FF
BDDC: FF        .byte $FF
BDDD: FF        .byte $FF
BDDE: FF        .byte $FF
BDDF: FF        .byte $FF
BDE0: FF        .byte $FF
BDE1: FF        .byte $FF
BDE2: FF        .byte $FF
BDE3: FF        .byte $FF
BDE4: FF        .byte $FF
BDE5: FF        .byte $FF
BDE6: FF        .byte $FF
BDE7: FF        .byte $FF
BDE8: FF        .byte $FF
BDE9: FF        .byte $FF
BDEA: FF        .byte $FF
BDEB: FF        .byte $FF
BDEC: FF        .byte $FF
BDED: FF        .byte $FF
BDEE: FF        .byte $FF
BDEF: FF        .byte $FF
BDF0: FF        .byte $FF
BDF1: FF        .byte $FF
BDF2: FF        .byte $FF
BDF3: FF        .byte $FF
BDF4: FF        .byte $FF
BDF5: FF        .byte $FF
BDF6: FF        .byte $FF
BDF7: FF        .byte $FF
BDF8: FF        .byte $FF
BDF9: FF        .byte $FF
BDFA: FF        .byte $FF
BDFB: FF        .byte $FF
BDFC: FF        .byte $FF
BDFD: FF        .byte $FF
BDFE: FF        .byte $FF
BDFF: FF        .byte $FF
BE00: FF        .byte $FF
BE01: FF        .byte $FF
BE02: FF        .byte $FF
BE03: FF        .byte $FF
BE04: FF        .byte $FF
BE05: FF        .byte $FF
BE06: FF        .byte $FF
BE07: FF        .byte $FF
BE08: FF        .byte $FF
BE09: FF        .byte $FF
BE0A: FF        .byte $FF
BE0B: FF        .byte $FF
BE0C: FF        .byte $FF
BE0D: FF        .byte $FF
BE0E: FF        .byte $FF
BE0F: FF        .byte $FF
BE10: FF        .byte $FF
BE11: FF        .byte $FF
BE12: FF        .byte $FF
BE13: FF        .byte $FF
BE14: FF        .byte $FF
BE15: FF        .byte $FF
BE16: FF        .byte $FF
BE17: FF        .byte $FF
BE18: FF        .byte $FF
BE19: FF        .byte $FF
BE1A: FF        .byte $FF
BE1B: FF        .byte $FF
BE1C: FF        .byte $FF
BE1D: FF        .byte $FF
BE1E: FF        .byte $FF
BE1F: FF        .byte $FF
BE20: FF        .byte $FF
BE21: FF        .byte $FF
BE22: FF        .byte $FF
BE23: FF        .byte $FF
BE24: FF        .byte $FF
BE25: FF        .byte $FF
BE26: FF        .byte $FF
BE27: FF        .byte $FF
BE28: FF        .byte $FF
BE29: FF        .byte $FF
BE2A: FF        .byte $FF
BE2B: FF        .byte $FF
BE2C: FF        .byte $FF
BE2D: FF        .byte $FF
BE2E: FF        .byte $FF
BE2F: FF        .byte $FF
BE30: FF        .byte $FF
BE31: FF        .byte $FF
BE32: FF        .byte $FF
BE33: FF        .byte $FF
BE34: FF        .byte $FF
BE35: FF        .byte $FF
BE36: FF        .byte $FF
BE37: FF        .byte $FF
BE38: FF        .byte $FF
BE39: FF        .byte $FF
BE3A: FF        .byte $FF
BE3B: FF        .byte $FF
BE3C: FF        .byte $FF
BE3D: FF        .byte $FF
BE3E: FF        .byte $FF
BE3F: FF        .byte $FF
BE40: FF        .byte $FF
BE41: FF        .byte $FF
BE42: FF        .byte $FF
BE43: FF        .byte $FF
BE44: FF        .byte $FF
BE45: FF        .byte $FF
BE46: FF        .byte $FF
BE47: FF        .byte $FF
BE48: FF        .byte $FF
BE49: FF        .byte $FF
BE4A: FF        .byte $FF
BE4B: FF        .byte $FF
BE4C: FF        .byte $FF
BE4D: FF        .byte $FF
BE4E: FF        .byte $FF
BE4F: FF        .byte $FF
BE50: FF        .byte $FF
BE51: FF        .byte $FF
BE52: FF        .byte $FF
BE53: FF        .byte $FF
BE54: FF        .byte $FF
BE55: FF        .byte $FF
BE56: FF        .byte $FF
BE57: FF        .byte $FF
BE58: FF        .byte $FF
BE59: FF        .byte $FF
BE5A: FF        .byte $FF
BE5B: FF        .byte $FF
BE5C: FF        .byte $FF
BE5D: FF        .byte $FF
BE5E: FF        .byte $FF
BE5F: FF        .byte $FF
BE60: FF        .byte $FF
BE61: FF        .byte $FF
BE62: FF        .byte $FF
BE63: FF        .byte $FF
BE64: FF        .byte $FF
BE65: FF        .byte $FF
BE66: FF        .byte $FF
BE67: FF        .byte $FF
BE68: FF        .byte $FF
BE69: FF        .byte $FF
BE6A: FF        .byte $FF
BE6B: FF        .byte $FF
BE6C: FF        .byte $FF
BE6D: FF        .byte $FF
BE6E: FF        .byte $FF
BE6F: FF        .byte $FF
BE70: FF        .byte $FF
BE71: FF        .byte $FF
BE72: FF        .byte $FF
BE73: FF        .byte $FF
BE74: FF        .byte $FF
BE75: FF        .byte $FF
BE76: FF        .byte $FF
BE77: FF        .byte $FF
BE78: FF        .byte $FF
BE79: FF        .byte $FF
BE7A: FF        .byte $FF
BE7B: FF        .byte $FF
BE7C: FF        .byte $FF
BE7D: FF        .byte $FF
BE7E: FF        .byte $FF
BE7F: FF        .byte $FF
BE80: FF        .byte $FF
BE81: FF        .byte $FF
BE82: FF        .byte $FF
BE83: FF        .byte $FF
BE84: FF        .byte $FF
BE85: FF        .byte $FF
BE86: FF        .byte $FF
BE87: FF        .byte $FF
BE88: FF        .byte $FF
BE89: FF        .byte $FF
BE8A: FF        .byte $FF
BE8B: FF        .byte $FF
BE8C: FF        .byte $FF
BE8D: FF        .byte $FF
BE8E: FF        .byte $FF
BE8F: FF        .byte $FF
BE90: FF        .byte $FF
BE91: FF        .byte $FF
BE92: FF        .byte $FF
BE93: FF        .byte $FF
BE94: FF        .byte $FF
BE95: FF        .byte $FF
BE96: FF        .byte $FF
BE97: FF        .byte $FF
BE98: FF        .byte $FF
BE99: FF        .byte $FF
BE9A: FF        .byte $FF
BE9B: FF        .byte $FF
BE9C: FF        .byte $FF
BE9D: FF        .byte $FF
BE9E: FF        .byte $FF
BE9F: FF        .byte $FF
BEA0: FF        .byte $FF
BEA1: FF        .byte $FF
BEA2: FF        .byte $FF
BEA3: FF        .byte $FF
BEA4: FF        .byte $FF
BEA5: FF        .byte $FF
BEA6: FF        .byte $FF
BEA7: FF        .byte $FF
BEA8: FF        .byte $FF
BEA9: FF        .byte $FF
BEAA: FF        .byte $FF
BEAB: FF        .byte $FF
BEAC: FF        .byte $FF
BEAD: FF        .byte $FF
BEAE: FF        .byte $FF
BEAF: FF        .byte $FF
BEB0: FF        .byte $FF
BEB1: FF        .byte $FF
BEB2: FF        .byte $FF
BEB3: FF        .byte $FF
BEB4: FF        .byte $FF
BEB5: FF        .byte $FF
BEB6: FF        .byte $FF
BEB7: FF        .byte $FF
BEB8: FF        .byte $FF
BEB9: FF        .byte $FF
BEBA: FF        .byte $FF
BEBB: FF        .byte $FF
BEBC: FF        .byte $FF
BEBD: FF        .byte $FF
BEBE: FF        .byte $FF
BEBF: FF        .byte $FF
BEC0: FF        .byte $FF
BEC1: FF        .byte $FF
BEC2: FF        .byte $FF
BEC3: FF        .byte $FF
BEC4: FF        .byte $FF
BEC5: FF        .byte $FF
BEC6: FF        .byte $FF
BEC7: FF        .byte $FF
BEC8: FF        .byte $FF
BEC9: FF        .byte $FF
BECA: FF        .byte $FF
BECB: FF        .byte $FF
BECC: FF        .byte $FF
BECD: FF        .byte $FF
BECE: FF        .byte $FF
BECF: FF        .byte $FF
BED0: FF        .byte $FF
BED1: FF        .byte $FF
BED2: FF        .byte $FF
BED3: FF        .byte $FF
BED4: FF        .byte $FF
BED5: FF        .byte $FF
BED6: FF        .byte $FF
BED7: FF        .byte $FF
BED8: FF        .byte $FF
BED9: FF        .byte $FF
BEDA: FF        .byte $FF
BEDB: FF        .byte $FF
BEDC: FF        .byte $FF
BEDD: FF        .byte $FF
BEDE: FF        .byte $FF
BEDF: FF        .byte $FF
BEE0: FF        .byte $FF
BEE1: FF        .byte $FF
BEE2: FF        .byte $FF
BEE3: FF        .byte $FF
BEE4: FF        .byte $FF
BEE5: FF        .byte $FF
BEE6: FF        .byte $FF
BEE7: FF        .byte $FF
BEE8: FF        .byte $FF
BEE9: FF        .byte $FF
BEEA: FF        .byte $FF
BEEB: FF        .byte $FF
BEEC: FF        .byte $FF
BEED: FF        .byte $FF
BEEE: FF        .byte $FF
BEEF: FF        .byte $FF
BEF0: FF        .byte $FF
BEF1: FF        .byte $FF
BEF2: FF        .byte $FF
BEF3: FF        .byte $FF
BEF4: FF        .byte $FF
BEF5: FF        .byte $FF
BEF6: FF        .byte $FF
BEF7: FF        .byte $FF
BEF8: FF        .byte $FF
BEF9: FF        .byte $FF
BEFA: FF        .byte $FF
BEFB: FF        .byte $FF
BEFC: FF        .byte $FF
BEFD: FF        .byte $FF
BEFE: FF        .byte $FF
BEFF: FF        .byte $FF
BF00: FF        .byte $FF
BF01: FF        .byte $FF
BF02: FF        .byte $FF
BF03: FF        .byte $FF
BF04: FF        .byte $FF
BF05: FF        .byte $FF
BF06: FF        .byte $FF
BF07: FF        .byte $FF
BF08: FF        .byte $FF
BF09: FF        .byte $FF
BF0A: FF        .byte $FF
BF0B: FF        .byte $FF
BF0C: FF        .byte $FF
BF0D: FF        .byte $FF
BF0E: FF        .byte $FF
BF0F: FF        .byte $FF
BF10: FF        .byte $FF
BF11: FF        .byte $FF
BF12: FF        .byte $FF
BF13: FF        .byte $FF
BF14: FF        .byte $FF
BF15: FF        .byte $FF
BF16: FF        .byte $FF
BF17: FF        .byte $FF
BF18: FF        .byte $FF
BF19: FF        .byte $FF
BF1A: FF        .byte $FF
BF1B: FF        .byte $FF
BF1C: FF        .byte $FF
BF1D: FF        .byte $FF
BF1E: FF        .byte $FF
BF1F: FF        .byte $FF
BF20: FF        .byte $FF
BF21: FF        .byte $FF
BF22: FF        .byte $FF
BF23: FF        .byte $FF
BF24: FF        .byte $FF
BF25: FF        .byte $FF
BF26: FF        .byte $FF
BF27: FF        .byte $FF
BF28: FF        .byte $FF
BF29: FF        .byte $FF
BF2A: FF        .byte $FF
BF2B: FF        .byte $FF
BF2C: FF        .byte $FF
BF2D: FF        .byte $FF
BF2E: FF        .byte $FF
BF2F: FF        .byte $FF
BF30: FF        .byte $FF
BF31: FF        .byte $FF
BF32: FF        .byte $FF
BF33: FF        .byte $FF
BF34: FF        .byte $FF
BF35: FF        .byte $FF
BF36: FF        .byte $FF
BF37: FF        .byte $FF
BF38: FF        .byte $FF
BF39: FF        .byte $FF
BF3A: FF        .byte $FF
BF3B: FF        .byte $FF
BF3C: FF        .byte $FF
BF3D: FF        .byte $FF
BF3E: FF        .byte $FF
BF3F: FF        .byte $FF
BF40: FF        .byte $FF
BF41: FF        .byte $FF
BF42: FF        .byte $FF
BF43: FF        .byte $FF
BF44: FF        .byte $FF
BF45: FF        .byte $FF
BF46: FF        .byte $FF
BF47: FF        .byte $FF
BF48: FF        .byte $FF
BF49: FF        .byte $FF
BF4A: FF        .byte $FF
BF4B: FF        .byte $FF
BF4C: FF        .byte $FF
BF4D: FF        .byte $FF
BF4E: FF        .byte $FF
BF4F: FF        .byte $FF
BF50: FF        .byte $FF
BF51: FF        .byte $FF
BF52: FF        .byte $FF
BF53: FF        .byte $FF
BF54: FF        .byte $FF
BF55: FF        .byte $FF
BF56: FF        .byte $FF
BF57: FF        .byte $FF
BF58: FF        .byte $FF
BF59: FF        .byte $FF
BF5A: FF        .byte $FF
BF5B: FF        .byte $FF
BF5C: FF        .byte $FF
BF5D: FF        .byte $FF
BF5E: FF        .byte $FF
BF5F: FF        .byte $FF
BF60: FF        .byte $FF
BF61: FF        .byte $FF
BF62: FF        .byte $FF
BF63: FF        .byte $FF
BF64: FF        .byte $FF
BF65: FF        .byte $FF
BF66: FF        .byte $FF
BF67: FF        .byte $FF
BF68: FF        .byte $FF
BF69: FF        .byte $FF
BF6A: FF        .byte $FF
BF6B: FF        .byte $FF
BF6C: FF        .byte $FF
BF6D: FF        .byte $FF
BF6E: FF        .byte $FF
BF6F: FF        .byte $FF
BF70: FF        .byte $FF
BF71: FF        .byte $FF
BF72: FF        .byte $FF
BF73: FF        .byte $FF
BF74: FF        .byte $FF
BF75: FF        .byte $FF
BF76: FF        .byte $FF
BF77: FF        .byte $FF
BF78: FF        .byte $FF
BF79: FF        .byte $FF
BF7A: FF        .byte $FF
BF7B: FF        .byte $FF
BF7C: FF        .byte $FF
BF7D: FF        .byte $FF
BF7E: FF        .byte $FF
BF7F: FF        .byte $FF
BF80: FF        .byte $FF
BF81: FF        .byte $FF
BF82: FF        .byte $FF
BF83: FF        .byte $FF
BF84: FF        .byte $FF
BF85: FF        .byte $FF
BF86: FF        .byte $FF
BF87: FF        .byte $FF
BF88: FF        .byte $FF
BF89: FF        .byte $FF
BF8A: FF        .byte $FF
BF8B: FF        .byte $FF
BF8C: FF        .byte $FF
BF8D: FF        .byte $FF
BF8E: FF        .byte $FF
BF8F: FF        .byte $FF
BF90: FF        .byte $FF
BF91: FF        .byte $FF
BF92: FF        .byte $FF
BF93: FF        .byte $FF
BF94: FF        .byte $FF
BF95: FF        .byte $FF
BF96: FF        .byte $FF
BF97: FF        .byte $FF
BF98: FF        .byte $FF
BF99: FF        .byte $FF
BF9A: FF        .byte $FF
BF9B: FF        .byte $FF
BF9C: FF        .byte $FF
BF9D: FF        .byte $FF
BF9E: FF        .byte $FF
BF9F: FF        .byte $FF
BFA0: FF        .byte $FF
BFA1: FF        .byte $FF
BFA2: FF        .byte $FF
BFA3: FF        .byte $FF
BFA4: FF        .byte $FF
BFA5: FF        .byte $FF
BFA6: FF        .byte $FF
BFA7: FF        .byte $FF
BFA8: FF        .byte $FF
BFA9: FF        .byte $FF
BFAA: FF        .byte $FF
BFAB: FF        .byte $FF
BFAC: FF        .byte $FF
BFAD: FF        .byte $FF
BFAE: FF        .byte $FF
BFAF: FF        .byte $FF
BFB0: FF        .byte $FF
BFB1: FF        .byte $FF
BFB2: FF        .byte $FF
BFB3: FF        .byte $FF
BFB4: FF        .byte $FF
BFB5: FF        .byte $FF
BFB6: FF        .byte $FF
BFB7: FF        .byte $FF
BFB8: FF        .byte $FF
BFB9: FF        .byte $FF
BFBA: FF        .byte $FF
BFBB: FF        .byte $FF
BFBC: FF        .byte $FF
BFBD: FF        .byte $FF
BFBE: FF        .byte $FF
BFBF: FF        .byte $FF
BFC0: FF        .byte $FF
BFC1: FF        .byte $FF
BFC2: FF        .byte $FF
BFC3: FF        .byte $FF
BFC4: FF        .byte $FF
BFC5: FF        .byte $FF
BFC6: FF        .byte $FF
BFC7: FF        .byte $FF
BFC8: FF        .byte $FF
BFC9: FF        .byte $FF
BFCA: FF        .byte $FF
BFCB: FF        .byte $FF
BFCC: FF        .byte $FF
BFCD: FF        .byte $FF
BFCE: FF        .byte $FF
BFCF: FF        .byte $FF
BFD0: FF        .byte $FF
BFD1: FF        .byte $FF
BFD2: FF        .byte $FF
BFD3: FF        .byte $FF
BFD4: FF        .byte $FF
BFD5: FF        .byte $FF
BFD6: FF        .byte $FF
BFD7: FF        .byte $FF
BFD8: FF        .byte $FF
BFD9: FF        .byte $FF
BFDA: FF        .byte $FF
BFDB: FF        .byte $FF
BFDC: FF        .byte $FF
BFDD: FF        .byte $FF
BFDE: FF        .byte $FF
BFDF: FF        .byte $FF
BFE0: FF        .byte $FF
BFE1: FF        .byte $FF
BFE2: FF        .byte $FF
BFE3: FF        .byte $FF
BFE4: FF        .byte $FF
BFE5: FF        .byte $FF
BFE6: FF        .byte $FF
BFE7: FF        .byte $FF
BFE8: FF        .byte $FF
BFE9: FF        .byte $FF
BFEA: FF        .byte $FF
BFEB: FF        .byte $FF
BFEC: FF        .byte $FF
BFED: FF        .byte $FF
BFEE: FF        .byte $FF
BFEF: FF        .byte $FF
BFF0: FF        .byte $FF
BFF1: FF        .byte $FF
BFF2: FF        .byte $FF
BFF3: FF        .byte $FF
BFF4: FF        .byte $FF
BFF5: FF        .byte $FF
BFF6: FF        .byte $FF
BFF7: FF        .byte $FF
BFF8: FF        .byte $FF
BFF9: FF        .byte $FF
BFFA: FF        .byte $FF
BFFB: FF        .byte $FF
BFFC: FF        .byte $FF
BFFD: FF        .byte $FF
BFFE: FF        .byte $FF
BFFF: FF        .byte $FF
