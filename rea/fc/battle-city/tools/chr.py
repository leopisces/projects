from PIL import Image
d=open('battle_city.nes','rb').read()
chr_=d[16+16384:]
PAL=[(0x00,0x00,0x00),(0x54,0x54,0x54),(0xAC,0xAC,0xAC),(0xFC,0xFC,0xFC)]
S=8; COLS=16; SCALE=4
tiles=len(chr_)//16
rows=(tiles+COLS-1)//COLS
img=Image.new('RGB',(COLS*S*SCALE, rows*S*SCALE),(20,20,30))
px=img.load()
for t in range(tiles):
    o=t*16
    for y in range(8):
        b0=chr_[o+y]; b1=chr_[o+y+8]
        for x in range(8):
            bit=7-x
            v=((b0>>bit)&1) | (((b1>>bit)&1)<<1)
            cx=((t%COLS)*S+x)*SCALE; cy=((t//COLS)*S+y)*SCALE
            for dy in range(SCALE):
                for dx in range(SCALE):
                    px[cx+dx,cy+dy]=PAL[v]
img.save('chr_tiles.png')
print("tiles:",tiles,"->",img.size)
