using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;


namespace CortexM0_Prog
{

    public static class uucodec
    {
        enum uucodecReturnCode
        {
            UUCODEC_SUCCESS = 0,
            UUCODEC_ARRAYLENGTH,
            UUCODEC_FAILDECODE,
            UUCODEC_BADCHECKSUM,
            UUCODEC_MAX
        }

        public static void uuencodearray(byte [] InputData, out byte[][] Output, out string CheckSum)
        {
            int numberblocks = InputData.Length / 45;
            bool partialblock = false;
            if (InputData.Length % 45 != 0)
            {
                partialblock = true;
                numberblocks++;
            }

            Output = new byte[numberblocks][];

            for (int i = 0; i < numberblocks; i++)
            {
                if ((partialblock == true)&&(i == (numberblocks-1)))
                {
                    int InputLength = InputData.Length % 45;
                    int OutputLength = ((InputLength / 3) + (3 - (InputLength % 3)))*4;
                    Output[i] = new byte[OutputLength + 3];
                }
                else
                {
                    Output[i] = new byte[63];
                }
            }
            CheckSum = "";
            uint CheckSumTemp = 0;

            for (int i = 0; i < numberblocks; i++)
            {
                if (InputData.Length < 46)
                {
                    byte [] EncodedBlock;
                    uuencodeblock(InputData, out EncodedBlock);
                    Array.Copy(EncodedBlock, 0, Output[i], 0, EncodedBlock.Length);
                    Output[i][Output[i].Length - 2] = (byte)'\r';
                    Output[i][Output[i].Length - 1] = (byte)'\n';

                    CheckSumTemp += uucodec.CalcCheckSum(InputData);
                }
                else
                {
                    byte[] DataToEncode = new byte[45];
                    Array.Copy(InputData, DataToEncode, 45);

                    byte [] EncodedBlock;
                    uuencodeblock(DataToEncode, out EncodedBlock);
                    Array.Copy(EncodedBlock, 0, Output[i], 0, EncodedBlock.Length);
                    Output[i][Output[i].Length - 2] = (byte)'\r';
                    Output[i][Output[i].Length - 1] = (byte)'\n';

                    byte[] NewInputData = new byte[InputData.Length - 45];
                    Array.Copy(InputData, 45, NewInputData, 0, NewInputData.Length);
                    InputData = NewInputData;

                    CheckSumTemp += uucodec.CalcCheckSum(DataToEncode);
                }
            }

            CheckSum = Convert.ToString(CheckSumTemp);
        }
        //public static int uudecodestring(byte[] InputData, string CheckSum, out string Output)
        //{
        //    int numberblocks = InputData.Length;
        //    uint CheckSumValue = Convert.ToUInt32(CheckSum);
        //    uint CalculatedCheckSum = 0;

        //    Output = "";

        //    for (int i = 0; i < numberblocks; i++)
        //    {
        //        byte[] EncodedData = Encoding.ASCII.GetBytes(InputData[i]);
        //        byte[] DecodedData;

        //        if (!uucodec.uudecodeblock(EncodedData, out DecodedData))
        //        {
        //            Output = null;
        //            return (int)uucodecReturnCode.UUCODEC_FAILDECODE;
        //        }

        //        string tempstr = Encoding.ASCII.GetString(DecodedData);
        //        CalculatedCheckSum += uucodec.CalcCheckSum(tempstr);
        //        Output += tempstr;
        //    }

        //    if (CheckSumValue != CalculatedCheckSum)
        //    {
        //        Output = null;
        //        return (int)uucodecReturnCode.UUCODEC_BADCHECKSUM;
        //    }

        //    return (int)uucodecReturnCode.UUCODEC_SUCCESS;
        //}

        public static bool uuencodeblock(byte[] InputData, out byte[] EncodedData)
        {

            int Length = InputData.Length;

            if (Length > 45)
            {
                EncodedData = null;
                return false;
            }

            byte[] InputDataPadded;
            int NumberEncodedUnitsRem = Length % 3;

            if (NumberEncodedUnitsRem != 0)
            {
                InputDataPadded = new byte[(Length + (3-NumberEncodedUnitsRem))];

                if ((3-NumberEncodedUnitsRem)==1)
                {
                    InputDataPadded[Length-1] = 0;
                }
                if ((3-NumberEncodedUnitsRem)==2)
                {
                    InputDataPadded[Length-1] = 0;
                    InputDataPadded[Length-2] = 0;
                }
            }
            else
            {
                InputDataPadded = new byte[Length];
            }
            

            for (int i = 0; i < Length; i++)
            {
                InputDataPadded[i] = InputData[i];
            }

            int EncodedBlocks = (InputDataPadded.Length / 3);
            int EncodedLength = EncodedBlocks * 4;

            EncodedData = new byte[EncodedLength+1];

            byte[] DataIn = new byte[3];
            byte[] DataOut;

            EncodedData[0] = (byte) (Length + 32);

            for (int i = 0; i < EncodedBlocks; i++)
            {
                DataIn[0] = InputDataPadded[i * 3];
                DataIn[1] = InputDataPadded[(i * 3) + 1];
                DataIn[2] = InputDataPadded[(i * 3) + 2];
                DataOut = null;

                if (!uucodec.uuencode(DataIn, out DataOut))
                {
                    EncodedData = null;
                    return false;
                }

                EncodedData[(i * 4) + 1] = DataOut[0];
                EncodedData[(i * 4) + 2] = DataOut[1];
                EncodedData[(i * 4) + 3] = DataOut[2];
                EncodedData[(i * 4) + 4] = DataOut[3];
            }
            return true;
        }
        public static bool uudecodeblock(byte[] InputData, out byte[] OutputData)
        {
            int Length = InputData.Length;

            if (Length > 61)
            {
                OutputData = null;
                return false;
            }

            int OriginalDataLength = InputData[0] - 32;
            int EncodedBlocks = Length / 4;
            byte[] DecodedData = new byte[(EncodedBlocks * 3)];

            byte [] Input = new byte[4];
            byte [] Output = new byte[3];

            for (int i = 0; i < EncodedBlocks; i++)
            {
                Input[0] = InputData[(i * 4) + 1];
                Input[1] = InputData[(i * 4) + 2];
                Input[2] = InputData[(i * 4) + 3];
                Input[3] = InputData[(i * 4) + 4];

                if (!uudecode(Input, out Output))
                {
                    OutputData = null;
                    return false;
                }

                DecodedData[i * 3] = Output[0];
                DecodedData[(i * 3) + 1] = Output[1];
                DecodedData[(i * 3) + 2] = Output[2];
            }

            OutputData = new byte[OriginalDataLength];

            for (int i = 0; i < OriginalDataLength; i++)
            {
                OutputData[i] = DecodedData[i];
            }
            return true;
        }

        private static bool uuencode(byte[] Input, out byte[] EncodedData)
        {
            if (Input.Length != 3)
            {
                EncodedData = null;
                return false;
            }
            
            EncodedData = new byte[4];
            EncodedData[0] = (byte) (Input[0] >> 2);
            EncodedData[1] = (byte) (((Input[0] << 4) & 48) | (Input[1] >> 4) & 15);
            EncodedData[2] = (byte) (((Input[1] << 2) & 60) | (Input[2] >> 6));
            EncodedData[3] = (byte) (Input[2] & 63);

            for (int i = 0; i < 4; i++)
            {
                if (EncodedData[i] == 0)
                {
                    EncodedData[i] = (byte)96;
                }
                else
                {
                    EncodedData[i] = (byte)(EncodedData[i] + 32);
                }
            }
            return true;
        }
        private static bool uudecode(byte[] Input, out byte [] DecodedData)
        {
            if (Input.Length != 4)
            {
                DecodedData = null;
                return false;
            }
            Input[0] = (byte)(Input[0] - 32);
            Input[1] = (byte)(Input[1] - 32);
            Input[2] = (byte)(Input[2] - 32);
            Input[3] = (byte)(Input[3] - 32);

            DecodedData = new byte[3];

            DecodedData[0] = (byte)((Input[0] << 2) | (Input[1] >> 4));
            DecodedData[1] = (byte)((Input[1] << 4) | ((Input[2] & 60) >> 2));
            DecodedData[2] = (byte)((Input[2] << 6) | Input[3]);
            
            return true;
        }
        private static uint CalcCheckSum(byte [] Input)
        {
            uint CheckSum = 0;

            for (int i = 0; i < Input.Length; i++)
            {
                CheckSum += (byte) Input[i];
            }

            return CheckSum;
        }
    }
}
