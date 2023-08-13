using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SDP
{
    public static class Utility
    {
        public static byte[][] Allocate256ByteBlockArray(uint Length)
        {
            uint NumberChunks = Length / 256;
            uint Remainder = Length % 256;

            byte[][] DataChunks;

            if (Remainder == 0)
            {
                DataChunks = new byte[NumberChunks][];
            }
            else
            {
                NumberChunks++;
                DataChunks = new byte[NumberChunks][];
            }

            for (uint i = 0; i < NumberChunks; i++)
            {
                if ((i == (NumberChunks - 1)) && (Remainder != 0))
                {
                    DataChunks[i] = new byte[Remainder];
                }
                else
                {
                    DataChunks[i] = new byte[256];
                }
            }

            return DataChunks;
        }
        public static void To256ByteBlocks(byte[] DataIn, out byte[][] DataOut)
        {
            uint NumberChunks;
            uint Remainder = (uint)(DataIn.Length % 256);

            if (Remainder == 0)
            {
                NumberChunks = (uint)(DataIn.Length / 256);
            }
            else
            {
                NumberChunks = (uint)(DataIn.Length / 256);
                NumberChunks++;
            }

            DataOut = new byte[NumberChunks][];

            for (uint i = 0; i < NumberChunks; i++)
            {
                if ((i == (NumberChunks - 1)) && (Remainder != 0))
                {
                    DataOut[i] = new byte[Remainder];
                }
                else
                {
                    DataOut[i] = new byte[256];
                }
                Array.Copy(DataIn, i * 256, DataOut[i], 0, DataOut[i].Length);
            }
        }
        public static void From256ByteBlocks(byte[][] DataIn, out byte[] DataOut)
        {
            uint NumberChunks = (uint)DataIn.Length;
            uint LastChunk = (uint)DataIn[NumberChunks - 1].Length;

            uint DataLength = ((NumberChunks - 1) * 256) + LastChunk;

            DataOut = new byte[DataLength];

            for (uint i = 0; i < NumberChunks; i++)
            {
                Array.Copy(DataIn[i], 0, DataOut, i * 256, DataIn[i].Length);
            }
        }
    }
}
