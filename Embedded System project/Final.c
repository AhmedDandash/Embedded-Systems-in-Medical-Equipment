//////////////////////////////////////////////SPI DEF////////////////////////////////
unsigned char LCDpins;
//void LCD_send_string( char *str_ptr );
#define RS  0x04    // RS pin
#define E   0x08    // E pin
//define SET_RS  LCDpins |= RS
//define CLR_RS  LCDpins &= ~RS
//define SET_E   LCDpins |= E
//define CLR_E   LCDpins &= ~E


#define        Scroll_right                0x1e        /* Scroll display one character right (all lines)                 */
#define Scroll_left                        0x18        /* Scroll display one character left (all lines)                        */

#define        LCD_HOME                        0x02        /* Home (move cursor to top/left character position)        */
#define        Cursor_left                        0x10        /* Move cursor one character left                                                                                        */
#define        Cursor_right                0x14        /* Move cursor one character right                                                                                */
#define Cursor_uline                0x0e        /* Turn on visible underline cursor                                                                         */
#define Cursor_block                0x0f        /* Turn on visible blinking-block cursor                                                        */
#define Cursor_invis                0x0c        /* Make cursor invisible                                                                                                                        */
#define        Display_blank                0x08        /* Blank the display (without clearing)                                                                */
#define Display_restore                0x0c        /* Restore the display (with cursor hidden)                                                */
#define        LCD_CLRSCR                        0x01        /* Clear Screen                                                                                                                                                                */

#define        SET_CURSOR                        0x80        /* Set cursor position (Set_cursor+DDRAM address)                        */
#define        Set_CGRAM                                0x40        /* Set pointer in character-generator RAM Set_CGRAM+(CGRAM address)        */


 //////////////////////////////////////////////SPI FUNCTIONS/////////////////////////////////
   void SPI_init()
{

  //master mode, clk fosc/4
  SSPCON.B3=  0;
  SSPCON.B2=  0;
  SSPCON.B1=   0;
  SSPCON.B0=  0;
  SSPCON.SSPEN=1;              // enable synchronous serial port
  // clk idle state low
  SSPCON.CKP=  0;
  // data read on low to high  MODE 0,0
  SSPSTAT.CKE=1; //if ckp=0
  //input data sampled at the middle of interval
   SSPSTAT.SMP=0;
   TRISC.B3 = 0;                 // define clock pin as output
   TRISC.B5=0;                  // define SDO as output (master ) to lcd
   // Define clock pin as an output for clk

}
unsigned char wr_SPI ( unsigned char dat )
{
 SSPBUF = dat;             // write byte to SSPBUF register
 while( !SSPSTAT.BF );  // wait until bus cycle complete
 return ( SSPBUF );         //
}

/* copies LCDpins variable to parallel output of the shift register */
void SPI_to_74HC595(  )
{
    wr_SPI ( LCDpins );     // send LCDpins out the SPI
    PORTE.B0 = 1;                //move data to parallel pins
    PORTE.B0 = 0;
}

 void LCD_sendbyte( unsigned char tosend )
{
    LCDpins &= 0x0f;                //prepare place for the upper nibble
    LCDpins |= ( tosend & 0xf0 );   //copy upper nibble to LCD variable
    LCDpins |= E        ;                  //send
    SPI_to_74HC595();
    LCDpins &= ~E        ;
    SPI_to_74HC595();
    LCDpins &= 0x0f;                    //prepare place for the lower nibble
    LCDpins |= ( tosend << 4 ) & 0xf0;    //copy lower nibble to LCD variable
    LCDpins |= E          ;                   //send
    SPI_to_74HC595();
    LCDpins &= ~E          ;
    SPI_to_74HC595();
}
  void LCD_sendcmd(unsigned char a)
 {   LCDpins &= ~RS         ;
      LCD_sendbyte(a);
  }

void LCD_sendchar(unsigned char a)
{   LCDpins |= RS            ;
    LCD_sendbyte(a);
}
/* LCD initialization by instruction                */
/* 4-bit 2 line                                     */
/* wait times are set for 8MHz clock (TCY 500ns)    */
void LCD_init ( void )
{
  LCDpins &= ~RS              ;
  PORTE.B0 = 0;
  /* wait 100msec */
  Delay_ms(100);
  /* send 0x03 */
  LCDpins =  0x30;  // send 0x3
  LCDpins |= E                 ;
  SPI_to_74HC595 ();
  LCDpins &= ~E                 ;
  SPI_to_74HC595 ();
  /* wait 10ms */
  Delay_ms(10);
  LCDpins |= E  ;        // send 0x3
  SPI_to_74HC595 ();
  LCDpins &= ~E                  ;
  SPI_to_74HC595 ();
  /* wait 10ms */
  Delay_ms(10);
  LCDpins |= E         ;// send 0x3
  SPI_to_74HC595 ();
  LCDpins &= ~E         ;
  SPI_to_74HC595 ();
  /* wait 1ms */
  Delay_ms(10);
  LCDpins =  0x20;        // send 0x2 - switch to 4-bit
  LCDpins |= E           ;
  SPI_to_74HC595();
  LCDpins &= ~E           ;
  SPI_to_74HC595();
  /* regular transfers start here */
 Delay_ms(10);
  LCD_sendcmd ( 0x28 );   //4-bit 2-line 5x7-font
  Delay_ms(10);
  LCD_sendcmd ( 0x01 );   //clear display
  Delay_ms(10);
  LCD_sendcmd ( 0x0c );   //turn off cursor, turn on display
  Delay_ms(10);
  LCD_sendcmd ( 0x06 );   //Increment cursor automatically
}
void LCD_send_string( char *str_ptr )
{
        while (*str_ptr) {
                LCD_sendchar(*str_ptr);
                str_ptr++;
        }
}
void LCD_second_row(  )
{
        LCD_sendcmd( 0xc0 );
}


void LCD_Home(  )
{
 LCD_sendcmd( LCD_CLRSCR );
  Delay_ms(10);
  LCD_sendcmd( LCD_HOME );
}
char Temperature[]= "Temp = 00.0C";
char HeartBeat[]= "Bpm = 00 ";
char text[15];
char txt[15];
float temp=0;
int pul=0;
int bpm=0;
unsigned int heart;
unsigned int bc=0;
unsigned int cnt=0;
unsigned int dr;
unsigned int j;
unsigned int hr;
unsigned int FR=1;
////uart
 void ser_int();
void tx(char);

 void DisplayLCD()
{
   //SPI_init();
   //LCD_init();
   LCD_Home();
   LCD_send_string(" Ready");
   delay_ms(500);
     //LCD_Home();

}

  void Port_init()
  {
  PORTA = 0X00;
  PORTC = 0X00;
  PORTE.F0 = 0;
  PORTE.F2=1;
  PORTD.B7=1;
  TRISD.B7=1;
  PORTD.B0=1;
  TRISD.B0=1;
  TRISD.B1=0;
  TRISC.F1=1;
  TRISC.F3=0;
  TRISC.F5=0;
  TRISE.F0=0;
  TRISD.B4=0;
  TRISC.f6=0;   //Output (TX)
  TRISC.f7=1;   //Input (RX)
  TRISE.F2=1;
  PORTB.B1=1;
  TRISB.B1=0;
  ADCON0.GO=1;
  TMR0=0X04;
  INTCON=0b10100000;
  OPTION_REG=0b00010111;
  T1CON.TMR1ON = 1;
  T1CON.TMR1CS = 1;           // External clock input on RC0 pin
  TMR1L = 0;
  TMR1H = 0;
  }
 void Analog_Init(){
ADCON0 = 0x80;
ADCON1 = 0x80;
// Select channel 0 = AN0
ADCON0.CHS0 = 0;
ADCON0.CHS1 = 0;
ADCON0.CHS2 = 0;
ADCON0.ADON = 1;
}
  void ser_int()
{
    TXSTA=0x20; //BRGH=0, TXEN = 1, Asynchronous Mode, 8-bit mode
    RCSTA=0b10000000; //Serial Port enabled,8-bit reception
    SPBRG=5;           //10417 baudrate for 4Mhz =n
    PIR1.TXIF=0;
    PIR1.RCIF=0;
}

void tx( char a)
{
    TXREG=a;
    while(!PIR1.TXIF);
    PIR1.TXIF = 0;
}
void Read_ADC()
{
ADCON0.GO=1;
while(ADCON0.GO);
   delay_ms(50);

  temp=((ADRESH<<8)+ADRESL)*0.488281;
  FloatToStr(temp, text);
  Temperature[7]=text[0];
  Temperature[8]=text[1];
  Temperature[10]=text[3];
  //Temperature[12]=223;

    for(dr=0;dr<=11;dr++ )
    {
  tx(Temperature[dr]);
     }
     tx(13);

}
void interrupt(){
   if(INTCON.f2=1)          //checking timer0 flag
    {
      INTCON.f2=0;          //zeroing the flag again to 0
    }

cnt++;                      //increment the counter by one
   if(cnt==155)
    { 
                          //every 50 cycles make 1 sec.

         pul = (TMR1H<<8)|(TMR1L);


    cnt=0;
    TMR1H=0;
    TMR1L=0;

    }
  TMR0=0X04;
}
void HeartPulse()
{

  hr=pul*6;
  FloatToStr(hr, txt);
  HeartBeat[6]=txt[0];
  HeartBeat[7]=txt[1];
  if(hr>99)
  {
   HeartBeat[8]=txt[2];
   }


    for(j=0;j<=10;j++ )
    {
  tx(HeartBeat[j]);
     }
     tx(13);


}

  void DisplayTemp()
{

  LCD_Home();
    Read_ADC();
   LCD_send_string(Temperature);
   delay_ms(100);
}
void DisplayHeart()
{
    HeartPulse();   //heart function

   LCD_send_string(HeartBeat);
   delay_ms(100);
}


void buttonSystem()
{
if(PORTD.B7==0)
{
delay_ms(100);
//PORTC.F1=0;
while(PORTD.B7==1)
{
PORTB.B1=0;
LCD_send_string(" OFF ");
}
PORTB.B1=1;
}
}
void bcValue()
{
if(PORTD.b0==0&&bc==0)
{
delay_ms(100);
bc=1;
}
else if(PORTD.b0==0&&bc==1)
{
delay_ms(100);
bc=2;
}
else if(PORTD.b0==0&&bc==2)
{
delay_ms(100);
bc=0;
}
}
void DisplayLCDChange()
{
while(bc==0)
{
LCD_Home();
DisplayTemp();
LCD_second_row();
DisplayHeart();
delay_ms(1);
buttonSystem();
bcValue();
PORTD.B3==1;
}
while(bc==1)
{
LCD_Home();
DisplayTemp();
delay_ms(1);
buttonSystem();
bcValue();
}
while(bc==2)
{
LCD_Home();
DisplayHeart();
delay_ms(1);
buttonSystem();
bcValue();
}
}

void main()
{
  Port_init();
  SPI_init();
  LCD_init();
  OSCCON = 0x60; //8mhz
  Analog_Init();
  DisplayLCD();
  ser_int();



     while(1)
     {
      DisplayLCDChange();


     }

}
