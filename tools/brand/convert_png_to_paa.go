// Build an Arma UI PAA from the canonical BGD institutional PNG.
// See assets/branding/bgd/README.md. No artwork is regenerated.
// Use transparency rather than the black background of the web master asset.
package main
import (
 "fmt"
 "image"
 "image/color"
 "image/png"
 "math"
 "os"
 "github.com/woozymasta/paa"
)
func main() {
 if len(os.Args)!=3 {panic("usage: convert_png_to_paa <source.png> <output.paa>")}
 f,err:=os.Open(os.Args[1]); if err!=nil {panic(err)}
 src,err:=png.Decode(f); f.Close(); if err!=nil {panic(err)}
 bounds:=src.Bounds()
 left,top,right,bottom:=bounds.Max.X,bounds.Max.Y,bounds.Min.X,bounds.Min.Y
 // The official monochrome BGD logo is white on an opaque black background.
 // Identify its real bounds without recolouring the original asset.
 for y:=bounds.Min.Y;y<bounds.Max.Y;y++{for x:=bounds.Min.X;x<bounds.Max.X;x++{
  r,g,b,_:=src.At(x,y).RGBA()
  if (int(r)+int(g)+int(b))/3>10000 {
   if x<left {left=x};if y<top {top=y};if x+1>right {right=x+1};if y+1>bottom {bottom=y+1}
  }
 }}
 if right<=left || bottom<=top {panic("institutional logo is empty")}
 // 256 square allows a clean icon in the ultrawide header; retain full logo aspect.
 const dim=256.0
 const pad=11.0
 ratio:=math.Min((dim-2*pad)/float64(right-left),(dim-2*pad)/float64(bottom-top))
 drawW:=float64(right-left)*ratio
 drawH:=float64(bottom-top)*ratio
 startX:=(dim-drawW)/2
 startY:=(dim-drawH)/2
 dst:=image.NewNRGBA(image.Rect(0,0,int(dim),int(dim)))
 for y:=0;y<int(dim);y++{for x:=0;x<int(dim);x++{
  u:=(float64(x)+0.5-startX)/ratio+float64(left)-0.5
  v:=(float64(y)+0.5-startY)/ratio+float64(top)-0.5
  if u<float64(left)||u>=float64(right)||v<float64(top)||v>=float64(bottom){continue}
  x0,y0:=int(math.Floor(u)),int(math.Floor(v))
  fx,fy:=u-float64(x0),v-float64(y0)
  brightness:=0.0
  for j:=0;j<2;j++{for i:=0;i<2;i++{
    sx,sy:=x0+i,y0+j
    if sx<left||sx>=right||sy<top||sy>=bottom{continue}
    r,g,b,_:=src.At(sx,sy).RGBA()
    weight:=math.Abs(float64(1-i)-fx)*math.Abs(float64(1-j)-fy)
    brightness+=weight*float64(r+g+b)/3/257
  }}
  a:=uint8(math.Round(math.Max(0,math.Min(255,brightness))))
  dst.SetNRGBA(x,y,color.NRGBA{R:255,G:255,B:255,A:a})
 }}
 out,err:=os.Create(os.Args[2]);if err!=nil {panic(err)}
 err=paa.EncodeWithOptions(out,dst,&paa.EncodeOptions{Type:paa.PaxDXT5,UseLZO:false,ForceCXAMFull:true})
 if err!=nil {out.Close();panic(err)}
 if err=out.Close();err!=nil {panic(err)}
 fmt.Printf("Built BGD PAA: %s -> %s, 256x256, DXT5 with alpha\n",os.Args[1],os.Args[2])
}
