
    
---------------------------------------------------------------------------------
-- Company: 
-- Engineer: Ibrahim El Shemy - CODICE PERSONA: 10491265
-- Engineer: Marco Gasperini - CODICE PERSONA: 10533178

-- Create Date: 
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity project_reti_logiche is 
port (
        i_clk: in std_logic; -- segnale di CLOCK in ingresso generato dal TestBench
        i_start: in std_logic; -- segnale di START generato dal TestBench
        i_rst: in std_logic; -- segnale di RESET che inizializza la macchina pronta per ricevere il primo segnale di START
        i_data: in std_logic_vector(7 downto 0); -- segnale (vettore) che arriva dalla memoria in seguito ad una richiesta di lettura
        o_address: out std_logic_vector(15 downto 0); -- segnale (vettore) di uscita che manda l'indirizzo alla memoria
        o_done: out std_logic; -- segnale di uscita che comunica la fine dell'elaborazione e il dato di uscita scritto in memoria
        o_en: out std_logic; -- segnale di ENABLE da dover mandare alla memoria per poter comunicarci (sia in lettura che in scrittura)
        o_we: out std_logic; --  segnale di WRITE ENABLE da dover mandare alla memoria (=1) per poter scriverci. Per leggere da memoria esso deve essere 0.
        o_data: out std_logic_vector(7 downto 0) -- segnale (vettore) di uscita dal componente verso la memoria
 );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

TYPE State_type IS (RST,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14);
signal State: State_Type:= RST;

signal maxRIGA: std_logic_vector (7 downto 0):=(others=>'0');
signal minRIGA: std_logic_vector (7 downto 0):=(others=>'0');
signal maxCOLONNA: std_logic_vector (15 downto 0):=(others=>'0');
signal minCOLONNA: std_logic_vector (15 downto 0):=(others=>'0');
signal area: std_logic_vector (15 downto 0):=(others=>'0');
signal riga: std_logic_vector (7 downto 0):=(0=>'1', others=>'0');
signal colonna: std_logic_vector (7 downto 0):=(0=>'1', others=>'0');
signal altezza: std_logic_vector (7 downto 0):=(others=>'0');
signal base: std_logic_vector (15 downto 0):=(others=>'0');
signal controllo: std_logic_vector (15 downto 0):=(others=>'0');

signal colonne: std_logic_vector (7 downto 0):=(others=>'0');
signal righe: std_logic_vector (7 downto 0):=(others=>'0');
signal soglia: std_logic_vector (7 downto 0):=(others=>'0');

signal temp_address: std_logic_vector (15 downto 0):=(0=>'1', others=>'0');
signal trovato_maxRIGA: std_logic:='0';

begin
FSM: process(i_clk, i_rst, i_start, State)

begin
if i_rst='1' then
    State <= RST;
end if; 
  
if falling_edge (i_clk) then
    case State is
    
        when RST =>
            o_address <= (1=>'1', others=>'0');
            trovato_maxRIGA <= '0';
            riga<= (0=>'1', others=>'0');
            colonna<= (0=>'1', others=>'0');
            State <= S1;
            
        when S1 => -- IN QUESTO STATO VIENE ABILITATA LA LETTURA DA MEMORIA E DISABILITATA LA SCRITTURA
            if i_start = '1' then
                o_en <= '1';
                o_we <= '0';
                State <= S2;
            end if;
            
        when S2 => -- CALCOLO IL NUMERO DI COLONNE DELLA FIGURA DALL'HEADER DEL FILE E LO ASSEGNO AL SEGNALE colonne
            colonne <= i_data;
            minCOLONNA <= "0000000000000000" + i_data;
            o_address <= (0=>'1', 1=>'1', others=>'0');
            State <= S3;
                
        when S3 => -- CALCOLO IL NUMERO DI RIGHE DELLA FIGURA DALL'HEADER DEL FILE E LO ASSEGNO AL SEGNALE righe
            righe<=i_data;
            o_address <= (2=>'1', others=>'0'); 
            State <= S4;
            
        when S4 => -- CALCOLO IL VALORE DELLA SOGLIA PER LA FIGURA D'INTERESSE E L'ASSEGNO A soglia
            soglia <= i_data;
            controllo <= righe*colonne +4;
            State <= S5;
            
        when S5 => -- HO FINITO DI LEGGERE L'HEADER
            temp_address <= (2=>'1', others=>'0');
            State <= S6;
        
        when S6 => -- INCREMENTO INIDRIZZO DI MEMORIA
            temp_address <= temp_address + 1;
            o_address <= temp_address+1;
            State <= S7;
               
        when S7 => -- ALGORITMO PRINCIPALE:  UTILE PER IL CALCOLO DI BASE E ALTEZZA DELLA FIGURA D'INTERESSE    
            
            if colonna = colonne then
                colonna <= "00000001";
                riga <= riga + 1;
            else
                colonna <= colonna + 1;
            end if;
            
            if i_data >= soglia then                
                if trovato_maxRIGA = '0' then
                    maxRIGA <= riga;
                    trovato_maxRIGA <= '1';
                end if;                
                minRIGA <= riga;
                
                if colonna < minCOLONNA then
                    minCOLONNA <= "0000000000000000" + colonna;
                end if;
                
                if colonna > maxCOLONNA then
                    maxCOLONNA <= "0000000000000000" + colonna;
                end if;
            end if;
         
            if temp_address = controllo then
                colonna <= (others=>'0');
                State <= S8;
            else
                temp_address <= temp_address + 1;
                o_address <= temp_address;
            end if;    
              
            
        when S8=> -- CALCOLO AREA NEL CASO DI UNA FIGURA VUOTA
            if trovato_maxRIGA = '0' then
                area <= (others=>'0');
                State <= S10;
            else
                base <= maxCOLONNA - minCOLONNA + 1;
                altezza <= minRIGA - maxRIGA + 1;
                State <= S9;
            end if;
            
           
       when S9 => -- CALCOLO AREA
        if colonna < altezza then
            area <= area + base;
            colonna <= colonna + 1;
        end if;
        if colonna = altezza then
            State <= s10;    
        end if;
            
            
        when S10 => -- AZZERO L'INDIRIZZO DI MEMORIA E ABILITO IL SEGANLE DI SCRITTURA
            o_address <= (others=>'0');
            o_we <= '1';
            State <= S11;
        
        when S11 => -- SCRIVO IN MEMORIA LA PARTE MENO SIGNIFICATIVA DELL'AREA
            o_data <= area(7 downto 0);
            State <= S12;
            
        when S12 => -- INCREMENTO L'INDIRIZZO DI MEMORIA IN CUI ANDRÒ A SCRIVERE LA PARTE PIÙ SIGNIFICATIVA DELL'AREA
            o_address <= (0=>'1', others=>'0');
            State <= S13;  
        
        when S13 => -- SCRIVO IN MEMORIA LA PARTE PIÙ SIGNIFICATIVA DELL'AREA
            o_data <= area(15 downto 8);
            o_done <= '1';
            State <= S14;
        
        when S14 =>  -- PORTO o_done e o_en a '0' E RESETTO LA MACCHINA
            o_done <= '0';
            o_en <= '0';
            State <= RST;
                      
    end case;
end if;

end process FSM;
end Behavioral;