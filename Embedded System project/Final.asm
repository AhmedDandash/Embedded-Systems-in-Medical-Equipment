
_SPI_init:

;Final.c,30 :: 		void SPI_init()
;Final.c,34 :: 		SSPCON.B3=  0;
	BCF        SSPCON+0, 3
;Final.c,35 :: 		SSPCON.B2=  0;
	BCF        SSPCON+0, 2
;Final.c,36 :: 		SSPCON.B1=   0;
	BCF        SSPCON+0, 1
;Final.c,37 :: 		SSPCON.B0=  0;
	BCF        SSPCON+0, 0
;Final.c,38 :: 		SSPCON.SSPEN=1;              // enable synchronous serial port
	BSF        SSPCON+0, 5
;Final.c,40 :: 		SSPCON.CKP=  0;
	BCF        SSPCON+0, 4
;Final.c,42 :: 		SSPSTAT.CKE=1; //if ckp=0
	BSF        SSPSTAT+0, 6
;Final.c,44 :: 		SSPSTAT.SMP=0;
	BCF        SSPSTAT+0, 7
;Final.c,45 :: 		TRISC.B3 = 0;                 // define clock pin as output
	BCF        TRISC+0, 3
;Final.c,46 :: 		TRISC.B5=0;                  // define SDO as output (master ) to lcd
	BCF        TRISC+0, 5
;Final.c,49 :: 		}
L_end_SPI_init:
	RETURN
; end of _SPI_init

_wr_SPI:

;Final.c,50 :: 		unsigned char wr_SPI ( unsigned char dat )
;Final.c,52 :: 		SSPBUF = dat;             // write byte to SSPBUF register
	MOVF       FARG_wr_SPI_dat+0, 0
	MOVWF      SSPBUF+0
;Final.c,53 :: 		while( !SSPSTAT.BF );  // wait until bus cycle complete
L_wr_SPI0:
	BTFSC      SSPSTAT+0, 0
	GOTO       L_wr_SPI1
	GOTO       L_wr_SPI0
L_wr_SPI1:
;Final.c,54 :: 		return ( SSPBUF );         //
	MOVF       SSPBUF+0, 0
	MOVWF      R0+0
;Final.c,55 :: 		}
L_end_wr_SPI:
	RETURN
; end of _wr_SPI

_SPI_to_74HC595:

;Final.c,58 :: 		void SPI_to_74HC595(  )
;Final.c,60 :: 		wr_SPI ( LCDpins );     // send LCDpins out the SPI
	MOVF       _LCDpins+0, 0
	MOVWF      FARG_wr_SPI_dat+0
	CALL       _wr_SPI+0
;Final.c,61 :: 		PORTE.B0 = 1;                //move data to parallel pins
	BSF        PORTE+0, 0
;Final.c,62 :: 		PORTE.B0 = 0;
	BCF        PORTE+0, 0
;Final.c,63 :: 		}
L_end_SPI_to_74HC595:
	RETURN
; end of _SPI_to_74HC595

_LCD_sendbyte:

;Final.c,65 :: 		void LCD_sendbyte( unsigned char tosend )
;Final.c,67 :: 		LCDpins &= 0x0f;                //prepare place for the upper nibble
	MOVLW      15
	ANDWF      _LCDpins+0, 1
;Final.c,68 :: 		LCDpins |= ( tosend & 0xf0 );   //copy upper nibble to LCD variable
	MOVLW      240
	ANDWF      FARG_LCD_sendbyte_tosend+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	IORWF      _LCDpins+0, 1
;Final.c,69 :: 		LCDpins |= E        ;                  //send
	BSF        _LCDpins+0, 3
;Final.c,70 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;Final.c,71 :: 		LCDpins &= ~E        ;
	BCF        _LCDpins+0, 3
;Final.c,72 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;Final.c,73 :: 		LCDpins &= 0x0f;                    //prepare place for the lower nibble
	MOVLW      15
	ANDWF      _LCDpins+0, 1
;Final.c,74 :: 		LCDpins |= ( tosend << 4 ) & 0xf0;    //copy lower nibble to LCD variable
	MOVF       FARG_LCD_sendbyte_tosend+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVLW      240
	ANDWF      R0+0, 1
	MOVF       R0+0, 0
	IORWF      _LCDpins+0, 1
;Final.c,75 :: 		LCDpins |= E          ;                   //send
	BSF        _LCDpins+0, 3
;Final.c,76 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;Final.c,77 :: 		LCDpins &= ~E          ;
	BCF        _LCDpins+0, 3
;Final.c,78 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;Final.c,79 :: 		}
L_end_LCD_sendbyte:
	RETURN
; end of _LCD_sendbyte

_LCD_sendcmd:

;Final.c,80 :: 		void LCD_sendcmd(unsigned char a)
;Final.c,81 :: 		{   LCDpins &= ~RS         ;
	BCF        _LCDpins+0, 2
;Final.c,82 :: 		LCD_sendbyte(a);
	MOVF       FARG_LCD_sendcmd_a+0, 0
	MOVWF      FARG_LCD_sendbyte_tosend+0
	CALL       _LCD_sendbyte+0
;Final.c,83 :: 		}
L_end_LCD_sendcmd:
	RETURN
; end of _LCD_sendcmd

_LCD_sendchar:

;Final.c,85 :: 		void LCD_sendchar(unsigned char a)
;Final.c,86 :: 		{   LCDpins |= RS            ;
	BSF        _LCDpins+0, 2
;Final.c,87 :: 		LCD_sendbyte(a);
	MOVF       FARG_LCD_sendchar_a+0, 0
	MOVWF      FARG_LCD_sendbyte_tosend+0
	CALL       _LCD_sendbyte+0
;Final.c,88 :: 		}
L_end_LCD_sendchar:
	RETURN
; end of _LCD_sendchar

_LCD_init:

;Final.c,92 :: 		void LCD_init ( void )
;Final.c,94 :: 		LCDpins &= ~RS              ;
	BCF        _LCDpins+0, 2
;Final.c,95 :: 		PORTE.B0 = 0;
	BCF        PORTE+0, 0
;Final.c,97 :: 		Delay_ms(100);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_LCD_init2:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init2
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init2
	NOP
	NOP
;Final.c,99 :: 		LCDpins =  0x30;  // send 0x3
	MOVLW      48
	MOVWF      _LCDpins+0
;Final.c,100 :: 		LCDpins |= E                 ;
	MOVLW      56
	MOVWF      _LCDpins+0
;Final.c,101 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;Final.c,102 :: 		LCDpins &= ~E                 ;
	BCF        _LCDpins+0, 3
;Final.c,103 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;Final.c,105 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init3:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init3
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init3
	NOP
	NOP
;Final.c,106 :: 		LCDpins |= E  ;        // send 0x3
	BSF        _LCDpins+0, 3
;Final.c,107 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;Final.c,108 :: 		LCDpins &= ~E                  ;
	BCF        _LCDpins+0, 3
;Final.c,109 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;Final.c,111 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init4:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init4
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init4
	NOP
	NOP
;Final.c,112 :: 		LCDpins |= E         ;// send 0x3
	BSF        _LCDpins+0, 3
;Final.c,113 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;Final.c,114 :: 		LCDpins &= ~E         ;
	BCF        _LCDpins+0, 3
;Final.c,115 :: 		SPI_to_74HC595 ();
	CALL       _SPI_to_74HC595+0
;Final.c,117 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init5:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init5
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init5
	NOP
	NOP
;Final.c,118 :: 		LCDpins =  0x20;        // send 0x2 - switch to 4-bit
	MOVLW      32
	MOVWF      _LCDpins+0
;Final.c,119 :: 		LCDpins |= E           ;
	MOVLW      40
	MOVWF      _LCDpins+0
;Final.c,120 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;Final.c,121 :: 		LCDpins &= ~E           ;
	BCF        _LCDpins+0, 3
;Final.c,122 :: 		SPI_to_74HC595();
	CALL       _SPI_to_74HC595+0
;Final.c,124 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init6:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init6
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init6
	NOP
	NOP
;Final.c,125 :: 		LCD_sendcmd ( 0x28 );   //4-bit 2-line 5x7-font
	MOVLW      40
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;Final.c,126 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init7:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init7
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init7
	NOP
	NOP
;Final.c,127 :: 		LCD_sendcmd ( 0x01 );   //clear display
	MOVLW      1
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;Final.c,128 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init8:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init8
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init8
	NOP
	NOP
;Final.c,129 :: 		LCD_sendcmd ( 0x0c );   //turn off cursor, turn on display
	MOVLW      12
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;Final.c,130 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_init9:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_init9
	DECFSZ     R12+0, 1
	GOTO       L_LCD_init9
	NOP
	NOP
;Final.c,131 :: 		LCD_sendcmd ( 0x06 );   //Increment cursor automatically
	MOVLW      6
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;Final.c,132 :: 		}
L_end_LCD_init:
	RETURN
; end of _LCD_init

_LCD_send_string:

;Final.c,133 :: 		void LCD_send_string( char *str_ptr )
;Final.c,135 :: 		while (*str_ptr) {
L_LCD_send_string10:
	MOVF       FARG_LCD_send_string_str_ptr+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_LCD_send_string11
;Final.c,136 :: 		LCD_sendchar(*str_ptr);
	MOVF       FARG_LCD_send_string_str_ptr+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_LCD_sendchar_a+0
	CALL       _LCD_sendchar+0
;Final.c,137 :: 		str_ptr++;
	INCF       FARG_LCD_send_string_str_ptr+0, 1
;Final.c,138 :: 		}
	GOTO       L_LCD_send_string10
L_LCD_send_string11:
;Final.c,139 :: 		}
L_end_LCD_send_string:
	RETURN
; end of _LCD_send_string

_LCD_second_row:

;Final.c,140 :: 		void LCD_second_row(  )
;Final.c,142 :: 		LCD_sendcmd( 0xc0 );
	MOVLW      192
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;Final.c,143 :: 		}
L_end_LCD_second_row:
	RETURN
; end of _LCD_second_row

_LCD_Home:

;Final.c,146 :: 		void LCD_Home(  )
;Final.c,148 :: 		LCD_sendcmd( LCD_CLRSCR );
	MOVLW      1
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;Final.c,149 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_LCD_Home12:
	DECFSZ     R13+0, 1
	GOTO       L_LCD_Home12
	DECFSZ     R12+0, 1
	GOTO       L_LCD_Home12
	NOP
	NOP
;Final.c,150 :: 		LCD_sendcmd( LCD_HOME );
	MOVLW      2
	MOVWF      FARG_LCD_sendcmd_a+0
	CALL       _LCD_sendcmd+0
;Final.c,151 :: 		}
L_end_LCD_Home:
	RETURN
; end of _LCD_Home

_DisplayLCD:

;Final.c,170 :: 		void DisplayLCD()
;Final.c,174 :: 		LCD_Home();
	CALL       _LCD_Home+0
;Final.c,175 :: 		LCD_send_string(" Ready");
	MOVLW      ?lstr1_Final+0
	MOVWF      FARG_LCD_send_string_str_ptr+0
	CALL       _LCD_send_string+0
;Final.c,176 :: 		delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_DisplayLCD13:
	DECFSZ     R13+0, 1
	GOTO       L_DisplayLCD13
	DECFSZ     R12+0, 1
	GOTO       L_DisplayLCD13
	DECFSZ     R11+0, 1
	GOTO       L_DisplayLCD13
	NOP
	NOP
;Final.c,179 :: 		}
L_end_DisplayLCD:
	RETURN
; end of _DisplayLCD

_Port_init:

;Final.c,181 :: 		void Port_init()
;Final.c,183 :: 		PORTA = 0X00;
	CLRF       PORTA+0
;Final.c,184 :: 		PORTC = 0X00;
	CLRF       PORTC+0
;Final.c,185 :: 		PORTE.F0 = 0;
	BCF        PORTE+0, 0
;Final.c,186 :: 		PORTE.F2=1;
	BSF        PORTE+0, 2
;Final.c,187 :: 		PORTD.B7=1;
	BSF        PORTD+0, 7
;Final.c,188 :: 		TRISD.B7=1;
	BSF        TRISD+0, 7
;Final.c,189 :: 		PORTD.B0=1;
	BSF        PORTD+0, 0
;Final.c,190 :: 		TRISD.B0=1;
	BSF        TRISD+0, 0
;Final.c,191 :: 		TRISD.B1=0;
	BCF        TRISD+0, 1
;Final.c,192 :: 		TRISC.F1=1;
	BSF        TRISC+0, 1
;Final.c,193 :: 		TRISC.F3=0;
	BCF        TRISC+0, 3
;Final.c,194 :: 		TRISC.F5=0;
	BCF        TRISC+0, 5
;Final.c,195 :: 		TRISE.F0=0;
	BCF        TRISE+0, 0
;Final.c,196 :: 		TRISD.B4=0;
	BCF        TRISD+0, 4
;Final.c,197 :: 		TRISC.f6=0;   //Output (TX)
	BCF        TRISC+0, 6
;Final.c,198 :: 		TRISC.f7=1;   //Input (RX)
	BSF        TRISC+0, 7
;Final.c,199 :: 		TRISE.F2=1;
	BSF        TRISE+0, 2
;Final.c,200 :: 		PORTB.B1=1;
	BSF        PORTB+0, 1
;Final.c,201 :: 		TRISB.B1=0;
	BCF        TRISB+0, 1
;Final.c,202 :: 		ADCON0.GO=1;
	BSF        ADCON0+0, 1
;Final.c,203 :: 		TMR0=0X04;
	MOVLW      4
	MOVWF      TMR0+0
;Final.c,204 :: 		INTCON=0b10100000;
	MOVLW      160
	MOVWF      INTCON+0
;Final.c,205 :: 		OPTION_REG=0b00010111;
	MOVLW      23
	MOVWF      OPTION_REG+0
;Final.c,206 :: 		T1CON.TMR1ON = 1;
	BSF        T1CON+0, 0
;Final.c,207 :: 		T1CON.TMR1CS = 1;           // External clock input on RC0 pin
	BSF        T1CON+0, 1
;Final.c,208 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;Final.c,209 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;Final.c,210 :: 		}
L_end_Port_init:
	RETURN
; end of _Port_init

_Analog_Init:

;Final.c,211 :: 		void Analog_Init(){
;Final.c,212 :: 		ADCON0 = 0x80;
	MOVLW      128
	MOVWF      ADCON0+0
;Final.c,213 :: 		ADCON1 = 0x80;
	MOVLW      128
	MOVWF      ADCON1+0
;Final.c,215 :: 		ADCON0.CHS0 = 0;
	BCF        ADCON0+0, 2
;Final.c,216 :: 		ADCON0.CHS1 = 0;
	BCF        ADCON0+0, 3
;Final.c,217 :: 		ADCON0.CHS2 = 0;
	BCF        ADCON0+0, 4
;Final.c,218 :: 		ADCON0.ADON = 1;
	BSF        ADCON0+0, 0
;Final.c,219 :: 		}
L_end_Analog_Init:
	RETURN
; end of _Analog_Init

_ser_int:

;Final.c,220 :: 		void ser_int()
;Final.c,222 :: 		TXSTA=0x20; //BRGH=0, TXEN = 1, Asynchronous Mode, 8-bit mode
	MOVLW      32
	MOVWF      TXSTA+0
;Final.c,223 :: 		RCSTA=0b10000000; //Serial Port enabled,8-bit reception
	MOVLW      128
	MOVWF      RCSTA+0
;Final.c,224 :: 		SPBRG=5;           //9600 baudrate for 4Mhz =n
	MOVLW      5
	MOVWF      SPBRG+0
;Final.c,225 :: 		PIR1.TXIF=0;
	BCF        PIR1+0, 4
;Final.c,226 :: 		PIR1.RCIF=0;
	BCF        PIR1+0, 5
;Final.c,227 :: 		}
L_end_ser_int:
	RETURN
; end of _ser_int

_tx:

;Final.c,229 :: 		void tx( char a)
;Final.c,231 :: 		TXREG=a;
	MOVF       FARG_tx_a+0, 0
	MOVWF      TXREG+0
;Final.c,232 :: 		while(!PIR1.TXIF);
L_tx14:
	BTFSC      PIR1+0, 4
	GOTO       L_tx15
	GOTO       L_tx14
L_tx15:
;Final.c,233 :: 		PIR1.TXIF = 0;
	BCF        PIR1+0, 4
;Final.c,234 :: 		}
L_end_tx:
	RETURN
; end of _tx

_Read_ADC:

;Final.c,235 :: 		void Read_ADC()
;Final.c,237 :: 		ADCON0.GO=1;
	BSF        ADCON0+0, 1
;Final.c,238 :: 		while(ADCON0.GO);
L_Read_ADC16:
	BTFSS      ADCON0+0, 1
	GOTO       L_Read_ADC17
	GOTO       L_Read_ADC16
L_Read_ADC17:
;Final.c,239 :: 		delay_ms(50);
	MOVLW      65
	MOVWF      R12+0
	MOVLW      238
	MOVWF      R13+0
L_Read_ADC18:
	DECFSZ     R13+0, 1
	GOTO       L_Read_ADC18
	DECFSZ     R12+0, 1
	GOTO       L_Read_ADC18
	NOP
;Final.c,241 :: 		temp=((ADRESH<<8)+ADRESL)*0.488281;
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	ADDWF      R0+0, 1
	BTFSC      STATUS+0, 0
	INCF       R0+1, 1
	CALL       _word2double+0
	MOVLW      248
	MOVWF      R4+0
	MOVLW      255
	MOVWF      R4+1
	MOVLW      121
	MOVWF      R4+2
	MOVLW      125
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      _temp+0
	MOVF       R0+1, 0
	MOVWF      _temp+1
	MOVF       R0+2, 0
	MOVWF      _temp+2
	MOVF       R0+3, 0
	MOVWF      _temp+3
;Final.c,242 :: 		FloatToStr(temp, text);
	MOVF       R0+0, 0
	MOVWF      FARG_FloatToStr_fnum+0
	MOVF       R0+1, 0
	MOVWF      FARG_FloatToStr_fnum+1
	MOVF       R0+2, 0
	MOVWF      FARG_FloatToStr_fnum+2
	MOVF       R0+3, 0
	MOVWF      FARG_FloatToStr_fnum+3
	MOVLW      _text+0
	MOVWF      FARG_FloatToStr_str+0
	CALL       _FloatToStr+0
;Final.c,243 :: 		Temperature[7]=text[0];
	MOVF       _text+0, 0
	MOVWF      _Temperature+7
;Final.c,244 :: 		Temperature[8]=text[1];
	MOVF       _text+1, 0
	MOVWF      _Temperature+8
;Final.c,245 :: 		Temperature[10]=text[3];
	MOVF       _text+3, 0
	MOVWF      _Temperature+10
;Final.c,248 :: 		for(dr=0;dr<=11;dr++ )
	CLRF       _dr+0
	CLRF       _dr+1
L_Read_ADC19:
	MOVF       _dr+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Read_ADC78
	MOVF       _dr+0, 0
	SUBLW      11
L__Read_ADC78:
	BTFSS      STATUS+0, 0
	GOTO       L_Read_ADC20
;Final.c,250 :: 		tx(Temperature[dr]);
	MOVF       _dr+0, 0
	ADDLW      _Temperature+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_tx_a+0
	CALL       _tx+0
;Final.c,248 :: 		for(dr=0;dr<=11;dr++ )
	INCF       _dr+0, 1
	BTFSC      STATUS+0, 2
	INCF       _dr+1, 1
;Final.c,251 :: 		}
	GOTO       L_Read_ADC19
L_Read_ADC20:
;Final.c,252 :: 		tx(13);
	MOVLW      13
	MOVWF      FARG_tx_a+0
	CALL       _tx+0
;Final.c,254 :: 		}
L_end_Read_ADC:
	RETURN
; end of _Read_ADC

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;Final.c,255 :: 		void interrupt(){
;Final.c,256 :: 		if(INTCON.f2=1)          //checking timer0 flag
	BSF        INTCON+0, 2
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt22
;Final.c,258 :: 		INTCON.f2=0;          //zeroing the flag again to 0
	BCF        INTCON+0, 2
;Final.c,259 :: 		}
L_interrupt22:
;Final.c,261 :: 		cnt++;                      //increment the counter by one
	INCF       _cnt+0, 1
	BTFSC      STATUS+0, 2
	INCF       _cnt+1, 1
;Final.c,262 :: 		if(cnt==155)
	MOVLW      0
	XORWF      _cnt+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt81
	MOVLW      155
	XORWF      _cnt+0, 0
L__interrupt81:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt23
;Final.c,266 :: 		pul = (TMR1H<<8)|(TMR1L);
	MOVF       TMR1H+0, 0
	MOVWF      _pul+1
	CLRF       _pul+0
	MOVF       TMR1L+0, 0
	IORWF      _pul+0, 1
	MOVLW      0
	IORWF      _pul+1, 1
;Final.c,269 :: 		cnt=0;
	CLRF       _cnt+0
	CLRF       _cnt+1
;Final.c,270 :: 		TMR1H=0;
	CLRF       TMR1H+0
;Final.c,271 :: 		TMR1L=0;
	CLRF       TMR1L+0
;Final.c,273 :: 		}
L_interrupt23:
;Final.c,274 :: 		TMR0=0X04;
	MOVLW      4
	MOVWF      TMR0+0
;Final.c,275 :: 		}
L_end_interrupt:
L__interrupt80:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_HeartPulse:

;Final.c,276 :: 		void HeartPulse()
;Final.c,280 :: 		bpm=60000/pul;
	MOVF       _pul+0, 0
	MOVWF      R4+0
	MOVF       _pul+1, 0
	MOVWF      R4+1
	MOVLW      96
	MOVWF      R0+0
	MOVLW      234
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      _bpm+0
	MOVF       R0+1, 0
	MOVWF      _bpm+1
;Final.c,281 :: 		hr=bpm/100;
	MOVLW      100
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_S+0
	MOVF       R0+0, 0
	MOVWF      _hr+0
	MOVF       R0+1, 0
	MOVWF      _hr+1
;Final.c,282 :: 		FloatToStr(hr, txt);
	CALL       _word2double+0
	MOVF       R0+0, 0
	MOVWF      FARG_FloatToStr_fnum+0
	MOVF       R0+1, 0
	MOVWF      FARG_FloatToStr_fnum+1
	MOVF       R0+2, 0
	MOVWF      FARG_FloatToStr_fnum+2
	MOVF       R0+3, 0
	MOVWF      FARG_FloatToStr_fnum+3
	MOVLW      _txt+0
	MOVWF      FARG_FloatToStr_str+0
	CALL       _FloatToStr+0
;Final.c,283 :: 		HeartBeat[6]=txt[0];
	MOVF       _txt+0, 0
	MOVWF      _HeartBeat+6
;Final.c,284 :: 		HeartBeat[7]=txt[1];
	MOVF       _txt+1, 0
	MOVWF      _HeartBeat+7
;Final.c,285 :: 		if(hr>99)
	MOVF       _hr+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__HeartPulse83
	MOVF       _hr+0, 0
	SUBLW      99
L__HeartPulse83:
	BTFSC      STATUS+0, 0
	GOTO       L_HeartPulse24
;Final.c,287 :: 		HeartBeat[8]=txt[2];
	MOVF       _txt+2, 0
	MOVWF      _HeartBeat+8
;Final.c,288 :: 		}
L_HeartPulse24:
;Final.c,291 :: 		for(j=0;j<=10;j++ )
	CLRF       _j+0
	CLRF       _j+1
L_HeartPulse25:
	MOVF       _j+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__HeartPulse84
	MOVF       _j+0, 0
	SUBLW      10
L__HeartPulse84:
	BTFSS      STATUS+0, 0
	GOTO       L_HeartPulse26
;Final.c,293 :: 		tx(HeartBeat[j]);
	MOVF       _j+0, 0
	ADDLW      _HeartBeat+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_tx_a+0
	CALL       _tx+0
;Final.c,291 :: 		for(j=0;j<=10;j++ )
	INCF       _j+0, 1
	BTFSC      STATUS+0, 2
	INCF       _j+1, 1
;Final.c,294 :: 		}
	GOTO       L_HeartPulse25
L_HeartPulse26:
;Final.c,295 :: 		tx(13);
	MOVLW      13
	MOVWF      FARG_tx_a+0
	CALL       _tx+0
;Final.c,298 :: 		}
L_end_HeartPulse:
	RETURN
; end of _HeartPulse

_DisplayTemp:

;Final.c,300 :: 		void DisplayTemp()
;Final.c,303 :: 		LCD_Home();
	CALL       _LCD_Home+0
;Final.c,304 :: 		Read_ADC();
	CALL       _Read_ADC+0
;Final.c,305 :: 		LCD_send_string(Temperature);
	MOVLW      _Temperature+0
	MOVWF      FARG_LCD_send_string_str_ptr+0
	CALL       _LCD_send_string+0
;Final.c,306 :: 		delay_ms(100);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_DisplayTemp28:
	DECFSZ     R13+0, 1
	GOTO       L_DisplayTemp28
	DECFSZ     R12+0, 1
	GOTO       L_DisplayTemp28
	NOP
	NOP
;Final.c,307 :: 		}
L_end_DisplayTemp:
	RETURN
; end of _DisplayTemp

_DisplayHeart:

;Final.c,308 :: 		void DisplayHeart()
;Final.c,310 :: 		HeartPulse();   //heart function
	CALL       _HeartPulse+0
;Final.c,312 :: 		LCD_send_string(HeartBeat);
	MOVLW      _HeartBeat+0
	MOVWF      FARG_LCD_send_string_str_ptr+0
	CALL       _LCD_send_string+0
;Final.c,313 :: 		delay_ms(100);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_DisplayHeart29:
	DECFSZ     R13+0, 1
	GOTO       L_DisplayHeart29
	DECFSZ     R12+0, 1
	GOTO       L_DisplayHeart29
	NOP
	NOP
;Final.c,314 :: 		}
L_end_DisplayHeart:
	RETURN
; end of _DisplayHeart

_buttonSystem:

;Final.c,317 :: 		void buttonSystem()
;Final.c,319 :: 		if(PORTD.B7==0)
	BTFSC      PORTD+0, 7
	GOTO       L_buttonSystem30
;Final.c,321 :: 		delay_ms(100);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_buttonSystem31:
	DECFSZ     R13+0, 1
	GOTO       L_buttonSystem31
	DECFSZ     R12+0, 1
	GOTO       L_buttonSystem31
	NOP
	NOP
;Final.c,323 :: 		while(PORTD.B7==1)
L_buttonSystem32:
	BTFSS      PORTD+0, 7
	GOTO       L_buttonSystem33
;Final.c,325 :: 		PORTB.B1=0;
	BCF        PORTB+0, 1
;Final.c,326 :: 		LCD_send_string(" OFF ");
	MOVLW      ?lstr2_Final+0
	MOVWF      FARG_LCD_send_string_str_ptr+0
	CALL       _LCD_send_string+0
;Final.c,327 :: 		}
	GOTO       L_buttonSystem32
L_buttonSystem33:
;Final.c,328 :: 		PORTB.B1=1;
	BSF        PORTB+0, 1
;Final.c,329 :: 		}
L_buttonSystem30:
;Final.c,330 :: 		}
L_end_buttonSystem:
	RETURN
; end of _buttonSystem

_bcValue:

;Final.c,331 :: 		void bcValue()
;Final.c,333 :: 		if(PORTD.b0==0&&bc==0)
	BTFSC      PORTD+0, 0
	GOTO       L_bcValue36
	MOVLW      0
	XORWF      _bc+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bcValue89
	MOVLW      0
	XORWF      _bc+0, 0
L__bcValue89:
	BTFSS      STATUS+0, 2
	GOTO       L_bcValue36
L__bcValue61:
;Final.c,335 :: 		delay_ms(100);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_bcValue37:
	DECFSZ     R13+0, 1
	GOTO       L_bcValue37
	DECFSZ     R12+0, 1
	GOTO       L_bcValue37
	NOP
	NOP
;Final.c,336 :: 		bc=1;
	MOVLW      1
	MOVWF      _bc+0
	MOVLW      0
	MOVWF      _bc+1
;Final.c,337 :: 		}
	GOTO       L_bcValue38
L_bcValue36:
;Final.c,338 :: 		else if(PORTD.b0==0&&bc==1)
	BTFSC      PORTD+0, 0
	GOTO       L_bcValue41
	MOVLW      0
	XORWF      _bc+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bcValue90
	MOVLW      1
	XORWF      _bc+0, 0
L__bcValue90:
	BTFSS      STATUS+0, 2
	GOTO       L_bcValue41
L__bcValue60:
;Final.c,340 :: 		delay_ms(100);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_bcValue42:
	DECFSZ     R13+0, 1
	GOTO       L_bcValue42
	DECFSZ     R12+0, 1
	GOTO       L_bcValue42
	NOP
	NOP
;Final.c,341 :: 		bc=2;
	MOVLW      2
	MOVWF      _bc+0
	MOVLW      0
	MOVWF      _bc+1
;Final.c,342 :: 		}
	GOTO       L_bcValue43
L_bcValue41:
;Final.c,343 :: 		else if(PORTD.b0==0&&bc==2)
	BTFSC      PORTD+0, 0
	GOTO       L_bcValue46
	MOVLW      0
	XORWF      _bc+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bcValue91
	MOVLW      2
	XORWF      _bc+0, 0
L__bcValue91:
	BTFSS      STATUS+0, 2
	GOTO       L_bcValue46
L__bcValue59:
;Final.c,345 :: 		delay_ms(100);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_bcValue47:
	DECFSZ     R13+0, 1
	GOTO       L_bcValue47
	DECFSZ     R12+0, 1
	GOTO       L_bcValue47
	NOP
	NOP
;Final.c,346 :: 		bc=0;
	CLRF       _bc+0
	CLRF       _bc+1
;Final.c,347 :: 		}
L_bcValue46:
L_bcValue43:
L_bcValue38:
;Final.c,348 :: 		}
L_end_bcValue:
	RETURN
; end of _bcValue

_DisplayLCDChange:

;Final.c,349 :: 		void DisplayLCDChange()
;Final.c,351 :: 		while(bc==0)
L_DisplayLCDChange48:
	MOVLW      0
	XORWF      _bc+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayLCDChange93
	MOVLW      0
	XORWF      _bc+0, 0
L__DisplayLCDChange93:
	BTFSS      STATUS+0, 2
	GOTO       L_DisplayLCDChange49
;Final.c,353 :: 		LCD_Home();
	CALL       _LCD_Home+0
;Final.c,354 :: 		DisplayTemp();
	CALL       _DisplayTemp+0
;Final.c,355 :: 		LCD_second_row();
	CALL       _LCD_second_row+0
;Final.c,356 :: 		DisplayHeart();
	CALL       _DisplayHeart+0
;Final.c,357 :: 		delay_ms(1);
	MOVLW      2
	MOVWF      R12+0
	MOVLW      75
	MOVWF      R13+0
L_DisplayLCDChange50:
	DECFSZ     R13+0, 1
	GOTO       L_DisplayLCDChange50
	DECFSZ     R12+0, 1
	GOTO       L_DisplayLCDChange50
;Final.c,358 :: 		buttonSystem();
	CALL       _buttonSystem+0
;Final.c,359 :: 		bcValue();
	CALL       _bcValue+0
;Final.c,361 :: 		}
	GOTO       L_DisplayLCDChange48
L_DisplayLCDChange49:
;Final.c,362 :: 		while(bc==1)
L_DisplayLCDChange51:
	MOVLW      0
	XORWF      _bc+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayLCDChange94
	MOVLW      1
	XORWF      _bc+0, 0
L__DisplayLCDChange94:
	BTFSS      STATUS+0, 2
	GOTO       L_DisplayLCDChange52
;Final.c,364 :: 		LCD_Home();
	CALL       _LCD_Home+0
;Final.c,365 :: 		DisplayTemp();
	CALL       _DisplayTemp+0
;Final.c,366 :: 		delay_ms(1);
	MOVLW      2
	MOVWF      R12+0
	MOVLW      75
	MOVWF      R13+0
L_DisplayLCDChange53:
	DECFSZ     R13+0, 1
	GOTO       L_DisplayLCDChange53
	DECFSZ     R12+0, 1
	GOTO       L_DisplayLCDChange53
;Final.c,367 :: 		buttonSystem();
	CALL       _buttonSystem+0
;Final.c,368 :: 		bcValue();
	CALL       _bcValue+0
;Final.c,369 :: 		}
	GOTO       L_DisplayLCDChange51
L_DisplayLCDChange52:
;Final.c,370 :: 		while(bc==2)
L_DisplayLCDChange54:
	MOVLW      0
	XORWF      _bc+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayLCDChange95
	MOVLW      2
	XORWF      _bc+0, 0
L__DisplayLCDChange95:
	BTFSS      STATUS+0, 2
	GOTO       L_DisplayLCDChange55
;Final.c,372 :: 		LCD_Home();
	CALL       _LCD_Home+0
;Final.c,373 :: 		DisplayHeart();
	CALL       _DisplayHeart+0
;Final.c,374 :: 		delay_ms(1);
	MOVLW      2
	MOVWF      R12+0
	MOVLW      75
	MOVWF      R13+0
L_DisplayLCDChange56:
	DECFSZ     R13+0, 1
	GOTO       L_DisplayLCDChange56
	DECFSZ     R12+0, 1
	GOTO       L_DisplayLCDChange56
;Final.c,375 :: 		buttonSystem();
	CALL       _buttonSystem+0
;Final.c,376 :: 		bcValue();
	CALL       _bcValue+0
;Final.c,377 :: 		}
	GOTO       L_DisplayLCDChange54
L_DisplayLCDChange55:
;Final.c,378 :: 		}
L_end_DisplayLCDChange:
	RETURN
; end of _DisplayLCDChange

_main:

;Final.c,380 :: 		void main()
;Final.c,382 :: 		Port_init();
	CALL       _Port_init+0
;Final.c,383 :: 		SPI_init();
	CALL       _SPI_init+0
;Final.c,384 :: 		LCD_init();
	CALL       _LCD_init+0
;Final.c,385 :: 		OSCCON = 0x60; //8mhz
	MOVLW      96
	MOVWF      OSCCON+0
;Final.c,386 :: 		Analog_Init();
	CALL       _Analog_Init+0
;Final.c,387 :: 		DisplayLCD();
	CALL       _DisplayLCD+0
;Final.c,388 :: 		ser_int();
	CALL       _ser_int+0
;Final.c,392 :: 		while(1)
L_main57:
;Final.c,394 :: 		DisplayLCDChange();
	CALL       _DisplayLCDChange+0
;Final.c,397 :: 		}
	GOTO       L_main57
;Final.c,399 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
