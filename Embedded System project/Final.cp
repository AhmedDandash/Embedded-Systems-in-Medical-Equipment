#line 1 "D:/Team 8 Embedded System/Final.c"

unsigned char LCDpins;
#line 30 "D:/Team 8 Embedded System/Final.c"
 void SPI_init()
{


 SSPCON.B3= 0;
 SSPCON.B2= 0;
 SSPCON.B1= 0;
 SSPCON.B0= 0;
 SSPCON.SSPEN=1;

 SSPCON.CKP= 0;

 SSPSTAT.CKE=1;

 SSPSTAT.SMP=0;
 TRISC.B3 = 0;
 TRISC.B5=0;


}
unsigned char wr_SPI ( unsigned char dat )
{
 SSPBUF = dat;
 while( !SSPSTAT.BF );
 return ( SSPBUF );
}


void SPI_to_74HC595( )
{
 wr_SPI ( LCDpins );
 PORTE.B0 = 1;
 PORTE.B0 = 0;
}

 void LCD_sendbyte( unsigned char tosend )
{
 LCDpins &= 0x0f;
 LCDpins |= ( tosend & 0xf0 );
 LCDpins |=  0x08  ;
 SPI_to_74HC595();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595();
 LCDpins &= 0x0f;
 LCDpins |= ( tosend << 4 ) & 0xf0;
 LCDpins |=  0x08  ;
 SPI_to_74HC595();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595();
}
 void LCD_sendcmd(unsigned char a)
 { LCDpins &= ~ 0x04  ;
 LCD_sendbyte(a);
 }

void LCD_sendchar(unsigned char a)
{ LCDpins |=  0x04  ;
 LCD_sendbyte(a);
}



void LCD_init ( void )
{
 LCDpins &= ~ 0x04  ;
 PORTE.B0 = 0;

 Delay_ms(100);

 LCDpins = 0x30;
 LCDpins |=  0x08  ;
 SPI_to_74HC595 ();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595 ();

 Delay_ms(10);
 LCDpins |=  0x08  ;
 SPI_to_74HC595 ();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595 ();

 Delay_ms(10);
 LCDpins |=  0x08  ;
 SPI_to_74HC595 ();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595 ();

 Delay_ms(10);
 LCDpins = 0x20;
 LCDpins |=  0x08  ;
 SPI_to_74HC595();
 LCDpins &= ~ 0x08  ;
 SPI_to_74HC595();

 Delay_ms(10);
 LCD_sendcmd ( 0x28 );
 Delay_ms(10);
 LCD_sendcmd ( 0x01 );
 Delay_ms(10);
 LCD_sendcmd ( 0x0c );
 Delay_ms(10);
 LCD_sendcmd ( 0x06 );
}
void LCD_send_string( char *str_ptr )
{
 while (*str_ptr) {
 LCD_sendchar(*str_ptr);
 str_ptr++;
 }
}
void LCD_second_row( )
{
 LCD_sendcmd( 0xc0 );
}


void LCD_Home( )
{
 LCD_sendcmd(  0x01  );
 Delay_ms(10);
 LCD_sendcmd(  0x02  );
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

 void ser_int();
void tx(char);

 void DisplayLCD()
{


 LCD_Home();
 LCD_send_string(" Ready");
 delay_ms(500);


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
 TRISC.f6=0;
 TRISC.f7=1;
 TRISE.F2=1;
 PORTB.B1=1;
 TRISB.B1=0;
 ADCON0.GO=1;
 TMR0=0X04;
 INTCON=0b10100000;
 OPTION_REG=0b00010111;
 T1CON.TMR1ON = 1;
 T1CON.TMR1CS = 1;
 TMR1L = 0;
 TMR1H = 0;
 }
 void Analog_Init(){
ADCON0 = 0x80;
ADCON1 = 0x80;

ADCON0.CHS0 = 0;
ADCON0.CHS1 = 0;
ADCON0.CHS2 = 0;
ADCON0.ADON = 1;
}
 void ser_int()
{
 TXSTA=0x20;
 RCSTA=0b10000000;
 SPBRG=5;
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


 for(dr=0;dr<=11;dr++ )
 {
 tx(Temperature[dr]);
 }
 tx(13);

}
void interrupt(){
 if(INTCON.f2=1)
 {
 INTCON.f2=0;
 }

cnt++;
 if(cnt==155)
 {


 pul = (TMR1H<<8)|(TMR1L);


 cnt=0;
 TMR1H=0;
 TMR1L=0;

 }
 TMR0=0X04;
}
void HeartPulse()
{


bpm=60000/pul;
 hr=bpm/100;
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
 HeartPulse();

 LCD_send_string(HeartBeat);
 delay_ms(100);
}


void buttonSystem()
{
if(PORTD.B7==0)
{
delay_ms(100);

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
 OSCCON = 0x60;
 Analog_Init();
 DisplayLCD();
 ser_int();



 while(1)
 {
 DisplayLCDChange();


 }

}
