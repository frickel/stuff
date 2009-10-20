#include <avr/io.h>
 
#include "spi.h"
 
void spi_init()
{
	DDR_SPI = 0xFF; // set the whole port to output
 
	DDR_SPI &= ~(1 << DD_MISO); // change back to input
 
	SPCR = (1 << SPE) | (1 << MSTR); // set spi clock rate to fck/4
}
 
void cs_low()
{
	PORT_SPI &= ~(1 << DD_CS);
}
 
void cs_high()
{
	PORT_SPI |= (1 << DD_CS);
}
 
char spi_send(char byte)
{
	SPDR = byte; //send byte
 
	while(!(SPSR & (1 << SPIF))); //wait until its done
	return SPDR; //return the rx byte
}
