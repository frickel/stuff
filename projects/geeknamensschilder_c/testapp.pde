#define BAUD		115200	
#define DELAY		1000
#define RST		2

#define INIT_SEQ	0x55
#define CMD_CLEAR	0x45
#define CMD_BGCOLOR	0x42
#define CMD_CPYPASTE	0x63
#define	CMD_LINE	0x4C
#define CMD_CIRCLE	0x43
#define CMD_FILLCIRCLE	0x69
#define CMD_PUTPIXEL	0x50
#define CMD_READPIXEL	0x52
#define CMD_RECTANGLE	0x72
#define CMD_PAINTAREA	0x70
#define CMD_SETFNTSIZE	0x46
#define FONT_5X7	0x01
#define FONT_8x8	0x02
#define FONT_8x12	0x03
#define CMD_FMTTEXT	0x54
#define CMD_CTL		0x59
#define CMD_DSPL	0x01
#define CMD_CONTRAST	0x02
#define CMD_POWER	0x03
#define RESPONSE_ACK	0x06
#define RESPONSE_NAK	0x15

void displayReset()
{
        digitalWrite(RST, LOW);
        delay(20);
        digitalWrite(RST, HIGH);
        delay(20);
}


char getDisplayResponse()
{
        byte incomingByte = RESPONSE_ACK;

        while(!Serial.available()) { delay(1); }
        incomingByte = Serial.read();
        return incomingByte;
}

void displayInit()
{
	displayReset();
	delay(DELAY);
	Serial.print(INIT_SEQ, BYTE);
	getDisplayResponse();
}

void displayClear()
{
	Serial.print(CMD_CLEAR, BYTE);
	delay(20);
	getDisplayResponse();
}

void displayDrawChar(char col, char row, char size, char myChar, int color)
{
	Serial.print(CMD_FMTTEXT, BYTE);
	Serial.print(myChar, BYTE);
	Serial.print(col, BYTE);
	Serial.print(row, BYTE);
	Serial.print(color >> 8, BYTE);		// MSB
	Serial.print(color & 0xFF, BYTE);	// LSB
	getDisplayResponse();
}

void setup()
{
        Serial.begin(BAUD);     // The OLED-Display is connected via UART

        pinMode(RST, OUTPUT);   // The OLED-Display's Reset-Pin is an OUTPUT.

        displayInit();
        displayClear();
        displayDrawChar(1, 1, 10, '4', 52333);
}

void loop()
{
        // Do nothing
}

