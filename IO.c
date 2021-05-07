// IO.c
// This software configures the switch and LED
// You are allowed to use any switch and any LED, 
// although the Lab suggests the SW1 switch PF4 and Red LED PF1
// Runs on TM4C123
// Program written by: Anthony Do
// Date Created: 3/30/2021
// Last Modified:  4/1/2021
// Lab number: 7


#include "../inc/tm4c123gh6pm.h"
#include <stdint.h>
#include "../inc/CortexM.h"

// Bit-specific addressing
#define PF2 (*((volatile unsigned long *)0x40025010)) // PF2
#define PF4 (*((volatile unsigned long *)0x40025040))  // PF4




//------------IO_Init------------
// Initialize GPIO Port for a switch and an LED
// Input: none
// Output: none

void IO_Init(void) { volatile uint32_t delay;
 // --UUU-- Code to initialize PF4 and PF2
  SYSCTL_RCGCGPIO_R |= 0x20;
  while((SYSCTL_RCGCGPIO_R&0x20) != 0x20){};
	GPIO_PORTF_DIR_R &= ~(0x10);
	GPIO_PORTF_DIR_R |= 0x04;
	GPIO_PORTF_PUR_R |= 0x10;
	GPIO_PORTF_DEN_R |= 0x14;
}

//------------IO_HeartBeat------------
// Toggle the output state of the PF2 LED.
// Input: none
// Output: none
uint8_t led = 0x04;
void IO_HeartBeat(void) {
 // --UUU-- 
	led ^= 0x04;
  PF2 = led;
	Clock_Delay1ms(100);
}

//------------IO_Touch------------
// wait for release and press of the switch
// Input: none
// Output: none
// 1) wait for release; 
// 2) delay for 5ms; 
// 3) wait for press; and then 
// 4) delay for another 5ms
void IO_Touch(void) {
 // --UUU-- 
	while(PF4 == 0){};
  Clock_Delay1ms(5);
	while(PF4 == 1){};
	Clock_Delay1ms(5);
}  


