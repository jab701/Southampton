using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;

namespace Spinnaker_Emu
{
    class MemoryRecord
    {
        public uint Address = 0;
        public uint Length = 0;
    }

    class NodeMemory
    {
        private byte[] Memory;
        private uint AvailableBytes;
        private SortedList MemoryMap = new SortedList();
        private SortedList FreeMemoryMap = new SortedList();

        public NodeMemory()
        {
            this.Memory = new byte[134217728];
            this.AvailableBytes = 134217728;
            this.MemoryMap.Clear();
            this.FreeMemoryMap.Clear();
            this.FreeMemoryMap.Add(0, 134217728);
        }
        public NodeMemory(uint Length)
        {
            this.Memory = new byte[Length];
            this.AvailableBytes = Length;
            this.MemoryMap.Clear(); this.FreeMemoryMap.Clear();
            this.FreeMemoryMap.Add(0, Length);
        }
        public bool Delete(uint Address)
        {

        }
        public bool New(uint NumBytes, out uint Address)
        {
            if (this.AvailableBytes < NumBytes)
            {
                Address = 0;
                return false;
            }
            
            // Find a section of memory that is large enough
            uint AllocatedKey = 0;
            bool Allocated = false;
            uint Addr = 0;
            uint Len = 0;

            for (uint i = 0; i < this.FreeMemoryMap.Keys.Count; i++)
            {
                Addr = (uint)this.FreeMemoryMap.GetKey((int)i);
                Len = (uint)this.FreeMemoryMap.GetByIndex((int)i);

                if (Len >= NumBytes)
                {
                    AllocatedKey = i;
                    Allocated = true;
                    break;
                }
            }

            if (Allocated == true)
            {
                // Now add new array to memory map
                this.MemoryMap.Add(Addr, NumBytes);
                // Remove Allocated Address from free memory map
                this.FreeMemoryMap.Remove(AllocatedKey);

                if (Len - NumBytes != 0) // Check if all the free black was used
                {
                    // if the free space wasnt completely used make record for the remainder
                    uint NewFreeAddr = Addr + NumBytes;
                    uint NewFreeLen = Len - NumBytes;
                    this.FreeMemoryMap.Add(NewFreeAddr, NewFreeLen);
                }
                // Update the number of free bytes
                this.AvailableBytes = this.AvailableBytes - NumBytes;
                Address = Addr;
                return true;
            }
            else
            {
                Address = 0;
                return false;
            }
        }
        public bool Read(uint Address, out byte Data)
        {

        }
        public bool Read(uint Address, out ushort Data)
        {

        }
        public bool Read(uint Address, out uint Data)
        {

        }
        public bool Read(uint Address, uint Size, out byte[] Data)
        {

        }
        public bool Read(uint Address, uint Size, out ushort[] Data)
        {

        }
        public bool Read(uint Address, uint Size, out uint[] Data)
        {

        }
        public bool Write(uint Address, byte Data)
        {

        }
        public bool Write(uint Address, ushort Data)
        {

        }
        public bool Write(uint Address, uint Data)
        {

        }
        public bool Write(uint Address, byte[] Data)
        {

        }
        public bool Write(uint Address, ushort[] Data)
        {

        }
        public bool Write(uint Address, uint[] Data)
        {

        }
    }
}
