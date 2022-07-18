# ECE 520 Spring 2022
**California State University, Northridge**  
**Department of Electrical and Computer Engineering**  

# Image Processing Platform on the Zedboard using the OV7670 Camera Pmod

**Report Created by:**
- FNU HARDIK

**Submission date:** 05/14/2022

**Link to Demo Video:** [Youtube_Video_Demo](https://youtu.be/2vIdqfb_39w)  
**Link to Secondary Demo Video:** [FPS_Check](https://youtu.be/34jz1RZQFFE)    

# Implementation Guide
In order to replicate my project you'll need to create a Vivado Project using the source files provided in this repository. The steps for replicating my project are detailed below.  
- Step 1: Copy all VHDL files inside the sources folder in this repository.  
- Step 2: The hierarchy of VHDL files for this project is shown in the image below.  
![VHDL_Hierarchy](./Presentation/images/Screenshot%20(376).png)  
- Step 3: You'll need to add two IP blocks into this design they are: CLocking Wizard and BRAM.  
- Step 4: Add one instance of the clocking wizard, we won't be utilizing the Zynq Processing System clock, instead we'll utilize the PL clock provied at pin Y9 and reduce it via the clocking wizard. Set outputs 3 and 4 of the IP to 50 Mhz and 25 Mhz respectively.
- Step 5: Now add two instances of BRAM IP. For the first one, make sure to select always enables for the we pin, then you'll need to set port width as 8 bits and depth as 307200. For the second BRAM IP block, set the port widths as 4 bits and the same depth of 307200.   

Note:- Don't customize the names of the newly added IP blocks, I've set the top level VHDL files to instantiate these modules with the default names that Vivado will assign.  

- Step 6: Now you are ready to synthesize the design, we now need to add the pin mappings in this stage, the two images below contain the pin mapping information (The constraint file is also present in the sources folder just in case).  
![Pin_Mappings_1](./Presentation/images/Screenshot%20(377).png)  
![Pin_Mappings_2](./Presentation/images/Screenshot%20(378).png)  
- Step 7: Now you are ready to make final connections on the Zedboard, generate the bitstream and use Vivado's Hardware Manager to program and run the FPGA.