/*
BikeTXT alpha2 - Based on Frank's LED-Matrix code
08. August 2009 by Frickel
 
Changelog:
22. August 2009 by Frickel - Use a more precise timing for delay
01. September 2009 by Frickel - Some cleanup.
*/
 
int i, j, k, x, xx , y, yy;
int lum=0, newscr=0, tmp;

int scrollx,scrolly;
 
// We've got a virtual resolution of 1x6 on our BikeTXT
#define SCRdx 1
#define SCRdy 6
 
// Oversampling factor <=5, Up to 2 on a ATMega168, 5 on ATMega328..
#define OSf 1
 
// int=2 Byte
int scr[SCRdx][SCRdy]; // (real) screen
int vscr[SCRdx*OSf][SCRdy*OSf]; // virtual (high res) screen
 
// Our font is 5x7
#define CFONTwidth 0x5
#define CFONTwidth2 0x7

// See 'char cfont[]={..}' below
#define CFONTstart 0x40
#define CFONTend 0x5b
 
int buttonPin = 10; // Button used to increase delay
int ledSpeed = 400; // Let's begin with a 400µs delay

// Button states - uarghs.
int buttonState;
int lastButtonState;
 
// The pins we've attached our LED's to
int linePins[] = { 2, 3, 4, 5, 6, 7 };
 
char cfont[]=
{ 0x00, 0x00, 0x00, 0x00, 0x00, // SPACE (0x40 or 0x20)
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
 
//char myoutstring[]="ABCDEFGHIJKLMNOPQRSTUVWXYZ ";
char myoutstring[]="BIKETXT ";
int myoutstringpos=0;
 
/* A more precise delay funcion (µs) - 4 cycles
Seems to be more efficient than delayMicroseconds()
(saves some bytes).
*/
 
void delay_us(unsigned int us)
{
  if (--us == 0)
    return;
    
  us <<= 2; us -= 2;
  
  cli(); // Clear global interrupt enable bit
  
  __asm__ __volatile__ (
    "1: sbiw %0,1" "\n\t"
    "brne 1b" : "=w" (us) : "0" (us)
  );
  
  sei(); // Set global interrupt enable bit
}
 
void setup()
{
  for(i=2;i<8;i++) pinMode(i, OUTPUT);
  pinMode(buttonPin, INPUT);
  lum=9999;
  newscr=0;
}
 

#define ANIMm 2
 
void loop()
{ newscr++;
  if (newscr%(ANIMm)==0)
  {
    newscr=0;
    int p0=myoutstringpos/OSf;
    int p2=p0/CFONTwidth2;
    char c=myoutstring[p2];
    if (c==0) { myoutstringpos=0; p0=0; p2=p0/CFONTwidth2; c=myoutstring[p2]; }
    int p1=p0%CFONTwidth2;
    int bits=0;
    if (c==0x20) c=0x40; // 0x40 is SPACE. Normally it would be 0x20
                         // which would mean we have to define all chars
                         // from 0x20 to 0x40.
                         
    if (p1<CFONTwidth && c<CFONTend) bits=cfont[(c-CFONTstart)*CFONTwidth+p1];
    
    for(y=0; y<SCRdy*OSf; y++)
    {
      vscr[SCRdx*OSf-1][y]=0;  // Clear our virtual screen
    }
    
    for (int b=1, p=0; b<0x40 && p<OSf*6; b*=2, p+=OSf) if (bits&b)
      for(y=0; y<OSf; y++) vscr[OSf*SCRdx-1][p+y]=256;
    myoutstringpos++;
  }
  
  lum+=16; if (lum>254) lum=0;
 
  for(y=0;y<SCRdy;y++)
  {
    digitalWrite(linePins[y], vscr[0][y]>128?HIGH:LOW);
  }
  
  // Increase speed each time our pushbutton is pressed
  buttonState = digitalRead(buttonPin);
  
  if (buttonState != lastButtonState){
    
    if (buttonState == HIGH){
        ledSpeed+=100;  // Feel free to use a more precise value here
    }
  
  lastButtonState = buttonState;
  }
 
  delay_us(ledSpeed);
  // End of our Quick-and-Dirty speed changing routine
}
