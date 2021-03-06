/*
This is test code for Project Grabber. This program includes basic control of the arm and
 * sensor feedback from the PING sensor. It requires the .NET 2.0 framework for proper function
 * for the COM port.
 * 
 * Daniel Rowan - 8DDA - 2006
 */

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing; 
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;

//include threading
using System.Threading; 

namespace COM_Port_Test
{

    public partial class frmMain : Form
    {

    //create a thread
    Thread tSerialDataIn = null;

    //Integer value for Ping0 sensor
        bool bSerialChk = false;
        int iTest = 0, iTest1 = 0, iTest2 = 0;
     
    //For now assume COM1 is the one to use
    SerialPort sp = new SerialPort("COM1", 2400);

    //SerialPort sp = new SerialPort();

        public frmMain()
        {
            InitializeComponent();
        }

        #region Form1_Load & serial port init
        private void Form1_Load(object sender, EventArgs e)
        {
            /*This is the serial port read thread, right now it is "unsafe" 
             * but will serve as a test platform
             *Tempory fix for threading for now...
            */ 
            Control.CheckForIllegalCrossThreadCalls = false; //unsafe...but meh

            this.sp.DataReceived += new SerialDataReceivedEventHandler(this.sp_DataReceived); //data event handler
            this.sp.ErrorReceived += new System.IO.Ports.SerialErrorReceivedEventHandler(this.sp_ErrorReceived);
            

            //this creates the thread upon load, and ties it to the tSerialDataIn function 
            tSerialDataIn = new Thread(new ThreadStart(serialDataInThread));
            tSerialDataIn.Start();

            //Get a serial port at COM1           
            try
            {
                //open serial port
                sp.Open();
                
                //set read time out to 500 ms
                sp.ReadTimeout = 550;

                baudRatelLabel.Text = "COM1 Online" + " Baud Rate: " + sp.BaudRate;
            }
            catch (System.Exception ex)
            {
                baudRatelLabel.Text = ex.Message;
            }

            //Set the bars to zero, probably do in loop
            barCh0.Value = 750;
            textCh0Pos.Text = barCh0.Value.ToString();
            barCh2.Value = 750;
            textCh2Pos.Text = barCh2.Value.ToString();
            barCh4.Value = 750;
            textCh4Pos.Text = barCh4.Value.ToString();
            barCh6.Value = 750;
            textCh6Pos.Text = barCh6.Value.ToString();
            barCh8.Value = 750;
            textCh8Pos.Text = barCh8.Value.ToString();
            barCh10.Value = 750;
            textCh10Pos.Text = barCh10.Value.ToString();
            barCh12.Value = 750;
            textCh12Pos.Text = barCh12.Value.ToString();
        }
        #endregion
        
        #region COM Port Test Code, Send/Rec
        //Send out a Message
        private void btnSndCom_Click(object sender, EventArgs e)
        {
            //Pass byte array with instructions to function
            funcComOut(textSndCom.Text);
        }

        //Recieve a Message
        private void btnRecCom_Click(object sender, EventArgs e)
        {

            //iDataRtrn = funcComIn();

            textRcvCom.Text = funcComIn().ToString();
        }
        #endregion

        #region COM Port Output functions
        ///<summary>
        ///One overloaded function that can send out pure bytes or ASCII messages
        ///</summary>
 
        //Com port Byte array output function
        private void funcComOut(byte[] btyaOutCom)
        {
            try
            {
                //write the bytes to serial port
                //the byte array, where to start, and how many bytes to send in the array
                sp.Write(btyaOutCom, 0, 8);
                           
                //clear the text box
                textSndCom.Text = "";
            }
            catch (System.Exception ex)
            {
                baudRatelLabel.Text = ex.Message;
            }
          
        }

        //Com port String message output function, overloaded
        private void funcComOut(string strOutCom)
        {
            try
            {
                //write the bytes to serial port
                //the byte array, where to start, and how many bytes to send in the array
                sp.WriteLine(strOutCom);

                //clear the text box
                textSndCom.Text = "";
            }
            catch (System.Exception ex)
            {
                baudRatelLabel.Text = ex.Message;
            }

        }
        #endregion

        #region COM port recieve functions
        /// <summary>
        /// Recieve functions, either ascii string or byte array returned
        /// </summary>
        
        //Com port string recieve function
        private string funcComIn()
        {
            string strRcvCom = "";
            try
            {
                //clear the text box
                textRcvCom.Text = "";
                //read serial port and displayed the data in text box
                strRcvCom = sp.ReadLine();
            }
            catch (System.Exception ex)
            {
                baudRatelLabel.Text = ex.Message;
                //bSerialChk = false;
            }

        return strRcvCom;
        }

        private byte funcComByteIn()
        {
            byte[] bytStore = { 0 };
            try
            {
                sp.Read(bytStore, 0, 1);
            }
            catch (System.Exception)
            {
                iTest2++;
                textBox4.Text = iTest2.ToString();
                return 0;   //return 0 if times out
            }
            return bytStore[0];
        }
        #endregion
        
    #region Servo slider position conversion function
    private void funcSndServoPos(int iSCh, int iSRa, int iSPos)
        {
            int iLowByte = iSPos % 256, iHighByte = iSPos / 256;

            //Encode the instructions into bytes
            //!, S, C, Channel, Ramp, low byte in int form, high byte in int form, carriage return
            Byte[] encodedBytes = { 33, 83, 67, (byte)iSCh, (byte)iSRa, (byte)iLowByte, (byte)iHighByte, 13 };

            //Pass byte array with instructions to function
            funcComOut(encodedBytes);
        }
#endregion

        #region Slider position pass code
        /// <Sumnary>
        /// Reads value from slider bars and passes it to the 
        /// Servo Position function
        /// </Sumnary>
   
        //Scroll bars for each servo channel
        private void barCh0_Scroll(object sender, ScrollEventArgs e) //Grip channel
        {
            textCh0Pos.Text = barCh0.Value.ToString();

            funcSndServoPos(2, 0, barCh0.Value);
        }

        private void barCh2_Scroll(object sender, ScrollEventArgs e) //Wrist channel
        {
            textCh2Pos.Text = barCh2.Value.ToString();

            funcSndServoPos(8, 0, barCh2.Value);
        }

        private void barCh4_Scroll(object sender, ScrollEventArgs e) //Elbow channel
        {
            textCh4Pos.Text = barCh4.Value.ToString();

            funcSndServoPos(14, 0, barCh4.Value);
        }

        private void barCh6_Scroll(object sender, ScrollEventArgs e) //Shoulder base pair channels
        {
            textCh6Pos.Text = barCh6.Value.ToString();

            funcSndServoPos(3, 0, barCh6.Value);
            funcSndServoPos(9, 0, barCh6.Value);
        }

        private void barCh8_Scroll(object sender, ScrollEventArgs e) //Rotation Channel
        {
            textCh8Pos.Text = barCh8.Value.ToString();
            //exprimental lower motor test
            funcSndServoPos(15, 0, barCh8.Value);
        }

        private void barCh10_Scroll(object sender, ScrollEventArgs e)
        {
            textCh10Pos.Text = barCh10.Value.ToString();

            //funcSndServoPos(10, 0, barCh10.Value);
        }

        private void barCh12_Scroll(object sender, ScrollEventArgs e)
        {
            textCh12Pos.Text = barCh12.Value.ToString();

            //funcSndServoPos(12, 0, barCh12.Value);
        }
#endregion

        #region Slider position reset code
        private void btnSPosCntr_Click(object sender, EventArgs e)
        {
            /*W/O Current Sensors
            //probably need antoher loop
            funcSndServoPos(0, 0, 750);
            textCh0Pos.Text = (barCh0.Value = 750).ToString();
            funcSndServoPos(2, 0, 750);
            textCh2Pos.Text = (barCh2.Value = 750).ToString();
            funcSndServoPos(4, 0, 750);
            textCh4Pos.Text = (barCh4.Value = 750).ToString();
            funcSndServoPos(6, 0, 750);
            textCh6Pos.Text = (barCh6.Value = 750).ToString();
            funcSndServoPos(8, 0, 750);
            textCh8Pos.Text = (barCh8.Value = 750).ToString();
            funcSndServoPos(10, 0, 750);
            textCh10Pos.Text = (barCh10.Value = 750).ToString();
            funcSndServoPos(12, 0, 750);
            textCh12Pos.Text = (barCh12.Value = 750).ToString();
            */
            funcSndServoPos(2, 0, 750);
            textCh0Pos.Text = (barCh0.Value = 750).ToString();
            funcSndServoPos(8, 0, 750);
            textCh2Pos.Text = (barCh2.Value = 750).ToString();
            funcSndServoPos(14, 0, 750);
            textCh4Pos.Text = (barCh4.Value = 750).ToString();
            funcSndServoPos(3, 0, 750);
            textCh6Pos.Text = (barCh6.Value = 750).ToString();
            funcSndServoPos(9, 0, 750);
            textCh8Pos.Text = (barCh8.Value = 750).ToString();
            funcSndServoPos(15, 0, 750);
            textCh10Pos.Text = (barCh10.Value = 750).ToString();
            funcSndServoPos(12, 0, 750);
            textCh12Pos.Text = (barCh12.Value = 750).ToString();
        }
        #endregion

        #region COM Port background thread
        public void serialDataInThread()
        {
            int iThreadSleep = 0;  //define how long to have the string sleep when done
            int iSearchCOM = 0;     //int that defines how many times to search for a valid byte
            do
            {
                bSerialChk = true;
                byte[] bytDataBuffer = { 0, 0, 0, 0, }; //This loop will keep looking for valid bytes
                do
                {
                    bytDataBuffer[0] = funcComByteIn();
                    if (bytDataBuffer[0] == 251)
                    {
                        bytDataBuffer[0] = funcComByteIn();

                        if (bytDataBuffer[0] == 251)
                        {
                            bSerialChk = true;      //checked ok
                        }

                        else
                        {
                            bSerialChk = false;
                        }

                    }

                    else
                    {
                        bSerialChk = false;
                    }


                }
                while (!bSerialChk);

                bytDataBuffer[1] = funcComByteIn();    //Should be identifier byte
                bytDataBuffer[2] = funcComByteIn();    //Should be high data byte
                bytDataBuffer[3] = funcComByteIn();    //Should be low data byte
                bytDataBuffer[0] = funcComByteIn();    //Should be $ byte

                if (bytDataBuffer[0] == 36)             //See if last byte if valid
                {
                    #region Sensor Calculations
                    if (bytDataBuffer[1] == 33)          //See if ! is present for experiment, PING0
                    {
                        //treated as ints, high byte multiplied by 255, then added to low byte
                        //very poor way of doing this, but need to get idea of accuracy
                        txtPing0.Text = Convert.ToString((((bytDataBuffer[2] * 256) + bytDataBuffer[3]) / 2) / 147.492f);
                        

                        //basically number of cycles (counts at 2MHz on PIC) halfed b/c time is both 
                        //to and from time, then divided number of cycles every 73.746us (time for 1 inch to move
                        //through air in most cases

                    }

                    if (bytDataBuffer[1] == 34) //PING1
                    {
                        txtPing1.Text = Convert.ToString((((bytDataBuffer[2] * 256) + bytDataBuffer[3]) / 2) / 147.492f);
                    }

                    if (bytDataBuffer[1] == 35) //PING2
                    {
                        txtPing2.Text = Convert.ToString((((bytDataBuffer[2] * 256) + bytDataBuffer[3]) / 2) / 147.492f);
                    }
 
                    if (bytDataBuffer[1] == 128) //ANCH00 0x80 - IRRANGE 1
                    {

                        txtVol00.Text = Convert.ToString((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f);

                    }

                    if (bytDataBuffer[1] == 132) //ANCH01 0x84 - Reserved
                    {

                        txtVol01.Text = Convert.ToString((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f);

                    }
                    if (bytDataBuffer[1] == 136) //ANCH02 0x88 - Pressure Sensor 1
                    {

                        txtVol02.Text = Convert.ToString((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f);

                    }
                    if (bytDataBuffer[1] == 140) //ANCH03 0x8C - IRRANGE 2
                    {

                        txtVol03.Text = Convert.ToString((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f);

                    }
                    if (bytDataBuffer[1] == 144) //ANCH04 0x90 - Servo 2
                    {

                        txtVol04.Text = Convert.ToString((((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f)- 2.48f) / 0.133f);

                    }
                    if (bytDataBuffer[1] == 148) //ANCH05 0x94 - Servo 8
                    {

                        txtVol05.Text = Convert.ToString((((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f) - 2.48f) / 0.133f);

                    }
                    if (bytDataBuffer[1] == 152) //ANCH06 0x98 - Servo 14
                    {

                        txtVol06.Text = Convert.ToString((((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f) - 2.48f) / 0.133f);

                    }

                    if (bytDataBuffer[1] == 156) //ANCH07 0x9C - Servo 3
                    {

                        txtVol07.Text = Convert.ToString((((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f)- 2.48f) / 0.133f);

                    }

                    if (bytDataBuffer[1] == 160) //ANCH08 0xA0 - Servo 9
                    {

                        txtVol08.Text = Convert.ToString(( ( ( ((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f) - 2.48f) / 0.133f);

                    }

                    if (bytDataBuffer[1] == 164) //ANCH09 0xA4 - Servo 15
                    {

                        txtVol09.Text = Convert.ToString((((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f) - 2.48f) / 0.133f);

                    }

                    if (bytDataBuffer[1] == 168) //ANCH10 0xA8 - Pressure Sensor 2
                    {

                        txtVol10.Text = Convert.ToString(( ((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.005f) - 2.48f)/ 0.133f);

                    }
                    /*
                     * NOT NEEDED, THIS IS RX PIN
                    if (bytDataBuffer[1] == 172) //ANCH11 0xAC
                    {

                        txtVol11.Text = Convert.ToString((((bytDataBuffer[2] * 256) + bytDataBuffer[3])) * 0.004882813f);

                    }
                    */

                    if (bytDataBuffer[1] == 176) // IR PAIR 0
                    {
                        if (Convert.ToInt16(bytDataBuffer[2] + bytDataBuffer[3]) == 159)
                        {
                            txtIRP0.Text = "OPEN";
                        }
                        else if (Convert.ToInt16(bytDataBuffer[2] + bytDataBuffer[3]) == 151)
                        {
                            txtIRP0.Text = "CLOSED";
                        }
                        else
                        {
                            txtIRP0.Text = "ERROR";
                        }  
             
                    }

                    if (bytDataBuffer[1] == 180) // IR PAIR 1
                    {
                        if (Convert.ToInt16(bytDataBuffer[2] + bytDataBuffer[3]) == 159)
                        {
                            txtIRP1.Text = "OPEN";
                        }
                        else if (Convert.ToInt16(bytDataBuffer[2] + bytDataBuffer[3]) == 151)
                        {
                            txtIRP1.Text = "CLOSED";
                        }
                        else
                        {
                            txtIRP1.Text = "ERROR";
                        }
                    }

                    else
                    {
                        iTest++;
                        textBox1.Text = iTest.ToString();
                        //textSndCom.Text = "Error!!";
                        Thread.Sleep(iThreadSleep);
                    }
                    #endregion Sensor Calculations

                }

                //iTest++;
                //textBox1.Text = iTest.ToString();
                Thread.Sleep(iThreadSleep);
            }
            while (true);
            
        }

        private void sp_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            //textBox2.Text = "DATA RECIEVED!";
            bSerialChk = true;
            iTest++;
            textBox3.Text = iTest.ToString();
           /* if (iDataCount > 6)
            {
                // funcComDataIn();
                iDataCount = 0;     //reset byte count;
            }
            else
            {
                iDataCount++;
            }
            */ 
        }

        private void sp_ErrorReceived(object sender, SerialErrorReceivedEventArgs e)
        {
            iTest1++;
            textBox1.Text = iTest.ToString();
        }

        //end COM Port background thread
        #endregion


        private void frmMain_FormClosed(object sender, FormClosedEventArgs e)
        {
            tSerialDataIn.Abort();  //end thread
            sp.Close();             //close serial port
            sp.Dispose();            
        }
        
    }

}
