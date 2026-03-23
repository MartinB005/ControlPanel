-------------------------------------------------------------
-- LCD image created by logic
-------------------------------------------------------------

library ieee, work; use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; -- for integer and unsigned types
use work.LCDpackV2.all;
entity LCDlogic0 is
    port(xcolumn, yrow  : in  xy_t  := XY_ZERO; -- x, y-coordinate of pixel (column, row indexes)
           XEND_N   : in  std_logic := '0'; -- 32.2 kHz'; '0' only when xcolumn=XCOLUMN_MAX, otherwise '1;
           YEND_N   : in  std_logic := '0'; -- 61.4 Hz; '0' only when max yrow=YROW_MAX, otherwise '1',
           LCD_DE   : in  std_logic := '0';   -- DataEnable indicates the visible part of LCD
           LCD_DCLK : in  std_logic := '0'; -- 33 MHz exactly; LCD data clock
          RGBcolor : out RGB_t); --  defined in LCDpackV2; RGB_t = std_logic_vector(23 downto 0)
end entity;
architecture behavioral of LCDlogic0 is
  constant DARKBLUE: RGB_t := ToRGB(0, 0, 139); -- the background
  begin -- architecture
  
LSPimage : process( xcolumn, yrow, LCD_DE)
-- In any process, we prefer variables. They must be initialized in the code!!!
-- The values after definitions are mainly for simulations. 
   variable RGB :RGB_t := YELLOW; -- the color of pixel 
   variable x : integer  range 0 to XCOLUMN_MAX:=0; 
   variable y : integer  range 0 to YROW_MAX:=0; 
  begin 
     x := to_integer(xcolumn); y := to_integer(yrow); -- we convert unsigned inputs to integers
     ---------- our image -------------------------
     RGB :=ORANGE;   
     
     if (y + LCD_WIDTH/2 < 2 * x - 300) and (y < LCD_HEIGHT/3) then RGB:=OLIVE; end if; 
     if (y + LCD_WIDTH/2 > LCD_WIDTH *2 - 2 * x) and (y > 2*LCD_HEIGHT/3) then RGB:=OLIVE; end if; 
	  
     if (x < 500) and (y > LCD_HEIGHT/3) and (y < 2*LCD_HEIGHT/3) 
		and 3**2 *(x-500)**2 + 2**2 *(y-240)**2 > (250)**2 then RGB:=YELLOW; end if; 
		
	  	if 8 *(x-600)**2 + 22 *(y-240)**2 < (300)**2 and 8 *(x-600)**2 + 10 *(y-240)**2 > (230)**2 then
			if (x > 550) then RGB:=YELLOW; else RGB:=OLIVE; end if;
	  end if;
	  
	  if 3**2 *(x-600)**2 + 5**2 *(y-240)**2 < (300)**2 and 3**2 *(x-600)**2 + 5**2/2 *(y-240)**2 > (260)**2 then
			if (x > 600) then RGB:=OLIVE; else RGB:=YELLOW; end if;
	  end if;
	  

     ------------------------------------------------------------
     if LCD_DE = '0' then  RGB  := BLACK; end if; -- auxiliary clipping to LCD visible area
    
	   RGBcolor <= RGB; -- assigning to output at the end
   end process;
	
end architecture;


 