# VHDL-project  
## OVERVIEW  
Implementation of a HW component described in VHDL that receives an image and calculates the area of the minimum rectangle that completely surrounds a figure represented by a sequence of bytes.  
## INPUT  
The file is divided in two parts.  
The first one is a header that describes the structure, the second one instead describes the content of image.  
- Header: it is divided in three parts, each one of the size of a byte.  The first byte contains the number of columns of the image, the second one contains the number of rows of the image and the third one contains the threshold value for the figure of interest.  
- The image content is encoded as a matrix (column*rows) in which each element represents the value of a single pixel that varies between 0 and 255.  
If the value of a pixel is equal/greater than the threshold value, this pixel belongs to the picture, otherwise it is a pixel of the background.  
## OUTPUT  
The area's value of the rectangle is located in byte '0' and '1' in the memory.  In byte '1' there is the most significant part of the area (in terms of bytes), in byte '0' the other one.  
## CONVENTIONS  
- The image is located in memory starting from byte '2'.  
- The module will start processing when an incoming START signal assumes value 1 for one clock cycle.  
- At the end of the computation the module will bring DONE signal to 1 for one clock cycle.  
- A new start signal can not be given as long as DONE has not been reset to '0'.  
- THE MEMORY IS ALREADY ISTANTIATED WITHIN THE TESTBENCH AND SHOULDN'T BE SYNTHESIZED. 
## SIGNALS
- i_clk is clock signal generated by TestBench;
- i_start is START signal generated by TestBench;
- i_rst is the signal of reset that starts the machine to receive START signal;
- i_data is the signal (vector) that comes from memory after a request for reading;
- o_address is the signal (vector) that sends the address to the memory;
- o_done is the ouput signal that comunicates the end of the elaboration;
- o_en is the signal to be sent to the memory in order to communicate with the component;
- o_we is the signal to be sent to the memory in order to write on it;
- o_data is the signal (vector) of output from the component to the memory.

## EXAMPLE
24 7  
2  
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  
0 3 3 3 3 0 0 7 7 7 7 0 0 11 11 11 11 0 0 15 0 0 0 0  
0 3 0 0 0 0 0 7 0 0 0 0 0 31 0 0 0 0 0 25 0 0 0 0  
0 3 3 3 0 0 0 7 7 7 0 0 0 31 31 11 0 0 0 25 0 0 0 0  
0 3 0 0 0 0 0 7 0 0 0 0 0 31 0 0 0 0 0 25 0 0 0 0  
0 3 0 0 0 0 0 7 7 7 7 0 0 11 11 11 11 0 0 15 15 15 15 0  
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

- threshold = 0 -> area is 168 pixels.
- threshold < 4 -> area is 110 pixels.
- 3 < threshold < 8  -> area is 80 pixels.
- 11< threshold < 16 -> area is 50 pixels.
- threshold > 31 -> area is 0 pixels.
