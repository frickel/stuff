#include <avr/io.h>
#include "spi.h"
#include "vs1053.h"

int sci_read(char addr)
{
	unsigned int tmp;
	
	cs_low();
	
	spi_send(0x03);		// Send read command
	spi_send(addr);		// the address
	
	tmp = spi_send(0x00);
	tmp <<= 8;		// Shift it
	
	tmp += spi_send(0x00);	// Get LSB
	
	cs_high();
	
	return tmp;
}

void sci_write(char addr, int data)
{
	cs_low();
	
	spi_send(0x02);		// Send write command
	spi_send(addr);		// the address

	spi_send((data >> 8) & 0xFF);	// Send the first 8 MSBs
	spi_send(data & 0xFF);		// Send the MSBs
	
	cs_high();
}

void send_sinewave(char pitch)
{
	cs_high();

	// 8-byte sine test initialization sequence
	spi_send(0x53);
	spi_send(0xEF);
	spi_send(0x6E);
	spi_send(pitch);
	
	spi_send(0x00);
	spi_send(0x00);
	spi_send(0x00);
	spi_send(0x00);
	
	cs_low();
}
