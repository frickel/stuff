#define DDR_SPI 	DDRB
#define PORT_SPI	PORTB
 
#define DD_CS	2
#define DD_MOSI 3
#define DD_MISO 4
#define DD_SCK	5
 
void spi_init(); // init the SPI subsystem
void cs_low(); // helpers
void cs_high();
char spi_send(char byte); // send a byte; return rx byte
