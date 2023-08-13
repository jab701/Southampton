using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace Spinnaker_Emu
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            ApplicationThread.EnableVisualStyles();
            ApplicationThread.SetCompatibleTextRenderingDefault(false);
            ApplicationThread.Run(new Form1());
        }
    }
}
