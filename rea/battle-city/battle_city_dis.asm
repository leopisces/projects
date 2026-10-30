; Battle City (Namco 1985) — NROM-128 (mapper 0), PRG $C000-$FFFF, CHR 8KB
; md5 cd4fe2e78df0696dbe652f02c19541a1
; RESET=$C070  NMI=$D400  IRQ=$C070
; 5047 instructions, 10268 bytes code

vectors:
.word nmi, reset, irq

; jump table $CA69 (3 entries)
.word sub_CA6F, sub_CA74, sub_CA7E

; jump table $E306 (7 entries)
.word sub_DBF0, sub_E312, sub_E317, sub_E31C, sub_E32E, sub_E336, sub_F1A9

; jump table $E498 (42 entries)
.word sub_DBF0, sub_DDEA, sub_DDEA, sub_DDEA, sub_DDEA, sub_DDEA, sub_DDEA, sub_DDEA, sub_DC52, sub_DD48, sub_DC7C, sub_DD94, sub_DD89, sub_DD7E, sub_DE64, sub_DE55, sub_DBF0, sub_DEFD, sub_DF33, sub_DF46, sub_DF46, sub_DECD, sub_DECD, sub_DECD, sub_DFB6, sub_DFB6, sub_DFB6, sub_DFB6, sub_DFB6, sub_DFB6, sub_E00B, sub_E00B, sub_DBF0, sub_E076, sub_E076, sub_E076, sub_E051, sub_DBF0, sub_E112, sub_E112, sub_E112, sub_E0FB

; jump table $E4B8 (26 entries)
.word sub_DBF0, sub_DEFD, sub_DF33, sub_DF46, sub_DF46, sub_DECD, sub_DECD, sub_DECD, sub_DFB6, sub_DFB6, sub_DFB6, sub_DFB6, sub_DFB6, sub_DFB6, sub_E00B, sub_E00B, sub_DBF0, sub_E076, sub_E076, sub_E076, sub_E051, sub_DBF0, sub_E112, sub_E112, sub_E112, sub_E0FB

; jump table $E4D8 (10 entries)
.word sub_DBF0, sub_E076, sub_E076, sub_E076, sub_E051, sub_DBF0, sub_E112, sub_E112, sub_E112, sub_E0FB

; jump table $E4E2 (5 entries)
.word sub_DBF0, sub_E112, sub_E112, sub_E112, sub_E0FB

; jump table $E9E2 (7 entries)
.word sub_E9F0, sub_E9F5, sub_E9FB, sub_EA07, sub_EA17, sub_EA3E, sub_EA48

; ---- $C000..$C06F : data ----
C070  78         irq:         SEI
C071  a9 10                   LDA #$10
C073  8d 00 20                STA $2000  ; PPUCTRL
C076  d8                      CLD
C077  a2 02                   LDX #$02
C079  ad 02 20   loc_C079:    LDA $2002  ; PPUSTATUS
C07C  10 fb                   BPL loc_C079
C07E  a9 06                   LDA #$06
C080  8d 01 20                STA $2001  ; PPUMASK
C083  ca                      DEX
C084  d0 f3                   BNE loc_C079
C086  a2 7f                   LDX #$7F
C088  9a                      TXS
C089  20 91 d4                JSR sub_D491
C08C  a9 00                   LDA #$00
C08E  85 4f                   STA $4F
C090  85 50                   STA $50
C092  20 67 d4                JSR sub_D467
C095  20 7f d1   sub_C095:    JSR sub_D17F
C098  a9 00                   LDA #$00
C09A  85 4b                   STA $4B
C09C  20 6a d1   sub_C09C:    JSR sub_D16A
C09F  20 ab c7                JSR sub_C7AB
C0A2  20 c0 c9   sub_C0A2:    JSR sub_C9C0
C0A5  20 b5 c3                JSR sub_C3B5
C0A8  20 1d c4                JSR sub_C41D
C0AB  4c 9c c0                JMP sub_C09C
C0AE  a5 4b      sub_C0AE:    LDA $4B
C0B0  d0 0c                   BNE loc_C0BE
C0B2  20 70 d4                JSR sub_D470
C0B5  20 b0 c9                JSR sub_C9B0
C0B8  20 b4 d7                JSR sub_D7B4
C0BB  20 67 d4                JSR sub_D467
C0BE  20 13 e4   loc_C0BE:    JSR sub_E413
C0C1  a9 10                   LDA #$10
C0C3  85 90                   STA $90
C0C5  a9 18                   LDA #$18
C0C7  85 98                   STA $98
C0C9  a9 84                   LDA #$84
C0CB  85 a0                   STA $A0
C0CD  a9 00                   LDA #$00
C0CF  85 a8                   STA $A8
C0D1  85 6e                   STA $6E
C0D3  85 b0                   STA $B0
C0D5  85 81                   STA $81
C0D7  85 7b                   STA $7B
C0D9  85 5c                   STA $5C
C0DB  85 4f                   STA $4F
C0DD  85 50                   STA $50
C0DF  85 6f                   STA $6F
C0E1  85 70                   STA $70
C0E3  a5 4b                   LDA $4B
C0E5  d0 03                   BNE loc_C0EA
C0E7  20 f5 ca                JSR sub_CAF5
C0EA  20 f6 d8   loc_C0EA:    JSR sub_D8F6
C0ED  20 d2 c6                JSR sub_C6D2
C0F0  20 d0 c8                JSR sub_C8D0
C0F3  a5 0b                   LDA $0B
C0F5  29 10                   AND #$10
C0F7  f0 03                   BEQ loc_C0FC
C0F9  20 a6 de                JSR sub_DEA6
C0FC  a5 06      loc_C0FC:    LDA $06
C0FE  29 f0                   AND #$F0
C100  d0 3c                   BNE loc_C13E
C102  a5 08                   LDA $08
C104  29 01                   AND #$01
C106  f0 18                   BEQ loc_C120
C108  a5 81                   LDA $81
C10A  d0 05                   BNE loc_C111
C10C  e6 81                   INC $81
C10E  4c 44 c1                JMP sub_C144
C111  e6 5c      loc_C111:    INC $5C
C113  a5 5c                   LDA $5C
C115  c9 0e                   CMP #$0E
C117  d0 2b                   BNE sub_C144
C119  a9 00                   LDA #$00
C11B  85 5c                   STA $5C
C11D  4c 44 c1                JMP sub_C144
C120  a5 08      loc_C120:    LDA $08
C122  29 02                   AND #$02
C124  f0 18                   BEQ loc_C13E
C126  a5 81                   LDA $81
C128  d0 05                   BNE loc_C12F
C12A  e6 81                   INC $81
C12C  4c 44 c1                JMP sub_C144
C12F  c6 5c      loc_C12F:    DEC $5C
C131  a5 5c                   LDA $5C
C133  c9 ff                   CMP #$FF
C135  d0 0d                   BNE sub_C144
C137  a9 0d                   LDA #$0D
C139  85 5c                   STA $5C
C13B  4c 44 c1                JMP sub_C144
C13E  a5 06      loc_C13E:    LDA $06
C140  29 03                   AND #$03
C142  f0 03                   BEQ loc_C147
C144  20 c6 c6   sub_C144:    JSR sub_C6C6
C147  a5 08      loc_C147:    LDA $08
C149  29 08                   AND #$08
C14B  d0 03                   BNE loc_C150
C14D  4c ea c0                JMP loc_C0EA
C150  a9 20      loc_C150:    LDA #$20
C152  85 6e                   STA $6E
C154  e6 4b                   INC $4B
C156  4c a2 c0                JMP sub_C0A2
C159  20 f6 d8   sub_C159:    JSR sub_D8F6
C15C  20 51 ea                JSR sub_EA51
C15F  a9 1c                   LDA #$1C
C161  85 05                   STA $05
C163  a9 00                   LDA #$00
C165  85 4f                   STA $4F
C167  85 50                   STA $50
C169  85 6d                   STA $6D
C16B  a9 04                   LDA #$04
C16D  85 4d                   STA $4D
C16F  20 90 cc                JSR sub_CC90
C172  20 91 ca   loc_C172:    JSR sub_CA91
C175  a5 4c                   LDA $4C
C177  d0 4c                   BNE loc_C1C5
C179  a5 08                   LDA $08
C17B  29 08                   AND #$08
C17D  d0 46                   BNE loc_C1C5
C17F  a5 08                   LDA $08
C181  29 01                   AND #$01
C183  d0 0c                   BNE loc_C191
C185  a5 06                   LDA $06
C187  29 01                   AND #$01
C189  f0 19                   BEQ loc_C1A4
C18B  a5 0b                   LDA $0B
C18D  29 07                   AND #$07
C18F  d0 13                   BNE loc_C1A4
C191  a9 00      loc_C191:    LDA #$00
C193  85 0b                   STA $0B
C195  e6 85                   INC $85
C197  a5 85                   LDA $85
C199  c9 24                   CMP #$24
C19B  d0 d5                   BNE loc_C172
C19D  a9 23                   LDA #$23
C19F  85 85                   STA $85
C1A1  4c 72 c1                JMP loc_C172
C1A4  a5 08      loc_C1A4:    LDA $08
C1A6  29 02                   AND #$02
C1A8  d0 0c                   BNE loc_C1B6
C1AA  a5 06                   LDA $06
C1AC  29 02                   AND #$02
C1AE  f0 c2                   BEQ loc_C172
C1B0  a5 0b                   LDA $0B
C1B2  29 07                   AND #$07
C1B4  d0 bc                   BNE loc_C172
C1B6  a9 00      loc_C1B6:    LDA #$00
C1B8  85 0b                   STA $0B
C1BA  c6 85                   DEC $85
C1BC  d0 b4                   BNE loc_C172
C1BE  a9 01                   LDA #$01
C1C0  85 85                   STA $85
C1C2  4c 72 c1                JMP loc_C172
C1C5  a9 01      loc_C1C5:    LDA #$01
C1C7  8d 01 03                STA $0301
C1CA  8d 02 03                STA $0302
C1CD  8d 03 03                STA $0303
C1D0  a5 4b                   LDA $4B
C1D2  d0 0e                   BNE loc_C1E2
C1D4  20 b0 c9                JSR sub_C9B0
C1D7  a5 85                   LDA $85
C1D9  20 00 f0                JSR sub_F000
C1DC  20 f5 ca                JSR sub_CAF5
C1DF  4c e5 c1                JMP sub_C1E5
C1E2  20 5d cb   loc_C1E2:    JSR sub_CB5D
C1E5  a9 00      sub_C1E5:    LDA #$00
C1E7  85 0c                   STA $0C
C1E9  20 27 cc                JSR sub_CC27
C1EC  20 b2 cc                JSR sub_CCB2
C1EF  a9 00                   LDA #$00
C1F1  85 4d                   STA $4D
C1F3  20 f6 d8                JSR sub_D8F6
C1F6  20 31 c3                JSR sub_C331
C1F9  20 f6 d8   loc_C1F9:    JSR sub_D8F6
C1FC  a5 6d                   LDA $6D
C1FE  d0 03                   BNE loc_C203
C200  20 e6 c2                JSR sub_C2E6
C203  20 3b e2   loc_C203:    JSR sub_E23B
C206  20 d8 e0                JSR sub_E0D8
C209  20 a6 de                JSR sub_DEA6
C20C  a5 08                   LDA $08
C20E  29 08                   AND #$08
C210  f0 09                   BEQ loc_C21B
C212  a9 01                   LDA #$01
C214  45 6d                   EOR $6D
C216  85 6d                   STA $6D
C218  8d 00 03                STA $0300
C21B  20 f9 c8   loc_C21B:    JSR sub_C8F9
C21E  20 28 c7                JSR sub_C728
C221  f0 d6                   BEQ loc_C1F9
C223  a9 00                   LDA #$00
C225  85 0a                   STA $0A
C227  85 0b                   STA $0B
C229  8d 11 03                STA $0311
C22C  8d 12 03                STA $0312
C22F  ad 08 01                LDA $0108
C232  f0 04                   BEQ loc_C238
C234  a9 fe                   LDA #$FE
C236  85 0a                   STA $0A
C238  20 f6 d8   loc_C238:    JSR sub_D8F6
C23B  20 a2 c2                JSR sub_C2A2
C23E  20 e6 c2                JSR sub_C2E6
C241  20 3b e2                JSR sub_E23B
C244  20 a6 de                JSR sub_DEA6
C247  20 d8 e0                JSR sub_E0D8
C24A  20 1d c3                JSR sub_C31D
C24D  a5 0a                   LDA $0A
C24F  c9 02                   CMP #$02
C251  d0 e5                   BNE loc_C238
C253  20 51 ea                JSR sub_EA51
C256  20 d4 cc                JSR sub_CCD4
C259  e6 85                   INC $85
C25B  a5 85                   LDA $85
C25D  c9 47                   CMP #$47
C25F  d0 08                   BNE loc_C269
C261  a9 01                   LDA #$01
C263  85 85                   STA $85
C265  a9 00                   LDA #$00
C267  85 46                   STA $46
C269  a5 85      loc_C269:    LDA $85
C26B  c9 24                   CMP #$24
C26D  d0 04                   BNE loc_C273
C26F  a9 01                   LDA #$01
C271  85 46                   STA $46
C273  a5 51      loc_C273:    LDA $51
C275  18                      CLC
C276  65 52                   ADC $52
C278  f0 09                   BEQ loc_C283
C27A  a5 68                   LDA $68
C27C  c9 80                   CMP #$80
C27E  d0 03                   BNE loc_C283
C280  4c 59 c1                JMP sub_C159
C283  20 d9 c5   loc_C283:    JSR sub_C5D9
C286  20 7d d9                JSR sub_D97D
C289  98                      TYA
C28A  f0 06                   BEQ loc_C292
C28C  20 4b c4                JSR sub_C44B
C28F  20 95 c2                JSR sub_C295
C292  4c 95 c0   loc_C292:    JMP sub_C095
C295  20 70 d4   sub_C295:    JSR sub_D470
C298  20 7e d4                JSR sub_D47E
C29B  20 b4 d7                JSR sub_D7B4
C29E  20 67 d4                JSR sub_D467
C2A1  60                      RTS
C2A2  a5 68      sub_C2A2:    LDA $68
C2A4  c9 80                   CMP #$80
C2A6  f0 0a                   BEQ loc_C2B2
C2A8  a9 00                   LDA #$00
C2AA  85 06                   STA $06
C2AC  85 07                   STA $07
C2AE  85 08                   STA $08
C2B0  85 09                   STA $09
C2B2  60         loc_C2B2:    RTS
C2B3  a2 15      sub_C2B3:    LDX #$15
C2B5  20 fe d9                JSR sub_D9FE
C2B8  a2 1d                   LDX #$1D
C2BA  20 fe d9                JSR sub_D9FE
C2BD  a9 00      sub_C2BD:    LDA #$00
C2BF  8d 01 01                STA $0101
C2C2  8d 02 01                STA $0102
C2C5  a9 00                   LDA #$00
C2C7  85 66                   STA $66
C2C9  85 67                   STA $67
C2CB  85 4c                   STA $4C
C2CD  a9 03                   LDA #$03
C2CF  85 51                   STA $51
C2D1  85 52                   STA $52
C2D3  85 6a                   STA $6A
C2D5  a5 83                   LDA $83
C2D7  d0 04                   BNE loc_C2DD
C2D9  a9 00                   LDA #$00
C2DB  85 52                   STA $52
C2DD  a9 01      loc_C2DD:    LDA #$01
C2DF  85 85                   STA $85
C2E1  a9 00                   LDA #$00
C2E3  85 46                   STA $46
C2E5  60                      RTS
C2E6  20 81 e1   sub_C2E6:    JSR sub_E181
C2E9  20 75 db                JSR sub_DB75
C2EC  20 f1 db                JSR sub_DBF1
C2EF  20 fa e1                JSR sub_E1FA
C2F2  20 2e e0                JSR sub_E02E
C2F5  20 a9 e2                JSR sub_E2A9
C2F8  20 7c e2                JSR sub_E27C
C2FB  20 22 e1                JSR sub_E122
C2FE  20 62 e1                JSR sub_E162
C301  20 48 db                JSR sub_DB48
C304  20 04 e6                JSR sub_E604
C307  20 10 e9                JSR sub_E910
C30A  20 0c e7                JSR sub_E70C
C30D  20 72 e9                JSR sub_E972
C310  20 72 c9                JSR sub_C972
C313  20 0b db                JSR sub_DB0B
C316  20 c8 c7                JSR sub_C7C8
C319  20 1d c3                JSR sub_C31D
C31C  60                      RTS
C31D  a5 0b      sub_C31D:    LDA $0B
C31F  29 3f                   AND #$3F
C321  f0 09                   BEQ loc_C32C
C323  c9 20                   CMP #$20
C325  d0 09                   BNE loc_C330
C327  a9 01                   LDA #$01
C329  85 4d                   STA $4D
C32B  60                      RTS
C32C  a9 02      loc_C32C:    LDA #$02
C32E  85 4d                   STA $4D
C330  60         loc_C330:    RTS
C331  20 09 e4   sub_C331:    JSR sub_E409
C334  20 13 e4                JSR sub_E413
C337  a9 f0                   LDA #$F0
C339  8d 06 01                STA $0106
C33C  a9 00                   LDA #$00
C33E  8d 08 01                STA $0108
C341  a5 51                   LDA $51
C343  f0 05                   BEQ loc_C34A
C345  a2 00                   LDX #$00
C347  20 63 e3                JSR sub_E363
C34A  a5 52      loc_C34A:    LDA $52
C34C  f0 05                   BEQ loc_C353
C34E  a2 01                   LDX #$01
C350  20 63 e3                JSR sub_E363
C353  a9 14      loc_C353:    LDA #$14
C355  85 7f                   STA $7F
C357  85 80                   STA $80
C359  a9 00                   LDA #$00
C35B  85 8f                   STA $8F
C35D  85 0a                   STA $0A
C35F  85 4b                   STA $4B
C361  85 45                   STA $45
C363  85 6f                   STA $6F
C365  85 70                   STA $70
C367  85 89                   STA $89
C369  85 8a                   STA $8A
C36B  85 82                   STA $82
C36D  85 86                   STA $86
C36F  8d 00 01                STA $0100
C372  85 6a                   STA $6A
C374  20 1e c7                JSR sub_C71E
C377  20 c0 c8                JSR sub_C8C0
C37A  20 f6 d8                JSR sub_D8F6
C37D  20 30 c8                JSR sub_C830
C380  20 59 c8                JSR sub_C859
C383  20 2b e4                JSR sub_E42B
C386  a9 80                   LDA #$80
C388  85 68                   STA $68
C38A  a9 01                   LDA #$01
C38C  8d 12 03                STA $0312
C38F  85 4c                   STA $4C
C391  a5 46                   LDA $46
C393  c9 01                   CMP #$01
C395  d0 05                   BNE loc_C39C
C397  a9 23                   LDA #$23
C399  4c 9e c3                JMP sub_C39E
C39C  a5 85      loc_C39C:    LDA $85
C39E  0a         sub_C39E:    ASL A
C39F  0a                      ASL A
C3A0  85 00                   STA $00
C3A2  a9 be                   LDA #$BE
C3A4  38                      SEC
C3A5  e5 00                   SBC $00
C3A7  85 84                   STA $84
C3A9  a5 83                   LDA $83
C3AB  f0 07                   BEQ loc_C3B4
C3AD  a5 84                   LDA $84
C3AF  38                      SEC
C3B0  e9 14                   SBC #$14
C3B2  85 84                   STA $84
C3B4  60         loc_C3B4:    RTS
C3B5  a9 01      sub_C3B5:    LDA #$01
C3B7  85 6d                   STA $6D
C3B9  a9 00                   LDA #$00
C3BB  85 4d                   STA $4D
C3BD  20 bd c2                JSR sub_C2BD
C3C0  a9 03                   LDA #$03
C3C2  85 52                   STA $52
C3C4  a9 00                   LDA #$00
C3C6  85 4f                   STA $4F
C3C8  85 50                   STA $50
C3CA  85 0a                   STA $0A
C3CC  85 0b                   STA $0B
C3CE  20 b0 c9                JSR sub_C9B0
C3D1  a9 ff                   LDA #$FF
C3D3  85 85                   STA $85
C3D5  20 00 f0                JSR sub_F000
C3D8  a9 1e                   LDA #$1E
C3DA  85 85                   STA $85
C3DC  a9 02                   LDA #$02
C3DE  85 46                   STA $46
C3E0  20 70 d4                JSR sub_D470
C3E3  a2 1a                   LDX #$1A
C3E5  86 56                   STX $56
C3E7  a0 46                   LDY #$46
C3E9  84 57                   STY $57
C3EB  a9 d2                   LDA #$D2
C3ED  85 14                   STA $14
C3EF  a9 99                   LDA #$99
C3F1  85 13                   STA $13
C3F3  20 d2 d8                JSR sub_D8D2
C3F6  a2 3c                   LDX #$3C
C3F8  86 56                   STX $56
C3FA  a0 78                   LDY #$78
C3FC  84 57                   STY $57
C3FE  a9 d2                   LDA #$D2
C400  85 14                   STA $14
C402  a9 a0                   LDA #$A0
C404  85 13                   STA $13
C406  20 d2 d8                JSR sub_D8D2
C409  20 b4 d7                JSR sub_D7B4
C40C  20 67 d4                JSR sub_D467
C40F  20 31 c3                JSR sub_C331
C412  20 f5 ca                JSR sub_CAF5
C415  20 f6 d8                JSR sub_D8F6
C418  a9 05                   LDA #$05
C41A  85 6c                   STA $6C
C41C  60                      RTS
C41D  20 f6 d8   sub_C41D:    JSR sub_D8F6
C420  a5 08                   LDA $08
C422  29 0c                   AND #$0C
C424  d0 19                   BNE loc_C43F
C426  20 42 c6                JSR sub_C642
C429  20 e6 c2                JSR sub_C2E6
C42C  20 3b e2                JSR sub_E23B
C42F  20 a6 de                JSR sub_DEA6
C432  20 d8 e0                JSR sub_E0D8
C435  20 28 c7                JSR sub_C728
C438  f0 e3                   BEQ sub_C41D
C43A  a9 00                   LDA #$00
C43C  85 0c                   STA $0C
C43E  60                      RTS
C43F  68         loc_C43F:    PLA
C440  68                      PLA
C441  a9 00                   LDA #$00
C443  85 0c                   STA $0C
C445  20 6a d1                JSR sub_D16A
C448  4c a2 c0                JMP sub_C0A2
C44B  20 70 d4   sub_C44B:    JSR sub_D470
C44E  a9 1c                   LDA #$1C
C450  85 05                   STA $05
C452  a9 00                   LDA #$00
C454  85 4f                   STA $4F
C456  85 50                   STA $50
C458  20 7e d4                JSR sub_D47E
C45B  a2 10                   LDX #$10
C45D  86 56                   STX $56
C45F  a0 32                   LDY #$32
C461  84 57                   STY $57
C463  a9 d2                   LDA #$D2
C465  85 14                   STA $14
C467  a9 b5                   LDA #$B5
C469  85 13                   STA $13
C46B  20 d2 d8                JSR sub_D8D2
C46E  20 51 d9                JSR sub_D951
C471  20 b4 d7                JSR sub_D7B4
C474  20 67 d4                JSR sub_D467
C477  a9 00                   LDA #$00
C479  85 0a                   STA $0A
C47B  a9 01                   LDA #$01
C47D  8d 15 03                STA $0315
C480  8d 16 03                STA $0316
C483  8d 17 03                STA $0317
C486  20 f6 d8   loc_C486:    JSR sub_D8F6
C489  a5 0b                   LDA $0B
C48B  29 03                   AND #$03
C48D  18                      CLC
C48E  69 05                   ADC #$05
C490  85 4d                   STA $4D
C492  ad 15 03                LDA $0315
C495  d0 ef                   BNE loc_C486
C497  a9 00                   LDA #$00
C499  85 4d                   STA $4D
C49B  60                      RTS
C49C  20 70 d4   sub_C49C:    JSR sub_D470
C49F  a9 1c                   LDA #$1C
C4A1  85 05                   STA $05
C4A3  a9 00                   LDA #$00
C4A5  85 4f                   STA $4F
C4A7  85 50                   STA $50
C4A9  20 7e d4                JSR sub_D47E
C4AC  20 b4 d7                JSR sub_D7B4
C4AF  20 67 d4                JSR sub_D467
C4B2  20 67 c5                JSR sub_C567
C4B5  20 67 c5                JSR sub_C567
C4B8  a9 d3                   LDA #$D3
C4BA  85 12                   STA $12
C4BC  a9 0f                   LDA #$0F
C4BE  85 11                   STA $11
C4C0  a2 08                   LDX #$08
C4C2  a0 08                   LDY #$08
C4C4  20 b3 d6                JSR sub_D6B3
C4C7  20 67 c5                JSR sub_C567
C4CA  a9 d2                   LDA #$D2
C4CC  85 12                   STA $12
C4CE  a9 84                   LDA #$84
C4D0  85 11                   STA $11
C4D2  a2 08                   LDX #$08
C4D4  a0 0a                   LDY #$0A
C4D6  20 b3 d6                JSR sub_D6B3
C4D9  20 67 c5                JSR sub_C567
C4DC  a9 d3                   LDA #$D3
C4DE  85 12                   STA $12
C4E0  a9 34                   LDA #$34
C4E2  85 11                   STA $11
C4E4  a2 08                   LDX #$08
C4E6  a0 0c                   LDY #$0C
C4E8  20 b3 d6                JSR sub_D6B3
C4EB  20 67 c5                JSR sub_C567
C4EE  a9 d3                   LDA #$D3
C4F0  85 12                   STA $12
C4F2  a9 4d                   LDA #$4D
C4F4  85 11                   STA $11
C4F6  a2 08                   LDX #$08
C4F8  a0 0e                   LDY #$0E
C4FA  20 b3 d6                JSR sub_D6B3
C4FD  20 67 c5                JSR sub_C567
C500  a9 d3                   LDA #$D3
C502  85 12                   STA $12
C504  a9 3f                   LDA #$3F
C506  85 11                   STA $11
C508  a2 08                   LDX #$08
C50A  a0 10                   LDY #$10
C50C  20 b3 d6                JSR sub_D6B3
C50F  20 67 c5                JSR sub_C567
C512  a9 d3                   LDA #$D3
C514  85 12                   STA $12
C516  a9 3f                   LDA #$3F
C518  85 11                   STA $11
C51A  a2 09                   LDX #$09
C51C  a0 10                   LDY #$10
C51E  20 b3 d6                JSR sub_D6B3
C521  20 67 c5                JSR sub_C567
C524  a9 d3                   LDA #$D3
C526  85 12                   STA $12
C528  a9 3f                   LDA #$3F
C52A  85 11                   STA $11
C52C  a2 0a                   LDX #$0A
C52E  a0 10                   LDY #$10
C530  20 b3 d6                JSR sub_D6B3
C533  20 67 c5                JSR sub_C567
C536  a9 d3                   LDA #$D3
C538  85 12                   STA $12
C53A  a9 3f                   LDA #$3F
C53C  85 11                   STA $11
C53E  a2 0b                   LDX #$0B
C540  a0 10                   LDY #$10
C542  20 b3 d6                JSR sub_D6B3
C545  20 67 c5                JSR sub_C567
C548  a9 d3                   LDA #$D3
C54A  85 12                   STA $12
C54C  a9 3f                   LDA #$3F
C54E  85 11                   STA $11
C550  a2 0c                   LDX #$0C
C552  a0 10                   LDY #$10
C554  20 b3 d6                JSR sub_D6B3
C557  20 75 c5                JSR sub_C575
C55A  20 70 d4                JSR sub_D470
C55D  20 b0 c9                JSR sub_C9B0
C560  20 b4 d7                JSR sub_D7B4
C563  20 67 d4                JSR sub_D467
C566  60                      RTS
C567  a9 00      sub_C567:    LDA #$00
C569  85 0b                   STA $0B
C56B  20 f6 d8   loc_C56B:    JSR sub_D8F6
C56E  a5 0b                   LDA $0B
C570  29 3f                   AND #$3F
C572  d0 f7                   BNE loc_C56B
C574  60                      RTS
C575  a9 78      sub_C575:    LDA #$78
C577  85 56                   STA $56
C579  a9 1e                   LDA #$1E
C57B  85 57                   STA $57
C57D  a9 00                   LDA #$00
C57F  85 5a                   STA $5A
C581  20 b0 c5   loc_C581:    JSR sub_C5B0
C584  20 b0 c5                JSR sub_C5B0
C587  20 b0 c5                JSR sub_C5B0
C58A  20 b0 c5                JSR sub_C5B0
C58D  e6 5a                   INC $5A
C58F  a5 5a                   LDA $5A
C591  c9 07                   CMP #$07
C593  d0 ec                   BNE loc_C581
C595  20 f6 d8   loc_C595:    JSR sub_D8F6
C598  e6 57                   INC $57
C59A  a9 9d                   LDA #$9D
C59C  85 53                   STA $53
C59E  a9 01                   LDA #$01
C5A0  85 04                   STA $04
C5A2  a6 56                   LDX $56
C5A4  a4 57                   LDY $57
C5A6  20 7b da                JSR sub_DA7B
C5A9  a5 57                   LDA $57
C5AB  c9 f8                   CMP #$F8
C5AD  d0 e6                   BNE loc_C595
C5AF  60                      RTS
C5B0  20 f6 d8   sub_C5B0:    JSR sub_D8F6
C5B3  a9 03                   LDA #$03
C5B5  85 04                   STA $04
C5B7  a9 03                   LDA #$03
C5B9  38                      SEC
C5BA  e5 5a                   SBC $5A
C5BC  10 05                   BPL loc_C5C3
C5BE  49 ff                   EOR #$FF
C5C0  18                      CLC
C5C1  69 01                   ADC #$01
C5C3  85 00      loc_C5C3:    STA $00
C5C5  a9 03                   LDA #$03
C5C7  38                      SEC
C5C8  e5 00                   SBC $00
C5CA  0a                      ASL A
C5CB  0a                      ASL A
C5CC  18                      CLC
C5CD  69 a1                   ADC #$A1
C5CF  85 53                   STA $53
C5D1  a6 56                   LDX $56
C5D3  a4 57                   LDY $57
C5D5  20 7b da                JSR sub_DA7B
C5D8  60                      RTS
C5D9  20 70 d4   sub_C5D9:    JSR sub_D470
C5DC  a9 1c                   LDA #$1C
C5DE  85 05                   STA $05
C5E0  a9 00                   LDA #$00
C5E2  85 4f                   STA $4F
C5E4  85 50                   STA $50
C5E6  20 7e d4                JSR sub_D47E
C5E9  a2 3c                   LDX #$3C
C5EB  86 56                   STX $56
C5ED  a0 46                   LDY #$46
C5EF  84 57                   STY $57
C5F1  a9 d3                   LDA #$D3
C5F3  85 14                   STA $14
C5F5  a9 43                   LDA #$43
C5F7  85 13                   STA $13
C5F9  20 d2 d8                JSR sub_D8D2
C5FC  a2 3c                   LDX #$3C
C5FE  86 56                   STX $56
C600  a0 78                   LDY #$78
C602  84 57                   STY $57
C604  a9 d3                   LDA #$D3
C606  85 14                   STA $14
C608  a9 48                   LDA #$48
C60A  85 13                   STA $13
C60C  20 d2 d8                JSR sub_D8D2
C60F  20 b4 d7                JSR sub_D7B4
C612  20 67 d4                JSR sub_D467
C615  a9 00                   LDA #$00
C617  85 0a                   STA $0A
C619  a9 01                   LDA #$01
C61B  8d 18 03                STA $0318
C61E  8d 19 03                STA $0319
C621  8d 1a 03                STA $031A
C624  20 f6 d8   loc_C624:    JSR sub_D8F6
C627  a5 08                   LDA $08
C629  29 0c                   AND #$0C
C62B  d0 05                   BNE loc_C632
C62D  ad 18 03                LDA $0318
C630  d0 f2                   BNE loc_C624
C632  20 70 d4   loc_C632:    JSR sub_D470
C635  20 7e d4                JSR sub_D47E
C638  20 b4 d7                JSR sub_D7B4
C63B  20 67 d4                JSR sub_D467
C63E  20 51 ea                JSR sub_EA51
C641  60                      RTS
C642  a9 01      sub_C642:    LDA #$01
C644  85 5a                   STA $5A
C646  a6 5a      loc_C646:    LDX $5A
C648  a5 86                   LDA $86
C64A  f0 12                   BEQ loc_C65E
C64C  a5 62                   LDA $62
C64E  d0 0e                   BNE loc_C65E
C650  a5 86                   LDA $86
C652  85 71                   STA $71
C654  a5 87                   LDA $87
C656  85 72                   STA $72
C658  20 a2 dd                JSR sub_DDA2
C65B  4c a5 c6                JMP sub_C6A5
C65E  b5 a2      loc_C65E:    LDA $A2,X
C660  10 12                   BPL loc_C674
C662  c9 e0                   CMP #$E0
C664  b0 0e                   BCS loc_C674
C666  b5 92                   LDA $92,X
C668  85 71                   STA $71
C66A  b5 9a                   LDA $9A,X
C66C  85 72                   STA $72
C66E  20 a2 dd                JSR sub_DDA2
C671  4c a5 c6                JMP sub_C6A5
C674  b5 a4      loc_C674:    LDA $A4,X
C676  10 12                   BPL loc_C68A
C678  c9 e0                   CMP #$E0
C67A  b0 0e                   BCS loc_C68A
C67C  b5 94                   LDA $94,X
C67E  85 71                   STA $71
C680  b5 9c                   LDA $9C,X
C682  85 72                   STA $72
C684  20 a2 dd                JSR sub_DDA2
C687  4c a5 c6                JMP sub_C6A5
C68A  b5 a3      loc_C68A:    LDA $A3,X
C68C  10 12                   BPL loc_C6A0
C68E  c9 e0                   CMP #$E0
C690  b0 0e                   BCS loc_C6A0
C692  b5 93                   LDA $93,X
C694  85 71                   STA $71
C696  b5 9b                   LDA $9B,X
C698  85 72                   STA $72
C69A  20 a2 dd                JSR sub_DDA2
C69D  4c a5 c6                JMP sub_C6A5
C6A0  a9 00      loc_C6A0:    LDA #$00
C6A2  4c ab c6                JMP sub_C6AB
C6A5  29 03      sub_C6A5:    AND #$03
C6A7  a8                      TAY
C6A8  b9 c2 c6                LDA $C6C2,Y
C6AB  a6 5a      sub_C6AB:    LDX $5A
C6AD  95 06                   STA $06,X
C6AF  95 08                   STA $08,X
C6B1  b5 98                   LDA $98,X
C6B3  c9 c8                   CMP #$C8
C6B5  90 06                   BCC loc_C6BD
C6B7  b5 08                   LDA $08,X
C6B9  29 f0                   AND #$F0
C6BB  95 08                   STA $08,X
C6BD  c6 5a      loc_C6BD:    DEC $5A
C6BF  10 85                   BPL loc_C646
C6C1  60                      RTS

; ---- $C6C2..$C6C5 (4 bytes: data) ----
C6C6  a5 5c      sub_C6C6:    LDA $5C
C6C8  29 0f                   AND #$0F
C6CA  a6 90                   LDX $90
C6CC  a4 98                   LDY $98
C6CE  20 0b d8                JSR sub_D80B
C6D1  60                      RTS
C6D2  a5 06      sub_C6D2:    LDA $06
C6D4  29 f0                   AND #$F0
C6D6  f0 09                   BEQ loc_C6E1
C6D8  e6 7b                   INC $7B
C6DA  a9 00                   LDA #$00
C6DC  85 81                   STA $81
C6DE  4c e5 c6                JMP sub_C6E5
C6E1  a9 00      loc_C6E1:    LDA #$00
C6E3  85 7b                   STA $7B
C6E5  a5 7b      sub_C6E5:    LDA $7B
C6E7  c9 14                   CMP #$14
C6E9  f0 10                   BEQ loc_C6FB
C6EB  a5 08                   LDA $08
C6ED  29 f0                   AND #$F0
C6EF  f0 2c                   BEQ loc_C71D
C6F1  a5 08                   LDA $08
C6F3  20 51 e4                JSR sub_E451
C6F6  30 25                   BMI loc_C71D
C6F8  4c 04 c7                JMP sub_C704
C6FB  a9 0f      loc_C6FB:    LDA #$0F
C6FD  85 7b                   STA $7B
C6FF  a5 06                   LDA $06
C701  20 51 e4                JSR sub_E451
C704  a8         sub_C704:    TAY
C705  b9 d5 d3                LDA $D3D5,Y
C708  0a                      ASL A
C709  0a                      ASL A
C70A  0a                      ASL A
C70B  0a                      ASL A
C70C  18                      CLC
C70D  65 90                   ADC $90
C70F  85 90                   STA $90
C711  b9 d9 d3                LDA $D3D9,Y
C714  0a                      ASL A
C715  0a                      ASL A
C716  0a                      ASL A
C717  0a                      ASL A
C718  18                      CLC
C719  65 98                   ADC $98
C71B  85 98                   STA $98
C71D  60         loc_C71D:    RTS
C71E  a2 07      sub_C71E:    LDX #$07
C720  a9 00                   LDA #$00
C722  95 73      loc_C722:    STA $73,X
C724  ca                      DEX
C725  10 fb                   BPL loc_C722
C727  60                      RTS
C728  a5 68      sub_C728:    LDA $68
C72A  f0 0b                   BEQ loc_C737
C72C  a5 80                   LDA $80
C72E  f0 1f                   BEQ loc_C74F
C730  a5 51                   LDA $51
C732  18                      CLC
C733  65 52                   ADC $52
C735  d0 1b                   BNE loc_C752
C737  a9 70      loc_C737:    LDA #$70
C739  8d 05 01                STA $0105
C73C  a9 f0                   LDA #$F0
C73E  8d 06 01                STA $0106
C741  a9 00                   LDA #$00
C743  8d 07 01                STA $0107
C746  a9 11                   LDA #$11
C748  8d 08 01                STA $0108
C74B  a9 00                   LDA #$00
C74D  85 0b                   STA $0B
C74F  a9 01      loc_C74F:    LDA #$01
C751  60                      RTS
C752  a9 00      loc_C752:    LDA #$00
C754  60                      RTS

; ---- $C755..$C7AA (86 bytes: data) ----
C7AB  a9 00      sub_C7AB:    LDA #$00
C7AD  85 4f                   STA $4F
C7AF  85 50                   STA $50
C7B1  20 f6 d8   loc_C7B1:    JSR sub_D8F6
C7B4  e6 4f                   INC $4F
C7B6  a5 08                   LDA $08
C7B8  29 0c                   AND #$0C
C7BA  d0 07                   BNE loc_C7C3
C7BC  a5 4f                   LDA $4F
C7BE  c9 f0                   CMP #$F0
C7C0  d0 ef                   BNE loc_C7B1
C7C2  60                      RTS
C7C3  68         loc_C7C3:    PLA
C7C4  68                      PLA
C7C5  4c a2 c0                JMP sub_C0A2
C7C8  a9 01      sub_C7C8:    LDA #$01
C7CA  85 5a                   STA $5A
C7CC  85 6b                   STA $6B
C7CE  a9 6e                   LDA #$6E
C7D0  85 60                   STA $60
C7D2  a9 d3                   LDA #$D3
C7D4  85 12                   STA $12
C7D6  a9 41                   LDA #$41
C7D8  85 11                   STA $11
C7DA  a2 1d                   LDX #$1D
C7DC  a0 12                   LDY #$12
C7DE  20 b3 d6                JSR sub_D6B3
C7E1  a5 46                   LDA $46
C7E3  c9 02                   CMP #$02
C7E5  f0 0b                   BEQ loc_C7F2
C7E7  a5 83                   LDA $83
C7E9  d0 07                   BNE loc_C7F2
C7EB  a9 00                   LDA #$00
C7ED  85 5a                   STA $5A
C7EF  4c 01 c8                JMP sub_C801
C7F2  a9 d3      loc_C7F2:    LDA #$D3
C7F4  85 12                   STA $12
C7F6  a9 41                   LDA #$41
C7F8  85 11                   STA $11
C7FA  a2 1d                   LDX #$1D
C7FC  a0 15                   LDY #$15
C7FE  20 b3 d6                JSR sub_D6B3
C801  a6 5a      sub_C801:    LDX $5A
C803  b5 51                   LDA $51,X
C805  38                      SEC
C806  e9 01                   SBC #$01
C808  10 02                   BPL loc_C80C
C80A  a9 00                   LDA #$00
C80C  20 13 da   loc_C80C:    JSR sub_DA13
C80F  a0 36                   LDY #$36
C811  a2 19                   LDX #$19
C813  20 34 d9                JSR sub_D934
C816  a5 5a                   LDA $5A
C818  85 00                   STA $00
C81A  0a                      ASL A
C81B  18                      CLC
C81C  65 00                   ADC $00
C81E  18                      CLC
C81F  69 12                   ADC #$12
C821  a8                      TAY
C822  20 dd d6                JSR sub_D6DD
C825  c6 5a                   DEC $5A
C827  10 d8                   BPL sub_C801
C829  a9 00                   LDA #$00
C82B  85 60                   STA $60
C82D  85 6b                   STA $6B
C82F  60                      RTS
C830  a9 d2      sub_C830:    LDA #$D2
C832  85 12                   STA $12
C834  a9 ab                   LDA #$AB
C836  85 11                   STA $11
C838  a2 1d                   LDX #$1D
C83A  a0 11                   LDY #$11
C83C  20 b3 d6                JSR sub_D6B3
C83F  a5 46                   LDA $46
C841  c9 02                   CMP #$02
C843  f0 04                   BEQ loc_C849
C845  a5 83                   LDA $83
C847  f0 0f                   BEQ loc_C858
C849  a9 d2      loc_C849:    LDA #$D2
C84B  85 12                   STA $12
C84D  a9 ae                   LDA #$AE
C84F  85 11                   STA $11
C851  a2 1d                   LDX #$1D
C853  a0 14                   LDY #$14
C855  20 b3 d6                JSR sub_D6B3
C858  60         loc_C858:    RTS
C859  20 f6 d8   sub_C859:    JSR sub_D8F6
C85C  a9 d3                   LDA #$D3
C85E  85 12                   STA $12
C860  a9 65                   LDA #$65
C862  85 11                   STA $11
C864  a2 1d                   LDX #$1D
C866  a0 17                   LDY #$17
C868  20 b3 d6                JSR sub_D6B3
C86B  a9 d3                   LDA #$D3
C86D  85 12                   STA $12
C86F  a9 68                   LDA #$68
C871  85 11                   STA $11
C873  a2 1d                   LDX #$1D
C875  a0 18                   LDY #$18
C877  20 b3 d6                JSR sub_D6B3
C87A  a9 6e                   LDA #$6E
C87C  85 60                   STA $60
C87E  a5 85                   LDA $85
C880  20 13 da                JSR sub_DA13
C883  a0 36                   LDY #$36
C885  a2 19                   LDX #$19
C887  20 34 d9                JSR sub_D934
C88A  a0 19                   LDY #$19
C88C  20 dd d6                JSR sub_D6DD
C88F  a9 00                   LDA #$00
C891  85 60                   STA $60
C893  60                      RTS
C894  48         sub_C894:    PHA
C895  29 01                   AND #$01
C897  18                      CLC
C898  69 1d                   ADC #$1D
C89A  aa                      TAX
C89B  68                      PLA
C89C  4a                      LSR A
C89D  18                      CLC
C89E  69 03                   ADC #$03
C8A0  a8                      TAY
C8A1  60                      RTS
C8A2  20 94 c8   sub_C8A2:    JSR sub_C894
C8A5  a9 d3                   LDA #$D3
C8A7  85 12                   STA $12
C8A9  a9 62                   LDA #$62
C8AB  85 11                   STA $11
C8AD  20 b3 d6                JSR sub_D6B3
C8B0  60                      RTS
C8B1  20 94 c8   sub_C8B1:    JSR sub_C894
C8B4  a9 d3                   LDA #$D3
C8B6  85 12                   STA $12
C8B8  a9 6b                   LDA #$6B
C8BA  85 11                   STA $11
C8BC  20 b3 d6                JSR sub_D6B3
C8BF  60                      RTS
C8C0  a9 12      sub_C8C0:    LDA #$12
C8C2  85 5a                   STA $5A
C8C4  a5 5a      loc_C8C4:    LDA $5A
C8C6  20 a2 c8                JSR sub_C8A2
C8C9  c6 5a                   DEC $5A
C8CB  c6 5a                   DEC $5A
C8CD  10 f5                   BPL loc_C8C4
C8CF  60                      RTS
C8D0  a5 90      sub_C8D0:    LDA $90
C8D2  c9 d8                   CMP #$D8
C8D4  90 04                   BCC loc_C8DA
C8D6  a9 d8                   LDA #$D8
C8D8  85 90                   STA $90
C8DA  a5 90      loc_C8DA:    LDA $90
C8DC  c9 18                   CMP #$18
C8DE  b0 04                   BCS loc_C8E4
C8E0  a9 18                   LDA #$18
C8E2  85 90                   STA $90
C8E4  a5 98      loc_C8E4:    LDA $98
C8E6  c9 d8                   CMP #$D8
C8E8  90 04                   BCC loc_C8EE
C8EA  a9 d8                   LDA #$D8
C8EC  85 98                   STA $98
C8EE  a5 98      loc_C8EE:    LDA $98
C8F0  c9 18                   CMP #$18
C8F2  b0 04                   BCS loc_C8F8
C8F4  a9 18                   LDA #$18
C8F6  85 98                   STA $98
C8F8  60         loc_C8F8:    RTS
C8F9  a5 6d      sub_C8F9:    LDA $6D
C8FB  f0 49                   BEQ loc_C946
C8FD  a5 0b                   LDA $0B
C8FF  29 10                   AND #$10
C901  f0 43                   BEQ loc_C946
C903  a9 03                   LDA #$03
C905  85 04                   STA $04
C907  a9 00                   LDA #$00
C909  85 6e                   STA $6E
C90B  a2 64                   LDX #$64
C90D  a0 80                   LDY #$80
C90F  a9 17                   LDA #$17
C911  85 53                   STA $53
C913  20 2b da                JSR sub_DA2B
C916  a2 6c                   LDX #$6C
C918  a0 80                   LDY #$80
C91A  a9 19                   LDA #$19
C91C  85 53                   STA $53
C91E  20 2b da                JSR sub_DA2B
C921  a2 74                   LDX #$74
C923  a0 80                   LDY #$80
C925  a9 1b                   LDA #$1B
C927  85 53                   STA $53
C929  20 2b da                JSR sub_DA2B
C92C  a2 7c                   LDX #$7C
C92E  a0 80                   LDY #$80
C930  a9 1d                   LDA #$1D
C932  85 53                   STA $53
C934  20 2b da                JSR sub_DA2B
C937  a2 84                   LDX #$84
C939  a0 80                   LDY #$80
C93B  a9 1f                   LDA #$1F
C93D  85 53                   STA $53
C93F  20 2b da                JSR sub_DA2B
C942  a9 20                   LDA #$20
C944  85 6e                   STA $6E
C946  60         loc_C946:    RTS
C947  a9 03      sub_C947:    LDA #$03
C949  85 04                   STA $04
C94B  a9 00                   LDA #$00
C94D  85 6e                   STA $6E
C94F  ae 05 01                LDX $0105
C952  ac 06 01                LDY $0106
C955  a9 79                   LDA #$79
C957  85 53                   STA $53
C959  20 7b da                JSR sub_DA7B
C95C  ad 05 01                LDA $0105
C95F  18                      CLC
C960  69 10                   ADC #$10
C962  aa                      TAX
C963  ac 06 01                LDY $0106
C966  a9 7d                   LDA #$7D
C968  85 53                   STA $53
C96A  20 7b da                JSR sub_DA7B
C96D  a9 20                   LDA #$20
C96F  85 6e                   STA $6E
C971  60                      RTS
C972  ad 08 01   sub_C972:    LDA $0108
C975  f0 38                   BEQ loc_C9AF
C977  a5 46                   LDA $46
C979  c9 02                   CMP #$02
C97B  f0 32                   BEQ loc_C9AF
C97D  a5 0b                   LDA $0B
C97F  29 0f                   AND #$0F
C981  d0 0a                   BNE loc_C98D
C983  ce 08 01                DEC $0108
C986  d0 05                   BNE loc_C98D
C988  a9 f0                   LDA #$F0
C98A  8d 06 01                STA $0106
C98D  ad 08 01   loc_C98D:    LDA $0108
C990  c9 0a                   CMP #$0A
C992  90 18                   BCC loc_C9AC
C994  ad 07 01                LDA $0107
C997  a8                      TAY
C998  b9 d5 d3                LDA $D3D5,Y
C99B  18                      CLC
C99C  6d 05 01                ADC $0105
C99F  8d 05 01                STA $0105
C9A2  b9 d9 d3                LDA $D3D9,Y
C9A5  18                      CLC
C9A6  6d 06 01                ADC $0106
C9A9  8d 06 01                STA $0106
C9AC  20 47 c9   loc_C9AC:    JSR sub_C947
C9AF  60         loc_C9AF:    RTS
C9B0  a9 02      sub_C9B0:    LDA #$02
C9B2  85 56                   STA $56
C9B4  85 57                   STA $57
C9B6  a9 1a                   LDA #$1A
C9B8  85 5a                   STA $5A
C9BA  85 5b                   STA $5B
C9BC  20 cc d7                JSR sub_D7CC
C9BF  60                      RTS
C9C0  a9 03      sub_C9C0:    LDA #$03
C9C2  85 4d                   STA $4D
C9C4  20 13 e4                JSR sub_E413
C9C7  a9 48                   LDA #$48
C9C9  85 90                   STA $90
C9CB  20 85 ca                JSR sub_CA85
C9CE  a9 83                   LDA #$83
C9D0  85 a0                   STA $A0
C9D2  a9 00                   LDA #$00
C9D4  85 0a                   STA $0A
C9D6  85 a8                   STA $A8
C9D8  85 b0                   STA $B0
C9DA  85 6f                   STA $6F
C9DC  85 70                   STA $70
C9DE  85 4f                   STA $4F
C9E0  85 4a                   STA $4A
C9E2  a9 02                   LDA #$02
C9E4  85 50                   STA $50
C9E6  20 f6 d8   loc_C9E6:    JSR sub_D8F6
C9E9  a5 0b                   LDA $0B
C9EB  29 03                   AND #$03
C9ED  d0 06                   BNE loc_C9F5
C9EF  a5 b0                   LDA $B0
C9F1  49 04                   EOR #$04
C9F3  85 b0                   STA $B0
C9F5  20 a6 de   loc_C9F5:    JSR sub_DEA6
C9F8  a5 08                   LDA $08
C9FA  29 04                   AND #$04
C9FC  f0 06                   BEQ loc_CA04
C9FE  e6 83                   INC $83
CA00  a9 00                   LDA #$00
CA02  85 0a                   STA $0A
CA04  a5 06      loc_CA04:    LDA $06
CA06  29 20                   AND #$20
CA08  f0 0d                   BEQ loc_CA17
CA0A  a5 09                   LDA $09
CA0C  29 01                   AND #$01
CA0E  f0 07                   BEQ loc_CA17
CA10  a9 10                   LDA #$10
CA12  18                      CLC
CA13  65 4a                   ADC $4A
CA15  85 4a                   STA $4A
CA17  a5 06      loc_CA17:    LDA $06
CA19  29 80                   AND #$80
CA1B  f0 08                   BEQ loc_CA25
CA1D  a5 09                   LDA $09
CA1F  29 02                   AND #$02
CA21  f0 02                   BEQ loc_CA25
CA23  c6 4a                   DEC $4A
CA25  a5 83      loc_CA25:    LDA $83
CA27  c9 03                   CMP #$03
CA29  90 04                   BCC loc_CA2F
CA2B  a9 00                   LDA #$00
CA2D  85 83                   STA $83
CA2F  20 85 ca   loc_CA2F:    JSR sub_CA85
CA32  a5 0a                   LDA $0A
CA34  c9 0a                   CMP #$0A
CA36  d0 05                   BNE loc_CA3D
CA38  a5 4b                   LDA $4B
CA3A  d0 01                   BNE loc_CA3D
CA3C  60                      RTS
CA3D  a5 08      loc_CA3D:    LDA $08
CA3F  29 08                   AND #$08
CA41  f0 a3                   BEQ loc_C9E6
CA43  a5 4b                   LDA $4B
CA45  c9 07                   CMP #$07
CA47  d0 09                   BNE loc_CA52
CA49  a5 4a                   LDA $4A
CA4B  c9 74                   CMP #$74
CA4D  d0 03                   BNE loc_CA52
CA4F  20 9c c4                JSR sub_C49C
CA52  a9 00      loc_CA52:    LDA #$00
CA54  85 4d                   STA $4D
CA56  68                      PLA
CA57  68                      PLA
CA58  a5 83                   LDA $83
CA5A  0a                      ASL A
CA5B  a8                      TAY
CA5C  b9 69 ca                LDA $CA69,Y
CA5F  85 11                   STA $11
CA61  b9 6a ca                LDA $CA6A,Y
CA64  85 12                   STA $12
CA66  6c 11 00                JMP ($0011)

; ---- $CA69..$CA6E (6 bytes: data) ----
CA6F  a9 05                   LDA #$05
CA71  4c 76 ca                JMP sub_CA76
CA74  a9 07                   LDA #$07
CA76  85 6c      sub_CA76:    STA $6C
CA78  20 b3 c2                JSR sub_C2B3
CA7B  4c 59 c1                JMP sub_C159
CA7E  a9 07                   LDA #$07
CA80  85 6c                   STA $6C
CA82  4c ae c0                JMP sub_C0AE
CA85  a5 83      sub_CA85:    LDA $83
CA87  0a                      ASL A
CA88  0a                      ASL A
CA89  0a                      ASL A
CA8A  0a                      ASL A
CA8B  18                      CLC
CA8C  69 8b                   ADC #$8B
CA8E  85 98                   STA $98
CA90  60                      RTS
CA91  20 f6 d8   sub_CA91:    JSR sub_D8F6
CA94  a2 0c                   LDX #$0C
CA96  a0 0e                   LDY #$0E
CA98  20 fb d5                JSR sub_D5FB
CA9B  a6 0c                   LDX $0C
CA9D  18                      CLC
CA9E  69 1c                   ADC #$1C
CAA0  9d 80 01                STA $0180,X
CAA3  e8                      INX
CAA4  98                      TYA
CAA5  9d 80 01                STA $0180,X
CAA8  e8                      INX
CAA9  a9 23                   LDA #$23
CAAB  9d 80 01                STA $0180,X
CAAE  e8                      INX
CAAF  a9 24                   LDA #$24
CAB1  9d 80 01                STA $0180,X
CAB4  e8                      INX
CAB5  a9 25                   LDA #$25
CAB7  9d 80 01                STA $0180,X
CABA  e8                      INX
CABB  a9 26                   LDA #$26
CABD  9d 80 01                STA $0180,X
CAC0  e8                      INX
CAC1  a9 27                   LDA #$27
CAC3  9d 80 01                STA $0180,X
CAC6  e8                      INX
CAC7  a9 11                   LDA #$11
CAC9  9d 80 01                STA $0180,X
CACC  e8                      INX
CACD  a9 11                   LDA #$11
CACF  9d 80 01                STA $0180,X
CAD2  e8                      INX
CAD3  a9 ff                   LDA #$FF
CAD5  9d 80 01                STA $0180,X
CAD8  e8                      INX
CAD9  86 0c                   STX $0C
CADB  a9 6e                   LDA #$6E
CADD  85 60                   STA $60
CADF  a5 85                   LDA $85
CAE1  20 13 da                JSR sub_DA13
CAE4  a0 36                   LDY #$36
CAE6  a2 0e                   LDX #$0E
CAE8  20 34 d9                JSR sub_D934
CAEB  a0 0e                   LDY #$0E
CAED  20 dd d6                JSR sub_D6DD
CAF0  a9 00                   LDA #$00
CAF2  85 60                   STA $60
CAF4  60                      RTS
CAF5  a9 d3      sub_CAF5:    LDA #$D3
CAF7  85 12                   STA $12
CAF9  a9 6d                   LDA #$6D
CAFB  85 11                   STA $11
CAFD  a2 0c                   LDX #$0C
CAFF  a0 18                   LDY #$18
CB01  20 b3 d6                JSR sub_D6B3
CB04  a9 d3                   LDA #$D3
CB06  85 12                   STA $12
CB08  a9 74                   LDA #$74
CB0A  85 11                   STA $11
CB0C  a2 0c                   LDX #$0C
CB0E  a0 19                   LDY #$19
CB10  20 b3 d6                JSR sub_D6B3
CB13  a9 d3                   LDA #$D3
CB15  85 12                   STA $12
CB17  a9 7b                   LDA #$7B
CB19  85 11                   STA $11
CB1B  a2 0c                   LDX #$0C
CB1D  a0 1a                   LDY #$1A
CB1F  20 b3 d6                JSR sub_D6B3
CB22  a9 d3                   LDA #$D3
CB24  85 12                   STA $12
CB26  a9 82                   LDA #$82
CB28  85 11                   STA $11
CB2A  a2 0c                   LDX #$0C
CB2C  a0 1b                   LDY #$1B
CB2E  20 b3 d6                JSR sub_D6B3
CB31  a6 0c                   LDX $0C
CB33  a9 23                   LDA #$23
CB35  9d 80 01                STA $0180,X
CB38  e8                      INX
CB39  a9 f3                   LDA #$F3
CB3B  9d 80 01                STA $0180,X
CB3E  e8                      INX
CB3F  a9 00                   LDA #$00
CB41  8d f3 07                STA $07F3
CB44  9d 80 01                STA $0180,X
CB47  e8                      INX
CB48  ad f4 07                LDA $07F4
CB4B  29 cc                   AND #$CC
CB4D  8d f4 07                STA $07F4
CB50  9d 80 01                STA $0180,X
CB53  e8                      INX
CB54  a9 ff                   LDA #$FF
CB56  9d 80 01                STA $0180,X
CB59  e8                      INX
CB5A  86 0c                   STX $0C
CB5C  60                      RTS
CB5D  a9 d3      sub_CB5D:    LDA #$D3
CB5F  85 12                   STA $12
CB61  a9 a5                   LDA #$A5
CB63  85 11                   STA $11
CB65  a2 0e                   LDX #$0E
CB67  a0 1a                   LDY #$1A
CB69  20 b3 d6                JSR sub_D6B3
CB6C  a9 d3                   LDA #$D3
CB6E  85 12                   STA $12
CB70  a9 a8                   LDA #$A8
CB72  85 11                   STA $11
CB74  a2 0e                   LDX #$0E
CB76  a0 1b                   LDY #$1B
CB78  20 b3 d6                JSR sub_D6B3
CB7B  a6 0c                   LDX $0C
CB7D  a9 23                   LDA #$23
CB7F  9d 80 01                STA $0180,X
CB82  e8                      INX
CB83  a9 f3                   LDA #$F3
CB85  9d 80 01                STA $0180,X
CB88  e8                      INX
CB89  ad f3 07                LDA $07F3
CB8C  29 3f                   AND #$3F
CB8E  8d f3 07                STA $07F3
CB91  9d 80 01                STA $0180,X
CB94  e8                      INX
CB95  a9 ff                   LDA #$FF
CB97  9d 80 01                STA $0180,X
CB9A  e8                      INX
CB9B  86 0c                   STX $0C
CB9D  60                      RTS
CB9E  a9 d3      sub_CB9E:    LDA #$D3
CBA0  85 12                   STA $12
CBA2  a9 89                   LDA #$89
CBA4  85 11                   STA $11
CBA6  a2 0c                   LDX #$0C
CBA8  a0 18                   LDY #$18
CBAA  20 b3 d6                JSR sub_D6B3
CBAD  a9 d3                   LDA #$D3
CBAF  85 12                   STA $12
CBB1  a9 90                   LDA #$90
CBB3  85 11                   STA $11
CBB5  a2 0c                   LDX #$0C
CBB7  a0 19                   LDY #$19
CBB9  20 b3 d6                JSR sub_D6B3
CBBC  a9 d3                   LDA #$D3
CBBE  85 12                   STA $12
CBC0  a9 97                   LDA #$97
CBC2  85 11                   STA $11
CBC4  a2 0c                   LDX #$0C
CBC6  a0 1a                   LDY #$1A
CBC8  20 b3 d6                JSR sub_D6B3
CBCB  a9 d3                   LDA #$D3
CBCD  85 12                   STA $12
CBCF  a9 9e                   LDA #$9E
CBD1  85 11                   STA $11
CBD3  a2 0c                   LDX #$0C
CBD5  a0 1b                   LDY #$1B
CBD7  20 b3 d6                JSR sub_D6B3
CBDA  a6 0c                   LDX $0C
CBDC  a9 23                   LDA #$23
CBDE  9d 80 01                STA $0180,X
CBE1  e8                      INX
CBE2  a9 f3                   LDA #$F3
CBE4  9d 80 01                STA $0180,X
CBE7  e8                      INX
CBE8  a9 3f                   LDA #$3F
CBEA  8d f3 07                STA $07F3
CBED  9d 80 01                STA $0180,X
CBF0  e8                      INX
CBF1  ad f4 07                LDA $07F4
CBF4  29 cc                   AND #$CC
CBF6  09 33                   ORA #$33
CBF8  8d f4 07                STA $07F4
CBFB  9d 80 01                STA $0180,X
CBFE  e8                      INX
CBFF  a9 ff                   LDA #$FF
CC01  9d 80 01                STA $0180,X
CC04  e8                      INX
CC05  86 0c                   STX $0C
CC07  60                      RTS
CC08  a9 d3      sub_CC08:    LDA #$D3
CC0A  85 12                   STA $12
CC0C  a9 ab                   LDA #$AB
CC0E  85 11                   STA $11
CC10  a2 0e                   LDX #$0E
CC12  a0 1a                   LDY #$1A
CC14  20 b3 d6                JSR sub_D6B3
CC17  a9 d3                   LDA #$D3
CC19  85 12                   STA $12
CC1B  a9 ae                   LDA #$AE
CC1D  85 11                   STA $11
CC1F  a2 0e                   LDX #$0E
CC21  a0 1b                   LDY #$1B
CC23  20 b3 d6                JSR sub_D6B3
CC26  60                      RTS
CC27  a0 00      sub_CC27:    LDY #$00
CC29  a9 23                   LDA #$23
CC2B  85 12                   STA $12
CC2D  a9 c0                   LDA #$C0
CC2F  85 11                   STA $11
CC31  20 f6 d8   loc_CC31:    JSR sub_D8F6
CC34  a6 0c                   LDX $0C
CC36  a5 12                   LDA $12
CC38  9d 80 01                STA $0180,X
CC3B  e8                      INX
CC3C  a5 11                   LDA $11
CC3E  9d 80 01                STA $0180,X
CC41  e8                      INX
CC42  b9 c0 07                LDA $07C0,Y
CC45  c8                      INY
CC46  9d 80 01                STA $0180,X
CC49  e8                      INX
CC4A  a9 ff                   LDA #$FF
CC4C  9d 80 01                STA $0180,X
CC4F  e8                      INX
CC50  86 0c                   STX $0C
CC52  a9 01                   LDA #$01
CC54  20 aa d7                JSR sub_D7AA
CC57  c0 40                   CPY #$40
CC59  d0 d6                   BNE loc_CC31
CC5B  60                      RTS
CC5C  a2 00      sub_CC5C:    LDX #$00
CC5E  20 fb d5                JSR sub_D5FB
CC61  85 12                   STA $12
CC63  84 11                   STY $11
CC65  a6 0c                   LDX $0C
CC67  a5 12                   LDA $12
CC69  18                      CLC
CC6A  69 1c                   ADC #$1C
CC6C  9d 80 01                STA $0180,X
CC6F  e8                      INX
CC70  a5 11                   LDA $11
CC72  9d 80 01                STA $0180,X
CC75  e8                      INX
CC76  a0 00                   LDY #$00
CC78  a5 63      loc_CC78:    LDA $63
CC7A  d0 02                   BNE loc_CC7E
CC7C  b1 11                   LDA ($11),Y
CC7E  9d 80 01   loc_CC7E:    STA $0180,X
CC81  e8                      INX
CC82  c8                      INY
CC83  c0 20                   CPY #$20
CC85  d0 f1                   BNE loc_CC78
CC87  a9 ff                   LDA #$FF
CC89  9d 80 01                STA $0180,X
CC8C  e8                      INX
CC8D  86 0c                   STX $0C
CC8F  60                      RTS
CC90  a9 11      sub_CC90:    LDA #$11
CC92  85 63                   STA $63
CC94  a9 00                   LDA #$00
CC96  85 57                   STA $57
CC98  20 f6 d8   loc_CC98:    JSR sub_D8F6
CC9B  a4 57                   LDY $57
CC9D  20 5c cc                JSR sub_CC5C
CCA0  a9 1d                   LDA #$1D
CCA2  38                      SEC
CCA3  e5 57                   SBC $57
CCA5  a8                      TAY
CCA6  20 5c cc                JSR sub_CC5C
CCA9  e6 57                   INC $57
CCAB  a5 57                   LDA $57
CCAD  c9 10                   CMP #$10
CCAF  d0 e7                   BNE loc_CC98
CCB1  60                      RTS
CCB2  a9 00      sub_CCB2:    LDA #$00
CCB4  85 63                   STA $63
CCB6  a9 0f                   LDA #$0F
CCB8  85 57                   STA $57
CCBA  20 f6 d8   loc_CCBA:    JSR sub_D8F6
CCBD  a4 57                   LDY $57
CCBF  20 5c cc                JSR sub_CC5C
CCC2  a9 1d                   LDA #$1D
CCC4  38                      SEC
CCC5  e5 57                   SBC $57
CCC7  a8                      TAY
CCC8  20 5c cc                JSR sub_CC5C
CCCB  c6 57                   DEC $57
CCCD  a5 57                   LDA $57
CCCF  c9 ff                   CMP #$FF
CCD1  d0 e7                   BNE loc_CCBA
CCD3  60                      RTS
CCD4  20 f7 ce   sub_CCD4:    JSR sub_CEF7
CCD7  a2 1e                   LDX #$1E
CCD9  20 76 d2                JSR sub_D276
CCDC  a5 73                   LDA $73
CCDE  18                      CLC
CCDF  65 74                   ADC $74
CCE1  18                      CLC
CCE2  65 75                   ADC $75
CCE4  18                      CLC
CCE5  65 76                   ADC $76
CCE7  85 7d                   STA $7D
CCE9  a5 77                   LDA $77
CCEB  18                      CLC
CCEC  65 78                   ADC $78
CCEE  18                      CLC
CCEF  65 79                   ADC $79
CCF1  18                      CLC
CCF2  65 7a                   ADC $7A
CCF4  85 7e                   STA $7E
CCF6  a9 00                   LDA #$00
CCF8  85 5a                   STA $5A
CCFA  20 f6 d8   sub_CCFA:    JSR sub_D8F6
CCFD  20 b8 d0                JSR sub_D0B8
CD00  a2 25                   LDX #$25
CD02  20 fe d9                JSR sub_D9FE
CD05  a2 2d                   LDX #$2D
CD07  20 fe d9                JSR sub_D9FE
CD0A  a9 00                   LDA #$00
CD0C  85 5d                   STA $5D
CD0E  85 5e                   STA $5E
CD10  20 f6 d8   sub_CD10:    JSR sub_D8F6
CD13  20 b8 d0                JSR sub_D0B8
CD16  a9 00                   LDA #$00
CD18  85 7c                   STA $7C
CD1A  a6 5a                   LDX $5A
CD1C  bd d1 d3                LDA $D3D1,X
CD1F  20 e1 d9                JSR sub_D9E1
CD22  a6 5a                   LDX $5A
CD24  b5 73                   LDA $73,X
CD26  f0 18                   BEQ loc_CD40
CD28  a9 01                   LDA #$01
CD2A  8d 13 03                STA $0313
CD2D  8d 14 03                STA $0314
CD30  d6 73                   DEC $73,X
CD32  e6 5d                   INC $5D
CD34  a2 02                   LDX #$02
CD36  20 be d9                JSR sub_D9BE
CD39  a9 01                   LDA #$01
CD3B  85 7c                   STA $7C
CD3D  20 38 d1                JSR sub_D138
CD40  a6 5a      loc_CD40:    LDX $5A
CD42  b5 77                   LDA $77,X
CD44  f0 18                   BEQ loc_CD5E
CD46  a9 01                   LDA #$01
CD48  8d 13 03                STA $0313
CD4B  8d 14 03                STA $0314
CD4E  d6 77                   DEC $77,X
CD50  e6 5e                   INC $5E
CD52  a2 03                   LDX #$03
CD54  20 be d9                JSR sub_D9BE
CD57  a9 01                   LDA #$01
CD59  85 7c                   STA $7C
CD5B  20 38 d1                JSR sub_D138
CD5E  a0 16      loc_CD5E:    LDY #$16
CD60  a2 05                   LDX #$05
CD62  20 34 d9                JSR sub_D934
CD65  a0 09                   LDY #$09
CD67  20 dd d6                JSR sub_D6DD
CD6A  a2 01                   LDX #$01
CD6C  a0 26                   LDY #$26
CD6E  20 34 d9                JSR sub_D934
CD71  a5 5a                   LDA $5A
CD73  0a                      ASL A
CD74  18                      CLC
CD75  65 5a                   ADC $5A
CD77  18                      CLC
CD78  69 0c                   ADC #$0C
CD7A  a8                      TAY
CD7B  20 dd d6                JSR sub_D6DD
CD7E  a6 5a                   LDX $5A
CD80  a5 5d                   LDA $5D
CD82  20 13 da                JSR sub_DA13
CD85  a2 08                   LDX #$08
CD87  a0 36                   LDY #$36
CD89  20 34 d9                JSR sub_D934
CD8C  a5 5a                   LDA $5A
CD8E  0a                      ASL A
CD8F  18                      CLC
CD90  65 5a                   ADC $5A
CD92  18                      CLC
CD93  69 0c                   ADC #$0C
CD95  a8                      TAY
CD96  20 dd d6                JSR sub_D6DD
CD99  a5 83                   LDA $83
CD9B  f0 3b                   BEQ loc_CDD8
CD9D  a0 1e                   LDY #$1E
CD9F  a2 17                   LDX #$17
CDA1  20 34 d9                JSR sub_D934
CDA4  a0 09                   LDY #$09
CDA6  20 dd d6                JSR sub_D6DD
CDA9  a2 13                   LDX #$13
CDAB  a0 2e                   LDY #$2E
CDAD  20 34 d9                JSR sub_D934
CDB0  a5 5a                   LDA $5A
CDB2  0a                      ASL A
CDB3  18                      CLC
CDB4  65 5a                   ADC $5A
CDB6  18                      CLC
CDB7  69 0c                   ADC #$0C
CDB9  a8                      TAY
CDBA  20 dd d6                JSR sub_D6DD
CDBD  a6 5a                   LDX $5A
CDBF  a5 5e                   LDA $5E
CDC1  20 13 da                JSR sub_DA13
CDC4  a2 0e                   LDX #$0E
CDC6  a0 36                   LDY #$36
CDC8  20 34 d9                JSR sub_D934
CDCB  a5 5a                   LDA $5A
CDCD  0a                      ASL A
CDCE  18                      CLC
CDCF  65 5a                   ADC $5A
CDD1  18                      CLC
CDD2  69 0c                   ADC #$0C
CDD4  a8                      TAY
CDD5  20 dd d6                JSR sub_D6DD
CDD8  a2 08      loc_CDD8:    LDX #$08
CDDA  20 76 d2                JSR sub_D276
CDDD  a5 7c                   LDA $7C
CDDF  f0 03                   BEQ loc_CDE4
CDE1  4c 10 cd                JMP sub_CD10
CDE4  e6 5a      loc_CDE4:    INC $5A
CDE6  a5 5a                   LDA $5A
CDE8  c9 04                   CMP #$04
CDEA  f0 08                   BEQ loc_CDF4
CDEC  a2 14                   LDX #$14
CDEE  20 76 d2                JSR sub_D276
CDF1  4c fa cc                JMP sub_CCFA
CDF4  a2 1e      loc_CDF4:    LDX #$1E
CDF6  20 76 d2                JSR sub_D276
CDF9  a5 7d                   LDA $7D
CDFB  20 13 da                JSR sub_DA13
CDFE  a0 36                   LDY #$36
CE00  a2 08                   LDX #$08
CE02  20 34 d9                JSR sub_D934
CE05  a0 17                   LDY #$17
CE07  20 dd d6                JSR sub_D6DD
CE0A  a5 83                   LDA $83
CE0C  f0 11                   BEQ loc_CE1F
CE0E  a5 7e                   LDA $7E
CE10  20 13 da                JSR sub_DA13
CE13  a0 36                   LDY #$36
CE15  a2 0e                   LDX #$0E
CE17  20 34 d9                JSR sub_D934
CE1A  a0 17                   LDY #$17
CE1C  20 dd d6                JSR sub_D6DD
CE1F  a2 0f      loc_CE1F:    LDX #$0F
CE21  20 76 d2                JSR sub_D276
CE24  a5 83                   LDA $83
CE26  d0 03                   BNE loc_CE2B
CE28  4c e5 ce                JMP sub_CEE5
CE2B  a5 68      loc_CE2B:    LDA $68
CE2D  d0 03                   BNE loc_CE32
CE2F  4c e5 ce                JMP sub_CEE5
CE32  a5 7e      loc_CE32:    LDA $7E
CE34  c5 7d                   CMP $7D
CE36  b0 55                   BCS loc_CE8D
CE38  a5 51                   LDA $51
CE3A  f0 51                   BEQ loc_CE8D
CE3C  a9 00                   LDA #$00
CE3E  20 e1 d9                JSR sub_D9E1
CE41  a2 00                   LDX #$00
CE43  20 be d9                JSR sub_D9BE
CE46  a0 16                   LDY #$16
CE48  a2 05                   LDX #$05
CE4A  20 34 d9                JSR sub_D934
CE4D  a0 09                   LDY #$09
CE4F  20 dd d6                JSR sub_D6DD
CE52  a0 36                   LDY #$36
CE54  a2 01                   LDX #$01
CE56  20 34 d9                JSR sub_D934
CE59  a0 1a                   LDY #$1A
CE5B  20 dd d6                JSR sub_D6DD
CE5E  a9 d3                   LDA #$D3
CE60  85 12                   STA $12
CE62  a9 c4                   LDA #$C4
CE64  85 11                   STA $11
CE66  a2 03                   LDX #$03
CE68  a0 19                   LDY #$19
CE6A  20 b3 d6                JSR sub_D6B3
CE6D  a9 d3                   LDA #$D3
CE6F  85 12                   STA $12
CE71  a9 5e                   LDA #$5E
CE73  85 11                   STA $11
CE75  a2 08                   LDX #$08
CE77  a0 1a                   LDY #$1A
CE79  20 b3 d6                JSR sub_D6B3
CE7C  a9 01                   LDA #$01
CE7E  8d 1b 03                STA $031B
CE81  8d 1c 03                STA $031C
CE84  8d 1d 03                STA $031D
CE87  20 38 d1                JSR sub_D138
CE8A  4c e5 ce                JMP sub_CEE5
CE8D  a5 7d      loc_CE8D:    LDA $7D
CE8F  c5 7e                   CMP $7E
CE91  b0 52                   BCS sub_CEE5
CE93  a5 52                   LDA $52
CE95  f0 4e                   BEQ sub_CEE5
CE97  a9 00                   LDA #$00
CE99  20 e1 d9                JSR sub_D9E1
CE9C  a2 01                   LDX #$01
CE9E  20 be d9                JSR sub_D9BE
CEA1  a0 1e                   LDY #$1E
CEA3  a2 17                   LDX #$17
CEA5  20 34 d9                JSR sub_D934
CEA8  a0 09                   LDY #$09
CEAA  20 dd d6                JSR sub_D6DD
CEAD  a0 36                   LDY #$36
CEAF  a2 14                   LDX #$14
CEB1  20 34 d9                JSR sub_D934
CEB4  a0 1a                   LDY #$1A
CEB6  20 dd d6                JSR sub_D6DD
CEB9  a9 d3                   LDA #$D3
CEBB  85 12                   STA $12
CEBD  a9 c4                   LDA #$C4
CEBF  85 11                   STA $11
CEC1  a2 16                   LDX #$16
CEC3  a0 19                   LDY #$19
CEC5  20 b3 d6                JSR sub_D6B3
CEC8  a9 d3                   LDA #$D3
CECA  85 12                   STA $12
CECC  a9 5e                   LDA #$5E
CECE  85 11                   STA $11
CED0  a2 1b                   LDX #$1B
CED2  a0 1a                   LDY #$1A
CED4  20 b3 d6                JSR sub_D6B3
CED7  a9 01                   LDA #$01
CED9  8d 1b 03                STA $031B
CEDC  8d 1c 03                STA $031C
CEDF  8d 1d 03                STA $031D
CEE2  20 38 d1                JSR sub_D138
CEE5  a2 78      sub_CEE5:    LDX #$78
CEE7  20 76 d2                JSR sub_D276
CEEA  a9 00                   LDA #$00
CEEC  85 50                   STA $50
CEEE  85 60                   STA $60
CEF0  85 6b                   STA $6B
CEF2  a9 00                   LDA #$00
CEF4  85 4d                   STA $4D
CEF6  60                      RTS
CEF7  20 f6 d8   sub_CEF7:    JSR sub_D8F6
CEFA  a9 01                   LDA #$01
CEFC  85 6b                   STA $6B
CEFE  a9 24                   LDA #$24
CF00  85 05                   STA $05
CF02  a9 00                   LDA #$00
CF04  85 4f                   STA $4F
CF06  a9 02                   LDA #$02
CF08  85 50                   STA $50
CF0A  a9 30                   LDA #$30
CF0C  85 60                   STA $60
CF0E  a9 03                   LDA #$03
CF10  85 4d                   STA $4D
CF12  20 70 d4                JSR sub_D470
CF15  20 7e d4                JSR sub_D47E
CF18  20 d9 d0                JSR sub_D0D9
CF1B  20 b4 d7                JSR sub_D7B4
CF1E  20 67 d4                JSR sub_D467
CF21  a9 d2                   LDA #$D2
CF23  85 12                   STA $12
CF25  a9 bd                   LDA #$BD
CF27  85 11                   STA $11
CF29  a2 08                   LDX #$08
CF2B  a0 03                   LDY #$03
CF2D  20 b3 d6                JSR sub_D6B3
CF30  a0 3e                   LDY #$3E
CF32  a2 12                   LDX #$12
CF34  20 34 d9                JSR sub_D934
CF37  a0 03                   LDY #$03
CF39  20 dd d6                JSR sub_D6DD
CF3C  a9 d3                   LDA #$D3
CF3E  85 12                   STA $12
CF40  a9 cb                   LDA #$CB
CF42  85 11                   STA $11
CF44  a2 0c                   LDX #$0C
CF46  a0 05                   LDY #$05
CF48  20 b3 d6                JSR sub_D6B3
CF4B  a5 85                   LDA $85
CF4D  20 13 da                JSR sub_DA13
CF50  a0 36                   LDY #$36
CF52  a2 0e                   LDX #$0E
CF54  20 34 d9                JSR sub_D934
CF57  a0 05                   LDY #$05
CF59  20 dd d6                JSR sub_D6DD
CF5C  20 f6 d8                JSR sub_D8F6
CF5F  a9 d2                   LDA #$D2
CF61  85 12                   STA $12
CF63  a9 d9                   LDA #$D9
CF65  85 11                   STA $11
CF67  a2 03                   LDX #$03
CF69  a0 07                   LDY #$07
CF6B  20 b3 d6                JSR sub_D6B3
CF6E  a0 16                   LDY #$16
CF70  a2 05                   LDX #$05
CF72  20 34 d9                JSR sub_D934
CF75  a0 09                   LDY #$09
CF77  20 dd d6                JSR sub_D6DD
CF7A  a9 d3                   LDA #$D3
CF7C  85 12                   STA $12
CF7E  a9 b1                   LDA #$B1
CF80  85 11                   STA $11
CF82  a2 0e                   LDX #$0E
CF84  a0 0c                   LDY #$0C
CF86  20 b3 d6                JSR sub_D6B3
CF89  a9 d3                   LDA #$D3
CF8B  85 12                   STA $12
CF8D  a9 b1                   LDA #$B1
CF8F  85 11                   STA $11
CF91  a2 0e                   LDX #$0E
CF93  a0 0f                   LDY #$0F
CF95  20 b3 d6                JSR sub_D6B3
CF98  a9 d3                   LDA #$D3
CF9A  85 12                   STA $12
CF9C  a9 b1                   LDA #$B1
CF9E  85 11                   STA $11
CFA0  a2 0e                   LDX #$0E
CFA2  a0 12                   LDY #$12
CFA4  20 b3 d6                JSR sub_D6B3
CFA7  a9 d3                   LDA #$D3
CFA9  85 12                   STA $12
CFAB  a9 b1                   LDA #$B1
CFAD  85 11                   STA $11
CFAF  a2 0e                   LDX #$0E
CFB1  a0 15                   LDY #$15
CFB3  20 b3 d6                JSR sub_D6B3
CFB6  a5 83                   LDA $83
CFB8  f0 5a                   BEQ loc_D014
CFBA  20 f6 d8                JSR sub_D8F6
CFBD  a9 d2                   LDA #$D2
CFBF  85 12                   STA $12
CFC1  a9 e2                   LDA #$E2
CFC3  85 11                   STA $11
CFC5  a2 15                   LDX #$15
CFC7  a0 07                   LDY #$07
CFC9  20 b3 d6                JSR sub_D6B3
CFCC  a0 1e                   LDY #$1E
CFCE  a2 17                   LDX #$17
CFD0  20 34 d9                JSR sub_D934
CFD3  a0 09                   LDY #$09
CFD5  20 dd d6                JSR sub_D6DD
CFD8  a9 d3                   LDA #$D3
CFDA  85 12                   STA $12
CFDC  a9 b3                   LDA #$B3
CFDE  85 11                   STA $11
CFE0  a2 11                   LDX #$11
CFE2  a0 0c                   LDY #$0C
CFE4  20 b3 d6                JSR sub_D6B3
CFE7  a9 d3                   LDA #$D3
CFE9  85 12                   STA $12
CFEB  a9 b3                   LDA #$B3
CFED  85 11                   STA $11
CFEF  a2 11                   LDX #$11
CFF1  a0 0f                   LDY #$0F
CFF3  20 b3 d6                JSR sub_D6B3
CFF6  a9 d3                   LDA #$D3
CFF8  85 12                   STA $12
CFFA  a9 b3                   LDA #$B3
CFFC  85 11                   STA $11
CFFE  a2 11                   LDX #$11
D000  a0 12                   LDY #$12
D002  20 b3 d6                JSR sub_D6B3
D005  a9 d3                   LDA #$D3
D007  85 12                   STA $12
D009  a9 b3                   LDA #$B3
D00B  85 11                   STA $11
D00D  a2 11                   LDX #$11
D00F  a0 15                   LDY #$15
D011  20 b3 d6                JSR sub_D6B3
D014  20 f6 d8   loc_D014:    JSR sub_D8F6
D017  a9 d3                   LDA #$D3
D019  85 12                   STA $12
D01B  a9 5e                   LDA #$5E
D01D  85 11                   STA $11
D01F  a2 08                   LDX #$08
D021  a0 0c                   LDY #$0C
D023  20 b3 d6                JSR sub_D6B3
D026  a9 d3                   LDA #$D3
D028  85 12                   STA $12
D02A  a9 5e                   LDA #$5E
D02C  85 11                   STA $11
D02E  a2 08                   LDX #$08
D030  a0 0f                   LDY #$0F
D032  20 b3 d6                JSR sub_D6B3
D035  a9 d3                   LDA #$D3
D037  85 12                   STA $12
D039  a9 5e                   LDA #$5E
D03B  85 11                   STA $11
D03D  a2 08                   LDX #$08
D03F  a0 12                   LDY #$12
D041  20 b3 d6                JSR sub_D6B3
D044  a9 d3                   LDA #$D3
D046  85 12                   STA $12
D048  a9 5e                   LDA #$5E
D04A  85 11                   STA $11
D04C  a2 08                   LDX #$08
D04E  a0 15                   LDY #$15
D050  20 b3 d6                JSR sub_D6B3
D053  a5 83                   LDA $83
D055  f0 3f                   BEQ loc_D096
D057  20 f6 d8                JSR sub_D8F6
D05A  a9 d3                   LDA #$D3
D05C  85 12                   STA $12
D05E  a9 5e                   LDA #$5E
D060  85 11                   STA $11
D062  a2 1a                   LDX #$1A
D064  a0 0c                   LDY #$0C
D066  20 b3 d6                JSR sub_D6B3
D069  a9 d3                   LDA #$D3
D06B  85 12                   STA $12
D06D  a9 5e                   LDA #$5E
D06F  85 11                   STA $11
D071  a2 1a                   LDX #$1A
D073  a0 0f                   LDY #$0F
D075  20 b3 d6                JSR sub_D6B3
D078  a9 d3                   LDA #$D3
D07A  85 12                   STA $12
D07C  a9 5e                   LDA #$5E
D07E  85 11                   STA $11
D080  a2 1a                   LDX #$1A
D082  a0 12                   LDY #$12
D084  20 b3 d6                JSR sub_D6B3
D087  a9 d3                   LDA #$D3
D089  85 12                   STA $12
D08B  a9 5e                   LDA #$5E
D08D  85 11                   STA $11
D08F  a2 1a                   LDX #$1A
D091  a0 15                   LDY #$15
D093  20 b3 d6                JSR sub_D6B3
D096  20 f6 d8   loc_D096:    JSR sub_D8F6
D099  a9 d3                   LDA #$D3
D09B  85 12                   STA $12
D09D  a9 bb                   LDA #$BB
D09F  85 11                   STA $11
D0A1  a2 0c                   LDX #$0C
D0A3  a0 16                   LDY #$16
D0A5  20 b3 d6                JSR sub_D6B3
D0A8  a9 d3                   LDA #$D3
D0AA  85 12                   STA $12
D0AC  a9 b5                   LDA #$B5
D0AE  85 11                   STA $11
D0B0  a2 06                   LDX #$06
D0B2  a0 17                   LDY #$17
D0B4  20 b3 d6                JSR sub_D6B3
D0B7  60                      RTS
D0B8  a9 02      sub_D0B8:    LDA #$02
D0BA  85 04                   STA $04
D0BC  a0 64                   LDY #$64
D0BE  a9 80                   LDA #$80
D0C0  20 30 d1                JSR sub_D130
D0C3  a0 7c                   LDY #$7C
D0C5  a9 a0                   LDA #$A0
D0C7  20 30 d1                JSR sub_D130
D0CA  a0 94                   LDY #$94
D0CC  a9 c0                   LDA #$C0
D0CE  20 30 d1                JSR sub_D130
D0D1  a0 ac                   LDY #$AC
D0D3  a9 e0                   LDA #$E0
D0D5  20 30 d1                JSR sub_D130
D0D8  60                      RTS
D0D9  a9 50      sub_D0D9:    LDA #$50
D0DB  8d c0 07                STA $07C0
D0DE  8d c1 07                STA $07C1
D0E1  8d c2 07                STA $07C2
D0E4  8d c3 07                STA $07C3
D0E7  8d c8 07                STA $07C8
D0EA  8d c9 07                STA $07C9
D0ED  8d ca 07                STA $07CA
D0F0  8d cd 07                STA $07CD
D0F3  8d ce 07                STA $07CE
D0F6  8d cf 07                STA $07CF
D0F9  a9 a0                   LDA #$A0
D0FB  8d c4 07                STA $07C4
D0FE  8d c5 07                STA $07C5
D101  8d c6 07                STA $07C6
D104  8d c7 07                STA $07C7
D107  a9 0a                   LDA #$0A
D109  8d d0 07                STA $07D0
D10C  8d d1 07                STA $07D1
D10F  8d d2 07                STA $07D2
D112  8d d5 07                STA $07D5
D115  8d d6 07                STA $07D6
D118  8d d7 07                STA $07D7
D11B  a9 05                   LDA #$05
D11D  8d f0 07                STA $07F0
D120  8d f1 07                STA $07F1
D123  8d f2 07                STA $07F2
D126  8d f5 07                STA $07F5
D129  8d f6 07                STA $07F6
D12C  8d f7 07                STA $07F7
D12F  60                      RTS
D130  85 53      sub_D130:    STA $53
D132  a2 81                   LDX #$81
D134  20 7b da                JSR sub_DA7B
D137  60                      RTS
D138  a5 68      sub_D138:    LDA $68
D13A  c9 80                   CMP #$80
D13C  d0 2b                   BNE loc_D169
D13E  a5 66                   LDA $66
D140  d0 0d                   BNE loc_D14F
D142  a5 17                   LDA $17
D144  c9 02                   CMP #$02
D146  90 07                   BCC loc_D14F
D148  e6 51                   INC $51
D14A  e6 66                   INC $66
D14C  4c 61 d1                JMP sub_D161
D14F  a5 83      loc_D14F:    LDA $83
D151  f0 16                   BEQ loc_D169
D153  a5 67                   LDA $67
D155  d0 12                   BNE loc_D169
D157  a5 1f                   LDA $1F
D159  c9 02                   CMP #$02
D15B  90 0c                   BCC loc_D169
D15D  e6 52                   INC $52
D15F  e6 67                   INC $67
D161  a9 01      sub_D161:    LDA #$01
D163  8d 04 03                STA $0304
D166  8d 05 03                STA $0305
D169  60         loc_D169:    RTS
D16A  20 70 d4   sub_D16A:    JSR sub_D470
D16D  a9 03                   LDA #$03
D16F  85 4d                   STA $4D
D171  a9 1c                   LDA #$1C
D173  85 05                   STA $05
D175  20 7e d4                JSR sub_D47E
D178  20 b4 d7                JSR sub_D7B4
D17B  20 67 d4                JSR sub_D467
D17E  60                      RTS
D17F  20 70 d4   sub_D17F:    JSR sub_D470
D182  a9 24                   LDA #$24
D184  85 05                   STA $05
D186  20 7e d4                JSR sub_D47E
D189  a2 1a                   LDX #$1A
D18B  86 56                   STX $56
D18D  a0 2e                   LDY #$2E
D18F  84 57                   STY $57
D191  a9 d2                   LDA #$D2
D193  85 14                   STA $14
D195  a9 99                   LDA #$99
D197  85 13                   STA $13
D199  20 d2 d8                JSR sub_D8D2
D19C  a2 3c                   LDX #$3C
D19E  86 56                   STX $56
D1A0  a0 56                   LDY #$56
D1A2  84 57                   STY $57
D1A4  a9 d2                   LDA #$D2
D1A6  85 14                   STA $14
D1A8  a9 a0                   LDA #$A0
D1AA  85 13                   STA $13
D1AC  20 d2 d8                JSR sub_D8D2
D1AF  20 b4 d7                JSR sub_D7B4
D1B2  20 67 d4                JSR sub_D467
D1B5  a9 30                   LDA #$30
D1B7  85 60                   STA $60
D1B9  a9 d2                   LDA #$D2
D1BB  85 12                   STA $12
D1BD  a9 a5                   LDA #$A5
D1BF  85 11                   STA $11
D1C1  a2 02                   LDX #$02
D1C3  a0 03                   LDY #$03
D1C5  20 b3 d6                JSR sub_D6B3
D1C8  a0 16                   LDY #$16
D1CA  a2 04                   LDX #$04
D1CC  20 34 d9                JSR sub_D934
D1CF  a0 03                   LDY #$03
D1D1  20 dd d6                JSR sub_D6DD
D1D4  a9 d2                   LDA #$D2
D1D6  85 12                   STA $12
D1D8  a9 b1                   LDA #$B1
D1DA  85 11                   STA $11
D1DC  a2 0b                   LDX #$0B
D1DE  a0 03                   LDY #$03
D1E0  20 b3 d6                JSR sub_D6B3
D1E3  a0 3e                   LDY #$3E
D1E5  a2 0e                   LDX #$0E
D1E7  20 34 d9                JSR sub_D934
D1EA  a0 03                   LDY #$03
D1EC  20 dd d6                JSR sub_D6DD
D1EF  a5 83                   LDA $83
D1F1  f0 1b                   BEQ loc_D20E
D1F3  a9 d2                   LDA #$D2
D1F5  85 12                   STA $12
D1F7  a9 a8                   LDA #$A8
D1F9  85 11                   STA $11
D1FB  a2 15                   LDX #$15
D1FD  a0 03                   LDY #$03
D1FF  20 b3 d6                JSR sub_D6B3
D202  a0 1e                   LDY #$1E
D204  a2 17                   LDX #$17
D206  20 34 d9                JSR sub_D934
D209  a0 03                   LDY #$03
D20B  20 dd d6                JSR sub_D6DD
D20E  a9 00      loc_D20E:    LDA #$00
D210  85 60                   STA $60
D212  20 f6 d8                JSR sub_D8F6
D215  a9 d2                   LDA #$D2
D217  85 12                   STA $12
D219  a9 c6                   LDA #$C6
D21B  85 11                   STA $11
D21D  a2 0b                   LDX #$0B
D21F  a0 11                   LDY #$11
D221  20 b3 d6                JSR sub_D6B3
D224  a9 d2                   LDA #$D2
D226  85 12                   STA $12
D228  a9 cf                   LDA #$CF
D22A  85 11                   STA $11
D22C  a2 0b                   LDX #$0B
D22E  a0 13                   LDY #$13
D230  20 b3 d6                JSR sub_D6B3
D233  a9 d2                   LDA #$D2
D235  85 12                   STA $12
D237  a9 eb                   LDA #$EB
D239  85 11                   STA $11
D23B  a2 0b                   LDX #$0B
D23D  a0 15                   LDY #$15
D23F  20 b3 d6                JSR sub_D6B3
D242  20 f6 d8                JSR sub_D8F6
D245  a9 d2                   LDA #$D2
D247  85 12                   STA $12
D249  a9 8f                   LDA #$8F
D24B  85 11                   STA $11
D24D  a2 0b                   LDX #$0B
D24F  a0 17                   LDY #$17
D251  20 b3 d6                JSR sub_D6B3
D254  a9 d2                   LDA #$D2
D256  85 12                   STA $12
D258  a9 f8                   LDA #$F8
D25A  85 11                   STA $11
D25C  a2 04                   LDX #$04
D25E  a0 19                   LDY #$19
D260  20 b3 d6                JSR sub_D6B3
D263  20 f6 d8                JSR sub_D8F6
D266  a9 d3                   LDA #$D3
D268  85 12                   STA $12
D26A  a9 20                   LDA #$20
D26C  85 11                   STA $11
D26E  a2 06                   LDX #$06
D270  a0 1b                   LDY #$1B
D272  20 b3 d6                JSR sub_D6B3
D275  60                      RTS
D276  20 f6 d8   sub_D276:    JSR sub_D8F6
D279  8a                      TXA
D27A  48                      PHA
D27B  20 b8 d0                JSR sub_D0B8
D27E  68                      PLA
D27F  aa                      TAX
D280  ca                      DEX
D281  d0 f3                   BNE sub_D276
D283  60                      RTS

; ---- $D284..$D3FF (380 bytes: data) ----
D400  48         nmi:         PHA
D401  8a                      TXA
D402  48                      PHA
D403  98                      TYA
D404  48                      PHA
D405  08                      PHP
D406  a9 00                   LDA #$00
D408  8d 03 20                STA $2003  ; OAMADDR
D40B  a9 02                   LDA #$02
D40D  8d 14 40                STA $4014  ; OAMDMA
D410  ad 02 20                LDA $2002  ; PPUSTATUS
D413  20 fd d8                JSR sub_D8FD
D416  a5 4d                   LDA $4D
D418  30 03                   BMI loc_D41D
D41A  20 0e d5                JSR sub_D50E
D41D  a5 50      loc_D41D:    LDA $50
D41F  09 b0                   ORA #$B0
D421  8d 00 20                STA $2000  ; PPUCTRL
D424  a9 00                   LDA #$00
D426  8d 05 20                STA $2005  ; PPUSCROLL
D429  a5 4f                   LDA $4F
D42B  8d 05 20                STA $2005  ; PPUSCROLL
D42E  a9 1e                   LDA #$1E
D430  8d 01 20                STA $2001  ; PPUMASK
D433  20 89 d6                JSR sub_D689
D436  20 93 da                JSR sub_DA93
D439  20 7e ea                JSR sub_EA7E
D43C  e6 0b                   INC $0B
D43E  a5 0b                   LDA $0B
D440  29 3f                   AND #$3F
D442  d0 02                   BNE loc_D446
D444  e6 0a                   INC $0A
D446  28         loc_D446:    PLP
D447  68                      PLA
D448  a8                      TAY
D449  68                      PLA
D44A  aa                      TAX
D44B  68                      PLA
D44C  40                      RTI
D44D  8a         sub_D44D:    TXA
D44E  48                      PHA
D44F  a5 0f                   LDA $0F
D451  0a                      ASL A
D452  0a                      ASL A
D453  0a                      ASL A
D454  38                      SEC
D455  e5 0f                   SBC $0F
D457  18                      CLC
D458  65 0a                   ADC $0A
D45A  e6 10                   INC $10
D45C  a6 10                   LDX $10
D45E  75 00                   ADC $00,X
D460  85 0f                   STA $0F
D462  68                      PLA
D463  aa                      TAX
D464  a5 0f                   LDA $0F
D466  60                      RTS
D467  20 f5 d5   sub_D467:    JSR sub_D5F5
D46A  a9 b0                   LDA #$B0
D46C  8d 00 20                STA $2000  ; PPUCTRL
D46F  60                      RTS
D470  20 f6 d8   sub_D470:    JSR sub_D8F6
D473  a9 10                   LDA #$10
D475  8d 00 20                STA $2000  ; PPUCTRL
D478  a9 06                   LDA #$06
D47A  8d 01 20                STA $2001  ; PPUMASK
D47D  60                      RTS
D47E  a9 00      sub_D47E:    LDA #$00
D480  aa                      TAX
D481  9d 00 04   loc_D481:    STA $0400,X
D484  9d 00 05                STA $0500,X
D487  9d 00 06                STA $0600,X
D48A  9d 00 07                STA $0700,X
D48D  e8                      INX
D48E  d0 f1                   BNE loc_D481
D490  60                      RTS
D491  a9 00      sub_D491:    LDA #$00
D493  85 60                   STA $60
D495  85 6b                   STA $6B
D497  85 0c                   STA $0C
D499  85 0d                   STA $0D
D49B  85 6d                   STA $6D
D49D  a9 ff                   LDA #$FF
D49F  85 4d                   STA $4D
D4A1  20 02 d5                JSR sub_D502
D4A4  a9 04                   LDA #$04
D4A6  85 0e                   STA $0E
D4A8  a9 20                   LDA #$20
D4AA  85 6e                   STA $6E
D4AC  20 7e d4                JSR sub_D47E
D4AF  20 93 da                JSR sub_DA93
D4B2  a2 15                   LDX #$15
D4B4  20 fe d9                JSR sub_D9FE
D4B7  a2 1d                   LDX #$1D
D4B9  20 fe d9                JSR sub_D9FE
D4BC  20 ef d4                JSR sub_D4EF
D4BF  d0 0d                   BNE loc_D4CE
D4C1  a2 3d                   LDX #$3D
D4C3  20 fe d9                JSR sub_D9FE
D4C6  a9 02                   LDA #$02
D4C8  85 3f                   STA $3F
D4CA  a9 00                   LDA #$00
D4CC  85 83                   STA $83
D4CE  a9 1c      loc_D4CE:    LDA #$1C
D4D0  85 05                   STA $05
D4D2  20 b4 d7                JSR sub_D7B4
D4D5  a9 24                   LDA #$24
D4D7  85 05                   STA $05
D4D9  20 b4 d7                JSR sub_D7B4
D4DC  20 e3 d4                JSR sub_D4E3
D4DF  20 51 ea                JSR sub_EA51
D4E2  60                      RTS
D4E3  a2 0f      sub_D4E3:    LDX #$0F
D4E5  bd 40 c0   loc_D4E5:    LDA $C040,X
D4E8  9d 10 01                STA $0110,X
D4EB  ca                      DEX
D4EC  10 f7                   BPL loc_D4E5
D4EE  60                      RTS
D4EF  a2 0f      sub_D4EF:    LDX #$0F
D4F1  bd 10 01   loc_D4F1:    LDA $0110,X
D4F4  dd 40 c0                CMP $C040,X
D4F7  d0 06                   BNE loc_D4FF
D4F9  ca                      DEX
D4FA  10 f5                   BPL loc_D4F1
D4FC  a9 01                   LDA #$01
D4FE  60                      RTS
D4FF  a9 00      loc_D4FF:    LDA #$00
D501  60                      RTS
D502  20 f5 d5   sub_D502:    JSR sub_D5F5
D505  20 3e d5                JSR sub_D53E
D508  a9 00                   LDA #$00
D50A  20 0e d5                JSR sub_D50E
D50D  60                      RTS
D50E  0a         sub_D50E:    ASL A
D50F  0a                      ASL A
D510  0a                      ASL A
D511  0a                      ASL A
D512  aa                      TAX
D513  a0 10                   LDY #$10
D515  a9 3f                   LDA #$3F
D517  8d 06 20                STA $2006  ; PPUADDR
D51A  a9 00                   LDA #$00
D51C  8d 06 20                STA $2006  ; PPUADDR
D51F  bd 65 d5   loc_D51F:    LDA $D565,X
D522  8d 07 20                STA $2007  ; PPUDATA
D525  e8                      INX
D526  88                      DEY
D527  d0 f6                   BNE loc_D51F
D529  a9 ff                   LDA #$FF
D52B  85 4d                   STA $4D
D52D  a9 3f                   LDA #$3F
D52F  8d 06 20                STA $2006  ; PPUADDR
D532  a9 00                   LDA #$00
D534  8d 06 20                STA $2006  ; PPUADDR
D537  8d 06 20                STA $2006  ; PPUADDR
D53A  8d 06 20                STA $2006  ; PPUADDR
D53D  60                      RTS
D53E  a2 00      sub_D53E:    LDX #$00
D540  a0 10                   LDY #$10
D542  a9 3f                   LDA #$3F
D544  8d 06 20                STA $2006  ; PPUADDR
D547  8c 06 20                STY $2006  ; PPUADDR
D54A  bd 55 d5   loc_D54A:    LDA $D555,X
D54D  8d 07 20                STA $2007  ; PPUDATA
D550  e8                      INX
D551  88                      DEY
D552  d0 f6                   BNE loc_D54A
D554  60                      RTS

; ---- $D555..$D5F4 (160 bytes: data) ----
D5F5  ad 02 20   sub_D5F5:    LDA $2002  ; PPUSTATUS
D5F8  10 fb                   BPL sub_D5F5
D5FA  60                      RTS
D5FB  a9 00      sub_D5FB:    LDA #$00
D5FD  85 00                   STA $00
D5FF  98                      TYA
D600  4a                      LSR A
D601  66 00                   ROR $00
D603  4a                      LSR A
D604  66 00                   ROR $00
D606  4a                      LSR A
D607  66 00                   ROR $00
D609  48                      PHA
D60A  8a                      TXA
D60B  05 00                   ORA $00
D60D  a8                      TAY
D60E  68                      PLA
D60F  09 04                   ORA #$04
D611  60                      RTS
D612  20 35 d6   sub_D612:    JSR sub_D635
D615  a6 0c                   LDX $0C
D617  a9 23                   LDA #$23
D619  9d 80 01                STA $0180,X
D61C  e8                      INX
D61D  98                      TYA
D61E  18                      CLC
D61F  69 c0                   ADC #$C0
D621  9d 80 01                STA $0180,X
D624  e8                      INX
D625  b9 c0 07                LDA $07C0,Y
D628  9d 80 01                STA $0180,X
D62B  e8                      INX
D62C  a9 ff                   LDA #$FF
D62E  9d 80 01                STA $0180,X
D631  e8                      INX
D632  86 0c                   STX $0C
D634  60                      RTS
D635  a5 04      sub_D635:    LDA $04
D637  20 84 d6                JSR sub_D684
D63A  20 84 d6                JSR sub_D684
D63D  20 84 d6                JSR sub_D684
D640  85 02                   STA $02
D642  98                      TYA
D643  29 02                   AND #$02
D645  d0 0f                   BNE loc_D656
D647  8a                      TXA
D648  29 02                   AND #$02
D64A  f0 05                   BEQ loc_D651
D64C  a9 f3                   LDA #$F3
D64E  4c 62 d6                JMP sub_D662
D651  a9 fc      loc_D651:    LDA #$FC
D653  4c 62 d6                JMP sub_D662
D656  8a         loc_D656:    TXA
D657  29 02                   AND #$02
D659  f0 05                   BEQ loc_D660
D65B  a9 3f                   LDA #$3F
D65D  4c 62 d6                JMP sub_D662
D660  a9 cf      loc_D660:    LDA #$CF
D662  85 01      sub_D662:    STA $01
D664  98                      TYA
D665  0a                      ASL A
D666  29 f8                   AND #$F8
D668  85 00                   STA $00
D66A  8a                      TXA
D66B  4a                      LSR A
D66C  4a                      LSR A
D66D  18                      CLC
D66E  65 00                   ADC $00
D670  a8                      TAY
D671  a5 01                   LDA $01
D673  49 ff                   EOR #$FF
D675  25 02                   AND $02
D677  85 02                   STA $02
D679  b9 c0 07                LDA $07C0,Y
D67C  25 01                   AND $01
D67E  05 02                   ORA $02
D680  99 c0 07                STA $07C0,Y
D683  60                      RTS
D684  0a         sub_D684:    ASL A
D685  0a                      ASL A
D686  05 04                   ORA $04
D688  60                      RTS
D689  a2 01      sub_D689:    LDX #$01
D68B  8e 16 40                STX $4016  ; JOY1
D68E  a0 00                   LDY #$00
D690  8c 16 40                STY $4016  ; JOY1
D693  84 00      loc_D693:    STY $00
D695  a0 08                   LDY #$08
D697  bd 16 40   loc_D697:    LDA $4016,X
D69A  29 03                   AND #$03
D69C  c9 01                   CMP #$01
D69E  66 00                   ROR $00
D6A0  88                      DEY
D6A1  d0 f4                   BNE loc_D697
D6A3  b5 06                   LDA $06,X
D6A5  49 ff                   EOR #$FF
D6A7  25 00                   AND $00
D6A9  95 08                   STA $08,X
D6AB  a5 00                   LDA $00
D6AD  95 06                   STA $06,X
D6AF  ca                      DEX
D6B0  10 e1                   BPL loc_D693
D6B2  60                      RTS
D6B3  20 fb d5   sub_D6B3:    JSR sub_D5FB
D6B6  85 14                   STA $14
D6B8  18                      CLC
D6B9  65 05                   ADC $05
D6BB  a6 0c                   LDX $0C
D6BD  9d 80 01                STA $0180,X
D6C0  e8                      INX
D6C1  98                      TYA
D6C2  9d 80 01                STA $0180,X
D6C5  e8                      INX
D6C6  85 13                   STA $13
D6C8  a0 00                   LDY #$00
D6CA  b1 11      sub_D6CA:    LDA ($11),Y
D6CC  9d 80 01                STA $0180,X
D6CF  e8                      INX
D6D0  c9 ff                   CMP #$FF
D6D2  f0 06                   BEQ loc_D6DA
D6D4  91 13                   STA ($13),Y
D6D6  c8                      INY
D6D7  4c ca d6                JMP sub_D6CA
D6DA  86 0c      loc_D6DA:    STX $0C
D6DC  60                      RTS
D6DD  20 fb d5   sub_D6DD:    JSR sub_D5FB
D6E0  18                      CLC
D6E1  65 05                   ADC $05
D6E3  a6 0c                   LDX $0C
D6E5  9d 80 01                STA $0180,X
D6E8  e8                      INX
D6E9  98                      TYA
D6EA  9d 80 01                STA $0180,X
D6ED  e8                      INX
D6EE  a0 00                   LDY #$00
D6F0  b1 11      sub_D6F0:    LDA ($11),Y
D6F2  30 03                   BMI loc_D6F7
D6F4  18                      CLC
D6F5  65 60                   ADC $60
D6F7  9d 80 01   loc_D6F7:    STA $0180,X
D6FA  e8                      INX
D6FB  c9 ff                   CMP #$FF
D6FD  f0 04                   BEQ loc_D703
D6FF  c8                      INY
D700  4c f0 d6                JMP sub_D6F0
D703  86 0c      loc_D703:    STX $0C
D705  60                      RTS
D706  20 13 d7   sub_D706:    JSR sub_D713
D709  20 fb d5   sub_D709:    JSR sub_D5FB
D70C  85 12                   STA $12
D70E  84 11                   STY $11
D710  a0 00                   LDY #$00
D712  60                      RTS
D713  98         sub_D713:    TYA
D714  4a                      LSR A
D715  4a                      LSR A
D716  4a                      LSR A
D717  a8                      TAY
D718  8a                      TXA
D719  4a                      LSR A
D71A  4a                      LSR A
D71B  4a                      LSR A
D71C  aa                      TAX
D71D  60                      RTS
D71E  86 47      sub_D71E:    STX $47
D720  84 48                   STY $48
D722  20 06 d7                JSR sub_D706
D725  a9 01      sub_D725:    LDA #$01
D727  85 00                   STA $00
D729  a5 48                   LDA $48
D72B  29 04                   AND #$04
D72D  f0 04                   BEQ loc_D733
D72F  06 00                   ASL $00
D731  06 00                   ASL $00
D733  a5 47      loc_D733:    LDA $47
D735  29 04                   AND #$04
D737  f0 02                   BEQ loc_D73B
D739  06 00                   ASL $00
D73B  60         loc_D73B:    RTS
D73C  a5 00      sub_D73C:    LDA $00
D73E  09 f0                   ORA #$F0
D740  31 11                   AND ($11),Y
D742  60                      RTS
D743  a5 00      sub_D743:    LDA $00
D745  49 ff                   EOR #$FF
D747  31 11                   AND ($11),Y
D749  20 84 d7                JSR sub_D784
D74C  60                      RTS
D74D  b1 11      sub_D74D:    LDA ($11),Y
D74F  29 f0                   AND #$F0
D751  d0 08                   BNE loc_D75B
D753  a5 00                   LDA $00
D755  49 ff                   EOR #$FF
D757  31 11                   AND ($11),Y
D759  91 11                   STA ($11),Y
D75B  60         loc_D75B:    RTS

; ---- $D75C..$D763 (8 bytes: data) ----
D764  b1 11      sub_D764:    LDA ($11),Y
D766  29 f0                   AND #$F0
D768  d0 06                   BNE loc_D770
D76A  a5 00                   LDA $00
D76C  11 11                   ORA ($11),Y
D76E  91 11                   STA ($11),Y
D770  60         loc_D770:    RTS
D771  a5 12      sub_D771:    LDA $12
D773  18                      CLC
D774  65 05                   ADC $05
D776  8d 06 20                STA $2006  ; PPUADDR
D779  a5 11                   LDA $11
D77B  8d 06 20                STA $2006  ; PPUADDR
D77E  b1 11                   LDA ($11),Y
D780  8d 07 20                STA $2007  ; PPUDATA
D783  60                      RTS
D784  91 11      sub_D784:    STA ($11),Y
D786  86 47                   STX $47
D788  a6 0c                   LDX $0C
D78A  a5 12                   LDA $12
D78C  18                      CLC
D78D  69 1c                   ADC #$1C
D78F  9d 80 01                STA $0180,X
D792  e8                      INX
D793  a5 11                   LDA $11
D795  9d 80 01                STA $0180,X
D798  e8                      INX
D799  b1 11                   LDA ($11),Y
D79B  9d 80 01                STA $0180,X
D79E  e8                      INX
D79F  a9 ff                   LDA #$FF
D7A1  9d 80 01                STA $0180,X
D7A4  e8                      INX
D7A5  86 0c                   STX $0C
D7A7  a6 47                   LDX $47
D7A9  60                      RTS
D7AA  18         sub_D7AA:    CLC
D7AB  65 11                   ADC $11
D7AD  85 11                   STA $11
D7AF  90 02                   BCC loc_D7B3
D7B1  e6 12                   INC $12
D7B3  60         loc_D7B3:    RTS
D7B4  a9 00      sub_D7B4:    LDA #$00
D7B6  85 11                   STA $11
D7B8  a8                      TAY
D7B9  a9 04                   LDA #$04
D7BB  85 12                   STA $12
D7BD  20 71 d7   loc_D7BD:    JSR sub_D771
D7C0  a9 01                   LDA #$01
D7C2  20 aa d7                JSR sub_D7AA
D7C5  a5 12                   LDA $12
D7C7  c9 08                   CMP #$08
D7C9  d0 f2                   BNE loc_D7BD
D7CB  60                      RTS
D7CC  a2 00      sub_D7CC:    LDX #$00
D7CE  a9 11                   LDA #$11
D7D0  9d 00 04   loc_D7D0:    STA $0400,X
D7D3  9d 00 05                STA $0500,X
D7D6  9d 00 06                STA $0600,X
D7D9  9d 00 07                STA $0700,X
D7DC  e8                      INX
D7DD  d0 f1                   BNE loc_D7D0
D7DF  a9 00                   LDA #$00
D7E1  a2 c0                   LDX #$C0
D7E3  9d 00 07   loc_D7E3:    STA $0700,X
D7E6  e8                      INX
D7E7  d0 fa                   BNE loc_D7E3
D7E9  a6 56                   LDX $56
D7EB  a4 57                   LDY $57
D7ED  20 fb d5                JSR sub_D5FB
D7F0  85 12                   STA $12
D7F2  84 11                   STY $11
D7F4  a4 5b      sub_D7F4:    LDY $5B
D7F6  88                      DEY
D7F7  a9 00      loc_D7F7:    LDA #$00
D7F9  91 11                   STA ($11),Y
D7FB  88                      DEY
D7FC  10 f9                   BPL loc_D7F7
D7FE  c6 5a                   DEC $5A
D800  f0 08                   BEQ loc_D80A
D802  a9 20                   LDA #$20
D804  20 aa d7                JSR sub_D7AA
D807  4c f4 d7                JMP sub_D7F4
D80A  60         loc_D80A:    RTS
D80B  48         sub_D80B:    PHA
D80C  85 00                   STA $00
D80E  20 13 d7                JSR sub_D713
D811  86 47                   STX $47
D813  84 48                   STY $48
D815  a4 00                   LDY $00
D817  b9 bb da                LDA $DABB,Y
D81A  85 04                   STA $04
D81C  a4 48                   LDY $48
D81E  20 12 d6                JSR sub_D612
D821  a5 48                   LDA $48
D823  29 fe                   AND #$FE
D825  a8                      TAY
D826  a5 47                   LDA $47
D828  29 fe                   AND #$FE
D82A  aa                      TAX
D82B  20 09 d7                JSR sub_D709
D82E  68                      PLA
D82F  0a                      ASL A
D830  0a                      ASL A
D831  aa                      TAX
D832  bd cb da                LDA $DACB,X
D835  e8                      INX
D836  20 84 d7                JSR sub_D784
D839  a9 01                   LDA #$01
D83B  20 aa d7                JSR sub_D7AA
D83E  bd cb da                LDA $DACB,X
D841  e8                      INX
D842  20 84 d7                JSR sub_D784
D845  a9 1f                   LDA #$1F
D847  20 aa d7                JSR sub_D7AA
D84A  bd cb da                LDA $DACB,X
D84D  e8                      INX
D84E  20 84 d7                JSR sub_D784
D851  a9 01                   LDA #$01
D853  20 aa d7                JSR sub_D7AA
D856  bd cb da                LDA $DACB,X
D859  e8                      INX
D85A  20 84 d7                JSR sub_D784
D85D  60                      RTS
D85E  86 5d      sub_D85E:    STX $5D
D860  aa                      TAX
D861  98                      TYA
D862  18                      CLC
D863  69 20                   ADC #$20
D865  85 5e                   STA $5E
D867  a9 00                   LDA #$00
D869  85 11                   STA $11
D86B  a9 10                   LDA #$10
D86D  85 12                   STA $12
D86F  ca         sub_D86F:    DEX
D870  30 08                   BMI loc_D87A
D872  a9 10                   LDA #$10
D874  20 aa d7                JSR sub_D7AA
D877  4c 6f d8                JMP sub_D86F
D87A  a5 12      loc_D87A:    LDA $12
D87C  8d 06 20                STA $2006  ; PPUADDR
D87F  a5 11                   LDA $11
D881  8d 06 20                STA $2006  ; PPUADDR
D884  ad 07 20                LDA $2007  ; PPUDATA
D887  a9 08                   LDA #$08
D889  85 5a                   STA $5A
D88B  ad 07 20   loc_D88B:    LDA $2007  ; PPUDATA
D88E  48                      PHA
D88F  c6 5a                   DEC $5A
D891  d0 f8                   BNE loc_D88B
D893  a9 08                   LDA #$08
D895  85 5a                   STA $5A
D897  68         loc_D897:    PLA
D898  85 02                   STA $02
D89A  a9 80                   LDA #$80
D89C  85 03                   STA $03
D89E  a6 5d      loc_D89E:    LDX $5D
D8A0  a4 5e                   LDY $5E
D8A2  20 1e d7                JSR sub_D71E
D8A5  a5 02                   LDA $02
D8A7  25 03                   AND $03
D8A9  f0 06                   BEQ loc_D8B1
D8AB  20 64 d7                JSR sub_D764
D8AE  4c b4 d8                JMP sub_D8B4
D8B1  20 4d d7   loc_D8B1:    JSR sub_D74D
D8B4  a5 5d      sub_D8B4:    LDA $5D
D8B6  18                      CLC
D8B7  69 04                   ADC #$04
D8B9  85 5d                   STA $5D
D8BB  46 03                   LSR $03
D8BD  90 df                   BCC loc_D89E
D8BF  a5 5d                   LDA $5D
D8C1  38                      SEC
D8C2  e9 20                   SBC #$20
D8C4  85 5d                   STA $5D
D8C6  a5 5e                   LDA $5E
D8C8  38                      SEC
D8C9  e9 04                   SBC #$04
D8CB  85 5e                   STA $5E
D8CD  c6 5a                   DEC $5A
D8CF  d0 c6                   BNE loc_D897
D8D1  60                      RTS
D8D2  a0 00      sub_D8D2:    LDY #$00
D8D4  84 5f                   STY $5F
D8D6  b1 13      sub_D8D6:    LDA ($13),Y
D8D8  c9 ff                   CMP #$FF
D8DA  f0 19                   BEQ loc_D8F5
D8DC  c8                      INY
D8DD  84 5f                   STY $5F
D8DF  a6 56                   LDX $56
D8E1  a4 57                   LDY $57
D8E3  18                      CLC
D8E4  65 60                   ADC $60
D8E6  20 5e d8                JSR sub_D85E
D8E9  a5 56                   LDA $56
D8EB  18                      CLC
D8EC  69 20                   ADC #$20
D8EE  85 56                   STA $56
D8F0  a4 5f                   LDY $5F
D8F2  4c d6 d8                JMP sub_D8D6
D8F5  60         loc_D8F5:    RTS
D8F6  a5 0b      sub_D8F6:    LDA $0B
D8F8  c5 0b      loc_D8F8:    CMP $0B
D8FA  f0 fc                   BEQ loc_D8F8
D8FC  60                      RTS
D8FD  a6 0c      sub_D8FD:    LDX $0C
D8FF  a9 00                   LDA #$00
D901  9d 80 01                STA $0180,X
D904  aa                      TAX
D905  e4 0c      loc_D905:    CPX $0C
D907  f0 26                   BEQ loc_D92F
D909  bd 80 01                LDA $0180,X
D90C  e8                      INX
D90D  8d 06 20                STA $2006  ; PPUADDR
D910  bd 80 01                LDA $0180,X
D913  e8                      INX
D914  8d 06 20                STA $2006  ; PPUADDR
D917  bd 80 01   sub_D917:    LDA $0180,X
D91A  e8                      INX
D91B  c9 ff                   CMP #$FF
D91D  d0 0a                   BNE loc_D929
D91F  bd 80 01                LDA $0180,X
D922  c9 ff                   CMP #$FF
D924  d0 df                   BNE loc_D905
D926  bd 7f 01                LDA $017F,X
D929  8d 07 20   loc_D929:    STA $2007  ; PPUDATA
D92C  4c 17 d9                JMP sub_D917
D92F  a9 00      loc_D92F:    LDA #$00
D931  85 0c                   STA $0C
D933  60                      RTS
D934  b9 00 00   sub_D934:    LDA $0000,Y
D937  d0 05                   BNE loc_D93E
D939  c8                      INY
D93A  e8                      INX
D93B  4c 34 d9                JMP sub_D934
D93E  c9 ff      loc_D93E:    CMP #$FF
D940  d0 08                   BNE loc_D94A
D942  a5 6b                   LDA $6B
D944  d0 02                   BNE loc_D948
D946  ca                      DEX
D947  88                      DEY
D948  ca         loc_D948:    DEX
D949  88                      DEY
D94A  a9 00      loc_D94A:    LDA #$00
D94C  85 12                   STA $12
D94E  84 11                   STY $11
D950  60                      RTS
D951  a9 10      sub_D951:    LDA #$10
D953  85 56                   STA $56
D955  a9 64                   LDA #$64
D957  85 57                   STA $57
D959  a9 30                   LDA #$30
D95B  85 60                   STA $60
D95D  a0 3d                   LDY #$3D
D95F  b9 00 00   sub_D95F:    LDA $0000,Y
D962  d0 0b                   BNE loc_D96F
D964  c8                      INY
D965  a5 56                   LDA $56
D967  18                      CLC
D968  69 20                   ADC #$20
D96A  85 56                   STA $56
D96C  4c 5f d9                JMP sub_D95F
D96F  a9 00      loc_D96F:    LDA #$00
D971  85 14                   STA $14
D973  84 13                   STY $13
D975  20 d2 d8                JSR sub_D8D2
D978  a9 00                   LDA #$00
D97A  85 60                   STA $60
D97C  60                      RTS
D97D  a2 00      sub_D97D:    LDX #$00
D97F  a0 00                   LDY #$00
D981  b5 15      sub_D981:    LDA $15,X
D983  d5 3d                   CMP $3D,X
D985  d0 08                   BNE loc_D98F
D987  e8                      INX
D988  e0 07                   CPX #$07
D98A  f0 12                   BEQ loc_D99E
D98C  4c 81 d9                JMP sub_D981
D98F  30 0d      loc_D98F:    BMI loc_D99E
D991  a2 00                   LDX #$00
D993  b5 15      loc_D993:    LDA $15,X
D995  95 3d                   STA $3D,X
D997  e8                      INX
D998  e0 07                   CPX #$07
D99A  d0 f7                   BNE loc_D993
D99C  a0 01                   LDY #$01
D99E  a2 00      loc_D99E:    LDX #$00
D9A0  b5 1d      sub_D9A0:    LDA $1D,X
D9A2  d5 3d                   CMP $3D,X
D9A4  d0 08                   BNE loc_D9AE
D9A6  e8                      INX
D9A7  e0 07                   CPX #$07
D9A9  f0 12                   BEQ loc_D9BD
D9AB  4c a0 d9                JMP sub_D9A0
D9AE  30 0d      loc_D9AE:    BMI loc_D9BD
D9B0  a2 00                   LDX #$00
D9B2  b5 1d      loc_D9B2:    LDA $1D,X
D9B4  95 3d                   STA $3D,X
D9B6  e8                      INX
D9B7  e0 07                   CPX #$07
D9B9  d0 f7                   BNE loc_D9B2
D9BB  a0 ff                   LDY #$FF
D9BD  60         loc_D9BD:    RTS
D9BE  8a         sub_D9BE:    TXA
D9BF  0a                      ASL A
D9C0  0a                      ASL A
D9C1  0a                      ASL A
D9C2  18                      CLC
D9C3  69 06                   ADC #$06
D9C5  aa                      TAX
D9C6  a0 06                   LDY #$06
D9C8  18                      CLC
D9C9  b9 35 00   loc_D9C9:    LDA $0035,Y
D9CC  75 15                   ADC $15,X
D9CE  c9 0a                   CMP #$0A
D9D0  30 07                   BMI loc_D9D9
D9D2  38                      SEC
D9D3  e9 0a                   SBC #$0A
D9D5  38                      SEC
D9D6  4c da d9                JMP sub_D9DA
D9D9  18         loc_D9D9:    CLC
D9DA  95 15      sub_D9DA:    STA $15,X
D9DC  ca                      DEX
D9DD  88                      DEY
D9DE  10 e9                   BPL loc_D9C9
D9E0  60                      RTS
D9E1  85 00      sub_D9E1:    STA $00
D9E3  a2 35                   LDX #$35
D9E5  20 fe d9                JSR sub_D9FE
D9E8  a5 00                   LDA $00
D9EA  f0 0d                   BEQ loc_D9F9
D9EC  29 0f                   AND #$0F
D9EE  85 3a                   STA $3A
D9F0  a5 00                   LDA $00
D9F2  4a                      LSR A
D9F3  4a                      LSR A
D9F4  4a                      LSR A
D9F5  4a                      LSR A
D9F6  85 39                   STA $39
D9F8  60                      RTS
D9F9  a9 01      loc_D9F9:    LDA #$01
D9FB  85 38                   STA $38
D9FD  60                      RTS
D9FE  a9 00      sub_D9FE:    LDA #$00
DA00  95 00                   STA $00,X
DA02  95 01                   STA $01,X
DA04  95 02                   STA $02,X
DA06  95 03                   STA $03,X
DA08  95 04                   STA $04,X
DA0A  95 05                   STA $05,X
DA0C  95 06                   STA $06,X
DA0E  a9 ff                   LDA #$FF
DA10  95 07                   STA $07,X
DA12  60                      RTS
DA13  85 00      sub_DA13:    STA $00
DA15  a2 35                   LDX #$35
DA17  20 fe d9                JSR sub_D9FE
DA1A  a5 00                   LDA $00
DA1C  c9 0a      sub_DA1C:    CMP #$0A
DA1E  90 08                   BCC loc_DA28
DA20  38                      SEC
DA21  e9 0a                   SBC #$0A
DA23  e6 3a                   INC $3A
DA25  4c 1c da                JMP sub_DA1C
DA28  85 3b      loc_DA28:    STA $3B
DA2A  60                      RTS
DA2B  8a         sub_DA2B:    TXA
DA2C  85 47                   STA $47
DA2E  18                      CLC
DA2F  69 03                   ADC #$03
DA31  aa                      TAX
DA32  98                      TYA
DA33  38                      SEC
DA34  e9 08                   SBC #$08
DA36  85 48                   STA $48
DA38  20 06 d7                JSR sub_D706
DA3B  b1 11                   LDA ($11),Y
DA3D  c9 22                   CMP #$22
DA3F  d0 06                   BNE loc_DA47
DA41  a5 04                   LDA $04
DA43  05 6e                   ORA $6E
DA45  85 04                   STA $04
DA47  a6 0d      loc_DA47:    LDX $0D
DA49  a5 48                   LDA $48
DA4B  9d 00 02                STA $0200,X
DA4E  a5 53                   LDA $53
DA50  9d 01 02                STA $0201,X
DA53  a5 04                   LDA $04
DA55  9d 02 02                STA $0202,X
DA58  a5 47                   LDA $47
DA5A  9d 03 02                STA $0203,X
DA5D  8a                      TXA
DA5E  18                      CLC
DA5F  65 0e                   ADC $0E
DA61  85 0d                   STA $0D
DA63  60                      RTS
DA64  0a         sub_DA64:    ASL A
DA65  18                      CLC
DA66  65 53                   ADC $53
DA68  85 53                   STA $53
DA6A  8a                      TXA
DA6B  38                      SEC
DA6C  e9 05                   SBC #$05
DA6E  aa                      TAX
DA6F  20 2b da                JSR sub_DA2B
DA72  60                      RTS
DA73  0a         sub_DA73:    ASL A
DA74  0a                      ASL A
DA75  0a                      ASL A
DA76  18                      CLC
DA77  65 53                   ADC $53
DA79  85 53                   STA $53
DA7B  86 54      sub_DA7B:    STX $54
DA7D  84 55                   STY $55
DA7F  8a                      TXA
DA80  38                      SEC
DA81  e9 08                   SBC #$08
DA83  aa                      TAX
DA84  20 2b da                JSR sub_DA2B
DA87  e6 53                   INC $53
DA89  e6 53                   INC $53
DA8B  a6 54                   LDX $54
DA8D  a4 55                   LDY $55
DA8F  20 2b da                JSR sub_DA2B
DA92  60                      RTS
DA93  a6 0d      sub_DA93:    LDX $0D
DA95  a5 0e                   LDA $0E
DA97  49 ff                   EOR #$FF
DA99  18                      CLC
DA9A  69 01                   ADC #$01
DA9C  85 0e                   STA $0E
DA9E  8a         loc_DA9E:    TXA
DA9F  18                      CLC
DAA0  65 0e                   ADC $0E
DAA2  aa                      TAX
DAA3  a9 f0                   LDA #$F0
DAA5  9d 00 02                STA $0200,X
DAA8  e0 04                   CPX #$04
DAAA  d0 f2                   BNE loc_DA9E
DAAC  86 0d                   STX $0D
DAAE  60                      RTS
DAAF  f0 09      sub_DAAF:    BEQ loc_DABA
DAB1  b0 05                   BCS loc_DAB8
DAB3  a9 ff                   LDA #$FF
DAB5  4c ba da                JMP loc_DABA
DAB8  a9 01      loc_DAB8:    LDA #$01
DABA  60         loc_DABA:    RTS

; ---- $DABB..$DB0A (80 bytes: data) ----
DB0B  ad 11 03   sub_DB0B:    LDA $0311
DB0E  f0 14                   BEQ loc_DB24
DB10  a2 00                   LDX #$00
DB12  20 38 db                JSR sub_DB38
DB15  d0 20                   BNE loc_DB37
DB17  a2 01                   LDX #$01
DB19  20 38 db                JSR sub_DB38
DB1C  d0 19                   BNE loc_DB37
DB1E  a9 00                   LDA #$00
DB20  8d 11 03                STA $0311
DB23  60                      RTS
DB24  a2 00      loc_DB24:    LDX #$00
DB26  20 38 db                JSR sub_DB38
DB29  d0 07                   BNE loc_DB32
DB2B  a2 01                   LDX #$01
DB2D  20 38 db                JSR sub_DB38
DB30  f0 05                   BEQ loc_DB37
DB32  a9 01      loc_DB32:    LDA #$01
DB34  8d 11 03                STA $0311
DB37  60         loc_DB37:    RTS
DB38  b5 06      sub_DB38:    LDA $06,X
DB3A  29 f0                   AND #$F0
DB3C  f0 07                   BEQ loc_DB45
DB3E  b5 a0                   LDA $A0,X
DB40  f0 03                   BEQ loc_DB45
DB42  a9 01                   LDA #$01
DB44  60                      RTS
DB45  a9 00      loc_DB45:    LDA #$00
DB47  60                      RTS
DB48  a5 82      sub_DB48:    LDA $82
DB4A  f0 03                   BEQ loc_DB4F
DB4C  c6 82                   DEC $82
DB4E  60                      RTS
DB4F  a5 7f      loc_DB4F:    LDA $7F
DB51  f0 21                   BEQ loc_DB74
DB53  a5 6c                   LDA $6C
DB55  85 5a                   STA $5A
DB57  a6 5a      loc_DB57:    LDX $5A
DB59  b5 a0                   LDA $A0,X
DB5B  d0 0f                   BNE loc_DB6C
DB5D  a5 84                   LDA $84
DB5F  85 82                   STA $82
DB61  20 63 e3                JSR sub_E363
DB64  c6 7f                   DEC $7F
DB66  a5 7f                   LDA $7F
DB68  20 b1 c8                JSR sub_C8B1
DB6B  60                      RTS
DB6C  c6 5a      loc_DB6C:    DEC $5A
DB6E  a5 5a                   LDA $5A
DB70  c9 01                   CMP #$01
DB72  d0 e3                   BNE loc_DB57
DB74  60         loc_DB74:    RTS
DB75  a5 0b      sub_DB75:    LDA $0B
DB77  29 01                   AND #$01
DB79  d0 06                   BNE loc_DB81
DB7B  a5 0b                   LDA $0B
DB7D  29 03                   AND #$03
DB7F  d0 6f                   BNE loc_DBF0
DB81  a2 01      loc_DB81:    LDX #$01
DB83  b5 a0      loc_DB83:    LDA $A0,X
DB85  10 66                   BPL loc_DBED
DB87  c9 e0                   CMP #$E0
DB89  b0 62                   BCS loc_DBED
DB8B  b5 6f                   LDA $6F,X
DB8D  f0 05                   BEQ loc_DB94
DB8F  d6 6f                   DEC $6F,X
DB91  4c a6 db                JMP sub_DBA6
DB94  bd 03 01   loc_DB94:    LDA $0103,X
DB97  10 04                   BPL loc_DB9D
DB99  29 10                   AND #$10
DB9B  d0 09                   BNE sub_DBA6
DB9D  b5 06      loc_DB9D:    LDA $06,X
DB9F  20 51 e4                JSR sub_E451
DBA2  85 00                   STA $00
DBA4  10 0e                   BPL loc_DBB4
DBA6  a9 80      sub_DBA6:    LDA #$80
DBA8  20 20 e4                JSR sub_E420
DBAB  a9 08                   LDA #$08
DBAD  15 a0                   ORA $A0,X
DBAF  95 a0                   STA $A0,X
DBB1  4c ed db                JMP loc_DBED
DBB4  bd 03 01   loc_DBB4:    LDA $0103,X
DBB7  10 0e                   BPL loc_DBC7
DBB9  29 1f                   AND #$1F
DBBB  d0 0a                   BNE loc_DBC7
DBBD  a9 9c                   LDA #$9C
DBBF  9d 03 01                STA $0103,X
DBC2  a9 01                   LDA #$01
DBC4  8d 10 03                STA $0310
DBC7  b5 a0      loc_DBC7:    LDA $A0,X
DBC9  29 03                   AND #$03
DBCB  c5 00                   CMP $00
DBCD  f0 18                   BEQ loc_DBE7
DBCF  49 02                   EOR #$02
DBD1  c5 00                   CMP $00
DBD3  f0 12                   BEQ loc_DBE7
DBD5  b5 90                   LDA $90,X
DBD7  18                      CLC
DBD8  69 04                   ADC #$04
DBDA  29 f8                   AND #$F8
DBDC  95 90                   STA $90,X
DBDE  b5 98                   LDA $98,X
DBE0  18                      CLC
DBE1  69 04                   ADC #$04
DBE3  29 f8                   AND #$F8
DBE5  95 98                   STA $98,X
DBE7  a5 00      loc_DBE7:    LDA $00
DBE9  09 a0                   ORA #$A0
DBEB  95 a0                   STA $A0,X
DBED  ca         loc_DBED:    DEX
DBEE  10 93                   BPL loc_DB83
DBF0  60         loc_DBF0:    RTS
DBF1  a9 07      sub_DBF1:    LDA #$07
DBF3  85 5a                   STA $5A
DBF5  ad 00 01                LDA $0100
DBF8  f0 09                   BEQ loc_DC03
DBFA  a5 0b                   LDA $0B
DBFC  29 3f                   AND #$3F
DBFE  d0 03                   BNE loc_DC03
DC00  ce 00 01                DEC $0100
DC03  a6 5a      loc_DC03:    LDX $5A
DC05  e0 02                   CPX #$02
DC07  b0 0f                   BCS loc_DC18
DC09  a5 0b                   LDA $0B
DC0B  29 01                   AND #$01
DC0D  d0 26                   BNE loc_DC35
DC0F  a5 0b                   LDA $0B
DC11  29 03                   AND #$03
DC13  d0 23                   BNE loc_DC38
DC15  4c 35 dc                JMP loc_DC35
DC18  ad 00 01   loc_DC18:    LDA $0100
DC1B  f0 08                   BEQ loc_DC25
DC1D  b5 a0                   LDA $A0,X
DC1F  10 04                   BPL loc_DC25
DC21  c9 e0                   CMP #$E0
DC23  90 13                   BCC loc_DC38
DC25  b5 a8      loc_DC25:    LDA $A8,X
DC27  29 f0                   AND #$F0
DC29  c9 a0                   CMP #$A0
DC2B  f0 08                   BEQ loc_DC35
DC2D  a5 5a                   LDA $5A
DC2F  45 0b                   EOR $0B
DC31  29 01                   AND #$01
DC33  f0 03                   BEQ loc_DC38
DC35  20 3d dc   loc_DC35:    JSR sub_DC3D
DC38  c6 5a      loc_DC38:    DEC $5A
DC3A  10 c7                   BPL loc_DC03
DC3C  60                      RTS
DC3D  b5 a0      sub_DC3D:    LDA $A0,X
DC3F  4a                      LSR A
DC40  4a                      LSR A
DC41  4a                      LSR A
DC42  29 fe                   AND #$FE
DC44  a8                      TAY
DC45  b9 98 e4                LDA $E498,Y
DC48  85 11                   STA $11
DC4A  b9 99 e4                LDA $E499,Y
DC4D  85 12                   STA $12
DC4F  6c 11 00                JMP ($0011)
DC52  e0 02                   CPX #$02
DC54  b0 15                   BCS loc_DC6B
DC56  bd 03 01                LDA $0103,X
DC59  10 10                   BPL loc_DC6B
DC5B  29 7f                   AND #$7F
DC5D  f0 0c                   BEQ loc_DC6B
DC5F  de 03 01                DEC $0103,X
DC62  b5 b0                   LDA $B0,X
DC64  49 04                   EOR #$04
DC66  95 b0                   STA $B0,X
DC68  4c 97 dc                JMP sub_DC97
DC6B  b5 a0      loc_DC6B:    LDA $A0,X
DC6D  38                      SEC
DC6E  e9 04                   SBC #$04
DC70  95 a0                   STA $A0,X
DC72  29 0c                   AND #$0C
DC74  d0 05                   BNE loc_DC7B
DC76  a9 a0                   LDA #$A0
DC78  20 20 e4                JSR sub_E420
DC7B  60         loc_DC7B:    RTS
DC7C  e0 02                   CPX #$02
DC7E  90 17                   BCC sub_DC97
DC80  b5 90                   LDA $90,X
DC82  29 07                   AND #$07
DC84  d0 11                   BNE sub_DC97
DC86  b5 98                   LDA $98,X
DC88  29 07                   AND #$07
DC8A  d0 0b                   BNE sub_DC97
DC8C  20 4d d4                JSR sub_D44D
DC8F  29 0f                   AND #$0F
DC91  d0 04                   BNE sub_DC97
DC93  20 72 de                JSR sub_DE72
DC96  60                      RTS
DC97  b5 a0      sub_DC97:    LDA $A0,X
DC99  29 03                   AND #$03
DC9B  a8                      TAY
DC9C  b9 70 e4                LDA $E470,Y
DC9F  0a                      ASL A
DCA0  0a                      ASL A
DCA1  0a                      ASL A
DCA2  85 59                   STA $59
DCA4  b9 70 e4                LDA $E470,Y
DCA7  18                      CLC
DCA8  75 98                   ADC $98,X
DCAA  85 57                   STA $57
DCAC  b9 6c e4                LDA $E46C,Y
DCAF  0a                      ASL A
DCB0  0a                      ASL A
DCB1  0a                      ASL A
DCB2  85 58                   STA $58
DCB4  b9 6c e4                LDA $E46C,Y
DCB7  18                      CLC
DCB8  75 90                   ADC $90,X
DCBA  85 56                   STA $56
DCBC  18                      CLC
DCBD  65 58                   ADC $58
DCBF  18                      CLC
DCC0  65 59                   ADC $59
DCC2  20 6e dd                JSR sub_DD6E
DCC5  aa                      TAX
DCC6  a5 57                   LDA $57
DCC8  18                      CLC
DCC9  65 58                   ADC $58
DCCB  18                      CLC
DCCC  65 59                   ADC $59
DCCE  20 76 dd                JSR sub_DD76
DCD1  a8                      TAY
DCD2  20 06 d7                JSR sub_D706
DCD5  b1 11                   LDA ($11),Y
DCD7  30 38                   BMI loc_DD11
DCD9  f0 04                   BEQ loc_DCDF
DCDB  c9 20                   CMP #$20
DCDD  90 32                   BCC loc_DD11
DCDF  a5 56      loc_DCDF:    LDA $56
DCE1  18                      CLC
DCE2  65 58                   ADC $58
DCE4  38                      SEC
DCE5  e5 59                   SBC $59
DCE7  20 6e dd                JSR sub_DD6E
DCEA  aa                      TAX
DCEB  a5 57                   LDA $57
DCED  18                      CLC
DCEE  65 59                   ADC $59
DCF0  38                      SEC
DCF1  e5 58                   SBC $58
DCF3  20 76 dd                JSR sub_DD76
DCF6  a8                      TAY
DCF7  20 06 d7                JSR sub_D706
DCFA  b1 11                   LDA ($11),Y
DCFC  30 13                   BMI loc_DD11
DCFE  f0 04                   BEQ loc_DD04
DD00  c9 20                   CMP #$20
DD02  90 0d                   BCC loc_DD11
DD04  a6 5a      loc_DD04:    LDX $5A
DD06  a5 56                   LDA $56
DD08  95 90                   STA $90,X
DD0A  a5 57                   LDA $57
DD0C  95 98                   STA $98,X
DD0E  4c 29 dd                JMP sub_DD29
DD11  a6 5a      loc_DD11:    LDX $5A
DD13  e0 02                   CPX #$02
DD15  90 12                   BCC sub_DD29
DD17  20 4d d4                JSR sub_D44D
DD1A  29 03                   AND #$03
DD1C  f0 12                   BEQ loc_DD30
DD1E  a9 80                   LDA #$80
DD20  20 20 e4                JSR sub_E420
DD23  a9 08                   LDA #$08
DD25  15 a0                   ORA $A0,X
DD27  95 a0                   STA $A0,X
DD29  b5 b0      sub_DD29:    LDA $B0,X
DD2B  49 04                   EOR #$04
DD2D  95 b0                   STA $B0,X
DD2F  60                      RTS
DD30  b5 90      loc_DD30:    LDA $90,X
DD32  29 07                   AND #$07
DD34  d0 0b                   BNE loc_DD41
DD36  b5 98                   LDA $98,X
DD38  29 07                   AND #$07
DD3A  d0 05                   BNE loc_DD41
DD3C  a9 90                   LDA #$90
DD3E  20 20 e4                JSR sub_E420
DD41  b5 a0      loc_DD41:    LDA $A0,X
DD43  49 02                   EOR #$02
DD45  95 a0                   STA $A0,X
DD47  60                      RTS
DD48  20 4d d4                JSR sub_D44D
DD4B  29 01                   AND #$01
DD4D  f0 1b                   BEQ loc_DD6A
DD4F  20 4d d4                JSR sub_D44D
DD52  29 01                   AND #$01
DD54  f0 08                   BEQ loc_DD5E
DD56  b5 a0                   LDA $A0,X
DD58  18                      CLC
DD59  69 01                   ADC #$01
DD5B  4c 63 dd                JMP sub_DD63
DD5E  b5 a0      loc_DD5E:    LDA $A0,X
DD60  38                      SEC
DD61  e9 01                   SBC #$01
DD63  29 03      sub_DD63:    AND #$03
DD65  09 a0                   ORA #$A0
DD67  95 a0                   STA $A0,X
DD69  60                      RTS
DD6A  20 72 de   loc_DD6A:    JSR sub_DE72
DD6D  60                      RTS
DD6E  c5 56      sub_DD6E:    CMP $56
DD70  90 03                   BCC loc_DD75
DD72  38                      SEC
DD73  e9 01                   SBC #$01
DD75  60         loc_DD75:    RTS
DD76  c5 57      sub_DD76:    CMP $57
DD78  90 03                   BCC loc_DD7D
DD7A  38                      SEC
DD7B  e9 01                   SBC #$01
DD7D  60         loc_DD7D:    RTS
DD7E  a5 90                   LDA $90
DD80  85 71                   STA $71
DD82  a5 98                   LDA $98
DD84  85 72                   STA $72
DD86  4c 9c dd                JMP sub_DD9C
DD89  a5 91                   LDA $91
DD8B  85 71                   STA $71
DD8D  a5 99                   LDA $99
DD8F  85 72                   STA $72
DD91  4c 9c dd                JMP sub_DD9C
DD94  a9 78                   LDA #$78
DD96  85 71                   STA $71
DD98  a9 d8                   LDA #$D8
DD9A  85 72                   STA $72
DD9C  20 a2 dd   sub_DD9C:    JSR sub_DDA2
DD9F  95 a0                   STA $A0,X
DDA1  60                      RTS
DDA2  a5 71      sub_DDA2:    LDA $71
DDA4  38                      SEC
DDA5  f5 90                   SBC $90,X
DDA7  20 af da                JSR sub_DAAF
DDAA  18                      CLC
DDAB  69 01                   ADC #$01
DDAD  85 64                   STA $64
DDAF  a5 72                   LDA $72
DDB1  38                      SEC
DDB2  f5 98                   SBC $98,X
DDB4  20 af da                JSR sub_DAAF
DDB7  18                      CLC
DDB8  69 01                   ADC #$01
DDBA  85 65                   STA $65
DDBC  0a                      ASL A
DDBD  18                      CLC
DDBE  65 65                   ADC $65
DDC0  18                      CLC
DDC1  65 64                   ADC $64
DDC3  85 64                   STA $64
DDC5  e0 02                   CPX #$02
DDC7  b0 0b                   BCS loc_DDD4
DDC9  8a                      TXA
DDCA  0a                      ASL A
DDCB  45 0a                   EOR $0A
DDCD  29 02                   AND #$02
DDCF  f0 13                   BEQ loc_DDE4
DDD1  4c db dd                JMP sub_DDDB
DDD4  20 4d d4   loc_DDD4:    JSR sub_D44D
DDD7  29 01                   AND #$01
DDD9  f0 09                   BEQ loc_DDE4
DDDB  a9 09      sub_DDDB:    LDA #$09
DDDD  18                      CLC
DDDE  65 64                   ADC $64
DDE0  a8                      TAY
DDE1  4c e6 dd                JMP sub_DDE6
DDE4  a4 64      loc_DDE4:    LDY $64
DDE6  b9 86 e4   sub_DDE6:    LDA $E486,Y
DDE9  60                      RTS
DDEA  d6 a0                   DEC $A0,X
DDEC  b5 a0                   LDA $A0,X
DDEE  29 0f                   AND #$0F
DDF0  d0 53                   BNE loc_DE45
DDF2  b5 a0                   LDA $A0,X
DDF4  38                      SEC
DDF5  e9 10                   SBC #$10
DDF7  f0 0e                   BEQ loc_DE07
DDF9  c9 10                   CMP #$10
DDFB  d0 05                   BNE loc_DE02
DDFD  09 06                   ORA #$06
DDFF  4c 04 de                JMP sub_DE04
DE02  09 03      loc_DE02:    ORA #$03
DE04  95 a0      sub_DE04:    STA $A0,X
DE06  60                      RTS
DE07  95 a0      loc_DE07:    STA $A0,X
DE09  e0 02                   CPX #$02
DE0B  b0 08                   BCS loc_DE15
DE0D  d6 51                   DEC $51,X
DE0F  f0 07                   BEQ loc_DE18
DE11  20 63 e3                JSR sub_E363
DE14  60                      RTS
DE15  c6 80      loc_DE15:    DEC $80
DE17  60                      RTS
DE18  a5 68      loc_DE18:    LDA $68
DE1A  c9 80                   CMP #$80
DE1C  d0 27                   BNE loc_DE45
DE1E  e0 01                   CPX #$01
DE20  f0 12                   BEQ loc_DE34
DE22  a5 52                   LDA $52
DE24  f0 1f                   BEQ loc_DE45
DE26  a9 03                   LDA #$03
DE28  8d 07 01                STA $0107
DE2B  a9 20                   LDA #$20
DE2D  8d 05 01                STA $0105
DE30  20 46 de                JSR sub_DE46
DE33  60                      RTS
DE34  a5 51      loc_DE34:    LDA $51
DE36  f0 0d                   BEQ loc_DE45
DE38  a9 01                   LDA #$01
DE3A  8d 07 01                STA $0107
DE3D  a9 c0                   LDA #$C0
DE3F  8d 05 01                STA $0105
DE42  20 46 de                JSR sub_DE46
DE45  60         loc_DE45:    RTS
DE46  a9 0d      sub_DE46:    LDA #$0D
DE48  8d 08 01                STA $0108
DE4B  a9 d8                   LDA #$D8
DE4D  8d 06 01                STA $0106
DE50  a9 00                   LDA #$00
DE52  85 0b                   STA $0B
DE54  60                      RTS
DE55  f6 a0                   INC $A0,X
DE57  b5 a0                   LDA $A0,X
DE59  29 0f                   AND #$0F
DE5B  c9 0e                   CMP #$0E
DE5D  d0 04                   BNE loc_DE63
DE5F  a9 e0                   LDA #$E0
DE61  95 a0                   STA $A0,X
DE63  60         loc_DE63:    RTS
DE64  f6 a0                   INC $A0,X
DE66  b5 a0                   LDA $A0,X
DE68  29 0f                   AND #$0F
DE6A  c9 0e                   CMP #$0E
DE6C  d0 03                   BNE loc_DE71
DE6E  20 b8 e3                JSR sub_E3B8
DE71  60         loc_DE71:    RTS
DE72  a5 84      sub_DE72:    LDA $84
DE74  4a                      LSR A
DE75  4a                      LSR A
DE76  c5 0a                   CMP $0A
DE78  b0 05                   BCS loc_DE7F
DE7A  a9 b0                   LDA #$B0
DE7C  4c a2 de                JMP sub_DEA2
DE7F  4a         loc_DE7F:    LSR A
DE80  c5 0a                   CMP $0A
DE82  90 0a                   BCC loc_DE8E
DE84  20 4d d4                JSR sub_D44D
DE87  29 03                   AND #$03
DE89  09 a0                   ORA #$A0
DE8B  95 a0                   STA $A0,X
DE8D  60                      RTS
DE8E  a5 a0      loc_DE8E:    LDA $A0
DE90  f0 09                   BEQ loc_DE9B
DE92  8a                      TXA
DE93  29 01                   AND #$01
DE95  f0 09                   BEQ loc_DEA0
DE97  a5 a1                   LDA $A1
DE99  f0 05                   BEQ loc_DEA0
DE9B  a9 c0      loc_DE9B:    LDA #$C0
DE9D  4c a2 de                JMP sub_DEA2
DEA0  a9 d0      loc_DEA0:    LDA #$D0
DEA2  20 20 e4   sub_DEA2:    JSR sub_E420
DEA5  60                      RTS
DEA6  a9 00      sub_DEA6:    LDA #$00
DEA8  85 5a                   STA $5A
DEAA  a6 5a      loc_DEAA:    LDX $5A
DEAC  20 b8 de                JSR sub_DEB8
DEAF  e6 5a                   INC $5A
DEB1  a5 5a                   LDA $5A
DEB3  c9 08                   CMP #$08
DEB5  d0 f3                   BNE loc_DEAA
DEB7  60                      RTS
DEB8  b5 a0      sub_DEB8:    LDA $A0,X
DEBA  4a                      LSR A
DEBB  4a                      LSR A
DEBC  4a                      LSR A
DEBD  29 fe                   AND #$FE
DEBF  a8                      TAY
DEC0  b9 b8 e4                LDA $E4B8,Y
DEC3  85 11                   STA $11
DEC5  b9 b9 e4                LDA $E4B9,Y
DEC8  85 12                   STA $12
DECA  6c 11 00                JMP ($0011)
DECD  a9 00                   LDA #$00
DECF  85 6e                   STA $6E
DED1  b5 a0                   LDA $A0,X
DED3  48                      PHA
DED4  b4 98                   LDY $98,X
DED6  b5 90                   LDA $90,X
DED8  aa                      TAX
DED9  68                      PLA
DEDA  20 e2 de                JSR sub_DEE2
DEDD  a9 20                   LDA #$20
DEDF  85 6e                   STA $6E
DEE1  60                      RTS
DEE2  4a         sub_DEE2:    LSR A
DEE3  4a                      LSR A
DEE4  4a                      LSR A
DEE5  4a                      LSR A
DEE6  38                      SEC
DEE7  e9 07                   SBC #$07
DEE9  49 ff                   EOR #$FF
DEEB  18                      CLC
DEEC  69 01                   ADC #$01
DEEE  0a                      ASL A
DEEF  0a                      ASL A
DEF0  18         sub_DEF0:    CLC
DEF1  69 f1                   ADC #$F1
DEF3  85 53                   STA $53
DEF5  a9 03                   LDA #$03
DEF7  85 04                   STA $04
DEF9  20 7b da                JSR sub_DA7B
DEFC  60                      RTS
DEFD  a9 00                   LDA #$00
DEFF  85 6e                   STA $6E
DF01  b5 a8                   LDA $A8,X
DF03  f0 1e                   BEQ loc_DF23
DF05  b5 a8                   LDA $A8,X
DF07  4a                      LSR A
DF08  4a                      LSR A
DF09  4a                      LSR A
DF0A  29 fc                   AND #$FC
DF0C  38                      SEC
DF0D  e9 10                   SBC #$10
DF0F  18                      CLC
DF10  69 b9                   ADC #$B9
DF12  85 53                   STA $53
DF14  a9 03                   LDA #$03
DF16  85 04                   STA $04
DF18  b4 98                   LDY $98,X
DF1A  b5 90                   LDA $90,X
DF1C  aa                      TAX
DF1D  20 7b da                JSR sub_DA7B
DF20  4c 2e df                JMP sub_DF2E
DF23  b5 98      loc_DF23:    LDA $98,X
DF25  a8                      TAY
DF26  b5 90                   LDA $90,X
DF28  aa                      TAX
DF29  a9 00                   LDA #$00
DF2B  20 f0 de                JSR sub_DEF0
DF2E  a9 20      sub_DF2E:    LDA #$20
DF30  85 6e                   STA $6E
DF32  60                      RTS
DF33  a9 00                   LDA #$00
DF35  85 6e                   STA $6E
DF37  b4 98                   LDY $98,X
DF39  b5 90                   LDA $90,X
DF3B  aa                      TAX
DF3C  a9 08                   LDA #$08
DF3E  20 f0 de                JSR sub_DEF0
DF41  a9 20                   LDA #$20
DF43  85 6e                   STA $6E
DF45  60                      RTS
DF46  a9 03                   LDA #$03
DF48  85 04                   STA $04
DF4A  a9 00                   LDA #$00
DF4C  85 6e                   STA $6E
DF4E  20 99 df                JSR sub_DF99
DF51  8a                      TXA
DF52  38                      SEC
DF53  e9 08                   SBC #$08
DF55  aa                      TAX
DF56  98                      TYA
DF57  38                      SEC
DF58  e9 08                   SBC #$08
DF5A  a8                      TAY
DF5B  20 7b da                JSR sub_DA7B
DF5E  a9 01                   LDA #$01
DF60  20 99 df                JSR sub_DF99
DF63  8a                      TXA
DF64  18                      CLC
DF65  69 08                   ADC #$08
DF67  aa                      TAX
DF68  98                      TYA
DF69  38                      SEC
DF6A  e9 08                   SBC #$08
DF6C  a8                      TAY
DF6D  20 7b da                JSR sub_DA7B
DF70  a9 02                   LDA #$02
DF72  20 99 df                JSR sub_DF99
DF75  8a                      TXA
DF76  38                      SEC
DF77  e9 08                   SBC #$08
DF79  aa                      TAX
DF7A  98                      TYA
DF7B  18                      CLC
DF7C  69 08                   ADC #$08
DF7E  a8                      TAY
DF7F  20 7b da                JSR sub_DA7B
DF82  a9 03                   LDA #$03
DF84  20 99 df                JSR sub_DF99
DF87  8a                      TXA
DF88  18                      CLC
DF89  69 08                   ADC #$08
DF8B  aa                      TAX
DF8C  98                      TYA
DF8D  18                      CLC
DF8E  69 08                   ADC #$08
DF90  a8                      TAY
DF91  20 7b da                JSR sub_DA7B
DF94  a9 20                   LDA #$20
DF96  85 6e                   STA $6E
DF98  60                      RTS
DF99  a6 5a      sub_DF99:    LDX $5A
DF9B  0a                      ASL A
DF9C  0a                      ASL A
DF9D  18                      CLC
DF9E  69 d1                   ADC #$D1
DFA0  85 00                   STA $00
DFA2  b5 a0                   LDA $A0,X
DFA4  29 f0                   AND #$F0
DFA6  38                      SEC
DFA7  e9 30                   SBC #$30
DFA9  49 10                   EOR #$10
DFAB  18                      CLC
DFAC  65 00                   ADC $00
DFAE  85 53                   STA $53
DFB0  b4 98                   LDY $98,X
DFB2  b5 90                   LDA $90,X
DFB4  aa                      TAX
DFB5  60                      RTS
DFB6  e0 02                   CPX #$02
DFB8  90 23                   BCC loc_DFDD
DFBA  b5 a8                   LDA $A8,X
DFBC  29 04                   AND #$04
DFBE  f0 0d                   BEQ loc_DFCD
DFC0  a5 0b                   LDA $0B
DFC2  4a                      LSR A
DFC3  4a                      LSR A
DFC4  4a                      LSR A
DFC5  29 01                   AND #$01
DFC7  18                      CLC
DFC8  69 02                   ADC #$02
DFCA  4c e9 df                JMP sub_DFE9
DFCD  a5 0b      loc_DFCD:    LDA $0B
DFCF  0a                      ASL A
DFD0  0a                      ASL A
DFD1  18                      CLC
DFD2  75 a8                   ADC $A8,X
DFD4  29 07                   AND #$07
DFD6  a8                      TAY
DFD7  b9 03 e0                LDA $E003,Y
DFDA  4c e9 df                JMP sub_DFE9
DFDD  b5 6f      loc_DFDD:    LDA $6F,X
DFDF  f0 07                   BEQ loc_DFE8
DFE1  a5 0b                   LDA $0B
DFE3  29 08                   AND #$08
DFE5  f0 01                   BEQ loc_DFE8
DFE7  60                      RTS
DFE8  8a         loc_DFE8:    TXA
DFE9  85 04      sub_DFE9:    STA $04
DFEB  b5 a0                   LDA $A0,X
DFED  29 03                   AND #$03
DFEF  48                      PHA
DFF0  b5 a8                   LDA $A8,X
DFF2  29 f0                   AND #$F0
DFF4  18                      CLC
DFF5  75 b0                   ADC $B0,X
DFF7  85 53                   STA $53
DFF9  b4 98                   LDY $98,X
DFFB  b5 90                   LDA $90,X
DFFD  aa                      TAX
DFFE  68                      PLA
DFFF  20 73 da                JSR sub_DA73
E002  60                      RTS

; ---- $E003..$E00A (8 bytes: data) ----
E00B  b5 a0                   LDA $A0,X
E00D  29 0f                   AND #$0F
E00F  38                      SEC
E010  e9 07                   SBC #$07
E012  10 05                   BPL loc_E019
E014  49 ff                   EOR #$FF
E016  18                      CLC
E017  69 01                   ADC #$01
E019  0a         loc_E019:    ASL A
E01A  29 fc                   AND #$FC
E01C  18                      CLC
E01D  69 a1                   ADC #$A1
E01F  85 53                   STA $53
E021  a9 03                   LDA #$03
E023  85 04                   STA $04
E025  b4 98                   LDY $98,X
E027  b5 90                   LDA $90,X
E029  aa                      TAX
E02A  20 7b da                JSR sub_DA7B
E02D  60                      RTS
E02E  a9 09      sub_E02E:    LDA #$09
E030  85 5a                   STA $5A
E032  a6 5a      loc_E032:    LDX $5A
E034  20 3c e0                JSR sub_E03C
E037  c6 5a                   DEC $5A
E039  10 f7                   BPL loc_E032
E03B  60                      RTS
E03C  b5 cc      sub_E03C:    LDA $CC,X
E03E  4a                      LSR A
E03F  4a                      LSR A
E040  4a                      LSR A
E041  29 fe                   AND #$FE
E043  a8                      TAY
E044  b9 d8 e4                LDA $E4D8,Y
E047  85 11                   STA $11
E049  b9 d9 e4                LDA $E4D9,Y
E04C  85 12                   STA $12
E04E  6c 11 00                JMP ($0011)
E051  b5 cc                   LDA $CC,X
E053  29 03                   AND #$03
E055  a8                      TAY
E056  20 63 e0                JSR sub_E063
E059  b5 d6                   LDA $D6,X
E05B  29 01                   AND #$01
E05D  f0 03                   BEQ loc_E062
E05F  20 63 e0                JSR sub_E063
E062  60         loc_E062:    RTS
E063  b9 6c e4   sub_E063:    LDA $E46C,Y
E066  0a                      ASL A
E067  18                      CLC
E068  75 b8                   ADC $B8,X
E06A  95 b8                   STA $B8,X
E06C  b9 70 e4                LDA $E470,Y
E06F  0a                      ASL A
E070  18                      CLC
E071  75 c2                   ADC $C2,X
E073  95 c2                   STA $C2,X
E075  60                      RTS
E076  d6 cc                   DEC $CC,X
E078  b5 cc                   LDA $CC,X
E07A  29 0f                   AND #$0F
E07C  d0 0d                   BNE loc_E08B
E07E  b5 cc                   LDA $CC,X
E080  29 f0                   AND #$F0
E082  38                      SEC
E083  e9 10                   SBC #$10
E085  f0 02                   BEQ loc_E089
E087  09 03                   ORA #$03
E089  95 cc      loc_E089:    STA $CC,X
E08B  60         loc_E08B:    RTS
E08C  b5 cc      sub_E08C:    LDA $CC,X
E08E  d0 47                   BNE loc_E0D7
E090  e0 02                   CPX #$02
E092  b0 05                   BCS loc_E099
E094  a9 01                   LDA #$01
E096  8d 0f 03                STA $030F
E099  b5 a0      loc_E099:    LDA $A0,X
E09B  29 03                   AND #$03
E09D  a8                      TAY
E09E  09 40                   ORA #$40
E0A0  95 cc                   STA $CC,X
E0A2  b9 6c e4                LDA $E46C,Y
E0A5  0a                      ASL A
E0A6  0a                      ASL A
E0A7  0a                      ASL A
E0A8  18                      CLC
E0A9  75 90                   ADC $90,X
E0AB  95 b8                   STA $B8,X
E0AD  b9 70 e4                LDA $E470,Y
E0B0  0a                      ASL A
E0B1  0a                      ASL A
E0B2  0a                      ASL A
E0B3  18                      CLC
E0B4  75 98                   ADC $98,X
E0B6  95 c2                   STA $C2,X
E0B8  a9 00                   LDA #$00
E0BA  95 d6                   STA $D6,X
E0BC  b5 a8                   LDA $A8,X
E0BE  29 f0                   AND #$F0
E0C0  f0 15                   BEQ loc_E0D7
E0C2  c9 c0                   CMP #$C0
E0C4  f0 08                   BEQ loc_E0CE
E0C6  c9 60                   CMP #$60
E0C8  f0 09                   BEQ loc_E0D3
E0CA  29 80                   AND #$80
E0CC  d0 09                   BNE loc_E0D7
E0CE  a9 01      loc_E0CE:    LDA #$01
E0D0  95 d6                   STA $D6,X
E0D2  60                      RTS
E0D3  a9 03      loc_E0D3:    LDA #$03
E0D5  95 d6                   STA $D6,X
E0D7  60         loc_E0D7:    RTS
E0D8  a9 09      sub_E0D8:    LDA #$09
E0DA  85 5a                   STA $5A
E0DC  a6 5a      loc_E0DC:    LDX $5A
E0DE  20 e6 e0                JSR sub_E0E6
E0E1  c6 5a                   DEC $5A
E0E3  10 f7                   BPL loc_E0DC
E0E5  60                      RTS
E0E6  b5 cc      sub_E0E6:    LDA $CC,X
E0E8  4a                      LSR A
E0E9  4a                      LSR A
E0EA  4a                      LSR A
E0EB  29 fe                   AND #$FE
E0ED  a8                      TAY
E0EE  b9 e2 e4                LDA $E4E2,Y
E0F1  85 11                   STA $11
E0F3  b9 e3 e4                LDA $E4E3,Y
E0F6  85 12                   STA $12
E0F8  6c 11 00                JMP ($0011)
E0FB  b5 cc                   LDA $CC,X
E0FD  29 03                   AND #$03
E0FF  48                      PHA
E100  b4 c2                   LDY $C2,X
E102  b5 b8                   LDA $B8,X
E104  aa                      TAX
E105  a9 02                   LDA #$02
E107  85 04                   STA $04
E109  a9 b1                   LDA #$B1
E10B  85 53                   STA $53
E10D  68                      PLA
E10E  20 64 da                JSR sub_DA64
E111  60                      RTS
E112  b5 cc                   LDA $CC,X
E114  48                      PHA
E115  b4 c2                   LDY $C2,X
E117  b5 b8                   LDA $B8,X
E119  aa                      TAX
E11A  68                      PLA
E11B  18                      CLC
E11C  69 40                   ADC #$40
E11E  20 e2 de                JSR sub_DEE2
E121  60                      RTS
E122  a9 01      sub_E122:    LDA #$01
E124  85 5a                   STA $5A
E126  a6 5a      loc_E126:    LDX $5A
E128  b5 a0                   LDA $A0,X
E12A  10 31                   BPL loc_E15D
E12C  c9 e0                   CMP #$E0
E12E  b0 2d                   BCS loc_E15D
E130  b5 08                   LDA $08,X
E132  29 03                   AND #$03
E134  f0 27                   BEQ loc_E15D
E136  b5 a8                   LDA $A8,X
E138  29 c0                   AND #$C0
E13A  c9 40                   CMP #$40
E13C  d0 1c                   BNE loc_E15A
E13E  b5 cc                   LDA $CC,X
E140  f0 18                   BEQ loc_E15A
E142  b5 d4                   LDA $D4,X
E144  d0 17                   BNE loc_E15D
E146  b5 cc                   LDA $CC,X
E148  95 d4                   STA $D4,X
E14A  b5 b8                   LDA $B8,X
E14C  95 c0                   STA $C0,X
E14E  b5 c2                   LDA $C2,X
E150  95 ca                   STA $CA,X
E152  b5 d6                   LDA $D6,X
E154  95 de                   STA $DE,X
E156  a9 00                   LDA #$00
E158  95 cc                   STA $CC,X
E15A  20 8c e0   loc_E15A:    JSR sub_E08C
E15D  c6 5a      loc_E15D:    DEC $5A
E15F  10 c5                   BPL loc_E126
E161  60                      RTS
E162  ad 00 01   sub_E162:    LDA $0100
E165  d0 19                   BNE loc_E180
E167  a2 07                   LDX #$07
E169  b5 a0      loc_E169:    LDA $A0,X
E16B  10 0e                   BPL loc_E17B
E16D  c9 e0                   CMP #$E0
E16F  b0 0a                   BCS loc_E17B
E171  20 4d d4                JSR sub_D44D
E174  29 1f                   AND #$1F
E176  d0 03                   BNE loc_E17B
E178  20 8c e0                JSR sub_E08C
E17B  ca         loc_E17B:    DEX
E17C  e0 01                   CPX #$01
E17E  d0 e9                   BNE loc_E169
E180  60         loc_E180:    RTS
E181  a9 07      sub_E181:    LDA #$07
E183  85 5a                   STA $5A
E185  a6 5a      loc_E185:    LDX $5A
E187  b5 a0                   LDA $A0,X
E189  10 63                   BPL loc_E1EE
E18B  c9 e0                   CMP #$E0
E18D  b0 5f                   BCS loc_E1EE
E18F  b5 98                   LDA $98,X
E191  38                      SEC
E192  e9 08                   SBC #$08
E194  a8                      TAY
E195  b5 90                   LDA $90,X
E197  38                      SEC
E198  e9 08                   SBC #$08
E19A  aa                      TAX
E19B  20 06 d7                JSR sub_D706
E19E  a6 5a                   LDX $5A
E1A0  a5 11                   LDA $11
E1A2  95 e0                   STA $E0,X
E1A4  a5 12                   LDA $12
E1A6  29 03                   AND #$03
E1A8  95 e8                   STA $E8,X
E1AA  a0 21                   LDY #$21
E1AC  e0 02                   CPX #$02
E1AE  b0 19                   BCS loc_E1C9
E1B0  b1 11                   LDA ($11),Y
E1B2  c9 21                   CMP #$21
E1B4  d0 0b                   BNE loc_E1C1
E1B6  a9 80                   LDA #$80
E1B8  1d 03 01                ORA $0103,X
E1BB  9d 03 01                STA $0103,X
E1BE  4c c9 e1                JMP loc_E1C9
E1C1  bd 03 01   loc_E1C1:    LDA $0103,X
E1C4  29 7f                   AND #$7F
E1C6  9d 03 01                STA $0103,X
E1C9  20 f3 e1   loc_E1C9:    JSR sub_E1F3
E1CC  b5 90                   LDA $90,X
E1CE  29 07                   AND #$07
E1D0  d0 0b                   BNE loc_E1DD
E1D2  b5 e8                   LDA $E8,X
E1D4  09 80                   ORA #$80
E1D6  95 e8                   STA $E8,X
E1D8  a0 20                   LDY #$20
E1DA  20 f3 e1                JSR sub_E1F3
E1DD  b5 98      loc_E1DD:    LDA $98,X
E1DF  29 07                   AND #$07
E1E1  d0 0b                   BNE loc_E1EE
E1E3  b5 e8                   LDA $E8,X
E1E5  09 40                   ORA #$40
E1E7  95 e8                   STA $E8,X
E1E9  a0 01                   LDY #$01
E1EB  20 f3 e1                JSR sub_E1F3
E1EE  c6 5a      loc_E1EE:    DEC $5A
E1F0  10 93                   BPL loc_E185
E1F2  60                      RTS
E1F3  b1 11      sub_E1F3:    LDA ($11),Y
E1F5  09 80                   ORA #$80
E1F7  91 11                   STA ($11),Y
E1F9  60                      RTS
E1FA  a9 07      sub_E1FA:    LDA #$07
E1FC  85 5a                   STA $5A
E1FE  a6 5a      loc_E1FE:    LDX $5A
E200  b5 a0                   LDA $A0,X
E202  10 2b                   BPL loc_E22F
E204  c9 e0                   CMP #$E0
E206  b0 27                   BCS loc_E22F
E208  b5 e0                   LDA $E0,X
E20A  85 11                   STA $11
E20C  b5 e8                   LDA $E8,X
E20E  29 03                   AND #$03
E210  09 04                   ORA #$04
E212  85 12                   STA $12
E214  a0 21                   LDY #$21
E216  20 34 e2                JSR sub_E234
E219  b5 e8                   LDA $E8,X
E21B  29 80                   AND #$80
E21D  f0 05                   BEQ loc_E224
E21F  a0 20                   LDY #$20
E221  20 34 e2                JSR sub_E234
E224  b5 e8      loc_E224:    LDA $E8,X
E226  29 40                   AND #$40
E228  f0 05                   BEQ loc_E22F
E22A  a0 01                   LDY #$01
E22C  20 34 e2                JSR sub_E234
E22F  c6 5a      loc_E22F:    DEC $5A
E231  10 cb                   BPL loc_E1FE
E233  60                      RTS
E234  b1 11      sub_E234:    LDA ($11),Y
E236  29 7f                   AND #$7F
E238  91 11                   STA ($11),Y
E23A  60                      RTS
E23B  a5 86      sub_E23B:    LDA $86
E23D  f0 3c                   BEQ loc_E27B
E23F  a5 62                   LDA $62
E241  f0 16                   BEQ loc_E259
E243  c6 62                   DEC $62
E245  d0 07                   BNE loc_E24E
E247  a9 00                   LDA #$00
E249  85 86                   STA $86
E24B  4c 7b e2                JMP loc_E27B
E24E  a9 02      loc_E24E:    LDA #$02
E250  85 04                   STA $04
E252  a9 3b                   LDA #$3B
E254  85 53                   STA $53
E256  4c 6c e2                JMP sub_E26C
E259  a5 0b      loc_E259:    LDA $0B
E25B  29 08                   AND #$08
E25D  f0 1c                   BEQ loc_E27B
E25F  a9 02                   LDA #$02
E261  85 04                   STA $04
E263  a5 88                   LDA $88
E265  0a                      ASL A
E266  0a                      ASL A
E267  18                      CLC
E268  69 81                   ADC #$81
E26A  85 53                   STA $53
E26C  a6 86      sub_E26C:    LDX $86
E26E  a4 87                   LDY $87
E270  a9 00                   LDA #$00
E272  85 6e                   STA $6E
E274  20 7b da                JSR sub_DA7B
E277  a9 20                   LDA #$20
E279  85 6e                   STA $6E
E27B  60         loc_E27B:    RTS
E27C  a9 01      sub_E27C:    LDA #$01
E27E  85 5a                   STA $5A
E280  a6 5a      loc_E280:    LDX $5A
E282  b5 89                   LDA $89,X
E284  f0 1e                   BEQ loc_E2A4
E286  a5 0b                   LDA $0B
E288  29 3f                   AND #$3F
E28A  d0 02                   BNE loc_E28E
E28C  d6 89                   DEC $89,X
E28E  a9 02      loc_E28E:    LDA #$02
E290  85 04                   STA $04
E292  b4 98                   LDY $98,X
E294  b5 90                   LDA $90,X
E296  aa                      TAX
E297  a5 0b                   LDA $0B
E299  29 02                   AND #$02
E29B  0a                      ASL A
E29C  18                      CLC
E29D  69 29                   ADC #$29
E29F  85 53                   STA $53
E2A1  20 7b da                JSR sub_DA7B
E2A4  c6 5a      loc_E2A4:    DEC $5A
E2A6  10 d8                   BPL loc_E280
E2A8  60                      RTS
E2A9  a5 45      sub_E2A9:    LDA $45
E2AB  f0 25                   BEQ loc_E2D2
E2AD  a5 0b                   LDA $0B
E2AF  29 0f                   AND #$0F
E2B1  d0 1f                   BNE loc_E2D2
E2B3  a5 0b                   LDA $0B
E2B5  29 3f                   AND #$3F
E2B7  d0 04                   BNE loc_E2BD
E2B9  c6 45                   DEC $45
E2BB  f0 12                   BEQ loc_E2CF
E2BD  a5 45      loc_E2BD:    LDA $45
E2BF  c9 04                   CMP #$04
E2C1  b0 0f                   BCS loc_E2D2
E2C3  a5 0b                   LDA $0B
E2C5  29 10                   AND #$10
E2C7  f0 06                   BEQ loc_E2CF
E2C9  20 9e cb                JSR sub_CB9E
E2CC  4c d2 e2                JMP loc_E2D2
E2CF  20 f5 ca   loc_E2CF:    JSR sub_CAF5
E2D2  a5 68      loc_E2D2:    LDA $68
E2D4  f0 2f                   BEQ loc_E305
E2D6  30 2d                   BMI loc_E305
E2D8  a9 03                   LDA #$03
E2DA  85 04                   STA $04
E2DC  c6 68                   DEC $68
E2DE  a5 68                   LDA $68
E2E0  4a                      LSR A
E2E1  4a                      LSR A
E2E2  38                      SEC
E2E3  e9 05                   SBC #$05
E2E5  10 05                   BPL loc_E2EC
E2E7  49 ff                   EOR #$FF
E2E9  18                      CLC
E2EA  69 01                   ADC #$01
E2EC  38         loc_E2EC:    SEC
E2ED  e9 05                   SBC #$05
E2EF  10 05                   BPL loc_E2F6
E2F1  49 ff                   EOR #$FF
E2F3  18                      CLC
E2F4  69 01                   ADC #$01
E2F6  0a         loc_E2F6:    ASL A
E2F7  a8                      TAY
E2F8  b9 06 e3                LDA $E306,Y
E2FB  85 11                   STA $11
E2FD  b9 07 e3                LDA $E307,Y
E300  85 12                   STA $12
E302  6c 11 00                JMP ($0011)
E305  60         loc_E305:    RTS

; ---- $E306..$E311 (12 bytes: data) ----
E312  a9 f1                   LDA #$F1
E314  4c 1e e3                JMP sub_E31E
E317  a9 f5                   LDA #$F5
E319  4c 1e e3                JMP sub_E31E
E31C  a9 f9                   LDA #$F9
E31E  a2 78      sub_E31E:    LDX #$78
E320  a0 d8                   LDY #$D8
E322  85 53      sub_E322:    STA $53
E324  20 7b da                JSR sub_DA7B
E327  60                      RTS
E328  18         sub_E328:    CLC
E329  65 69                   ADC $69
E32B  4c 22 e3                JMP sub_E322
E32E  a9 00                   LDA #$00
E330  85 69                   STA $69
E332  20 3e e3                JSR sub_E33E
E335  60                      RTS
E336  a9 10                   LDA #$10
E338  85 69                   STA $69
E33A  20 3e e3                JSR sub_E33E
E33D  60                      RTS
E33E  a2 70      sub_E33E:    LDX #$70
E340  a0 d0                   LDY #$D0
E342  a9 d1                   LDA #$D1
E344  20 28 e3                JSR sub_E328
E347  a2 80                   LDX #$80
E349  a0 d0                   LDY #$D0
E34B  a9 d5                   LDA #$D5
E34D  20 28 e3                JSR sub_E328
E350  a2 70                   LDX #$70
E352  a0 e0                   LDY #$E0
E354  a9 d9                   LDA #$D9
E356  20 28 e3                JSR sub_E328
E359  a2 80                   LDX #$80
E35B  a0 e0                   LDY #$E0
E35D  a9 dd                   LDA #$DD
E35F  20 28 e3                JSR sub_E328
E362  60                      RTS
E363  a9 00      sub_E363:    LDA #$00
E365  95 a8                   STA $A8,X
E367  e0 02                   CPX #$02
E369  b0 11                   BCS loc_E37C
E36B  bd 7a e4                LDA $E47A,X
E36E  95 90                   STA $90,X
E370  bd 7c e4                LDA $E47C,X
E373  95 98                   STA $98,X
E375  a9 00                   LDA #$00
E377  95 6f                   STA $6F,X
E379  4c a9 e3                JMP sub_E3A9
E37C  e6 6a      loc_E37C:    INC $6A
E37E  a4 6a                   LDY $6A
E380  c0 03                   CPY #$03
E382  d0 05                   BNE loc_E389
E384  a9 00                   LDA #$00
E386  85 6a                   STA $6A
E388  a8                      TAY
E389  b9 74 e4   loc_E389:    LDA $E474,Y
E38C  95 90                   STA $90,X
E38E  b9 77 e4                LDA $E477,Y
E391  95 98                   STA $98,X
E393  a5 7f                   LDA $7F
E395  c9 03                   CMP #$03
E397  f0 08                   BEQ loc_E3A1
E399  c9 0a                   CMP #$0A
E39B  f0 04                   BEQ loc_E3A1
E39D  c9 11                   CMP #$11
E39F  d0 08                   BNE sub_E3A9
E3A1  a9 04      loc_E3A1:    LDA #$04
E3A3  95 a8                   STA $A8,X
E3A5  a9 00                   LDA #$00
E3A7  85 86                   STA $86
E3A9  a9 f0      sub_E3A9:    LDA #$F0
E3AB  95 a0                   STA $A0,X
E3AD  b4 98                   LDY $98,X
E3AF  b5 90                   LDA $90,X
E3B1  aa                      TAX
E3B2  a9 0f                   LDA #$0F
E3B4  20 0b d8                JSR sub_D80B
E3B7  60                      RTS
E3B8  bd 7e e4   sub_E3B8:    LDA $E47E,X
E3BB  95 a0                   STA $A0,X
E3BD  e0 02                   CPX #$02
E3BF  b0 0a                   BCS loc_E3CB
E3C1  a9 03                   LDA #$03
E3C3  95 89                   STA $89,X
E3C5  bd 01 01                LDA $0101,X
E3C8  4c fa e3                JMP sub_E3FA
E3CB  a4 8f      loc_E3CB:    LDY $8F
E3CD  b9 8b 00                LDA $008B,Y
E3D0  d0 05                   BNE loc_E3D7
E3D2  e6 8f                   INC $8F
E3D4  4c cb e3                JMP loc_E3CB
E3D7  38         loc_E3D7:    SEC
E3D8  e9 01                   SBC #$01
E3DA  99 8b 00                STA $008B,Y
E3DD  a5 46                   LDA $46
E3DF  f0 05                   BEQ loc_E3E6
E3E1  a9 23                   LDA #$23
E3E3  4c e8 e3                JMP sub_E3E8
E3E6  a5 85      loc_E3E6:    LDA $85
E3E8  38         sub_E3E8:    SEC
E3E9  e9 01                   SBC #$01
E3EB  0a                      ASL A
E3EC  0a                      ASL A
E3ED  18                      CLC
E3EE  65 8f                   ADC $8F
E3F0  a8                      TAY
E3F1  b9 ec e4                LDA $E4EC,Y
E3F4  c9 e0                   CMP #$E0
E3F6  d0 02                   BNE sub_E3FA
E3F8  09 03                   ORA #$03
E3FA  15 a8      sub_E3FA:    ORA $A8,X
E3FC  c9 e7                   CMP #$E7
E3FE  d0 02                   BNE loc_E402
E400  a9 e4                   LDA #$E4
E402  95 a8      loc_E402:    STA $A8,X
E404  a9 00                   LDA #$00
E406  95 b0                   STA $B0,X
E408  60                      RTS
E409  a2 09      sub_E409:    LDX #$09
E40B  a9 00                   LDA #$00
E40D  95 cc      loc_E40D:    STA $CC,X
E40F  ca                      DEX
E410  10 fb                   BPL loc_E40D
E412  60                      RTS
E413  a9 00      sub_E413:    LDA #$00
E415  a2 07                   LDX #$07
E417  95 a0      loc_E417:    STA $A0,X
E419  9d 03 01                STA $0103,X
E41C  ca                      DEX
E41D  10 f8                   BPL loc_E417
E41F  60                      RTS
E420  85 00      sub_E420:    STA $00
E422  b5 a0                   LDA $A0,X
E424  29 0f                   AND #$0F
E426  05 00                   ORA $00
E428  95 a0                   STA $A0,X
E42A  60                      RTS
E42B  a5 46      sub_E42B:    LDA $46
E42D  f0 05                   BEQ loc_E434
E42F  a9 23                   LDA #$23
E431  4c 36 e4                JMP sub_E436
E434  a5 85      loc_E434:    LDA $85
E436  38         sub_E436:    SEC
E437  e9 01                   SBC #$01
E439  0a                      ASL A
E43A  0a                      ASL A
E43B  a8                      TAY
E43C  b9 78 e5                LDA $E578,Y
E43F  85 8b                   STA $8B
E441  b9 79 e5                LDA $E579,Y
E444  85 8c                   STA $8C
E446  b9 7a e5                LDA $E57A,Y
E449  85 8d                   STA $8D
E44B  b9 7b e5                LDA $E57B,Y
E44E  85 8e                   STA $8E
E450  60                      RTS
E451  0a         sub_E451:    ASL A
E452  90 03                   BCC loc_E457
E454  a9 03                   LDA #$03
E456  60                      RTS
E457  0a         loc_E457:    ASL A
E458  90 03                   BCC loc_E45D
E45A  a9 01                   LDA #$01
E45C  60                      RTS
E45D  0a         loc_E45D:    ASL A
E45E  90 03                   BCC loc_E463
E460  a9 02                   LDA #$02
E462  60                      RTS
E463  0a         loc_E463:    ASL A
E464  90 03                   BCC loc_E469
E466  a9 00                   LDA #$00
E468  60                      RTS
E469  a9 ff      loc_E469:    LDA #$FF
E46B  60                      RTS

; ---- $E46C..$E603 (408 bytes: data) ----
E604  a9 09      sub_E604:    LDA #$09
E606  85 5a                   STA $5A
E608  a6 5a      sub_E608:    LDX $5A
E60A  b5 cc                   LDA $CC,X
E60C  29 f0                   AND #$F0
E60E  c9 40                   CMP #$40
E610  d0 79                   BNE loc_E68B
E612  b5 d6                   LDA $D6,X
E614  d0 07                   BNE loc_E61D
E616  8a                      TXA
E617  45 0b                   EOR $0B
E619  29 01                   AND #$01
E61B  f0 6e                   BEQ loc_E68B
E61D  b5 cc      loc_E61D:    LDA $CC,X
E61F  29 03                   AND #$03
E621  a8                      TAY
E622  b9 49 ea                LDA $EA49,Y
E625  10 05                   BPL loc_E62C
E627  49 ff                   EOR #$FF
E629  18                      CLC
E62A  69 01                   ADC #$01
E62C  85 54      loc_E62C:    STA $54
E62E  0a                      ASL A
E62F  0a                      ASL A
E630  85 64                   STA $64
E632  b9 4d ea                LDA $EA4D,Y
E635  10 05                   BPL loc_E63C
E637  49 ff                   EOR #$FF
E639  18                      CLC
E63A  69 01                   ADC #$01
E63C  85 55      loc_E63C:    STA $55
E63E  0a                      ASL A
E63F  0a                      ASL A
E640  85 65                   STA $65
E642  b4 c2                   LDY $C2,X
E644  b5 b8                   LDA $B8,X
E646  aa                      TAX
E647  20 93 e6                JSR sub_E693
E64A  f0 13                   BEQ loc_E65F
E64C  a6 5a                   LDX $5A
E64E  b5 c2                   LDA $C2,X
E650  18                      CLC
E651  65 64                   ADC $64
E653  85 48                   STA $48
E655  b5 b8                   LDA $B8,X
E657  18                      CLC
E658  65 65                   ADC $65
E65A  85 47                   STA $47
E65C  20 9a e6                JSR sub_E69A
E65F  a6 5a      loc_E65F:    LDX $5A
E661  b5 c2                   LDA $C2,X
E663  38                      SEC
E664  e5 54                   SBC $54
E666  a8                      TAY
E667  b5 b8                   LDA $B8,X
E669  38                      SEC
E66A  e5 55                   SBC $55
E66C  aa                      TAX
E66D  20 93 e6                JSR sub_E693
E670  f0 19                   BEQ loc_E68B
E672  a6 5a                   LDX $5A
E674  b5 c2                   LDA $C2,X
E676  38                      SEC
E677  e5 64                   SBC $64
E679  38                      SEC
E67A  e5 54                   SBC $54
E67C  85 48                   STA $48
E67E  b5 b8                   LDA $B8,X
E680  38                      SEC
E681  e5 65                   SBC $65
E683  38                      SEC
E684  e5 55                   SBC $55
E686  85 47                   STA $47
E688  20 9a e6                JSR sub_E69A
E68B  c6 5a      loc_E68B:    DEC $5A
E68D  30 03                   BMI loc_E692
E68F  4c 08 e6                JMP sub_E608
E692  60         loc_E692:    RTS
E693  86 47      sub_E693:    STX $47
E695  84 48                   STY $48
E697  20 06 d7                JSR sub_D706
E69A  20 25 d7   sub_E69A:    JSR sub_D725
E69D  20 3c d7                JSR sub_D73C
E6A0  f0 67                   BEQ loc_E709
E6A2  b1 11                   LDA ($11),Y
E6A4  29 fc                   AND #$FC
E6A6  c9 c8                   CMP #$C8
E6A8  d0 1c                   BNE loc_E6C6
E6AA  a5 68                   LDA $68
E6AC  f0 18                   BEQ loc_E6C6
E6AE  a9 27                   LDA #$27
E6B0  85 68                   STA $68
E6B2  a9 01                   LDA #$01
E6B4  8d 0b 03                STA $030B
E6B7  8d 07 03                STA $0307
E6BA  20 08 cc                JSR sub_CC08
E6BD  a6 5a                   LDX $5A
E6BF  a9 33                   LDA #$33
E6C1  95 cc                   STA $CC,X
E6C3  4c 09 e7                JMP loc_E709
E6C6  b1 11      loc_E6C6:    LDA ($11),Y
E6C8  c9 12                   CMP #$12
E6CA  b0 3d                   BCS loc_E709
E6CC  a6 5a                   LDX $5A
E6CE  a9 33                   LDA #$33
E6D0  95 cc                   STA $CC,X
E6D2  b1 11                   LDA ($11),Y
E6D4  c9 11                   CMP #$11
E6D6  f0 28                   BEQ loc_E700
E6D8  b5 d6                   LDA $D6,X
E6DA  29 02                   AND #$02
E6DC  f0 0d                   BEQ loc_E6EB
E6DE  a9 00                   LDA #$00
E6E0  20 84 d7                JSR sub_D784
E6E3  a9 01                   LDA #$01
E6E5  8d 0c 03                STA $030C
E6E8  4c 09 e7                JMP loc_E709
E6EB  b1 11      loc_E6EB:    LDA ($11),Y
E6ED  c9 10                   CMP #$10
E6EF  f0 0f                   BEQ loc_E700
E6F1  e0 02                   CPX #$02
E6F3  b0 05                   BCS loc_E6FA
E6F5  a9 01                   LDA #$01
E6F7  8d 0c 03                STA $030C
E6FA  20 43 d7   loc_E6FA:    JSR sub_D743
E6FD  a9 01                   LDA #$01
E6FF  60                      RTS
E700  e0 02      loc_E700:    CPX #$02
E702  b0 05                   BCS loc_E709
E704  a9 01                   LDA #$01
E706  8d 0d 03                STA $030D
E709  a9 00      loc_E709:    LDA #$00
E70B  60                      RTS
E70C  a9 01      sub_E70C:    LDA #$01
E70E  85 5a                   STA $5A
E710  a6 5a      loc_E710:    LDX $5A
E712  b5 a0                   LDA $A0,X
E714  10 04                   BPL loc_E71A
E716  c9 e0                   CMP #$E0
E718  90 03                   BCC loc_E71D
E71A  4c 7a e7   loc_E71A:    JMP sub_E77A
E71D  a9 07      loc_E71D:    LDA #$07
E71F  85 5b                   STA $5B
E721  a4 5b      loc_E721:    LDY $5B
E723  b9 cc 00                LDA $00CC,Y
E726  29 f0                   AND #$F0
E728  c9 40                   CMP #$40
E72A  d0 46                   BNE loc_E772
E72C  b9 b8 00                LDA $00B8,Y
E72F  38                      SEC
E730  f5 90                   SBC $90,X
E732  10 05                   BPL loc_E739
E734  49 ff                   EOR #$FF
E736  18                      CLC
E737  69 01                   ADC #$01
E739  c9 0a      loc_E739:    CMP #$0A
E73B  b0 35                   BCS loc_E772
E73D  b9 c2 00                LDA $00C2,Y
E740  38                      SEC
E741  f5 98                   SBC $98,X
E743  10 05                   BPL loc_E74A
E745  49 ff                   EOR #$FF
E747  18                      CLC
E748  69 01                   ADC #$01
E74A  c9 0a      loc_E74A:    CMP #$0A
E74C  b0 24                   BCS loc_E772
E74E  a9 33                   LDA #$33
E750  99 cc 00                STA $00CC,Y
E753  b5 89                   LDA $89,X
E755  f0 08                   BEQ loc_E75F
E757  a9 00                   LDA #$00
E759  99 cc 00                STA $00CC,Y
E75C  4c 72 e7                JMP loc_E772
E75F  a9 73      loc_E75F:    LDA #$73
E761  95 a0                   STA $A0,X
E763  a9 01                   LDA #$01
E765  8d 07 03                STA $0307
E768  a9 00                   LDA #$00
E76A  9d 01 01                STA $0101,X
E76D  95 a8                   STA $A8,X
E76F  4c 7a e7                JMP sub_E77A
E772  c6 5b      loc_E772:    DEC $5B
E774  a5 5b                   LDA $5B
E776  c9 01                   CMP #$01
E778  d0 a7                   BNE loc_E721
E77A  c6 5a      sub_E77A:    DEC $5A
E77C  10 92                   BPL loc_E710
E77E  a9 07                   LDA #$07
E780  85 5a                   STA $5A
E782  a6 5a      sub_E782:    LDX $5A
E784  b5 a0                   LDA $A0,X
E786  10 04                   BPL loc_E78C
E788  c9 e0                   CMP #$E0
E78A  90 03                   BCC loc_E78F
E78C  4c 34 e8   loc_E78C:    JMP sub_E834
E78F  a9 09      loc_E78F:    LDA #$09
E791  85 5b                   STA $5B
E793  a5 5b      sub_E793:    LDA $5B
E795  29 06                   AND #$06
E797  f0 03                   BEQ loc_E79C
E799  4c 2d e8                JMP sub_E82D
E79C  a4 5b      loc_E79C:    LDY $5B
E79E  b9 cc 00                LDA $00CC,Y
E7A1  29 f0                   AND #$F0
E7A3  c9 40                   CMP #$40
E7A5  f0 03                   BEQ loc_E7AA
E7A7  4c 2d e8                JMP sub_E82D
E7AA  b9 b8 00   loc_E7AA:    LDA $00B8,Y
E7AD  38                      SEC
E7AE  f5 90                   SBC $90,X
E7B0  10 05                   BPL loc_E7B7
E7B2  49 ff                   EOR #$FF
E7B4  18                      CLC
E7B5  69 01                   ADC #$01
E7B7  c9 0a      loc_E7B7:    CMP #$0A
E7B9  b0 72                   BCS sub_E82D
E7BB  b9 c2 00                LDA $00C2,Y
E7BE  38                      SEC
E7BF  f5 98                   SBC $98,X
E7C1  10 05                   BPL loc_E7C8
E7C3  49 ff                   EOR #$FF
E7C5  18                      CLC
E7C6  69 01                   ADC #$01
E7C8  c9 0a      loc_E7C8:    CMP #$0A
E7CA  b0 61                   BCS sub_E82D
E7CC  a9 33                   LDA #$33
E7CE  99 cc 00                STA $00CC,Y
E7D1  b5 a8                   LDA $A8,X
E7D3  29 04                   AND #$04
E7D5  f0 0b                   BEQ loc_E7E2
E7D7  20 be e8                JSR sub_E8BE
E7DA  b5 a8                   LDA $A8,X
E7DC  c9 e4                   CMP #$E4
E7DE  d0 02                   BNE loc_E7E2
E7E0  d6 a8                   DEC $A8,X
E7E2  b5 a8      loc_E7E2:    LDA $A8,X
E7E4  29 03                   AND #$03
E7E6  f0 0a                   BEQ loc_E7F2
E7E8  d6 a8                   DEC $A8,X
E7EA  a9 01                   LDA #$01
E7EC  8d 0e 03                STA $030E
E7EF  4c 2d e8                JMP sub_E82D
E7F2  a9 73      loc_E7F2:    LDA #$73
E7F4  95 a0                   STA $A0,X
E7F6  a9 01                   LDA #$01
E7F8  8d 0a 03                STA $030A
E7FB  b5 a8                   LDA $A8,X
E7FD  4a                      LSR A
E7FE  4a                      LSR A
E7FF  4a                      LSR A
E800  4a                      LSR A
E801  4a                      LSR A
E802  38                      SEC
E803  e9 04                   SBC #$04
E805  aa                      TAX
E806  a5 5b                   LDA $5B
E808  29 01                   AND #$01
E80A  85 47                   STA $47
E80C  d0 05                   BNE loc_E813
E80E  f6 73                   INC $73,X
E810  4c 15 e8                JMP sub_E815
E813  f6 77      loc_E813:    INC $77,X
E815  a5 46      sub_E815:    LDA $46
E817  c9 02                   CMP #$02
E819  f0 19                   BEQ sub_E834
E81B  bd ba e8                LDA $E8BA,X
E81E  20 e1 d9                JSR sub_D9E1
E821  a5 47                   LDA $47
E823  aa                      TAX
E824  20 be d9                JSR sub_D9BE
E827  20 38 d1                JSR sub_D138
E82A  4c 34 e8                JMP sub_E834
E82D  c6 5b      sub_E82D:    DEC $5B
E82F  30 03                   BMI sub_E834
E831  4c 93 e7                JMP sub_E793
E834  c6 5a      sub_E834:    DEC $5A
E836  a5 5a                   LDA $5A
E838  c9 01                   CMP #$01
E83A  f0 03                   BEQ loc_E83F
E83C  4c 82 e7                JMP sub_E782
E83F  a9 01      loc_E83F:    LDA #$01
E841  85 5a                   STA $5A
E843  a6 5a      loc_E843:    LDX $5A
E845  b5 a0                   LDA $A0,X
E847  10 04                   BPL loc_E84D
E849  c9 e0                   CMP #$E0
E84B  90 03                   BCC loc_E850
E84D  4c b5 e8   loc_E84D:    JMP sub_E8B5
E850  a9 09      loc_E850:    LDA #$09
E852  85 5b                   STA $5B
E854  a5 5b      loc_E854:    LDA $5B
E856  29 06                   AND #$06
E858  d0 57                   BNE loc_E8B1
E85A  a4 5b                   LDY $5B
E85C  b9 cc 00                LDA $00CC,Y
E85F  29 f0                   AND #$F0
E861  c9 40                   CMP #$40
E863  d0 4c                   BNE loc_E8B1
E865  a5 5a                   LDA $5A
E867  45 5b                   EOR $5B
E869  29 01                   AND #$01
E86B  f0 44                   BEQ loc_E8B1
E86D  b9 b8 00                LDA $00B8,Y
E870  38                      SEC
E871  f5 90                   SBC $90,X
E873  10 05                   BPL loc_E87A
E875  49 ff                   EOR #$FF
E877  18                      CLC
E878  69 01                   ADC #$01
E87A  c9 0a      loc_E87A:    CMP #$0A
E87C  b0 33                   BCS loc_E8B1
E87E  b9 c2 00                LDA $00C2,Y
E881  38                      SEC
E882  f5 98                   SBC $98,X
E884  10 05                   BPL loc_E88B
E886  49 ff                   EOR #$FF
E888  18                      CLC
E889  69 01                   ADC #$01
E88B  c9 0a      loc_E88B:    CMP #$0A
E88D  b0 22                   BCS loc_E8B1
E88F  a9 33                   LDA #$33
E891  99 cc 00                STA $00CC,Y
E894  b5 89                   LDA $89,X
E896  f0 08                   BEQ loc_E8A0
E898  a9 00                   LDA #$00
E89A  99 cc 00                STA $00CC,Y
E89D  4c b1 e8                JMP loc_E8B1
E8A0  b5 6f      loc_E8A0:    LDA $6F,X
E8A2  d0 0d                   BNE loc_E8B1
E8A4  a5 46                   LDA $46
E8A6  c9 02                   CMP #$02
E8A8  f0 07                   BEQ loc_E8B1
E8AA  a9 c8                   LDA #$C8
E8AC  95 6f                   STA $6F,X
E8AE  4c b5 e8                JMP sub_E8B5
E8B1  c6 5b      loc_E8B1:    DEC $5B
E8B3  10 9f                   BPL loc_E854
E8B5  c6 5a      sub_E8B5:    DEC $5A
E8B7  10 8a                   BPL loc_E843
E8B9  60                      RTS

; ---- $E8BA..$E8BD (4 bytes: data) ----
E8BE  a9 01      sub_E8BE:    LDA #$01
E8C0  8d 09 03                STA $0309
E8C3  20 4d d4   loc_E8C3:    JSR sub_D44D
E8C6  29 03                   AND #$03
E8C8  20 02 e9                JSR sub_E902
E8CB  85 86                   STA $86
E8CD  20 4d d4                JSR sub_D44D
E8D0  29 03                   AND #$03
E8D2  20 02 e9                JSR sub_E902
E8D5  85 87                   STA $87
E8D7  a9 ff                   LDA #$FF
E8D9  85 88                   STA $88
E8DB  a9 00                   LDA #$00
E8DD  85 62                   STA $62
E8DF  20 72 e9                JSR sub_E972
E8E2  a5 62                   LDA $62
E8E4  d0 dd                   BNE loc_E8C3
E8E6  20 4d d4                JSR sub_D44D
E8E9  29 07                   AND #$07
E8EB  a8                      TAY
E8EC  b9 fa e8                LDA $E8FA,Y
E8EF  85 88                   STA $88
E8F1  a9 00                   LDA #$00
E8F3  85 62                   STA $62
E8F5  a6 5a                   LDX $5A
E8F7  a4 5b                   LDY $5B
E8F9  60                      RTS

; ---- $E8FA..$E901 (8 bytes: data) ----
E902  85 00      sub_E902:    STA $00
E904  0a                      ASL A
E905  18                      CLC
E906  65 00                   ADC $00
E908  0a                      ASL A
E909  18                      CLC
E90A  69 06                   ADC #$06
E90C  0a                      ASL A
E90D  0a                      ASL A
E90E  0a                      ASL A
E90F  60                      RTS
E910  a9 09      sub_E910:    LDA #$09
E912  85 5a                   STA $5A
E914  a5 5a      loc_E914:    LDA $5A
E916  29 06                   AND #$06
E918  d0 53                   BNE loc_E96D
E91A  a6 5a                   LDX $5A
E91C  b5 cc                   LDA $CC,X
E91E  29 f0                   AND #$F0
E920  c9 40                   CMP #$40
E922  d0 49                   BNE loc_E96D
E924  a9 09                   LDA #$09
E926  85 5b                   STA $5B
E928  a5 5b      loc_E928:    LDA $5B
E92A  a8                      TAY
E92B  29 07                   AND #$07
E92D  85 00                   STA $00
E92F  a5 5a                   LDA $5A
E931  29 07                   AND #$07
E933  c5 00                   CMP $00
E935  f0 32                   BEQ loc_E969
E937  b9 cc 00                LDA $00CC,Y
E93A  29 f0                   AND #$F0
E93C  c9 40                   CMP #$40
E93E  d0 29                   BNE loc_E969
E940  b9 b8 00                LDA $00B8,Y
E943  38                      SEC
E944  f5 b8                   SBC $B8,X
E946  10 05                   BPL loc_E94D
E948  49 ff                   EOR #$FF
E94A  18                      CLC
E94B  69 01                   ADC #$01
E94D  c9 06      loc_E94D:    CMP #$06
E94F  b0 18                   BCS loc_E969
E951  b9 c2 00                LDA $00C2,Y
E954  38                      SEC
E955  f5 c2                   SBC $C2,X
E957  10 05                   BPL loc_E95E
E959  49 ff                   EOR #$FF
E95B  18                      CLC
E95C  69 01                   ADC #$01
E95E  c9 06      loc_E95E:    CMP #$06
E960  b0 07                   BCS loc_E969
E962  a9 00                   LDA #$00
E964  95 cc                   STA $CC,X
E966  99 cc 00                STA $00CC,Y
E969  c6 5b      loc_E969:    DEC $5B
E96B  10 bb                   BPL loc_E928
E96D  c6 5a      loc_E96D:    DEC $5A
E96F  10 a3                   BPL loc_E914
E971  60                      RTS
E972  a5 86      sub_E972:    LDA $86
E974  f0 6b                   BEQ loc_E9E1
E976  a5 62                   LDA $62
E978  d0 67                   BNE loc_E9E1
E97A  a9 01                   LDA #$01
E97C  85 49                   STA $49
E97E  a6 49      loc_E97E:    LDX $49
E980  b5 a0                   LDA $A0,X
E982  10 59                   BPL loc_E9DD
E984  c9 e0                   CMP #$E0
E986  b0 55                   BCS loc_E9DD
E988  b5 90                   LDA $90,X
E98A  38                      SEC
E98B  e5 86                   SBC $86
E98D  10 05                   BPL loc_E994
E98F  49 ff                   EOR #$FF
E991  18                      CLC
E992  69 01                   ADC #$01
E994  c9 0c      loc_E994:    CMP #$0C
E996  b0 45                   BCS loc_E9DD
E998  b5 98                   LDA $98,X
E99A  38                      SEC
E99B  e5 87                   SBC $87
E99D  10 05                   BPL loc_E9A4
E99F  49 ff                   EOR #$FF
E9A1  18                      CLC
E9A2  69 01                   ADC #$01
E9A4  c9 0c      loc_E9A4:    CMP #$0C
E9A6  b0 35                   BCS loc_E9DD
E9A8  a9 32                   LDA #$32
E9AA  85 62                   STA $62
E9AC  a5 88                   LDA $88
E9AE  30 31                   BMI loc_E9E1
E9B0  a5 46                   LDA $46
E9B2  c9 02                   CMP #$02
E9B4  f0 14                   BEQ loc_E9CA
E9B6  a9 50                   LDA #$50
E9B8  20 e1 d9                JSR sub_D9E1
E9BB  a6 49                   LDX $49
E9BD  20 be d9                JSR sub_D9BE
E9C0  20 38 d1                JSR sub_D138
E9C3  a6 49                   LDX $49
E9C5  a9 01                   LDA #$01
E9C7  8d 06 03                STA $0306
E9CA  a5 88      loc_E9CA:    LDA $88
E9CC  0a                      ASL A
E9CD  a8                      TAY
E9CE  b9 e2 e9                LDA $E9E2,Y
E9D1  85 11                   STA $11
E9D3  b9 e3 e9                LDA $E9E3,Y
E9D6  85 12                   STA $12
E9D8  68                      PLA
E9D9  68                      PLA
E9DA  6c 11 00                JMP ($0011)
E9DD  c6 49      loc_E9DD:    DEC $49
E9DF  10 9d                   BPL loc_E97E
E9E1  60         loc_E9E1:    RTS

; ---- $E9E2..$E9EF (14 bytes: data) ----
E9F0  a9 0a                   LDA #$0A
E9F2  95 89                   STA $89,X
E9F4  60                      RTS
E9F5  a9 0a                   LDA #$0A
E9F7  8d 00 01                STA $0100
E9FA  60                      RTS
E9FB  a5 68                   LDA $68
E9FD  10 07                   BPL loc_EA06
E9FF  20 9e cb                JSR sub_CB9E
EA02  a9 14                   LDA #$14
EA04  85 45                   STA $45
EA06  60         loc_EA06:    RTS
EA07  bd 01 01                LDA $0101,X
EA0A  c9 60                   CMP #$60
EA0C  f0 08                   BEQ loc_EA16
EA0E  18                      CLC
EA0F  69 20                   ADC #$20
EA11  9d 01 01                STA $0101,X
EA14  95 a8                   STA $A8,X
EA16  60         loc_EA16:    RTS
EA17  a9 07                   LDA #$07
EA19  85 5a                   STA $5A
EA1B  a9 01                   LDA #$01
EA1D  8d 0a 03                STA $030A
EA20  a4 5a      loc_EA20:    LDY $5A
EA22  b9 a0 00                LDA $00A0,Y
EA25  10 0e                   BPL loc_EA35
EA27  c9 e0                   CMP #$E0
EA29  b0 0a                   BCS loc_EA35
EA2B  a9 73                   LDA #$73
EA2D  99 a0 00                STA $00A0,Y
EA30  a9 00                   LDA #$00
EA32  99 a8 00                STA $00A8,Y
EA35  c6 5a      loc_EA35:    DEC $5A
EA37  a5 5a                   LDA $5A
EA39  c9 01                   CMP #$01
EA3B  d0 e3                   BNE loc_EA20
EA3D  60                      RTS
EA3E  f6 51                   INC $51,X
EA40  a9 01                   LDA #$01
EA42  8d 04 03                STA $0304
EA45  8d 05 03                STA $0305
EA48  60                      RTS

; ---- $EA49..$EA50 (8 bytes: data) ----
EA51  a9 0f      sub_EA51:    LDA #$0F
EA53  8d 15 40                STA $4015  ; APUSTATUS
EA56  a9 c0                   LDA #$C0
EA58  8d 17 40                STA $4017  ; JOY2
EA5B  a9 1c                   LDA #$1C
EA5D  85 f0                   STA $F0
EA5F  a9 03                   LDA #$03
EA61  85 f1                   STA $F1
EA63  a2 00                   LDX #$00
EA65  a0 00                   LDY #$00
EA67  98         loc_EA67:    TYA
EA68  91 f0                   STA ($F0),Y
EA6A  9d 00 03                STA $0300,X
EA6D  18                      CLC
EA6E  a5 f0                   LDA $F0
EA70  69 08                   ADC #$08
EA72  85 f0                   STA $F0
EA74  90 02                   BCC loc_EA78
EA76  e6 f1                   INC $F1
EA78  e8         loc_EA78:    INX
EA79  e0 1c                   CPX #$1C
EA7B  d0 ea                   BNE loc_EA67
EA7D  60                      RTS
EA7E  a5 6d      sub_EA7E:    LDA $6D
EA80  d0 06                   BNE loc_EA88
EA82  a9 1c                   LDA #$1C
EA84  85 f5                   STA $F5
EA86  10 04                   BPL loc_EA8C
EA88  a9 01      loc_EA88:    LDA #$01
EA8A  85 f5                   STA $F5
EA8C  a9 00      loc_EA8C:    LDA #$00
EA8E  a2 03                   LDX #$03
EA90  95 f9      loc_EA90:    STA $F9,X
EA92  ca                      DEX
EA93  10 fb                   BPL loc_EA90
EA95  a9 00                   LDA #$00
EA97  85 f4                   STA $F4
EA99  a9 1c                   LDA #$1C
EA9B  85 f0                   STA $F0
EA9D  a9 03                   LDA #$03
EA9F  85 f1                   STA $F1
EAA1  a6 f4      loc_EAA1:    LDX $F4
EAA3  bd 00 03                LDA $0300,X
EAA6  f0 3b                   BEQ loc_EAE3
EAA8  a0 00                   LDY #$00
EAAA  b1 f0                   LDA ($F0),Y
EAAC  f0 35                   BEQ loc_EAE3
EAAE  c9 05                   CMP #$05
EAB0  90 0b                   BCC loc_EABD
EAB2  38                      SEC
EAB3  e9 05                   SBC #$05
EAB5  aa                      TAX
EAB6  a9 01                   LDA #$01
EAB8  95 f9                   STA $F9,X
EABA  4c e3 ea                JMP loc_EAE3
EABD  aa         loc_EABD:    TAX
EABE  ca                      DEX
EABF  b5 f9                   LDA $F9,X
EAC1  d0 20                   BNE loc_EAE3
EAC3  a9 01                   LDA #$01
EAC5  95 f9                   STA $F9,X
EAC7  8a                      TXA
EAC8  a8                      TAY
EAC9  18                      CLC
EACA  69 05                   ADC #$05
EACC  a0 00                   LDY #$00
EACE  91 f0                   STA ($F0),Y
EAD0  8a                      TXA
EAD1  0a                      ASL A
EAD2  0a                      ASL A
EAD3  aa                      TAX
EAD4  a9 04                   LDA #$04
EAD6  85 fd                   STA $FD
EAD8  c8         loc_EAD8:    INY
EAD9  b1 f0                   LDA ($F0),Y
EADB  9d 00 40                STA $4000,X
EADE  e8                      INX
EADF  c6 fd                   DEC $FD
EAE1  d0 f5                   BNE loc_EAD8
EAE3  18         loc_EAE3:    CLC
EAE4  a5 f0                   LDA $F0
EAE6  69 08                   ADC #$08
EAE8  85 f0                   STA $F0
EAEA  90 02                   BCC loc_EAEE
EAEC  e6 f1                   INC $F1
EAEE  e6 f4      loc_EAEE:    INC $F4
EAF0  a5 f4                   LDA $F4
EAF2  c5 f5                   CMP $F5
EAF4  90 ab                   BCC loc_EAA1
EAF6  a2 00                   LDX #$00
EAF8  86 fd      loc_EAF8:    STX $FD
EAFA  b5 f9                   LDA $F9,X
EAFC  d0 0c                   BNE loc_EB0A
EAFE  8a                      TXA
EAFF  0a                      ASL A
EB00  0a                      ASL A
EB01  aa                      TAX
EB02  0a                      ASL A
EB03  29 10                   AND #$10
EB05  49 10                   EOR #$10
EB07  9d 00 40                STA $4000,X
EB0A  a6 fd      loc_EB0A:    LDX $FD
EB0C  e8                      INX
EB0D  e0 04                   CPX #$04
EB0F  90 e7                   BCC loc_EAF8
EB11  a0 00                   LDY #$00
EB13  84 f4                   STY $F4
EB15  a9 1c                   LDA #$1C
EB17  85 f0                   STA $F0
EB19  a9 03                   LDA #$03
EB1B  85 f1                   STA $F1
EB1D  a6 f4      loc_EB1D:    LDX $F4
EB1F  bd 00 03                LDA $0300,X
EB22  f0 0a                   BEQ loc_EB2E
EB24  c9 01                   CMP #$01
EB26  d0 1a                   BNE loc_EB42
EB28  fe 00 03                INC $0300,X
EB2B  4c 4f eb                JMP sub_EB4F
EB2E  18         loc_EB2E:    CLC
EB2F  a5 f0                   LDA $F0
EB31  69 08                   ADC #$08
EB33  85 f0                   STA $F0
EB35  90 02                   BCC loc_EB39
EB37  e6 f1                   INC $F1
EB39  e6 f4      loc_EB39:    INC $F4
EB3B  a5 f4                   LDA $F4
EB3D  c5 f5                   CMP $F5
EB3F  90 dc                   BCC loc_EB1D
EB41  60                      RTS
EB42  a0 07      loc_EB42:    LDY #$07
EB44  b1 f0                   LDA ($F0),Y
EB46  38                      SEC
EB47  e9 01                   SBC #$01
EB49  91 f0                   STA ($F0),Y
EB4B  f0 38                   BEQ loc_EB85
EB4D  d0 df                   BNE loc_EB2E
EB4F  a9 00      sub_EB4F:    LDA #$00
EB51  a0 05                   LDY #$05
EB53  91 f0                   STA ($F0),Y
EB55  20 af ec                JSR sub_ECAF
EB58  20 be ec                JSR sub_ECBE
EB5B  a0 00                   LDY #$00
EB5D  91 f0                   STA ($F0),Y
EB5F  20 be ec                JSR sub_ECBE
EB62  a0 01                   LDY #$01
EB64  91 f0                   STA ($F0),Y
EB66  20 be ec                JSR sub_ECBE
EB69  a0 02                   LDY #$02
EB6B  91 f0                   STA ($F0),Y
EB6D  20 be ec                JSR sub_ECBE
EB70  a0 04                   LDY #$04
EB72  91 f0                   STA ($F0),Y
EB74  a0 00                   LDY #$00
EB76  b1 f0                   LDA ($F0),Y
EB78  c9 04                   CMP #$04
EB7A  d0 0c                   BNE loc_EB88
EB7C  20 be ec                JSR sub_ECBE
EB7F  a0 03                   LDY #$03
EB81  91 f0                   STA ($F0),Y
EB83  10 03                   BPL loc_EB88
EB85  20 af ec   loc_EB85:    JSR sub_ECAF
EB88  20 be ec   loc_EB88:    JSR sub_ECBE
EB8B  c9 e8                   CMP #$E8
EB8D  b0 52                   BCS loc_EBE1
EB8F  c9 60                   CMP #$60
EB91  f0 44                   BEQ loc_EBD7
EB93  90 09                   BCC loc_EB9E
EB95  e9 60                   SBC #$60
EB97  a0 06                   LDY #$06
EB99  91 f0                   STA ($F0),Y
EB9B  4c 88 eb                JMP loc_EB88
EB9E  48         loc_EB9E:    PHA
EB9F  29 f8                   AND #$F8
EBA1  4a                      LSR A
EBA2  4a                      LSR A
EBA3  aa                      TAX
EBA4  bd e6 ec                LDA $ECE6,X
EBA7  85 fd                   STA $FD
EBA9  bd e7 ec                LDA $ECE7,X
EBAC  85 fe                   STA $FE
EBAE  68                      PLA
EBAF  29 07                   AND #$07
EBB1  f0 08                   BEQ loc_EBBB
EBB3  aa                      TAX
EBB4  46 fd      loc_EBB4:    LSR $FD
EBB6  66 fe                   ROR $FE
EBB8  ca                      DEX
EBB9  d0 f9                   BNE loc_EBB4
EBBB  a0 04      loc_EBBB:    LDY #$04
EBBD  b1 f0                   LDA ($F0),Y
EBBF  29 f8                   AND #$F8
EBC1  05 fd                   ORA $FD
EBC3  91 f0                   STA ($F0),Y
EBC5  a5 fe                   LDA $FE
EBC7  88                      DEY
EBC8  91 f0                   STA ($F0),Y
EBCA  a0 00                   LDY #$00
EBCC  b1 f0                   LDA ($F0),Y
EBCE  c9 05                   CMP #$05
EBD0  90 05                   BCC loc_EBD7
EBD2  38                      SEC
EBD3  e9 04                   SBC #$04
EBD5  91 f0                   STA ($F0),Y
EBD7  a0 06      loc_EBD7:    LDY #$06
EBD9  b1 f0                   LDA ($F0),Y
EBDB  c8                      INY
EBDC  91 f0                   STA ($F0),Y
EBDE  4c 2e eb                JMP loc_EB2E
EBE1  e9 e8      loc_EBE1:    SBC #$E8
EBE3  20 d0 ec                JSR sub_ECD0
EBE6  0a                      ASL A
EBE7  ec 21 ec                CPX $EC21

; ---- $EBEA..$EC20 (55 bytes: data) ----
EC21  20 be ec                JSR sub_ECBE
EC24  85 fd                   STA $FD
EC26  a0 01                   LDY #$01
EC28  b1 f0                   LDA ($F0),Y
EC2A  29 3f                   AND #$3F
EC2C  05 fd                   ORA $FD
EC2E  91 f0                   STA ($F0),Y
EC30  4c 88 eb                JMP loc_EB88
EC33  20 be ec                JSR sub_ECBE
EC36  85 fd                   STA $FD
EC38  a0 01                   LDY #$01
EC3A  b1 f0                   LDA ($F0),Y
EC3C  29 c0                   AND #$C0
EC3E  05 fd                   ORA $FD
EC40  91 f0                   STA ($F0),Y
EC42  4c 88 eb                JMP loc_EB88
EC45  20 be ec                JSR sub_ECBE
EC48  85 fd                   STA $FD
EC4A  a0 01                   LDY #$01
EC4C  b1 f0                   LDA ($F0),Y
EC4E  29 f0                   AND #$F0
EC50  05 fd                   ORA $FD
EC52  91 f0                   STA ($F0),Y
EC54  4c 88 eb                JMP loc_EB88
EC57  20 be ec                JSR sub_ECBE
EC5A  a0 02                   LDY #$02
EC5C  91 f0                   STA ($F0),Y
EC5E  4c 88 eb                JMP loc_EB88
EC61  20 be ec                JSR sub_ECBE
EC64  a0 04                   LDY #$04
EC66  91 f0                   STA ($F0),Y
EC68  4c 88 eb                JMP loc_EB88
EC6B  20 be ec                JSR sub_ECBE
EC6E  a0 01                   LDY #$01
EC70  91 f0                   STA ($F0),Y
EC72  4c 88 eb                JMP loc_EB88
EC75  a9 00                   LDA #$00
EC77  a2 02                   LDX #$02
EC79  95 f6      loc_EC79:    STA $F6,X
EC7B  ca                      DEX
EC7C  10 fb                   BPL loc_EC79
EC7E  4c 88 eb                JMP loc_EB88
EC81  a2 00                   LDX #$00
EC83  f0 05                   BEQ loc_EC8A
EC85  a2 01                   LDX #$01
EC87  2c a2 02                BIT $02A2

; ---- $EC8A..$EC87 (-2 bytes: data) ----
EC88  a2 02                   LDX #$02
EC8A  20 be ec   loc_EC8A:    JSR sub_ECBE
EC8D  f6 f6                   INC $F6,X
EC8F  d5 f6                   CMP $F6,X
EC91  d0 12                   BNE loc_ECA5
EC93  a9 00                   LDA #$00
EC95  95 f6                   STA $F6,X
EC97  f0 00                   BEQ loc_EC99
EC99  a0 05      loc_EC99:    LDY #$05
EC9B  b1 f0                   LDA ($F0),Y
EC9D  18                      CLC
EC9E  69 01                   ADC #$01
ECA0  91 f0                   STA ($F0),Y
ECA2  4c 88 eb                JMP loc_EB88
ECA5  20 be ec   loc_ECA5:    JSR sub_ECBE
ECA8  a0 05                   LDY #$05
ECAA  91 f0                   STA ($F0),Y
ECAC  4c 88 eb                JMP loc_EB88
ECAF  a5 f4      sub_ECAF:    LDA $F4
ECB1  0a                      ASL A
ECB2  aa                      TAX
ECB3  bd fe ec                LDA $ECFE,X
ECB6  85 f2                   STA $F2
ECB8  bd ff ec                LDA $ECFF,X
ECBB  85 f3                   STA $F3
ECBD  60                      RTS
ECBE  a5 f4      sub_ECBE:    LDA $F4
ECC0  a0 05                   LDY #$05
ECC2  b1 f0                   LDA ($F0),Y
ECC4  a8                      TAY
ECC5  b1 f2                   LDA ($F2),Y
ECC7  48                      PHA
ECC8  c8                      INY
ECC9  98                      TYA
ECCA  a0 05                   LDY #$05
ECCC  91 f0                   STA ($F0),Y
ECCE  68                      PLA
ECCF  60                      RTS
ECD0  0a         sub_ECD0:    ASL A
ECD1  a8                      TAY
ECD2  c8                      INY
ECD3  68                      PLA
ECD4  85 fd                   STA $FD
ECD6  68                      PLA
ECD7  85 fe                   STA $FE
ECD9  b1 fd                   LDA ($FD),Y
ECDB  aa                      TAX
ECDC  c8                      INY
ECDD  b1 fd                   LDA ($FD),Y
ECDF  85 fe                   STA $FE
ECE1  86 fd                   STX $FD
ECE3  6c fd 00                JMP ($00FD)

; ---- $ECE6..$EFFF (794 bytes: data) ----
F000  c9 ff      sub_F000:    CMP #$FF
F002  d0 05                   BNE loc_F009
F004  a9 24                   LDA #$24
F006  4c 10 f0                JMP sub_F010
F009  c9 24      loc_F009:    CMP #$24
F00B  90 03                   BCC sub_F010
F00D  38                      SEC
F00E  e9 23                   SBC #$23
F010  85 00      sub_F010:    STA $00
F012  a9 f0                   LDA #$F0
F014  85 12                   STA $12
F016  a9 7a                   LDA #$7A
F018  85 11                   STA $11
F01A  c6 00      sub_F01A:    DEC $00
F01C  f0 08                   BEQ loc_F026
F01E  a9 5b                   LDA #$5B
F020  20 aa d7                JSR sub_D7AA
F023  4c 1a f0                JMP sub_F01A
F026  a9 00      loc_F026:    LDA #$00
F028  85 5a                   STA $5A
F02A  a5 11                   LDA $11
F02C  85 13                   STA $13
F02E  a5 12                   LDA $12
F030  85 14                   STA $14
F032  a9 10                   LDA #$10
F034  85 57                   STA $57
F036  20 f6 d8   loc_F036:    JSR sub_D8F6
F039  a9 10                   LDA #$10
F03B  85 56                   STA $56
F03D  a5 5a      loc_F03D:    LDA $5A
F03F  4a                      LSR A
F040  a8                      TAY
F041  a5 5a                   LDA $5A
F043  29 01                   AND #$01
F045  f0 07                   BEQ loc_F04E
F047  b1 13                   LDA ($13),Y
F049  29 0f                   AND #$0F
F04B  4c 54 f0                JMP sub_F054
F04E  b1 13      loc_F04E:    LDA ($13),Y
F050  4a                      LSR A
F051  4a                      LSR A
F052  4a                      LSR A
F053  4a                      LSR A
F054  a6 56      sub_F054:    LDX $56
F056  a4 57                   LDY $57
F058  20 0b d8                JSR sub_D80B
F05B  a9 00                   LDA #$00
F05D  85 0c                   STA $0C
F05F  e6 5a                   INC $5A
F061  a5 56                   LDA $56
F063  18                      CLC
F064  69 10                   ADC #$10
F066  85 56                   STA $56
F068  c9 e0                   CMP #$E0
F06A  d0 d1                   BNE loc_F03D
F06C  e6 5a                   INC $5A
F06E  a5 57                   LDA $57
F070  18                      CLC
F071  69 10                   ADC #$10
F073  85 57                   STA $57
F075  c9 e0                   CMP #$E0
F077  d0 bd                   BNE loc_F036
F079  60                      RTS

; ---- $F07A..$F1A8 (303 bytes: data) ----
F1A9  dd d3 44                CMP $44D3,X
