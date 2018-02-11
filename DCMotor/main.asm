


.equ TCCR0Config = 0b01100110 // [0][1][1][0] [0][1][1][0]
				   // WGM01:00 = 01 (PWM-Phase Correct)
				   // COM01:00 = 10 (Clear OC0 on compare match when up-counting, Set OC0 on compare match when down-counting)
				   // CS02:01:00 = 110 (External clock source on T0 pin, Clock on falling edge)

.equ PortBDDR = 0b00001000 // [XXXX][1][X][0][X] => OC0 output and T0 input

.equ LoopDelayA = 255
.equ LoopDelayB = 12

.include "m32def.inc"

.org 0
rjmp start

.org $0050
start:
	
	ldi r16, $FF
	out ddra, r16	
	out ddrd, r16
    ldi r16, PortBDDR
	out ddrb, r16
	ldi r16, $FC // $FC = 1111 1100
	out ddrc, r16
	ldi r16, 0
	out TCNT0, r16
	ldi r16, 0
	out OCR0, r16
	ldi r16, TCCR0Config
	out TCCR0, r16
	
    InfLoop:
			IncCheck:
				SBIS pinc, 0 // Skip if PortC.0 is one
				rjmp DecCheck

				in r25, OCR0 // only when OCR0 < 255
				cpi r25, 255
				brsh DecCheck
				inc r25
				out ocr0, r25

				rjmp delay
			DecCheck:
				SBIS pinc, 1 // Skip if PortC.1 is one
				rjmp Delay

				in r26, OCR0 //  only when OCR0 >= 1
				cpi r26, 1
				brlo Delay
				dec r26
				out ocr0, r26
			Delay:
				in r17, OCR0
				out portd, r17


				ldi r18, 0
				ldi r19, 0
				CounterLoop:
					inc r18
					cpi r18, LoopDelayA
					brsh CounterLoop2
					rjmp CounterLoop
					CounterLoop2:
						ldi r18, 0
						inc r19
						cpi r19, LoopDelayB
						brsh InfLoop
						rjmp CounterLoop

		rjmp InfLoop
