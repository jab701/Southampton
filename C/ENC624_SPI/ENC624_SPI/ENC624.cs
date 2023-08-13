using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ENC624
{
    public class SRAM
    {
        public const UInt16 BUF_ORG = 0x0000;
        public const UInt16 BUF_TOP = 0x5FFF;

        public const UInt16 CRYPT_ORG = 0x7800;
        public const UInt16 CRYPT_TOP = 0x7C4F;
    }
    public class SFR
    {
        // Unbanked Registers
        public const byte ETXSTL = 0x00;
        public const byte ETXSTH = 0x01;
        public const byte ETXLENL = 0x02;
        public const byte ETXLENH = 0x03;
        public const byte ERXSTL = 0x04;
        public const byte ERXSTH = 0x05;
        public const byte ERXTAILL = 0x06;
        public const byte ERXTAILH = 0x07;
        public const byte ERXHEADL = 0x08;
        public const byte ERXHEADH = 0x09;
        public const byte EDMASTL = 0x0A;
        public const byte EDMASTH = 0x0B;
        public const byte EDMALENL = 0x0C;
        public const byte EDMALENH = 0x0D;
        public const byte EDMADSTL = 0x0E;
        public const byte EDMADSTH = 0x0F;
        public const byte EDMACSL = 0x10;
        public const byte EDMACSH = 0x11;
        public const byte ETXSTATL = 0x12;
        public const byte ETXSTATH = 0x13;
        public const byte ETXWIREL = 0x14;
        public const byte ETXWIREH = 0x15;
        public const byte EUDASTL = 0x16;
        public const byte EUDASTH = 0x17;
        public const byte EUDANDL = 0x18;
        public const byte EUDANDH = 0x19;
        public const byte ESTATL = 0x1A;
        public const byte ESTATH = 0x1B;
        public const byte EIRL = 0x1C;
        public const byte EIRH = 0x1D;
        public const byte ECON1L = 0x1E;
        public const byte ECON1H = 0x1F;

        public const byte EHT1L = 0x20;
        public const byte EHT1H = 0x21;
        public const byte EHT2L = 0x22;
        public const byte EHT2H = 0x23;
        public const byte EHT3L = 0x24;
        public const byte EHT3H = 0x25;
        public const byte EHT4L = 0x26;
        public const byte EHT4H = 0x27;
        public const byte EPMM1L = 0x28;
        public const byte EPMM1H = 0x29;
        public const byte EPMM2L = 0x2A;
        public const byte EPMM2H = 0x2B;
        public const byte EPMM3L = 0x2C;
        public const byte EPMM3H = 0x2D;
        public const byte EPMM4L = 0x2E;
        public const byte EPMM4H = 0x2F;
        public const byte EPMCSL = 0x30;
        public const byte EPMCSH = 0x31;
        public const byte EPMOL = 0x32;
        public const byte EPMOH = 0x33;
        public const byte ERXCONL = 0x34;
        public const byte ERMCONH = 0x35;
        // SFR 0x36 - 0x3F Copies of 0x16 - 0x1f

        public const byte MACON1L = 0x40;
        public const byte MACON1H = 0x41;
        public const byte MACON2L = 0x42;
        public const byte MACON2H = 0x43;
        public const byte MABBIPGL = 0x44;
        public const byte MABBIPGH = 0x45;
        public const byte MAIPGL = 0x46;
        public const byte MAIPGH = 0x47;
        public const byte MACLCONL = 0x48;
        public const byte MACLCONH = 0x49;
        public const byte MAMXFLL = 0x4A;
        public const byte MAMXFLH = 0x4B;
        // SFR 0X4C - 0X51 RESERVED 
        public const byte MICMDL = 0x52;
        public const byte MICMDH = 0x53;
        public const byte MIREGADRL = 0x54;
        public const byte MIREGADRH = 0x55;
        // SFR 0x56 - 0x5F Copies of 0x16 - 0x1f

        public const byte MAADR3H = 0x60;
        public const byte MAADR3L = 0x61;
        public const byte MAADR2H = 0x62;
        public const byte MAADR2L = 0x63;
        public const byte MAADR1H = 0x64;
        public const byte MAADR1L = 0x65;
        public const byte MIWRL = 0x66;
        public const byte MIWRH = 0x67;
        public const byte MIRDL = 0x68;
        public const byte MIRDH = 0x69;
        public const byte MISTATL = 0x6A;
        public const byte MISTATH = 0x6B;
        public const byte EPAUSL = 0x6C;
        public const byte EPAUSH = 0x6D;
        public const byte ECON2L = 0x6E;
        public const byte ECON2H = 0x6F;
        public const byte ERXWML = 0x70;
        public const byte ERXWMH = 0x71;
        public const byte EIEL = 0x72;
        public const byte EIEH = 0x73;
        public const byte EIDLEDL = 0x74;
        public const byte EIDLEDH = 0x75;
        // SFR 0x75 - 0x7f Copies of 0x16 - 0x1f

        public const byte EGPDATA = 0x80;
        // SFR 0x81 Reserved
        public const byte ERXDATA = 0x82;
        // SFR 0x83 Reserved
        public const byte EUDADATA = 0x84;
        // SFR 0x85 Reserved
        public const byte EGPRDPTL = 0x86;
        public const byte EGPRDPTH = 0x87;
        public const byte EDPWRPTL = 0x88;
        public const byte EDPWRPTH = 0x89;
        public const byte ERXRDPTL = 0x8A;
        public const byte ERXRDPTH = 0x8B;
        public const byte ERXWRPTL = 0x8C;
        public const byte ERXWRPTH = 0x8D;
        public const byte EUDARDPTL = 0x8E;
        public const byte EUDARDPTH = 0x8F;
        public const byte EUDAWRPTL = 0x90;
        public const byte EUDAWRPTH = 0x91;
        // SFR 0x92 - 0x9D are reserved
        // SFR 0x9E & 0x9F not implemented.
    }
    public class BANKED_SFR
    {
        // Banked Registers
        public const byte BANK_0 = 0x00;
        public const byte BANK_1 = 0x20;
        public const byte BANK_2 = 0x40;
        public const byte BANK_3 = 0x60;

        // Common Registers (Same for all banks)
        public const byte EUDASTL = 0x16;
        public const byte EUDASTH = 0x17;
        public const byte EUDANDL = 0x18;
        public const byte EUDANDH = 0x19;
        public const byte ESTATL = 0x1A;
        public const byte ESTATH = 0x1B;
        public const byte EIRL = 0x1C;
        public const byte EIRH = 0x1D;
        public const byte ECON1L = 0x1E;
        public const byte ECON1H = 0x1F;

        // SFR BANK 0
        public const byte ETXSTL = 0x00;
        public const byte ETXSTH = 0x01;
        public const byte ETXLENL = 0x02;
        public const byte ETXLENH = 0x03;
        public const byte ERXSTL = 0x04;
        public const byte ERXSTH = 0x05;
        public const byte ERXTAILL = 0x06;
        public const byte ERXTAILH = 0x07;
        public const byte ERXHEADL = 0x08;
        public const byte ERXHEADH = 0x09;
        public const byte EDMASTL = 0x0A;
        public const byte EDMASTH = 0x0B;
        public const byte EDMALENL = 0x0C;
        public const byte EDMALENH = 0x0D;
        public const byte EDMADSTL = 0x0E;
        public const byte EDMADSTH = 0x0F;
        public const byte EDMACSL = 0x10;
        public const byte EDMACSH = 0x11;
        public const byte ETXSTATL = 0x12;
        public const byte ETXSTATH = 0x13;
        public const byte ETXWIREL = 0x14;
        public const byte ETXWIREH = 0x15;

        // SFR Bank 1
        public const byte EHT1L = 0x00;
        public const byte EHT1H = 0x01;
        public const byte EHT2L = 0x02;
        public const byte EHT2H = 0x03;
        public const byte EHT3L = 0x04;
        public const byte EHT3H = 0x05;
        public const byte EHT4L = 0x06;
        public const byte EHT4H = 0x07;
        public const byte EPMM1L = 0x08;
        public const byte EPMM1H = 0x09;
        public const byte EPMM2L = 0x0A;
        public const byte EPMM2H = 0x0B;
        public const byte EPMM3L = 0x0C;
        public const byte EPMM3H = 0x0D;
        public const byte EPMM4L = 0x0E;
        public const byte EPMM4H = 0x0F;
        public const byte EPMCSL = 0x10;
        public const byte EPMCSH = 0x11;
        public const byte EPMOL = 0x12;
        public const byte EPMOH = 0x13;
        public const byte ERXCONL = 0x14;
        public const byte ERMCONH = 0x15;

        // SFR Bank 2
        public const byte MACON1L = 0x00;
        public const byte MACON1H = 0x01;
        public const byte MACON2L = 0x02;
        public const byte MACON2H = 0x03;
        public const byte MABBIPGL = 0x04;
        public const byte MABBIPGH = 0x05;
        public const byte MAIPGL = 0x06;
        public const byte MAIPGH = 0x07;
        public const byte MACLCONL = 0x08;
        public const byte MACLCONH = 0x09;
        public const byte MAMXFLL = 0x0A;
        public const byte MAMXFLH = 0x0B;
        public const byte MICMDL = 0x12;
        public const byte MICMDH = 0x13;
        public const byte MIREGADRL = 0x14;
        public const byte MIREGADRH = 0x15;

        // SFR Bank 3
        public const byte MAADR3H = 0x00;
        public const byte MAADR3L = 0x01;
        public const byte MAADR2H = 0x02;
        public const byte MAADR2L = 0x03;
        public const byte MAADR1H = 0x04;
        public const byte MAADR1L = 0x05;
        public const byte MIWRL = 0x06;
        public const byte MIWRH = 0x07;
        public const byte MIRDL = 0x08;
        public const byte MIRDH = 0x09;
        public const byte MISTATL = 0x0A;
        public const byte MISTATH = 0x0B;
        public const byte EPAUSL = 0x0C;
        public const byte EPAUSH = 0x0D;
        public const byte ECON2L = 0x0E;
        public const byte ECON2H = 0x0F;
        public const byte ERXWML = 0x10;
        public const byte ERXWMH = 0x11;
        public const byte EIEL = 0x12;
        public const byte EIEH = 0x13;
        public const byte EIDLEDL = 0x14;
        public const byte EIDLEDH = 0x15;
    }
    public class INSTRUCTIONS
    {
        // Single Byte Instruction
        public const byte B0SEL         = 0xC0;
        public const byte B1SEL         = 0xC2;
        public const byte B2SEL         = 0xC4;
        public const byte B3SEL         = 0xC6;
        public const byte SETETHRST     = 0xCA;
        public const byte FCDISABLE     = 0xE0;
        public const byte FCSINGLE      = 0xE2;
        public const byte FCMULTIPLE    = 0xE4;
        public const byte FCCLEAR       = 0xE6;
        public const byte SETPKTDEC     = 0xCC;
        public const byte DMASTOP       = 0xD2;
        public const byte DMACKSUM      = 0xD8;
        public const byte DMACKSUMS     = 0xDA;
        public const byte DMACOPY       = 0xDC;
        public const byte DMACOPYS      = 0xDE;
        public const byte SETTXRTS      = 0xD4;
        public const byte ENABLERX      = 0xE8;
        public const byte DISABLERX     = 0xEA;
        public const byte SETEIE        = 0xEC;
        public const byte CLREIE        = 0xEE;
        // Two Byte Instruction
        public const byte RBSEL         = 0xC8;
        // Three Byte Instruction
        public const byte WGPRDPT       = 0x60;
        public const byte RGPRDPT       = 0x62;
        public const byte WRXRDPT       = 0x64;
        public const byte RRXRDPT       = 0x66;
        public const byte WUDARDPT      = 0x68;
        public const byte RUDARDPT      = 0x6A;
        public const byte WGPWRPT       = 0x6C;
        public const byte RGPWRPT       = 0x6E;
        public const byte WRXWRPT       = 0x70;
        public const byte RRXWRPT       = 0x72;
        public const byte WUDAWRPT      = 0x74;
        public const byte RUDAWRPT      = 0x76;
        // N Byte Instruction
        public const byte RCR           = 0x00;
        public const byte WCR           = 0x40;
        public const byte RCRU          = 0x20;
        public const byte WCRU          = 0x22;
        public const byte BFS           = 0x80;
        public const byte BFC           = 0xC0;
        public const byte BFSU          = 0x24;
        public const byte BFCU          = 0x26;
        public const byte RGPDATA       = 0x28;
        public const byte WGPDATA       = 0x2A;
        public const byte RRXDATA       = 0x2C;
        public const byte WRXDATA       = 0x2E;
        public const byte RUDADATA      = 0x30;
        public const byte WUDADATA      = 0x32;
    }
    class ENC624_SPI
    {
        public byte Write(byte OpCode)
        {

        }
        public byte Write(byte OpCode, byte[] Data)
        {

        }
        public byte Send(byte OpCode, byte[] DataSend, out byte[] DataRecv)
        {

        }

        public byte ReadBankSelect(out byte Bank)
        {
            byte [] Data = new byte[1];

            byte RC = Read(INSTRUCTIONS.RBSEL, 1, out Data);

            Bank = Data[0];

            return RC;
        }
        
        public byte ReadSFRBanked(byte Address, uint NumBytes, out byte [] Data)
        {
            byte Op = (byte)(INSTRUCTIONS.RCR | (Address & 0x1F));

            byte RC = Read(Op, NumBytes, out Data);

            return RC;
        }
        public byte WriteSFRBanked(byte Address, byte [] Data)
        {
            byte Op = (byte)(INSTRUCTIONS.WCR | (Address & 0x1F));

            byte RC = Write(Op, Data);

            return RC;
        }
        public byte BitFieldSetBanked(byte Address, byte[] Data)
        {
            byte Op = (byte)(INSTRUCTIONS.BFS | (Address & 0x1F));

            byte RC = Write(Op, Data);

            return RC;
        }
        public byte BitFieldClrBanked(byte Address, byte[] Data)
        {
            byte Op = (byte)(INSTRUCTIONS.BFC | (Address & 0x1F));

            byte RC = Write(Op, Data);

            return RC;
        }

        public byte ReadSFRUnbanked(byte Address, uint NumBytes, out byte[] Data)
        {
            byte Op = (byte)INSTRUCTIONS.RCRU;

            byte[] DataToSend = new byte[NumBytes + 1];
            byte[] DataToRecv;

            DataToSend[0] = Address;

            byte RC = Send(Op, DataToSend, out DataToRecv);

            Data = new byte[DataToRecv.Length - 1];

            Array.Copy(DataToRecv, 1, Data, 0, Data.Length);

            return RC;
        }
        public byte WriteSFRUnbanked(byte Address, byte[] Data)
        {
            byte Op = (byte)INSTRUCTIONS.WCRU;

            byte[] DataToSend = new byte[Data.Length + 1];
            byte[] DataToRecv;

            DataToSend[0] = Address;

            Array.Copy(Data, 0, DataToSend, 1, Data.Length);

            byte RC = Send(Op, Data, out DataToRecv);

            return RC;
        }
        public byte BitFieldSetUnbanked(byte Address, byte[] Data)
        {
            byte Op = (byte)INSTRUCTIONS.BFSU;

            byte[] DataToSend = new byte [Data.Length + 1];
            byte[] DataToRecv;

            DataToSend[0] = Address;

            Array.Copy(Data, 0, DataToSend, 1, Data.Length);

            byte RC = Send(Op, DataToSend, out DataToRecv);

            return RC;
        }
        public byte BitFieldClrUnbanked(byte Address, byte[] Data)
        {
            byte Op = (byte)INSTRUCTIONS.BFCU;

            byte[] DataToSend = new byte[Data.Length + 1];
            byte[] DataToRecv;

            DataToSend[0] = Address;

            Array.Copy(Data, 0, DataToSend, 1, Data.Length);

            byte RC = Send(Op, DataToSend, out DataToRecv);

            return RC;
        }
    }
}
