/*
2009 Frickel
#08. August 2009 by Frickel
#biketxt alpha for atmega168 running at 16 MHz
*/
 
int i, j, k, x,y,xx,yy, lum=0,newscr=0,tmp;
int scrollx,scrolly;
char c;
 
#define SCRdx 8
#define SCRdy 8
#define OSf 2 // Oversampling factor <=5, sonst Speicher voll. Max 2 beim atmega168.
#define ANIMm ((int)(   32   /OSf))
int YEnlA = 84; // 1 bzw. 76;
int YEnlB = 60; // 1 bzw. 60;
int YEnl = YEnlA>1 ? 0 : 0; // vergr. der pixel y
int glimmer = 1; // 0off/1on

int myoutstringmax=512;
 
// int=2 Byte
int scr[SCRdx][SCRdy]; // (real) screen
int vscr[SCRdx*OSf][SCRdy*OSf]; // virtual (high res) screen
 
int buttonPin = 10;
int ledSpeed = 1;

int hell=0;
float hellpos=0;
float PI2=3.141592*2;
 
int buttonState;
int lastButtonState;
 
int linePins[] = { 4, 5, 6, 7, 8, 9, 10, 11 };
int shiftDataPin = 3;
int shiftClockPin = 2;
 
#define CFONTwidth 0x5
#define CFONTwidth2 0x7
#define CFONTstart 0x20
#define CFONTend 0x5b
 
char cfont[]=
{
  0x00, 0x00, 0x00, 0x00, 0x00, // SPACE 0x20
  0x00, 0x00, 0x2f, 0x00, 0x00, // !
  0x00, 0x03, 0x00, 0x03, 0x00, // "
  0x12, 0x3f, 0x12, 0x3f, 0x12, // #
  0x22, 0x25, 0x3f, 0x25, 0x18, // $
  0x03, 0x33, 0x0c, 0x33, 0x30, // %
  0x12, 0x2d, 0x2d, 0x12, 0x28, // &
  0x00, 0x00, 0x03, 0x00, 0x00, // '
  0x00, 0x00, 0x1e, 0x21, 0x00, // (
  0x00, 0x21, 0x1e, 0x00, 0x00, // )
  0x12, 0x0c, 0x3f, 0x0c, 0x12, // *
  0x08, 0x08, 0x3e, 0x08, 0x08, // +
  0x00, 0x20, 0x10, 0x00, 0x00, // ,
  0x08, 0x08, 0x08, 0x08, 0x08, // -
  0x00, 0x10, 0x38, 0x10, 0x00, // .
  0x00, 0x30, 0x0c, 0x03, 0x00, // /
  0x1e, 0x21, 0x2d, 0x21, 0x1e, // 0
  0x00, 0x21, 0x3f, 0x20, 0x00, // 1
  0x22, 0x31, 0x29, 0x25, 0x22, // 2
  0x12, 0x21, 0x25, 0x25, 0x1a, // 3
  0x08, 0x0c, 0x0a, 0x3f, 0x08, // 4
  0x27, 0x25, 0x25, 0x25, 0x18, // 5
  0x1e, 0x29, 0x29, 0x29, 0x11, // 6
  0x01, 0x31, 0x0d, 0x03, 0x00, // 7
  0x1a, 0x25, 0x25, 0x25, 0x1a, // 8
  0x26, 0x29, 0x29, 0x25, 0x1e, // 9
  0x00, 0x00, 0x12, 0x00, 0x00, // :
  0x00, 0x20, 0x12, 0x00, 0x00, // ;
  0x00, 0x08, 0x14, 0x22, 0x00, // <
  0x12, 0x12, 0x12, 0x12, 0x12, // =
  0x00, 0x22, 0x14, 0x08, 0x00, // >
  0x00, 0x01, 0x2d, 0x05, 0x02, // ?

  0x1e, 0x21, 0x2d, 0x2d, 0x0e, // @  0x40
  0x38, 0x16, 0x11, 0x16, 0x38, // A (0x41)
  0x3f, 0x25, 0x25, 0x26, 0x18, // B (0x42)
  0x1e, 0x21, 0x21, 0x21, 0x12, // C
  0x3f, 0x21, 0x21, 0x21, 0x1e, // D
  0x3f, 0x25, 0x25, 0x25, 0x21, // E
  0x3f, 0x05, 0x05, 0x05, 0x01, // F
  0x1e, 0x21, 0x21, 0x29, 0x1a, // G
  0x3f, 0x08, 0x08, 0x08, 0x3f, // H
  0x00, 0x21, 0x3f, 0x21, 0x00, // I
  0x00, 0x11, 0x21, 0x1f, 0x00, // J
  0x3f, 0x08, 0x14, 0x14, 0x22, // K
  0x3f, 0x20, 0x20, 0x20, 0x20, // L
  0x3f, 0x02, 0x0c, 0x02, 0x3f, // M
  0x3f, 0x02, 0x04, 0x08, 0x3f, // N
  0x1e, 0x21, 0x21, 0x21, 0x1e, // O
  0x3f, 0x09, 0x09, 0x09, 0x06, // P
  0x1e, 0x21, 0x29, 0x11, 0x2e, // Q
  0x3f, 0x09, 0x09, 0x19, 0x26, // R
  0x22, 0x25, 0x25, 0x25, 0x18, // S
  0x01, 0x01, 0x3f, 0x01, 0x01, // T
  0x1f, 0x20, 0x20, 0x20, 0x1f, // U
  0x03, 0x0c, 0x30, 0x0c, 0x03, // V
  0x3f, 0x10, 0x0c, 0x10, 0x3f, // W
  0x31, 0x0a, 0x04, 0x0a, 0x31, // X
  0x01, 0x02, 0x3c, 0x02, 0x01, // Y
  0x31, 0x29, 0x25, 0x23, 0x21, // Z
};
 
//char myoutstring0[]="!\"#$%&'()*+,-./0123456789:;<=>? ";
//char myoutstring0[]="ABCDEFGHIJKLMNOPQRSTUVWXYZ ";
char myoutstring0[]="FRICKL ";
//char myoutstring0[]="HALLO ";
int myoutstringpos=0;

char *myoutstring=myoutstring0;
int myoutstringlen=-1;
 
void setup()
{
  for(i=0;i<SCRdx;i++) pinMode(linePins[i], OUTPUT);
  pinMode(shiftDataPin, OUTPUT);
  pinMode(shiftClockPin, OUTPUT);
  //pinMode(buttonPin, INPUT);
  lum=9999;
  newscr=0;
  
  Serial.begin(9600);
}
void vscr2scr()
{ int x,y,xx,yy,xxx,yyy,sum;
  for(x=0; x<SCRdx; x++)
  { xxx=x*OSf;
    for(y=0; y<SCRdy; y++)
    { yyy=y*OSf;
      sum=0;
      for(xx=0; xx<OSf; xx++) for(yy=0; yy<OSf; yy++) sum+=vscr[xxx+xx][yyy+yy];
      scr[x][y]=sum/OSf/OSf;
    }
  }
}
 
void loop()
{ newscr++;
 
  if (newscr%(ANIMm)==0)
  {
    newscr=0;
    int p0=myoutstringpos/OSf;
    //int p0=myoutstringpos/(OSf); // Zeichen nur (OSf-1)/OSf breit ausgeben
    int p2=p0/CFONTwidth2;
    c=myoutstring[p2];
    if (c==0) { myoutstringpos=0; p0=0; p2=p0/CFONTwidth2; c=myoutstring[p2]; }
    if (c!=0)
    {
    int p1=p0%CFONTwidth2;
    int bits=0;
    if (p1<CFONTwidth && c<CFONTend) bits=cfont[(c-CFONTstart)*CFONTwidth+p1];
    
    for(y=0; y<SCRdy*OSf; y++)
    {
      //vscr[SCRdx*OSf-1][y]=0; // clear
    }
    // Scrolling not temporarily disabled
    for(y=0; y<SCRdy*OSf; y++)
    { for(x=0; x<SCRdx*OSf-1; x++) vscr[x][y]=vscr[x+1][y];
      vscr[SCRdx*OSf-1][y]=0; // clear
    }
    //for (int b=1, p=0; b<0x40 && p<OSf*6; b*=2, p+=OSf) if (bits&b)
    //for(y=0; y<OSf; y++) vscr[OSf*SCRdx-1][p+y]=256;
    //for (int b=1, p=0, i=0; b<0x40 && p<OSf*6; b*=2, p+=OSf+(i++&1?1:0)) if (bits&b)
    //for(y=0; y<OSf+1; y++) vscr[OSf*SCRdx-1][p+y]=256;
    for (int b=1, p=0, i=0; b<0x40; b*=2, p=(OSf*(++i)*YEnlA)/YEnlB) if (bits&b)
    { j=random(240)+16;
      j=16; if (!glimmer || random(240)>200) j=256;
      for(y=0; y<OSf+YEnl; y++)
        if (p+y<OSf*SCRdy) 
          vscr[OSf*SCRdx-1][p+y]=j;
    }
    //  for(y=0; y<OSf; y++) vscr[OSf*SCRdx-1][p+y]=240*hell/64 +16;
    myoutstringpos++;
    
    hellpos+=PI2/50; if (hell>PI2) hell-=PI2;
    hell=sin(hellpos)*32+32;
 
    vscr2scr();
    }
  }
  
  lum+=16; if (lum>254) lum=0;

if(0) 
  for(y=0;y<SCRdy;y++)
    for(x=SCRdx-1;x>=0;x--)
      scr[x][y]=x==y?0:255;

  for(y=0;y<SCRdy;y++)
  {
    for(x=SCRdx-1;x>=0;x--)
    {
      //digitalWrite(shiftDataPin, HIGH);
      digitalWrite(shiftDataPin, scr[x][y]<=lum ? LOW : HIGH);
      for(i=0;i<1;i++);
      digitalWrite(shiftClockPin, HIGH);
      for(i=0;i<1;i++);
      digitalWrite(shiftClockPin, LOW);
      for(i=0;i<1;i++);
    }
    digitalWrite(linePins[y], HIGH);
// for(j=0;j<6;j++)
      for(i=0;i<100;i++);
    //delay(1);
    digitalWrite(linePins[y], LOW);
  }

  if (Serial.available()>0)
  { c = Serial.read();
    Serial.write(c);
    if (myoutstringlen<0)
    { myoutstring=(char*)malloc(myoutstringmax+2);
      if (!myoutstring)  { myoutstring=myoutstring0; myoutstring0[0]='X'; return; } // error: out of memory!
      myoutstringlen=0; 
    }
    if (c==23 || c=='|') { myoutstringlen=0; myoutstring[0]=0; myoutstring[1]=0;  myoutstringpos=0; }
    else if (myoutstringlen<myoutstringmax)
    { if (c>='a' && c<='z') c-=0x20;
      if (c<CFONTstart || c>CFONTend) c='.';
      myoutstring[myoutstringlen+1]=0;
      myoutstring[myoutstringlen]=c;
      myoutstringlen++;
    }
  }
}

