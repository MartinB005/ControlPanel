-------------------------------------------------------------
-- LCD image created by logic
-------------------------------------------------------------

library ieee, work; use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; -- for integer and unsigned types
use work.LCDpackV2.all;
entity MainLogic is
    port(xcolumn, yrow  : in  xy_t  := XY_ZERO; -- x, y-coordinate of pixel (column, row indexes)
           XEND_N   : in  std_logic := '0'; -- 32.2 kHz'; '0' only when xcolumn=XCOLUMN_MAX, otherwise '1;
           YEND_N   : in  std_logic := '0'; -- 61.4 Hz; '0' only when max yrow=YROW_MAX, otherwise '1',
           LCD_DE   : in  std_logic := '0';   -- DataEnable indicates the visible part of LCD
           LCD_DCLK : in  std_logic := '0'; -- 33 MHz exactly; LCD data clock
          RGBcolor : out RGB_t); --  defined in LCDpackV2; RGB_t = std_logic_vector(23 downto 0)
end entity;
architecture behavioral of MainLogic is
  constant DARKBLUE: RGB_t := ToRGB(0, 0, 139); -- the background
  type sizes_t is record Width, Height: integer; end record;
  constant L10img : sizes_t :=(192,70);
  constant L10r1 : rect_t :=(520, 170, L10img.Width, L10img.Height);
  constant L10r2 : rect_t :=(520, 170 + L10img.Height, L10img.Width, L10img.Height);
  constant MORSE : std_logic_vector(0 to 57) := "0111011100011101010100010001011101010001000101110111011100";


  
  type palette is array (0 to 2) of RGB_t;
  constant L10p1:palette:=(X"EF7B19",  X"FFEF00",  X"4A8C7B");

  signal L10addr: std_logic_vector(13 downto 0):=(others=>'0');
  signal L10q, L10q0: std_logic_vector(1 downto 0):=(others=>'0');
  
  function toSlv(n:integer; slvWidth:positive) return std_logic_vector is
	begin return std_logic_vector(to_unsigned(n,slvWidth));
  end function;
  
  
signal counter : integer := 0;
signal tick    : std_logic := '0';

constant DIVIDER : integer := 5000000; -- adjust for speed
  
  signal index : integer range 0 to 59 := 0;
signal morse_bit : std_logic;

begin

-- clocked process

process(LCD_DCLK)
begin
    if rising_edge(LCD_DCLK) then
        if counter = DIVIDER then
            counter <= 0;
            tick <= '1';
        else
            counter <= counter + 1;
            tick <= '0';
        end if;
    end if;
end process;

process(LCD_DCLK)
begin
    if rising_edge(LCD_DCLK) then
        if tick = '1' then
            if index = 59 then
                index <= 0;
            else
                index <= index + 1;
            end if;
        end if;
    end if;
end process;

-- read MORSE
morse_bit <= MORSE(index);
  
  iL10Rom : entity work.L10Rom port map(L10addr, LCD_DCLK, L10q0);
 L10q<=L10q0 when rising_edge(LCD_DCLK);
  
LSPimage : process( xcolumn, yrow, LCD_DE)
-- In any process, we prefer variables. They must be initialized in the code!!!
-- The values after definitions are mainly for simulations. 
   variable RGB :RGB_t := YELLOW; -- the color of pixel 
   variable x : integer  range 0 to XCOLUMN_MAX:=0; 
   variable y : integer  range 0 to YROW_MAX:=0;
	
	 variable L10idRect : integer range 0 to 2:=0; -- the flag that the x,y pixel is inside a rectangle, 0 - no
	variable L10ixColor : integer range L10p1'RANGE:=0; -- the
  begin 
     x := to_integer(xcolumn); y := to_integer(yrow); -- we convert unsigned inputs to integers
	  L10idRect:=0;
	  if InRect(L10r1, x, y) then L10idRect:=1; elsif InRect(L10r2,x,y) then L10idRect:=2; end if;
	  L10ixColor := to_integer(unsigned(L10q));
	  
     ---------- our image -------------------------
     RGB :=ORANGE;   
     
     if (y + LCD_WIDTH/2 < 2 * x - 300) and (y < LCD_HEIGHT/3) then RGB:=OLIVE; end if; 
     if (y > LCD_WIDTH + 378 - 2 * x) and (y > 2*LCD_HEIGHT/3) then RGB:=OLIVE; end if; 
	  
    
		
	if (morse_bit = '1') then
		
	  if L10idRect > 0 and L10ixColor/=3 then -- Is the current pixel in any rectangle and a color-index is a opacity color?
		RGB:=L10p1(L10ixColor);
	  end if;
	  

	 end if;
	 
	  case L10idRect is
			when 1=> L10addr<=toSlv( (y-L10r1.Y)*L10img.Width+(x-L10r1.X), L10addr'LENGTH );
			when 2=> L10addr<=toSlv( (L10img.Height-(y-L10r2.Y)-1)*L10img.Width+(x-L10r2.X), L10addr'LENGTH );
			when others=> L10addr<=(others=>'0');
	  end case;
	  
	  
	   if (x < 500) and (y > LCD_HEIGHT/3) and (y < 2*LCD_HEIGHT/3) 
		and 3**2 *(x-500)**2 + 2**2 *(y-240)**2 > (250)**2 then RGB:=YELLOW; end if;
		
		if (y > 400 and y < 420 and MORSE(x * 37 / 512 ) = '1') then
				RGB := GREEN; 
		end if;
		
		if (y > 390 and y < 430 and index * 512 / 37 > x - 2 and index * 512 / 37 < x + 2) then
			RGB := RED;
		end if;
	  
     ------------------------------------------------------------
     if LCD_DE = '0' then  RGB  := BLACK; end if; -- auxiliary clipping to LCD visible area
    
	   RGBcolor <= RGB; -- assigning to output at the end
   end process;
	
end architecture;


