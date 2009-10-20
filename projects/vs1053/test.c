#include <avr/io.h>

#include "spi.h"
#include "vs1053.h"
 
int main(void)
{
	spi_init(); //set up SPI registers
	cs_high(); // probably a good idea
 
	sci_write(0x00, (1<<SM_TESTS)|(1<<SM_SDISHARE)|(1<<SM_STREAM)|(1<<SM_SDINEW));
	cs_low(); // for data interface
	send_sinewave(170);
}
